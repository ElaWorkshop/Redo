//
//  RedoListVC.swift
//  Redo
//
//  Created by AquarHEAD L. on 19/09/2015.
//  Copyright © 2015 ElaWorkshop. All rights reserved.
//

import UIKit
import CoreData
import MagicalRecord

class RedoListVC: UITableViewController, NSFetchedResultsControllerDelegate {

    var redolists: [String] = ["Take a shower", "rMBP 15'", "MagSafe 2", "iPad Mini", "iPhone", "band-it, cards and keys", "Nikon Df w/ Eye-Fi", "PowerBlade", "Df Batteries", "Lightning Cable", "Pen & Paper", "Misfit Shine", "Ring", "Earpods" ]

    lazy var redoListFRC : NSFetchedResultsController = {
        let request = NSFetchRequest()
        request.entity = RedoList.MR_entityDescription()
        let lastFinishedSort = NSSortDescriptor(key: "lastFinished", ascending: true)
        request.sortDescriptors = [lastFinishedSort]
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc;
    }()

    var selectedRedoList: RedoList?

    override func viewDidLoad() {
        super.viewDidLoad()

        try! self.redoListFRC.performFetch()
    }

    // MARK: - Button actions

    @IBAction func addRedoList(sender: AnyObject) {
        let newListPopup = UIAlertController(title: "New List", message: "", preferredStyle: .Alert)
        newListPopup.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Redo List Name"
        }
        let okAction = UIAlertAction(title: "Save", style: .Default) { (action) -> Void in
            MagicalRecord.saveWithBlockAndWait({ (context) -> Void in
                let newList = RedoList.MR_createEntityInContext(context)
                newList.name = newListPopup.textFields![0].text
            })
        }
        newListPopup.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        newListPopup.addAction(cancelAction)
        self.presentViewController(newListPopup, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.redoListFRC.sections?.count)!
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.redoListFRC.sections![section]
        return sectionInfo.numberOfObjects
    }

    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let redoList = self.redoListFRC.objectAtIndexPath(indexPath) as! RedoList
        cell.textLabel?.text = redoList.name
        if ((redoList.lastFinished) != nil) {
            cell.detailTextLabel?.text = "Last: \(redoList.lastFinished!.description)"
        }
        else {
            cell.detailTextLabel?.text = "Fresh..."
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RedoListCell", forIndexPath: indexPath)
        self.configureCell(cell, indexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRedoList = self.redoListFRC.objectAtIndexPath(indexPath) as? RedoList
        performSegueWithIdentifier("openRedoList", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Fetched results controller

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Update:
            self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        //
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "openRedoList") {
            let destVC = segue.destinationViewController as! RedoVC
            destVC.title = self.selectedRedoList!.name
            destVC.redoList = self.selectedRedoList
        }
    }

}

