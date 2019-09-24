//
//  UIViewExtension.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/24/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

extension UIView {
  func addShadow() {
    layer.shadowColor = UIColor.black.cgColor
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
}


