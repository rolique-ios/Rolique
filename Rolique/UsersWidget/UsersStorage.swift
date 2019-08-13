//
//  UsersStorage.swift
//  UsersWidget
//
//  Created by Bohdan Savych on 8/7/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

final class UsersStorage {
  static let shared = UsersStorage()
  private init() {}
  
  var users = [AnyUserable]()
}
