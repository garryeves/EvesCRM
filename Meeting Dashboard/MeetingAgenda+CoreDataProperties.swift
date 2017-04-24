//
//  MeetingAgenda+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 22/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData


extension MeetingAgenda {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeetingAgenda> {
        return NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
    }

    @NSManaged public var chair: String?
    @NSManaged public var endTime: NSDate?
    @NSManaged public var location: String?
    @NSManaged public var meetingID: String?
    @NSManaged public var minutes: String?
    @NSManaged public var minutesType: String?
    @NSManaged public var name: String?
    @NSManaged public var previousMeetingID: String?
    @NSManaged public var startTime: NSDate?
    @NSManaged public var teamID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
