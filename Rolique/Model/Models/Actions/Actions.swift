//
//  ActionLate.swift
//  Model
//
//  Created by Andrii on 8/2/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

public enum ActionType: String, CaseIterable {
  case late
  case remote
  case doprac
  case pochav
}

public enum DopracType {
  case now
  case hour(Date?)
  
  var description: String {
    switch self {
    case .now:
      return "now"
    case .hour:
      return "hour"
    }
  }
}

public enum RemoteType {
  case today
  case tommorow
  case custom(start: Date, end: Date)
  
  var description: String {
    switch self {
    case .today:
      return "today"
    case .tommorow:
      return "tomorrow"
    case .custom:
      return "custom"
    }
  }
}

public enum From {
  case now
  case tenOclock
  
  var param: String {
    switch self {
    case .now:
      return "now"
    case .tenOclock:
      return "start"
    }
  }
}

public enum LateType {
  case in30minutes(from: From)
  case in1hour(from: From)
  case choosen(from: From, time: String)
  
  var description: String {
    switch self {
    case .in30minutes:
      return "30_m"
    case .in1hour:
      return "1_h"
    case .choosen(let value):
      return value.time
    }
  }
}

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
  public init(sender: String, value: String, startDate: String? = nil, endDate: String? = nil) {
    var props = ["value": value]
    if let startDate = startDate {
      props["start_date"] = startDate
    }
    if let endDate = endDate {
      props["end_date"] = endDate
    }
    super.init(type: "remote", sender: sender, test: Settings.isTest, props: props)
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
    super.init(type: "doprac", sender: sender, test: Settings.isTest, props: props)
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
  }
}

public final class ActionPochav: Action {
  public init(sender: String) {
    super.init(type: "pochav", sender: sender, test: Settings.isTest, props: [:])
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
  }
}
