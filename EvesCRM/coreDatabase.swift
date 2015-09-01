//
//  coreDatabase.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 14/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import CoreData


class coreDatabase: NSObject
{
    
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext 
    
    func getAllOpenProjects(inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "projectName", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!
    }
    
    func getOpenProjectsForArea(inAreaID: Int, inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (areaID != \(inAreaID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!
    }

    
    func getProjectDetails(myProjectID: Int, inTeamID: Int)->[Projects]
    {
        
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(myProjectID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!
    }
    
    
    func getAllProjects(inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!
    }
    
    func getProjectCount()->Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!.count
    }
    
    func getRoles(inTeamID: Int)->[Roles]
    {
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
        
        return fetchResults!
    }
    
    func deleteAllRoles(inTeamID: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Roles")

        let predicate = NSPredicate(format: "(teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
            
         //   managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }
    
    func getMaxRoleID()-> Int
    {
        var retVal: Int = 0
        
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        
        fetchRequest.propertiesToFetch = ["roleID"]
        
        let sortDescriptor = NSSortDescriptor(key: "roleID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
        
        for myItem in fetchResults!
        {
            retVal = myItem.roleID as Int
        }
        
        return retVal + 1
    }
    
    func createRole(inRoleName: String, inTeamID: Int)
    {
        var mySelectedRole: Roles
        var error : NSError?
        
        mySelectedRole = NSEntityDescription.insertNewObjectForEntityForName("Roles", inManagedObjectContext: managedObjectContext!) as! Roles
        
        // Get the role number
        mySelectedRole.roleID = getNextID("Roles")
        mySelectedRole.roleDescription = inRoleName
        mySelectedRole.teamID = inTeamID
        mySelectedRole.updateTime = NSDate()
        mySelectedRole.updateType = "Add"

        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func deleteRoleEntry(inRoleName: String, inTeamID: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        
        let predicate = NSPredicate(format: "(roleDescription == \"\(inRoleName)\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
           // managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }
    
    func saveTeamMember(inProjectID: Int, inRoleID: Int, inPersonName: String, inNotes: String)
    {
        var error: NSError?
        var myProjectTeam: ProjectTeamMembers!
        
        let myProjectTeamRecords = getTeamMemberRecord(inProjectID, inPersonName: inPersonName)
        if myProjectTeamRecords.count == 0
        { // Add
            myProjectTeam = NSEntityDescription.insertNewObjectForEntityForName("ProjectTeamMembers", inManagedObjectContext: self.managedObjectContext!) as! ProjectTeamMembers
            myProjectTeam.projectID = inProjectID
            myProjectTeam.teamMember = inPersonName
            myProjectTeam.roleID = inRoleID
            myProjectTeam.projectMemberNotes = inNotes
            myProjectTeam.updateTime = NSDate()
            myProjectTeam.updateType = "Add"
        }
        else
        { // Update
            myProjectTeam = myProjectTeamRecords[0]
            myProjectTeam.roleID = inRoleID
            myProjectTeam.projectMemberNotes = inNotes
            myProjectTeam.updateTime = NSDate()
            if myProjectTeam.updateType != "Add"
            {
                myProjectTeam.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }

    func deleteTeamMember(inProjectID: Int, inPersonName: String)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) AND (teamMember == \"\(inPersonName)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTeamMembers]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
            // managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }

    func getTeamMemberRecord(inProjectID: Int, inPersonName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) && (teamMember == \"\(inPersonName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    func getTeamMembers(inProjectID: NSNumber)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    func getProjects(inTeamID: Int, inArchiveFlag: Bool = false) -> [Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        if !inArchiveFlag
        {
            var predicate: NSPredicate
        
            predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
        }
        else
        {
            // Create a new predicate that filters out any object that
            // doesn't have a title of "Best Language" exactly.
            let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
        }
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!

    }
    
    func getProjectsForPerson(inPersonName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(teamMember == \"\(inPersonName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    func getRoleDescription(inRoleID: NSNumber, inTeamID: Int)->String
    {
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        let predicate = NSPredicate(format: "(roleID == \(inRoleID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
        
        if fetchResults!.count == 0
        {
            return ""
        }
        else
        {
            return fetchResults![0].roleDescription
        }
    }
    
    func getDecodeValue(inCodeKey: String) -> String
    {
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
        let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Decodes]
        
        if fetchResults!.count == 0
        {
            return ""
        }
        else
        {
            return fetchResults![0].decode_value
        }
    }
    
    func getVisibleDecodes() -> [Decodes]
    {
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
        
        let predicate = NSPredicate(format: "(decodeType != \"hidden\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Decodes]
        
        return fetchResults!
    }
    
    func updateDecodeValue(inCodeKey: String, inCodeValue: String, inCodeType: String)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myDecode: Decodes!
        
        if getDecodeValue(inCodeKey) == ""
        { // Add
            myDecode = NSEntityDescription.insertNewObjectForEntityForName("Decodes", inManagedObjectContext: managedObjectContext!) as! Decodes
            
            myDecode.decode_name = inCodeKey
            myDecode.decode_value = inCodeValue
            myDecode.decodeType = inCodeType
            myDecode.updateTime = NSDate()
            myDecode.updateType = "Add"
        }
        else
        { // Update
            let fetchRequest = NSFetchRequest(entityName: "Decodes")
            let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\") && (updateType != \"Delete\")")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
            
            // Execute the fetch request, and cast the results to an array of  objects
            let myDecodes = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Decodes]
            myDecode = myDecodes![0]
            myDecode.decode_value = inCodeValue
            myDecode.decodeType = inCodeType
            myDecode.updateTime = NSDate()
            if myDecode.updateType != "Add"
            {
                myDecode.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
/*    func deleteDecodeValue(inTeamID: Int)   commented out as does not seem to be correct
    {
        var error : NSError?

        let fetchRequest = NSFetchRequest(entityName: "Decodes")

        let predicate = NSPredicate(format: "(teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Decodes]
    
        for myDecode in fetchResults!
        {
            myDecode.updateTime = NSDate()
            myDecode.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                //   println(error?.localizedDescription)
            }
            
           // managedObjectContext!.deleteObject(myDecode as NSManagedObject)
        }
    }
*/
    func getStages(inTeamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
        
        return fetchResults!
    }
    
    func getVisibleStages(inTeamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
    
        let predicate = NSPredicate(format: "(stageDescription != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
    
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
        
        return fetchResults!
    }
    
    func deleteAllStages(inTeamID: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        let predicate = NSPredicate(format: "(teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        //    managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }

    func stageExists(inStageDesc:String, inTeamID: Int)-> Bool
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(stageDescription == \"\(inStageDesc)\") && (teamID == \(inTeamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
        
        if fetchResults!.count > 0
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func createStage(inStageDesc: String, inTeamID: Int)
    {
        var error: NSError?
        let myStage = NSEntityDescription.insertNewObjectForEntityForName("Stages", inManagedObjectContext: managedObjectContext!) as! Stages
        
        myStage.stageDescription = inStageDesc
        myStage.teamID = inTeamID
        myStage.updateTime = NSDate()
        myStage.updateType = "Add"
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func deleteStageEntry(inStageDesc: String, inTeamID: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        let predicate = NSPredicate(format: "(stageDescription == \"\(inStageDesc)\") && (teamID == \(inTeamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
//            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }
    
    func searchPastAgendaByPartialMeetingIDBeforeStart(inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID contains \"\(inSearchText)\") && (startTime <= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func searchPastAgendaWithoutPartialMeetingIDBeforeStart(inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(teamID == \(inTeamID))  && (updateType != \"Delete\") && (startTime <= %@) && (not meetingID contains \"\(inSearchText)\") ", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }

    func listAgendaReverseDateBeforeStart(inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime <= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func searchPastAgendaByPartialMeetingIDAfterStart(inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID contains \"\(inSearchText)\") && (startTime >= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func searchPastAgendaWithoutPartialMeetingIDAfterStart(inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
 
        predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID)) && NOT (meetingID contains \"\(inSearchText)\") && (startTime >= %@)", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func listAgendaReverseDateAfterStart(inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime >= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func createAgenda(inEvent: myCalendarItem)
    {
        var myAgenda: MeetingAgenda
        var error : NSError?
        
        myAgenda = NSEntityDescription.insertNewObjectForEntityForName("MeetingAgenda", inManagedObjectContext: managedObjectContext!) as! MeetingAgenda
        myAgenda.previousMeetingID = inEvent.previousMinutes
        myAgenda.meetingID = inEvent.eventID
        myAgenda.name = inEvent.title
        myAgenda.chair = inEvent.chair
        myAgenda.minutes = inEvent.minutes
        myAgenda.location = inEvent.location
        myAgenda.startTime = inEvent.startDate
        myAgenda.endTime = inEvent.endDate
        myAgenda.minutesType = inEvent.minutesType
        myAgenda.teamID = inEvent.teamID
        myAgenda.updateTime = NSDate()
        myAgenda.updateType = "Add"
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func loadPreviousAgenda(inMeetingID: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(previousMeetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")

        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func loadAgenda(inMeetingID: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }

    func updateAgenda(inEvent: myCalendarItem)
    {
        var error : NSError?

        let myAgenda = loadAgenda(inEvent.eventID, inTeamID: inEvent.teamID)[0]
        myAgenda.previousMeetingID = inEvent.previousMinutes
        myAgenda.name = inEvent.title
        myAgenda.chair = inEvent.chair
        myAgenda.minutes = inEvent.minutes
        myAgenda.location = inEvent.location
        myAgenda.startTime = inEvent.startDate
        myAgenda.endTime = inEvent.endDate
        myAgenda.minutesType = inEvent.minutesType
        myAgenda.updateTime = NSDate()
        if myAgenda.updateType != "Add"
        {
            myAgenda.updateType = "Update"
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }

    func updatePreviousAgendaID(inPreviousMeetingID: String, inMeetingID: String, inTeamID: Int)
    {
        var error : NSError?
  
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        for myResult in fetchResults!
        {
            myResult.previousMeetingID = inPreviousMeetingID
            myResult.updateTime = NSDate()
            if myResult.updateType != "Add"
            {
                myResult.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func loadAgendaForProject(inProjectName: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name contains \"\(inProjectName)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }
   
    func getAgendaForDateRange(inStartDate: NSDate, inEndDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime >= %@) && (endTime <= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inStartDate, inEndDate)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func loadAttendees(inMeetingID: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAttendees]
        
        return fetchResults!
    }
    
    func loadMeetingsForAttendee(inAttendeeName: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name == \"\(inAttendeeName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAttendees]
        
        return fetchResults!
    }

    func saveAttendee(inMeetingID: String, inAttendees: [meetingAttendee])
    {
        var myPerson: MeetingAttendees
        var error : NSError?
        
        // Before we can add attendees, we first need to clear out the existing entries
        deleteAllAttendees(inMeetingID)
        
        for myAttendee in inAttendees
        {
            myPerson = NSEntityDescription.insertNewObjectForEntityForName("MeetingAttendees", inManagedObjectContext: managedObjectContext!) as! MeetingAttendees
            myPerson.attendenceStatus = myAttendee.status
            myPerson.meetingID = inMeetingID
            myPerson.email = myAttendee.emailAddress
            myPerson.name = myAttendee.name
            myPerson.type = myAttendee.type
            myPerson.updateTime = NSDate()
            myPerson.updateType = "Add"
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
    }

    func deleteAllAttendees(inMeetingID: String)
    {
        var error : NSError?
        
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest(entityName: "MeetingAttendees")
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAttendees]
        
        for myMeeting in fetchResults!
        {
            myMeeting.updateTime = NSDate()
            myMeeting.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
         //   managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
    }
    
    func loadAgendaItem(inMeetingID: String)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgendaItem]
        
        return fetchResults!
    }
    
    func saveAgendaItem(inMeetingID: String, inItem: meetingAgendaItem)
    {
        var mySavedItem: MeetingAgendaItem
        var error : NSError?
        
        mySavedItem = NSEntityDescription.insertNewObjectForEntityForName("MeetingAgendaItem", inManagedObjectContext: managedObjectContext!) as! MeetingAgendaItem
        mySavedItem.meetingID = inMeetingID
        if inItem.actualEndTime != nil
        {
            mySavedItem.actualEndTime = inItem.actualEndTime!
        }
        if inItem.actualStartTime != nil
        {
            mySavedItem.actualStartTime = inItem.actualStartTime!
        }
        mySavedItem.status = inItem.status
        mySavedItem.decisionMade = inItem.decisionMade
        mySavedItem.discussionNotes = inItem.discussionNotes
        mySavedItem.timeAllocation = inItem.timeAllocation
        mySavedItem.owner = inItem.owner
        mySavedItem.title = inItem.title
        mySavedItem.agendaID = inItem.agendaID
        mySavedItem.updateTime = NSDate()
        mySavedItem.updateTime = NSDate()
        mySavedItem.updateType = "Add"

        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

    }
    
    func loadSpecificAgendaItem(inMeetingID: String, inAgendaID: Int)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") AND (agendaID == \(inAgendaID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgendaItem]
        
        return fetchResults!
    }
    
    func updateAgendaItem(inMeetingID: String, inItem: meetingAgendaItem)
    {
        var error : NSError?
        
        let myAgendaItem = loadSpecificAgendaItem(inMeetingID,inAgendaID: inItem.agendaID)[0]
        if inItem.actualEndTime != nil
        {
            myAgendaItem.actualEndTime = inItem.actualEndTime!
        }
        if inItem.actualStartTime != nil
        {
            myAgendaItem.actualStartTime = inItem.actualStartTime!
        }
        myAgendaItem.status = inItem.status
        myAgendaItem.decisionMade = inItem.decisionMade
        myAgendaItem.discussionNotes = inItem.discussionNotes
        myAgendaItem.timeAllocation = inItem.timeAllocation
        myAgendaItem.owner = inItem.owner
        myAgendaItem.title = inItem.title
        myAgendaItem.updateTime = NSDate()
        if myAgendaItem.updateType != "Add"
        {
            myAgendaItem.updateType = "Update"
        }
        
        if (!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

    }

    func deleteAgendaItem(inMeetingID: String, inItem: meetingAgendaItem)
    {
        var error : NSError?
        
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") AND (agendaID == \(inItem.agendaID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgendaItem]
        
        for myMeeting in fetchResults!
        {
            myMeeting.updateTime = NSDate()
            myMeeting.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
           // managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
    }
    
    func deleteAllAgendaItems(inMeetingID: String)
    {
        var error : NSError?
        
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "meetingID == \"\(inMeetingID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgendaItem]
        
        for myMeeting in fetchResults!
        {
            myMeeting.updateTime = NSDate()
            myMeeting.updateType = "Delete"
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }

           // managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
    }

    func saveTask(inTaskID: Int, inTitle: String, inDetails: String, inDueDate: NSDate, inStartDate: NSDate, inStatus: String, inPriority: String, inEnergyLevel: String, inEstimatedTime: Int, inEstimatedTimeType: String, inProjectID: Int, inCompletionDate: NSDate, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inFlagged: Bool, inUrgency: String, inTeamID: Int)
    {
        var error: NSError?
        var myTask: Task!
        
        let myTasks = getTask(inTaskID, inTeamID: inTeamID)
        
        if myTasks.count == 0
        { // Add
            myTask = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: self.managedObjectContext!) as! Task
            myTask.taskID = inTaskID
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = inEstimatedTime
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = inProjectID
            myTask.completionDate = inCompletionDate
            myTask.repeatInterval = inRepeatInterval
            myTask.repeatType = inRepeatType
            myTask.repeatBase = inRepeatBase
            myTask.flagged = inFlagged
            myTask.urgency = inUrgency
            myTask.updateTime = NSDate()
            myTask.updateType = "Add"
            myTask.teamID = inTeamID
        }
        else
        { // Update
            myTask = myTasks[0]
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = inEstimatedTime
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = inProjectID
            myTask.completionDate = inCompletionDate
            myTask.repeatInterval = inRepeatInterval
            myTask.repeatType = inRepeatType
            myTask.repeatBase = inRepeatBase
            myTask.flagged = inFlagged
            myTask.urgency = inUrgency
            myTask.updateTime = NSDate()
            if myTask.updateType != "Add"
            {
                myTask.updateType = "Update"
            }
            myTask.teamID = inTeamID
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteTask(inTaskID: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        let predicate = NSPredicate(format: "taskID == \(inTaskID)")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
//            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }
    
    func getTasks(inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "taskID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!
    }
    
    func getTasksForProject(inProjectID: Int, inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(inProjectID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!
    }

 /*   func getMaxProjectTaskOrder(inProjectID: Int)->Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(parentID == \(inProjectID)) && (parentType == \"Project\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!.count
    }

    func getMaxTaskTaskOrder(inTaskID: Int)->Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(parentID == \(inTaskID)) && (parentType == \"Task\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!.count
    }
  */
    func getTasksWithoutProject(inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == 0) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!
    }
    
    func getTaskWithoutContext(inTeamID: Int)->[Task]
    {
        // Get distinct taskID from context table
        var myContextTasks: [String] = Array()
        var error: NSError?
        
        // first get a list of all tasks that have a context
        
        let fetchContext = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate1 = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchContext.predicate = predicate1

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchContextResults = managedObjectContext!.executeFetchRequest(fetchContext, error: nil) as? [TaskContext]
        
        // Get the list of all current tasks
        let fetchTask = NSFetchRequest(entityName: "Task")
        
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate2 = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\")")
        
        // Set the predicate on the fetch request
        fetchTask.predicate = predicate2
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchTaskResults = managedObjectContext!.executeFetchRequest(fetchTask, error: nil) as? [Task]

        var myTaskArray: [Task] = Array()
        var taskFound: Bool = false
        
        for myTask in fetchTaskResults!
        {
            // loop though the context tasks
            taskFound = false
            for myContext in fetchContextResults!
            {
                if myTask.taskID == myContext.taskID
                {
                    taskFound = true
                    break
                }
            }
            
            if !taskFound
            {
                myTaskArray.append(myTask)
            }
        }
        
        return myTaskArray
    }
    
    func getTask(inTaskID: Int, inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!
    }
    
    func getActiveTask(inTaskID: Int, inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID))  && (status != \"Closed\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!
    }

    func getTaskCount()->Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!.count
    }
    
    func getTaskPredecessors(inTaskID: Int)->[TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskPredecessor")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskPredecessor]
        
        return fetchResults!
    }
   
    func savePredecessorTask(inTaskID: Int, inPredecessorID: Int, inPredecessorType: String)
    {
        var error: NSError?
        var myTask: TaskPredecessor!
        
        let myTasks = getTaskPredecessors(inTaskID)
        
        if myTasks.count == 0
        { // Add
            myTask = NSEntityDescription.insertNewObjectForEntityForName("TaskPredecessor", inManagedObjectContext: self.managedObjectContext!) as! TaskPredecessor
            myTask.taskID = inTaskID
            myTask.predecessorID = inPredecessorID
            myTask.predecessorType = inPredecessorType
            myTask.updateTime = NSDate()
            myTask.updateType = "Add"
        }
        else
        { // Update
            myTask.predecessorID = inPredecessorID
            myTask.predecessorType = inPredecessorType
            myTask.updateTime = NSDate()
            if myTask.updateType != "Add"
            {
                myTask.updateType = "Update"
            }
        }

        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func updatePredecessorTaskType(inTaskID: Int, inPredecessorID: Int, inPredecessorType: String)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (predecessorID == \(inPredecessorID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskPredecessor]
        for myStage in fetchResults!
        {
            myStage.predecessorType = inPredecessorType
            myStage.updateTime = NSDate()
            if myStage.updateType != "Add"
            {
                myStage.updateType = "Update"
            }
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
    }

    func deleteTaskPredecessor(inTaskID: Int, inPredecessorID: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (predecessorID == \(inPredecessorID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskPredecessor]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
            //            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }
    
    func saveProject(inProjectID: Int, inProjectEndDate: NSDate, inProjectName: String, inProjectStartDate: NSDate, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: NSDate, inAreaID: Int, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inTeamID: Int)
    {
        var error: NSError?
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID, inTeamID: inTeamID)
        
        if myProjects.count == 0
        { // Add
            myProject = NSEntityDescription.insertNewObjectForEntityForName("Projects", inManagedObjectContext: self.managedObjectContext!) as! Projects
            myProject.projectID = inProjectID
            myProject.projectEndDate = inProjectEndDate
            myProject.projectName = inProjectName
            myProject.projectStartDate = inProjectStartDate
            myProject.projectStatus = inProjectStatus
            myProject.reviewFrequency = inReviewFrequency
            myProject.lastReviewDate = inLastReviewDate
            myProject.areaID = inAreaID
            myProject.repeatInterval = inRepeatInterval
            myProject.repeatType = inRepeatType
            myProject.repeatBase = inRepeatBase
            myProject.teamID = inTeamID
            myProject.updateTime = NSDate()
            myProject.updateType = "Add"
        }
        else
        { // Update
            myProject = myProjects[0]
            myProject.projectEndDate = inProjectEndDate
            myProject.projectName = inProjectName
            myProject.projectStartDate = inProjectStartDate
            myProject.projectStatus = inProjectStatus
            myProject.reviewFrequency = inReviewFrequency
            myProject.lastReviewDate = inLastReviewDate
            myProject.areaID = inAreaID
            myProject.repeatInterval = inRepeatInterval
            myProject.repeatType = inRepeatType
            myProject.repeatBase = inRepeatBase
            myProject.teamID = inTeamID
            myProject.updateTime = NSDate()
            if myProject.updateType != "Add"
            {
                myProject.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
 
    func deleteProject(inProjectID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID, inTeamID: inTeamID)
        
        if myProjects.count > 0
        { // Update
            myProject = myProjects[0]
            myProject.updateTime = NSDate()
            myProject.updateType = "Delete"
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
        
        var myProjectNote: ProjectNote!
        
        let myTeams = getProjectNote(inProjectID)
        
        if myTeams.count > 0
        { // Update
            myProjectNote = myTeams[0]
            myProjectNote.updateType = "Delete"
            myProjectNote.updateTime = NSDate()
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func saveTaskUpdate(inTaskID: Int, inDetails: String, inSource: String)
    {
        var error: NSError?
        var myTaskUpdate: TaskUpdates!

        myTaskUpdate = NSEntityDescription.insertNewObjectForEntityForName("TaskUpdates", inManagedObjectContext: self.managedObjectContext!) as! TaskUpdates
        myTaskUpdate.taskID = inTaskID
        myTaskUpdate.updateDate = NSDate()
        myTaskUpdate.details = inDetails
        myTaskUpdate.source = inSource
        myTaskUpdate.updateTime = NSDate()
        myTaskUpdate.updateType = "Add"
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }

    func getTaskUpdates(inTaskID: Int)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskUpdates]
        
        return fetchResults!
    }

    func saveContext(inContextID: Int, inName: String, inEmail: String, inAutoEmail: String, inParentContext: Int, inStatus: String, inPersonID: Int32, inTeamID: Int)
    {
        var error: NSError?
        var myContext: Context!
        
        let myContexts = getContextDetails(inContextID, inTeamID: inTeamID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObjectForEntityForName("Context", inManagedObjectContext: self.managedObjectContext!) as! Context
            myContext.contextID = inContextID
            myContext.name = inName
            myContext.email = inEmail
            myContext.autoEmail = inAutoEmail
            myContext.parentContext = inParentContext
            myContext.status = inStatus
            myContext.personID = NSNumber(int: inPersonID)
            myContext.teamID = inTeamID
            myContext.updateTime = NSDate()
            myContext.updateType = "Add"
        }
        else
        {
            myContext = myContexts[0]
            myContext.name = inName
            myContext.email = inEmail
            myContext.autoEmail = inAutoEmail
            myContext.parentContext = inParentContext
            myContext.status = inStatus
            myContext.personID = NSNumber(int: inPersonID)
            myContext.teamID = inTeamID
            myContext.updateTime = NSDate()
            if myContext.updateType != "Add"
            {
                myContext.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteContext(inContextID: Int, inTeamID: Int)
    {
        var error: NSError?
        
        let myContexts = getContextDetails(inContextID, inTeamID: inTeamID)
        
        if myContexts.count > 0
       {
            let myContext = myContexts[0]
            myContext.updateTime = NSDate()
            myContext.updateType = "Delete"
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
        
        let myContexts2 = getContext1_1(inContextID)
        
        if myContexts2.count > 0
        {
            let myContext = myContexts[0]
            myContext.updateTime = NSDate()
            myContext.updateType = "Delete"
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }

    }
    
    func getContexts(inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(status != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context]
        
        return fetchResults!
    }

    func getContextByName(inContextName: String, inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(name = \"\(inContextName)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context]
        
        return fetchResults!
    }
    
    func getContextDetails(inContextID: Int, inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID == \(inContextID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context]
        
        return fetchResults!
    }

    func getAllContexts(inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context]
        
        return fetchResults!
    }
    
    func getContextCount()->Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context]
        
        return fetchResults!.count
    }

    
    func saveTaskContext(inContextID: Int, inTaskID: Int)
    {
        var error: NSError?
        var myContext: TaskContext!
        
        let myContexts = getTaskContext(inContextID, inTaskID: inTaskID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObjectForEntityForName("TaskContext", inManagedObjectContext: self.managedObjectContext!) as! TaskContext
            myContext.contextID = inContextID
            myContext.taskID = inTaskID
            myContext.updateTime = NSDate()
            myContext.updateType = "Add"
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteTaskContext(inContextID: Int, inTaskID: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        let predicate = NSPredicate(format: "(contextID == \(inContextID)) AND (taskID = \(inTaskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskContext]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
          //  managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }

    private func getTaskContext(inContextID: Int, inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) AND (contextID = \(inContextID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskContext]
        
        return fetchResults!
    }

    func getContextsForTask(inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskContext]
        
        return fetchResults!
    }

    func getTasksForContext(inContextID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID = \(inContextID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskContext]
        
        return fetchResults!
    }

    func saveAreaOfResponsibility(inAreaID: Int, inGoalID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: NSDate, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int)
    {
        var error: NSError?
        var myArea: AreaOfResponsibility!
        
        let myAreas = checkAreaOfResponsibility(inAreaID, inTeamID: inTeamID)
        
        if myAreas.count == 0
        { // Add
            myArea = NSEntityDescription.insertNewObjectForEntityForName("AreaOfResponsibility", inManagedObjectContext: self.managedObjectContext!) as! AreaOfResponsibility
            myArea.areaID = inAreaID
            myArea.goalID = inGoalID
            myArea.title = inTitle
            myArea.status = inStatus
            myArea.updateTime = NSDate()
            myArea.updateType = "Add"
            myArea.teamID = inTeamID
            myArea.note = inNote
            myArea.lastReviewDate = inLastReviewDate
            myArea.reviewFrequency = inReviewFrequency
            myArea.reviewPeriod = inReviewPeriod
            myArea.predecessor = inPredecessor
        }
        else
        { // Update
            myArea = myAreas[0]
            myArea.goalID = inGoalID
            myArea.title = inTitle
            myArea.status = inStatus
            myArea.updateTime = NSDate()
            if myArea.updateType != "Add"
            {
                myArea.updateType = "Update"
            }
            myArea.teamID = inTeamID
            myArea.note = inNote
            myArea.lastReviewDate = inLastReviewDate
            myArea.reviewFrequency = inReviewFrequency
            myArea.reviewPeriod = inReviewPeriod
            myArea.predecessor = inPredecessor
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteAreaOfResponsibility(inAreaID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myArea: AreaOfResponsibility!
        
        let myAreas = checkAreaOfResponsibility(inAreaID, inTeamID: inTeamID)
        
        if myAreas.count > 0
        { // Update
            myArea = myAreas[0]
            myArea.updateTime = NSDate()
            myArea.updateType = "Delete"
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getAreaOfResponsibility(inAreaID: Int, inTeamID: Int)->[AreaOfResponsibility]
    {
        let fetchRequest = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(areaID == \(inAreaID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [AreaOfResponsibility]
        
        return fetchResults!
    }
 
    func getAreaCount() -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [AreaOfResponsibility]
        
        return fetchResults!.count
    }
    
    func getOpenAreasForGoal(inGoalID: Int, inTeamID: Int)->[AreaOfResponsibility]
    {
        let fetchRequest = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(goalID == \(inGoalID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [AreaOfResponsibility]
        
        return fetchResults!
    }

    private func checkAreaOfResponsibility(inAreaID: Int, inTeamID: Int)->[AreaOfResponsibility]
    {
        let fetchRequest = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(areaID == \(inAreaID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [AreaOfResponsibility]
        
        return fetchResults!
    }

    func saveAreaProject(inProjectID: Int, inAreaID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID, inTeamID: inTeamID)
        
        if myProjects.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myProject = myProjects[0]
            myProject.areaID = inAreaID
            myProject.updateTime = NSDate()
            if myProject.updateType != "Add"
            {
                myProject.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }

    func deleteAreaProject(inProjectID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID, inTeamID: inTeamID)
        
        if myProjects.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myProject = myProjects[0]
            myProject.areaID = 0
            myProject.updateTime = NSDate()
            if myProject.updateType != "Add"
            {
                myProject.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func saveGoal(inGoalID: Int, inVisionID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: NSDate, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int)
    {
        var error: NSError?
        var myGoal: GoalAndObjective!
        
        let myGoals = getGoals(inGoalID, inTeamID: inTeamID)
        
        if myGoals.count == 0
        { // Add
            myGoal = NSEntityDescription.insertNewObjectForEntityForName("GoalAndObjective", inManagedObjectContext: self.managedObjectContext!) as! GoalAndObjective
            myGoal.goalID = inGoalID
            myGoal.visionID = inVisionID
            myGoal.title = inTitle
            myGoal.status = inStatus
            myGoal.updateTime = NSDate()
            myGoal.updateType = "Add"
            myGoal.teamID = inTeamID
            myGoal.note = inNote
            myGoal.lastReviewDate = inLastReviewDate
            myGoal.reviewFrequency = inReviewFrequency
            myGoal.reviewPeriod = inReviewPeriod
            myGoal.predecessor = inPredecessor
        }
        else
        { // Update
            myGoal = myGoals[0]
            myGoal.visionID = inVisionID
            myGoal.title = inTitle
            myGoal.status = inStatus
            myGoal.updateTime = NSDate()
            if myGoal.updateType != "Add"
            {
                myGoal.updateType = "Update"
            }
            myGoal.teamID = inTeamID
            myGoal.note = inNote
            myGoal.lastReviewDate = inLastReviewDate
            myGoal.reviewFrequency = inReviewFrequency
            myGoal.reviewPeriod = inReviewPeriod
            myGoal.predecessor = inPredecessor
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteGoal(inGoalID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myGoal: GoalAndObjective!
        
        let myGoals = getGoals(inGoalID, inTeamID: inTeamID)
        
        if myGoals.count > 0
        { // Update
            myGoal = myGoals[0]
            myGoal.updateTime = NSDate()
            myGoal.updateType = "Delete"
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getGoals(inGoalID: Int, inTeamID: Int)->[GoalAndObjective]
    {
        let fetchRequest = NSFetchRequest(entityName: "GoalAndObjective")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(goalID == \(inGoalID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [GoalAndObjective]
        
        return fetchResults!
    }
    
    func getGoalCount() -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "GoalAndObjective")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [GoalAndObjective]
        
        return fetchResults!.count
    }
    
    func getOpenGoalsForVision(inVisionID: Int, inTeamID: Int)->[GoalAndObjective]
    {
        let fetchRequest = NSFetchRequest(entityName: "GoalAndObjective")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(visionID == \(inVisionID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [GoalAndObjective]
        
        return fetchResults!
    }
    
    func saveGoalArea(inGoalID: Int, inAreaID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myArea: AreaOfResponsibility!
        
        let myAreas = getAreaOfResponsibility(inAreaID, inTeamID: inTeamID)
        
        if myAreas.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myArea = myAreas[0]
            myArea.goalID = inGoalID
            myArea.updateTime = NSDate()
            if myArea.updateType != "Add"
            {
                myArea.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteGoalArea(inAreaID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myArea: AreaOfResponsibility!
        
        let myAreas = getAreaOfResponsibility(inAreaID, inTeamID: inTeamID)
        
        if myAreas.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myArea = myAreas[0]
            myArea.goalID = 0
            myArea.updateTime = NSDate()
            if myArea.updateType != "Add"
            {
                myArea.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }

    func saveVision(inVisionID: Int, inPurposeID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: NSDate, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int)
    {
        var error: NSError?
        var myVision: Vision!
        
        let myVisions = getVisions(inVisionID, inTeamID: inTeamID)
        
        if myVisions.count == 0
        { // Add
            myVision = NSEntityDescription.insertNewObjectForEntityForName("Vision", inManagedObjectContext: self.managedObjectContext!) as! Vision
            myVision.visionID = inVisionID
            myVision.purposeID = inPurposeID
            myVision.title = inTitle
            myVision.status = inStatus
            myVision.updateTime = NSDate()
            myVision.updateType = "Add"
            myVision.teamID = inTeamID
            myVision.note = inNote
            myVision.lastReviewDate = inLastReviewDate
            myVision.reviewFrequency = inReviewFrequency
            myVision.reviewPeriod = inReviewPeriod
            myVision.predecessor = inPredecessor
        }
        else
        { // Update
            myVision = myVisions[0]
            myVision.purposeID = inPurposeID
            myVision.title = inTitle
            myVision.status = inStatus
            myVision.updateTime = NSDate()
            if myVision.updateType != "Add"
            {
                myVision.updateType = "Update"
            }
            myVision.teamID = inTeamID
            myVision.note = inNote
            myVision.lastReviewDate = inLastReviewDate
            myVision.reviewFrequency = inReviewFrequency
            myVision.reviewPeriod = inReviewPeriod
            myVision.predecessor = inPredecessor
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteVision(inVisionID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myVision: Vision!
        
        let myVisions = getVisions(inVisionID, inTeamID: inTeamID)
        
        if myVisions.count > 0
        { // Update
            myVision = myVisions[0]
            myVision.updateTime = NSDate()
            myVision.updateType = "Delete"
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getVisions(inVisionID: Int, inTeamID: Int)->[Vision]
    {
        let fetchRequest = NSFetchRequest(entityName: "Vision")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(visionID == \(inVisionID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Vision]
        
        return fetchResults!
    }
    
    func getVisionCount() -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Vision")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Vision]
        
        return fetchResults!.count
    }
    
    func getOpenVisionsForPurpose(inPurposeID: Int, inTeamID: Int)->[Vision]
    {
        let fetchRequest = NSFetchRequest(entityName: "Vision")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(purposeID == \(inPurposeID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Vision]
        
        return fetchResults!
    }

    
    func saveVisionGoal(inVisionID: Int, inGoalID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myGoal: GoalAndObjective!
        
        let myGoals = getGoals(inGoalID, inTeamID: inTeamID)
        
        if myGoals.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myGoal = myGoals[0]
            myGoal.visionID = inVisionID
            myGoal.updateTime = NSDate()
            if myGoal.updateType != "Add"
            {
                myGoal.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteVisionGoal(inGoalID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myGoal: GoalAndObjective!
        
        let myGoals = getGoals(inGoalID, inTeamID: inTeamID)
        
        if myGoals.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myGoal = myGoals[0]
            myGoal.visionID = 0
            myGoal.updateTime = NSDate()
            if myGoal.updateType != "Add"
            {
                myGoal.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func savePurpose(inPurposeID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: NSDate, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int)
    {
        var error: NSError?
        var myPurpose: PurposeAndCoreValue!
        
        let myPurposes = getPurpose(inPurposeID, inTeamID: inTeamID)
        
        if myPurposes.count == 0
        { // Add
            myPurpose = NSEntityDescription.insertNewObjectForEntityForName("PurposeAndCoreValue", inManagedObjectContext: self.managedObjectContext!) as! PurposeAndCoreValue
            myPurpose.purposeID = inPurposeID
            myPurpose.title = inTitle
            myPurpose.status = inStatus
            myPurpose.updateTime = NSDate()
            myPurpose.updateType = "Add"
            myPurpose.teamID = inTeamID
            myPurpose.note = inNote
            myPurpose.lastReviewDate = inLastReviewDate
            myPurpose.reviewFrequency = inReviewFrequency
            myPurpose.reviewPeriod = inReviewPeriod
            myPurpose.predecessor = inPredecessor
        }
        else
        { // Update
            myPurpose = myPurposes[0]
            myPurpose.title = inTitle
            myPurpose.status = inStatus
            myPurpose.updateTime = NSDate()
            if myPurpose.updateType != "Add"
            {
                myPurpose.updateType = "Update"
            }
            myPurpose.teamID = inTeamID
            myPurpose.note = inNote
            myPurpose.lastReviewDate = inLastReviewDate
            myPurpose.reviewFrequency = inReviewFrequency
            myPurpose.reviewPeriod = inReviewPeriod
            myPurpose.predecessor = inPredecessor
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deletePurpose(inPurposeID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myPurpose: PurposeAndCoreValue!
        
        let myPurposes = getPurpose(inPurposeID, inTeamID: inTeamID)
        
        if myPurposes.count > 0
        { // Update
            myPurpose = myPurposes[0]
            myPurpose.updateTime = NSDate()
            myPurpose.updateType = "Delete"
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getPurpose(inPurposeID: Int, inTeamID: Int)->[PurposeAndCoreValue]
    {
        let fetchRequest = NSFetchRequest(entityName: "PurposeAndCoreValue")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(purposeID == \(inPurposeID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [PurposeAndCoreValue]
        
        return fetchResults!
    }
    
    func getAllPurpose(inTeamID: Int)->[PurposeAndCoreValue]
    {
        let fetchRequest = NSFetchRequest(entityName: "PurposeAndCoreValue")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [PurposeAndCoreValue]
        
        return fetchResults!
    }

    
    func getPurposeCount()-> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "PurposeAndCoreValue")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects

        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [PurposeAndCoreValue]
        
        return fetchResults!.count
    }
    
    func savePurposeVision(inPurposeID: Int, inVisionID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myVision: Vision!
        
        let myVisions = getVisions(inVisionID, inTeamID: inTeamID)
        
        if myVisions.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myVision = myVisions[0]
            myVision.purposeID = inPurposeID
            myVision.updateTime = NSDate()
            if myVision.updateType != "Add"
            {
                myVision.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deletePurposeVision(inVisionID: Int, inTeamID: Int)
    {
        var error: NSError?
        var myVision: Vision!
        
        let myVisions = getVisions(inVisionID, inTeamID: inTeamID)
        
        if myVisions.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myVision = myVisions[0]
            myVision.purposeID = 0
            myVision.updateTime = NSDate()
            if myVision.updateType != "Add"
            {
                myVision.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }

    func resetprojects()
    {
        var error : NSError?
    
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
    
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTeamMembers]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
            //managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }

        let fetchRequest2 = NSFetchRequest(entityName: "Projects")
            
        // Execute the fetch request, and cast the results to an array of objects
        let fetchResults2 = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [Projects]
        for myStage in fetchResults2!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
          //  managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }

    }
    
    func deleteAllPanes()
    {  // This is used to allow for testing of pane creation, so can delete all the panes if needed
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Panes")

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Panes]
        for myPane in fetchResults!
        {
            myPane.updateTime = NSDate()
            myPane.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
         //   managedObjectContext!.deleteObject(myPane as NSManagedObject)
        }
    }

    func getPanes() -> [Panes]
    {
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
        let sortDescriptor = NSSortDescriptor(key: "pane_name", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(pane_available == true) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Panes]
        
        return fetchResults!
    }

    func getPane(paneName:String) -> [Panes]
    {
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "pane_name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Panes]
        
        return fetchResults!
    }
    
    func togglePaneVisible(paneName: String)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Panes]
        for myPane in fetchResults!
        {
            if myPane.pane_visible == true
            {
                myPane.pane_visible = false
            }
            else
            {
                myPane.pane_visible = true
            }
            
            myPane.updateTime = NSDate()
            if myPane.updateType != "Add"
            {
                myPane.updateType = "Update"
            }

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
    }

    func setPaneOrder(paneName: String, paneOrder: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Panes]
        for myPane in fetchResults!
        {
            myPane.pane_order = paneOrder
            myPane.updateTime = NSDate()
            if myPane.updateType != "Add"
            {
                myPane.updateType = "Update"
            }
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
    }
    
    func savePane(inPaneName:String, inPaneAvailable: Bool, inPaneVisible: Bool, inPaneOrder: Int)
    {
        // Save the details of this pane to the database
        var error: NSError?
        let myPane = NSEntityDescription.insertNewObjectForEntityForName("Panes", inManagedObjectContext: self.managedObjectContext!) as! Panes
        
        myPane.pane_name = inPaneName
        myPane.pane_available = inPaneAvailable
        myPane.pane_visible = inPaneVisible
        myPane.pane_order = inPaneOrder
        myPane.updateTime = NSDate()
        myPane.updateType = "Add"
        
        if !managedObjectContext!.save(&error)
        {
            println(error?.localizedDescription)
        }
    }
    
    func resetMeetings()
    {
        var error : NSError?
        
        let fetchRequest1 = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults1 = managedObjectContext!.executeFetchRequest(fetchRequest1, error: nil) as? [MeetingAgenda]
        
        for myMeeting in fetchResults1!
        {
            myMeeting.updateTime = NSDate()
            myMeeting.updateType = "Delete"
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }

          //  managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
        
        let fetchRequest2 = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [MeetingAttendees]
        
        for myMeeting2 in fetchResults2!
        {
            myMeeting2.updateTime = NSDate()
            myMeeting2.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
           // managedObjectContext!.deleteObject(myMeeting2 as NSManagedObject)
        }
        
        let fetchRequest3 = NSFetchRequest(entityName: "MeetingAgendaItem")

        let fetchResults3 = managedObjectContext!.executeFetchRequest(fetchRequest3, error: nil) as? [MeetingAgendaItem]
        
        for myMeeting3 in fetchResults3!
        {
            myMeeting3.updateTime = NSDate()
            myMeeting3.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
            
           // managedObjectContext!.deleteObject(myMeeting3 as NSManagedObject)
        }
        
        let fetchRequest4 = NSFetchRequest(entityName: "MeetingTasks")
        
        let fetchResults4 = managedObjectContext!.executeFetchRequest(fetchRequest4, error: nil) as? [MeetingTasks]
        
        for myMeeting4 in fetchResults4!
        {
            myMeeting4.updateTime = NSDate()
            myMeeting4.updateType = "Delete"
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
          //  managedObjectContext!.deleteObject(myMeeting4 as NSManagedObject)
        }
        
        let fetchRequest6 = NSFetchRequest(entityName: "MeetingSupportingDocs")
        
        let fetchResults6 = managedObjectContext!.executeFetchRequest(fetchRequest6, error: nil) as? [MeetingSupportingDocs]
        
        for myMeeting6 in fetchResults6!
        {
            myMeeting6.updateTime = NSDate()
            myMeeting6.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
           // managedObjectContext!.deleteObject(myMeeting6 as NSManagedObject)
        }
    }
    
    func resetTasks()
    {
        var error : NSError?
        
        let fetchRequest1 = NSFetchRequest(entityName: "MeetingTasks")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults1 = managedObjectContext!.executeFetchRequest(fetchRequest1, error: nil) as? [MeetingTasks]
        
        for myMeeting in fetchResults1!
        {
            myMeeting.updateTime = NSDate()
            myMeeting.updateType = "Delete"
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
            
           // managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }

        let fetchRequest2 = NSFetchRequest(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [Task]
        
        for myMeeting2 in fetchResults2!
        {
            myMeeting2.updateTime = NSDate()
            myMeeting2.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        //    managedObjectContext!.deleteObject(myMeeting2 as NSManagedObject)
        }
        
        let fetchRequest3 = NSFetchRequest(entityName: "TaskContext")
        
        let fetchResults3 = managedObjectContext!.executeFetchRequest(fetchRequest3, error: nil) as? [TaskContext]
        
        for myMeeting3 in fetchResults3!
        {
            myMeeting3.updateTime = NSDate()
            myMeeting3.updateType = "Delete"
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
           // managedObjectContext!.deleteObject(myMeeting3 as NSManagedObject)
        }
        
        let fetchRequest4 = NSFetchRequest(entityName: "TaskUpdates")
        
        let fetchResults4 = managedObjectContext!.executeFetchRequest(fetchRequest4, error: nil) as? [TaskUpdates]
        
        for myMeeting4 in fetchResults4!
        {
            myMeeting4.updateTime = NSDate()
            myMeeting4.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
//            managedObjectContext!.deleteObject(myMeeting4 as NSManagedObject)
        }
    }

    func getAgendaTasks(inMeetingID: String, inAgendaID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) AND (meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func getMeetingsTasks(inMeetingID: String)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func saveAgendaTask(inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        var myTask: MeetingTasks
        var error : NSError?
        
        myTask = NSEntityDescription.insertNewObjectForEntityForName("MeetingTasks", inManagedObjectContext: managedObjectContext!) as! MeetingTasks
        myTask.agendaID = inAgendaID
        myTask.meetingID = inMeetingID
        myTask.taskID = inTaskID
        myTask.updateTime = NSDate()
        myTask.updateType = "Add"
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }

    func deleteAgendaTask(inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) AND (meetingID == \"\(inMeetingID)\") AND (taskID == \(inTaskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingTasks]
        
        for myItem in fetchResults!
        {
            myItem.updateTime = NSDate()
            myItem.updateType = "Delete"
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        //    managedObjectContext!.deleteObject(myItem as NSManagedObject)
        }
    }
    
    func getAgendaTask(inAgendaID: Int, inMeetingID: String, inTaskID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) && (meetingID == \"\(inMeetingID)\") && (taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func resetContexts()
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
                // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context]
        
        for myItem in fetchResults!
        {
            myItem.updateTime = NSDate()
            myItem.updateType = "Delete"
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
           // managedObjectContext!.deleteObject(myItem as NSManagedObject)
        }

        let fetchRequest2 = NSFetchRequest(entityName: "TaskContext")
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults2 = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [TaskContext]
        for myItem2 in fetchResults2!
        {
            myItem2.updateTime = NSDate()
            myItem2.updateType = "Delete"

            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
          //  managedObjectContext!.deleteObject(myItem2 as NSManagedObject)
        }
    }
    
    func clearDeletedItems()
    {
        var error : NSError?
        
        let fetchRequest1 = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        let predicate = NSPredicate(format: "(updateType == \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest1.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults1 = managedObjectContext!.executeFetchRequest(fetchRequest1, error: nil) as? [AreaOfResponsibility]
        
        for myItem1 in fetchResults1!
        {
            managedObjectContext!.deleteObject(myItem1 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest2 = NSFetchRequest(entityName: "Context")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [Context]
        
        for myItem2 in fetchResults2!
        {
            managedObjectContext!.deleteObject(myItem2 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest3 = NSFetchRequest(entityName: "Decodes")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults3 = managedObjectContext!.executeFetchRequest(fetchRequest3, error: nil) as? [Decodes]
        
        for myItem3 in fetchResults3!
        {
            managedObjectContext!.deleteObject(myItem3 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest4 = NSFetchRequest(entityName: "GoalAndObjective")
        
        // Set the predicate on the fetch request
        fetchRequest4.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults4 = managedObjectContext!.executeFetchRequest(fetchRequest4, error: nil) as? [GoalAndObjective]
        
        for myItem4 in fetchResults4!
        {
            managedObjectContext!.deleteObject(myItem4 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest5 = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Set the predicate on the fetch request
        fetchRequest5.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults5 = managedObjectContext!.executeFetchRequest(fetchRequest5, error: nil) as? [MeetingAgenda]
        
        for myItem5 in fetchResults5!
        {
            managedObjectContext!.deleteObject(myItem5 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest6 = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Set the predicate on the fetch request
        fetchRequest6.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults6 = managedObjectContext!.executeFetchRequest(fetchRequest6, error: nil) as? [MeetingAgendaItem]
        
        for myItem6 in fetchResults6!
        {
            managedObjectContext!.deleteObject(myItem6 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest7 = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Set the predicate on the fetch request
        fetchRequest7.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults7 = managedObjectContext!.executeFetchRequest(fetchRequest7, error: nil) as? [MeetingAttendees]
        
        for myItem7 in fetchResults7!
        {
            managedObjectContext!.deleteObject(myItem7 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest8 = NSFetchRequest(entityName: "MeetingSupportingDocs")
        
        // Set the predicate on the fetch request
        fetchRequest8.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults8 = managedObjectContext!.executeFetchRequest(fetchRequest8, error: nil) as? [MeetingSupportingDocs]
        
        for myItem8 in fetchResults8!
        {
            managedObjectContext!.deleteObject(myItem8 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest9 = NSFetchRequest(entityName: "MeetingTasks")
        
        // Set the predicate on the fetch request
        fetchRequest9.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults9 = managedObjectContext!.executeFetchRequest(fetchRequest9, error: nil) as? [MeetingTasks]
        
        for myItem9 in fetchResults9!
        {
            managedObjectContext!.deleteObject(myItem9 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest10 = NSFetchRequest(entityName: "Panes")
        
        // Set the predicate on the fetch request
        fetchRequest10.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults10 = managedObjectContext!.executeFetchRequest(fetchRequest10, error: nil) as? [Panes]
        
        for myItem10 in fetchResults10!
        {
            managedObjectContext!.deleteObject(myItem10 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest11 = NSFetchRequest(entityName: "Projects")
        
        // Set the predicate on the fetch request
        fetchRequest11.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults11 = managedObjectContext!.executeFetchRequest(fetchRequest11, error: nil) as? [Projects]
        
        for myItem11 in fetchResults11!
        {
            managedObjectContext!.deleteObject(myItem11 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest12 = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Set the predicate on the fetch request
        fetchRequest12.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults12 = managedObjectContext!.executeFetchRequest(fetchRequest12, error: nil) as? [ProjectTeamMembers]
        
        for myItem12 in fetchResults12!
        {
            managedObjectContext!.deleteObject(myItem12 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest13 = NSFetchRequest(entityName: "PurposeAndCoreValue")
        
        // Set the predicate on the fetch request
        fetchRequest13.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults13 = managedObjectContext!.executeFetchRequest(fetchRequest13, error: nil) as? [PurposeAndCoreValue]
        
        for myItem13 in fetchResults13!
        {
            managedObjectContext!.deleteObject(myItem13 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest14 = NSFetchRequest(entityName: "Roles")
        
        // Set the predicate on the fetch request
        fetchRequest14.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults14 = managedObjectContext!.executeFetchRequest(fetchRequest14, error: nil) as? [Roles]
        
        for myItem14 in fetchResults14!
        {
            managedObjectContext!.deleteObject(myItem14 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest15 = NSFetchRequest(entityName: "Stages")
        
        // Set the predicate on the fetch request
        fetchRequest15.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults15 = managedObjectContext!.executeFetchRequest(fetchRequest15, error: nil) as? [Stages]
        
        for myItem15 in fetchResults15!
        {
            managedObjectContext!.deleteObject(myItem15 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest16 = NSFetchRequest(entityName: "Task")
        
        // Set the predicate on the fetch request
        fetchRequest16.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults16 = managedObjectContext!.executeFetchRequest(fetchRequest16, error: nil) as? [Task]
        
        for myItem16 in fetchResults16!
        {
            managedObjectContext!.deleteObject(myItem16 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest17 = NSFetchRequest(entityName: "TaskAttachment")
        
        // Set the predicate on the fetch request
        fetchRequest17.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults17 = managedObjectContext!.executeFetchRequest(fetchRequest17, error: nil) as? [TaskAttachment]
        
        for myItem17 in fetchResults17!
        {
            managedObjectContext!.deleteObject(myItem17 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest18 = NSFetchRequest(entityName: "TaskContext")
        
        // Set the predicate on the fetch request
        fetchRequest18.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults18 = managedObjectContext!.executeFetchRequest(fetchRequest18, error: nil) as? [TaskContext]
        
        for myItem18 in fetchResults18!
        {
            managedObjectContext!.deleteObject(myItem18 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest19 = NSFetchRequest(entityName: "TaskUpdates")
        
        // Set the predicate on the fetch request
        fetchRequest19.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults19 = managedObjectContext!.executeFetchRequest(fetchRequest19, error: nil) as? [TaskUpdates]
        
        for myItem19 in fetchResults19!
        {
            managedObjectContext!.deleteObject(myItem19 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest20 = NSFetchRequest(entityName: "Vision")
        
        // Set the predicate on the fetch request
        fetchRequest20.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults20 = managedObjectContext!.executeFetchRequest(fetchRequest20, error: nil) as? [Vision]
        
        for myItem20 in fetchResults20!
        {
            managedObjectContext!.deleteObject(myItem20 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
        
        let fetchRequest21 = NSFetchRequest(entityName: "TaskPredecessor")
        
        // Set the predicate on the fetch request
        fetchRequest21.predicate = predicate
        let fetchResults21 = managedObjectContext!.executeFetchRequest(fetchRequest21, error: nil) as? [TaskPredecessor]
        
        for myItem21 in fetchResults21!
        {
            managedObjectContext!.deleteObject(myItem21 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
        
        let fetchRequest22 = NSFetchRequest(entityName: "Team")
        
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        let fetchResults22 = managedObjectContext!.executeFetchRequest(fetchRequest22, error: nil) as? [Team]
        
        for myItem22 in fetchResults22!
        {
            managedObjectContext!.deleteObject(myItem22 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest23 = NSFetchRequest(entityName: "ProjectNote")
        
        // Set the predicate on the fetch request
        fetchRequest23.predicate = predicate
        let fetchResults23 = managedObjectContext!.executeFetchRequest(fetchRequest23, error: nil) as? [ProjectNote]
        
        for myItem23 in fetchResults23!
        {
            managedObjectContext!.deleteObject(myItem23 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
        
        let fetchRequest24 = NSFetchRequest(entityName: "Context1_1")
        
        // Set the predicate on the fetch request
        fetchRequest24.predicate = predicate
        let fetchResults24 = managedObjectContext!.executeFetchRequest(fetchRequest24, error: nil) as? [Context1_1]
        
        for myItem24 in fetchResults24!
        {
            managedObjectContext!.deleteObject(myItem24 as NSManagedObject)
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

    }

    func clearSyncedItems()
    {
        var error : NSError?
        
        let fetchRequest1 = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        let predicate = NSPredicate(format: "(updateType != \"\")")
        
        // Set the predicate on the fetch request
        fetchRequest1.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults1 = managedObjectContext!.executeFetchRequest(fetchRequest1, error: nil) as? [AreaOfResponsibility]
        
        for myItem1 in fetchResults1!
        {
            myItem1.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest2 = NSFetchRequest(entityName: "Context")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [Context]
        
        for myItem2 in fetchResults2!
        {
            myItem2.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest3 = NSFetchRequest(entityName: "Decodes")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults3 = managedObjectContext!.executeFetchRequest(fetchRequest3, error: nil) as? [Decodes]
        
        for myItem3 in fetchResults3!
        {
            myItem3.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest4 = NSFetchRequest(entityName: "GoalAndObjective")
        
        // Set the predicate on the fetch request
        fetchRequest4.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults4 = managedObjectContext!.executeFetchRequest(fetchRequest4, error: nil) as? [GoalAndObjective]
        
        for myItem4 in fetchResults4!
        {
            myItem4.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest5 = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Set the predicate on the fetch request
        fetchRequest5.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults5 = managedObjectContext!.executeFetchRequest(fetchRequest5, error: nil) as? [MeetingAgenda]
        
        for myItem5 in fetchResults5!
        {
            myItem5.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest6 = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Set the predicate on the fetch request
        fetchRequest6.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults6 = managedObjectContext!.executeFetchRequest(fetchRequest6, error: nil) as? [MeetingAgendaItem]
        
        for myItem6 in fetchResults6!
        {
            myItem6.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
       
        let fetchRequest7 = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Set the predicate on the fetch request
        fetchRequest7.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults7 = managedObjectContext!.executeFetchRequest(fetchRequest7, error: nil) as? [MeetingAttendees]
        
        for myItem7 in fetchResults7!
        {
            myItem7.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest8 = NSFetchRequest(entityName: "MeetingSupportingDocs")
        
        // Set the predicate on the fetch request
        fetchRequest8.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults8 = managedObjectContext!.executeFetchRequest(fetchRequest8, error: nil) as? [MeetingSupportingDocs]
        
        for myItem8 in fetchResults8!
        {
            myItem8.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest9 = NSFetchRequest(entityName: "MeetingTasks")
        
        // Set the predicate on the fetch request
        fetchRequest9.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults9 = managedObjectContext!.executeFetchRequest(fetchRequest9, error: nil) as? [MeetingTasks]
        
        for myItem9 in fetchResults9!
        {
            myItem9.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest10 = NSFetchRequest(entityName: "Panes")
        
        // Set the predicate on the fetch request
        fetchRequest10.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults10 = managedObjectContext!.executeFetchRequest(fetchRequest10, error: nil) as? [Panes]
        
        for myItem10 in fetchResults10!
        {
            myItem10.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest11 = NSFetchRequest(entityName: "Projects")
        
        // Set the predicate on the fetch request
        fetchRequest11.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults11 = managedObjectContext!.executeFetchRequest(fetchRequest11, error: nil) as? [Projects]
        
        for myItem11 in fetchResults11!
        {
            myItem11.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest12 = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Set the predicate on the fetch request
        fetchRequest12.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults12 = managedObjectContext!.executeFetchRequest(fetchRequest12, error: nil) as? [ProjectTeamMembers]
        
        for myItem12 in fetchResults12!
        {
            myItem12.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest13 = NSFetchRequest(entityName: "PurposeAndCoreValue")
        
        // Set the predicate on the fetch request
        fetchRequest13.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults13 = managedObjectContext!.executeFetchRequest(fetchRequest13, error: nil) as? [PurposeAndCoreValue]
        
        for myItem13 in fetchResults13!
        {
            myItem13.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }

        let fetchRequest14 = NSFetchRequest(entityName: "Roles")
        
        // Set the predicate on the fetch request
        fetchRequest14.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults14 = managedObjectContext!.executeFetchRequest(fetchRequest14, error: nil) as? [Roles]
        
        for myItem14 in fetchResults14!
        {
            myItem14.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest15 = NSFetchRequest(entityName: "Stages")
        
        // Set the predicate on the fetch request
        fetchRequest15.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults15 = managedObjectContext!.executeFetchRequest(fetchRequest15, error: nil) as? [Stages]
        
        for myItem15 in fetchResults15!
        {
            myItem15.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest16 = NSFetchRequest(entityName: "Task")
        
        // Set the predicate on the fetch request
        fetchRequest16.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults16 = managedObjectContext!.executeFetchRequest(fetchRequest16, error: nil) as? [Task]
        
        for myItem16 in fetchResults16!
        {
            myItem16.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest17 = NSFetchRequest(entityName: "TaskAttachment")
        
        // Set the predicate on the fetch request
        fetchRequest17.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults17 = managedObjectContext!.executeFetchRequest(fetchRequest17, error: nil) as? [TaskAttachment]
        
        for myItem17 in fetchResults17!
        {
            myItem17.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest18 = NSFetchRequest(entityName: "TaskContext")
        
        // Set the predicate on the fetch request
        fetchRequest18.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults18 = managedObjectContext!.executeFetchRequest(fetchRequest18, error: nil) as? [TaskContext]
        
        for myItem18 in fetchResults18!
        {
            myItem18.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest19 = NSFetchRequest(entityName: "TaskUpdates")
        
        // Set the predicate on the fetch request
        fetchRequest19.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults19 = managedObjectContext!.executeFetchRequest(fetchRequest19, error: nil) as? [TaskUpdates]
        
        for myItem19 in fetchResults19!
        {
            myItem19.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest20 = NSFetchRequest(entityName: "Vision")
        
        // Set the predicate on the fetch request
        fetchRequest20.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults20 = managedObjectContext!.executeFetchRequest(fetchRequest20, error: nil) as? [Vision]
        
        for myItem20 in fetchResults20!
        {
            myItem20.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest21 = NSFetchRequest(entityName: "TaskPredecessor")
        
        // Set the predicate on the fetch request
        fetchRequest21.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults21 = managedObjectContext!.executeFetchRequest(fetchRequest21, error: nil) as? [TaskPredecessor]
        
        for myItem21 in fetchResults21!
        {
            myItem21.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest22 = NSFetchRequest(entityName: "Team")
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults22 = managedObjectContext!.executeFetchRequest(fetchRequest22, error: nil) as? [Team]
        
        for myItem22 in fetchResults22!
        {
            myItem22.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }

        let fetchRequest23 = NSFetchRequest(entityName: "ProjectNote")
        // Set the predicate on the fetch request
        fetchRequest23.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults23 = managedObjectContext!.executeFetchRequest(fetchRequest23, error: nil) as? [ProjectNote]
        
        for myItem23 in fetchResults23!
        {
            myItem23.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
        
        let fetchRequest24 = NSFetchRequest(entityName: "Context1_1")
        // Set the predicate on the fetch request
        fetchRequest24.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults24 = managedObjectContext!.executeFetchRequest(fetchRequest24, error: nil) as? [Context1_1]
        
        for myItem24 in fetchResults24!
        {
            myItem24.updateType = ""
            
            if(!managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
    }
    
    func saveTeam(inTeamID: Int, inName: String, inStatus: String, inNote: String, inType: String, inPredecessor: Int, inExternalID: Int)
    {
        var error: NSError?
        var myTeam: Team!
        
        let myTeams = getTeam(inTeamID)
        
        if myTeams.count == 0
        { // Add
            myTeam = NSEntityDescription.insertNewObjectForEntityForName("Team", inManagedObjectContext: self.managedObjectContext!) as! Team
            myTeam.teamID = inTeamID
            myTeam.name = inName
            myTeam.status = inStatus
            myTeam.note = inNote
            myTeam.type = inType
            myTeam.updateTime = NSDate()
            myTeam.updateType = "Add"
            myTeam.predecessor = inPredecessor
            myTeam.externalID = inExternalID
        }
        else
        { // Update
            myTeam = myTeams[0]
            myTeam.name = inName
            myTeam.status = inStatus
            myTeam.note = inNote
            myTeam.type = inType
            
            if myTeam.updateType != "Add"
            {
                myTeam.updateType = "Update"
            }
            myTeam.updateTime = NSDate()
            myTeam.predecessor = inPredecessor
            myTeam.externalID = inExternalID
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getTeam(inTeamID: Int)->[Team]
    {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Team]
        
        return fetchResults!
    }
    
    func getAllTeams()->[Team]
    {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Team]
    
        return fetchResults!
    }
    
    func getTeamsCount() -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Team]
        
        return fetchResults!.count
    }

    
    func saveProjectNote(inProjectID: Int, inNote: String, inReviewPeriod: String, inPredecessor: Int)
    {
        var error: NSError?
        var myProjectNote: ProjectNote!
        
        let myTeams = getProjectNote(inProjectID)
        
        if myTeams.count == 0
        { // Add
            myProjectNote = NSEntityDescription.insertNewObjectForEntityForName("ProjectNote", inManagedObjectContext: self.managedObjectContext!) as! ProjectNote
            myProjectNote.projectID = inProjectID
            myProjectNote.note = inNote
            myProjectNote.updateTime = NSDate()
            myProjectNote.updateType = "Add"
            myProjectNote.reviewPeriod = inReviewPeriod
            myProjectNote.predecessor = inPredecessor
        }
        else
        { // Update
            myProjectNote = myTeams[0]
            myProjectNote.note = inNote
            
            if myProjectNote.updateType != "Add"
            {
                myProjectNote.updateType = "Update"
            }
            myProjectNote.updateTime = NSDate()
            myProjectNote.reviewPeriod = inReviewPeriod
            myProjectNote.predecessor = inPredecessor
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getProjectNote(inProjectID: Int)->[ProjectNote]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectNote")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (projectID == \(inProjectID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectNote]
        
        return fetchResults!
    }

    func getNextID(inTableName: String, inInitialValue: Int = 1) -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
        let predicate = NSPredicate(format: "(decode_name == \"\(inTableName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Decodes]
        
        if fetchResults!.count == 0
        {
            // Create table entry
            let storeKey = "\(inInitialValue)"
            updateDecodeValue(inTableName, inCodeValue: storeKey, inCodeType: "hidden")
println("key = \(inTableName)  value = \(storeKey)")
            return inInitialValue
        }
        else
        {
            // Increment table value by 1 and save back to database
            let storeint = fetchResults![0].decode_value.toInt()! + 1
            
            let storeKey = "\(storeint)"
            updateDecodeValue(inTableName, inCodeValue: storeKey, inCodeType: "hidden")
    println("key = \(inTableName)  value = \(storeKey)")
            return storeint
        }
    }
    
    func initialiseTeamForMeetingAgenda(inTeamID: Int)
    {
        var error: NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
            }
            
            if(!managedObjectContext!.save(&error) )
            {
                //   println(error?.localizedDescription)
            }
        }
    }

    func initialiseTeamForContext(inTeamID: Int)
    {
        var error: NSError?
        
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        let sortDescriptor = NSSortDescriptor(key: "contextID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
                maxID = myItem.contextID as Int
            }
        
            if(!managedObjectContext!.save(&error) )
            {
                //   println(error?.localizedDescription)
            }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Context", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func initialiseTeamForProject(inTeamID: Int)
    {
        var error: NSError?
        
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        let sortDescriptor = NSSortDescriptor(key: "projectID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
                maxID = myItem.projectID as Int
            }
            
            if(!managedObjectContext!.save(&error) )
            {
                //   println(error?.localizedDescription)
            }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Projects", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func initialiseTeamForRoles(inTeamID: Int)
    {
        var error: NSError?
        
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        
        let sortDescriptor = NSSortDescriptor(key: "roleID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
                maxID = myItem.roleID as Int
            }
            
            if(!managedObjectContext!.save(&error) )
            {
                //   println(error?.localizedDescription)
            }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Roles", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func initialiseTeamForStages(inTeamID: Int)
    {
        var error: NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
            }
            
            if(!managedObjectContext!.save(&error) )
            {
                //   println(error?.localizedDescription)
            }
        }
    }

    func initialiseTeamForTask(inTeamID: Int)
    {
        var error: NSError?
        
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        let sortDescriptor = NSSortDescriptor(key: "taskID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
                maxID = myItem.taskID as Int
            }
            
            if(!managedObjectContext!.save(&error) )
            {
                //   println(error?.localizedDescription)
            }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Task", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func saveContext1_1(inContextID: Int, inPredecessor: Int)
    {
        var error: NSError?
        var myContext: Context1_1!
        
        let myContexts = getContext1_1(inContextID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObjectForEntityForName("Context", inManagedObjectContext: self.managedObjectContext!) as! Context1_1
            myContext.contextID = inContextID
            myContext.predecessor = inPredecessor
            myContext.updateTime = NSDate()
            myContext.updateType = "Add"
        }
        else
        {
            myContext = myContexts[0]
            myContext.predecessor = inPredecessor
            myContext.updateTime = NSDate()
            if myContext.updateType != "Add"
            {
                myContext.updateType = "Update"
            }
        }
        
        if(!managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getContext1_1(inContextID: Int)->[Context1_1]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context1_1")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (contextID == \(inContextID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "contextID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context1_1]
        
        return fetchResults!
    }
    
    
}
