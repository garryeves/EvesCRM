//
//  Context1_1+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 5/10/2015.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Context1_1 {

    @NSManaged var contextID: NSNumber?
    @NSManaged var contextType: String?
    @NSManaged var predecessor: NSNumber?
    @NSManaged var updateTime: Date?
    @NSManaged var updateType: String?

}
