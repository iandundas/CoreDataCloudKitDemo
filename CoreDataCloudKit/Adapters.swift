//
//  Adapters.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 04/08/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreData

//TODO - think of a better name
protocol AdapterProtocol{
    typealias ItemType // Type of objects that are vended
    
    var objects: Array<ItemType> {get}
    
    // These are taken from FRC but can apply generally
    // They don't currently indicate WHAT was changed, though.
    var willChangeContent: (() -> ())? {get set}
    var didChangeContent: ((Array<ItemType>) -> ())? {get set}
}

/*  
Array version of "Adapter" protocol
    
Designed so that you can pass an arbitrary set of (Item, for now) objects 
into a ViewModel. 

The companion class is the FRCAdapter, which has the same interface, but which
automates the fetching and updating of object sets.
*/

public class ArrayAdapter : AdapterProtocol{
    
    // These are taken from FRC but can apply generally
    public var willChangeContent: (() -> ())?
    public var didChangeContent: ((Array<Item>) -> ())?
    
    public var objects: Array<Item>{
        willSet(newObjectsArray){
            self.willChangeContent?()
        }
        didSet{
            didChangeContent?(objects)
        }
    }
    
    public convenience init(){
        self.init(initial:[])
    }
    public init(initial: Array<Item>){
        self.objects = initial
    }
}

/* 
FetchedResultsController version of the AdapterProtocol

- You pass this into a ViewModel and it will be used as the datasource therein.
- You can inject in a differently-configured FetchedResultsController and this 
will obviously change the objectSet, which will be communicated to the ViewModel.

*/
public class FRCAdapter : AdapterProtocol, NSFetchedResultsControllerDelegate {
    public typealias SectionDidChangeType = ((sectionInfo: NSFetchedResultsSectionInfo, sectionIndex: Int, type: NSFetchedResultsChangeType) -> ())?
    public typealias ObjectDidChangeType = ((indexPath: NSIndexPath?, type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) -> ())?
    
    public var objects: Array<Item> {
        get{
            if let result = self.fetchedResultsController.fetchedObjects as? [Item]{
                return result
            }
            return []
        }
    }
    
    // These are taken from FRC but can apply generally
    public var willChangeContent: (() -> ())?
    public var didChangeContent: ((Array<Item>) -> ())?
    
    // FIXME: quite dodgy here - I don't really want to perform the initial fetch on the FRC before it's even been set 
    // we're doing it so that we can calculate the difference between old and new FRC fetchedObjects
    public var fetchedResultsController: NSFetchedResultsController{
        willSet(newFetchedResultsController){
            self.dynamicType.performInitialFetch(newFetchedResultsController)
            
            let hasChanges = hasChangesBetween(fetchedResultsController, newFetchedResultsController: newFetchedResultsController)
            if hasChanges{
                willChangeContent?()
            }
        }
        didSet(oldFetchedResultsController){
            fetchedResultsController.delegate = self
            
            let hasChanges = hasChangesBetween(oldFetchedResultsController, newFetchedResultsController: fetchedResultsController)
            if hasChanges{
                didChangeContent?(fetchedResultsController.fetchedObjects as! [Item])
            }
        }
    }
    
    public init(fetchedResultsController: NSFetchedResultsController){
        
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsController.delegate = self
        
        self.dynamicType.performInitialFetch(fetchedResultsController)
    }

    
    // TODO: add error handling here
    private class func performInitialFetch(frc: NSFetchedResultsController){
        
        var error: NSError? = nil
        frc.performFetch(&error)
        assert(error == nil, "ERROR on initial fetch on Fetch Results Controller: \(error)")
    }
    
    // MARK FetchedResultsController Delegate Callbacks:
    @objc
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        willChangeContent?()
    }
    @objc
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        didChangeContent?(controller.fetchedObjects as! [Item])
    }
    
    // These are specific to FRC and probably worth implementing if needed
    //    public var didChangeSection: SectionDidChangeType
    //    public var didChangeObject: ObjectDidChangeType // This is bad-  shouldn't be surfacing Model objects outside of the ViewModel

//    @objc
//    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        didChangeSection?(sectionInfo: sectionInfo, sectionIndex: sectionIndex, type: type)
//    }
//    @objc
//    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        didChangeObject?(indexPath: indexPath, type: type, newIndexPath: newIndexPath)
//    }
    
    /* FIXME not a pretty function - rewrite when I know some optionals syntax sugar */
    private func hasChangesBetween(oldFetchedResultsController:NSFetchedResultsController, newFetchedResultsController:NSFetchedResultsController) -> Bool{
        
        let old = oldFetchedResultsController.fetchedObjects as? [Item]
        let new = newFetchedResultsController.fetchedObjects as? [Item]
        
        if let oldObjects = old, newObjects = new{
            
            let oldSet = Set(oldObjects)
            let newSet = Set(newObjects)
            
            let union = newSet.union(oldSet)
            
            // if same size and union doesn't increase total size, presumably the array is the same
            return !((union.count == oldSet.count) && (oldSet.count == newSet.count))
        }
        else{
            if (old != nil) && (new == nil){ // new failed, so there's a difference
                return true
            }
            else if (old == nil) && (new != nil){ // old failed, so there's a difference
                return true
            }
        }
        
        return false
    }
    
}
