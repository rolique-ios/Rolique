//
//  UINavigationController.swift
//  Spyfall
//
//  Created by bbb on 7/4/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

public extension UINavigationController {
    func makeNavigationBarTranslucent(_ translucent: Bool) {
        navigationBar.shadowImage = translucent ? UIImage() : nil
        navigationBar.setBackgroundImage(translucent ? UIImage() : nil, for: .default)
        navigationBar.isTranslucent = true
    }
  
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
