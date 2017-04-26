//
//  TaskUpdates+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 26/4/17.
//
//

import Foundation
import CoreData


extension TaskUpdates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskUpdates> {
        return NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
    }

    @NSManaged public var details: String?
    @NSManaged public var source: String?
    @NSManaged public var taskID: Int32
    @NSManaged public var updateDate: NSDate?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
