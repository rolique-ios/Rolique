//
//  MeetingRooms.swift
//  Networking
//
//  Created by Maksym Ivanyk on 11/26/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

public final class GetMeetingRooms: Route {
  public init(meetingRoom: String, startDate: String, endDate: String) {
    let params = ["room": meetingRoom,
                  "start_date": startDate,
                  "end_date": endDate]
    
    super.init(endpoint:"rooms", method: .get, urlParams: params)
  }
}

public final class PostMeetingRoom: Route {
  public init(meetingRoom: String, startTime: String, endTime: String, timeZone: String, summary: String?, participants: [(email: String?, displayName: String?)], isTest: String) {
    let params = ["room": meetingRoom, "test": isTest]
    
    var eventParams = [String: Any]()
    
    eventParams["start"] = ["dateTime": startTime, "timeZone": timeZone]
    eventParams["end"] = ["dateTime": endTime, "timeZone": timeZone]
    
    var attendees = [[String: String?]]()
    for participant in participants {
      attendees.append(["email": participant.email, "displayName": participant.displayName])
    }
    if !attendees.isEmpty {
      eventParams["attendees"] = attendees
    }
    if let summary = summary {
      eventParams["summary"] = summary
    }
    let bodyParams = ["event": eventParams]
    
    super.init(endpoint:"rooms", method: .post, urlParams: params, body: bodyParams)
  }
}
