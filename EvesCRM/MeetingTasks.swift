//
//  MeetingTasks.swift
//  
//
//  Created by Garry Eves on 17/08/2015.
//
//

import Foundation
import CoreData

class MeetingTasks: NSManagedObject {

    @NSManaged var agendaID: NSNumber
    @NSManaged var meetingID: String
    @NSManaged var taskID: NSNumber

}
