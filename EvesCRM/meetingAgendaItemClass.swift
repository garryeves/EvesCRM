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
    fileprivate var myTimeAllocation: Int16 = 0
    fileprivate var myOwner: String = ""
    fileprivate var myTitle: String = ""
    fileprivate var myAgendaID: Int32 = 0
    fileprivate var myTasks: [task] = Array()
    fileprivate var myMeetingID: String = ""
    fileprivate var myUpdateAllowed: Bool = true
    fileprivate var myMeetingOrder: Int32 = 0
    fileprivate var saveCalled: Bool = false
    
    var actualEndTime: Date?
    {
        get
        {
            return myActualEndTime
        }
        set
        {
            myActualEndTime = newValue
            save()
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
            save()
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
            save()
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
            save()
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
            save()
        }
    }
    
    var timeAllocation: Int16
    {
        get
        {
            return myTimeAllocation
        }
        set
        {
            myTimeAllocation = newValue
            save()
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
            save()
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
            save()
        }
    }
    
    var agendaID: Int32
    {
        get
        {
            return myAgendaID
        }
        set
        {
            myAgendaID = newValue
            save()
        }
    }
    
    var meetingOrder: Int32
    {
        get
        {
            return myMeetingOrder
        }
        set
        {
            myMeetingOrder = newValue
            save()
        }
    }
    
    var tasks: [task]
    {
        get
        {
            return myTasks
        }
    }
    
    init(meetingID: String)
    {
        myMeetingID = meetingID
        myTitle = "New Item"
        myTimeAllocation = 10
        myActualEndTime = getDefaultDate() as Date!
        myActualStartTime = getDefaultDate() as Date!
        
        let tempAgendaItems = myDatabaseConnection.loadAgendaItem(myMeetingID)
        
        myAgendaID = Int32(tempAgendaItems.count + 1)
        
        save()
    }
    
    init(meetingID: String, agendaID: Int32)
    {
        myMeetingID = meetingID
        
        let tempAgendaItems = myDatabaseConnection.loadSpecificAgendaItem(myMeetingID, agendaID: agendaID)
        
        if tempAgendaItems.count > 0
        {
            myAgendaID = tempAgendaItems[0].agendaID
            myTitle = tempAgendaItems[0].title!
            myOwner = tempAgendaItems[0].owner!
            myTimeAllocation = tempAgendaItems[0].timeAllocation
            myDiscussionNotes = tempAgendaItems[0].discussionNotes!
            myDecisionMade = tempAgendaItems[0].decisionMade!
            myStatus = tempAgendaItems[0].status!
 //           if tempAgendaItems[0].meetingOrder != nil
 //           {
                myMeetingOrder = tempAgendaItems[0].meetingOrder
 //           }
            myActualStartTime = tempAgendaItems[0].actualStartTime! as Date
            myActualEndTime = tempAgendaItems[0].actualEndTime! as Date
        }
        else
        {
            myAgendaID = 0
        }
    }
    
    init(rowType: String)
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
    }
    
    func save()
    {
        if myUpdateAllowed
        {
            myDatabaseConnection.saveAgendaItem(myMeetingID, actualEndTime: myActualEndTime!, actualStartTime: myActualStartTime!, status: myStatus, decisionMade: myDecisionMade, discussionNotes: myDiscussionNotes, timeAllocation: myTimeAllocation, owner: myOwner, title: myTitle, agendaID: myAgendaID, meetingOrder: myMeetingOrder)
            
            if !saveCalled
            {
                saveCalled = true
                let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func performSave()
    {
        let myAgendaItem = myDatabaseConnection.loadSpecificAgendaItem(myMeetingID, agendaID: myAgendaID)[0]
        
        myCloudDB.saveMeetingAgendaItemRecordToCloudKit(myAgendaItem, teamID: currentUser.currentTeam!.teamID)
        
        saveCalled = false
    }
    
    func delete()
    {
        // call code to perform the delete
        if myUpdateAllowed
        {
            myDatabaseConnection.deleteAgendaItem(myMeetingID, agendaID: myAgendaID)
        }
    }
    
    func loadTasks()
    {
        myTasks.removeAll()
        
        let myAgendaTasks = myDatabaseConnection.getAgendaTasks(myMeetingID, agendaID:myAgendaID)
        
        for myAgendaTask in myAgendaTasks
        {
            let myNewTask = task(taskID: myAgendaTask.taskID)
            myTasks.append(myNewTask)
        }
    }
    
    func addTask(_ taskItem: task)
    {
        // Is there ale=ready a link between the agenda and the task, if there is then no need to save
        let myCheck = myDatabaseConnection.getAgendaTask(myAgendaID, meetingID: myMeetingID, taskID: taskItem.taskID)
        
        if myCheck.count == 0
        {
            // Associate Agenda to Task
            myDatabaseConnection.saveAgendaTask(myAgendaID, meetingID: myMeetingID, taskID: taskItem.taskID)
        }
        
        // reload the tasks array
        loadTasks()
    }
    
    func removeTask(_ taskItem: task)
    {
        // Associate Agenda to Task
        myDatabaseConnection.deleteAgendaTask(myAgendaID, meetingID: myMeetingID, taskID: taskItem.taskID)
        
        // reload the tasks array
        loadTasks()
    }
}

extension coreDatabase
{
    func loadAgendaItem(_ meetingID: String)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") && (updateType != \"Delete\")")
        
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
    
    func saveAgendaItem(_ meetingID: String, actualEndTime: Date, actualStartTime: Date, status: String, decisionMade: String, discussionNotes: String, timeAllocation: Int16, owner: String, title: String, agendaID: Int32, meetingOrder: Int32,  updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var mySavedItem: MeetingAgendaItem
        
        let myAgendaItem = loadSpecificAgendaItem(meetingID,agendaID: agendaID)
        
        if myAgendaItem.count == 0
        {
            mySavedItem = MeetingAgendaItem(context: objectContext)
            mySavedItem.meetingID = meetingID
            mySavedItem.agendaID = agendaID
            mySavedItem.actualEndTime = actualEndTime as NSDate
            mySavedItem.actualStartTime = actualStartTime as NSDate
            mySavedItem.status = status
            mySavedItem.decisionMade = decisionMade
            mySavedItem.discussionNotes = discussionNotes
            mySavedItem.timeAllocation = timeAllocation
            mySavedItem.owner = owner
            mySavedItem.title = title
            mySavedItem.meetingOrder = meetingOrder
            
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
            mySavedItem.timeAllocation = timeAllocation
            mySavedItem.owner = owner
            mySavedItem.title = title
            mySavedItem.meetingOrder = meetingOrder
            
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
    
    func replaceAgendaItem(_ meetingID: String, actualEndTime: Date, actualStartTime: Date, status: String, decisionMade: String, discussionNotes: String, timeAllocation: Int16, owner: String, title: String, agendaID: Int32, meetingOrder: Int32, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let mySavedItem = MeetingAgendaItem(context: objectContext)
        mySavedItem.meetingID = meetingID
        mySavedItem.agendaID = agendaID
        mySavedItem.actualEndTime = actualEndTime as NSDate
        mySavedItem.actualStartTime = actualStartTime as NSDate
        mySavedItem.status = status
        mySavedItem.decisionMade = decisionMade
        mySavedItem.discussionNotes = discussionNotes
        mySavedItem.timeAllocation = timeAllocation
        mySavedItem.owner = owner
        mySavedItem.title = title
        mySavedItem.meetingOrder = meetingOrder
        
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
        
        saveContext()
    }
    
    func loadSpecificAgendaItem(_ meetingID: String, agendaID: Int32)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") AND (agendaID == \(agendaID)) && (updateType != \"Delete\")")
        
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
    
    func deleteAgendaItem(_ meetingID: String, agendaID: Int32)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") AND (agendaID == \(agendaID)) && (updateType != \"Delete\")")
        
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
    
    func deleteAllAgendaItems(_ meetingID: String)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "meetingID == \"\(meetingID)\"")
        
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
    
    func getAgendaTasks(_ meetingID: String, agendaID: Int32)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) AND (meetingID == \"\(meetingID)\") && (updateType != \"Delete\")")
        
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
    
    func getMeetingsTasks(_ meetingID: String)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") && (updateType != \"Delete\")")
        
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
    
    func saveAgendaTask(_ agendaID: Int32, meetingID: String, taskID: Int32)
    {
        var myTask: MeetingTasks
        
        myTask = MeetingTasks(context: objectContext)
        myTask.agendaID = agendaID
        myTask.meetingID = meetingID
        myTask.taskID = taskID
        myTask.updateTime =  NSDate()
        myTask.updateType = "Add"
        
        saveContext()
        
        myCloudDB.saveMeetingTasksRecordToCloudKit(myTask, teamID: currentUser.currentTeam!.teamID)
    }
    
    func replaceAgendaTask(_ agendaID: Int32, meetingID: String, taskID: Int32)
    {
        let myTask = MeetingTasks(context: objectContext)
        myTask.agendaID = agendaID
        myTask.meetingID = meetingID
        myTask.taskID = taskID
        myTask.updateTime =  NSDate()
        myTask.updateType = "Add"
        
        saveContext()
    }
    
    func checkMeetingTask(_ meetingID: String, agendaID: Int32, taskID: Int32)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) && (meetingID == \"\(meetingID)\") && (updateType != \"Delete\") && (taskID == \(taskID))")
        
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
    
    func saveMeetingTask(_ agendaID: Int32, meetingID: String, taskID: Int32, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myTask: MeetingTasks
        
        let myTaskList = checkMeetingTask(meetingID, agendaID: agendaID, taskID: taskID)
        
        if myTaskList.count == 0
        {
            myTask = MeetingTasks(context: objectContext)
            myTask.agendaID = agendaID
            myTask.meetingID = meetingID
            myTask.taskID = taskID
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
    
    func replaceMeetingTask(_ agendaID: Int32, meetingID: String, taskID: Int32, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myTask = MeetingTasks(context: objectContext)
        myTask.agendaID = agendaID
        myTask.meetingID = meetingID
        myTask.taskID = taskID
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
        saveContext()
    }
    
    func deleteAgendaTask(_ agendaID: Int32, meetingID: String, taskID: Int32)
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) AND (meetingID == \"\(meetingID)\") AND (taskID == \(taskID))")
        
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
    
    func getAgendaTask(_ agendaID: Int32, meetingID: String, taskID: Int32)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) && (meetingID == \"\(meetingID)\") && (taskID == \(taskID)) && (updateType != \"Delete\")")
        
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
        for myItem in myDatabaseConnection.getMeetingAgendaItemsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "MeetingAgendaItem"))
        {
            saveMeetingAgendaItemRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }

    func updateMeetingAgendaItemInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(teamID))", myDatabaseConnection.getSyncDateForTable(tableName: "MeetingAgendaItem") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1

            self.updateMeetingAgendaItemRecord(record)
            self.recordCount -= 1

            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func deleteMeetingAgendaItem(teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performPublicDelete(myRecordList)
            sem.signal()
        })
        sem.wait()
    }

    func replaceMeetingAgendaItemInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let meetingID = record.object(forKey: "meetingID") as! String
            let agendaID = record.object(forKey: "agendaID") as! Int32
            var updateTime = Date()
            if record.object(forKey: "updateTime") != nil
            {
                updateTime = record.object(forKey: "updateTime") as! Date
            }
            var updateType: String = ""
            if record.object(forKey: "updateType") != nil
            {
                updateType = record.object(forKey: "updateType") as! String
            }
            let actualEndTime = record.object(forKey: "actualEndTime") as! Date
            let actualStartTime = record.object(forKey: "actualStartTime") as! Date
            let decisionMade = record.object(forKey: "decisionMade") as! String
            let discussionNotes = record.object(forKey: "discussionNotes") as! String
            let owner = record.object(forKey: "owner") as! String
            let status = record.object(forKey: "status") as! String
            let timeAllocation = record.object(forKey: "timeAllocation") as! Int16
            let title = record.object(forKey: "title") as! String
            let meetingOrder = record.object(forKey: "meetingOrder") as! Int32
            
            myDatabaseConnection.replaceAgendaItem(meetingID, actualEndTime: actualEndTime, actualStartTime: actualStartTime, status: status, decisionMade: decisionMade, discussionNotes: discussionNotes, timeAllocation: timeAllocation, owner: owner, title: title, agendaID: agendaID, meetingOrder: meetingOrder, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveMeetingAgendaItemRecordToCloudKit(_ sourceRecord: MeetingAgendaItem, teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID!)\") && (agendaID == \(sourceRecord.agendaID)) AND (teamID == \(teamID))") // better be accurate to get only the record you need
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
                    record.setValue(teamID, forKey: "teamID")
                    
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
        let agendaID = sourceRecord.object(forKey: "agendaID") as! Int32
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
        let timeAllocation = sourceRecord.object(forKey: "timeAllocation") as! Int16
        let title = sourceRecord.object(forKey: "title") as! String
        let meetingOrder = sourceRecord.object(forKey: "meetingOrder") as! Int32
        
        myDatabaseConnection.saveAgendaItem(meetingID, actualEndTime: actualEndTime, actualStartTime: actualStartTime, status: status, decisionMade: decisionMade, discussionNotes: discussionNotes, timeAllocation: timeAllocation, owner: owner, title: title, agendaID: agendaID, meetingOrder: meetingOrder, updateTime: updateTime, updateType: updateType)
    }
    
    func saveMeetingTasksToCloudKit()
    {
        //        NSLog("Syncing MeetingTasks")
        for myItem in myDatabaseConnection.getMeetingTasksForSync(myDatabaseConnection.getSyncDateForTable(tableName: "MeetingTasks"))
        {
            saveMeetingTasksRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }

    func updateMeetingTasksInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(teamID))", myDatabaseConnection.getSyncDateForTable(tableName: "MeetingTasks") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1

            self.updateMeetingTasksRecord(record)
            self.recordCount -= 1

            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func deleteMeetingTasks(teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performPublicDelete(myRecordList)
            sem.signal()
        })
        sem.wait()
    }

    func replaceMeetingTasksInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let meetingID = record.object(forKey: "meetingID") as! String
            let agendaID = record.object(forKey: "agendaID") as! Int32
            var updateTime = Date()
            if record.object(forKey: "updateTime") != nil
            {
                updateTime = record.object(forKey: "updateTime") as! Date
            }
            var updateType: String = ""
            if record.object(forKey: "updateType") != nil
            {
                updateType = record.object(forKey: "updateType") as! String
            }
            let taskID = record.object(forKey: "taskID") as! Int32
            
            myDatabaseConnection.replaceMeetingTask(agendaID, meetingID: meetingID, taskID: taskID, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveMeetingTasksRecordToCloudKit(_ sourceRecord: MeetingTasks, teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID!)\") && (agendaID == \(sourceRecord.agendaID)) && (taskID == \(sourceRecord.taskID)) AND (teamID == \(teamID))") // better be accurate to get only the
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
                    record.setValue(teamID, forKey: "teamID")
                    
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
        let meetingID = sourceRecord.object(forKey: "meetingID") as! String
        let agendaID = sourceRecord.object(forKey: "agendaID") as! Int32
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
        let taskID = sourceRecord.object(forKey: "taskID") as! Int32
        
        myDatabaseConnection.saveMeetingTask(agendaID, meetingID: meetingID, taskID: taskID, updateTime: updateTime, updateType: updateType)
    }
}
