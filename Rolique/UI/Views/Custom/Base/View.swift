//
//  View.swift
//  Rolique
//
//  Created by Bohdan Savych on 1/8/20.
//  Copyright © 2020 Rolique. All rights reserved.
//

import UIKit

class View: UIView {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
    
    // MARK: - UI
    // MARK: Configuration
    
    func configure() {
        backgroundColor = .clear
    }
}
