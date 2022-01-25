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
    
    
    // MARK: - Properties
    private var locationManager = CLLocationManager()
    private var currentLoc: CLLocation?
    private var currentWeather: CurrentWeather!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Labels
        cityLabel.isHidden = true
        weatherLabel.isHidden = true
        temperatureLabel.isHidden = true
        
        // Индикатор загрузки
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        // Определяем город пользователя
        locationManager.requestWhenInUseAuthorization()

        if(locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways) {
            guard let currentLoc = locationManager.location else { return }

            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(currentLoc) { [weak self] placemarks, error in
                guard let self = self, let placeMark = placemarks?.first else { return }

                if let city = placeMark.subAdministrativeArea {
                    self.confirmSelectCity(city)
                }
            }
        }
    }
}

extension ViewController {
    // Подтверждение определения текущего города пользователя
    func confirmSelectCity(_ city: String) {
        let alert = UIAlertController(title: "Выбор города", message: "Ваш город \(city)?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let currentCity = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
            
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
            let urlPath = "http://api.openweathermap.org/data/2.5/forecast?q=\(currentCity)&appid=8765be3815e47d66a00ae2f6f9b622d9&lang=ru&units=metric&cnt=1"
            
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
                case .failure(let error):
                    print(error)
                }
            }
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
    
    // Обновление UI информации о текущей погоде
    func updateUICurrentWeather(city: String) {
        guard let weather = currentWeather else { return }
        
        activityIndicator.stopAnimating()
        
        cityLabel.text = city
        weatherLabel.text = weather.description
        temperatureLabel.text = "\(Int(weather.temp))°"
        
        cityLabel.isHidden = false
        weatherLabel.isHidden = false
        temperatureLabel.isHidden = false
    }
}
