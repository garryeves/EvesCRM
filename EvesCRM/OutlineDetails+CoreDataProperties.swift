//
//  OutlineDetails+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 6/01/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension OutlineDetails {

    @NSManaged var outlineID: NSNumber?
    @NSManaged var lineID: NSNumber?
    @NSManaged var lineOrder: NSNumber?
    @NSManaged var parentLine: NSNumber?
    @NSManaged var lineText: String?
    @NSManaged var lineType: String?
    @NSManaged var checkBoxValue: NSNumber?
    @NSManaged var updateTime: Date?
    @NSManaged var updateType: String?

}
