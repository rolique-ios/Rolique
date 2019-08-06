//
//  TodayViewController.swift
//  RemoteTodayExtension
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import NotificationCenter
import UsersWidget
import Model
import Utils

// MARK: - Userable
extension User: Userable {
  public var name: String {
    return self.slackProfile.realName
  }
  
  public var thumnailURL: URL? {
    return URL(string: (self.slackProfile.image48 ?? self.slackProfile.image32 ?? ""))
  }
}

final class RemoteViewController: UsersViewController {
  private let userManager: UserManager = UserManagerImpl()
  
  override func loadData(usersCompletion: @escaping (([Userable]) -> Void)) {
    self.userManager.getTodayUsersForRecordType(.remote) { result in
      if let users = result.value {
        usersCompletion(users)
      }
    }
  }
}
