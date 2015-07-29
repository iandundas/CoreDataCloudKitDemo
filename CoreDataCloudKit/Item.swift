//
//  Item.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 29/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreData

class Item: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var created: NSDate

}
