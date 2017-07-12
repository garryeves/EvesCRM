//
//  meetingAgendaItemClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class meetingAgendaItem
{
    fileprivate var myActualEndTime: Date!
    fileprivate var myActualStartTime: Date!
    fileprivate var myStatus: String = ""
    fileprivate var myDecisionMade: String = ""
    fileprivate var myDiscussionNotes: String = ""
    fileprivate var myTimeAllocation: Int = 0
    fileprivate var myOwner: String = ""
    fileprivate var myTitle: String = ""
    fileprivate var myAgendaID: Int = 0
    fileprivate var myTasks: [task] = Array()
    fileprivate var myMeetingID: String = ""
    fileprivate var myUpdateAllowed: Bool = true
    fileprivate var myMeetingOrder: Int = 0
    fileprivate var saveCalled: Bool = false
    fileprivate var myTeamID: Int = 0
    
    var actualEndTime: Date?
    {
        get
        {
            return myActualEndTime
        }
        set
        {
            myActualEndTime = newValue
        }
    }
    
    var actualStartTime: Date?
    {
        get
        {
            return myActualStartTime
        }
        set
        {
            myActualStartTime = newValue
        }
    }
    
    var status: String
    {
        get
        {
            return myStatus
        }
        set
        {
            myStatus = newValue
        }
    }
    
    var decisionMade: String
    {
        get
        {
            return myDecisionMade
        }
        set
        {
            myDecisionMade = newValue
        }
    }
    
    var discussionNotes: String
    {
        get
        {
            return myDiscussionNotes
        }
        set
        {
            myDiscussionNotes = newValue
        }
    }
    
    var timeAllocation: Int
    {
        get
        {
            return myTimeAllocation
        }
        set
        {
            myTimeAllocation = newValue
        }
    }
    
    var owner: String
    {
        get
        {
            return myOwner
        }
        set
        {
            myOwner = newValue
        }
    }
    
    var title: String
    {
        get
        {
            return myTitle
        }
        set
        {
            myTitle = newValue
        }
    }
    
    var agendaID: Int
    {
        get
        {
            return myAgendaID
        }
        set
        {
            myAgendaID = newValue
        }
    }
    
    var meetingOrder: Int
    {
        get
        {
            return myMeetingOrder
        }
        set
        {
            myMeetingOrder = newValue
        }
    }
    
    var tasks: [task]
    {
        get
        {
            return myTasks
        }
    }
    
    init(meetingID: String, teamID: Int)
    {
        myMeetingID = meetingID
        myTitle = "New Item"
        myTimeAllocation = 10
        myActualEndTime = getDefaultDate() as Date!
        myActualStartTime = getDefaultDate() as Date!
        myTeamID = teamID
        
        let tempAgendaItems = myDatabaseConnection.loadAgendaItem(myMeetingID, teamID: teamID)
        
        myAgendaID = Int(tempAgendaItems.count + 1)
        
        save()
    }
    
    init(meetingID: String, agendaID: Int, teamID: Int)
    {
        myMeetingID = meetingID
        
        let tempAgendaItems = myDatabaseConnection.loadSpecificAgendaItem(myMeetingID, agendaID: agendaID, teamID: teamID)
        
        if tempAgendaItems.count > 0
        {
            myAgendaID = Int(tempAgendaItems[0].agendaID)
            myTitle = tempAgendaItems[0].title!
            myOwner = tempAgendaItems[0].owner!
            myTimeAllocation = Int(tempAgendaItems[0].timeAllocation)
            myDiscussionNotes = tempAgendaItems[0].discussionNotes!
            myDecisionMade = tempAgendaItems[0].decisionMade!
            myStatus = tempAgendaItems[0].status!
            myMeetingOrder = Int(tempAgendaItems[0].meetingOrder)
            myActualStartTime = tempAgendaItems[0].actualStartTime! as Date
            myActualEndTime = tempAgendaItems[0].actualEndTime! as Date
            myTeamID = Int(tempAgendaItems[0].teamID)
        }
        else
        {
            myAgendaID = 0
            myTeamID = teamID
        }
    }
    
    init(rowType: String, teamID: Int)
    {
        switch rowType
        {
            case "Welcome" :
                myTitle = "Welcome"
                myTimeAllocation = 5
                
            case "PreviousMinutes" :
                myTitle = "Review of previous meeting actions"
                myTimeAllocation = 10
                
            case "Close" :
                myTitle = "Close meeting"
                myTimeAllocation = 1
                
            default:
                myTitle = "Unknown item"
                myTimeAllocation = 10
        }
        
        myStatus = "Open"
        myOwner = "All"
        myUpdateAllowed = false
        myTeamID = teamID
    }
    
    func save()
    {
        if myUpdateAllowed
        {
            myDatabaseConnection.saveAgendaItem(myMeetingID, actualEndTime: myActualEndTime!, actualStartTime: myActualStartTime!, status: myStatus, decisionMade: myDecisionMade, discussionNotes: myDiscussionNotes, timeAllocation: myTimeAllocation, owner: myOwner, title: myTitle, agendaID: myAgendaID, meetingOrder: myMeetingOrder, teamID: myTeamID)
            
            if !saveCalled
            {
                saveCalled = true
                let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func performSave()
    {
        let myAgendaItem = myDatabaseConnection.loadSpecificAgendaItem(myMeetingID, agendaID: myAgendaID, teamID: myTeamID)[0]
        
        myCloudDB.saveMeetingAgendaItemRecordToCloudKit(myAgendaItem)
        
        saveCalled = false
    }
    
    func delete()
    {
        // call code to perform the delete
        if myUpdateAllowed
        {
            myDatabaseConnection.deleteAgendaItem(myMeetingID, agendaID: myAgendaID, teamID: myTeamID)
        }
    }
    
    func loadTasks()
    {
        myTasks.removeAll()
        
        let myAgendaTasks = myDatabaseConnection.getAgendaTasks(myMeetingID, agendaID:myAgendaID, teamID: myTeamID)
        
        for myAgendaTask in myAgendaTasks
        {
            let myNewTask = task(taskID: Int(myAgendaTask.taskID), teamID: myTeamID)
            myTasks.append(myNewTask)
        }
    }
    
    func addTask(_ taskItem: task)
    {
        // Is there ale=ready a link between the agenda and the task, if there is then no need to save
        let myCheck = myDatabaseConnection.getAgendaTask(myAgendaID, meetingID: myMeetingID, taskID: taskItem.taskID, teamID: myTeamID)
        
        if myCheck.count == 0
        {
            // Associate Agenda to Task
            myDatabaseConnection.saveAgendaTask(myAgendaID, meetingID: myMeetingID, taskID: taskItem.taskID, teamID: myTeamID)
        }
        
        // reload the tasks array
        loadTasks()
    }
    
    func removeTask(_ taskItem: task)
    {
        // Associate Agenda to Task
        myDatabaseConnection.deleteAgendaTask(myAgendaID, meetingID: myMeetingID, taskID: taskItem.taskID, teamID: myTeamID)
        
        // reload the tasks array
        loadTasks()
    }
}

extension coreDatabase
{
    func loadAgendaItem(_ meetingID: String, teamID: Int)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") AND (teamID == \(teamID)) AND (updateType != \"Delete\") AND (teamID == \(currentUser.currentTeam!.teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "meetingOrder", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func saveAgendaItem(_ meetingID: String, actualEndTime: Date, actualStartTime: Date, status: String, decisionMade: String, discussionNotes: String, timeAllocation: Int, owner: String, title: String, agendaID: Int, meetingOrder: Int, teamID: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var mySavedItem: MeetingAgendaItem
        
        let myAgendaItem = loadSpecificAgendaItem(meetingID, agendaID: agendaID, teamID: teamID)
        
        if myAgendaItem.count == 0
        {
            mySavedItem = MeetingAgendaItem(context: objectContext)
            mySavedItem.meetingID = meetingID
            mySavedItem.agendaID = Int64(agendaID)
            mySavedItem.actualEndTime = actualEndTime as NSDate
            mySavedItem.actualStartTime = actualStartTime as NSDate
            mySavedItem.status = status
            mySavedItem.decisionMade = decisionMade
            mySavedItem.discussionNotes = discussionNotes
            mySavedItem.timeAllocation = Int64(timeAllocation)
            mySavedItem.owner = owner
            mySavedItem.title = title
            mySavedItem.meetingOrder = Int64(meetingOrder)
            mySavedItem.teamID = Int64(teamID)
            
            if updateType == "CODE"
            {
                mySavedItem.updateTime =  NSDate()
                mySavedItem.updateType = "Add"
            }
            else
            {
                mySavedItem.updateTime = updateTime as NSDate
                mySavedItem.updateType = updateType
            }
        }
        else
        {
            mySavedItem = myAgendaItem[0]
            mySavedItem.actualEndTime = actualEndTime as NSDate
            mySavedItem.actualStartTime = actualStartTime as NSDate
            mySavedItem.status = status
            mySavedItem.decisionMade = decisionMade
            mySavedItem.discussionNotes = discussionNotes
            mySavedItem.timeAllocation = Int64(timeAllocation)
            mySavedItem.owner = owner
            mySavedItem.title = title
            mySavedItem.meetingOrder = Int64(meetingOrder)
            
            if updateType == "CODE"
            {
                mySavedItem.updateTime =  NSDate()
                if mySavedItem.updateType != "Add"
                {
                    mySavedItem.updateType = "Update"
                }
            }
            else
            {
                mySavedItem.updateTime = updateTime as NSDate
                mySavedItem.updateType = updateType
            }
        }
        
        saveContext()
    }
    
    func loadSpecificAgendaItem(_ meetingID: String, agendaID: Int, teamID: Int)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") AND (agendaID == \(agendaID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "meetingOrder", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func deleteAgendaItem(_ meetingID: String, agendaID: Int, teamID: Int)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") AND (agendaID == \(agendaID)) && (updateType != \"Delete\") AND (teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myMeeting in fetchResults
            {
                myMeeting.updateTime =  NSDate()
                myMeeting.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func deleteAllAgendaItems(_ meetingID: String, teamID: Int)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") AND (teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myMeeting in fetchResults
            {
                myMeeting.updateTime =  NSDate()
                myMeeting.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func resetMeetingAgendaItems()
    {
        let fetchRequest3 = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        do
        {
            let fetchResults3 = try objectContext.fetch(fetchRequest3)
            for myMeeting3 in fetchResults3
            {
                myMeeting3.updateTime =  NSDate()
                myMeeting3.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearDeletedMeetingAgendaItems(predicate: NSPredicate)
    {
        let fetchRequest6 = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        // Set the predicate on the fetch request
        fetchRequest6.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults6 = try objectContext.fetch(fetchRequest6)
            for myItem6 in fetchResults6
            {
                objectContext.delete(myItem6 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedMeetingAgendaItems(predicate: NSPredicate)
    {
        let fetchRequest6 = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        // Set the predicate on the fetch request
        fetchRequest6.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults6 = try objectContext.fetch(fetchRequest6)
            for myItem6 in fetchResults6
            {
                myItem6.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func getMeetingAgendaItemsForSync(_ syncDate: Date) -> [MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", syncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func deleteAllMeetingAgendaItemRecords()
    {
        let fetchRequest6 = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults6 = try objectContext.fetch(fetchRequest6)
            for myItem6 in fetchResults6
            {
                self.objectContext.delete(myItem6 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func resetMeetingTasks()
    {
        let fetchRequest1 = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults1 = try objectContext.fetch(fetchRequest1)
            for myMeeting in fetchResults1
            {
                myMeeting.updateTime =  NSDate()
                myMeeting.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getAgendaTasks(_ meetingID: String, agendaID: Int, teamID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) AND (meetingID == \"\(meetingID)\") AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func getMeetingsTasks(_ meetingID: String, teamID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func saveAgendaTask(_ agendaID: Int, meetingID: String, taskID: Int, teamID: Int)
    {
        var myTask: MeetingTasks
        
        myTask = MeetingTasks(context: objectContext)
        myTask.agendaID = Int64(agendaID)
        myTask.meetingID = meetingID
        myTask.taskID = Int64(taskID)
        myTask.updateTime =  NSDate()
        myTask.updateType = "Add"
        myTask.teamID = Int64(teamID)
        
        saveContext()
        
        myCloudDB.saveMeetingTasksRecordToCloudKit(myTask)
    }
    
    func checkMeetingTask(_ meetingID: String, agendaID: Int, taskID: Int, teamID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) && (meetingID == \"\(meetingID)\") AND (teamID == \(teamID)) AND (updateType != \"Delete\") && (taskID == \(taskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func saveMeetingTask(_ agendaID: Int, meetingID: String, taskID: Int, teamID: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myTask: MeetingTasks
        
        let myTaskList = checkMeetingTask(meetingID, agendaID: agendaID, taskID: taskID, teamID: teamID)
        
        if myTaskList.count == 0
        {
            myTask = MeetingTasks(context: objectContext)
            myTask.agendaID = Int64(agendaID)
            myTask.meetingID = meetingID
            myTask.taskID = Int64(taskID)
            myTask.teamID = Int64(teamID)

            if updateType == "CODE"
            {
                myTask.updateTime =  NSDate()
                myTask.updateType = "Add"
            }
            else
            {
                myTask.updateTime = updateTime as NSDate
                myTask.updateType = updateType
            }
        }
        else
        {
            myTask = myTaskList[0]
            if updateType == "CODE"
            {
                myTask.updateTime =  NSDate()
                if myTask.updateType != "Add"
                {
                    myTask.updateType = "Update"
                }
            }
            else
            {
                myTask.updateTime = updateTime as NSDate
                myTask.updateType = updateType
            }
        }
        
        saveContext()
    }
    
    func deleteAgendaTask(_ agendaID: Int, meetingID: String, taskID: Int, teamID: Int)
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) AND (meetingID == \"\(meetingID)\") AND (teamID == \(teamID)) AND (taskID == \(taskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                myItem.updateTime =  NSDate()
                myItem.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func getAgendaTask(_ agendaID: Int, meetingID: String, taskID: Int, teamID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) && (meetingID == \"\(meetingID)\") AND (teamID == \(teamID)) AND (taskID == \(taskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func clearDeletedMeetingTasks(predicate: NSPredicate)
    {
        let fetchRequest9 = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Set the predicate on the fetch request
        fetchRequest9.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults9 = try objectContext.fetch(fetchRequest9)
            for myItem9 in fetchResults9
            {
                objectContext.delete(myItem9 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedMeetingTasks(predicate: NSPredicate)
    {
        let fetchRequest9 = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Set the predicate on the fetch request
        fetchRequest9.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults9 = try objectContext.fetch(fetchRequest9)
            for myItem9 in fetchResults9
            {
                myItem9.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getMeetingTasksForSync(_ syncDate: Date) -> [MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", syncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func deleteAllMeetingTaskRecords()
    {
        let fetchRequest9 = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults9 = try objectContext.fetch(fetchRequest9)
            for myItem9 in fetchResults9
            {
                self.objectContext.delete(myItem9 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
}

extension CloudKitInteraction
{
    func saveMeetingAgendaItemToCloudKit()
    {
        for myItem in myDatabaseConnection.getMeetingAgendaItemsForSync(getSyncDateForTable(tableName: "MeetingAgendaItem"))
        {
            saveMeetingAgendaItemRecordToCloudKit(myItem)
        }
    }

    func updateMeetingAgendaItemInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "MeetingAgendaItem") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateMeetingAgendaItemRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "MeetingAgendaItem", queryOperation: operation, onOperationQueue: operationQueue)
    }

//    func deleteMeetingAgendaItem(teamID: Int)
//    {
//        let sem = DispatchSemaphore(value: 0);
//        
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
//        let query: CKQuery = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
//        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
//            for record in results!
//            {
//                myRecordList.append(record.recordID)
//            }
//            self.performPublicDelete(myRecordList)
//            sem.signal()
//        })
//        sem.wait()
//    }

    func saveMeetingAgendaItemRecordToCloudKit(_ sourceRecord: MeetingAgendaItem)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID!)\") && (agendaID == \(sourceRecord.agendaID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.actualEndTime, forKey: "actualEndTime")
                    record!.setValue(sourceRecord.actualStartTime, forKey: "actualStartTime")
                    record!.setValue(sourceRecord.decisionMade, forKey: "decisionMade")
                    record!.setValue(sourceRecord.discussionNotes, forKey: "discussionNotes")
                    record!.setValue(sourceRecord.owner, forKey: "owner")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    record!.setValue(sourceRecord.timeAllocation, forKey: "timeAllocation")
                    record!.setValue(sourceRecord.title, forKey: "title")
                    record!.setValue(sourceRecord.meetingOrder, forKey: "meetingOrder")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully updated record!")
                            }
                        }
                    })
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "MeetingAgendaItem")
                    record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                    record.setValue(sourceRecord.agendaID, forKey: "agendaID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.actualEndTime, forKey: "actualEndTime")
                    record.setValue(sourceRecord.actualStartTime, forKey: "actualStartTime")
                    record.setValue(sourceRecord.decisionMade, forKey: "decisionMade")
                    record.setValue(sourceRecord.discussionNotes, forKey: "discussionNotes")
                    record.setValue(sourceRecord.owner, forKey: "owner")
                    record.setValue(sourceRecord.status, forKey: "status")
                    record.setValue(sourceRecord.timeAllocation, forKey: "timeAllocation")
                    record.setValue(sourceRecord.title, forKey: "title")
                    record.setValue(sourceRecord.meetingOrder, forKey: "meetingOrder")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully saved record!")
                            }
                        }
                    })
                }
            }
            sem.signal()
        })
        sem.wait()
    }

    func updateMeetingAgendaItemRecord(_ sourceRecord: CKRecord)
    {
        let meetingID = sourceRecord.object(forKey: "meetingID") as! String
        let agendaID = sourceRecord.object(forKey: "agendaID") as! Int
        var updateTime = Date()
        if sourceRecord.object(forKey: "updateTime") != nil
        {
            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
        }
        
        var updateType = ""
        
        if sourceRecord.object(forKey: "updateType") != nil
        {
            updateType = sourceRecord.object(forKey: "updateType") as! String
        }
        var actualEndTime: Date!
        if sourceRecord.object(forKey: "actualEndTime") != nil
        {
            actualEndTime = sourceRecord.object(forKey: "actualEndTime") as! Date
        }
        else
        {
            actualEndTime = getDefaultDate() as Date!
        }
        var actualStartTime: Date!
        if sourceRecord.object(forKey: "actualStartTime") != nil
        {
            actualStartTime = sourceRecord.object(forKey: "actualStartTime") as! Date
        }
        else
        {
            actualStartTime = getDefaultDate() as Date!
        }
        let decisionMade = sourceRecord.object(forKey: "decisionMade") as! String
        let discussionNotes = sourceRecord.object(forKey: "discussionNotes") as! String
        let owner = sourceRecord.object(forKey: "owner") as! String
        let status = sourceRecord.object(forKey: "status") as! String
        let timeAllocation = sourceRecord.object(forKey: "timeAllocation") as! Int
        let title = sourceRecord.object(forKey: "title") as! String
        let meetingOrder = sourceRecord.object(forKey: "meetingOrder") as! Int
        
        var teamID: Int = 0
        if sourceRecord.object(forKey: "teamID") != nil
        {
            teamID = sourceRecord.object(forKey: "teamID") as! Int
        }
        
        myDatabaseConnection.recordsToChange += 1
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
        
        self.recordCount += 1
        
        myDatabaseConnection.saveAgendaItem(meetingID, actualEndTime: actualEndTime, actualStartTime: actualStartTime, status: status, decisionMade: decisionMade, discussionNotes: discussionNotes, timeAllocation: timeAllocation, owner: owner, title: title, agendaID: agendaID, meetingOrder: meetingOrder, teamID: teamID, updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
    
    func saveMeetingTasksToCloudKit()
    {
        for myItem in myDatabaseConnection.getMeetingTasksForSync(getSyncDateForTable(tableName: "MeetingTasks"))
        {
            saveMeetingTasksRecordToCloudKit(myItem)
        }
    }

    func updateMeetingTasksInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "MeetingTasks") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateMeetingTasksRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "MeetingTasks", queryOperation: operation, onOperationQueue: operationQueue)
    }

//    func deleteMeetingTasks(teamID: Int)
//    {
//        let sem = DispatchSemaphore(value: 0);
//        
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
//        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
//        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
//            for record in results!
//            {
//                myRecordList.append(record.recordID)
//            }
//            self.performPublicDelete(myRecordList)
//            sem.signal()
//        })
//        sem.wait()
//    }

    func saveMeetingTasksRecordToCloudKit(_ sourceRecord: MeetingTasks)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID!)\") && (agendaID == \(sourceRecord.agendaID)) && (taskID == \(sourceRecord.taskID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the
        let query = CKQuery(recordType: "MeetingTasks", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.taskID, forKey: "taskID")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully updated record!")
                            }
                        }
                    })
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "MeetingTasks")
                    record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                    record.setValue(sourceRecord.agendaID, forKey: "agendaID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.taskID, forKey: "taskID")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully saved record!")
                            }
                        }
                    })
                }
            }
            sem.signal()
        })
        sem.wait()
    }

    func updateMeetingTasksRecord(_ sourceRecord: CKRecord)
    {
        let meetingID = sourceRecord.object(forKey: "meetingIDInt") as! String
        let agendaID = sourceRecord.object(forKey: "agendaID") as! Int
        var updateTime = Date()
        if sourceRecord.object(forKey: "updateTime") != nil
        {
            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
        }
        
        var updateType = ""
        
        if sourceRecord.object(forKey: "updateType") != nil
        {
            updateType = sourceRecord.object(forKey: "updateType") as! String
        }
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
        
        var teamID: Int = 0
        if sourceRecord.object(forKey: "teamID") != nil
        {
            teamID = sourceRecord.object(forKey: "teamID") as! Int
        }
        
        myDatabaseConnection.recordsToChange += 1
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
        
        self.recordCount += 1
        
        myDatabaseConnection.saveMeetingTask(agendaID, meetingID: meetingID, taskID: taskID, teamID: teamID, updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
}
