//
//  Reports+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 12/6/17.
//
//

import Foundation
import CoreData


extension Reports {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reports> {
        return NSFetchRequest<Reports>(entityName: "Reports")
    }

    @NSManaged public var reportID: Int64
    @NSManaged public var reportTitle: String?
    @NSManaged public var reportDescription: String?
    @NSManaged public var reportType: String?
    @NSManaged public var systemReport: Bool
    @NSManaged public var teamID: Int64
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?
    @NSManaged public var columnTitle1: String?
    @NSManaged public var columnSource1: String?
    @NSManaged public var columnWidth1: Double
    @NSManaged public var columnTitle2: String?
    @NSManaged public var columnSource2: String?
    @NSManaged public var columnWidth2: Double
    @NSManaged public var columnTitle3: String?
    @NSManaged public var columnSource3: String?
    @NSManaged public var columnWidth3: Double
    @NSManaged public var columnTitle4: String?
    @NSManaged public var columnSource4: String?
    @NSManaged public var columnWidth4: Double
    @NSManaged public var columnTitle5: String?
    @NSManaged public var columnSource5: String?
    @NSManaged public var columnWidth5: Double
    @NSManaged public var columnTitle6: String?
    @NSManaged public var columnSource6: String?
    @NSManaged public var columnWidth6: Double
    @NSManaged public var columnTitle7: String?
    @NSManaged public var columnSource7: String?
    @NSManaged public var columnWidth7: Double
    @NSManaged public var columnTitle8: String?
    @NSManaged public var columnSource8: String?
    @NSManaged public var columnWidth8: Double
    @NSManaged public var columnTitle9: String?
    @NSManaged public var columnSource9: String?
    @NSManaged public var columnWidth9: Double
    @NSManaged public var columnTitle10: String?
    @NSManaged public var columnSource10: String?
    @NSManaged public var columnWidth10: Double
    @NSManaged public var columnTitle11: String?
    @NSManaged public var columnSource11: String?
    @NSManaged public var columnWidth11: Double
    @NSManaged public var columnTitle12: String?
    @NSManaged public var columnSource12: String?
    @NSManaged public var columnWidth12: Double
    @NSManaged public var columnTitle13: String?
    @NSManaged public var columnSource13: String?
    @NSManaged public var columnWidth13: Double
    @NSManaged public var columnWidth14: Double
    @NSManaged public var columnTitle14: String?
    @NSManaged public var columnSource14: String?
    @NSManaged public var selectionCriteria1: String?
    @NSManaged public var selectionCriteria2: String?
    @NSManaged public var selectionCriteria3: String?
    @NSManaged public var selectionCriteria4: String?
    @NSManaged public var sortOrder1: String?
    @NSManaged public var sortOrder2: String?
    @NSManaged public var sortOrder3: String?
    @NSManaged public var sortOrder4: String?

}
