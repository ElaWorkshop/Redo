//
//  Redo+CoreDataProperties.swift
//  Redo
//
//  Created by AquarHEAD L. on 02/10/2015.
//  Copyright © 2015 ElaWorkshop. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Redo {

    @NSManaged var detail: String?
    @NSManaged var order: NSNumber?
    @NSManaged var finished: NSNumber?
    @NSManaged var list: RedoList?

}
