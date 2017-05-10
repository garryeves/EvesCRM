//
//  Dropdowns+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension Dropdowns {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dropdowns> {
        return NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
    }

    @NSManaged public var dropDownName: String?
    @NSManaged public var dropDownValue: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
