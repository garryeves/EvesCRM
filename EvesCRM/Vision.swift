//
//  Vision.swift
//  
//
//  Created by Garry Eves on 28/07/2015.
//
//

import Foundation
import CoreData

class Vision: NSManagedObject {

    @NSManaged var purposeID: NSNumber
    @NSManaged var status: String
    @NSManaged var title: String
    @NSManaged var visionID: NSNumber

}
