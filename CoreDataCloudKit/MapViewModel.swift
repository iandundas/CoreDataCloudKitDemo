//
//  MapViewModel.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 04/08/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreData

class MapViewModel<ItemType, SomeAdapter: AdapterProtocol where ItemType == SomeAdapter.ItemType>{
    let persistence: MCPersistenceController
    
    // The adapter provides us with a datasource of Items (soon to be Places)
    var adapter: SomeAdapter
    
    init(persistence: MCPersistenceController, newAdapter: SomeAdapter){
        self.persistence = persistence
        
        self.adapter = newAdapter
    }
}
