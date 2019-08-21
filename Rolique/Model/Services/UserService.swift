//
//  UserService.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/20/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Networking
import Utils

public protocol UserService {
  func getAllUsers(sortDecrciptors: [NSSortDescriptor]?, onLocal: ((Result<[User], Error>) -> Void)?, onFetch: ((Result<[User], Error>) -> Void)?)
  func getUserWithId(_ userId: String, onLocal: ((Result<User, Error>) -> Void)?, onFetch: ((Result<User, Error>) -> Void)?)
  func getTodayUsersForRecordType(_ recordType: RecordType, onFetch: ((Result<[User], Error>) -> Void)?)
}

final class UserServiceImpl: UserService {
  let userManager: UserManager
  let coreDataManager: CoreDataManager<User>
  init(userManager: UserManager, coreDataManager: CoreDataManager<User>) {
    self.userManager = userManager
    self.coreDataManager = coreDataManager
  }
  
  func getAllUsers(sortDecrciptors: [NSSortDescriptor]?, onLocal: ((Result<[User], Error>) -> Void)?, onFetch: ((Result<[User], Error>) -> Void)?) {
    do {
      let mos = try coreDataManager.getManagedObjects(sortDescriptors: sortDecrciptors)
      let users = mos.compactMap { User($0) }
      onLocal?(.success(users))
    } catch {
      onLocal?(.failure(error))
    }
    
    let date = Date()
    guard date >= UserDefaultsManager.shared.allUsersRequstTimeLimit ?? date else { return }
    
    userManager.getAllUsers { [weak self] usersResult in
      switch usersResult {
      case .success(let array):
        self?.coreDataManager.clearCoreData()
        self?.coreDataManager.saveToCoreData(array)
        self?.writeIntoUserDefaults()
        onFetch?(.success(array))
      case .failure(let error):
        onFetch?(.failure(error))
      }
    }
  }
  
  func getUserWithId(_ userId: String, onLocal: ((Result<User, Error>) -> Void)?, onFetch: ((Result<User, Error>) -> Void)?) {
    let predicate = NSPredicate(format: "id == %@", userId)
    do {
      if let managedUser = try coreDataManager.getManagedObjects(with: predicate).first,
        let user = User(managedUser) {
        onLocal?(.success(user))
      } else {
        onLocal?(.failure(Err.general(msg: "Not found user with id: \(userId)")))
      }
    } catch {
      onLocal?(.failure(error))
    }
    
    userManager.getUserWithId(userId) { userResult in
      switch userResult {
      case .success(let user):
        onFetch?(.success(user))
      case .failure(let error):
        onFetch?(.failure(error))
      }
    }
  }
  
  func getTodayUsersForRecordType(_ recordType: RecordType, onFetch: ((Result<[User], Error>) -> Void)?) {
    userManager.getTodayUsersForRecordType(recordType) { usersResult in
      switch usersResult {
      case .success(let array):
        onFetch?(.success(array))
      case .failure(let error):
        onFetch?(.failure(error))
      }
    }
  }
  
  private func writeIntoUserDefaults() {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(abbreviation: "UTC")!
    let limit = calendar.date(byAdding: .hour, value: 24, to: Date()) ?? Date()
    UserDefaultsManager.shared.allUsersRequstTime = Date()
    UserDefaultsManager.shared.allUsersRequstTimeLimit = limit
  }
}
