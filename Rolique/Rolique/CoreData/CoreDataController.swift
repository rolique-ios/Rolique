//
//  CoreDataController.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import CoreData

protocol CoreDataCompatible {
  associatedtype ManagedType: NSManagedObject
  
  init?(_ managedObject: ManagedType)
  func predicateById() -> NSPredicate
  @discardableResult
  func createOrUpdate(with context: NSManagedObjectContext?) -> ManagedType?
}

final class CoreDataController: NSObject {
  static let shared = CoreDataController()
  private override init() {}
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Rolique")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      debugPrint(storeDescription)
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    
    return container
  }()
  
  func mainContext() -> NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  func backgroundContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
    return context
  }
}

final class CoreDataManager<R: CoreDataCompatible> {
  func saveToCoreData(with context: NSManagedObjectContext? = nil) throws {
    let context = context ?? CoreDataController.shared.mainContext()
    guard context.hasChanges else { return }
    try context.save()
  }
  
  func save(with context: NSManagedObjectContext? = nil) {
    let context = context ?? CoreDataController.shared.mainContext()
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  func getManagedObjects(with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext? = nil) throws -> [R.ManagedType] {
    let context = context ?? CoreDataController.shared.mainContext()
    let request = NSFetchRequest<R.ManagedType>(entityName: String(describing: R.ManagedType.self))
    request.predicate = predicate
    request.sortDescriptors = sortDescriptors
    return try context.fetch(request)
  }
  
  func saveToCoreData(_ objects: [R], context: NSManagedObjectContext? = nil) {
    let context = context ?? CoreDataController.shared.mainContext()
    context.performAndWait {
      for object in objects {
        object.createOrUpdate(with: context)
      }
    }

    do {
      try self.saveToCoreData(with: context)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func clearCoreData(with predicate: NSPredicate? = nil, context: NSManagedObjectContext? = nil) {
    let context = context ?? CoreDataController.shared.backgroundContext()
    
    let request = R.ManagedType.fetchRequest()
    request.predicate = predicate
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
    
    do {
      try context.execute(deleteRequest)
    } catch {
      print(error.localizedDescription)
    }
  }
}

