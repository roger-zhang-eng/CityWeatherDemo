//
//  Platform.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 31/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

struct Platform {
    static let isSimulator: Bool = {
        #if targetEnvironment(simulator)
            // we're on the simulator
            return true
        #else
            // we're on a device
             return false
        #endif
    }()
}
