//
//  MeetingRoomManager.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/26/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Networking

public protocol MeetingRoomManager {
  func getMeetingRooms(meetingRoom: MeetingRoom, startDate: Date, endDate: Date, result: ((Result<(RoomRequest, [Room]), Error>) -> Void)?)
  func bookMeetingRoom(meetingRoom: MeetingRoom, startTime: String, endTime: String, timeZone: String, summary: String?, participants: [(email: String?, displayName: String?)], result: ((Result<Bool, Error>) -> Void)?)
}

public final class MeetingRoomManagerImpl: MeetingRoomManager {
  public init() {}
  
  public func getMeetingRooms(meetingRoom: MeetingRoom, startDate: Date, endDate: Date, result: ((Result<(RoomRequest, [Room]), Error>) -> Void)?) {
    Net.Worker.request(GetMeetingRooms(meetingRoom: meetingRoom.rawValue,
                                       startDate: DateFormatters.dateFormatter.string(from: startDate),
                                       endDate: DateFormatters.dateFormatter.string(from: endDate)), onSuccess: { json in
      DispatchQueue.main.async {
        let array: [Room]? = json.buildArray()
        if let array = array,
          let data = json.json("request")?.stringValue.data(using: .utf8),
          let roomRequest = try? JSONDecoder().decode(RoomRequest.self, from: data) {
          result?(.success((roomRequest, array)))
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
  
  public func bookMeetingRoom(meetingRoom: MeetingRoom, startTime: String, endTime: String, timeZone: String, summary: String?, participants: [(email: String?, displayName: String?)], result: ((Result<Bool, Error>) -> Void)?) {
    Net.Worker.request(PostMeetingRoom(meetingRoom: meetingRoom.rawValue, startTime: startTime, endTime: endTime, timeZone: timeZone, summary: summary, participants: participants ), onSuccess: { json in
      DispatchQueue.main.async {
        result?(.success(json.error == nil))
      }
    }, onError: { error in
      DispatchQueue.main.async {
        result?(.failure(error))
      }
    })
  }
}
