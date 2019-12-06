//
//  MoreViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/7/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Utils

protocol MoreViewModel: ViewModel {
  var user: User { get }
}

final class MoreViewModelImpl: BaseViewModel, MoreViewModel {
  private let userService: UserService
  let user: User
  
  init(userService: UserService, user: User) {
    self.userService = userService
    self.user = user
  }
}
