//
//  ProjectNote.swift
//  
//
//  Created by Garry Eves on 27/08/2015.
//
//

import Foundation
import CoreData

class ProjectNote: NSManagedObject {

    @NSManaged var projectID: NSNumber
    @NSManaged var note: String
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String

}
