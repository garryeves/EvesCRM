//
//  Team+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension Team {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @NSManaged public var externalID: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var predecessor: NSNumber?
    @NSManaged public var status: String?
    @NSManaged public var teamID: NSNumber?
    @NSManaged public var type: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
