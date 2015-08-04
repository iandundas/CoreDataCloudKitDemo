//
//  Adapters.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 04/08/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreData

protocol AdapterProtocol{
    typealias T // Type of objects that are vended
    
    var objects: Array<T> {get}
    
    // These are taken from FRC but can apply generally
    // They don't currently indicate WHAT was changed, though.
    var willChangeContent: ((Array<T>) -> ())? {get set}
    var didChangeContent: (() -> ())? {get set}
}

public class ArrayAdapter : AdapterProtocol{
    
    // These are taken from FRC but can apply generally
    public var willChangeContent: ((Array<Item>) -> ())?
    public var didChangeContent: (() -> ())?
    
    public var objects: Array<Item>{
        willSet(newObjectsArray){
            self.willChangeContent?(newObjectsArray)
        }
        didSet{
            didChangeContent?()
        }
    }
    
    public convenience init(){
        self.init(initial:[])
    }
    public init(initial: Array<Item>){
        self.objects = initial
    }
}

//public class FRCAdapter : AdapterProtocol{
//    public typealias SectionDidChangeType = ((sectionInfo: NSFetchedResultsSectionInfo, sectionIndex: Int, type: NSFetchedResultsChangeType) -> ())?
//    public typealias ObjectDidChangeType = ((indexPath: NSIndexPath?, type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) -> ())?
//    
//    public var objects: Array<Item>?
//    
//    // These are taken from FRC but can apply generally
//    public var willChangeContent: ((Array<Item>) -> ())?
//    public var didChangeContent: (() -> ())?
//    
//    // These are specific to FRC and probably worth implementing if needed
////    public var didChangeSection: SectionDidChangeType
////    public var didChangeObject: ObjectDidChangeType // This is bad-  shouldn't be surfacing Model objects outside of the ViewModel
//    
//}
