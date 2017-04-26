//
//  OutlineDetails+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 26/4/17.
//
//

import Foundation
import CoreData


extension OutlineDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OutlineDetails> {
        return NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
    }

    @NSManaged public var checkBoxValue: NSNumber?
    @NSManaged public var lineID: Int32
    @NSManaged public var lineOrder: Int32
    @NSManaged public var lineText: String?
    @NSManaged public var lineType: String?
    @NSManaged public var outlineID: Int32
    @NSManaged public var parentLine: Int32
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
