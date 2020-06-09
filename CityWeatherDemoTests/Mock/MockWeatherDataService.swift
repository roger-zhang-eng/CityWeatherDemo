//
//  MockWeatherDataService.swift
//  CityWeatherDemoTests
//
//  Created by Roger Zhang on 31/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

class MockWeatherDataService: DownloadProtocol {
    let disposeBag = DisposeBag()

    private func mockupWeatherData() -> WeatherCityData? {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "SydneyWeatherData", withExtension: "json") else {
            debugPrint("Missing file: SydneyWeatherData.json")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let cityWeatherData = try JSONDecoder().decode(WeatherCityData.self, from: data)
            return cityWeatherData
        } catch {
            return nil
        }
    }

    func getCityWetherData(searchType: SearchType, appId: String?) -> Observable<(WeatherCityData)> {
        if let mockData = mockupWeatherData() {
            return Observable.just(mockData)
        } else {
            return Observable.just(WeatherCityData())
        }
    }
}
