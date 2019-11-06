//
//  Calendar.swift
//  Utils
//
//  Created by Maksym Ivanyk on 11/1/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

public extension Calendar {
  static var utc: Calendar {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
  }
}
