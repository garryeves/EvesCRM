//
//  Vision.swift
//  
//
//  Created by Garry Eves on 27/08/2015.
//
//

import Foundation
import CoreData

class Vision: NSManagedObject {

    @NSManaged var purposeID: NSNumber
    @NSManaged var status: String
    @NSManaged var teamID: NSNumber
    @NSManaged var title: String
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String
    @NSManaged var visionID: NSNumber
    @NSManaged var note: String

}
