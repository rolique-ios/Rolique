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
}
