//
//  Context.swift
//  
//
//  Created by Garry Eves on 28/07/2015.
//
//

import Foundation
import CoreData

class Context: NSManagedObject {

    @NSManaged var autoEmail: String
    @NSManaged var contextID: NSNumber
    @NSManaged var email: String
    @NSManaged var name: String
    @NSManaged var parentContext: NSNumber
    @NSManaged var status: String

}
