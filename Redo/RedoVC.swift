//
//  RedoVC.swift
//  Redo
//
//  Created by AquarHEAD L. on 19/09/2015.
//  Copyright © 2015 ElaWorkshop. All rights reserved.
//

import UIKit

class RedoVC: UITableViewController {

    var redos: [String] = []
    var doned: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
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
        if (section == 0) {
            return redos.count
        }
        else {
            return doned.count;
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RedoEntryCell", forIndexPath: indexPath)
        if (indexPath.section == 0) {
            cell.textLabel?.text = redos[indexPath.row]
        }
        else {
            let strikedRedo = NSMutableAttributedString(string: doned[indexPath.row])
            strikedRedo.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, strikedRedo.length))
            cell.textLabel?.attributedText = strikedRedo
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let strikedRedo = NSMutableAttributedString(string: (cell!.textLabel?.text)!)
        strikedRedo.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, strikedRedo.length))
        cell!.textLabel?.attributedText = strikedRedo
        let newIndexPath = NSIndexPath(forRow: tableView.numberOfRowsInSection(1), inSection: 1)
        let donedRedo = redos.removeAtIndex(indexPath.row)
        doned.append(donedRedo)
        tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
}
