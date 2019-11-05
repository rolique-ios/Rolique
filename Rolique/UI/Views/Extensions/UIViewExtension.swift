//
//  UIViewExtension.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/24/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

extension UIView {
  func setShadow() {
    layer.shadowColor = Colors.shadowColor
    layer.shadowRadius = 6.0
    layer.shadowOffset = CGSize(width: 0, height: 7)
    layer.shadowOpacity = 0.1
  }
  
  func removeShadow() {
    layer.shadowColor = nil
    layer.shadowRadius = 0
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.shadowOpacity = 0
  }
  
  func addShadowWithShadowPath(shadowHeight: CGFloat, shadowRadius: CGFloat) {
    let shadowHeight = shadowHeight
    let shadowRadius = shadowRadius
    let width = self.frame.width
    let height = self.frame.height
    
    let shadowPath = UIBezierPath()
    shadowPath.move(to: CGPoint(x: 0, y: height))
    shadowPath.addLine(to: CGPoint(x: width, y: height))
    shadowPath.addLine(to: CGPoint(x: width, y: height + shadowHeight))
    shadowPath.addLine(to: CGPoint(x: 0, y: height + shadowHeight))
    
    self.clipsToBounds = false
    self.layer.masksToBounds = false
    self.layer.shadowPath = shadowPath.cgPath
    self.layer.shadowRadius = shadowRadius
    self.layer.shadowOffset = .zero
    self.layer.shadowOpacity = 0.5
    self.layer.shadowColor = Colors.shadowColor
  }
  
  func removeShadowWithShadowPath() {
    self.layer.shadowPath = nil
    self.layer.shadowRadius = .zero
    self.layer.shadowOffset = .zero
    self.layer.shadowOpacity = .zero
  }
}


