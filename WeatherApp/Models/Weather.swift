//
//  Weather.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 25.01.2022.
//

struct WeatherData: Codable {
    let list: [WeatherItem]?
}

struct WeatherItem: Codable {
    let main: WeatherItemMain?
    let weather: [WeatherItemWeather]?
}

struct WeatherItemMain: Codable {
    let temp: Double?
}

struct WeatherItemWeather: Codable {
    let description: String?
}

struct CurrentWeather {
    let temp: Double
    let description: String
}
