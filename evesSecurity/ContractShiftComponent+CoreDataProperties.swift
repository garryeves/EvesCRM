//
//  ContractShiftComponent+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension ContractShiftComponent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContractShiftComponent> {
        return NSFetchRequest<ContractShiftComponent>(entityName: "ContractShiftComponent")
    }

    @NSManaged public var contractShiftID: Int32
    @NSManaged public var dayOfWeek: String?
    @NSManaged public var endTime: NSDate?
    @NSManaged public var startTime: NSDate?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
