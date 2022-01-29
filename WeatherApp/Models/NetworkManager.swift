//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 25.01.2022.
//

import Alamofire

class NetworkManager {
    private init() {}
    
    static let shared = NetworkManager()
    private static let apiKey = "8765be3815e47d66a00ae2f6f9b622d9"
    private static var apiUrl: String {
        "http://api.openweathermap.org/data/2.5/forecast?appid=\(NetworkManager.apiKey)&lang=ru&units=metric"
    }
    
    // Получение погоды для города по API
    func getCurrentWeather(city: String, cntWeather: Int = 1, onSuccess: @escaping (CurrentWeather, [WeatherItem]?) -> (), onError: @escaping () -> ()) {
        guard let currentCity = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        let urlPath = NetworkManager.apiUrl + "&cnt=\(cntWeather)&q=\(currentCity)"
        
        AF.request(urlPath, method: .get)
        .validate()
        .responseDecodable(of: WeatherData.self) { response in
            switch response.result {
            case .success(let weatherData):
                guard let currentTemp = weatherData.list?[0].main?.temp,
                      let currentDescription = weatherData.list?[0].weather?[0].description else { return }

                let currentWeather = CurrentWeather(temp: currentTemp, description: currentDescription)
                
                onSuccess(currentWeather, weatherData.list)
            case .failure(_):
                onError()
            }
        }
    }
}
