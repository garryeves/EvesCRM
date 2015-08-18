//
//  MeetingAgenda.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class MeetingAgenda: NSManagedObject {

    @NSManaged var chair: String
    @NSManaged var endTime: NSDate
    @NSManaged var location: String
    @NSManaged var meetingID: String
    @NSManaged var minutes: String
    @NSManaged var minutesType: String
    @NSManaged var name: String
    @NSManaged var previousMeetingID: String
    @NSManaged var startTime: NSDate
    @NSManaged var teamID: NSNumber
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String

}
