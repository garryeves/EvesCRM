//
//  Contacts+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension Contacts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contacts> {
        return NSFetchRequest<Contacts>(entityName: "Contacts")
    }

    @NSManaged public var contactType: String?
    @NSManaged public var contactValue: String?
    @NSManaged public var personID: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
