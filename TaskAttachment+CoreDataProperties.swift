//
//  TaskAttachment+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 26/4/17.
//
//

import Foundation
import CoreData


extension TaskAttachment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskAttachment> {
        return NSFetchRequest<TaskAttachment>(entityName: "TaskAttachment")
    }

    @NSManaged public var attachment: NSData?
    @NSManaged public var taskID: Int32
    @NSManaged public var title: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
