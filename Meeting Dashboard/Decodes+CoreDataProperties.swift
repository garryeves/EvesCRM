//
//  Decodes+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 25/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
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
