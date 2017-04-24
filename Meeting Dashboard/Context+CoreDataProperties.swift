//
//  Context+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 22/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData


extension Context {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Context> {
        return NSFetchRequest<Context>(entityName: "Context")
    }

    @NSManaged public var autoEmail: String?
    @NSManaged public var contextID: Int32
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var parentContext: Int32
    @NSManaged public var personID: Int32
    @NSManaged public var status: String?
    @NSManaged public var teamID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
