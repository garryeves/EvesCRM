//
//  AreaOfResponsibility.swift
//  
//
//  Created by Garry Eves on 27/07/2015.
//
//

import Foundation
import CoreData

class AreaOfResponsibility: NSManagedObject {

    @NSManaged var areaID: String
    @NSManaged var goalID: String
    @NSManaged var title: String
    @NSManaged var status: String

}
