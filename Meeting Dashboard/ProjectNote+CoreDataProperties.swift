//
//  ProjectNote+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 27/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData


extension ProjectNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectNote> {
        return NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
    }

    @NSManaged public var note: String?
    @NSManaged public var predecessor: Int32
    @NSManaged public var projectID: Int32
    @NSManaged public var reviewPeriod: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
