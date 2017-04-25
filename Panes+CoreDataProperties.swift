//
//  Panes+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension Panes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Panes> {
        return NSFetchRequest<Panes>(entityName: "Panes")
    }

    @NSManaged public var pane_available: NSNumber?
    @NSManaged public var pane_name: String?
    @NSManaged public var pane_order: NSNumber?
    @NSManaged public var pane_visible: NSNumber?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
