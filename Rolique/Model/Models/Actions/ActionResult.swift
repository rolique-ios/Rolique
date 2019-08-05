//
//  ActionResult.swift
//  Model
//
//  Created by Andrii on 8/1/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

public final class ActionResult: Codable, CustomStringConvertible {
  
  public let error: String?
  public let ok: Bool

  init (error: String?) {
    self.error = error
    self.ok = error == nil
  }
  
  public var description: String {
    return "ActionResult ok: \(ok), error: \(error ?? "")"
  }

}
