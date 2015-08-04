//
//  TaskAttachment.swift
//  
//
//  Created by Garry Eves on 4/08/2015.
//
//

import Foundation
import CoreData

class TaskAttachment: NSManagedObject {

    @NSManaged var taskID: NSNumber
    @NSManaged var title: String
    @NSManaged var attachment: NSData

}
