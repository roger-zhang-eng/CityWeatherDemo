//
//  Bundle+Extension.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

extension Bundle {
    static let appID: String = (Bundle.main.infoDictionary?["AppID"] as? String) ?? ""
    static let preferenceCountryCodes: [String] = (Bundle.main.infoDictionary?["PreferenceCountryCodes"] as? [String]) ?? [String]()
}
