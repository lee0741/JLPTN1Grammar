//
//  ExampleCell.swift
//  JLPT N1 Grammar
//
//  Created by Yancen Li on 2/19/17.
//  Copyright © 2017 Yancen Li. All rights reserved.
//

import UIKit

class ExampleCell: UITableViewCell {
    
    let jpLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let enLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = UIColor.gray
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(jpLabel)
        addSubview(enLabel)
        jpLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        jpLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        jpLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        jpLabel.bottomAnchor.constraint(equalTo: enLabel.topAnchor, constant: -3).isActive = true
        enLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        enLabel.topAnchor.constraint(equalTo: jpLabel.bottomAnchor, constant: 3).isActive = true
        enLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        enLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
