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
  private let vacationUserService: UserService = VacationUserServiceImpl(userManager: UserManagerImpl(), coreDataManager: CoreDataManager<User>())
  
  override func loadData(usersCompletion: @escaping (([AnyUserable]) -> Void)) {
    self.vacationUserService.getTodayUsersForRecordType(.vacation, onLocal: { [weak self] result in
      self?.handleResult(result: result, usersCompletion: usersCompletion)
    }, onFetch: { [weak self] result in
      self?.handleResult(result: result, usersCompletion: usersCompletion)
    })
  }
  
  private func handleResult(result: Result<[User], Error>, usersCompletion: @escaping (([AnyUserable]) -> Void)) {
    guard !result.isFailure else { return }
    (result.value?
      .map { AnyUserable($0) })
      .map(usersCompletion)
  }
}
