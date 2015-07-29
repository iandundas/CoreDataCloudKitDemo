//
//  ListViewModel.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 29/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreData

class ListViewModel: NSFetchedResultsControllerDelegate{
    
    internal var persistenceController: MCPersistenceController
    
    init(persistenceController: MCPersistenceController){
        self.persistenceController = persistenceController
    }
    
    internal var numberOfRows: Int{
        get {
            let sectionInfo = self.fetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
    }
    
    internal func itemForIndexPath(indexPath: NSIndexPath) -> Item{
        return fetchedResultsController.objectAtIndexPath(indexPath) as! Item
    }
    
    // doesn't really need to be lazy, just trying out the syntax:
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Item",
            inManagedObjectContext: self.persistenceController.managedObjectContext
        )
        
        fetchRequest.fetchBatchSize = 20
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.persistenceController.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        
        var error: NSError? = nil
        frc.performFetch(&error)
        assert(error == nil, "Initial Fetch on Fetch Results Controller: \(error)")
        
        return frc
    }()
    
}
