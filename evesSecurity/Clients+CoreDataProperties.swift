//
//  Clients+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension Clients {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Clients> {
        return NSFetchRequest<Clients>(entityName: "Clients")
    }

    @NSManaged public var clientContact: String?
    @NSManaged public var clientID: Int32
    @NSManaged public var clientName: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
