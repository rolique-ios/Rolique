//
//  CoreDataManager.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
  static let shared = CoreDataManager()
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
  
  func saveContext() {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  func getManagedObject<T: NSManagedObject>(predicate: NSPredicate, context: NSManagedObjectContext? = nil) -> [T] {
    let context = context ?? CoreDataManager.shared.persistentContainer.viewContext
    let request = NSFetchRequest<T>(entityName: String(describing: T.self))
    request.predicate = predicate
    return (try? context.fetch(request)) ?? []
  }
  
  func saveToCoreData(context: NSManagedObjectContext? = nil) throws {
    let context = context ?? CoreDataManager.shared.persistentContainer.viewContext
    guard context.hasChanges else { return }
    try context.save()
  }
  
}

