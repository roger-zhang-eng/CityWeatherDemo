//
//  SearchCityWeatherViewModelTest.swift
//  CityWeatherDemoTests
//
//  Created by Roger Zhang on 31/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking

class SearchCityWeatherViewModelTest: XCTestCase {
    let disposeBag = DisposeBag()
    var scheduler: TestScheduler!
    var viewModel: SearchCityWeatherViewModel!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        viewModel = SearchCityWeatherViewModel(weatherService: MockWeatherDataService(),
                                               countryCodeDecoder: MockCityHelper(),
                                               locationService: MockLocationManager(),
                                               networkMonitor: MockNetworkMonitor())
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearchCityName() {
        let expectedCity = "Sydney"
        
        let response = scheduler.createObserver(String.self)
        
        scheduler.createColdObservable([.next(10, "Sydney")])
            .bind(to: self.viewModel.input.searchContentTrigger)
            .disposed(by: disposeBag)
        
        self.viewModel.output?.refreshTableView
            .map({
                 [unowned self] (_) in
                debugPrint("Get weather data city: \(self.viewModel.latestWeatherData?.name)")
                 return self.viewModel.latestWeatherData?.name ?? ""
             })
            .bind(to: response)
            .disposed(by: disposeBag)

        scheduler.start()
        
        XCTAssertEqual(response.events, [.next(10, expectedCity)])
    }
    
    func testSearchCityGPS() {
        let expectedCity = "Sydney"
        
        let response = scheduler.createObserver(String.self)
        
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: self.viewModel.input.gpsLocationTrigger)
            .disposed(by: disposeBag)
        
        self.viewModel.output?.refreshTableView
            .map({
                 [unowned self] (_) in
                debugPrint("Get weather data city: \(self.viewModel.latestWeatherData?.name)")
                 return self.viewModel.latestWeatherData?.name ?? ""
             })
            .bind(to: response)
            .disposed(by: disposeBag)

        scheduler.start()
        
        XCTAssertEqual(response.events, [.next(10, expectedCity)])
    }

    func testSearchCityZipCode() {
        let expectedCity = "Sydney"
        
        let response = scheduler.createObserver(String.self)
        
        scheduler.createColdObservable([.next(10, "2001")])
            .bind(to: self.viewModel.input.searchContentTrigger)
            .disposed(by: disposeBag)
        
        self.viewModel.output?.refreshTableView
            .map({
                 [unowned self] (_) in
                debugPrint("Get weather data city: \(self.viewModel.latestWeatherData?.name)")
                 return self.viewModel.latestWeatherData?.name ?? ""
             })
            .bind(to: response)
            .disposed(by: disposeBag)

        scheduler.start()
        
        XCTAssertEqual(response.events, [.next(10, expectedCity)])
    }
}
