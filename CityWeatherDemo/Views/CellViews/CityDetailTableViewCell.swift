//
//  CityDetailTableViewCell.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit

class CityDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Appearance.Style.Colors.tableViewCellGroupBackground
        contentLabel.textColor = Appearance.Style.Colors.label
    }

    func config(cellData: WeatherDetailType) {
        switch cellData {
        case .description(_):
            iconImageView.image = UIImage(named: "description")
        case .temperature(_):
            iconImageView.image = UIImage(named: "temperature")
        case .wind(_):
            iconImageView.image = UIImage(named: "wind")
        case .humidity(_):
            iconImageView.image = UIImage(named: "humidity")
        default:
            break
        }
        contentLabel.text = cellData.text()
    }
}
