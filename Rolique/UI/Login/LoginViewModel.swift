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
        let am = ActionMangerImpl()
        let action = ActionLate(sender: user.id, from: "now", value: "1_h")
        am.sendAction(action, result: { result in
          dump(result)
        })
      }
    }
  }
}


