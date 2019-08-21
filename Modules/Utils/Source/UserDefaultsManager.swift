//
//  UserDefaultsManager.swift
//  Utils
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

private struct Constants {
  static var openFirstTime: String { return "openFirstTime" }
  static var userId: String { return "userId" }
  static var allUsersRequstTime: String { return "allUsersRequstTime" }
  static var allUsersRequstTimeLimit: String { return "allUsersRequstTimeLimit" }
}

public final class UserDefaultsManager {
  public static let shared = UserDefaultsManager()
  private let defaults = UserDefaults.standard
  
  public var openFirstTime: Bool {
    get {
      return !defaults.bool(forKey: Constants.openFirstTime)
    } set {
      defaults.set(!newValue, forKey: Constants.openFirstTime)
    }
  }
  
  public var userId: String? {
    get {
      return defaults.string(forKey: Constants.userId)
    } set {
      defaults.set(newValue, forKey: Constants.userId)
    }
  }
  
  public var allUsersRequstTime: Date? {
    get {
      return defaults.object(forKey: Constants.allUsersRequstTime) as? Date
    } set {
      defaults.set(newValue, forKey: Constants.allUsersRequstTime)
    }
  }
  
  public var allUsersRequstTimeLimit: Date? {
    get {
      return defaults.object(forKey: Constants.allUsersRequstTimeLimit) as? Date
    } set {
      defaults.set(newValue, forKey: Constants.allUsersRequstTimeLimit)
    }
  }
}
