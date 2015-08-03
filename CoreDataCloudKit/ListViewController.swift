//
//  ListViewController.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 29/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import UIKit
import CoreData
import ReactiveCocoa

class ListViewController: UITableViewController, UIGestureRecognizerDelegate {

    let viewModel: ListViewModel
    
    lazy var longPressRecogniser: UILongPressGestureRecognizer = {
        let recogniser = UILongPressGestureRecognizer(target: self, action: "didLongPressOnTableWithRecogniser:")
        recogniser.minimumPressDuration = 0.3
        recogniser.delegate = self
        return recogniser
    }()
    
    
    init(viewModel: ListViewModel){
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.willChangeContent = contentWillChange
        self.viewModel.didChangeContent = contentDidChange
        
        self.viewModel.didChangeSection = sectionDidChange
        self.viewModel.didChangeObject = objectDidChange
        
        
        var signal = self.viewModel.signal.observe(next: { update in
            println("update: \(update)")
        })
        
        
        self.tableView.registerNib(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        title = "💂🏻"
        
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.tableView.addGestureRecognizer(longPressRecogniser)
        
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "didTapDebugButton:")
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "didTapInsertButton:")
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    // Debugging
    func didTapDebugButton(sender: AnyObject?){
        
    }
    
    
    
    // MARK TableView:
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
        if let cell = cell as? TextFieldCell{
            cell.viewModel = viewModel.cellViewModelForIndexPath(indexPath)
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.viewModel.deleteItemWithIndexPath(indexPath)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.endEditing(true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK Actions:
    func didTapInsertButton(sender: AnyObject){
        viewModel.addNewItem()
    }

    func didLongPressOnTableWithRecogniser(gestureRecogniser: UILongPressGestureRecognizer){
        if (gestureRecogniser.state == UIGestureRecognizerState.Began){
            let point = gestureRecogniser.locationInView(self.tableView)
            if let indexPath = self.tableView.indexPathForRowAtPoint(point){
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! TextFieldCell
                cell.becomeFirstResponder()
            }
        }
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
