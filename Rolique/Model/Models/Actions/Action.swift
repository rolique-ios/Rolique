//
//  Action.swift
//  Model
//
//  Created by Andrii on 8/2/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation
import Networking

public class Action: Model {
  
  public enum ActionType: String {
    case empty
    case late
  }
  
  enum CodingKeys: String, CodingKey {
      case type, props, sender
  }
  
  public var type: ActionType
  public var sender: String
  public var props: [String: String]?
  
  init(sender: String, type: String, props: [String: String]? = nil) {
    self.type = ActionType(rawValue: type) ?? .empty
    self.sender = sender
    self.props = props
    var map: [String: Any] = [
      "sender": sender,
      "type": type]
    if let props = props {
      map["props"] = props
    }
    super.init(map: map)
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let typeString = try values.decode(String.self, forKey: .type)
    self.type =  ActionType(rawValue: typeString) ?? .empty
    self.props = try values.decode([String: String].self, forKey: .props)
    self.sender = try values.decode(String.self, forKey: .sender)
    try super.init(from: decoder)
  }

  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type.rawValue, forKey: .type)
    try container.encode(props, forKey: .props)
    try container.encode(sender, forKey: .sender)
    try super.encode(to: encoder)
  }

  func makeCommand() -> Command {
    return Command(trigger: type.rawValue, sender: sender, params: props ?? [:], isTest: true)
  }
}
