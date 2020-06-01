//
//  RecentSearchHeaderView.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 1/6/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit

class RecentSearchHeaderView: UITableViewHeaderFooterView {

    static var identifier: String {
        return String(describing: self)
    }
    
    let title = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureContents() {
        title.font = UIFont.systemFont(ofSize: 13)
        title.textAlignment = .left
        title.numberOfLines = 1
        title.textColor = Appearance.Style.Colors.label
        title.text = "RecentSearchView-Indicate".localized
        title.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(title)

        NSLayoutConstraint.activate([
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            title.trailingAnchor.constraint(equalTo:
                   contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

}
