//
//  MeetingTasks.swift
//  
//
//  Created by Garry Eves on 28/07/2015.
//
//

import Foundation
import CoreData

class MeetingTasks: NSManagedObject {

    @NSManaged var agendaID: String
    @NSManaged var meetingID: String
    @NSManaged var taskID: NSNumber

}
