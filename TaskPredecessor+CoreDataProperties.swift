//
//  TaskPredecessor+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension TaskPredecessor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskPredecessor> {
        return NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
    }

    @NSManaged public var predecessorID: NSNumber?
    @NSManaged public var predecessorType: String?
    @NSManaged public var taskID: NSNumber?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
