//
//  WeatherManager.swift
//  Clima
//
//  Created by Macbook on 23/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?q=tokyo&appid=71dcd98ec389c9b71d35b3474033e478&units=metric"
    var delegate: WeatherManagerDelegate?

    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        PerformRequest(urlString: urlString)
    }
    
    //Networking
    func PerformRequest(urlString: String){
        //1.Create URL
        if let url = URL(string: urlString){
            //2.Create URL Session
            let session = URLSession(configuration: .default)
            //3.give the session a task
            let task = session.dataTask(with: url) { (data, urlRespone, error) in
                
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(weatherManager: self, weather: weather)
                    }
                }
            }
            //4.start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
        let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(condition: id, name: name, temperature: temp)
            
            return weather
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
            
        }
    }
}

