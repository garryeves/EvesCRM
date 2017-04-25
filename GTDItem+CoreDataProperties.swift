//
//  GTDItem+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension GTDItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GTDItem> {
        return NSFetchRequest<GTDItem>(entityName: "GTDItem")
    }

    @NSManaged public var gTDItemID: NSNumber?
    @NSManaged public var gTDLevel: NSNumber?
    @NSManaged public var gTDParentID: NSNumber?
    @NSManaged public var lastReviewDate: NSDate?
    @NSManaged public var note: String?
    @NSManaged public var predecessor: NSNumber?
    @NSManaged public var reviewFrequency: NSNumber?
    @NSManaged public var reviewPeriod: String?
    @NSManaged public var status: String?
    @NSManaged public var teamID: NSNumber?
    @NSManaged public var title: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
