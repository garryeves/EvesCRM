//
//  ProjectTeamMembers.swift
//  
//
//  Created by Garry Eves on 4/05/2015.
//
//

import Foundation
import CoreData

class ProjectTeamMembers: NSManagedObject {

    @NSManaged var projectID: NSNumber
    @NSManaged var projectMemberNotes: String
    @NSManaged var roleID: NSNumber
    @NSManaged var teamMember: String

}
