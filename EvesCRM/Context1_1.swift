//
//  Context1_1.swift
//  
//
//  Created by Garry Eves on 31/08/2015.
//
//

import Foundation
import CoreData

class Context1_1: NSManagedObject {

    @NSManaged var contextID: NSNumber
    @NSManaged var predecessor: NSNumber
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String

}
