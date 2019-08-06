//
//  ActionLate.swift
//  Model
//
//  Created by Andrii on 8/2/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

public final class ActionLate: Action {
  public init(sender: String, from: String, value: String) {
    super.init(type: "late", sender: sender, test: "true", props: ["from": from, "value": value])
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
  }
}

public final class ActionRemote: Action {
  public init(sender: String, from: String, value: String) {
    super.init(type: "remote", sender: sender, test: "true", props: ["from": from, "value": value])
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
  }
}
