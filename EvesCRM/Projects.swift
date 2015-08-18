//
//  Projects.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class Projects: NSManagedObject {

    @NSManaged var areaID: NSNumber
    @NSManaged var lastReviewDate: NSDate
    @NSManaged var projectEndDate: NSDate
    @NSManaged var projectID: NSNumber
    @NSManaged var projectName: String
    @NSManaged var projectStartDate: NSDate
    @NSManaged var projectStatus: String
    @NSManaged var repeatBase: String
    @NSManaged var repeatInterval: NSNumber
    @NSManaged var repeatType: String
    @NSManaged var reviewFrequency: NSNumber
    @NSManaged var teamID: NSNumber
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String

}
