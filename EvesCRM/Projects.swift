//
//  Projects.swift
//  
//
//  Created by Garry Eves on 4/05/2015.
//
//

import Foundation
import CoreData

class Projects: NSManagedObject {

    @NSManaged var projectEndDate: NSDate
    @NSManaged var projectID: NSNumber
    @NSManaged var projectName: String
    @NSManaged var projectStartDate: NSDate
    @NSManaged var projectStatus: String

}
