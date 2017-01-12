//
//  GTDLevel+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 7/09/2015.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GTDLevel {

    @NSManaged var teamID: NSNumber?
    @NSManaged var levelName: String?
    @NSManaged var gTDLevel: NSNumber?
    @NSManaged var updateTime: Date?
    @NSManaged var updateType: String?

}
