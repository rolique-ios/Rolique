//
//  ColleaguesViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/15/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

protocol ColleaguesViewModel: ViewModel {
  var users: [User] { get }
  var onRefreshList: (() -> Void)? { get set }
  var usersStatus: UsersStatus { get set }
  
  func refreshList()
}

final class ColleaguesViewModelImpl: BaseViewModel, ColleaguesViewModel {
  private let userService: UserService
  var usersStatus: UsersStatus
  
  init(userService: UserService, usersStatus: UsersStatus) {
    self.userService = userService
    self.usersStatus = usersStatus
  }
  
  var onRefreshList: (() -> Void)?
  var users = [User]()
  
  func refreshList() {
    users.removeAll()
    onRefreshList?()
    
    switch usersStatus {
    case .all:
      all()
    case .remote:
      onRemote()
    case .vacation:
      onVacation()
    }
  }
  
  private func all() {
    userService.getAllUsers(
      sortDecrciptors: [NSSortDescriptor(key: "slackProfile.realName", ascending: true)],
      onLocal: { [weak self] result in
        self?.handleResult(.all, result: result)
      }, onFetch: { [weak self] result in
        self?.handleResult(.all, result: result)
    })
  }
  
  private func onRemote() {
    userService.getTodayUsersForRecordType(.remote) { [weak self] result in
      self?.handleResult(.remote, result: result)
    }
  }
  
  private func onVacation() {
    userService.getTodayUsersForRecordType(.vacation) { [weak self] result in
      self?.handleResult(.vacation, result: result)
    }
  }
  
  private func handleResult(_ status: UsersStatus, result: Result<[User], Error>) {
    guard usersStatus == status else { return }
    switch result {
    case .success(let users):
      self.users = users.sorted(by: {$0.slackProfile.realName < $1.slackProfile.realName})
      self.onRefreshList?()
    case .failure(let error):
      print(error.localizedDescription)
    }
  }
}
