//
//  ViewController.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 24.01.2022.
//

import UIKit
import CoreLocation
import Alamofire

class ViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noCityTextStack: UIStackView!
    
    
    // MARK: - Properties
    private let segueFromCityToMain = "fromCityToMain"
    private var locationManager = CLLocationManager()
    private var currentLoc: CLLocation?
    private var currentWeather: CurrentWeather!
    private let storageManager = StorageManager.shared
    private var getCities: [City] {
        storageManager.getCities()
    }
    var cityIndexPath: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Блок с текстом об отсутсвии городов
        noCityTextStack.isHidden = false
        
        // Labels
        cityLabel.isHidden = true
        weatherLabel.isHidden = true
        temperatureLabel.isHidden = true
        
        // Индикатор загрузки
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true

        // Геолокация
        locationManager.delegate = self
        
        if getCities.isEmpty {
            locationManager.requestWhenInUseAuthorization()
        } else {
            getCurrentWeather(city: getCities[0].name)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !getCities.isEmpty && currentWeather == nil {
            guard let city = getCities.first?.name else { return }
            getCurrentWeather(city: city)
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard segue.identifier == segueFromCityToMain else { return }
        guard let _ = segue.source as? CitiesViewController else { return }
        
        if cityIndexPath != nil {
            getCurrentWeather(city: getCities[cityIndexPath].name)
        }
    }
}

// MARK: - CLLocationManagerDelegate?
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied, .notDetermined:
            break

        case .authorizedWhenInUse, .authorizedAlways:
            guard getCities.isEmpty else { return }
            guard let currentLoc = locationManager.location else { return }

            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(currentLoc) { [weak self] placemarks, error in
                guard let self = self, let placeMark = placemarks?.first else { return }

                if let city = placeMark.subAdministrativeArea {
                    self.confirmSelectCity(city)
                }
            }
            break
        default:
            break
        }
    }
}

extension ViewController {
    // Подтверждение определения текущего города пользователя
    func confirmSelectCity(_ city: String) {
        let alert = UIAlertController(title: "Выбор города", message: "Ваш город \(city)?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let _ = self.storageManager.addCity(city: City(name: city), at: 0)
            self.getCurrentWeather(city: city)
        }
        let otherAction = UIAlertAction(title: "Нет", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.dismiss(animated: true) {
                self.tabBarController?.selectedIndex = 1
            }
        }
        
        alert.addAction(okAction)
        alert.addAction(otherAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func getCurrentWeather(city: String) {
        guard let currentCity = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        let urlPath = "http://api.openweathermap.org/data/2.5/forecast?q=\(currentCity)&appid=8765be3815e47d66a00ae2f6f9b622d9&lang=ru&units=metric&cnt=1"
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        AF.request(urlPath, method: .get)
        .validate()
        .responseDecodable(of: WeatherData.self) { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .success(let weatherData):
                guard let currentTemp = weatherData.list?[0].main?.temp,
                      let currentDescription = weatherData.list?[0].weather?[0].description else { return }

                let currentWeather = CurrentWeather(temp: currentTemp, description: currentDescription)

                self.currentWeather = currentWeather
                self.updateUICurrentWeather(city: city)
                
                self.activityIndicator.stopAnimating()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Обновление UI информации о текущей погоде
    func updateUICurrentWeather(city: String) {
        guard let weather = currentWeather else { return }
        
        cityLabel.text = city
        weatherLabel.text = weather.description.capitalizingFirstLetter()
        temperatureLabel.text = "\(Int(weather.temp))°"
        
        noCityTextStack.isHidden = true
        cityLabel.isHidden = false
        weatherLabel.isHidden = false
        temperatureLabel.isHidden = false
    }
}
