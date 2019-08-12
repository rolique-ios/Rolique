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
import Utils



final class RemoteViewController: UsersViewController {
  private let userManager: UserManager = UserManagerImpl()
  
  override func loadData(usersCompletion: @escaping (([AnyUserable]) -> Void)) {
    self.userManager.getTodayUsersForRecordType(.remote) { result in
      (result.value?
        .map { AnyUserable($0) })
        .map(usersCompletion)
    }
  }
}
