//
//  MeetingItemsBroughtForward.swift
//  
//
//  Created by Garry Eves on 7/07/2015.
//
//

import Foundation
import CoreData

class MeetingItemsBroughtForward: NSManagedObject {

    @NSManaged var decisionMade: String
    @NSManaged var discussionNotes: String
    @NSManaged var status: String
    @NSManaged var currentUpdate: String
    @NSManaged var targetDate: NSDate
    @NSManaged var owner: String
    @NSManaged var title: String
    @NSManaged var previousAgendaID: String
    @NSManaged var agendaID: String
    @NSManaged var meetingID: String

}
