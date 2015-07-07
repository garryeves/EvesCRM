//
//  MeetingTasks.swift
//  
//
//  Created by Garry Eves on 7/07/2015.
//
//

import Foundation
import CoreData

class MeetingTasks: NSManagedObject {

    @NSManaged var externalSystemID: String
    @NSManaged var externalSystemName: String
    @NSManaged var status: String
    @NSManaged var targetDate: NSDate
    @NSManaged var owner: String
    @NSManaged var title: String
    @NSManaged var taskID: String
    @NSManaged var agendaID: String
    @NSManaged var meetingID: String

}
