//
//  ProjectTasks.swift
//  
//
//  Created by Garry Eves on 24/07/2015.
//
//

import Foundation
import CoreData

class ProjectTasks: NSManagedObject {

    @NSManaged var projectID: NSNumber
    @NSManaged var taskID: String

}
