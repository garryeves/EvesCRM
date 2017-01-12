//
//  MeetingAgendaItem+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 5/10/2015.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MeetingAgendaItem {

    @NSManaged var actualEndTime: Date?
    @NSManaged var actualStartTime: Date?
    @NSManaged var agendaID: NSNumber?
    @NSManaged var decisionMade: String?
    @NSManaged var discussionNotes: String?
    @NSManaged var meetingID: String?
    @NSManaged var owner: String?
    @NSManaged var status: String?
    @NSManaged var timeAllocation: NSNumber?
    @NSManaged var title: String?
    @NSManaged var updateTime: Date?
    @NSManaged var updateType: String?
    @NSManaged var meetingOrder: NSNumber?

}
