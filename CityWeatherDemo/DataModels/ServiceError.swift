//
//  ServiceError.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 29/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

public enum ServiceError: Error {
    /// The error is unknown, e.g the service gives an unexpected response string that cannot be parsed
    case unknown

    /// The request fails because of the network connection
    case network
    /// The request is unauthenticated, probably because the access token in the AuthenticationContext expires
    case unauthenticated
    /// The resource is not found
    case notFound
    /// The request params are invalid
    case badRequest
    /// Invalid Response
    case invalidResponse
    /// Decode Error
    case decodeError
    /// Oversize
    case overSize
    /// GPS Error
    case gpsError
    
    func title() -> String {
        switch self {
        case .notFound:
            return "Error-Title".localized
        default:
            return "Alert-Title".localized
        }
    }
    
    func message() -> String {
        switch self {
        case .network:
            return "Network-Message".localized
        case .gpsError:
            return "GPS-Message".localized
        default:
            return "NotFount-Message".localized
        }
    }
}
