//
//  PurposeAndCoreValue.swift
//  
//
//  Created by Garry Eves on 17/08/2015.
//
//

import Foundation
import CoreData

class PurposeAndCoreValue: NSManagedObject {

    @NSManaged var purposeID: NSNumber
    @NSManaged var status: String
    @NSManaged var title: String

}
