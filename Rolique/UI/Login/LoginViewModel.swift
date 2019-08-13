//
//  LoginViewModel.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Foundation
import Utils

protocol LoginViewModel: ViewModel {
  var onError: ((String) -> Void)? { get set }
  
  func login()
}

final class LoginViewModelImpl: BaseViewModel, LoginViewModel {
  private let loginManager: LoginManager
  
  init(loginManager: LoginManager) {
    self.loginManager = loginManager
  }
  
  var onError: ((String) -> Void)?
  
  func login() {
    self.loginManager.login { [weak self] res in
      switch res {
      case .success(let user):
        print("\(user)")
        UserDefaultsManager.shared.userId = user.id
        self?.shouldSet?([Router.getTabBarController()], true)
      case .failure(let error):
        self?.onError?(error.localizedDescription)
      }
    }
  }
}


