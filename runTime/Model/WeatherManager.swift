//
//  WeatherManager.swift
//  runTime
//
//  Created by michael taylor on 10/9/20.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

func getDate() -> Int {
    let currentTime = Date()
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("HH")
    let dateTime = formatter.string(from: currentTime)
    return Int(dateTime)!
}

struct WeatherManager {

    let weatherURL = "https://api.weatherapi.com/v1/forecast.json?key=23f7947dc120486e8ef191204201010&days=3"
    
    
    var delegate: WeatherManagerDelegate?
    
    
    var currentHour = getDate()
    
    
    
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        let urlString = "\(weatherURL)&q=lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("Got an error")
                    self.delegate?.didFailWithError(error: error!)
                    
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    
    
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(APIWeatherData.self, from: weatherData)
            
            let name = decodedData.location.name
            let uv = decodedData.current.uv
            var futureWeather: [WeatherModel] = []

            
            for nextHour in currentHour...23 {
                
                let hourlyTemp = decodedData.forecast.forecastday[0].hour[nextHour].temp_f
                let hourlyWind = decodedData.forecast.forecastday[0].hour[nextHour].wind_mph
                let hourlyRain = decodedData.forecast.forecastday[0].hour[nextHour].chance_of_rain
                let hourlyHumidity = decodedData.forecast.forecastday[0].hour[nextHour].humidity
                let hourlyFeelsLike = decodedData.forecast.forecastday[0].hour[nextHour].feelslike_f
                let hourlyConditionId = decodedData.forecast.forecastday[0].hour[nextHour].condition.code
                let hourlyCurrentHour = nextHour
                
                let hourlyWeather = WeatherModel(conditionId: hourlyConditionId,
                                                 cityName: name,
                                                 temperature: hourlyTemp,
                                                 humidity: hourlyHumidity,
                                                 feelsLike: hourlyFeelsLike,
                                                 windSpeed: hourlyWind,
                                                 uvRating: uv,
                                                 chanceOfRain: Double(hourlyRain) ?? 0, currentHour: hourlyCurrentHour,
                                                 hoursArray: [])
                
                
                futureWeather.append(hourlyWeather)
            }

            let temp = decodedData.current.temp_f
            let wind = decodedData.current.wind_mph
            let rain = decodedData.forecast.forecastday[0].hour[currentHour].chance_of_rain
            let humidity = decodedData.current.humidity
            let feelsLike = decodedData.current.feelslike_f
            let conditionId = decodedData.current.condition.code
            
            
            let currentWeather = WeatherModel(conditionId: conditionId,
                                       cityName: name,
                                       temperature: temp,
                                       humidity: humidity,
                                       feelsLike: feelsLike,
                                       windSpeed: wind,
                                       uvRating: uv,
                                       chanceOfRain: Double(rain) ?? 0, currentHour: currentHour,
                                       hoursArray: futureWeather)
            
            
            return currentWeather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}



