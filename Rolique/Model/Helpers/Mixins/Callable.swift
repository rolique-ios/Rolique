//
//  Callable.swift
//  Rolique
//
//  Created by Maks on 9/23/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

protocol Callable {
  func call(to phone: String)
}

extension Callable where Self: UIViewController {
  func call(to phone: String) {
    if let url = URL(string: "telprompt:\(phone.replacingOccurrences(of: " ", with: ""))"), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
      Spitter.showOkAlert("Phone not valid", viewController: self)
    }
  }
}
