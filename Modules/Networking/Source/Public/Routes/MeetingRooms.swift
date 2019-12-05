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
