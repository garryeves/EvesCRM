//
//  MeetingSupportingDocs+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension MeetingSupportingDocs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeetingSupportingDocs> {
        return NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
    }

    @NSManaged public var agendaID: Int32
    @NSManaged public var attachmentPath: String?
    @NSManaged public var meetingID: String?
    @NSManaged public var title: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
