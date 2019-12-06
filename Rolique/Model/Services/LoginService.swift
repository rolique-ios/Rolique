//
//  LoginService.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 12/6/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Utils

public protocol LoginService {
  func login(result: ((Result<User, Error>) -> Void)?)
}

class LoginServiceImpl: LoginService {
  let loginManager: LoginManager
  let coreDataManager: CoreDataManager<User>
  
  init(loginManager: LoginManager, coreDataManager: CoreDataManager<User>) {
    self.loginManager = loginManager
    self.coreDataManager = coreDataManager
  }
  
  func login(result: ((Result<User, Error>) -> Void)?) {
    loginManager.login { managerResult in
      switch managerResult {
      case .success(let user):
        UserDefaultsManager.shared.userId = user.id
        user.saveToCoreData()
        result?(.success(user))
      case .failure(let error):
        result?(.failure(error))
      }
    }
  }
}
