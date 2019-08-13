//
//  Late.swift
//  Networking
//
//  Created by Andrii on 7/31/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

public final class Late: Command {
  public enum From: String { case now, start }
  
  public enum To: String {
    case fiveMin = "5_m"
    case tenMin = "10_m"
    case fftnMin = "15_m"
    case thrtyMin = "30_m"
    case frtyFveMin = "45_m"
    case oneHr = "1_h"
    case twoHr = "2_h"
    case threeHr = "3_h"
    case fourHr = "4_h"
    case sixHr = "6_h"
  }
  
  public init(sender: String, from: From, to: To, isTest: Bool = false) {
    super.init(trigger: "late", sender: sender, params: [
      "from": from.rawValue,
      "value": to.rawValue
    ], isTest: isTest)
  }
  
  public init(sender: String, from: String, value: String, isTest: Bool = false) {
    super.init(trigger: "late", sender: sender, params: [
      "from": from,
      "value": value
    ], isTest: isTest)
  }
}
