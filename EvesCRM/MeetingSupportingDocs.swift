//
//  MeetingSupportingDocs.swift
//  
//
//  Created by Garry Eves on 7/07/2015.
//
//

import Foundation
import CoreData

class MeetingSupportingDocs: NSManagedObject {

    @NSManaged var attachmentPath: String
    @NSManaged var title: String
    @NSManaged var agendaID: String
    @NSManaged var meetingID: String

}
