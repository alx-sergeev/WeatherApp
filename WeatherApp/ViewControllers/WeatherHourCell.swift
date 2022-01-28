//
//  WeatherHourCell.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 27.01.2022.
//

import UIKit

class WeatherHourCell: UICollectionViewCell {
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    func configureCell(at index: Int, weathers: [WeatherItem]) {
        let weather = weathers[index]
        
        guard let date = weather.date,
              let weatherMain = weather.main,
              let weatherWeather = weather.weather?.first else { return }
        
        guard
            let weatherTemp = weatherMain.temp,
            let weatherIcon = weatherWeather.icon else { return }

        hourLabel.text = date.resultTime

        dayLabel.text = ""
        if index == 0 {
            dayLabel.text = "Сегодня"
        } else if (index > 0) && (weathers[index - 1].date?.resultDay != date.resultDay) {
            dayLabel.text = date.resultDay
        }

        weatherImageView.image = UIImage(named: weatherIcon)
        temperatureLabel.text = "\(Int(weatherTemp))°"
    }
}
