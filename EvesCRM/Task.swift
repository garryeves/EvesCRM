//
//  Task.swift
//  
//
//  Created by Garry Eves on 27/07/2015.
//
//

import Foundation
import CoreData

class Task: NSManagedObject {

    @NSManaged var details: String
    @NSManaged var dueDate: NSDate
    @NSManaged var startDate: NSDate
    @NSManaged var status: String
    @NSManaged var taskID: String
    @NSManaged var title: String
    @NSManaged var parentTaskID: String

}
