//
//  Decodes.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class Decodes: NSManagedObject {

    @NSManaged var decode_name: String
    @NSManaged var decode_value: String
    @NSManaged var decodeType: String
    @NSManaged var teamID: NSNumber
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String

}
