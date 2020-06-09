//
//  DateUtility.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

class DateUtility {

    static var mediumDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()

    static var sunriseTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter

    }()
}
