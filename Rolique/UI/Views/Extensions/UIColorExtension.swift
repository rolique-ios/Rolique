//
//  UIColorExtension.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/25/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

extension UIColor {
  static func shadowColor() -> CGColor {
    if #available(iOS 13.0, *) {
      let color = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        if traitCollection.userInterfaceStyle == .dark {
          return .white
        } else {
          return .black
        }
      }
      return color.cgColor
    } else {
      return UIColor.black.cgColor
    }
  }
  
  static func mainBackgroundColor() -> UIColor {
    if #available(iOS 13.0, *) {
      return .systemBackground
    } else {
      return Colors.Colleagues.softWhite
    }
  }
  
  static func secondaryBackgroundColor() -> UIColor {
    if #available(iOS 13.0, *) {
      return .tertiarySystemBackground
    } else {
      return .white
    }
  }
  
  static func separatorColor() -> UIColor {
    if #available(iOS 13.0, *) {
      return .separator
    } else {
      return Colors.Profile.separatorColor
    }
  }
  
  static func mainTextColor() -> UIColor {
    if #available(iOS 13.0, *) {
      return .label
    } else {
      return .black
    }
  }
  
  static func secondaryTextColor() -> UIColor {
    if #available(iOS 13.0, *) {
      return .secondaryLabel
    } else {
      return .darkGray
    }
  }
}
