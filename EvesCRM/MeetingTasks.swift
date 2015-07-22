//
//  MeetingTasks.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 22/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData

class MeetingTasks: NSManagedObject {

    @NSManaged var agendaID: String
    @NSManaged var meetingID: String
    @NSManaged var taskID: String

}
