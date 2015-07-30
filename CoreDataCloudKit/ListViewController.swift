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
        
        self.viewModel.willChangeContent = contentWillChange
        self.viewModel.didChangeContent = contentDidChange
        
        self.viewModel.didChangeSection = sectionDidChange
        self.viewModel.didChangeObject = objectDidChange
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
        return self.viewModel.numberOfSections
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
    
    // MARK Content did change callbacks:
    func contentWillChange(){
        self.tableView.beginUpdates()
    }
    func contentDidChange(){
        self.tableView.endUpdates()
    }
    
    func objectDidChange(indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?){
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func sectionDidChange(sectionInfo: NSFetchedResultsSectionInfo, sectionIndex: Int, type: NSFetchedResultsChangeType) -> () {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
}
