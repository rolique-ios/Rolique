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
  var currentUser: User { get }
  func getAllUsersFromLocal(usersResult: (([User]) -> Void)?)
  func getAwayUsers(onFetch: ((Result<[User], Error>) -> Void)?)
  func getAllUsers(sortDecrciptors: [NSSortDescriptor]?, onLocal: ((Result<[User], Error>) -> Void)?, onFetch: ((Result<[User], Error>) -> Void)?)
  func getUserWithId(_ userId: String, onLocal: ((Result<User, Error>) -> Void)?, onFetch: ((Result<User, Error>) -> Void)?)
  func getTodayUsersForRecordType(_ recordType: RecordType, onLocal: ((Result<[User], Error>) -> Void)?, onFetch: ((Result<[User], Error>) -> Void)?)
}

class UserServiceImpl: UserService {
  let currentUser: User
  let userManager: UserManager
  let coreDataManager: CoreDataManager<User>
  
  init(userManager: UserManager, coreDataManager: CoreDataManager<User>, user: User) {
    self.currentUser = user
    self.userManager = userManager
    self.coreDataManager = coreDataManager
  }
  
  func getAllUsersFromLocal(usersResult: (([User]) -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }
      
      let context = CoreDataController.shared.backgroundContext()
      do {
        let mos = try self.coreDataManager.getManagedObjects(sortDescriptors:  [NSSortDescriptor(key: "slackProfile.realName", ascending: true)], context: context)
        let users = mos.compactMap { User($0) }
        DispatchQueue.main.async {
          usersResult?(users)
        }
      } catch {
        DispatchQueue.main.async {
          usersResult?([])
        }
      }
    }
  }
  
  func getAllUsers(sortDecrciptors: [NSSortDescriptor]?, onLocal: ((Result<[User], Error>) -> Void)?, onFetch: ((Result<[User], Error>) -> Void)?) {
    let context = CoreDataController.shared.backgroundContext()
    var mos = [User.ManagedType]()
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let self = self else { return }
      do {
        mos = try self.coreDataManager.getManagedObjects(sortDescriptors: sortDecrciptors, context: context)
        let users = mos.compactMap { User($0) }
        DispatchQueue.main.async {
          onLocal?(.success(users))
        }
      } catch {
        DispatchQueue.main.async {
          onLocal?(.failure(error))
        }
      }
    }
    
    userManager.getAllUsers { [weak self] usersResult in
      switch usersResult {
      case .success(let users):
        DispatchQueue.global(qos: .userInteractive).async {
          let today = Date().normalized
          let todayStatusDate = TodayStatusDate(date: today, todayStatuses: [:]).createOrUpdate(with: context)
          
          for user in users {
            guard let status = TodayStatus(status: user.todayStatus.orEmpty, userId: user.id).createOrUpdate(with: context) else {
              continue
            }
            
            todayStatusDate?.addToStatuses(status)
          }
          
          self?.coreDataManager.saveToCoreDateWithoutMismatch(mos, objects: users, context: context)
        }
        onFetch?(.success(users))
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
  
  func getTodayUsersForRecordType(_ recordType: RecordType, onLocal: ((Result<[User], Error>) -> Void)?, onFetch: ((Result<[User], Error>) -> Void)?) {
    let context = CoreDataController.shared.backgroundContext()
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let self = self else { return }
      
      do {
        let moUsers = try self.coreDataManager.getManagedObjects(context: context)
        let filteredUsers = moUsers.compactMap { User($0) }.filter { $0.todayStatus == recordType.rawValue }
        DispatchQueue.main.async {
          onLocal?(.success(filteredUsers))
        }
      } catch {
        DispatchQueue.main.async {
          onLocal?(.failure(error))
        }
      }
    }

    userManager.getTodayUsersForRecordType(recordType) { [weak self] usersResult in
      switch usersResult {
      case .success(let array):
        self?.coreDataManager.saveToCoreData(array, context: context)
        onFetch?(.success(array))
      case .failure(let error):
        onFetch?(.failure(error))
      }
    }
  }
  
  func getAwayUsers(onFetch: ((Result<[User], Error>) -> Void)?) {
    userManager.getAllUsers { usersResult in
      switch usersResult {
      case .success(let array):
        onFetch?(.success(array.filter({ $0.todayStatus?.isEmpty == false })))
      case .failure(let error):
        onFetch?(.failure(error))
      }
    }
  }
}
