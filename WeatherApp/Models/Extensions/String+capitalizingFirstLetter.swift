//
//  String+capitalizingFirstLetter.swift
//  WeatherApp
//
//  Created by Сергеев Александр on 26.01.2022.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
   }
}
