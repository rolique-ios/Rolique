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
  var onSuccess: (() -> Void)? { get set }
  
  func all()
  func onRemote()
  func onVacation()
}

final class ColleaguesViewModelImpl: BaseViewModel, ColleaguesViewModel {
  private let userService: UserService
  
  init(userService: UserService) {
    self.userService = userService
  }
  
  var onSuccess: (() -> Void)?
  var users = [User]()
  
  func all() {
    userService.getAllUsers(onLocal: { [weak self] result in
      self?.handleResult(result)
    }, onFetch: { [weak self] result in
      self?.handleResult(result)
    })
  }
  
  func onRemote() {
    userService.getTodayUsersForRecordType(.remote) { [weak self] result in
      self?.handleResult(result)
    }
  }
  
  func onVacation() {
    userService.getTodayUsersForRecordType(.vacation) { [weak self] result in
      self?.handleResult(result)
    }
  }
  
  private func handleResult(_ result: Result<[User], Error>) {
    switch result {
    case .success(let users):
      self.users = users
      self.onSuccess?()
    case .failure(let error):
      print(error.localizedDescription)
    }
  }
}
