//
//  TaskContext+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 25/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData


extension TaskContext {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskContext> {
        return NSFetchRequest<TaskContext>(entityName: "TaskContext")
    }

    @NSManaged public var contextID: Int32
    @NSManaged public var taskID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
