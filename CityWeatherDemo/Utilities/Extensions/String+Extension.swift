//
//  String+Extension.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

extension String {
    func getFlag() -> String {

        return self
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }

    fileprivate var enGeneralBundle: Bundle? {
        get {
            if let path = Bundle.main.path(forResource: "en", ofType: "lproj") {
                return Bundle(path: path)
            } else {
                return nil
            }
        }
    }

    var localized: String {
        if enGeneralBundle != nil {
            return enGeneralBundle!.localizedString(forKey: self, value: self, table: "generalText")
        } else {
            return self
        }
    }
}
