//
//  UserRoles+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension UserRoles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserRoles> {
        return NSFetchRequest<UserRoles>(entityName: "UserRoles")
    }

    @NSManaged public var readAccess: Bool
    @NSManaged public var roleID: Int32
    @NSManaged public var roleTypeID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?
    @NSManaged public var userID: Int32
    @NSManaged public var writeAccess: Bool

}
