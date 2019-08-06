//
//  TodayViewController.swift
//  VacationTodayExtension
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import NotificationCenter
import UsersWidget
import Utils
import Model

// MARK: - Userable
extension User: Userable {
  public var name: String {
    return self.slackProfile.realName
  }
  
  public var thumbnailURL: URL? {
    return URL(string: (self.slackProfile.image48 ?? self.slackProfile.image32 ?? ""))
  }
}

class VacationViewController: UsersViewController {
  private let userManager: UserManager = UserManagerImpl()
  
  override func loadData(usersCompletion: @escaping (([AnyUserable]) -> Void)) {
    self.userManager.getTodayUsersForRecordType(.vacation) { result in
      (result.value?
        .map { AnyUserable($0) })
        .map(usersCompletion)
    }
  }
}
