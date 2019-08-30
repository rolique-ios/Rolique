//
//  ColleaguesViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/15/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

enum ListType {
  case all
  case filtered
}

protocol ColleaguesViewModel: ViewModel {
  var users: [User] { get }
  var filteredUsers: [User] { get }
  var searchedUsers: [User] { get }
  var onRefreshList: ((ListType) -> Void)? { get set }
  var onError: ((ListType) -> Void)? { get set }
  var listType: ListType { get set }
  var isSearching: Bool { get set }
  var recordType: RecordType? { get set }
  
  func all()
  func sort(_ recordType: RecordType)
  func searchUser(with text: String)
  func refresh()
}

final class ColleaguesViewModelImpl: BaseViewModel, ColleaguesViewModel {
  private let userService: UserService
  
  init(userService: UserService) {
    self.userService = userService
  }
  
  var onRefreshList: ((ListType) -> Void)?
  var onError: ((ListType) -> Void)?
  var users = [User]()
  var filteredUsers = [User]()
  var searchedUsers = [User]()
  var listType = ListType.all
  var isSearching = false
  var recordType: RecordType?
  
  func all() {
    userService.getAllUsers(
      sortDecrciptors: [NSSortDescriptor(key: "slackProfile.realName", ascending: true)],
      onLocal: { [weak self] result in
        self?.handleResult(.all, result: result)
      }, onFetch: { [weak self] result in
        self?.handleResult(.all, result: result)
    })
  }
  
  func sort(_ recordType: RecordType) {
    userService.getTodayUsersForRecordType(recordType) { [weak self] result in
      self?.handleResult(.filtered, result: result)
    }
  }
  
  func searchUser(with text: String) {
    var searchedUsers = [User]()
    switch listType {
    case .all:
      users.forEach { user in
        if user.slackProfile.realName.lowercased().contains(text.lowercased()) {
          searchedUsers.append(user)
        }
      }
    case .filtered:
      filteredUsers.forEach { user in
        if user.slackProfile.realName.lowercased().contains(text.lowercased()) {
          searchedUsers.append(user)
        }
      }
    }
    self.searchedUsers = searchedUsers
    onRefreshList?(listType)
  }
  
  func refresh() {
    switch listType {
    case .all:
      all()
    case .filtered:
      if let recordType = recordType {
        sort(recordType)
      }
    }
  }
  
  private func handleResult(_ listType: ListType, result: Result<[User], Error>) {
    switch result {
    case .success(let users):
      let users = users.sorted(by: {$0.slackProfile.realName < $1.slackProfile.realName})
      switch listType {
      case .all:
        self.users = users
      case .filtered:
        self.filteredUsers = users
      }
      self.onRefreshList?(listType)
    case .failure(let error):
      self.onError?(listType)
      print(error.localizedDescription)
    }
  }
}
