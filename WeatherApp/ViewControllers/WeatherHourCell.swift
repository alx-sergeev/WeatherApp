//
//  WeatherHourCell.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 27.01.2022.
//

import UIKit

enum WeatherImage {
    
}

class WeatherHourCell: UICollectionViewCell {
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    func configureCell(weather: WeatherItem, dateFormatter: (_ unixUTC: Double) -> (String, String)) {
        guard let dt = weather.dt else { return }
        guard let weatherItemWeather = weather.weather?.first, let weatherIcon = weatherItemWeather.icon else { return }
        guard let weatherMain = weather.main, let weatherTemp = weatherMain.temp else { return }
        
        let (resultDay, resultTime) = dateFormatter(dt)
        hourLabel.text = resultTime
        dayLabel.text = resultDay
        weatherImageView.image = UIImage(named: weatherIcon)
        
        temperatureLabel.text = "\(Int(weatherTemp))"
    }
}
