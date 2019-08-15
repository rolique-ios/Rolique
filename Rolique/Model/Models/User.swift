//
//  User.swift
//  Model
//
//  Created by Andrii on 8/1/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation
import UsersWidget
import CoreData

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
  public let birthday: String?
  public let dateOfJoining: String?
  public let eduPoints, emergencyDays: Double?
  public let roles: [String]
  public let vacationData: [String: Double]?
  
  init(id: String, slackProfile: SlackProfile, birthday: String?, dateOfJoining: String?, eduPoints: Double, emergencyDays: Double?, roles: [String], vacationData: [String: Double]?) {
    self.id = id
    self.slackProfile = slackProfile
    self.birthday = birthday
    self.dateOfJoining = dateOfJoining
    self.eduPoints = eduPoints
    self.emergencyDays = emergencyDays
    self.roles = roles
    self.vacationData = vacationData
  }
  
  func saveToCoreData(context: NSManagedObjectContext? = nil) {
    let context = context ?? CoreDataManager.shared.persistentContainer.viewContext
    createOrUpdate(with: context)
    try? CoreDataManager.shared.saveToCoreData(context: context)
  }
  
  @discardableResult
  func createOrUpdate(with context: NSManagedObjectContext? = nil) -> ManagedUser? {
    let context = context ?? CoreDataManager.shared.persistentContainer.viewContext
    
    guard let userEntityDescription = NSEntityDescription.entity(forEntityName: "ManagedUser", in: context) else { return nil }
    
    let managedUser = CoreDataManager.shared.getManagedObject(predicate: NSPredicate(format: "id == %@", self.id), context: context).first ?? ManagedUser(entity: userEntityDescription, insertInto: context)
    managedUser.id = self.id
    managedUser.slackProfile = self.slackProfile.createOrUpdate(with: context)
    managedUser.birthday = self.birthday
    managedUser.dateOfJoining = self.dateOfJoining
    managedUser.eduPoints = self.eduPoints ?? 0
    managedUser.emergencyDays = self.emergencyDays ?? 0
    managedUser.roles = self.roles
    managedUser.vacationData = self.vacationData
    
    return managedUser
  }
  
  static func getFromCoreData(with id: String, context: NSManagedObjectContext? = nil) -> User? {
    let context = context ?? CoreDataManager.shared.persistentContainer.viewContext

    guard let managedUser: ManagedUser = CoreDataManager.shared.getManagedObject(predicate: NSPredicate(format: "id == %@", id), context: context).first,
      let realName = managedUser.slackProfile?.realName,
      let slackProfile = SlackProfile.getFromCoreData(with: realName, context: context)
      else { return nil }

    let user = User(id: id,
                    slackProfile: slackProfile,
                    birthday: managedUser.birthday,
                    dateOfJoining: managedUser.dateOfJoining,
                    eduPoints: managedUser.eduPoints,
                    emergencyDays: managedUser.emergencyDays,
                    roles: managedUser.roles ?? [],
                    vacationData: managedUser.vacationData)

    return user
  }
}

// MARK: - SlackProfile
public final class SlackProfile: Codable {
  public let avatarHash, displayName, displayNameNormalized, email: String?
  public let firstName: String?
  public let image192, image24, image32, image1024: String?
  public let image48, image512, image72: String?
  public let imageOriginal: String?
  public let isCustomImage: Bool?
  public let lastName: String?
  public let phone, realName, realNameNormalized: String
  public let skype, statusEmoji: String?
  public let statusExpiration: Int
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
  
  init(avatarHash: String, displayName: String, displayNameNormalized: String, email: String,
       firstName: String?,
       image1024: String?,
       image192: String, image24: String, image32: String, image48: String, image512: String,
       image72: String,
       imageOriginal: String?,
       isCustomImage: Bool?,
       lastName: String?,
       phone: String, realName: String, realNameNormalized: String, skype: String, statusEmoji: String, statusExpiration: Int, statusText: String, statusTextCanonical: String, team: String, title: String) {
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
  
  func saveToCoreData(context: NSManagedObjectContext? = nil) {
    let context = context ?? CoreDataManager.shared.persistentContainer.viewContext
    createOrUpdate(with: context)
    try? CoreDataManager.shared.saveToCoreData(context: context)
  }
  
  @discardableResult
  func createOrUpdate(with context: NSManagedObjectContext? = nil) -> ManagedSlackProfile? {
    let context = context ?? CoreDataManager.shared.persistentContainer.viewContext
    
    guard let slackProfileEntityRequest = NSEntityDescription.entity(forEntityName: "ManagedSlackProfile", in: context) else { return nil }
    
    let managedSlackProfile = CoreDataManager.shared.getManagedObject(predicate: NSPredicate(format: "realName == %@", self.realName),
                                                                      context: context).first ?? ManagedSlackProfile(entity: slackProfileEntityRequest, insertInto: context)
    managedSlackProfile.avatarHash = self.avatarHash
    managedSlackProfile.displayName = self.displayName
    managedSlackProfile.displayNameNormalized = self.displayNameNormalized
    managedSlackProfile.email = self.email
    managedSlackProfile.firstName = self.firstName
    managedSlackProfile.image24 = self.image24
    managedSlackProfile.image32 = self.image32
    managedSlackProfile.image48 = self.image48
    managedSlackProfile.image72 = self.image72
    managedSlackProfile.image192 = self.image192
    managedSlackProfile.image512 = self.image512
    managedSlackProfile.image1024 = self.image1024
    managedSlackProfile.imageOriginal = self.imageOriginal
    managedSlackProfile.isCustomImage = self.isCustomImage ?? false
    managedSlackProfile.lastName = self.lastName
    managedSlackProfile.phone = self.phone
    managedSlackProfile.realName = self.realName
    managedSlackProfile.realNameNormalized = self.realNameNormalized
    managedSlackProfile.skype = self.skype
    managedSlackProfile.statusEmoji = self.statusEmoji
    managedSlackProfile.statusExpiration = Int64(self.statusExpiration)
    managedSlackProfile.statusText = self.statusText
    managedSlackProfile.statusTextCanonical = self.statusTextCanonical
    managedSlackProfile.team = self.team
    managedSlackProfile.title = self.title
    
    return managedSlackProfile
  }
  
  static func getFromCoreData(with realName: String, context: NSManagedObjectContext? = nil) -> SlackProfile? {
    let context = context ?? CoreDataManager.shared.persistentContainer.viewContext

    guard let managedSlackProfile: ManagedSlackProfile = CoreDataManager.shared.getManagedObject(predicate: NSPredicate(format: "realName == %@", realName), context: context).first,
      let avatarHash = managedSlackProfile.avatarHash,
      let displayName = managedSlackProfile.displayName,
      let displayNameNormalized = managedSlackProfile.displayNameNormalized,
      let email = managedSlackProfile.email,
      let image192 = managedSlackProfile.image192,
      let image24 = managedSlackProfile.image24,
      let image32 = managedSlackProfile.image32,
      let image48 = managedSlackProfile.image48,
      let image512 = managedSlackProfile.image512,
      let image72 = managedSlackProfile.image72,
      let phone = managedSlackProfile.phone,
      let realNameNormalized = managedSlackProfile.realNameNormalized,
      let skype = managedSlackProfile.skype,
      let statusEmoji = managedSlackProfile.statusEmoji,
      let statusText = managedSlackProfile.statusText,
      let statusTextCanonical = managedSlackProfile.statusTextCanonical,
      let team = managedSlackProfile.team,
      let title = managedSlackProfile.title
      else { return nil }
    
    let slackProfile = SlackProfile(avatarHash: avatarHash,
                                    displayName: displayName,
                                    displayNameNormalized: displayNameNormalized,
                                    email: email,
                                    firstName: managedSlackProfile.firstName,
                                    image1024: managedSlackProfile.image1024,
                                    image192: image192,
                                    image24: image24,
                                    image32: image32,
                                    image48: image48,
                                    image512: image512,
                                    image72: image72,
                                    imageOriginal: managedSlackProfile.imageOriginal,
                                    isCustomImage: managedSlackProfile.isCustomImage,
                                    lastName: managedSlackProfile.lastName,
                                    phone: phone,
                                    realName: realName,
                                    realNameNormalized: realNameNormalized,
                                    skype: skype,
                                    statusEmoji: statusEmoji,
                                    statusExpiration: Int(managedSlackProfile.statusExpiration),
                                    statusText: statusText,
                                    statusTextCanonical: statusTextCanonical,
                                    team: team,
                                    title: title)

    return slackProfile
  }
}

extension User: Equatable {
  static public func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
  }
}

extension User: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
}


// MARK: - Userable
extension User: Userable {
  public var name: String {
    return self.slackProfile.realName
  }
  
  public var thumbnailURL: URL? {
    return URL(string: (self.slackProfile.image48 ?? self.slackProfile.image32 ?? ""))
  }
}
