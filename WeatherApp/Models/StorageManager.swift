//
//  StorageManager.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 25.01.2022.
//

import Foundation

class StorageManager {
    private init() {}
    
    static let shared = StorageManager()
    
    // MARK: - Properties
    private let citiesKey = "cities"
    private let userDefaults = UserDefaults.standard
    
    // Получить список городов
    func getCities() -> [City] {
        guard let data = userDefaults.value(forKey: citiesKey) as? Data,
              let cities = try? JSONDecoder().decode([City].self, from: data) else { return [] }
        
        return cities
    }
    
    // Добавить город
    func addCity(city: City) -> Bool {
        var cities = getCities()
        
        cities.append(city)
        
        guard let data = try? JSONEncoder().encode(cities) else { return false }
        
        userDefaults.set(data, forKey: citiesKey)
        
        return true
    }
    
    // Удалить город
    func deleteCity(at index: Int) -> City? {
        var cities = getCities()
        let currentCity = cities.remove(at: index)
        
        guard let data = try? JSONEncoder().encode(cities) else { return nil }
        userDefaults.set(data, forKey: citiesKey)
        
        return currentCity
    }
}
