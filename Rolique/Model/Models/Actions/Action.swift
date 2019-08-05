//
//  Action.swift
//  Model
//
//  Created by Andrii on 8/2/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation
import Networking

public class Action: Codable {
  let type, sender, test: String
  let props: [String: String]?
  
  init(type: String, sender: String, test: String, props: [String: String]?) {
    self.type = type
    self.sender = sender
    self.test = test
    self.props = props
  }
  
  func makeCommand() -> Command {
    return Command(trigger: type, sender: sender, params: props ?? [:], isTest: true)
  }
}
