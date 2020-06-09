//
//  UserDefaultsProperty.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

class UserDefaultsProperty<Value>: NSObject {
    private let key: String

    var value: Value {
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: key)
            userDefaults.synchronize()
        }

        get {
            return UserDefaults.standard.value(forKey: key) as! Value
        }
    }

    var stringArray: [String]? {
        get {
            return UserDefaults.standard.array(forKey: key) as? [String]
        }
    }

    var dateValue: Date? {
        get {
            return UserDefaults.standard.object(forKey: key) as? Date
        }
    }

    var savedWeatherData: WeatherCityData? {
        get {
            if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
                do {
                    let jsonObject = try JSONDecoder().decode(WeatherCityData.self, from: savedData)
                    return jsonObject
                } catch {
                    return nil
                }
            } else {
                return nil
            }
        }

        set {
            guard newValue != nil else {
                debugPrint("savedData is nil")
                return
            }

            do {
                let jsonData = try JSONEncoder().encode(newValue!)
                UserDefaults.standard.set(jsonData, forKey: key)
                UserDefaults.standard.synchronize()
            } catch {
                debugPrint("encode failed")
            }
        }
    }

    var savedSearchCities: [CityInfo] {
        get {
            if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
                do {
                    let jsonObject = try JSONDecoder().decode([CityInfo].self, from: savedData)
                    return jsonObject
                } catch {
                    return [CityInfo]()
                }
            } else {
                return [CityInfo]()
            }
        }

        set {

            do {
                let jsonData = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(jsonData, forKey: key)
                UserDefaults.standard.synchronize()
            } catch {
                debugPrint("encode failed")
            }
        }
    }

    init(key: String) {
        self.key = key
    }

}
