//
//  Outline+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 6/01/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Outline {

    @NSManaged var outlineID: NSNumber?
    @NSManaged var parentID: NSNumber?
    @NSManaged var parentType: String?
    @NSManaged var title: String?
    @NSManaged var status: String?
    @NSManaged var updateTime: Date?
    @NSManaged var updateType: String?

}
