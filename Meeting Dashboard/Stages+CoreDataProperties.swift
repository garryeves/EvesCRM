//
//  Stages+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 27/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData


extension Stages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stages> {
        return NSFetchRequest<Stages>(entityName: "Stages")
    }

    @NSManaged public var stageDescription: String?
    @NSManaged public var teamID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
