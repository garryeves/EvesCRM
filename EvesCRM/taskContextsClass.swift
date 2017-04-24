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

    func saveTaskContext(_ inContextID: Int, inTaskID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myContext: TaskContext!
        
        let myContexts = getTaskContext(inContextID, inTaskID: inTaskID)
        
        if myContexts.count == 0
        { // Add
            myContext = TaskContext(context: objectContext)
            myContext.contextID = NSNumber(value: inContextID)
            myContext.taskID = NSNumber(value: inTaskID)
            if inUpdateType == "CODE"
            {
                myContext.updateTime =  Date()
                myContext.updateType = "Add"
            }
            else
            {
                myContext.updateTime = inUpdateTime
                myContext.updateType = inUpdateType
            }
        }
        else
        {
            myContext = myContexts[0]
            if inUpdateType == "CODE"
            {
                myContext.updateTime =  Date()
                if myContext.updateType != "Add"
                {
                    myContext.updateType = "Update"
                }
            }
            else
            {
                myContext.updateTime = inUpdateTime
                myContext.updateType = inUpdateType
            }
        }
        
        saveContext()
        
        myCloudDB.saveTaskContextRecordToCloudKit(myContext)
    }
    
    func replaceTaskContext(_ inContextID: Int, inTaskID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        
        let myContext = TaskContext(context: objectContext)
        myContext.contextID = NSNumber(value: inContextID)
        myContext.taskID = NSNumber(value: inTaskID)
        if inUpdateType == "CODE"
        {
            myContext.updateTime =  Date()
            myContext.updateType = "Add"
        }
        else
        {
            myContext.updateTime = inUpdateTime
            myContext.updateType = inUpdateType
        }
        saveContext()
    }
    
    func deleteTaskContext(_ inContextID: Int, inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        let predicate = NSPredicate(format: "(contextID == \(inContextID)) AND (taskID = \(inTaskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.updateTime =  Date()
                myStage.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    private func getTaskContext(_ inContextID: Int, inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) AND (contextID = \(inContextID)) && (updateType != \"Delete\")")
        
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
    
    func getContextsForTask(_ inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) && (updateType != \"Delete\")")
        
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
    
    func getTasksForContext(_ inContextID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID = \(inContextID)) && (updateType != \"Delete\")")
        
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
                myMeeting3.updateTime =  Date()
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
    
    func getTaskContextsForSync(_ inLastSyncDate: NSDate) -> [TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
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
    func saveTaskContextToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing TaskContext")
        for myItem in myDatabaseConnection.getTaskContextsForSync(inLastSyncDate)
        {
            saveTaskContextRecordToCloudKit(myItem)
        }
    }

    func updateTaskContextInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateTaskContextRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteTaskContext()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            sem.signal()
        })
        sem.wait()
    }

    func replaceTaskContextInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let taskID = record.object(forKey: "taskID") as! Int
                let contextID = record.object(forKey: "contextID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                
                myDatabaseConnection.replaceTaskContext(contextID, inTaskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveTaskContextRecordToCloudKit(_ sourceRecord: TaskContext)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as! Int)) && (contextID == \(sourceRecord.contextID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "TaskContext", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
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
                    record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    // Save this record again
                    self.privateDB.save(record!, completionHandler: { (savedRecord, saveError) in
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
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    
                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
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
        })
    }

    func updateTaskContextRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
        let contextID = sourceRecord.object(forKey: "contextID") as! Int
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
        
        myDatabaseConnection.saveTaskContext(contextID, inTaskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
}
