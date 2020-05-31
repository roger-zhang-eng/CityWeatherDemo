//
//  SunriseSunsetTableViewCell.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit

class SunriseSunsetTableViewCell: UITableViewCell {

    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Appearance.Style.Colors.tableViewCellGroupBackground
        sunsetLabel.textColor = Appearance.Style.Colors.label
        sunriseLabel.textColor = Appearance.Style.Colors.label
    }
 
    func config(sunrise: TimeInterval, sunset: TimeInterval) {
        let sunriseTime = Date(timeIntervalSince1970: sunrise)
        let sunsetTime = Date(timeIntervalSince1970: sunset)
        self.sunriseLabel.text = DateUtility.sunriseTimeFormatter.string(from: sunriseTime)
        self.sunsetLabel.text = DateUtility.sunriseTimeFormatter.string(from: sunsetTime)
    }
}
