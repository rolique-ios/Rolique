//
//  Model.swift
//  Model
//
//  Created by Andrii on 8/1/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation
import Networking

public protocol ModelType: Codable {
//  var stringValue: String { get set }
//
//  var isValid: Bool { get }
//  func parse() -> [String: Any]?
 }

public extension ModelType {
  
}

public class Model: ModelType {
//  public var stringValue: String
//  public init(map: [String: Any]?) {
//    self.stringValue = Json.stringify(dict: map ?? [:]) ?? ""
//  }
}

//public extension Model {
//  func get(key: String) -> Any? { return Json.get(dict: parse() ?? [:], keyPath: key) }
//  
//  func parse() -> [String: Any]? {
//    return Model.parse(stringValue)
//  }
//  
//  static func parse(_ stringValue: String) -> [String: Any]? {
//    return Json.parse(stringValue)
//  }
//  
//  static func stringify(_ dict: [String: Any]) -> String? {
//    return Json.stringify(dict: dict)
//  }
//  
//  var isValid: Bool { return parse() != nil }
//  
//  var error: String? { return parse()?["error"] as? String }
//  
//  
//  convenience init() {
//    self.init(map: [:])
//    self.stringValue = ""
//  }
//}



