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
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!
    }
    
    func getOpenProjectsForArea(inAreaID: String)->[Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") AND (areaID != \"\(inAreaID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
        
        return fetchResults!
    }

    
    func getProjectDetails(myProjectID: NSNumber)->[Projects]
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
        
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) AND (teamMember == \(inPersonName))")
        
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
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) AND (teamMember == \(inPersonName))")
        
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

    func saveTask(inTaskID: String, inTitle: String, inDetails: String, inDueDate: NSDate, inStartDate: NSDate, inStatus: String, inParentTask: String)
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
            myTask.parentTaskID = inParentTask
        }
        else
        { // Update
            myTask = myTasks[0]
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.parentTaskID = inParentTask
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteTask(inTaskID: String)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        let predicate = NSPredicate(format: "taskID == \"\(inTaskID)\"")
        
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
    
    func saveProjectTask(inProjectID: Int, inTaskID: String, inTaskOrder: Int)
    {
        // first check to see if decode exists, if not we create
        
        var error: NSError?
        var myProjectTask: ProjectTasks!
        
        let myProjectTasks = checkProjectTasks(inProjectID, inTaskID: inTaskID)
        
        if myProjectTasks.count == 0
        { // Add
            myProjectTask = NSEntityDescription.insertNewObjectForEntityForName("ProjectTasks", inManagedObjectContext: self.managedObjectContext!) as! ProjectTasks
            myProjectTask.taskID = inTaskID
            myProjectTask.projectID = inProjectID
            myProjectTask.taskOrder = inTaskOrder
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func deleteProjectTask(inProjectID: Int, inTaskID: String)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "ProjectTasks")
        
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) AND (taskID = \"\(inTaskID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTasks]
        for myStage in fetchResults!
        {
            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
    }
   
    func getProjectTasks(inProjectID: Int)->[ProjectTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTasks")

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTasks]
        
        return fetchResults!
    }
    
    func getMaxProjectTaskOrder(inProjectID: Int)->Int
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTasks]
        
        return fetchResults!.count
    }

    
    private func checkProjectTasks(inProjectID: Int, inTaskID: String)->[ProjectTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) AND (taskID = \"\(inTaskID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTasks]
        
        return fetchResults!
    }

    func getProjectForTask(inTaskID: String)->[ProjectTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \"\(inTaskID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTasks]
        
        return fetchResults!
    }
    
    func getTaskWithoutProject()->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "projectID == 0")
        
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
        
        let contextRequest = NSFetchRequest(entityName: "TaskContext")
        contextRequest.propertiesToFetch = ["contextID"]
        contextRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        contextRequest.returnsDistinctResults = true
        
        let contextResults = managedObjectContext!.executeFetchRequest(contextRequest, error: &error)

        for var i = 0; i < contextResults!.count; i++
        {
            if let dic = (contextResults[i] as! [String : String])
            {
                if let myContext = dic["contextID"]?
                {
                    myContextTasks.append(myContext)
                }
            }
        }
        
        
        
        
        let fetchRequest = NSFetchRequest(entityName: "Task")
GRE needs to code
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "projectID == \"\(inTaskID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task]
        
        return fetchResults!
    }
    
    func getTask(inTaskID: String)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "taskID == \"\(inTaskID)\"")
        
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
    
    func saveProject(inProjectID: Int, inProjectEndDate: NSDate, inProjectName: String, inProjectStartDate: NSDate, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: NSDate, inAreaID: String)
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
 
    func saveTaskUpdate(inTaskID: String, inDetails: String, inSource: String)
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
    
    func getTaskUpdates(inTaskID: String)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \"\(inTaskID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskUpdates]
        
        return fetchResults!
    }

    func saveContext(inContextID: String, inName: String, inEmail: String, inAutoEmail: String, inParentContext: String, inStatus: String)
    {
        // first check to see if decode exists, if not we create

        var error: NSError?
        var myContext: Context!
        
        let myContexts = getContexts()
        
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

    func getContextDetails(inContextID: String)->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID == \"inContextID\")")
        
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
    
    func saveTaskContext(inContextID: String, inTaskID: String)
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
    
    func deleteTaskContext(inContextID: String, inTaskID: String)
    {
        var error : NSError?
        
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        let predicate = NSPredicate(format: "(contextID == \"\(inContextID)\") AND (taskID = \"\(inTaskID)\")")
        
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

    private func getTaskContext(inContextID: String, inTaskID: String)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \"\(inTaskID)\") AND (contextID = \"\(inContextID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskContext]
        
        return fetchResults!
    }

    func getContextsForTask(inTaskID: String)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \"\(inTaskID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskContext]
        
        return fetchResults!
    }

    func getTasksForContext(inContextID: String)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID = \"\(inContextID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskContext]
        
        return fetchResults!
    }

    func saveAreaOfResponsibility(inAreaID: String, inGoalID: String, inTitle: String, inStatus: String)
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
    
    func getAreaOfResponsibility(inAreaID: String)->[AreaOfResponsibility]
    {
        let fetchRequest = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(areaID == \"\(inAreaID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [AreaOfResponsibility]
        
        return fetchResults!
    }
    
    func getOpenAreasForGoal(inGoalID: String)->[AreaOfResponsibility]
    {
        let fetchRequest = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(goalID == \"\(inGoalID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [AreaOfResponsibility]
        
        return fetchResults!
    }

    private func checkAreaOfResponsibility(inAreaID: String)->[AreaOfResponsibility]
    {
        let fetchRequest = NSFetchRequest(entityName: "AreaOfResponsibility")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(areaID == \"\(inAreaID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [AreaOfResponsibility]
        
        return fetchResults!
    }

    func saveAreaProject(inProjectID: Int, inAreaID: String)
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
            myProject.areaID = ""
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func saveGoal(inGoalID: String, inVisionID: String, inTitle: String, inStatus: String)
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
    
    func getGoals(inGoalID: String)->[GoalAndObjective]
    {
        let fetchRequest = NSFetchRequest(entityName: "GoalAndObjective")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(goalID == \"\(inGoalID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [GoalAndObjective]
        
        return fetchResults!
    }
    
    func getOpenGoalsForVision(inVisionID: String)->[GoalAndObjective]
    {
        let fetchRequest = NSFetchRequest(entityName: "GoalAndObjective")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(visionID == \"\(inVisionID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [GoalAndObjective]
        
        return fetchResults!
    }
    
    func saveGoalArea(inGoalID: String, inAreaID: String)
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
    
    func deleteGoalArea(inAreaID: String)
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
            myArea.goalID = ""
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }

    func saveVision(inVisionID: String, inPurposeID: String, inTitle: String, inStatus: String)
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
    
    func getVisions(inVisionID: String)->[Vision]
    {
        let fetchRequest = NSFetchRequest(entityName: "Vision")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(visionID == \"\(inVisionID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Vision]
        
        return fetchResults!
    }
    
    func getOpenVisionsForPurpose(inPurposeID: String)->[Vision]
    {
        let fetchRequest = NSFetchRequest(entityName: "Vision")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(purposeID == \"\(inPurposeID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Vision]
        
        return fetchResults!
    }

    
    func saveVisionGoal(inVisionID: String, inGoalID: String)
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
    
    func deleteVisionGoal(inGoalID: String)
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
            myGoal.visionID = ""
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }
    
    func savePurpose(inPurposeID: String, inTitle: String, inStatus: String)
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
    
    func getPurpose(inPurposeID: String)->[PurposeAndCoreValue]
    {
        let fetchRequest = NSFetchRequest(entityName: "PurposeAndCoreValue")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(purposeID == \"\(inPurposeID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [PurposeAndCoreValue]
        
        return fetchResults!
    }
    
    func savePurposeVision(inPurposeID: String, inVisionID: String)
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
    
    func deletePurposeVision(inVisionID: String)
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
            myVision.purposeID = ""
        }
        
        if(managedObjectContext!.save(&error) )
        {
            //   println(error?.localizedDescription)
        }
    }

}
