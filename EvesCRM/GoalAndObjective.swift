//
//  GoalAndObjective.swift
//  
//
//  Created by Garry Eves on 27/07/2015.
//
//

import Foundation
import CoreData

class GoalAndObjective: NSManagedObject {

    @NSManaged var goalID: String
    @NSManaged var visionID: String
    @NSManaged var title: String
    @NSManaged var status: String

}
