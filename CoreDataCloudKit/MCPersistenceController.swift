//
//  MCPersistenceController.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 28/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

// This class is a Swift 1.2 port of http://martiancraft.com/blog/2015/03/core-data-stack/

import Foundation
import CoreData

public enum PersistenceType{
    case SQLLite
    case InMemory
}

public typealias PersistenceReadyType = () -> ()

public protocol PersistenceController{
    var managedContext: NSManagedObjectContext{get}
    func save()
}

public class MCPersistenceController : PersistenceController{
    
    // this is our Single Source Of Truth.
    // will be used by our User Interface (and therefore exposed outside of this controller.
    public let managedContext: NSManagedObjectContext // TODO rename mainContext
    
    // we specifically want this to be asynchronous from the UI.
    // the private queue context has one job in life. It writes to disk.
    // we want to avoid locking the UI as much as possible because of the persistence layer.
    private let privateContext: NSManagedObjectContext
    
    public init?(persistenceReady: PersistenceReadyType, persistenceType: PersistenceType = PersistenceType.SQLLite){
        managedContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        if let  modelURL = NSBundle.mainBundle().URLForResource("CoreDataCloudKit", withExtension: "momd"),
            mom = NSManagedObjectModel(contentsOfURL: modelURL)
        {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
            
            privateContext.persistentStoreCoordinator = coordinator
            
            managedContext.parentContext = privateContext
        }
        else{
            assertionFailure("Could not find/initialise Model file")
            return nil
        }
        
        initialisePersistentStore(persistenceReady, storeType: persistenceType)
    }
    
    public func save(){ // this should possibly have a success and failure block provided
        
        // TODO replace with guard statement when 2.0
        if privateContext.hasChanges || managedContext.hasChanges {
            
            managedContext.performBlockAndWait{
                var error: NSError?
                assert(self.managedContext.save(&error), "Failed to save on the Main Context with [error: \(error?.localizedDescription), userInfo: \(error?.userInfo)]")
                
                // perform on another queue, allowing method to return (privateContext shouldn't block thread)
                self.privateContext.performBlock{
                    var privateError: NSError?
                    assert(self.privateContext.save(&privateError), "Failed to save on the Background Context with [error: \(error?.localizedDescription), userInfo: \(error?.userInfo)]")
                }
            }
        }
    }
    
    /*
        TODO: use this Swiftier version of save:
    
    var error: NSError?
    let success: Bool = managedObjectContext.save(&error)
    // handle success or error
    
    // make it Swift-er
    func saveContext(context:) -> (success: Bool, error: NSError?)
    
    // Example
    let result = saveContext(context)
    if !result.success {
    println("Error: \(result.error)")
    }

    */
    
    private func initialisePersistentStore(persistenceReady: PersistenceReadyType, storeType: PersistenceType){
        
        let priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let psc = self.privateContext.persistentStoreCoordinator
            
            let options: Dictionary = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true,
                NSSQLitePragmasOption: ["journal_mode": "DELETE"]
            ]
            
            switch storeType{
            case .SQLLite:
                let fileManager = NSFileManager.defaultManager()
                let documentsURL = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
                let storeURL = documentsURL.URLByAppendingPathComponent("DataModel.sqlite")
                
                var error: NSError?
                var store = psc?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error)
                assert(store != nil, "Store should be not be nil")
                assert(error == nil, "Could not create persistent store: \(error)")
                
            case .InMemory:
                var error: NSError?
                var store = psc?.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: options, error: &error)
                assert(store != nil, "Store should be not be nil")
                assert(error == nil, "Could not create persistent store: \(error)")
            }
            
            
            dispatch_async(dispatch_get_main_queue(), persistenceReady)
        }
    }
    
}
