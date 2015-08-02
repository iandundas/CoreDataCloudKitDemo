//
//  MCPersistenceMock.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 01/08/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreData
import CoreDataCloudKit

// Simplified version of our MCPersistenceController which can 
// be used for tests (in-memory DB)

class MCPersistenceFakeController : PersistenceController{
    
    // this is our Single Source Of Truth.
    // will be used by our User Interface (and therefore exposed outside of this controller.
    internal let managedContext: NSManagedObjectContext // TODO rename mainContext
    
    init(){
        managedContext = setUpInMemoryManagedObjectContext()
    }
    
    func save(){ // this should possibly have a success and failure block provided
        if managedContext.hasChanges {
            managedContext.performBlockAndWait{
                var error: NSError?
                assert(self.managedContext.save(&error), "Failed to save on the Main Context with [error: \(error?.localizedDescription), userInfo: \(error?.userInfo)]")
            }
        }
    }
}

// Taken from https://www.andrewcbancroft.com/2015/01/13/unit-testing-model-layer-core-data-swift/
func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
    let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
    
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
}

