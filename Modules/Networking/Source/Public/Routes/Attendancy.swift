//
//  Attendance.swift
//  Networking
//
//  Created by Maksym Ivanyk on 10/29/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

public final class GetAttendance: Route {
  public init(startDate: Date, endDate: Date, limit: Int? = nil, offset: Int? = nil) {
    print(startDate)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd"
    let startDate = dateFormatter.string(from: startDate)
    let endDate = dateFormatter.string(from: endDate)
    
    var params = ["start_date": startDate,
                  "end_date": endDate]
    
    if let limit = limit {
      params["limit"] = "\(limit)"
    }
    
    if let offset = offset {
      params["offset"] = "\(offset)"
    }
    
    super.init(endpoint:"attendancy", method: .get, urlParams: params)
  }
}
