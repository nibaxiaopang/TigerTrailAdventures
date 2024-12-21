//
//  NumberCell.swift
//  TigerTrail Adventures
//
//  Created by TigerTrail Adventures on 2024/12/21.
//

import UIKit

class NumberCell: UICollectionViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    
    func configure(with number: Int) {
        numberLabel.text = "\(number)"
        numberLabel.textColor = .white
        contentView.backgroundColor = .systemBlue
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }
}
