//
//  DateFormatters.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/29/19.
//

import Foundation

final class DateFormatters {
  static var dopracDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter
  }()
  
  static var remoteDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
  }()
  
  static var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
    return dateFormatter
  }()
  
  static var withTDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm"
    return dateFormatter
  }()
  
  static var timeDateFormatter: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter
  }()
  
  static func withTimeZoneFormatter(timeZone: TimeZone?) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.timeZone = timeZone
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return formatter
  }
}
