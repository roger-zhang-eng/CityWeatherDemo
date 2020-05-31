//
//  RecentSearchTableViewCell.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit

class RecentSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Appearance.Style.Colors.tableViewCellGroupBackground
        titleLabel.textColor = Appearance.Style.Colors.label
    }

        static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func config(countryCode: String, cityName: String) {
        titleLabel.text = countryCode.getFlag() + " " + cityName
    }
}
