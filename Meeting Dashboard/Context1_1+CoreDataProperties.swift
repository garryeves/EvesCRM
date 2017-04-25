//
//  Context1_1+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 25/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData


extension Context1_1 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Context1_1> {
        return NSFetchRequest<Context1_1>(entityName: "Context1_1")
    }

    @NSManaged public var contextID: Int32
    @NSManaged public var contextType: String?
    @NSManaged public var predecessor: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
