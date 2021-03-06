//
//  WeatherModel.swift
//  runTime
//
//  Created by michael taylor on 10/9/20.
//

import Foundation

struct WeatherModel {
    let conditionId: Int
    var cityName: String
    let temperatureF: Double
    let temperatureC: Double
    let humidity: Double
    let feelsLikeF: Double
    let feelsLikeC: Double
    let windSpeed: Double
    let uvRating: Double
    let chanceOfRain: Double
    let chanceOfSnow: Double
    let currentHour: Int
    let isDay: Int
    let isCelsius: Bool
    var temperatureStringF: String {
        return String(format: "%.1f", feelsLikeF)
    }
    var temperatureStringC: String {
        return String(format: "%.1f", feelsLikeC)
    }
    
    
    var hoursArray: [WeatherModel]
    
    var conditionName: String {
        if (isDay == 1) {
            switch conditionId {
            case 1000:
                return "sun.max"
            case 1003:
                return "cloud.sun"
            case 1006...1009:
                return "cloud"
            case 1183...1189, 1063, 1150, 1153, 1168, 1171, 1180, 1240:
                return "cloud.drizzle"
            case 1192, 1195, 1198, 1201, 1243, 1246:
                return "cloud.heavyrain"
            case 1087, 1273, 1276, 1279, 1282:
                return "cloud.bolt"
            case 1213...1219, 1066, 1069, 1072, 1114, 1204, 1207, 1210, 1249, 1252, 1255, 1261, 1264:
                return "cloud.snow"
            case 1135,1147, 1030:
                return "cloud.fog"
            case 1225,1117, 1222, 1237, 1258:
                return "snow"
            default:
                return "sun.min"
            }

        } else {
            switch conditionId {
            case 1000:
                return "moon.stars"
            case 1003:
                return "cloud.moon"
            case 1006...1009:
                return "cloud"
            case 1183...1189,1063,1150, 1153, 1168, 1171, 1180, 1240:
                return "cloud.drizzle"
            case 1192, 1195, 1198, 1201, 1243, 1246:
                return "cloud.moon.rain"
            case 1087, 1273, 1276, 1279, 1282:
                return "cloud.bolt"
            case 1213...1219, 1066, 1069, 1072, 1114, 1204, 1207, 1210, 1249, 1252, 1255, 1261, 1264:
                return "cloud.snow"
            case 1135,1147, 1030:
                return "cloud.fog"
            case 1225,1117, 1222, 1237, 1258:
                return "snow"
            default:
                return "moon"
            }
        }
    }
    
    var conditionStatement: String {
        switch getRunningConditions() {
        case 10:
            return "Perfect conditions for a run"
        case 8,9:
            return "Great conditions for a run"
        case 6,7:
            return "Good conditions for a run"
        case 5:
            return "Tough conditions for a run"
        case 2,3,4:
            return "Bad conditions for a run"
        case 0,1:
            return "Terrible conditions, running not recommended"
        default:
            return "Conditions inconclusive"
        }
    }
    
    
    
    func getRunningConditions() -> Int {
        
        let idealTemperature = SettingsModelStore.shared.model?.idealTemperature ?? 65
        let idealHumidity = SettingsModelStore.shared.model?.idealHumidity ?? 40
        let idealWindSpeed = SettingsModelStore.shared.model?.idealWindSpeed ?? 2
        
        func getTempFactor(_ factor: Double = 0.4) -> Double {
            var condition = 10.0
            var tempOffset = 0.0
            
            if temperatureF > idealTemperature {
                tempOffset = temperatureF - idealTemperature
            } else {
                tempOffset = idealTemperature - temperatureF
            }
            
            
            if (10...14.9).contains(tempOffset) {
                condition -= 3
            } else if (15...25.9).contains(tempOffset) {
                condition -= 6
            } else if (26...100).contains(tempOffset) {
                condition -= 9
            }
            return condition * factor
        }
        
        
        
        func getHumidityFactor(_ factor: Double = 0.3) -> Double {
            var condition = 10.0
            var humidityOffset = 0.0
            
            if humidity > idealHumidity {
                humidityOffset = humidity - idealHumidity
            }
            
            if (5...14.9).contains(humidityOffset) {
                condition -= 3
            } else if (15...29.9).contains(humidityOffset) {
                condition -= 6
            } else if (30...100).contains(humidityOffset) {
                condition -= 9
            }
            return condition * factor
            
        }
        
        func getWindFactor(_ factor: Double = 0.2) -> Double {
            var condition = 10.0
            var windSpeedOffset = 0.0
            
            if windSpeed > idealWindSpeed {
                windSpeedOffset = windSpeed - idealWindSpeed
            } else {
                windSpeedOffset = idealWindSpeed - windSpeed
            }
            
            if (2...3.9).contains(windSpeedOffset) {
                condition -= 3
            } else if (4...100).contains(windSpeedOffset) {
                condition -= 6
            }
            return condition * factor
        }
        
        func getPrecipitationFactor() -> Double {
            var condition = 10.0
            
            if (36...47.8).contains(chanceOfRain) || (36...47.8).contains(chanceOfSnow) {
                condition -= 3
            } else if (48...60).contains(chanceOfRain) || (48...60).contains(chanceOfSnow){
                condition -= 6
            } else if chanceOfRain > 60 || chanceOfSnow > 60 {
                condition -= 9
            }
            return condition * 0.1
        }
        
        if SettingsModelStore.shared.model?.ignoreRain ?? false{
            let runningConditions = Int(round(getTempFactor(0.43) + getHumidityFactor(0.33) + getWindFactor(0.23)))
            return runningConditions
        } else {
            let runningConditions =  Int(round(getTempFactor() + getPrecipitationFactor() + getWindFactor() + getHumidityFactor()))
            return runningConditions
        }

     
    }
    
}
