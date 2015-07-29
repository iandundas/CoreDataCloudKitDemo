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

class MCPersistenceController{
    
    typealias PersistenceReadyType = () -> ()
    
    // this is our Single Source Of Truth.
    // will be used by our User Interface (and therefore exposed outside of this controller.
    let managedObjectContext: NSManagedObjectContext // TODO rename mainContext
    
    // we specifically want this to be asynchronous from the UI.
    // the private queue context has one job in life. It writes to disk.
    // we want to avoid locking the UI as much as possible because of the persistence layer.
    private let privateContext: NSManagedObjectContext
    
    
    init?(persistenceReady: PersistenceReadyType) {
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        if let  modelURL = NSBundle.mainBundle().URLForResource("CoreDataCloudKit", withExtension: "momd"),
                mom = NSManagedObjectModel(contentsOfURL: modelURL)
        {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
            
            privateContext.persistentStoreCoordinator = coordinator
            
            managedObjectContext.parentContext = privateContext
        }
        else{
            assertionFailure("Could not find/initialise Model file")
            return nil
        }
        
        initialisePersistentStore(persistenceReady)
    }
    
    func initialisePersistentStore(persistenceReady: PersistenceReadyType){
        
        let priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let psc = self.privateContext.persistentStoreCoordinator
            
            let options: Dictionary = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true,
                NSSQLitePragmasOption: ["journal_mode": "DELETE"]
            ]
            
            let fileManager = NSFileManager.defaultManager()
            let documentsURL = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
            
            let storeURL = documentsURL.URLByAppendingPathComponent("DataModel.sqlite")
            
            var error: NSError?
            psc?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error)
            assert(error == nil, "Could not create persistent store: \(error)")

            dispatch_async(dispatch_get_main_queue(), persistenceReady)
        }
    }
    
    func save(){
        
        // TODO replace with guard statement when 2.0
        
        var privateHasChanges = privateContext.hasChanges
        var mainHasChanges = managedObjectContext.hasChanges
        
        if privateContext.hasChanges || managedObjectContext.hasChanges {
         
            managedObjectContext.performBlockAndWait{
                var error: NSError?
                assert(self.managedObjectContext.save(&error), "Failed to save on the Main Context with [error: \(error?.localizedDescription), userInfo: \(error?.userInfo)]")
                
                // perform on another queue, allowing method to return (privateContext shouldn't block thread)
                self.privateContext.performBlock{
                    var privateError: NSError?
                    assert(self.privateContext.save(&privateError), "Failed to save on the Background Context with [error: \(error?.localizedDescription), userInfo: \(error?.userInfo)]")
                }
            }
        }
    }
    
}
