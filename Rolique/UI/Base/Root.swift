//
//  Root.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/26/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Dip

final class Root {
  let container = DependencyContainer()
  static let shared = Root()
  
  private init() {
    registerManagers()
    registerServices()
    registerViewModels()
  }
  
  /// does nothing, just triggers registration
  func start() {}
  
  func safeResolve<DependencyType>() throws -> DependencyType {
    return try container.resolve()
  }
  
  func hardResolve<DependencyType>() -> DependencyType {
    return try! safeResolve()
  }
  
  func resolveRuntime<T, Z>(arg1: Z) -> T {
    return try! self.container.resolve(arguments: arg1)
  }
  
  func resolveRuntime<T, Z, H>(arg1: Z, arg2: H) -> T {
    return try! self.container.resolve(arguments: arg1, arg2)
  }
  
  func resolveRuntime<T, Z, H, G>(arg1: Z, arg2: H, arg3: G) -> T {
    return try! self.container.resolve(arguments: arg1, arg2, arg3)
  }
  
  func registerUserService(with user: User) {
    container.register(.singleton) { UserServiceImpl(userManager: self.hardResolve(), coreDataManager: self.hardResolve(), user: user) as UserService }
  }
}

private extension Root {
  func registerManagers() {
    container.register(.singleton) { LoginManagerImpl() as LoginManager }
    container.register(.singleton) { UserManagerImpl() as UserManager }
    container.register(.singleton) { ActionMangerImpl() as ActionManger }
    container.register(.singleton) { AttendanceManagerImpl() as AttendanceManager }
    container.register(.singleton) { MeetingRoomManagerImpl() as MeetingRoomManager }
    
    container.register(.singleton) { CoreDataManager<User>() }
  }
  
  func registerServices() {
    container.register(.singleton) { LoginServiceImpl(loginManager: self.hardResolve(), coreDataManager: self.hardResolve()) as LoginService }
  }
  
  func registerViewModels() {
    container.register(.unique) { LoginViewModelImpl(loginService: self.hardResolve()) }
    container.register(.unique) { users, mode in ColleaguesViewModelImpl(users: users, mode: mode, userService: self.hardResolve()) }
    container.register(.unique) { ActionsViewModelImpl(actionManager: self.hardResolve()) }
    container.register(.unique) { CalendarViewModelImpl(userService: self.hardResolve(), attendanceManager: self.hardResolve()) }
    container.register(.unique) { user in MoreViewModelImpl(userService: self.hardResolve(), user: user) }
    container.register(.unique) { user in ProfileDetailViewModelImpl(userService: self.hardResolve(), coreDataMananger: self.hardResolve(), user: user) }
    container.register(.unique) { MeetingRoomsViewModelImpl(userService: self.hardResolve(), meetingRoomsManager: self.hardResolve()) }
  }
}
