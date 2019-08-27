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
  var usersOnRemote: [User] { get }
  var usersOnVacation: [User] { get }
  var searchedUsers: [User] { get }
  var onRefreshList: ((Segment) -> Void)? { get set }
  var onError: ((Segment) -> Void)? { get set }
  var segment: Segment { get set }
  var isSearching: Bool { get set }
  
  func all()
  func onRemote()
  func onVacation()
  func searchUser(with text: String)
}

final class ColleaguesViewModelImpl: BaseViewModel, ColleaguesViewModel {
  private let userService: UserService
  
  init(userService: UserService) {
    self.userService = userService
  }
  
  var onRefreshList: ((Segment) -> Void)?
  var onError: ((Segment) -> Void)?
  var users = [User]()
  var usersOnRemote = [User]()
  var usersOnVacation = [User]()
  var searchedUsers = [User]()
  var segment: Segment = .all
  var isSearching = false
  
  func all() {
    userService.getAllUsers(
      sortDecrciptors: [NSSortDescriptor(key: "slackProfile.realName", ascending: true)],
      onLocal: { [weak self] result in
        self?.handleResult(.all, result: result)
      }, onFetch: { [weak self] result in
        self?.handleResult(.all, result: result)
    })
  }
  
  func onRemote() {
    userService.getTodayUsersForRecordType(.remote) { [weak self] result in
      self?.handleResult(.remote, result: result)
    }
  }
  
  func onVacation() {
    userService.getTodayUsersForRecordType(.vacation) { [weak self] result in
      self?.handleResult(.vacation, result: result)
    }
  }
  
  func searchUser(with text: String) {
    var searchedUsers = [User]()
    users.forEach { user in
      if user.slackProfile.realName.contains(text) {
        searchedUsers.append(user)
      }
    }
    self.searchedUsers = searchedUsers
    onRefreshList?(.all)
  }
  
  private func handleResult(_ segment: Segment, result: Result<[User], Error>) {
    switch result {
    case .success(let users):
      let users = users.sorted(by: {$0.slackProfile.realName < $1.slackProfile.realName})
      switch segment {
      case .all:
        self.users = users
      case .remote:
        self.usersOnRemote = users
      case .vacation:
        self.usersOnVacation = users
      }
      self.onRefreshList?(segment)
    case .failure(let error):
      self.onError?(segment)
      print(error.localizedDescription)
    }
  }
}
