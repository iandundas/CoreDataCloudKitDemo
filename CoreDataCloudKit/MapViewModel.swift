//
//  MapViewModel.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 04/08/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import CoreData
import ReactiveCocoa

//class MapViewModel<SomeAdapter: AdapterProtocol where Item == SomeAdapter.ItemType>{
public class MapViewModel{
    let persistence: PersistenceController
    
    // The adapter provides us with a datasource of Items (soon to be Places)
    public var adapter: AdapterProtocol{
        didSet{
            adapter.willChangeContent = willChangeAdapterContent
            adapter.didChangeContent = didChangeAdapterContent
            items.put(adapter.objects)
        }
    }
    
    // At this point we switch from Adapter land to RAC land
    public let items = MutableProperty<[Item]>([Item]())
    
    public let viewableArea = MutableProperty<String>("initial")
    
    // FIXME: use generics properly, instead of hard coding everything to Item. Doesn't matter for now.. 
    // init(persistence: MCPersistenceController, newAdapter: SomeAdapter){
    public init(persistence: PersistenceController, newAdapter: AdapterProtocol){
        self.persistence = persistence
        self.adapter = newAdapter
        
        adapter.willChangeContent = willChangeAdapterContent
        adapter.didChangeContent = didChangeAdapterContent
        items.put(adapter.objects)
        
        viewableArea <~ items.producer |> map {items in items.count > 0 ? items[0].title : "None"}
        
        
        viewableArea.producer.start(next:{ value in
            println("New Value: \(value)")
        })
        
    }
    
    func willChangeAdapterContent(){}
    func didChangeAdapterContent(newObjects: [Item]){
        items.put(newObjects)
    }
    
    
    
}
