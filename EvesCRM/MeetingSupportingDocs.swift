//
//  MeetingSupportingDocs.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class MeetingSupportingDocs: NSManagedObject {

    @NSManaged var agendaID: NSNumber
    @NSManaged var attachmentPath: String
    @NSManaged var meetingID: String
    @NSManaged var title: String
    @NSManaged var updateTime: Date
    @NSManaged var updateType: String

}
