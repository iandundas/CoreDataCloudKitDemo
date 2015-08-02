//
//  ManagedObjectContext+extensions.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 02/08/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreData


extension NSManagedObjectContext {
    // 👍🏻 http://commandshift.co.uk/blog/2015/05/11/swift-generics/
    public func insert<T : NSManagedObject>(entity: T.Type) -> T{
        let entityName = entity.entityName
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self) as! T
    }
}
