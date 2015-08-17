//
//  TaskAttachment.swift
//  
//
//  Created by Garry Eves on 17/08/2015.
//
//

import Foundation
import CoreData

class TaskAttachment: NSManagedObject {

    @NSManaged var attachment: NSData
    @NSManaged var taskID: NSNumber
    @NSManaged var title: String

}
