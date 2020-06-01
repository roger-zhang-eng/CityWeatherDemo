//
//  NetworkMonitor.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 31/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation
import Network
import RxSwift
import RxCocoa

struct NetworkMonitorInput {
    let triggerMonitor: PublishSubject<Bool>
}

struct NetworkMonitorOutput {
    let networkConnected: Observable<Bool>
}

protocol NetworkMonitorProtocol {
    var input: NetworkMonitorInput { get }
    var output: NetworkMonitorOutput? { get }
}

class NetworkMonitor: NetworkMonitorProtocol {
    let input: NetworkMonitorInput
    var output: NetworkMonitorOutput?
    private let networkConnIndicator = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .default)
    private var netOn: Bool?
    private var connType: NWInterface.InterfaceType = .wifi
 
    init() {
        input = NetworkMonitorInput(triggerMonitor: PublishSubject<Bool>())
        self.monitor.start(queue: queue)
        
        setupBinding()
        debugPrint("In Simulator: \(Platform.isSimulator)")
    }
 
    func setupBinding() {
        input.triggerMonitor
        .distinctUntilChanged()
        .subscribe(onNext: {
            [unowned self] (triggerState) in
            if triggerState {
                self.startMonitoring()
            } else {
                self.stopMonitoring()
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        output = NetworkMonitorOutput(networkConnected: networkConnIndicator.asObservable())
    }
    
    private func startMonitoring() {
        debugPrint("start monitoring NW")
        self.monitor.pathUpdateHandler = {
            [unowned self] (path) in
            if self.netOn == nil {
                self.netOn = (path.status == .satisfied)
            } else {
                if Platform.isSimulator {
                    self.netOn = !self.netOn!
                } else {
                    self.netOn = (path.status == .satisfied)
                }
            }
            
            self.connType = self.checkConnectionTypeForPath(path)
            debugPrint("NW monitor: netOn \(self.netOn), connType \(self.connType)")
            
            self.networkConnIndicator.onNext(self.netOn!)
        }
    }
 
    private func stopMonitoring() {
        debugPrint("stop monitoring NW")
        self.monitor.cancel()
    }
 
    private func checkConnectionTypeForPath(_ path: NWPath) -> NWInterface.InterfaceType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .wiredEthernet
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        }
 
        return .other
    }
}
