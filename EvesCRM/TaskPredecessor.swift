//
//  TaskPredecessor.swift
//  
//
//  Created by Garry Eves on 19/08/2015.
//
//

import Foundation
import CoreData

class TaskPredecessor: NSManagedObject {

    @NSManaged var taskID: NSNumber
    @NSManaged var predecessorID: NSNumber
    @NSManaged var predecessorType: String
    @NSManaged var updateTime: Date
    @NSManaged var updateType: String

}
