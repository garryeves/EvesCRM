//
//  AreaOfResponsibility.swift
//  
//
//  Created by Garry Eves on 28/07/2015.
//
//

import Foundation
import CoreData

class AreaOfResponsibility: NSManagedObject {

    @NSManaged var areaID: NSNumber
    @NSManaged var goalID: NSNumber
    @NSManaged var status: String
    @NSManaged var title: String

}
