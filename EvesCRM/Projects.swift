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
    @NSManaged var lastReviewDate: Date
    @NSManaged var projectEndDate: Date
    @NSManaged var projectID: NSNumber
    @NSManaged var projectName: String
    @NSManaged var projectStartDate: Date
    @NSManaged var projectStatus: String
    @NSManaged var repeatBase: String
    @NSManaged var repeatInterval: NSNumber
    @NSManaged var repeatType: String
    @NSManaged var reviewFrequency: NSNumber
    @NSManaged var teamID: NSNumber
    @NSManaged var updateTime: Date
    @NSManaged var updateType: String

}
