//
//  Stages.swift
//  
//
//  Created by Garry Eves on 18/08/2015.
//
//

import Foundation
import CoreData

class Stages: NSManagedObject {

    @NSManaged var stageDescription: String
    @NSManaged var teamID: NSNumber
    @NSManaged var updateTime: Date
    @NSManaged var updateType: String

}
