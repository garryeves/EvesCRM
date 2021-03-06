//
//  Outline+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 26/4/17.
//
//

import Foundation
import CoreData


extension Outline {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Outline> {
        return NSFetchRequest<Outline>(entityName: "Outline")
    }

    @NSManaged public var outlineID: Int32
    @NSManaged public var parentID: Int32
    @NSManaged public var parentType: String?
    @NSManaged public var status: String?
    @NSManaged public var title: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
