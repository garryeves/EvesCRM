//
//  Roles.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class Roles: NSManagedObject {

    @NSManaged var roleDescription: String
    @NSManaged var roleID: NSNumber
    @NSManaged var teamID: NSNumber
    @NSManaged var updateTime: Date
    @NSManaged var updateType: String

}
