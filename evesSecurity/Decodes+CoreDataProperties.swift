//
//  Decodes+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension Decodes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Decodes> {
        return NSFetchRequest<Decodes>(entityName: "Decodes")
    }

    @NSManaged public var decode_name: String?
    @NSManaged public var decode_value: String?
    @NSManaged public var decodeType: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
