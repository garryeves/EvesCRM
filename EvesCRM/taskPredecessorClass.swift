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
    fileprivate var myPredecessorID: Int = 0
    fileprivate var myPredecessorType: String = ""
    
    var predecessorID: Int
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
    
    init(inPredecessorID: Int, inPredecessorType: String)
    {
        myPredecessorID = inPredecessorID
        myPredecessorType = inPredecessorType
    }
}

extension coreDatabase
{
    func getTaskPredecessors(_ inTaskID: Int)->[TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
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
    
    func savePredecessorTask(_ inTaskID: Int, inPredecessorID: Int, inPredecessorType: String, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myTask: TaskPredecessor!
        
        let myTasks = getTaskPredecessors(inTaskID)
        
        if myTasks.count == 0
        { // Add
            myTask = TaskPredecessor(context: objectContext)
            myTask.taskID = NSNumber(value: inTaskID)
            myTask.predecessorID = NSNumber(value: inPredecessorID)
            myTask.predecessorType = inPredecessorType
            if inUpdateType == "CODE"
            {
                myTask.updateTime =  Date()
                myTask.updateType = "Add"
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }
        }
        else
        { // Update
            myTask.predecessorID = NSNumber(value: inPredecessorID)
            myTask.predecessorType = inPredecessorType
            if inUpdateType == "CODE"
            {
                myTask.updateTime =  Date()
                if myTask.updateType != "Add"
                {
                    myTask.updateType = "Update"
                }
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }
        }
        
        saveContext()
        
        myCloudDB.saveTaskPredecessorRecordToCloudKit(myTask)
    }
    
    func replacePredecessorTask(_ inTaskID: Int, inPredecessorID: Int, inPredecessorType: String, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myTask = TaskPredecessor(context: objectContext)
        myTask.taskID = NSNumber(value: inTaskID)
        myTask.predecessorID = NSNumber(value: inPredecessorID)
        myTask.predecessorType = inPredecessorType
        if inUpdateType == "CODE"
        {
            myTask.updateTime =  Date()
            myTask.updateType = "Add"
        }
        else
        {
            myTask.updateTime = inUpdateTime
            myTask.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func updatePredecessorTaskType(_ inTaskID: Int, inPredecessorID: Int, inPredecessorType: String)
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (predecessorID == \(inPredecessorID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.predecessorType = inPredecessorType
                myStage.updateTime =  Date()
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
    
    func deleteTaskPredecessor(_ inTaskID: Int, inPredecessorID: Int)
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (predecessorID == \(inPredecessorID))")
        
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
    func getTaskPredecessorsForSync(_ inLastSyncDate: NSDate) -> [TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
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
    func saveTaskPredecessorToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing TaskPredecessor")
        for myItem in myDatabaseConnection.getTaskPredecessorsForSync(inLastSyncDate)
        {
            saveTaskPredecessorRecordToCloudKit(myItem)
        }
    }

    func updateTaskPredecessorInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateTaskPredecessorRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
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
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let taskID = record.object(forKey: "taskID") as! Int
                let predecessorID = record.object(forKey: "predecessorID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let predecessorType = record.object(forKey: "predecessorType") as! String
                
                myDatabaseConnection.replacePredecessorTask(taskID, inPredecessorID: predecessorID, inPredecessorType: predecessorType, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveTaskPredecessorRecordToCloudKit(_ sourceRecord: TaskPredecessor)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as! Int)) && (predecessorID == \(sourceRecord.predecessorID as! Int))") // better be accurate to get only the record you need
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
                    record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
        })
    }

    func updateTaskPredecessorRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
        let predecessorID = sourceRecord.object(forKey: "predecessorID") as! Int
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
        
        myDatabaseConnection.savePredecessorTask(taskID, inPredecessorID: predecessorID, inPredecessorType: predecessorType, inUpdateTime: updateTime, inUpdateType: updateType)
    }
}
