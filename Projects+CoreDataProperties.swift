//
//  Projects+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension Projects {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Projects> {
        return NSFetchRequest<Projects>(entityName: "Projects")
    }

    @NSManaged public var areaID: NSNumber?
    @NSManaged public var lastReviewDate: NSDate?
    @NSManaged public var projectEndDate: NSDate?
    @NSManaged public var projectID: NSNumber?
    @NSManaged public var projectName: String?
    @NSManaged public var projectStartDate: NSDate?
    @NSManaged public var projectStatus: String?
    @NSManaged public var repeatBase: String?
    @NSManaged public var repeatInterval: NSNumber?
    @NSManaged public var repeatType: String?
    @NSManaged public var reviewFrequency: NSNumber?
    @NSManaged public var teamID: NSNumber?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
