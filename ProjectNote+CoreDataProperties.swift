//
//  ProjectNote+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension ProjectNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectNote> {
        return NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
    }

    @NSManaged public var note: String?
    @NSManaged public var predecessor: NSNumber?
    @NSManaged public var projectID: NSNumber?
    @NSManaged public var reviewPeriod: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
