//
//  Roles+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension Roles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Roles> {
        return NSFetchRequest<Roles>(entityName: "Roles")
    }

    @NSManaged public var roleDescription: String?
    @NSManaged public var roleID: Int32
    @NSManaged public var teamID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
