//
//  WeatherDataServiceTest.swift
//  CityWeatherDemoTests
//
//  Created by Roger Zhang on 31/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import XCTest
import RxSwift
import Action
import RxTest
import RxBlocking

class WeatherDataServiceTest: XCTestCase {
    let disposeBag = DisposeBag()
    let sydneyCityId = "2147714"
    let testAppId = "5c6090ae72520cc52ea0e6e951bd786d"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWeatherService() {
        let exp = expectation(description: "Download weather list test")

        let expectedCity = "Sydney"

        let weatherService = WeatherDataService()
        weatherService.getCityWetherData(searchType: SearchType.cityId(sydneyCityId), appId: testAppId)
            .asObservable()
            .subscribe(onNext: {
                (weatherData) in
                XCTAssertNotNil(weatherData.name)
                XCTAssert(weatherData.name!.compare(expectedCity) == .orderedSame)
                debugPrint("testWeatherService get data for: \(weatherData.name!)")
                exp.fulfill()
            }, onError: { (error) in
                XCTAssert(false, error.localizedDescription)
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, (error?.localizedDescription)!)
        }
    }

}
