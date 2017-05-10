//
//  GTDItem+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension GTDItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GTDItem> {
        return NSFetchRequest<GTDItem>(entityName: "GTDItem")
    }

    @NSManaged public var gTDItemID: Int32
    @NSManaged public var gTDLevel: Int32
    @NSManaged public var gTDParentID: Int32
    @NSManaged public var lastReviewDate: NSDate?
    @NSManaged public var note: String?
    @NSManaged public var predecessor: Int32
    @NSManaged public var reviewFrequency: Int16
    @NSManaged public var reviewPeriod: String?
    @NSManaged public var status: String?
    @NSManaged public var teamID: Int32
    @NSManaged public var title: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
