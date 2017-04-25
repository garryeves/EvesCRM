//
//  MeetingTasks+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension MeetingTasks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeetingTasks> {
        return NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
    }

    @NSManaged public var agendaID: NSNumber?
    @NSManaged public var meetingID: String?
    @NSManaged public var taskID: NSNumber?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
