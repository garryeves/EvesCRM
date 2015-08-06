//
//  MeetingItemsBroughtForward.swift
//  
//
//  Created by Garry Eves on 6/08/2015.
//
//

import Foundation
import CoreData

class MeetingItemsBroughtForward: NSManagedObject {

    @NSManaged var agendaID: NSNumber
    @NSManaged var currentUpdate: String
    @NSManaged var decisionMade: String
    @NSManaged var discussionNotes: String
    @NSManaged var meetingID: String
    @NSManaged var owner: String
    @NSManaged var previousAgendaID: NSNumber
    @NSManaged var status: String
    @NSManaged var targetDate: NSDate
    @NSManaged var title: String

}
