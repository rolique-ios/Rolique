//
//  Settings.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 12/25/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

struct Settings {
  static var isTest: String {
    #if DEBUG
    return "true"
    #else
    return "false"
    #endif
  }
}
