//
//  MeetingAgendaItem.swift
//  
//
//  Created by Garry Eves on 17/08/2015.
//
//

import Foundation
import CoreData

class MeetingAgendaItem: NSManagedObject {

    @NSManaged var actualEndTime: NSDate
    @NSManaged var actualStartTime: NSDate
    @NSManaged var agendaID: NSNumber
    @NSManaged var decisionMade: String
    @NSManaged var discussionNotes: String
    @NSManaged var meetingID: String
    @NSManaged var owner: String
    @NSManaged var status: String
    @NSManaged var timeAllocation: NSNumber
    @NSManaged var title: String

}
