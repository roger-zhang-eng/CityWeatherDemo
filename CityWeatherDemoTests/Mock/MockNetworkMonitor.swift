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
    
    var mockConnected = true
    
    init() {
        input = NetworkMonitorInput(triggerMonitor: PublishSubject<Bool>())
        setupBinding()
    }
    
    func setupBinding() {
        
        output = NetworkMonitorOutput(networkConnected: input.triggerMonitor
            .asObservable()
            .map { [unowned self] _ in
                return self.mockConnected
            })
    }
    
    func mockNetworkDown() {
        mockConnected = false
        input.triggerMonitor.onNext(true)
    }
}
