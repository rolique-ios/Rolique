//
//  ActionLate.swift
//  Model
//
//  Created by Andrii on 8/2/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

struct Settings {
  static let isTest = "true"
}

public final class ActionLate: Action {
  public init(sender: String, from: String, value: String) {
    super.init(type: "late", sender: sender, test: Settings.isTest, props: ["from": from, "value": value])
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
  }
}

public final class ActionRemote: Action {
  public init(sender: String, value: String) {
    super.init(type: "remote", sender: sender, test: Settings.isTest, props: ["value": value])
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
  }
}

public final class ActionDoprac: Action {
  public init(sender: String, value: String, custom: String? = nil) {
    var props = ["value": value]
    if let custom = custom {
      props["custom"] = custom
    }
    super.init(type: "remote", sender: sender, test: Settings.isTest, props: props)
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
  }
}
