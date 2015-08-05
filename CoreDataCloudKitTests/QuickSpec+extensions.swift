//
//  QuickSpec+extensions.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 04/08/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import Quick
import Nimble
import CoreData
import CoreDataCloudKit

extension QuickSpec{

    func saveAndCatch(moc: NSManagedObjectContext){
        var error: NSError? = nil;
        moc.save(&error)
        expect(error).to(beFalsy())
    }
    
    // convenience frc generator
    func quick_frc(predicate: NSPredicate, moc:NSManagedObjectContext) -> NSFetchedResultsController{
        let fetchRequest = Item.fetchRequest(
            context: moc,
            predicate: predicate,
            sortedBy: "created",
            ascending: false
        )
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return frc
    }
    
    
}
