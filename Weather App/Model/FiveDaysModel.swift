//
//  FiveDaysModel.swift
//  Weather App
//
//  Created by Muhamad Septian Nugraha on 30/11/24.
//

import Foundation

struct FiveDaysModel {
    
    let conditionId: Int
    let temp: Double
    let icon: String
    let date: String
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "Hujan Badai"
        case 300...321:
            return "Hujan Gerimis"
        case 500...531:
            return "Hujan"
        case 600...622:
            return "Salju Berawan"
        case 701...781:
            return "Berkabut"
        case 800:
            return "Cerah"
        case 801...804:
            return "Berawan"
        default:
            return "Berawan"
        }
    }

    var temperatureString: String {
        return String(format: "%.1f", temp)
    }
}


