//
//  Task.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 22/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData

class Task: NSManagedObject {

    @NSManaged var taskID: String
    @NSManaged var title: String
    @NSManaged var details: String
    @NSManaged var dueDate: NSDate
    @NSManaged var startDate: NSDate
    @NSManaged var status: String

}
