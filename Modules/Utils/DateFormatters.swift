//
//  DateFormatters.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/29/19.
//

public final class DateFormatters {
  public static var dopracDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter
  }()
  
  public static var remoteDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
  }()
}
