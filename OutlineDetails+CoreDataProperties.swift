//
//  OutlineDetails+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension OutlineDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OutlineDetails> {
        return NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
    }

    @NSManaged public var checkBoxValue: NSNumber?
    @NSManaged public var lineID: NSNumber?
    @NSManaged public var lineOrder: NSNumber?
    @NSManaged public var lineText: String?
    @NSManaged public var lineType: String?
    @NSManaged public var outlineID: NSNumber?
    @NSManaged public var parentLine: NSNumber?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
