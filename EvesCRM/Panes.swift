//
//  Panes.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class Panes: NSManagedObject {

    @NSManaged var pane_available: NSNumber
    @NSManaged var pane_name: String
    @NSManaged var pane_order: NSNumber
    @NSManaged var pane_visible: NSNumber
    @NSManaged var teamID: NSNumber
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String

}
