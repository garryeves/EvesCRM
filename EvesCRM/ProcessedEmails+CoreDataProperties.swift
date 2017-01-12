//
//  ProcessedEmails+CoreDataProperties.swift
//  
//
//  Created by Garry Eves on 29/09/2015.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ProcessedEmails {

    @NSManaged var emailID: String?
    @NSManaged var emailType: String?
    @NSManaged var processedDate: Date?
    @NSManaged var updateTime: Date?
    @NSManaged var updateType: String?

}
