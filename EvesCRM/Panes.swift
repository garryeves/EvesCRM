//
//  Panes.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 11/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData

class Panes: NSManagedObject {

    @NSManaged var pane_order: NSNumber
    @NSManaged var pane_available: NSNumber
    @NSManaged var pane_visible: NSNumber
    @NSManaged var pane_name: String

}
