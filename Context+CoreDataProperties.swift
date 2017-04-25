//
//  Context+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension Context {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Context> {
        return NSFetchRequest<Context>(entityName: "Context")
    }

    @NSManaged public var autoEmail: String?
    @NSManaged public var contextID: NSNumber?
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var parentContext: NSNumber?
    @NSManaged public var personID: NSNumber?
    @NSManaged public var status: String?
    @NSManaged public var teamID: NSNumber?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
