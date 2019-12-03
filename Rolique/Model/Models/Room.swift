//
//  Room.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/26/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

public enum MeetingRoom: String, CaseIterable {
  case conference = "conference-4"
  case first = "meeting-1-4"
  case second = "meeting-2-4"
  
  var description: String {
    switch self {
    case .conference:
      return "Conf"
    case .first:
      return "MR1"
    case .second:
      return "MR2"
    }
  }
}

public final class Room: Codable {
  enum CodingKeys: String, CodingKey, CaseIterable {
    case id
    case title = "summary"
    case creator
    case organizer
    case start
    case end
    case recurrence
    case attendees
    case htmlLink
    case hangoutLink
  }
  
  let id: String
  let title: String?
  let creator: UserInfo
  let organizer: UserInfo
  let start: BookingTime
  let end: BookingTime
  let recurrence: [String]?
  let attendees: [Attendee]
  let htmlLink: String?
  let hangoutLink: String?
  
  init(id: String, title: String?, creator: UserInfo, organizer: UserInfo, start: BookingTime, end: BookingTime, recurrence: [String], attendees: [Attendee], htmlLink: String?, hangoutLink: String?) {
    self.id = id
    self.title = title
    self.creator = creator
    self.organizer = organizer
    self.start = start
    self.end = end
    self.recurrence = recurrence
    self.attendees = attendees
    self.htmlLink = htmlLink
    self.hangoutLink = hangoutLink
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try values.decode(String.self, forKey: .id)
    self.title = try? values.decode(String.self, forKey: .title)
    self.creator = try values.decode(UserInfo.self, forKey: .creator)
    self.organizer = try values.decode(UserInfo.self, forKey: .creator)
    self.start = try values.decode(BookingTime.self, forKey: .start)
    self.end = try values.decode(BookingTime.self, forKey: .end)
    self.recurrence = try? values.decode([String].self, forKey: .recurrence)
    self.attendees = try values.decode([Attendee].self, forKey: .attendees)
    self.htmlLink = try? values.decode(String.self, forKey: .htmlLink)
    self.hangoutLink = try? values.decode(String.self, forKey: .hangoutLink)
  }
}

public final class UserInfo: Codable {
  enum CodingKeys: String, CodingKey, CaseIterable {
    case email
    case displayName
  }
  
  let email: String
  let displayName: String?
  
  init(email: String, displayName: String?) {
    self.email = email
    self.displayName = displayName
  }
}

public final class Attendee: Codable {
  enum CodingKeys: String, CodingKey, CaseIterable {
    case email
    case isOrganizer = "organizer"
    case displayName
    case isSelf = "self"
    case isResource = "resource"
    case responseStatus
  }
  
  let email: String
  var isOrganizer: Bool = false
  let displayName: String?
  let isSelf: Bool?
  var isResource: Bool = false
  let responseStatus: String
  
  init(with email: String, displayName: String?, isSelf: Bool?, isResource: Bool = false, isOrganizer: Bool = false, responseStatus: String) {
    self.email = email
    self.isOrganizer = isOrganizer
    self.displayName = displayName
    self.isSelf = isSelf
    self.isResource = isResource
    self.responseStatus = responseStatus
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.email = try values.decode(String.self, forKey: .email)
    self.isOrganizer = (try? values.decode(Bool.self, forKey: .isOrganizer)) ?? false
    self.displayName = try? values.decode(String.self, forKey: .displayName)
    self.isSelf = try? values.decode(Bool.self, forKey: .isSelf)
    self.isResource = (try? values.decode(Bool.self, forKey: .isResource)) ?? false
    self.responseStatus = try values.decode(String.self, forKey: .responseStatus)
  }
}

public final class BookingTime: Codable {
  enum CodingKeys: String, CodingKey, CaseIterable {
    case dateTime
    case timeZone
  }
  
  let dateTime: Date
  var timeZone: String?
  
  init(with dateTime: Date, timeZone: String?) {
    self.dateTime = dateTime
    self.timeZone = timeZone
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let dateTimeString = try values.decode(String.self, forKey: .dateTime)
    self.timeZone = try? values.decode(String.self, forKey: .timeZone)
    let timeZone = TimeZone(identifier: self.timeZone ?? "") ?? .current
    let ISO8601Date = ISO8601DateFormatter().date(from: dateTimeString).orCurrent
    let calendar = Calendar.current
    self.dateTime = calendar.date(byAdding: .second, value: timeZone.secondsFromGMT(), to: ISO8601Date).orCurrent
  }
}

public final class RoomRequest: Codable {
  enum CodingKeys: String, CodingKey, CaseIterable {
    case room
    case startDate = "start_date"
    case endDate = "end_date"
  }
  
  let room: String
  let startDate: Date
  let endDate: Date
  
  init(room: String, startDate: Date, endDate: Date) {
    self.room = room
    self.startDate = startDate
    self.endDate = endDate
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.room = try values.decode(String.self, forKey: .room)
    let startDateString = try values.decode(String.self, forKey: .startDate)
    self.startDate = DateFormatters.dateFormatter.date(from: startDateString).orCurrent
    let endDateString = try values.decode(String.self, forKey: .endDate)
    self.endDate = DateFormatters.dateFormatter.date(from: endDateString).orCurrent
  }
}
