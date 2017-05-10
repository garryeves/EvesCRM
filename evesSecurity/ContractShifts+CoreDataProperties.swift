//
//  ContractShifts+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 10/5/17.
//
//

import Foundation
import CoreData


extension ContractShifts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContractShifts> {
        return NSFetchRequest<ContractShifts>(entityName: "ContractShifts")
    }

    @NSManaged public var contractShiftID: Int32
    @NSManaged public var endDate: NSDate?
    @NSManaged public var projectID: Int32
    @NSManaged public var startDate: NSDate?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
