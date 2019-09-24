//
//  ShadowView.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/15/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

class ShadowView: UIView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  private func commonInit() {
    layer.rasterizationScale = UIScreen.main.scale
    layer.shouldRasterize = true
    layer.cornerRadius = 5.0
    layer.masksToBounds = false
    addShadow()
  }
}

