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

extension QuickSpec{

    func saveAndCatch(moc: NSManagedObjectContext){
        var error: NSError? = nil;
        moc.save(&error)
        expect(error).to(beFalsy())
    }
    
}
