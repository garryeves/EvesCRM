//
//  AreaOfResponsibility.swift
//  
//
//  Created by Garry Eves on 27/08/2015.
//
//

import Foundation
import CoreData

class AreaOfResponsibility: NSManagedObject {

    @NSManaged var areaID: NSNumber
    @NSManaged var goalID: NSNumber
    @NSManaged var status: String
    @NSManaged var teamID: NSNumber
    @NSManaged var title: String
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String
    @NSManaged var note: String

}
