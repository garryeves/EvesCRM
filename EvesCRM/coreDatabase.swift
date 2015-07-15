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

    func getProjects()->[Projects]
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
    
    func saveAgendaItem(inMeetingID: String, inItems: [meetingAgendaItem])
    {
        var mySavedItem: MeetingAgendaItem
        var error : NSError?
        
        // Before we can add items, we first need to clear out the existing entries
        deleteAllAgendaItems(inMeetingID)
        
        for inItem in inItems
        {
            mySavedItem = NSEntityDescription.insertNewObjectForEntityForName("MeetingAgendaItem", inManagedObjectContext: managedObjectContext!) as! MeetingAgendaItem
            mySavedItem.meetingID = inMeetingID
            mySavedItem.actualEndTime = inItem.actualEndTime
            mySavedItem.actualStartTime = inItem.actualStartTime
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

}
