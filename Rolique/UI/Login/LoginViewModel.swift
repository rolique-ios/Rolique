//
//  LoginViewModel.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Foundation
import Utils
import Networking

protocol LoginViewModel: ViewModel {
  var onError: ((String) -> Void)? { get set }
  var onLogin: Completion? { get set }
  
  func login()
}

final class LoginViewModelImpl: BaseViewModel, LoginViewModel {
  private let loginService: LoginService
  var onLogin: Completion?
  
  init(loginService: LoginService) {
    self.loginService = loginService
  }
  
  var onError: ((String) -> Void)?
  
  func login() {
    self.loginService.login { [weak self] res in
      switch res {
      case .success:
        self?.shouldSet?([Router.getStartViewController()], true)
      case .failure(let error):
        if case Err.general(let msg)? = error as? Err {
          self?.onError?(msg)
        } else {
          self?.onError?(error.localizedDescription)
        }
      }
    }
  }
}


