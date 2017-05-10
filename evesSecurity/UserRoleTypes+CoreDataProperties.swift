//
//  UserRoleTypes+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension UserRoleTypes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserRoleTypes> {
        return NSFetchRequest<UserRoleTypes>(entityName: "UserRoleTypes")
    }

    @NSManaged public var name: String?
    @NSManaged public var roleTypeID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
