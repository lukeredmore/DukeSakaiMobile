//
//  LogDataController.swift
//  DukeSakai
//
//  Created by Luke Redmore on 10/21/22.
//

import Foundation
import CoreData

class LogDataController: ObservableObject {
    let container = NSPersistentContainer(name: "Model", managedObjectModel: CoreDataManager.shared.coreDataStack.storeContainer.managedObjectModel)
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}

class CoreDataManager {

    static let shared = CoreDataManager()
    private init() {}
    lazy var coreDataStack = CoreDataStack(modelName: "Model")
    
    func clearLogs() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LogEntry")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try coreDataStack.storeContainer.persistentStoreCoordinator.execute(deleteRequest, with: coreDataStack.managedContext)
        } catch let error as NSError {
            print("Could not delete all: \(error.localizedDescription)")
        }

    }
    
    func appendToLog(source: String, msg: String) {
        let entry = LogEntry(context: coreDataStack.managedContext)
        entry.date = Date()
        entry.source = source
        entry.msg = msg
        
        do {
            try coreDataStack.managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

class CoreDataStack {
    
    private let modelName: String
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else {return}
        do{
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func updateContext() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func clearChange() {
        managedContext.rollback()
    }
    
}
