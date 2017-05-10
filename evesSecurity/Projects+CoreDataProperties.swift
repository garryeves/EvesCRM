//
//  Projects+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension Projects {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Projects> {
        return NSFetchRequest<Projects>(entityName: "Projects")
    }

    @NSManaged public var areaID: Int32
    @NSManaged public var clientID: Int32
    @NSManaged public var lastReviewDate: NSDate?
    @NSManaged public var projectEndDate: NSDate?
    @NSManaged public var projectID: Int32
    @NSManaged public var projectName: String?
    @NSManaged public var projectStartDate: NSDate?
    @NSManaged public var projectStatus: String?
    @NSManaged public var repeatBase: String?
    @NSManaged public var repeatInterval: Int16
    @NSManaged public var repeatType: String?
    @NSManaged public var reviewFrequency: Int16
    @NSManaged public var teamID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
