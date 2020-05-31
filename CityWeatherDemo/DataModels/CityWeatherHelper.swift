//
//  CityWeatherHelper.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

protocol CountryCodeDecodeProtocol {
    func initSetup()
    func countryList() -> [String]
}

class CityWeatherHelper: CountryCodeDecodeProtocol {    
    private var cityListRawArray: [CityInfo]?
    
    private let preferenceCountryCodes = Bundle.preferenceCountryCodes
    
    init() { }
    
    func initSetup() {
        guard cityListRawArray == nil else {
            NotificationCenter.default.post(name: .loadCityList, object: nil)
            return
        }
        
        loadCityList()
    }
    
    private func loadCityList() {
        DispatchQueue.global(qos: .userInteractive).async {
            [weak self] in
            self?.cityListRawArray = self?.loadCitiesJSON()
            debugPrint("City list count: \(String(describing: self?.cityListRawArray?.count))")
            if self?.cityListRawArray == nil {
                debugPrint("City List load failed.")
                return
            } else {
                NotificationCenter.default.post(name: .loadCityList, object: nil)
            }
        }
    }
    
    func countryList() -> [String] {
        guard cityListRawArray != nil && cityListRawArray!.count > 0 else {
            return preferenceCountryCodes
        }
        
        let countrySet: Set<String> = Set(cityListRawArray!.map { $0.country ?? "" } )
        if preferenceCountryCodes.count > 0 {
            let preferenceSet = Set(preferenceCountryCodes)
            let fullCountryCodes = Array(countrySet).sorted { $0 < $1 }
            var shapedCountryCode = preferenceCountryCodes
            for countryCode in fullCountryCodes {
                if !preferenceSet.contains(countryCode) && !countryCode.isEmpty {
                    shapedCountryCode.append(countryCode)
                }
            }
            
            return shapedCountryCode
        } else {
            return Array(countrySet).sorted { $0 < $1 }
        }
    }
    
    private func loadCitiesJSON() -> [CityInfo]? {
        if let url = Bundle.main.url(forResource: "city.list", withExtension: "json") {

            do {
                
                let data = try Data(contentsOf: url)
                let cityArray = try JSONDecoder().decode([CityInfo].self, from: data)
                debugPrint("decode done")
                return cityArray

            } catch {
                debugPrint("error:\(error.localizedDescription)")
            }
        }
        return nil
    }
}
