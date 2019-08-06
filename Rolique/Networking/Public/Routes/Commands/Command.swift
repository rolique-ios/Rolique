//
//  Command.swift
//  Networking
//
//  Created by Andrii on 7/31/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

public class Command: Route {
  public init(trigger: String, sender: String, params: Route.Params, isTest: Bool) {
    var prms: Route.Params = [
      "type": trigger,
      "sender": sender,
      "test": isTest ? "true" : "false",
    ]
    params.keys.forEach { prms[$0] = params[$0] }
    super.init(endpoint: "command", method: .get, urlParams: prms)
  }
}
