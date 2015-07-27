//
//  PurposeAndCoreValue.swift
//  
//
//  Created by Garry Eves on 27/07/2015.
//
//

import Foundation
import CoreData

class PurposeAndCoreValue: NSManagedObject {

    @NSManaged var purposeID: String
    @NSManaged var title: String
    @NSManaged var status: String

}
