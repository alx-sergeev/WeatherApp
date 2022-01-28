//
//  Weather.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 25.01.2022.
//

import Foundation

struct WeatherData: Codable {
    let list: [WeatherItem]?
}

struct WeatherItem: Codable {
    let dt: Double?
    let main: WeatherItemMain?
    let weather: [WeatherItemWeather]?
    var date: (resultDay: String, resultTime: String)? {
        guard let dt = dt else { return nil }
        
        let date = Date(timeIntervalSince1970: dt)
        
        let dateFormatter = DateFormatter()
        
        // Число
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let stringDay = dateFormatter.string(from: date)
        let resultDay = stringDay.prefix(7).trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Время
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let resultTime = dateFormatter.string(from: date)
    
        return (resultDay: resultDay, resultTime: resultTime)
    }
}

struct WeatherItemMain: Codable {
    let temp: Double?
}

struct WeatherItemWeather: Codable {
    let description: String?
    let icon: String?
}

struct CurrentWeather {
    let temp: Double
    let description: String
}
