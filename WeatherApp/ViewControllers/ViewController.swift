//
//  ViewController.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 24.01.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    private var locationManager = CLLocationManager()
    private var currentLoc: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    func confirmSelectCity(_ city: String) {
        let alert = UIAlertController(title: "Выбор города", message: "Ваш город \(city)?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Да", style: .default, handler: nil)
        let otherAction = UIAlertAction(title: "Нет", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.tabBarController?.selectedIndex = 1
        }
        
        alert.addAction(okAction)
        alert.addAction(otherAction)
        
        present(alert, animated: true, completion: nil)
    }
}
