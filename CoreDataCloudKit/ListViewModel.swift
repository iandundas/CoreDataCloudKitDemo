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

    
    internal func addNewItem() -> Item{
        let entity = self.fetchedResultsController.fetchRequest.entity!
        
        let item = NSEntityDescription.insertNewObjectForEntityForName(
            entity.name!,
            inManagedObjectContext: self.persistenceController.managedContext
        ) as! Item
        
        item.created = NSDate()
        item.title = "New List Item"
        
        persistenceController.save()
        
        return item
    }
    
    // MARK Accessors:
    internal var numberOfRows: Int{
        get {
            let sectionInfo = self.fetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
    }
    
    internal func itemForIndexPath(indexPath: NSIndexPath) -> Item{
        return fetchedResultsController.objectAtIndexPath(indexPath) as! Item
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Item",
            inManagedObjectContext: self.persistenceController.managedContext
        )
        
        fetchRequest.fetchBatchSize = 20
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: false)
        ]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.persistenceController.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        
        var error: NSError? = nil
        frc.performFetch(&error)
        assert(error == nil, "Initial Fetch on Fetch Results Controller: \(error)")
        
        return frc
    }()
    
    
    // MARK FetchedResultsController Delegate Callbacks:
    @objc
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("Controller will change")
    }
    @objc
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        print("Controller did change section")
    }
    @objc
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        print("Controller did change object")
    }
    @objc
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("Controller did change content")
    }
    
    
}
