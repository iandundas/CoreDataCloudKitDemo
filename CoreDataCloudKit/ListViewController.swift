//
//  ListViewController.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 29/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    // implicitly unwrapped optional here prevents need to initWithPersistenceController etc
    internal var persistenceController: MCPersistenceController!
    
    override func viewDidLoad() {
        assert(persistenceController != nil, "persistenceController should have been provided")
    }
}
