//
//  ProcessedEmails+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 25/4/17.
//
//

import Foundation
import CoreData


extension ProcessedEmails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProcessedEmails> {
        return NSFetchRequest<ProcessedEmails>(entityName: "ProcessedEmails")
    }

    @NSManaged public var emailID: String?
    @NSManaged public var emailType: String?
    @NSManaged public var processedDate: NSDate?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
