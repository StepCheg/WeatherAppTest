//
//  ApiHelper.swift
//  WeatherAppTest
//
//  Created by Stepan Chegrenev on 25.03.2018.
//  Copyright © 2018 Stepan Chegrenev. All rights reserved.
//

import Foundation

class ApiHelper {
    
    public enum HttpMethod: Int {
        case post   = 1
        case get    = 2
    }
    
    public enum ApiMethod: String {
        case locationSearch = "api/location/search/"
        case location       = "api/location/"
    }
    
    let coreDataHelper = CoreDataHelper()
    var url = "https://www.metaweather.com/"
    var temp: String?
    var cityName: String?
    var cityWoeid: String?
    var weatherStateAbbr: String?
    var weatherStateName: String?
    
    func changeURLForGetRequest(urlString: String, apiMethod: ApiMethod, params: [String:String]) -> String {
        var paramString = urlString
        paramString += apiMethod.rawValue
        
        var counter = 0
        
        if apiMethod == .locationSearch {
            paramString += "?"
            for item in params {
                counter += 1
                paramString += item.key
                paramString += "="
                paramString += item.value
                if params.count > 1 && params.count != counter {
                    paramString += "&"
                }
            }
        } else if apiMethod == .location {
            paramString += params["woeid"]!
            paramString += "/"
        }
        return paramString
    }
    
    func getOrPostRequest(method: HttpMethod, urlString: String, apiMethod: ApiMethod, params: [String:String]?) {
        let session = URLSession.shared
        
        if (method == .get) {
            var newURLString = urlString
            
            if params != nil {
                newURLString = changeURLForGetRequest(urlString: urlString, apiMethod: apiMethod, params: params!)
                
            }
            guard let url = URL(string: newURLString) else {return}
            
            session.dataTask(with: url) { (data, response, error) in
                self.dataTaskMethod(data: data, response: response, error: error, apiMethod: apiMethod)
                
                }.resume()
            
        } else if (method == .post) {
            guard let url = URL(string: urlString + apiMethod.rawValue) else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params!, options: []) else { return }
            request.httpBody = httpBody
            
            session.dataTask(with: request) { (data, response, error) in
                self.dataTaskMethod(data: data, response: response, error: error, apiMethod: apiMethod)
                
                }.resume()
        }
    }
    
    func dataTaskMethod(data: Data?, response: URLResponse?, error: Error?, apiMethod: ApiMethod) {
//        if let response = response {
//            print(response)
//        }
        
        guard let data = data else { return }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if (apiMethod == .locationSearch) {
                
//                print(json)
                
                if (json as! Array<Any>).isEmpty {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "CityNotFound"), object: nil)
                    return
                }
                
                let currentCity = (json as! Array<Any>)[0] as! Dictionary<String, Any>
                cityName = currentCity["title"] as? String
                cityWoeid = String(describing: (currentCity["woeid"] as! Int))
//                print(json)
                let params = ["woeid":cityWoeid!]
                getOrPostRequest(method: .get, urlString: url, apiMethod: .location, params: params)
            } else if (apiMethod == .location) {
                print(json)
                let consolidatedWeather = (json as! Dictionary<String, Any>)["consolidated_weather"] as! Array<Any>
                let currentDay = consolidatedWeather[0] as! Dictionary<String, Any>
                temp = (currentDay["the_temp"] as! NSNumber).stringValue
                weatherStateName = currentDay["weather_state_name"] as? String
                weatherStateAbbr = currentDay["weather_state_abbr"] as? String
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "CityFound"), object: nil)
                coreDataHelper.deleteData(cityName: cityName!)
                coreDataHelper.saveData(cityName: cityName!, woeid: cityWoeid!, temp: temp!, weatherStateName: weatherStateName!, weatherStateAbbr: weatherStateAbbr!)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "DataUpdated"), object: nil)
                
            }
        } catch {
            print(error)
        }
    }

    func updateData(array: [String]) {
        
        for item in array {
            let params = ["query":item]
            getOrPostRequest(method: .get, urlString: url, apiMethod: .locationSearch, params: params)
        }
    }

}
