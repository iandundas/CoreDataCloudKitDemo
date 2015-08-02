//
//  Item.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 29/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreData

public class Item: NSManagedObject {

    @NSManaged public var title: String
    @NSManaged public var created: NSDate
    
    
    public struct ItemConstants{
        public let Title = "hello world"
    }
    
    public class func defaults() -> ItemConstants{
        return ItemConstants()
    }
    
    public override func awakeFromInsert() {
        super.awakeFromNib()
        created = NSDate()
        title = Item.defaults().Title
    }
}


