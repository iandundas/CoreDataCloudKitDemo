//
//  ManagedObject+extensions.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 02/08/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreData

// Swift 2.0: use protocols with default implementations here instead (don't want to subclass if we can avoid it)
// Accessor Additions:
extension NSManagedObject{
    
    public class var entityName: String {
        let fullClassName = NSStringFromClass(self)
        let nameComponents = split(fullClassName) { $0 == "." }
        return last(nameComponents)!
    }
}


// Queries:
extension NSManagedObject{
    public class func countWithContext(context: NSManagedObjectContext, predicate: NSPredicate?=nil)->Int{
        
        let request = fetchRequest(context: context, predicate: predicate)
        let error: NSErrorPointer = nil;
        let count = context.countForFetchRequest(request, error: error)
        if error != nil { // Swift 2.0: replace with guard
            NSLog("Error retrieving data %@, %@", error, error.debugDescription)
            return 0;
        }
        
        return count;
    }
    
    
    // FIXME Swift 2.0: should use throws here, rather than burying the error
    // FIXME Swift 2.0: returning AnyObject, see http://martiancraft.com/blog/2015/07/objective-c-swift-core-data/ for a better way
    public class func objectsInContext(context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortedBy: String? = nil, ascending: Bool = false) -> [AnyObject] {
        
        let error: NSErrorPointer = nil;
        
        let request = fetchRequest(context: context, predicate: predicate, sortedBy: sortedBy, ascending: ascending)
        let fetchResults = context.executeFetchRequest(request, error: error)
        
        if error != nil { // Swift 2.0: replace with guard
            NSLog("Error retrieving data %@, %@", error, error.debugDescription)
            return [];
        }
        
        if let r = fetchResults{
            return r
        }
        return []
    }
    
    public class func singleObjectInContext(context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortedBy: String? = nil, ascending: Bool = false) -> AnyObject? {
        let managedObjects = objectsInContext(context, predicate: predicate, sortedBy: sortedBy, ascending: ascending)
        if managedObjects.count == 0 { return nil }
        return managedObjects.first
    }
    
    // https://gist.github.com/capttaco/adb38e0d37fbaf9c004e
    public class func fetchRequest(#context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortedBy: String? = nil, ascending: Bool = false) -> NSFetchRequest
    {
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: context)
        request.entity = entity
        
        if predicate != nil {
            request.predicate = predicate
        }
        
        if let sortedBy = sortedBy {
            let sort = NSSortDescriptor(key: sortedBy, ascending: ascending)
            let sortDescriptors = [sort]
            request.sortDescriptors = sortDescriptors
        }
        
        return request
    }
}
