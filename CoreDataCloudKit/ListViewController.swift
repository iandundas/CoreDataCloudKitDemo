//
//  ListViewController.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 29/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {

    let viewModel: ListViewModel
    
    init(viewModel: ListViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    required override init!(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
//        self.viewModel = ListViewModel() as! ListViewModel // is there a better way to do this?
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//    required init!(coder aDecoder: NSCoder!){
//        self.viewModel = ListViewModel(persistenceController: MCPersistenceController(persistenceReady: {})!)
//        super.init(coder: aDecoder)
//    }
    
    override func viewDidLoad() {

    }
    
    
    // MARK TableViewDataSource:
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let item = viewModel.itemForIndexPath(indexPath)
        cell.textLabel!.text = item.title
    }
    
}
