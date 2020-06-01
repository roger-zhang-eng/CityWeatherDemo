//
//  RecentSearchTableViewCell.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit

class RecentSearchTableViewCell: UITableViewCell {

    fileprivate let displayModeLeadingOffset: CGFloat = 16
    fileprivate let editModeLeadingOffset: CGFloat = 32
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var titleLabelLeadingOffset: NSLayoutConstraint!
    
    var imageIsChecked: Bool = false {
        didSet {
            if imageIsChecked {
                checkImage.image = UIImage(named: "checked")
                checkImage.tintColor = .systemBlue
            } else {
                checkImage.image = UIImage(named: "unchecked")
                checkImage.tintColor = .darkGray
            }
            
            checkImage.setNeedsLayout()
        }
    }
    
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
    
    func config(countryCode: String, cityName: String, isEditMode: Bool, isChecked: Bool = false) {
        titleLabel.text = countryCode.getFlag() + " " + cityName
        titleLabelLeadingOffset.constant = isEditMode ? editModeLeadingOffset : displayModeLeadingOffset
        checkImage.isHidden = !isEditMode
        if isEditMode {
            imageIsChecked = isChecked
        }
    }
    
    func switchMode(isEditMode: Bool) {
        titleLabelLeadingOffset.constant = isEditMode ? editModeLeadingOffset : displayModeLeadingOffset
        checkImage.isHidden = !isEditMode
        if isEditMode {
            imageIsChecked = false
        }
    }
    
    func eidtModeImageConfig(needChecked: Bool) {
        imageIsChecked = needChecked
        
    }
}
