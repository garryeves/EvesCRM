//
//  Team+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 22/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData


extension Team {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @NSManaged public var externalID: NSObject?
    @NSManaged public var name: NSObject?
    @NSManaged public var note: NSObject?
    @NSManaged public var predecessor: NSObject?
    @NSManaged public var status: NSObject?
    @NSManaged public var teamID: NSObject?
    @NSManaged public var type: NSObject?
    @NSManaged public var updateTime: NSObject?
    @NSManaged public var updateType: NSObject?

}
