//
//  LocationManager.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation
import CoreLocation
import RxCoreLocation
import RxSwift
import RxCocoa

struct LocationManagerInput {
    let authorizationCheckTrigger: PublishSubject<Void>
    let requestLocationUpdate: PublishSubject<Void>
}

struct LocationManagerOutput {
    let locationData: Observable<(Double, Double)>
    let error: Observable<ServiceError>
}

protocol LocationServiceProtocol {
    var input: LocationManagerInput { get }
    var output: LocationManagerOutput? { get }
    var isLocationAllowed: Bool { get }
}

class LocationManager: LocationServiceProtocol {
    private let disposeBag = DisposeBag()
    private let manager = CLLocationManager()
    
    //Input
    let input: LocationManagerInput
    //Output
    var output: LocationManagerOutput?
    
    private let locationAuthorization = PublishSubject<Bool>()
    private let locationDataUpdate = PublishSubject<(Double, Double)>()
    private var lastLocation: CLLocationCoordinate2D?
    var isLocationAllowed = true
    
    init() {
        input = LocationManagerInput(authorizationCheckTrigger: PublishSubject<Void>(),
                                     requestLocationUpdate: PublishSubject<Void>())
        
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.distanceFilter = 3000
        setupBinding()
    }
    
    func setupBinding() {
        self.input.authorizationCheckTrigger
            .subscribe(onNext: {
                [unowned self] (_) in
                self.manager.requestWhenInUseAuthorization()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        self.input.requestLocationUpdate
            .subscribe(onNext: {
                [unowned self] (_) in
                self.manager.startUpdatingLocation()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        self.manager.rx
        .didChangeAuthorization
        .debug()
        .subscribe(onNext: {
            [unowned self] (manager, status) in
            debugPrint("Location didChangeAuthorization: \(status)")
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.isLocationAllowed = true
            default:
                self.isLocationAllowed = false
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        self.manager.rx
        .didUpdateLocations
            .subscribe(onNext: {
                [unowned self] (manager, locations) in
                //Get location update time
                let latestLoc = locations.last!
                let eventDate = latestLoc.timestamp
                let howRecent = eventDate.timeIntervalSinceNow
                
                if abs(howRecent) < 30 {
                    print("In didUpdateLocations: Locaion: Latitude \(latestLoc.coordinate.latitude.description), Longtitude \(latestLoc.coordinate.longitude.description)")
                    self.lastLocation = latestLoc.coordinate
                    self.locationDataUpdate.onNext((latestLoc.coordinate.latitude ,latestLoc.coordinate.longitude))
                    self.manager.stopUpdatingLocation()
                } else {
                    print("In didUpdateLocations: The got location address is too old! and lastLocation is nil \(self.lastLocation == nil)")
                    if self.lastLocation != nil {
                        self.locationDataUpdate.onNext((self.lastLocation!.latitude, self.lastLocation!.longitude))
                        self.manager.stopUpdatingLocation()
                    }
                }
                
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: disposeBag)
        
        
        output = LocationManagerOutput(locationData: self.locationDataUpdate.asObservable(),
                                       error: self.manager.rx.didError
                                        .asObservable()
                                        .map({ (_) in
                                            return ServiceError.gpsError
                                        }))
    }
}
