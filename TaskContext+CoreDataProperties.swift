//
//  TaskContext+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension TaskContext {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskContext> {
        return NSFetchRequest<TaskContext>(entityName: "TaskContext")
    }

    @NSManaged public var contextID: NSNumber?
    @NSManaged public var taskID: NSNumber?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
