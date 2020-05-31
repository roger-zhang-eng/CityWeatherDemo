//
//  MockCityHelper.swift
//  CityWeatherDemoTests
//
//  Created by Roger Zhang on 31/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

class MockCityHelper: CountryCodeDecodeProtocol {
    func initSetup() {}
    
    func countryList() -> [String] {
        return ["US", "AU", "CA", "NZ"]
    }
}
