//
//  Stages+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension Stages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stages> {
        return NSFetchRequest<Stages>(entityName: "Stages")
    }

    @NSManaged public var stageDescription: String?
    @NSManaged public var teamID: NSNumber?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
