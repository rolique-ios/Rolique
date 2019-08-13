//
//  Json.swift
//  ROLIQUE
//
//  Created by Andrii on 7/31/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

public struct Json: Codable {
  public let stringValue: String
  public init(stringValue: String) {
    self.stringValue = stringValue
  }
}

public extension Json {
  
  func build<M: Codable>() -> M? {
    guard let body = self.json("body") else {
      print("failed to build body")
      return nil }
    guard let data = body.stringValue.data(using: .utf8) else {
      print("failed to build data")
      return nil }
    do {
    return try JSONDecoder().decode(M.self, from: data)
    } catch let err {
      print(err)
      return nil
    }
  }
  
  func buildArray<M: Codable>() -> [M]? {
    guard let values = Json.get(json: self, keyPath: "values") as? [[String: Any]] else {
      print("failed to get values")
      return nil }
    let jsones: [Json] = values.compactMap { Json(stringValue: Json.stringify(dict: $0) ?? "bad_json_string") }
    let coded: [M] = jsones.compactMap { $0.build() }
    return coded
  }
  
  var error: String? { return string("error") }
  
  func json(_ keyPath: String) -> Json? {
    guard let dict = self.dict(keyPath) else { return nil }
    guard let jsonString = Json.stringify(dict: dict) else { return nil }
    return Json(stringValue: jsonString)
  }
  
  func string(_ keyPath: String) -> String? {
    return Json.get(json: self, keyPath: keyPath) as? String
  }
  
  func int(_ keyPath: String) -> Int? {
    return Json.get(json: self, keyPath: keyPath) as? Int
  }
  
  func bool(_ keyPath: String) -> Bool? {
    return Json.get(json: self, keyPath: keyPath) as? Bool
  }
  
  func float(_ keyPath: String) -> Float? {
    return Json.get(json: self, keyPath: keyPath) as? Float
  }
  
  func dict() -> [String: Any]? {
    return Json.parse(self.stringValue)
  }
  
  func dict(_ keyPath: String) -> [String: Any]? {
    return Json.get(json: self, keyPath: keyPath) as? [String: Any]
  }
  
  func any(_ keyPath: String) -> Any? {
    return Json.get(json: self, keyPath: keyPath)
  }
  
  static func stringify(dict: [String: Any]) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return nil }
    guard let jsonString = String(data: data, encoding: .utf8) else { return nil }
    return jsonString
  }
  
  static func parse(_ jsonString: String) -> [String: Any]? {
    guard let data = jsonString.data(using: .utf8) else { return nil }
    return try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
  }
  
  static func get(json: Json, keyPath: String) -> Any? {
    guard let parsed = Json.parse(json.stringValue) else { return nil }
    return Json.get(dict: parsed, keyPath: keyPath)
  }
  
  static func get(dict: [String: Any], keyPath: String) -> Any? {
    if keyPath.contains("/") {
      var parts = keyPath.split(separator: "/")
      let first = String(parts.removeFirst())
      if let subDict = dict[first] as? [String: Any] {
        return Json.get(dict: subDict, keyPath: parts.joined(separator: "/"))
      } else {
        return dict[first]
      }
    } else {
      return dict[keyPath]
    }
  }
  
}
