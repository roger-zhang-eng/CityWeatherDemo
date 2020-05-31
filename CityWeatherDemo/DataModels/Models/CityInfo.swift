//
//  CityInfo.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

struct CityInfo: Codable {
    var id: Int?
    var name: String?
    var state: String?
    var country: String?
    
    init() {}
}
