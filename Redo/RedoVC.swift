//
//  RedoVC.swift
//  Redo
//
//  Created by AquarHEAD L. on 19/09/2015.
//  Copyright © 2015 ElaWorkshop. All rights reserved.
//

import UIKit
import CoreData
import MagicalRecord

class RedoVC: UITableViewController, NSFetchedResultsControllerDelegate {

    var redoList: RedoList?

    lazy var redosFRC: NSFetchedResultsController = {
        // Fetch Redo
        let request = NSFetchRequest()
        request.entity = Redo.MR_entityDescription()

        // Of self.redoList
        let predicate = NSPredicate(format: "list == %@", self.redoList!)
        request.predicate = predicate

        // Section by finished, sort by order
        let finishedSort = NSSortDescriptor(key: "finished", ascending: true)
        let orderSort = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [finishedSort, orderSort]
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: "finished", cacheName: nil)

        // Final touch
        frc.delegate = self
        return frc;
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        try! self.redosFRC.performFetch()
    }

    @IBAction func addRedo(sender: AnyObject) {

        let newRedoPopup = UIAlertController(title: "Add Redo", message: "", preferredStyle: .Alert)
        newRedoPopup.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Redo Detail..."
        }
        let okAction = UIAlertAction(title: "Save", style: .Default) { (action) -> Void in
            let context = NSManagedObjectContext.MR_defaultContext()
            let newRedo = Redo.MR_createEntityInContext(context)
            newRedo.detail = newRedoPopup.textFields![0].text
            newRedo.list = self.redoList
            let predicate = NSPredicate(format: "list == %@", self.redoList!)
            let maxOrder = Redo.MR_aggregateOperation("max:", onAttribute: "order", withPredicate: predicate) as! NSNumber
            newRedo.order = NSNumber(integer: maxOrder.integerValue + 1)
            context.MR_saveToPersistentStoreAndWait()
        }
        newRedoPopup.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        newRedoPopup.addAction(cancelAction)
        self.presentViewController(newRedoPopup, animated: true, completion: nil)
    }
    
    // MARK: - Table view related

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (redosFRC.sections?.count)!
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Todo"
        }
        else {
            return "Done"
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.redosFRC.sections![section]
        return sectionInfo.numberOfObjects
    }

    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let thisRedo = self.redosFRC.objectAtIndexPath(indexPath) as! Redo
        if (thisRedo.finished!.boolValue) {
            let strikedRedo = NSMutableAttributedString(string: thisRedo.detail!)
            strikedRedo.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, strikedRedo.length))
            cell.textLabel?.attributedText = strikedRedo
        }
        else {
            cell.textLabel?.text = thisRedo.detail
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RedoEntryCell", forIndexPath: indexPath)
        self.configureCell(cell, indexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thisRedo = self.redosFRC.objectAtIndexPath(indexPath) as! Redo
        thisRedo.finished = NSNumber(bool: true)
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.checkListFinished()
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (indexPath.section == 0)
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let thisRedo = self.redosFRC.objectAtIndexPath(indexPath) as! Redo
            thisRedo.MR_deleteEntityInContext(NSManagedObjectContext.MR_defaultContext())
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            self.checkListFinished()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    func checkListFinished() {
        let predicate = NSPredicate(format: "list == %@ AND finished == false", self.redoList!)
        let count = Redo.MR_countOfEntitiesWithPredicate(predicate)
        if (count == 0) {
            self.redoList!.lastFinished = NSDate()
            let resetFinished = NSBatchUpdateRequest(entity: Redo.MR_entityDescription())
            resetFinished.propertiesToUpdate = ["finished": false]
            let predicate = NSPredicate(format: "list == %@", self.redoList!)
            resetFinished.predicate = predicate
            try! NSManagedObjectContext.MR_defaultContext().executeRequest(resetFinished)
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()

            self.navigationController?.popViewControllerAnimated(true)
        }
    }


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
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            self.tableView.reloadSectionIndexTitles()
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Update:
            self.tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}
