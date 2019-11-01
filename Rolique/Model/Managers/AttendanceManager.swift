//
//  AttendanceManager.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 10/29/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Networking

public protocol AttendanceManager {
  func getAttandance(startDate: Date, endDate: Date, limit: Int?, offset: Int?, result: ((Result<[AttendanceRecord], Error>) -> Void)?)
}

public final class AttendanceManagerImpl: AttendanceManager {
  public init() {}
  
  public func getAttandance(startDate: Date, endDate: Date, limit: Int? = nil, offset: Int? = nil, result: ((Result<[AttendanceRecord], Error>) -> Void)?) {
    Net.Worker.request(GetAttendance(startDate: startDate, endDate: endDate, limit: limit, offset: offset), onSuccess: { json in
      DispatchQueue.main.async {
        let array: [AttendanceRecord]? = json.buildArray()
        if let array = array {
          result?(.success(array))
        } else {
          result?(.failure(Err.general(msg: "failed to build attendance records")))
        }
      }
    }, onError: { error in
      DispatchQueue.main.async {
        result?(.failure(error))
      }
    })
  }
}
