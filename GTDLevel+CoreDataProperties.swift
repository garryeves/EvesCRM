//
//  GTDLevel+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension GTDLevel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GTDLevel> {
        return NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
    }

    @NSManaged public var gTDLevel: NSNumber?
    @NSManaged public var levelName: String?
    @NSManaged public var teamID: NSNumber?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
