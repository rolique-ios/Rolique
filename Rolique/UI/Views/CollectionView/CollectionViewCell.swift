//
//  CollectionViewCell.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/6/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {}
}
