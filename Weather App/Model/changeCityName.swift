//
//  changeCityName.swift
//  Weather App
//
//  Created by Muhamad Septian Nugraha on 01/12/24.
//

import UIKit

extension String {
    func changeCityName() -> String {
        let wordsToRemove = ["Kabupaten ", "Kota ", " Timur", " Barat", " Utara", " Selatan", " Pusat" ," Tenggara", " Tengah"]
        var newCityName = self
        for word in wordsToRemove {
            newCityName = newCityName.replacingOccurrences(of: word, with: "", options: .caseInsensitive, range: nil)
        }
        return newCityName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
    }
}
