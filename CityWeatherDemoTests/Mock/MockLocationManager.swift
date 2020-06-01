//
//  MockLocationManager.swift
//  CityWeatherDemoTests
//
//  Created by Roger Zhang on 31/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation
import RxSwift
import RxTest

class MockLocationManager: LocationServiceProtocol {
    let input: LocationManagerInput
    var output: LocationManagerOutput?
    var isLocationAllowed = true
    private let gpsError = PublishSubject<ServiceError>()
    
    init() {
        input = LocationManagerInput(authorizationCheckTrigger: PublishSubject<Void>(),
                                    requestLocationUpdate: PublishSubject<Void>())
        setupBinding()
    }
    
    func setupBinding() {
        
        output = LocationManagerOutput(locationData: input.requestLocationUpdate
                                                            .asObservable()
                                                            .map { return (-33.8699, 151.2100) },
                                       error: gpsError.asObservable())
    }
    
    func mockLocationNotAuthorised() {
        isLocationAllowed = false
    }
}
