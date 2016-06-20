//
//  RedoList1to2MigrationPolicy.swift
//  Redo
//
//  Created by AquarHEAD L. on 06/10/2015.
//  Copyright © 2015 ElaWorkshop. All rights reserved.
//

import UIKit
import CoreData

class RedoList1to2MigrationPolicy: NSEntityMigrationPolicy {

    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        let destMOC : NSManagedObjectContext = manager.destinationContext
        let destEntityName = mapping.destinationEntityName
        let dInstance = NSEntityDescription.insertNewObjectForEntityForName(destEntityName!, inManagedObjectContext: destMOC)
        dInstance.setValue(sInstance.valueForKeyPath("name"), forKeyPath: "name")
        dInstance.setValue(sInstance.valueForKeyPath("lastFinished"), forKeyPath: "lastFinished")

        if ((sInstance.valueForKeyPath("lastFinished")) != nil) {
            dInstance.setValue(NSNumber(integer: 0), forKeyPath: "finishCount")
        }
        else {
            dInstance.setValue(NSNumber(integer: 1), forKeyPath: "finishCount")
        }

        manager.associateSourceInstance(sInstance, withDestinationInstance: dInstance, forEntityMapping: mapping)
    }
}


/*

// destination managed object context and entity name
NSManagedObjectContext *destinationManagedObjectContext = [manager destinationContext];
NSString *destinationEntityName = [mapping destinationEntityName];

// create the Address entity in the destination model
NSManagedObject *dInstance = [NSEntityDescription insertNewObjectForEntityForName:destinationEntityName
inManagedObjectContext:destinationManagedObjectContext];
// set the non-normalized attributes
[dInstance setValue:[sInstance valueForKey:@"street"] forKeyPath:@"street"];
[dInstance setValue:[sInstance valueForKey:@"city"] forKeyPath:@"city"];

// lookup its state
NSString *stateName = [sInstance valueForKey:@"state"];
NSMutableDictionary *states = [manager userInfo][@"states"];
NSManagedObject *state = states[stateName];

// create and store a new State entity if not found
if (!state) {
state
= [NSEntityDescription insertNewObjectForEntityForName:@"State"
inManagedObjectContext:destinationManagedObjectContext];
[state setValue:stateName forKeyPath:@"name"];
states[stateName] = state;
}

// set the State relationship on the Address entity
[dInstance setValue:state forKeyPath:@"state"];

// associate the source and destination Address entities
[manager associateSourceInstance:sInstance
withDestinationInstance:dInstance
forEntityMapping:mapping];

return YES;
*/