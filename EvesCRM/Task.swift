//
//  Task.swift
//  
//
//  Created by Garry Eves on 19/08/2015.
//
//

import Foundation
import CoreData

class Task: NSManagedObject {

    @NSManaged var completionDate: Date
    @NSManaged var details: String
    @NSManaged var dueDate: Date
    @NSManaged var energyLevel: String
    @NSManaged var estimatedTime: NSNumber
    @NSManaged var estimatedTimeType: String
    @NSManaged var flagged: NSNumber
    @NSManaged var priority: String
    @NSManaged var projectID: NSNumber
    @NSManaged var repeatBase: String
    @NSManaged var repeatInterval: NSNumber
    @NSManaged var repeatType: String
    @NSManaged var startDate: Date
    @NSManaged var status: String
    @NSManaged var taskID: NSNumber
    @NSManaged var teamID: NSNumber
    @NSManaged var title: String
    @NSManaged var updateTime: Date
    @NSManaged var updateType: String
    @NSManaged var urgency: String

}
