//
//  WeatherDataService.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 29/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift

enum SearchType {
    //ID
    case cityId(String)
    //name, countryCode
    case cityName(String, String)
    //zip, countryCode
    case zipCode(String, String)
    //lat, long
    case location(String, String)
}

protocol DownloadProtocol {
    func getCityWetherData(searchType: SearchType, appId: String?) -> Observable<(WeatherCityData)>
}

struct WeatherDataService: DownloadProtocol {
    private let baseURL = URL(string: "https://api.openweathermap.org/data/2.5")!
    private let defaultHeaders = ["Content-Type": "application/json"]
    
    func getCityWetherData(searchType: SearchType, appId: String? = nil) -> Observable<(WeatherCityData)> {
        let path = "weather"
        var parameters = [String: Any]()
        let appId: String = (appId != nil) ? appId! : Bundle.appID
        
        switch searchType {
        case .cityId(let cityId):
            parameters["id"] = cityId
        case .cityName(let cityName, let countryCode):
            parameters["q"] = cityName + "," + countryCode
        case .zipCode(let zipCode, let countryCode):
            parameters["zip"] = zipCode + "," + countryCode
        case .location(let lat, let lon):
            parameters["lat"] = lat
            parameters["lon"] = lon
        }
        
        parameters["appid"] = appId
        parameters["units"] = "metric"
        
        let url = baseURL.appendingPathComponent(path)
        
        //return Observable.just(CityWeatherHelper.shared.mockupWeatherData()!)
        
        return RxAlamofire.requestData(.get, url, parameters: parameters, encoding: URLEncoding.default, headers: defaultHeaders)
                .flatMap { (response, value) -> Observable<WeatherCityData> in
                    guard response.statusCode < 300 && response.statusCode >= 200 else {
                        return (response.statusCode == 404) ? .error(ServiceError.notFound) : .error(ServiceError.network)
                    }
                    
                    do {
                        let cityWeatherData = try JSONDecoder().decode(WeatherCityData.self, from: value)
                        return .just(cityWeatherData)
                    } catch {
                        return .error(ServiceError.notFound)
                    }
                }
        
    }
}
