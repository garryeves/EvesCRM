//
//  Person+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var dob: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var personID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
