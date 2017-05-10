//
//  Shifts+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension Shifts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shifts> {
        return NSFetchRequest<Shifts>(entityName: "Shifts")
    }

    @NSManaged public var dayOfWeek: String?
    @NSManaged public var endTime: NSDate?
    @NSManaged public var personID: Int32
    @NSManaged public var projectID: Int32
    @NSManaged public var rateID: Int32
    @NSManaged public var shiftID: Int32
    @NSManaged public var startTime: NSDate?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?
    @NSManaged public var workDate: NSDate?

}
