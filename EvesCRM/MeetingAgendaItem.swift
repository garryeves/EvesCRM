//
//  MeetingAgendaItem.swift
//  
//
//  Created by Garry Eves on 7/07/2015.
//
//

import Foundation
import CoreData

class MeetingAgendaItem: NSManagedObject {

    @NSManaged var actualEndTime: NSDate
    @NSManaged var actualStartTime: NSDate
    @NSManaged var status: String
    @NSManaged var decisionMade: String
    @NSManaged var discussionNotes: String
    @NSManaged var timeAllocation: NSNumber
    @NSManaged var owner: String
    @NSManaged var title: String
    @NSManaged var agendaID: String
    @NSManaged var meetingID: String

}
