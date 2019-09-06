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
  static var botId: String { return "botId" }
  static var teamId: String { return "teamId" }
  static var teamName: String { return "teamName" }
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
  
  public var botId: String? {
    get {
      return defaults.string(forKey: Constants.botId)
    } set {
      defaults.set(newValue, forKey: Constants.botId)
    }
  }
  
  public var teamId: String? {
    get {
      return defaults.string(forKey: Constants.teamId)
    } set {
      defaults.set(newValue, forKey: Constants.teamId)
    }
  }
  
  public var teamName: String? {
    get {
      return defaults.string(forKey: Constants.teamName)
    } set {
      defaults.set(newValue, forKey: Constants.teamName)
    }
  }
}
