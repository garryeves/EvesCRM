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

    func getAllOpenProjects()->[Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "projectStatus != \"Archived\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "projectName", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!
    }
    
    func getOpenProjectsForArea(inAreaID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") AND (areaID != \(inAreaID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!
    }

    
    func getProjectDetails(myProjectID: Int)->[Projects]
    {
        
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "projectID == \(myProjectID)")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!
    }
    
    
    func getAllProjects()->[Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Execute the fetch request, and cast the results to an array of objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!
    }
    
    func getRoles()->[Roles]
    {
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
        
        return fetchResults!
    }
    
    func deleteAllRoles()
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
        for myStage in fetchResults!
        {
            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
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
    
    func createRole(inRoleName: String)
    {
        var mySelectedRole: Roles
        var error : NSError?
        
        mySelectedRole = NSEntityDescription.insertNewObjectForEntityForName("Roles", inManagedObjectContext: managedObjectContext!) as! Roles
        mySelectedRole.roleID = getMaxRoleID()
        mySelectedRole.roleDescription = inRoleName
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func deleteRoleEntry(inRoleName: String)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        
        let predicate = NSPredicate(format: "roleDescription == \"\(inRoleName)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
        for myStage in fetchResults!
        {
            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func saveTeamMember(inProjectID: Int, inRoleID: Int, inPersonName: String, inNotes: String)
    {
        // first check to see if decode exists, if not we create
        
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
        }
        else
        { // Update
            myProjectTeam = myProjectTeamRecords[0]
            myProjectTeam.roleID = inRoleID
            myProjectTeam.projectMemberNotes = inNotes
        }
        
        if(managedObjectContext!.save(&error) )
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
            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }

    func getTeamMemberRecord(inProjectID: Int, inPersonName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) AND (teamMember == \"\(inPersonName)\")")
        
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
        let predicate = NSPredicate(format: "projectID == \(inProjectID)")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    func getProjects(inArchiveFlag: Bool = false) -> [Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        if !inArchiveFlag
        {
            var predicate: NSPredicate
        
            predicate = NSPredicate(format: "projectStatus != \"Archived\"")
        
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
        
        predicate = NSPredicate(format: "teamMember == \"\(inPersonName)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    
    func getRoleDescription(inRoleID: NSNumber)->String
    {
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        let predicate = NSPredicate(format: "roleID == \(inRoleID)")
        
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
    
    func getDecodeValue(inCodeType: String) -> String
    {
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
        let predicate = NSPredicate(format: "decode_name == \"\(inCodeType)\"")
        
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
    
    func updateDecodeValue(inCodeType: String, inCodeValue: String)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myDecode: Decodes!
        
        if getDecodeValue(inCodeType) == ""
        { // Add
            myDecode = NSEntityDescription.insertNewObjectForEntityForName("Decodes", inManagedObjectContext: managedObjectContext!) as! Decodes
            
            myDecode.decode_name = inCodeType
            myDecode.decode_value = inCodeValue
        }
        else
        { // Update
            let fetchRequest = NSFetchRequest(entityName: "Decodes")
            let predicate = NSPredicate(format: "decode_name == \"\(inCodeType)\"")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
            
            // Execute the fetch request, and cast the results to an array of  objects
            let myDecodes = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Decodes]
            myDecode = myDecodes![0]
            myDecode.decode_value = inCodeValue
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getStages()->[Stages]
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
        
        return fetchResults!
    }
    
    func deleteAllStages()
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
        for myStage in fetchResults!
        {
            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }

    func stageExists(inStageDesc:String)-> Bool
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "stageDescription == \"\(inStageDesc)\"")
        
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
    
    func createStage(inStageDesc: String)
    {
        // Save the details of this pane to the database
        var error: NSError?
        let myStage = NSEntityDescription.insertNewObjectForEntityForName("Stages", inManagedObjectContext: managedObjectContext!) as! Stages
        
        myStage.stageDescription = inStageDesc
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func deleteStageEntry(inStageDesc: String)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        let predicate = NSPredicate(format: "stageDescription == \"\(inStageDesc)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
        for myStage in fetchResults!
        {
            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
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
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func loadAgenda(inMeetingID: String)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "meetingID == \"\(inMeetingID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgenda]
        
        return fetchResults!
    }

    func updateAgenda(inEvent: myCalendarItem)
    {
        var error : NSError?
        
        let myAgenda = loadAgenda(inEvent.eventID)[0]
        myAgenda.previousMeetingID = inEvent.previousMinutes
        myAgenda.name = inEvent.title
        myAgenda.chair = inEvent.chair
        myAgenda.minutes = inEvent.minutes
        myAgenda.location = inEvent.location
        myAgenda.startTime = inEvent.startDate
        myAgenda.endTime = inEvent.endDate
        myAgenda.minutesType = inEvent.minutesType
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }

    func loadAttendees(inMeetingID: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "meetingID == \"\(inMeetingID)\"")
        
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
            
            if(managedObjectContext!.save(&error) )
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
        predicate = NSPredicate(format: "meetingID == \"\(inMeetingID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAttendees]
        
        for myMeeting in fetchResults!
        {
            managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func loadAgendaItem(inMeetingID: String)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "meetingID == \"\(inMeetingID)\"")
        
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

        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

    }
    
    func loadSpecificAgendaItem(inMeetingID: String, inAgendaID: String)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") AND (agendaID = \"\(inAgendaID)\")")
        
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
        
        if (managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

    }

    func deleteAgendaItem(inMeetingID: String, inItem: meetingAgendaItem)
    {
        var error : NSError?
        
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") AND (agendaID = \"\(inItem.agendaID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingAgendaItem]
        
        for myMeeting in fetchResults!
        {
            managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
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
            managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }

    func saveTask(inTaskID: Int, inTitle: String, inDetails: String, inDueDate: NSDate, inStartDate: NSDate, inStatus: String, inParentID: Int, inParentType: String,inTaskMode: String, inTaskOrder: Int, inPriority: String, inEnergyLevel: String, inEstimatedTime: Int, inEstimatedTimeType: String, inProjectID: Int)
    {
        // first check to see if decode exists, if not we create
        var error: NSError?
        var myTask: Task!
        
        let myTasks = getTask(inTaskID)
        
        if myTasks.count == 0
        { // Add
            myTask = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: self.managedObjectContext!) as! Task
            myTask.taskID = inTaskID
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.parentID = inParentID
            myTask.parentType = inParentType
            myTask.taskMode = inTaskMode
            myTask.taskOrder = inTaskOrder
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = inEstimatedTime
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = inProjectID
        }
        else
        { // Update
            myTask = myTasks[0]
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.parentID = inParentID
            myTask.parentType = inParentType
            myTask.taskMode = inTaskMode
            myTask.taskOrder = inTaskOrder
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = inEstimatedTime
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = inProjectID
        }
        
        if(managedObjectContext!.save(&error) )
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
            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func getTasks(inParentID: Int, inParentType: String)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "parentID == \(inParentID) AND (parentType = \"\(inParentType)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "parentID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!
    }

    
    func getMaxProjectTaskOrder(inProjectID: Int)->Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(parentID == \(inProjectID)) AND (parentType == \"Project\")")
        
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
        let predicate = NSPredicate(format: "(parentID == \(inTaskID)) AND (parentType == \"Task\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!.count
    }
    
    func getTasksWithoutProject()->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(parentID == 0) AND (parentType == \"Project\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!
    }
    
    func getTaskWithoutContext()->[Task]
    {
        // Get distinct taskID from context table
        var myContextTasks: [String] = Array()
        var error: NSError?
        
        // first get a list of all tasks that have a context
        
        let fetchContext = NSFetchRequest(entityName: "TaskContext")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchContextResults = managedObjectContext!.executeFetchRequest(fetchContext, error: nil) as? [TaskContext]
        
        // Get the list of all current tasks
        let fetchTask = NSFetchRequest(entityName: "Task")
        
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
    
    func getTask(inTaskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "taskID == \(inTaskID)")
        
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
    
    func saveProject(inProjectID: Int, inProjectEndDate: NSDate, inProjectName: String, inProjectStartDate: NSDate, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: NSDate, inAreaID: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID)
        
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
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
 
    func saveTaskUpdate(inTaskID: Int, inDetails: String, inSource: String)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myTaskUpdate: TaskUpdates!

        myTaskUpdate = NSEntityDescription.insertNewObjectForEntityForName("TaskUpdates", inManagedObjectContext: self.managedObjectContext!) as! TaskUpdates
        myTaskUpdate.taskID = inTaskID
        myTaskUpdate.updateDate = NSDate()
        myTaskUpdate.details = inDetails
        myTaskUpdate.source = inSource
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getTaskUpdates(inTaskID: Int)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskUpdates]
        
        return fetchResults!
    }

    func saveContext(inContextID: Int, inName: String, inEmail: String, inAutoEmail: String, inParentContext: Int, inStatus: String)
    {
        // first check to see if decode exists, if not we create

        var error: NSError?
        var myContext: Context!
        
        let myContexts = getContextDetails(inContextID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObjectForEntityForName("Context", inManagedObjectContext: self.managedObjectContext!) as! Context
            myContext.contextID = inContextID
            myContext.name = inName
            myContext.email = inEmail
            myContext.autoEmail = inAutoEmail
            myContext.parentContext = inParentContext
            myContext.status = inStatus
        }
        else
        {
            myContext = myContexts[0]
            myContext.name = inName
            myContext.email = inEmail
            myContext.autoEmail = inAutoEmail
            myContext.parentContext = inParentContext
            myContext.status = inStatus
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
        
    func getContexts()->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(status != \"Archived\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context]
        
        return fetchResults!
    }

    func getContextDetails(inContextID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID == \(inContextID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context]
        
        return fetchResults!
    }

    func getAllContexts()->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Context]
        
        return fetchResults!
    }
    
    func saveTaskContext(inContextID: Int, inTaskID: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myContext: TaskContext!
        
        let myContexts = getTaskContext(inContextID, inTaskID: inTaskID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObjectForEntityForName("TaskContext", inManagedObjectContext: self.managedObjectContext!) as! TaskContext
            myContext.contextID = inContextID
            myContext.taskID = inTaskID
        }
        
        if(managedObjectContext!.save(&error) )
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
            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }

    private func getTaskContext(inContextID: Int, inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) AND (contextID = \(inContextID))")
        
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
        let predicate = NSPredicate(format: "(taskID = \(inTaskID))")
        
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
        let predicate = NSPredicate(format: "(contextID = \(inContextID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskContext]
        
        return fetchResults!
    }

    func saveAreaOfResponsibility(inAreaID: Int, inGoalID: Int, inTitle: String, inStatus: String)
    {
        // first check to see if decode exists, if not we create

        var error: NSError?
        var myArea: AreaOfResponsibility!
        
        let myAreas = checkAreaOfResponsibility(inAreaID)
        
        if myAreas.count == 0
        { // Add
            myArea = NSEntityDescription.insertNewObjectForEntityForName("AreaOfResponsibility", inManagedObjectContext: self.managedObjectContext!) as! AreaOfResponsibility
            myArea.areaID = inAreaID
            myArea.goalID = inGoalID
            myArea.title = inTitle
            myArea.status = inStatus
        }
        else
        { // Update
            myArea = myAreas[0]
            myArea.goalID = inGoalID
            myArea.title = inTitle
            myArea.status = inStatus
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getAreaOfResponsibility(inAreaID: Int)->[AreaOfResponsibility]
    {
        let fetchRequest = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(areaID == \(inAreaID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [AreaOfResponsibility]
        
        return fetchResults!
    }
    
    func getOpenAreasForGoal(inGoalID: Int)->[AreaOfResponsibility]
    {
        let fetchRequest = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(goalID == \(inGoalID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [AreaOfResponsibility]
        
        return fetchResults!
    }

    private func checkAreaOfResponsibility(inAreaID: Int)->[AreaOfResponsibility]
    {
        let fetchRequest = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(areaID == \(inAreaID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [AreaOfResponsibility]
        
        return fetchResults!
    }

    func saveAreaProject(inProjectID: Int, inAreaID: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID)
        
        if myProjects.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myProject = myProjects[0]
            myProject.areaID = inAreaID
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }

    func deleteAreaProject(inProjectID: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID)
        
        if myProjects.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myProject = myProjects[0]
            myProject.areaID = 0
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func saveGoal(inGoalID: Int, inVisionID: Int, inTitle: String, inStatus: String)
    {
        // first check to see if decode exists, if not we create

        var error: NSError?
        var myGoal: GoalAndObjective!
        
        let myGoals = getGoals(inGoalID)
        
        if myGoals.count == 0
        { // Add
            myGoal = NSEntityDescription.insertNewObjectForEntityForName("GoalAndObjective", inManagedObjectContext: self.managedObjectContext!) as! GoalAndObjective
            myGoal.goalID = inGoalID
            myGoal.visionID = inVisionID
            myGoal.title = inTitle
            myGoal.status = inStatus
        }
        else
        { // Update
            myGoal = myGoals[0]
            myGoal.visionID = inVisionID
            myGoal.title = inTitle
            myGoal.status = inStatus
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getGoals(inGoalID: Int)->[GoalAndObjective]
    {
        let fetchRequest = NSFetchRequest(entityName: "GoalAndObjective")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(goalID == \(inGoalID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [GoalAndObjective]
        
        return fetchResults!
    }
    
    func getOpenGoalsForVision(inVisionID: Int)->[GoalAndObjective]
    {
        let fetchRequest = NSFetchRequest(entityName: "GoalAndObjective")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(visionID == \(inVisionID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [GoalAndObjective]
        
        return fetchResults!
    }
    
    func saveGoalArea(inGoalID: Int, inAreaID: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myArea: AreaOfResponsibility!
        
        let myAreas = getAreaOfResponsibility(inAreaID)
        
        if myAreas.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myArea = myAreas[0]
            myArea.goalID = inGoalID
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteGoalArea(inAreaID: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myArea: AreaOfResponsibility!
        
        let myAreas = getAreaOfResponsibility(inAreaID)
        
        if myAreas.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myArea = myAreas[0]
            myArea.goalID = 0
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }

    func saveVision(inVisionID: Int, inPurposeID: Int, inTitle: String, inStatus: String)
    {
        // first check to see if decode exists, if not we create

        var error: NSError?
        var myVision: Vision!
        
        let myVisions = getVisions(inVisionID)
        
        if myVisions.count == 0
        { // Add
            myVision = NSEntityDescription.insertNewObjectForEntityForName("Vision", inManagedObjectContext: self.managedObjectContext!) as! Vision
            myVision.visionID = inVisionID
            myVision.purposeID = inPurposeID
            myVision.title = inTitle
            myVision.status = inStatus
        }
        else
        { // Update
            myVision = myVisions[0]
            myVision.purposeID = inPurposeID
            myVision.title = inTitle
            myVision.status = inStatus
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getVisions(inVisionID: Int)->[Vision]
    {
        let fetchRequest = NSFetchRequest(entityName: "Vision")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(visionID == \(inVisionID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Vision]
        
        return fetchResults!
    }
    
    func getOpenVisionsForPurpose(inPurposeID: Int)->[Vision]
    {
        let fetchRequest = NSFetchRequest(entityName: "Vision")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(purposeID == \(inPurposeID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Vision]
        
        return fetchResults!
    }

    
    func saveVisionGoal(inVisionID: Int, inGoalID: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myGoal: GoalAndObjective!
        
        let myGoals = getGoals(inGoalID)
        
        if myGoals.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myGoal = myGoals[0]
            myGoal.visionID = inVisionID
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteVisionGoal(inGoalID: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myGoal: GoalAndObjective!
        
        let myGoals = getGoals(inGoalID)
        
        if myGoals.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myGoal = myGoals[0]
            myGoal.visionID = 0
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func savePurpose(inPurposeID: Int, inTitle: String, inStatus: String)
    {
        // first check to see if decode exists, if not we create

        var error: NSError?
        var myPurpose: PurposeAndCoreValue!
        
        let myPurposes = getPurpose(inPurposeID)
        
        if myPurposes.count == 0
        { // Add
            myPurpose = NSEntityDescription.insertNewObjectForEntityForName("PurposeAndCoreValue", inManagedObjectContext: self.managedObjectContext!) as! PurposeAndCoreValue
            myPurpose.purposeID = inPurposeID
            myPurpose.title = inTitle
            myPurpose.status = inStatus
        }
        else
        { // Update
            myPurpose = myPurposes[0]
            myPurpose.title = inTitle
            myPurpose.status = inStatus
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func getPurpose(inPurposeID: Int)->[PurposeAndCoreValue]
    {
        let fetchRequest = NSFetchRequest(entityName: "PurposeAndCoreValue")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(purposeID == \(inPurposeID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [PurposeAndCoreValue]
        
        return fetchResults!
    }
    
    func savePurposeVision(inPurposeID: Int, inVisionID: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myVision: Vision!
        
        let myVisions = getVisions(inVisionID)
        
        if myVisions.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myVision = myVisions[0]
            myVision.purposeID = inPurposeID
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deletePurposeVision(inVisionID: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myVision: Vision!
        
        let myVisions = getVisions(inVisionID)
        
        if myVisions.count == 0
        { // Add
            // do nothing
        }
        else
        { // Update
            myVision = myVisions[0]
            myVision.purposeID = 0
        }
        
        if(managedObjectContext!.save(&error) )
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
            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
        

        let fetchRequest2 = NSFetchRequest(entityName: "Projects")
            
        // Execute the fetch request, and cast the results to an array of objects
        let fetchResults2 = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [Projects]
        for myStage in fetchResults2!
        {
            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
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
            managedObjectContext!.deleteObject(myPane as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
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
        let predicate = NSPredicate(format: "pane_available == true")
        
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
        let predicate = NSPredicate(format: "pane_name == \"\(paneName)\"")
        
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
        
        let predicate = NSPredicate(format: "pane_name == \"\(paneName)\"")
        
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

            if(managedObjectContext!.save(&error) )
            {
                println(error?.localizedDescription)
            }
        }
    }

    func setPaneOrder(paneName: String, paneOrder: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
        let predicate = NSPredicate(format: "pane_name == \"\(paneName)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Panes]
        for myPane in fetchResults!
        {
            myPane.pane_order = paneOrder
            
            if(managedObjectContext!.save(&error) )
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
            managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    
        let fetchRequest2 = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [MeetingAttendees]
        
        for myMeeting2 in fetchResults2!
        {
            managedObjectContext!.deleteObject(myMeeting2 as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest3 = NSFetchRequest(entityName: "MeetingAgendaItem")

        let fetchResults3 = managedObjectContext!.executeFetchRequest(fetchRequest3, error: nil) as? [MeetingAgendaItem]
        
        for myMeeting3 in fetchResults3!
        {
            managedObjectContext!.deleteObject(myMeeting3 as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
        
        let fetchRequest4 = NSFetchRequest(entityName: "MeetingTasks")
        
        let fetchResults4 = managedObjectContext!.executeFetchRequest(fetchRequest4, error: nil) as? [MeetingTasks]
        
        for myMeeting4 in fetchResults4!
        {
            managedObjectContext!.deleteObject(myMeeting4 as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest5 = NSFetchRequest(entityName: "MeetingItemsBroughtForward")
        
        let fetchResults5 = managedObjectContext!.executeFetchRequest(fetchRequest5, error: nil) as? [MeetingItemsBroughtForward]
        
        for myMeeting5 in fetchResults5!
        {
            managedObjectContext!.deleteObject(myMeeting5 as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        
        let fetchRequest6 = NSFetchRequest(entityName: "MeetingSupportingDocs")
        
        let fetchResults6 = managedObjectContext!.executeFetchRequest(fetchRequest6, error: nil) as? [MeetingSupportingDocs]
        
        for myMeeting6 in fetchResults6!
        {
            managedObjectContext!.deleteObject(myMeeting6 as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
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
            managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
        
        let fetchRequest2 = NSFetchRequest(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [Task]
        
        for myMeeting2 in fetchResults2!
        {
            managedObjectContext!.deleteObject(myMeeting2 as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
        
        let fetchRequest3 = NSFetchRequest(entityName: "TaskContext")
        
        let fetchResults3 = managedObjectContext!.executeFetchRequest(fetchRequest3, error: nil) as? [TaskContext]
        
        for myMeeting3 in fetchResults3!
        {
            managedObjectContext!.deleteObject(myMeeting3 as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
        
        let fetchRequest4 = NSFetchRequest(entityName: "TaskUpdates")
        
        let fetchResults4 = managedObjectContext!.executeFetchRequest(fetchRequest4, error: nil) as? [TaskUpdates]
        
        for myMeeting4 in fetchResults4!
        {
            managedObjectContext!.deleteObject(myMeeting4 as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }

    func getAgendaTasks(inMeetingID: String, inAgendaID: String)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \"\(inAgendaID)\") AND (meetingID == \"\(inMeetingID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func saveAgendaTask(inAgendaID: String, inMeetingID: String, inTaskID: Int)
    {
        var myTask: MeetingTasks
        var error : NSError?
        
        myTask = NSEntityDescription.insertNewObjectForEntityForName("MeetingTasks", inManagedObjectContext: managedObjectContext!) as! MeetingTasks
        myTask.agendaID = inAgendaID
        myTask.meetingID = inMeetingID
        myTask.taskID = inTaskID
            
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }

    func deleteAgendaTask(inAgendaID: String, inMeetingID: String, inTaskID: Int)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \"\(inAgendaID)\") AND (meetingID == \"\(inMeetingID)\") AND (taskID == \(inTaskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [MeetingTasks]
        
        for myItem in fetchResults!
        {
            managedObjectContext!.deleteObject(myItem as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
    
    func getAgendaTask(inAgendaID: String, inMeetingID: String, inTaskID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \"\(inAgendaID)\") AND (meetingID == \"\(inMeetingID)\") AND (taskID == \(inTaskID))")
        
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
            managedObjectContext!.deleteObject(myItem as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        let fetchRequest2 = NSFetchRequest(entityName: "TaskContext")
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults2 = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [TaskContext]
        for myItem2 in fetchResults2!
        {
            managedObjectContext!.deleteObject(myItem2 as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

    }
}
