//
//  MoreViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/7/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Utils

protocol MoreViewModel: ViewModel {
  var user: User? { get }
  var onSuccess: Completion? { get set }
  var onError: ((String) -> Void)? { get set }
}

final class MoreViewModelImpl: BaseViewModel, MoreViewModel {
  private let userService: UserService
  var user: User?
  
  init(userService: UserService) {
    self.userService = userService
  }
  
  var onSuccess: Completion?
  var onError: ((String) -> Void)?
  
  override func viewDidLoad() {
    getUser()
  }
  
  func getUser() {
    userService.getUserWithId(UserDefaultsManager.shared.userId ?? "",
                              onLocal: handleUserResponse(result:),
                              onFetch: handleUserResponse(result:))
  }
  
  private func handleUserResponse(result: Result<User, Error>) {
    switch result {
    case .success(let user):
      self.user = user
      onSuccess?()
    case .failure(let error):
      onError?(error.localizedDescription)
    }
  }
}
