//
//  TaskUpdates.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 22/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData

class TaskUpdates: NSManagedObject {

    @NSManaged var taskID: String
    @NSManaged var updateDate: NSDate
    @NSManaged var details: String
    @NSManaged var source: String

}
