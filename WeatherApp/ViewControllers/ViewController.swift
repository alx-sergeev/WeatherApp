//
//  ViewController.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 24.01.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noCityTextStack: UIStackView!
    @IBOutlet weak var weatherHourLabel: UILabel!
    @IBOutlet weak var weatherHourCollectionView: UICollectionView!
    
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    private let segueFromCityToMain = "fromCityToMain"
    private var locationManager = CLLocationManager()
    private var currentLoc: CLLocation?
    private var currentWeather: CurrentWeather!
    private let storageManager = StorageManager.shared
    private var getCities: [City] {
        storageManager.getCities()
    }
    var cityIndexPath: Int!
    
    // MARK: - Properties for weatherHourCollectionView
    private let weatherFooterHourCell = "weatherFooterHourCell"
    private let weatherHourCell = "weatherHourCell"
    private let weatherHourVisibleItem: CGFloat = 5
    private let weatherHourSectionInsets = UIEdgeInsets(top: 20, left: 6, bottom: 20, right: 6)
    private let weatherHourItemHeight: CGFloat = 100
    private let weatherHourCount = 56 // на 1 неделю вперед, каждый день по 8 отрезков времени(каждые 3 часа)
    private var weatherHourWeathers: [WeatherItem]! = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UICollectionView
        weatherHourCollectionView.dataSource = self
        weatherHourCollectionView.delegate = self
        weatherHourCollectionView.showsHorizontalScrollIndicator = false
        
        // Блок с текстом об отсутсвии городов
        noCityTextStack.isHidden = false
        
        // Блок с почасовой погодой
        weatherHourCollectionView.isHidden = true
        weatherHourLabel.isHidden = true
        
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
            networkManager.getCurrentWeather(city: getCities[0].name, cntWeather: weatherHourCount) { [unowned self] currentWeather, weatherHourWeathers in
                self.currentWeather = currentWeather
                self.weatherHourWeathers = weatherHourWeathers
                self.updateUICurrentWeather(city: getCities[0].name)
            } onError: {
                self.showAlertErrorWeather()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !getCities.isEmpty && currentWeather == nil {
            guard let city = getCities.first?.name else { return }
            
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            networkManager.getCurrentWeather(city: city, cntWeather: weatherHourCount) { [unowned self] (currentWeather, weatherHourWeathers) in
                self.activityIndicator.stopAnimating()
                
                self.currentWeather = currentWeather
                self.weatherHourWeathers = weatherHourWeathers
                self.updateUICurrentWeather(city: city)
            } onError: {
                self.showAlertErrorWeather()
            }
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard segue.identifier == segueFromCityToMain else { return }
        guard let _ = segue.source as? CitiesViewController else { return }
        
        if cityIndexPath != nil {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            networkManager.getCurrentWeather(city: getCities[cityIndexPath].name, cntWeather: weatherHourCount) { [unowned self] (currentWeather, weatherHourWeathers) in
                self.activityIndicator.stopAnimating()
                
                self.currentWeather = currentWeather
                self.weatherHourWeathers = weatherHourWeathers
                self.updateUICurrentWeather(city: getCities[cityIndexPath].name)
            } onError: {
                self.showAlertErrorWeather()
            }
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
            
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
            self.networkManager.getCurrentWeather(city: city, cntWeather: self.weatherHourCount) { [unowned self] (currentWeather, weatherHourWeathers) in
                self.activityIndicator.stopAnimating()
                
                self.currentWeather = currentWeather
                self.weatherHourWeathers = weatherHourWeathers
                self.updateUICurrentWeather(city: city)
            } onError: {
                self.showAlertErrorWeather()
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
        
        weatherHourCollectionView.reloadData()
        
        cityLabel.text = city
        weatherLabel.text = weather.description.capitalizingFirstLetter()
        temperatureLabel.text = "\(Int(weather.temp))°"
        
        noCityTextStack.isHidden = true
        cityLabel.isHidden = false
        weatherLabel.isHidden = false
        temperatureLabel.isHidden = false
        
        weatherHourCollectionView.isHidden = false
        weatherHourLabel.isHidden = false
    }
    
    // Сообщение о неудачной попытке получения данных о погоде
    func showAlertErrorWeather() {
        let alert = UIAlertController(title: "Ошибка получения данных", message: "Не удалось получить данные о погоде для данного местоположения", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherHourWeathers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: weatherHourCell, for: indexPath) as! WeatherHourCell
        
        let index = indexPath.item
        cell.configureCell(at: index, weathers: weatherHourWeathers)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingWidth = weatherHourSectionInsets.left * (weatherHourVisibleItem + 1)
        let availableWidth = weatherHourCollectionView.frame.width - paddingWidth
        let itemWidth = availableWidth / weatherHourVisibleItem
        
        return CGSize(width: itemWidth, height: weatherHourItemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return weatherHourSectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return weatherHourSectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return weatherHourSectionInsets.left
    }
}
