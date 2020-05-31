//
//  MockNetworkMonitor.swift
//  CityWeatherDemoTests
//
//  Created by Roger Zhang on 31/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation
import RxSwift
import RxTest

class MockNetworkMonitor: NetworkMonitorProtocol {
    let input: NetworkMonitorInput
    var output: NetworkMonitorOutput?
    
    private let disposeBag = DisposeBag()
    
    init() {
        input = NetworkMonitorInput(startMonitor: PublishSubject<Void>(),
                                    stopMonitor: PublishSubject<Void>())
        setupBinding()
    }
    
    func setupBinding() {
        
        output = NetworkMonitorOutput(networkConnected: input.startMonitor
            .asObservable()
            .map {
                return true
            })
    }
}
