//
//  MeetingTasks+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 27/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
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
