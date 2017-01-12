//
//  TaskAttachment.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class TaskAttachment: NSManagedObject {

    @NSManaged var attachment: Data
    @NSManaged var taskID: NSNumber
    @NSManaged var title: String
    @NSManaged var updateTime: Date
    @NSManaged var updateType: String

}
