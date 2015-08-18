//
//  TaskContext.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class TaskContext: NSManagedObject {

    @NSManaged var contextID: NSNumber
    @NSManaged var taskID: NSNumber
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String

}
