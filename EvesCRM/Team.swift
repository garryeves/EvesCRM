//
//  Team.swift
//  
//
//  Created by Garry Eves on 31/08/2015.
//
//

import Foundation
import CoreData

class Team: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var note: String
    @NSManaged var status: String
    @NSManaged var teamID: NSNumber
    @NSManaged var type: String
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String
    @NSManaged var predecessor: NSNumber
    @NSManaged var externalID: NSNumber

}
