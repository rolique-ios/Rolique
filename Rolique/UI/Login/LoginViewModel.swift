//
//  LoginViewModel.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Foundation
import Model

public protocol LoginViewModel: ViewModel {
  var onError: ((String) -> Void)? { get set }
  
  func login()
}

public final class LoginViewModelImpl: BaseViewModel, LoginViewModel {
  
  private let loginManager: LoginManager
  
  public init(loginManager: LoginManager) {
    self.loginManager = loginManager
  }
  
  public var onError: ((String) -> Void)?
  
  public func login() {
    self.loginManager.login { [weak self] res in
      switch res {
      case .success(let user):
        print(user)
      case .failure(let error):
        self?.onError?(error.localizedDescription)
      }
    }
  }
}


