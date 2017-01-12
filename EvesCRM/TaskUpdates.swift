//
//  TaskUpdates.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class TaskUpdates: NSManagedObject {

    @NSManaged var details: String
    @NSManaged var source: String
    @NSManaged var taskID: NSNumber
    @NSManaged var updateDate: Date
    @NSManaged var updateTime: Date
    @NSManaged var updateType: String

}
