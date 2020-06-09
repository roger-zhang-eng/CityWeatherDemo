//
//  Appearance.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit

public enum DefaultStyle {

    public enum Colors {

        public static let label: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return .black
            }
        }()

        public static let background: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.systemBackground
            } else {
                return .white
            }
        }()

        public static let tableViewGroupBackground: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.systemGroupedBackground
            } else {
                return .white
            }
        }()

        public static let tableViewCellGroupBackground: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.secondarySystemGroupedBackground
            } else {
                return .white
            }
        }()
    }
}

class Appearance {
    static let Style = DefaultStyle.self
}
