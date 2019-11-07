//
//  Colors.swift
//  ROLIQUE
//
//  Created by Bohdan Savych on 7/31/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import UIKit

public struct Colors {
  public struct Login {
    public static var backgroundColor: UIColor {
      return UIColor(red:0.01, green:0.05, blue:0.49, alpha:1.00)
    }
  }
  
  public struct Colleagues {
    public static var softWhite: UIColor {
      return UIColor(red: 252.0 / 255.0, green: 252.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    }
    public static var lightBlue: UIColor {
      return  UIColor(red: 53.0 / 255.0, green: 134.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
  }
  
  public struct Actions {
    public static var nicePurple: UIColor {
      return UIColor(red: 93.0 / 255.0, green: 17.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
    }
    public static var darkGray: UIColor {
      return .black
    }
  }
  
  public struct Profile {
    public static var separatorColor: UIColor {
      return UIColor(red: 233.0 / 255.0, green: 233.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
    }
  }
  
  public struct Calendar {
    public static var remote: UIColor {
      return UIColor(hexString: "#2980b9")
    }
    public static var sick: UIColor {
      return UIColor(hexString: "#27ae60")
    }
    public static var vacation: UIColor {
      return UIColor(hexString: "#c0392b")
    }
    public static var dayOff: UIColor {
      return UIColor(hexString: "#f1c40f")
    }
    public static var businessTrip: UIColor {
      return UIColor(hexString: "#e67e22")
    }
    public static var marrige: UIColor {
      return UIColor(hexString: "#e74c3c")
    }
    public static var babyBirth: UIColor {
      return UIColor(hexString: "#9b59b6")
    }
    public static var funeral: UIColor {
      return UIColor(hexString: "#2c3e50")
    }
    public static var birthday: UIColor {
      return UIColor(hexString: "#d35400")
    }
  }
  
  public static var shadowColor: CGColor {
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
  
  public static var mainBackgroundColor: UIColor {
    if #available(iOS 13.0, *) {
      return .systemBackground
    } else {
      return Colors.Colleagues.softWhite
    }
  }
  
  public static var secondaryBackgroundColor: UIColor {
    if #available(iOS 13.0, *) {
      return .tertiarySystemBackground
    } else {
      return .white
    }
  }
  
  public static var seconaryGroupedBackgroundColor: UIColor {
    if #available(iOS 13.0, *) {
      return .tertiarySystemGroupedBackground
    } else {
      return Colors.Colleagues.softWhite
    }
  }
  
  public static var separatorColor: UIColor {
    if #available(iOS 13.0, *) {
      return .separator
    } else {
      return Colors.Profile.separatorColor
    }
  }
  
  public static var mainTextColor: UIColor {
    if #available(iOS 13.0, *) {
      return .label
    } else {
      return .black
    }
  }
  
  public static var secondaryTextColor: UIColor {
    if #available(iOS 13.0, *) {
      return .secondaryLabel
    } else {
      return .darkGray
    }
  }
}
