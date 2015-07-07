//
//  MeetingAgenda.swift
//  
//
//  Created by Garry Eves on 7/07/2015.
//
//

import Foundation
import CoreData

class MeetingAgenda: NSManagedObject {

    @NSManaged var previousMeetingID: String
    @NSManaged var meetingID: String
    @NSManaged var name: String
    @NSManaged var chair: String
    @NSManaged var minutes: String
    @NSManaged var location: String
    @NSManaged var startTime: NSDate
    @NSManaged var endTime: NSDate
    @NSManaged var minutesType: String

}
