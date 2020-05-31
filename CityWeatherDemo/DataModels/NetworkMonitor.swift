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
    let startMonitor: PublishSubject<Void>
    let stopMonitor: PublishSubject<Void>
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
    private let queue = DispatchQueue.global(qos: .background)
    private var netOn: Bool?
    private var connType: NWInterface.InterfaceType = .wifi
 
    init() {
        input = NetworkMonitorInput(startMonitor: PublishSubject<Void>(),
                                    stopMonitor: PublishSubject<Void>())
        setupBinding()
        self.monitor.start(queue: queue)
        debugPrint("In Simulator: \(Platform.isSimulator)")
    }
 
    func setupBinding() {
        input.startMonitor.subscribe(onNext: {
            [unowned self] (_) in
            self.startMonitoring()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        input.stopMonitor.subscribe(onNext: {
            [unowned self] (_) in
            self.stopMonitoring()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        output = NetworkMonitorOutput(networkConnected: networkConnIndicator.asObservable())
    }
    
    private func startMonitoring() {
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
