//
//  CoreDataManager.swift
//  Deliver
//
//  Created by Пользователь on 13.12.2018.
//  Copyright © 2018 SK_DevTeam. All rights reserved.
//

import Foundation
import CoreData

let CoreDataModelName: String = "Vezu"

enum CoreDataManagerParametersKeys: String {
    case entityName     = "entityName"
    case predicate      = "predicate"
    case sorts          = "sorts"
}

final class CoreData {
    
    static let shared: CoreData = CoreData(modelName: CoreDataModelName)
    
    // MARK: - Properties
    
    private let modelName: String
    
    // MARK: - Initialization
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // MARK: - Core Data Stack
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.privateManagedObjectContext
        return managedObjectContext
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            let options = [NSInferMappingModelAutomaticallyOption : true, NSMigratePersistentStoresAutomaticallyOption : true]
            
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: options)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if self.managedObjectContext.hasChanges {
            do {
                try self.managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func objects(_ objectName: String?, predicate: NSPredicate?, sorts: [Any]?, in context: NSManagedObjectContext?) -> [Any]? {
        
        let fetchedObjects = try? context?.fetch(fetchRequest(forObjectName: objectName, with: predicate, andSorts: sorts, in: context)!)
        
        if fetchedObjects == nil {
            return nil
        }
        
        return fetchedObjects!
    }
    
    private func fetchRequest(forObjectName objectName: String?, with predicate: NSPredicate?, andSorts sorts: [Any]?, in context: NSManagedObjectContext?) -> NSFetchRequest<NSFetchRequestResult>? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        var entity: NSEntityDescription? = nil
        if let aContext = context {
            entity = NSEntityDescription.entity(forEntityName: objectName ?? "", in: aContext)
        }
        fetchRequest.entity = entity
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        if sorts != nil && sorts?.count != nil {
            fetchRequest.sortDescriptors = sorts as? [NSSortDescriptor]
        }
        return fetchRequest
    }
    
    func saveChanges() {
        managedObjectContext.perform {
            do {
                if self.managedObjectContext.hasChanges {
                    try self.managedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
            
            self.privateManagedObjectContext.perform {
                do {
                    if self.privateManagedObjectContext.hasChanges {
                        try self.privateManagedObjectContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print("Unable to Save Changes of Private Managed Object Context")
                    print("\(saveError), \(saveError.localizedDescription)")
                }
            }
        }
    }
}

public extension NSManagedObject {
    
    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
    
}
