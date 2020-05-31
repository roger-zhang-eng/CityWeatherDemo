//
//  TopHeaderSectionView.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit

class TopHeaderSectionView: UITableViewHeaderFooterView {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    static var identifier: String {
        return String(describing: self)
    }

    func config(refreshTime: Date, cityName: String, countryCode: String) {
        self.timeLabel.text = "Last refresh: " + DateUtility.mediumDateFormatter.string(from: refreshTime)
        self.cityLabel.text = countryCode.getFlag() + " " + cityName
    }
}
