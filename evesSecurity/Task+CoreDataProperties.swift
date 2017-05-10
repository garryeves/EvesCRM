//
//  Task+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var completionDate: NSDate?
    @NSManaged public var details: String?
    @NSManaged public var dueDate: NSDate?
    @NSManaged public var energyLevel: String?
    @NSManaged public var estimatedTime: Int16
    @NSManaged public var estimatedTimeType: String?
    @NSManaged public var flagged: NSNumber?
    @NSManaged public var priority: String?
    @NSManaged public var projectID: Int32
    @NSManaged public var repeatBase: String?
    @NSManaged public var repeatInterval: Int16
    @NSManaged public var repeatType: String?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var status: String?
    @NSManaged public var taskID: Int32
    @NSManaged public var teamID: Int32
    @NSManaged public var title: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?
    @NSManaged public var urgency: String?

}
