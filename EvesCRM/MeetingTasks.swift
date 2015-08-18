//
//  MeetingTasks.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class MeetingTasks: NSManagedObject {

    @NSManaged var agendaID: NSNumber
    @NSManaged var meetingID: String
    @NSManaged var taskID: NSNumber
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String

}
