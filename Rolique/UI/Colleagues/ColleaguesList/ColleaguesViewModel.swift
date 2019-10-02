//
//  ColleaguesViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/15/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

enum ListType {
  case all
  case filtered
}

protocol ColleaguesViewModel: ViewModel {
  var users: [User] { get }
  var filteredUsers: [User] { get }
  var searchedUsers: [User] { get }
  var onRefreshList: (([User]) -> Void)? { get set }
  var onError: ((ListType) -> Void)? { get set }
  var listType: ListType { get set }
  var recordType: RecordType? { get set }
  
  func all()
  func away()
  func sort(_ recordType: RecordType)
  func searchUser(with text: String)
  func refresh()
  func updateRecordType(_ recordType: RecordType)
  func cancelSearch()
  func getUsersByCurrentListType() -> [User]
}

final class ColleaguesViewModelImpl: BaseViewModel, ColleaguesViewModel {
  private let userService: UserService
  
  init(userService: UserService) {
    self.userService = userService
  }
  
  var onRefreshList: (([User]) -> Void)?
  var onError: ((ListType) -> Void)?
  var users = [User]()
  var filteredUsers = [User]()
  var searchedUsers = [User]()
  var listType = ListType.all
  var recordType: RecordType?
  
  private lazy var isSearching = false
  
  override func viewDidLoad() {
    all()
  }
  
  func all() {
    userService.getAllUsers(
      sortDecrciptors: [NSSortDescriptor(key: "slackProfile.realName", ascending: true)],
      onLocal: { [weak self] result in
        self?.handleResult(.all, result: result)
      }, onFetch: { [weak self] result in
        self?.handleResult(.all, result: result)
    })
  }
  
  func away() {
    userService.getAwayUsers { [weak self] result in
      self?.handleResult(.filtered, result: result)
    }
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
    isSearching = true
    onRefreshList?(getUsersByCurrentListType())
  }
  
  func refresh() {
    switch listType {
    case .all:
      all()
    case .filtered:
      if let recordType = recordType {
        if case .away = recordType {
          away()
        } else {
          sort(recordType)
        }
      }
    }
  }
  
  func updateRecordType(_ recordType: RecordType) {
    self.recordType = recordType
    if recordType == .all {
      self.listType = .all
      self.all()
    } else if recordType == .away {
      self.listType = .filtered
      self.away()
    } else {
      self.listType = .filtered
      self.sort(recordType)
    }
  }
  
  func cancelSearch() {
    isSearching = false
    onRefreshList?(getUsersByCurrentListType())
  }
  
  func getUsersByCurrentListType() -> [User] {
    if isSearching {
      return searchedUsers
    } else {
      switch listType {
      case .all:
        return users
      case .filtered:
        return filteredUsers
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
      self.onRefreshList?(users)
    case .failure(let error):
      self.onError?(listType)
      print(error.localizedDescription)
    }
  }
}
