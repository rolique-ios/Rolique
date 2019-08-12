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
