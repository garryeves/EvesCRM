//
//  taskContextsClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension coreDatabase
{
    func getTaskWithoutContext(_ teamID: Int)->[Task]
    {
        // first get a list of all tasks that have a context
        
        let fetchContext = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate1 = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchContext.predicate = predicate1
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        
        var fetchContextResults: [TaskContext] = Array()
        
        do
        {
            fetchContextResults = try objectContext.fetch(fetchContext)
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        // Get the list of all current tasks
        let fetchTask = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate2 = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\") && (status != \"Complete\")")
        
        // Set the predicate on the fetch request
        fetchTask.predicate = predicate2
        
        var fetchTaskResults: [Task] = Array()
        
        do
        {
            fetchTaskResults = try objectContext.fetch(fetchTask)
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        // Execute the fetch request, and cast the results to an array of LogItem objects
        
        var myTaskArray: [Task] = Array()
        var taskFound: Bool = false
        
        for myTask in fetchTaskResults
        {
            // loop though the context tasks
            taskFound = false
            for myContext in fetchContextResults
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

    func saveTaskContext(_ contextID: Int, taskID: Int, teamID: Int, contextType: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myContext: TaskContext!
        
        let myContexts = getTaskContext(contextID, taskID: taskID, teamID: teamID)
        
        if myContexts.count == 0
        { // Add
            myContext = TaskContext(context: objectContext)
            myContext.contextID = Int64(contextID)
            myContext.taskID = Int64(taskID)
            myContext.teamID = Int64(teamID)
            myContext.contextType = contextType
            
            if updateType == "CODE"
            {
                myContext.updateTime =  NSDate()
                myContext.updateType = "Add"
            }
            else
            {
                myContext.updateTime = updateTime as NSDate
                myContext.updateType = updateType
            }
        }
        else
        {
            myContext = myContexts[0]
            myContext.contextType = contextType
            if updateType == "CODE"
            {
                myContext.updateTime =  NSDate()
                if myContext.updateType != "Add"
                {
                    myContext.updateType = "Update"
                }
            }
            else
            {
                myContext.updateTime = updateTime as NSDate
                myContext.updateType = updateType
            }
        }
        
        saveContext()
        
        myCloudDB.saveTaskContextRecordToCloudKit(myContext)
    }
    
    func deleteTaskContext(_ contextID: Int, taskID: Int, teamID: Int)
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        let predicate = NSPredicate(format: "(contextID == \(contextID)) AND (teamID == \(teamID)) AND (taskID = \(taskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.updateTime =  NSDate()
                myStage.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    private func getTaskContext(_ contextID: Int, taskID: Int, teamID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(taskID)) AND (teamID == \(teamID)) AND (contextID = \(contextID)) && (updateType != \"Delete\")")
        
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
    
    func getContextsForTask(_ taskID: Int, teamID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(taskID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
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
    
    func getTasksForContext(_ contextID: Int, teamID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID = \(contextID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
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

    func resetTaskContextRecords()
    {
        let fetchRequest3 = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
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
    
    func clearDeletedTaskContexts(predicate: NSPredicate)
    {
        let fetchRequest18 = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Set the predicate on the fetch request
        fetchRequest18.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults18 = try objectContext.fetch(fetchRequest18)
            for myItem18 in fetchResults18
            {
                objectContext.delete(myItem18 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedTaskContexts(predicate: NSPredicate)
    {
        let fetchRequest18 = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Set the predicate on the fetch request
        fetchRequest18.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults18 = try objectContext.fetch(fetchRequest18)
            for myItem18 in fetchResults18
            {
                myItem18.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getTaskContextsForSync(_ syncDate: Date) -> [TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
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

    func deleteAllTaskContextRecords()
    {
        let fetchRequest18 = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults18 = try objectContext.fetch(fetchRequest18)
            for myItem18 in fetchResults18
            {
                self.objectContext.delete(myItem18 as NSManagedObject)
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
    func saveTaskContextToCloudKit()
    {
        for myItem in myDatabaseConnection.getTaskContextsForSync(getSyncDateForTable(tableName: "TaskContext"))
        {
            saveTaskContextRecordToCloudKit(myItem)
        }
    }

    func updateTaskContextInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "TaskContext") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
                self.updateTaskContextRecord(record)
            }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "TaskContext", queryOperation: operation, onOperationQueue: operationQueue)
    }

//    func deleteTaskContext(teamID: Int)
//    {
//        let sem = DispatchSemaphore(value: 0);
//        
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
//        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
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

    func saveTaskContextRecordToCloudKit(_ sourceRecord: TaskContext)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID)) AND (contextID == \(sourceRecord.contextID)) AND (contextType == \"\(sourceRecord.contextType!)\") AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "TaskContext", predicate: predicate)
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
                    let record = CKRecord(recordType: "TaskContext")
                    record.setValue(sourceRecord.taskID, forKey: "taskID")
                    record.setValue(sourceRecord.contextID, forKey: "contextID")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    
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

    func updateTaskContextRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
        let contextID = sourceRecord.object(forKey: "contextID") as! Int
        let contextType = sourceRecord.object(forKey: "contextType") as! String
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
        
        myDatabaseConnection.saveTaskContext(contextID, taskID: taskID, teamID: teamID, contextType: contextType, updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
}
