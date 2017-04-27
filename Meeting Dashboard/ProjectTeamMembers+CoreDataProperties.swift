//
//  ProjectTeamMembers+CoreDataProperties.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 27/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData


extension ProjectTeamMembers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectTeamMembers> {
        return NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
    }

    @NSManaged public var projectID: Int32
    @NSManaged public var projectMemberNotes: String?
    @NSManaged public var roleID: Int32
    @NSManaged public var teamMember: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var updateType: String?

}
