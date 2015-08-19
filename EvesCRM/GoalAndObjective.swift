//
//  GoalAndObjective.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class GoalAndObjective: NSManagedObject {

    @NSManaged var goalID: NSNumber
    @NSManaged var status: String
    @NSManaged var title: String
    @NSManaged var visionID: NSNumber
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String
    @NSManaged var teamID: NSNumber

}