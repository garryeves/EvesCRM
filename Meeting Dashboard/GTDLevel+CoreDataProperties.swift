//
//  GTDLevel+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 27/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData


extension GTDLevel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GTDLevel> {
        return NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
    }

    @NSManaged public var gTDLevel: Int32
    @NSManaged public var levelName: String?
    @NSManaged public var teamID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
