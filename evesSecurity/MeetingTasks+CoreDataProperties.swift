//
//  MeetingTasks+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension MeetingTasks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeetingTasks> {
        return NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
    }

    @NSManaged public var agendaID: Int32
    @NSManaged public var meetingID: String?
    @NSManaged public var taskID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
