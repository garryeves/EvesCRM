//
//  GoalAndObjective.swift
//  
//
//  Created by Garry Eves on 31/08/2015.
//
//

import Foundation
import CoreData

class GoalAndObjective: NSManagedObject {

    @NSManaged var goalID: NSNumber
    @NSManaged var note: String
    @NSManaged var status: String
    @NSManaged var teamID: NSNumber
    @NSManaged var title: String
    @NSManaged var updateTime: NSDate
    @NSManaged var updateType: String
    @NSManaged var visionID: NSNumber
    @NSManaged var lastReviewDate: NSDate
    @NSManaged var reviewFrequency: NSNumber
    @NSManaged var reviewPeriod: String
    @NSManaged var predecessor: NSNumber

}
