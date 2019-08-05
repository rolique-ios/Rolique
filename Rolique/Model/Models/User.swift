//
//  User.swift
//  Model
//
//  Created by Andrii on 8/1/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

public final class User: Codable {
  
  enum CodingKeys: String, CodingKey, CaseIterable {
    case id
    case slackProfile = "slack_profile"
    case birthday
    case dateOfJoining = "date_of_joining"
    case eduPoints = "edu_points"
    case emergencyDays = "emergency_days"
    case roles
    case vacationData = "vacation_data"
  }
  
  public let id: String
  public let slackProfile: SlackProfile
  public let birthday, dateOfJoining: String
  public let eduPoints, emergencyDays: Int
  public let roles: [String]
  public let vacationData: [String: Double]
  
  init(id: String, slackProfile: SlackProfile, birthday: String, dateOfJoining: String, eduPoints: Int, emergencyDays: Int, roles: [String], vacationData: [String: Double]) {
    self.id = id
    self.slackProfile = slackProfile
    self.birthday = birthday
    self.dateOfJoining = dateOfJoining
    self.eduPoints = eduPoints
    self.emergencyDays = emergencyDays
    self.roles = roles
    self.vacationData = vacationData
  }

}

// MARK: - SlackProfile
public final class SlackProfile: Codable {
  public let avatarHash, displayName, displayNameNormalized, email: String
  public let firstName: String
  public let image1024, image192, image24, image32: String
  public let image48, image512, image72, imageOriginal: String
  public let isCustomImage: Bool
  public let lastName, phone, realName, realNameNormalized: String
  public let skype, statusEmoji: String
  public  let statusExpiration: Int
  public let statusText, statusTextCanonical, team, title: String
  
  enum CodingKeys: String, CodingKey {
    case avatarHash = "avatar_hash"
    case displayName = "display_name"
    case displayNameNormalized = "display_name_normalized"
    case email
    case firstName = "first_name"
    case image1024 = "image_1024"
    case image192 = "image_192"
    case image24 = "image_24"
    case image32 = "image_32"
    case image48 = "image_48"
    case image512 = "image_512"
    case image72 = "image_72"
    case imageOriginal = "image_original"
    case isCustomImage = "is_custom_image"
    case lastName = "last_name"
    case phone
    case realName = "real_name"
    case realNameNormalized = "real_name_normalized"
    case skype
    case statusEmoji = "status_emoji"
    case statusExpiration = "status_expiration"
    case statusText = "status_text"
    case statusTextCanonical = "status_text_canonical"
    case team, title
  }
  
  init(avatarHash: String, displayName: String, displayNameNormalized: String, email: String, firstName: String, image1024: String, image192: String, image24: String, image32: String, image48: String, image512: String, image72: String, imageOriginal: String, isCustomImage: Bool, lastName: String, phone: String, realName: String, realNameNormalized: String, skype: String, statusEmoji: String, statusExpiration: Int, statusText: String, statusTextCanonical: String, team: String, title: String) {
    self.avatarHash = avatarHash
    self.displayName = displayName
    self.displayNameNormalized = displayNameNormalized
    self.email = email
    self.firstName = firstName
    self.image1024 = image1024
    self.image192 = image192
    self.image24 = image24
    self.image32 = image32
    self.image48 = image48
    self.image512 = image512
    self.image72 = image72
    self.imageOriginal = imageOriginal
    self.isCustomImage = isCustomImage
    self.lastName = lastName
    self.phone = phone
    self.realName = realName
    self.realNameNormalized = realNameNormalized
    self.skype = skype
    self.statusEmoji = statusEmoji
    self.statusExpiration = statusExpiration
    self.statusText = statusText
    self.statusTextCanonical = statusTextCanonical
    self.team = team
    self.title = title
  }
}
