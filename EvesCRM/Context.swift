//
//  Context.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 22/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData

class Context: NSManagedObject {

    @NSManaged var contextID: String
    @NSManaged var name: String
    @NSManaged var email: String
    @NSManaged var autoEmail: String
    @NSManaged var parentContext: String
    @NSManaged var status: String

}
