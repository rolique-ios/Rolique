//
//  UserManager.swift
//  Model
//
//  Created by Andrii on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Networking

public protocol  UserManager {
  func getAllUsers(result: ((Result<[User], Error>) -> Void)?)
  func getUserWithId(_ userId: String, result: ((Result<User, Error>) -> Void)?)
  func getTodayUsersForRecordType(recordType: String, result: ((Result<[User], Error>) -> Void)?)
}

public final class UserManagerImpl:  UserManager {
  public func getAllUsers(result: ((Result<[User], Error>) -> Void)?) {
    Net.Worker.request(GetAllUsers(), onSuccess: { json in
      DispatchQueue.main.async {
        print(json)
      }
    }, onError: { error in
      DispatchQueue.main.async {
        print(error)
        result?(.failure(error))
      }
    })
  }
  
  public func getUserWithId(_ userId: String, result: ((Result<User, Error>) -> Void)?) {
    Net.Worker.request(GetUserWithId(userId: userId), onSuccess: { json in
      DispatchQueue.main.async {
        print(json)
      }
    }, onError: { error in
      DispatchQueue.main.async {
        print(error)
        result?(.failure(error))
      }
    })
  }
  
  public func getTodayUsersForRecordType(recordType: String, result: ((Result<[User], Error>) -> Void)?) {
    Net.Worker.request(GetTodayUsersForRecordType(recordType: recordType), onSuccess: { json in
      DispatchQueue.main.async {
        print(json)
      }
    }, onError: { error in
      DispatchQueue.main.async {
        print(error)
        result?(.failure(error))
      }
    })
  }
  
  
  public init() {}
  
  public func sendAction(_ action: Action, result: ((Result<ActionResult, Error>) -> Void)?) {
    Net.Worker.request(action.makeCommand(), onSuccess: { json in
      DispatchQueue.main.async {
        result?(.success(ActionResult(error: json.string("error"))))
      }
    }, onError: { error in
      DispatchQueue.main.async {
        result?(.success(ActionResult(error: error.localizedDescription)))
      }
    })
  }
}
