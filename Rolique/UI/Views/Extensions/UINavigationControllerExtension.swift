//
//  UINavigationControllerExtension.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/26/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

extension UINavigationController {
  func setAppearance(with titleAttributes: [NSAttributedString.Key: Any], backgroundColor: UIColor) {
    if #available(iOS 13.0, *) {
      let navBarAppearance = UINavigationBarAppearance()
      navBarAppearance.configureWithOpaqueBackground()
      navBarAppearance.titleTextAttributes = titleAttributes
      navBarAppearance.largeTitleTextAttributes = titleAttributes
      navBarAppearance.backgroundColor = backgroundColor
      self.navigationBar.standardAppearance = navBarAppearance
      self.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
  }
}
