//
//  TodayStatus.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 10/31/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import UsersWidget
import CoreData

public final class TodayStatusDate {
  public var date: Date
  public var todayStatuses: [String: String]
  
  init(date: Date, todayStatuses: [String: String]) {
    self.date = date
    self.todayStatuses = todayStatuses
  }
  
  convenience init?(_ managedObject: ManagedTodayStatusDate, context: NSManagedObjectContext? = nil) {
    guard let date = managedObject.date,
      let statuses = managedObject.statuses else { return nil }
    
    var todayStatuses = [String: String]()
    for status in statuses {
      guard let status = status as? ManagedTodayStatus,
        let userId = status.userId,
        let todayStatus = TodayStatus.getFromCoreData(with: userId, context: context) else {
        continue
      }
      
      todayStatuses[userId] = todayStatus.status
    }
    
    self.init(date: date, todayStatuses: todayStatuses)
  }

  func saveToCoreData(context: NSManagedObjectContext? = nil) {
    let context = context ?? CoreDataController.shared.mainContext()
    CoreDataManager<TodayStatusDate>().saveToCoreData([self], context: context)
  }

  static func getFromCoreData(with date: Date, context: NSManagedObjectContext? = nil) -> TodayStatusDate? {
    guard let managedTodayStatusDate = try? CoreDataManager<TodayStatusDate>().getManagedObjects(with: NSPredicate(format: "date == %@", date as NSDate), context: context).first else { return nil }

    return TodayStatusDate(managedTodayStatusDate)
  }
}

public final class TodayStatus {
  public var status: String
  public var userId: String
  
  init(status: String, userId: String) {
    self.status = status
    self.userId = userId
  }
  
  convenience init?(_ managedObject: ManagedTodayStatus, context: NSManagedObjectContext? = nil) {
    guard let status = managedObject.status,
      let userId = managedObject.userId else { return nil }

    self.init(status: status, userId: userId)
  }

  func saveToCoreData(context: NSManagedObjectContext? = nil) {
    let context = context ?? CoreDataController.shared.mainContext()
    CoreDataManager<TodayStatus>().saveToCoreData([self], context: context)
  }

  static func getFromCoreData(with userId: String, context: NSManagedObjectContext? = nil) -> TodayStatus? {
    guard let managedTodayStatuses = try? CoreDataManager<TodayStatus>().getManagedObjects(with: NSPredicate(format: "userId == %@", userId), context: context).first else { return nil }

    return TodayStatus(managedTodayStatuses)
  }
}

// MARK: - Managed
extension TodayStatusDate: CoreDataCompatible {
  typealias ManagedType = ManagedTodayStatusDate
  
  func predicateById() -> NSPredicate {
    return NSPredicate(format: "date == %@", self.date as NSDate)
  }
  
  @discardableResult
  func createOrUpdate(with context: NSManagedObjectContext?) -> ManagedTodayStatusDate? {
    let context = context ?? CoreDataController.shared.mainContext()
    
    guard let userEntityDescription = NSEntityDescription.entity(forEntityName: "ManagedTodayStatusDate", in: context) else { return nil }
    
    let managedTodayStatusDate = (try? CoreDataManager<TodayStatusDate>().getManagedObjects(with: self.predicateById(), context: context).first) ?? ManagedTodayStatusDate(entity: userEntityDescription, insertInto: context)
    managedTodayStatusDate.date = self.date
    
    return managedTodayStatusDate
  }
  
  static var compare: (ManagedTodayStatusDate, TodayStatusDate) -> Bool { return { $0.date == $1.date } }
}


extension TodayStatus: CoreDataCompatible {
  typealias ManagedType = ManagedTodayStatus
  
  func predicateById() -> NSPredicate {
    return NSPredicate(format: "userId == %@", self.userId)
  }
  
  @discardableResult
  func createOrUpdate(with context: NSManagedObjectContext?) -> ManagedTodayStatus? {
    let context = context ?? CoreDataController.shared.mainContext()
    
    guard let userEntityDescription = NSEntityDescription.entity(forEntityName: "ManagedTodayStatus", in: context) else { return nil }
    
    let managedTodayStatus = (try? CoreDataManager<TodayStatus>().getManagedObjects(with: self.predicateById(), context: context).first) ?? ManagedTodayStatus(entity: userEntityDescription, insertInto: context)
    managedTodayStatus.status = self.status
    managedTodayStatus.userId = self.userId
    
    return managedTodayStatus
  }
  
  static var compare: (ManagedTodayStatus, TodayStatus) -> Bool { return { $0.userId == $1.userId } }
}
