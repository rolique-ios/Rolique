//
//  Skypable.swift
//  Rolique
//
//  Created by Maks on 9/23/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

protocol Skypable: class {
  func openSkype()
}

extension Skypable {
  var skypeStringUrl: String { return "skype://" }
  
  func openSkype() {
    let app = UIApplication.shared
    if let skypeURL = URL(string: skypeStringUrl), app.canOpenURL(skypeURL) {
      app.open(skypeURL, options: [:], completionHandler: nil)
    }
  }
}
