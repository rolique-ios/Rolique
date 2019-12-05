//
//  AttendanceRecord.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 10/29/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

public final class AttendanceRecord: Codable {
  
   enum CodingKeys: String, CodingKey, CaseIterable {
    case startDate = "start_date"
    case userSlackId = "user_slack_id"
    case endDate = "end_date"
    case type = "type"
    case userName = "user_name"
    case created = "created"
    case reviewer = "reviewer"
    case reviewDate = "review_date"
    case editor = "editor"
    case editDate = "edit_date"
    case isCreatedByHr = "is_created_by_hr"
  }
  
  public let startDate: Date
  public let userSlackId: String
  public let endDate: Date
  public let type: String
  public let userName: String
  public let created: Date?
  public let reviewer: String?
  public let reviewDate: Date?
  public let editor: String?
  public let editDate: Date?
  public let isCreatedByHr: Bool?
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let startDateString = try values.decode(String.self, forKey: .startDate)
    startDate = DateFormatters.dateFormatter.date(from: startDateString).orCurrent
    userSlackId = try values.decode(String.self, forKey: .userSlackId)
    let endDateString = try values.decode(String.self, forKey: .endDate)
    self.endDate = DateFormatters.dateFormatter.date(from: endDateString).orCurrent
    self.type = try values.decode(String.self, forKey: .type)
    self.userName = try values.decode(String.self, forKey: .userName)
    let createdString = try? values.decode(String.self, forKey: .created)
    self.created = DateFormatters.withTDateFormatter.date(from: createdString.orEmpty)
    self.reviewer = try? values.decode(String.self, forKey: .reviewer)
    let reviewDateString = try? values.decode(String.self, forKey: .reviewDate)
    self.reviewDate = DateFormatters.withTDateFormatter.date(from: reviewDateString.orEmpty)
    self.editor = try? values.decode(String.self, forKey: .editor)
    let editDateString = try? values.decode(String.self, forKey: .editDate)
    self.editDate = DateFormatters.withTDateFormatter.date(from: editDateString.orEmpty)
    self.isCreatedByHr = try? values.decode(Bool.self, forKey: .isCreatedByHr)
  }
  
  init(startDate: String, userSlackId: String, endDate: String, type: String, userName: String, created: String?, reviewer: String?, reviewDate: String?, editor: String?, editDate: String?, isCreatedByHr: Bool?) {
    self.startDate = DateFormatters.dateFormatter.date(from: startDate).orCurrent
    self.userSlackId = userSlackId
    self.endDate = DateFormatters.dateFormatter.date(from: endDate).orCurrent
    self.type = type
    self.userName = userName
    self.created = DateFormatters.withTDateFormatter.date(from: created.orEmpty)
    self.reviewer = reviewer
    self.reviewDate = DateFormatters.withTDateFormatter.date(from: reviewDate.orEmpty)
    self.editor = editor
    self.editDate = DateFormatters.withTDateFormatter.date(from: editDate.orEmpty)
    self.isCreatedByHr = isCreatedByHr
  }
  
}
