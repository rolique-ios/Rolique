//
//  Err.swift
//  Networking
//
//  Created by Andrii on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

public enum Err: Error {

  case general(msg: String)
  
  var localizedDescription: String {
    if case .general(let msg) = self {
      return msg
    } else { return "unknown error" }
  }
}
