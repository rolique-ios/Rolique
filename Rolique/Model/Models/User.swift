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
    case todayStatus = "today_status"
  }
  
  public var id: String
  public var slackProfile: SlackProfile
  public var birthday: String?
  public var dateOfJoining: String?
  public var eduPoints, emergencyDays: Double?
  public var roles: [String]
  public var vacationData: [String: Double]?
  public var todayStatus: String?
  
  var biggestImage: String? {
    return slackProfile.imageOriginal ?? slackProfile.image1024 ?? slackProfile.image512 ?? slackProfile.image192
  }
  
  var optimalImage: String? {
    return slackProfile.image192 ?? slackProfile.image512 ?? slackProfile.image1024 ?? slackProfile.imageOriginal
  }
  
  init(id: String, slackProfile: SlackProfile, birthday: String?, dateOfJoining: String?, eduPoints: Double, emergencyDays: Double?, roles: [String], vacationData: [String: Double]?, todayStatus: String?) {
    self.id = id
    self.slackProfile = slackProfile
    self.birthday = birthday
    self.dateOfJoining = dateOfJoining
    self.eduPoints = eduPoints
    self.emergencyDays = emergencyDays
    self.roles = roles
    self.vacationData = vacationData
    self.todayStatus = todayStatus
  }
  
  init?(_ managedObject: ManagedUser, context: NSManagedObjectContext? = nil) {
    guard let id = managedObject.id,
      let realName = managedObject.slackProfile?.realName,
      let slackProfile = SlackProfile.getFromCoreData(with: realName, context: context) else { return nil }
    
    self.id = id
    self.slackProfile = slackProfile
    self.birthday = managedObject.birthday
    self.dateOfJoining = managedObject.dateOfJoining
    self.eduPoints = managedObject.eduPoints
    self.emergencyDays = managedObject.emergencyDays
    self.roles = managedObject.roles ?? []
    self.vacationData = managedObject.vacationData
    let todayStatusDate = TodayStatusDate.getFromCoreData(with: Date().normalized, context: context)
    self.todayStatus = todayStatusDate?.todayStatuses[id]
  }
  
  static var mockedUser: User {
    return User(id: "", slackProfile: SlackProfile.mockedSlackProfile, birthday: nil, dateOfJoining: nil, eduPoints: 0, emergencyDays: nil, roles: [], vacationData: nil, todayStatus: nil)
  }
  
  func saveToCoreData(context: NSManagedObjectContext? = nil) {
    let context = context ?? CoreDataController.shared.mainContext()
    CoreDataManager<User>().saveToCoreData([self], context: context)
  }
  
  static func getFromCoreData(with id: String, context: NSManagedObjectContext? = nil) -> User? {
    guard let managedUser = try? CoreDataManager<User>().getManagedObjects(with: NSPredicate(format: "id == %@", id), context: context).first else { return nil }

    return User(managedUser)
  }
}

// MARK: - SlackProfile
public final class SlackProfile: Codable {
  public var avatarHash, displayName, displayNameNormalized, email: String?
  public var firstName: String?
  public var image192, image24, image32, image1024: String?
  public var image48, image512, image72: String?
  public var imageOriginal: String?
  public var isCustomImage: Bool?
  public var lastName: String?
  public var phone, realName, realNameNormalized: String
  public var skype, statusEmoji: String?
  public var statusExpiration: Int
  public var statusText, statusTextCanonical, team, title: String
  
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
  
  init?(_ managedObject: ManagedSlackProfile, context: NSManagedObjectContext? = nil) {
    guard let phone = managedObject.phone,
      let realName = managedObject.realName,
      let realNameNormalized = managedObject.realNameNormalized,
      let skype = managedObject.skype,
      let statusText = managedObject.statusText,
      let statusTextCanonical = managedObject.statusTextCanonical,
      let team = managedObject.team,
      let title = managedObject.title
      else { return nil }
    
    self.avatarHash = managedObject.avatarHash
    self.displayName = managedObject.displayName
    self.displayNameNormalized = managedObject.displayNameNormalized
    self.email = managedObject.email
    self.firstName = managedObject.firstName
    self.image1024 = managedObject.image1024
    self.image192 = managedObject.image192
    self.image24 = managedObject.image24
    self.image32 = managedObject.image32
    self.image48 = managedObject.image48
    self.image512 = managedObject.image512
    self.image72 = managedObject.image72
    self.imageOriginal = managedObject.imageOriginal
    self.isCustomImage = managedObject.isCustomImage
    self.lastName = managedObject.lastName
    self.phone = phone
    self.realName = realName
    self.realNameNormalized = realNameNormalized
    self.skype = skype
    self.statusEmoji = managedObject.statusEmoji
    self.statusExpiration = Int(managedObject.statusExpiration)
    self.statusText = statusText
    self.statusTextCanonical = statusTextCanonical
    self.team = team
    self.title = title
  }
  
  static var mockedSlackProfile: SlackProfile {
    return SlackProfile(avatarHash: "", displayName: "", displayNameNormalized: "", email: "", firstName: nil, image1024: nil, image192: "", image24: "", image32: "", image48: "", image512: "", image72: "", imageOriginal: nil, isCustomImage: nil, lastName: nil, phone: "", realName: "", realNameNormalized: "", skype: "", statusEmoji: "", statusExpiration: 0, statusText: "", statusTextCanonical: "", team: "", title: "")
  }
  
  func saveToCoreData(context: NSManagedObjectContext? = nil) {
    let context = context ?? CoreDataController.shared.mainContext()
    CoreDataManager<SlackProfile>().saveToCoreData([self], context: context)
  }
  
  static func getFromCoreData(with realName: String, context: NSManagedObjectContext? = nil) -> SlackProfile? {
    guard let managedSlackProfile = try? CoreDataManager<SlackProfile>().getManagedObjects(with: NSPredicate(format: "realName == %@", realName), context: context).first else { return nil }
    
    return SlackProfile(managedSlackProfile)
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

// MARK: - Managed

extension User: CoreDataCompatible {
  typealias ManagedType = ManagedUser
  
  func predicateById() -> NSPredicate {
    return NSPredicate(format: "id == %@", self.id)
  }
  
  @discardableResult
  func createOrUpdate(with context: NSManagedObjectContext?) -> ManagedUser? {
    let context = context ?? CoreDataController.shared.mainContext()
    
    guard let userEntityDescription = NSEntityDescription.entity(forEntityName: "ManagedUser", in: context),
      let slackProfile = self.slackProfile.createOrUpdate(with: context) else { return nil }
    
    let managedUser = (try? CoreDataManager<User>().getManagedObjects(with: self.predicateById(), context: context).first) ?? ManagedUser(entity: userEntityDescription, insertInto: context)
    managedUser.id = self.id
    managedUser.slackProfile = slackProfile
    managedUser.birthday = self.birthday
    managedUser.dateOfJoining = self.dateOfJoining
    managedUser.eduPoints = self.eduPoints ?? 0
    managedUser.emergencyDays = self.emergencyDays ?? 0
    managedUser.roles = self.roles
    managedUser.vacationData = self.vacationData
    
    return managedUser
  }
  
  static var compare: (ManagedUser, User) -> Bool { return { $0.id == $1.id } }
}

extension SlackProfile: CoreDataCompatible {
  typealias ManagedType = ManagedSlackProfile
  
  func predicateById() -> NSPredicate {
    return NSPredicate(format: "realName == %@", self.realName)
  }
  
  @discardableResult
  func createOrUpdate(with context: NSManagedObjectContext?) -> ManagedSlackProfile? {
    let context = context ?? CoreDataController.shared.mainContext()
    
    guard let slackProfileEntityRequest = NSEntityDescription.entity(forEntityName: "ManagedSlackProfile", in: context) else { return nil }
    
    let managedSlackProfile = (try? CoreDataManager<SlackProfile>().getManagedObjects(with: self.predicateById(), context: context).first) ?? ManagedSlackProfile(entity: slackProfileEntityRequest, insertInto: context)
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
  
  static var compare: (ManagedSlackProfile, SlackProfile) -> Bool { return { $0.realName == $1.realName } }
}
