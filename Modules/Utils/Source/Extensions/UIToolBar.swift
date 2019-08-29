//
//  UIToolBar.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/29/19.
//

import UIKit

public extension UIToolbar {
  static func toolbarPiker(rightButton: UIBarButtonItem) -> UIToolbar {
    let toolBar = UIToolbar()
    
    toolBar.barStyle = UIBarStyle.default
    toolBar.isTranslucent = true
    toolBar.tintColor = UIColor.black
    toolBar.sizeToFit()
    
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    
    toolBar.setItems([spaceButton, rightButton], animated: false)
    toolBar.isUserInteractionEnabled = true
    
    return toolBar
  }
}
