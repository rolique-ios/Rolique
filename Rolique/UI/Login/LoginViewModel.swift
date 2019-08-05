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
  var onError: (() -> String)? { get set }
  
  func login()
}

public final class LoginViewModelImpl: BaseViewModel, LoginViewModel {
  private let loginManager: LoginManager
  
  public init(loginManager: LoginManager) {
    self.loginManager = loginManager
  }
  
  public var onError: (() -> String)?
  
  public func login() {
    
    self.loginManager.login { res in
      if case .success(let user) = res {
        let um = UserManagerImpl()
        um.getUserWithId(user.id, result: { result in
          print(result)
        })
      }
    }
  }
}


