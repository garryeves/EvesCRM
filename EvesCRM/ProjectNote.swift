//
//  ProjectNote.swift
//  
//
//  Created by Garry Eves on 31/08/2015.
//
//

import Foundation
import CoreData

class ProjectNote: NSManagedObject {

    @NSManaged var note: String
    @NSManaged var projectID: NSNumber
    @NSManaged var updateTime: Date
    @NSManaged var updateType: String
    @NSManaged var reviewPeriod: String
    @NSManaged var predecessor: NSNumber

}
