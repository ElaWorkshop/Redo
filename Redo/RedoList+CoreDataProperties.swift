//
//  RedoList+CoreDataProperties.swift
//  Redo
//
//  Created by AquarHEAD L. on 20/09/2015.
//  Copyright © 2015 ElaWorkshop. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RedoList {

    @NSManaged var name: String?
    @NSManaged var redos: NSSet?

}