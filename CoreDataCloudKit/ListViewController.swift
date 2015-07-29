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
    
    override func viewDidLoad() {

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "didTapInsertButton:")
        self.navigationItem.rightBarButtonItem = addButton
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
        return cell
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.configureCell(cell, atIndexPath: indexPath)
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let item = viewModel.itemForIndexPath(indexPath)

        // apparently you have to do it like this
        // ( see update here: http://quellish.tumblr.com/post/93190211147/secrets-of-nsfetchedresultscontroller-happiness )
        item.managedObjectContext?.performBlock{
            if let someCell = self.tableView.cellForRowAtIndexPath(indexPath) {
                someCell.textLabel!.text = item.title
            }
        }
    }

    // MARK Actions:
    func didTapInsertButton(sender: AnyObject){
        viewModel.addNewItem()
    }

}
