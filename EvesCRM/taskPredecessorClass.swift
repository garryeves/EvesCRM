//
//  taskPredecessorClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class taskPredecessor: NSObject
{
    fileprivate var myPredecessorID: Int32 = 0
    fileprivate var myPredecessorType: String = ""
    
    var predecessorID: Int32
    {
        get
        {
            return myPredecessorID
        }
        set
        {
            myPredecessorID = newValue
        }
    }
    
    var predecessorType: String
    {
        get
        {
            return myPredecessorType
        }
        set
        {
            myPredecessorType = newValue
        }
    }
    
    init(predecessorID: Int32, predecessorType: String)
    {
        myPredecessorID = predecessorID
        myPredecessorType = predecessorType
    }
}

extension coreDatabase
{
    func getTaskPredecessors(_ taskID: Int32)->[TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\")")
        
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
    
    func savePredecessorTask(_ taskID: Int32, predecessorID: Int32, predecessorType: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myTask: TaskPredecessor!
        
        let myTasks = getTaskPredecessors(taskID)
        
        if myTasks.count == 0
        { // Add
            myTask = TaskPredecessor(context: objectContext)
            myTask.taskID = taskID
            myTask.predecessorID = predecessorID
            myTask.predecessorType = predecessorType
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
        { // Update
            myTask.predecessorID = predecessorID
            myTask.predecessorType = predecessorType
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
        
        myCloudDB.saveTaskPredecessorRecordToCloudKit(myTask)
    }
    
    func replacePredecessorTask(_ taskID: Int32, predecessorID: Int32, predecessorType: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myTask = TaskPredecessor(context: objectContext)
        myTask.taskID = taskID
        myTask.predecessorID = predecessorID
        myTask.predecessorType = predecessorType
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
    
    func updatePredecessorTaskType(_ taskID: Int32, predecessorID: Int32, predecessorType: String)
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (predecessorID == \(predecessorID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.predecessorType = predecessorType
                myStage.updateTime =  NSDate()
                if myStage.updateType != "Add"
                {
                    myStage.updateType = "Update"
                }
                
                myCloudDB.saveTaskPredecessorRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func deleteTaskPredecessor(_ taskID: Int32, predecessorID: Int32)
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (predecessorID == \(predecessorID))")
        
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
                
                myCloudDB.saveTaskPredecessorRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearDeletedTaskPredecessor(predicate: NSPredicate)
    {
        let fetchRequest21 = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        // Set the predicate on the fetch request
        fetchRequest21.predicate = predicate
        do
        {
            let fetchResults21 = try objectContext.fetch(fetchRequest21)
            for myItem21 in fetchResults21
            {
                objectContext.delete(myItem21 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedTaskPredecessor(predicate: NSPredicate)
    {
        let fetchRequest21 = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        // Set the predicate on the fetch request
        fetchRequest21.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem object
        do
        {
            let fetchResults21 = try objectContext.fetch(fetchRequest21)
            for myItem21 in fetchResults21
            {
                myItem21.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    func getTaskPredecessorsForSync(_ syncDate: Date) -> [TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
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

    func deleteAllTaskPredecessorRecords()
    {
        let fetchRequest21 = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        do
        {
            let fetchResults21 = try objectContext.fetch(fetchRequest21)
            for myItem21 in fetchResults21
            {
                self.objectContext.delete(myItem21 as NSManagedObject)
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
    func saveTaskPredecessorToCloudKit()
    {
        for myItem in myDatabaseConnection.getTaskPredecessorsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "TaskPredecessor"))
        {
            saveTaskPredecessorRecordToCloudKit(myItem)
        }
    }

    func updateTaskPredecessorInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", myDatabaseConnection.getSyncDateForTable(tableName: "TaskPredecessor") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.updateTaskPredecessorRecord(record)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executeQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func deleteTaskPredecessor()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
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

    func replaceTaskPredecessorInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let taskID = record.object(forKey: "taskID") as! Int32
            let predecessorID = record.object(forKey: "predecessorID") as! Int32
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
            let predecessorType = record.object(forKey: "predecessorType") as! String
            
            myDatabaseConnection.replacePredecessorTask(taskID, predecessorID: predecessorID, predecessorType: predecessorType, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executeQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveTaskPredecessorRecordToCloudKit(_ sourceRecord: TaskPredecessor)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID)) && (predecessorID == \(sourceRecord.predecessorID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
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
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.predecessorType, forKey: "predecessorType")
                    
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
                    let record = CKRecord(recordType: "TaskPredecessor")
                    record.setValue(sourceRecord.taskID, forKey: "taskID")
                    record.setValue(sourceRecord.predecessorID, forKey: "predecessorID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.predecessorType, forKey: "predecessorType")
                    
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
            sem.signal()
        })
        sem.wait()
    }

    func updateTaskPredecessorRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int32
        let predecessorID = sourceRecord.object(forKey: "predecessorID") as! Int32
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
        let predecessorType = sourceRecord.object(forKey: "predecessorType") as! String
        
        myDatabaseConnection.savePredecessorTask(taskID, predecessorID: predecessorID, predecessorType: predecessorType, updateTime: updateTime, updateType: updateType)
    }
}
