//
//  Slackable.swift
//  Rolique
//
//  Created by Maks on 9/23/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

protocol Slackable: class {
  func openSlack(with userId: String)
}

extension Slackable {
  func openSlack(with userId: String) {
    let urlString = "slack://user?team=\(UserDefaultsManager.shared.teamId ?? "no-team-id")&id=\(userId)"
    guard let url = URL(string: urlString) ,UIApplication.shared.canOpenURL(url) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}
