//
//  Task.swift
//  
//
//  Created by Garry Eves on 4/08/2015.
//
//

import Foundation
import CoreData

class Task: NSManagedObject {

    @NSManaged var details: String
    @NSManaged var dueDate: NSDate
    @NSManaged var energyLevel: String
    @NSManaged var estimatedTime: NSNumber
    @NSManaged var estimatedTimeType: String
    @NSManaged var parentID: NSNumber
    @NSManaged var parentType: String
    @NSManaged var priority: String
    @NSManaged var projectID: NSNumber
    @NSManaged var startDate: NSDate
    @NSManaged var status: String
    @NSManaged var taskID: NSNumber
    @NSManaged var taskMode: String
    @NSManaged var taskOrder: NSNumber
    @NSManaged var title: String
    @NSManaged var completionDate: NSDate

}
