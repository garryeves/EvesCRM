//
//  MeetingAttendees.swift
//  
//
//  Created by Garry Eves on 7/07/2015.
//
//

import Foundation
import CoreData

class MeetingAttendees: NSManagedObject {

    @NSManaged var attendenceStatus: String
    @NSManaged var email: String
    @NSManaged var name: String
    @NSManaged var meetingID: String

}
