//
//  UserManager.swift
//  Model
//
//  Created by Andrii on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Networking

public enum RecordType: String, CaseIterable {
  case all,
  away,
  vacation,
  remote,
  sick,
  dayoff,
  business_trip,
  marrige,
  baby_birth,
  funeral,
  birthday
  
  var desctiption: String {
    switch self {
    case .vacation:
      return "Vacation"
    case .remote:
      return "Remote"
    case .sick:
      return "Sick"
    case .dayoff:
      return "Day off"
    case .business_trip:
      return "Business trip"
    case .marrige:
      return "Marrige"
    case .baby_birth:
      return "Baby birth"
    case .funeral:
      return "Personal leave"
    case .birthday:
      return "Birthday"
    case .all:
      return "All"
    case .away: return "Away"
    }
  }
}

public protocol  UserManager {
  func getAllUsers(result: ((Result<[User], Error>) -> Void)?)
  func getUserWithId(_ userId: String, result: ((Result<User, Error>) -> Void)?)
  func getTodayUsersForRecordType(_ recordType: RecordType, result: ((Result<[User], Error>) -> Void)?)
}

public final class UserManagerImpl:  UserManager {
  public func getAllUsers(result: ((Result<[User], Error>) -> Void)?) {
    Net.Worker.request(GetAllUsers(), onSuccess: { json in
      DispatchQueue.main.async {
        let array: [User]? = json.buildArray()
        if let array = array {
          result?(.success(array))
        } else {
          result?(.failure(Err.general(msg: "failed to build users")))
        }
      }
    }, onError: { error in
      DispatchQueue.main.async {
        result?(.failure(error))
      }
    })
  }
  
  public func getUserWithId(_ userId: String, result: ((Result<User, Error>) -> Void)?) {
    Net.Worker.request(GetUserWithId(userId: userId), onSuccess: { json in
      DispatchQueue.main.async {
        let user: User? = json.build()
        if let user = user {
          result?(.success(user))
        } else {
          result?(.failure(Err.general(msg: "failed to build user")))
        }
      }
    }, onError: { error in
      DispatchQueue.main.async {
        result?(.failure(error))
      }
    })
  }
  
  public func getTodayUsersForRecordType(_ recordType: RecordType, result: ((Result<[User], Error>) -> Void)?) {
    getAllUsers { allUsersResult in
      switch allUsersResult {
      case .success(let array):
        let filteredArray = array.filter { $0.todayStatus == recordType.rawValue }
        result?(.success(filteredArray))
      case .failure(let error):
        result?(.failure(error))
      }
    }
  }
  
  
  public init() {}

}
