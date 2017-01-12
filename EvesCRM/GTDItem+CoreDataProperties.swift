//
//  GTDItem+CoreDataProperties.swift
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

extension GTDItem {

    @NSManaged var gTDItemID: NSNumber?
    @NSManaged var gTDParentID: NSNumber?
    @NSManaged var lastReviewDate: Date?
    @NSManaged var note: String?
    @NSManaged var predecessor: NSNumber?
    @NSManaged var reviewFrequency: NSNumber?
    @NSManaged var reviewPeriod: String?
    @NSManaged var status: String?
    @NSManaged var teamID: NSNumber?
    @NSManaged var title: String?
    @NSManaged var updateTime: Date?
    @NSManaged var updateType: String?
    @NSManaged var gTDLevel: NSNumber?

}
