//
//  taskUpdatesClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class taskUpdates: NSObject
{
    fileprivate var myTaskID: Int = 0
    fileprivate var myUpdateDate: Date!
    fileprivate var myDetails: String = ""
    fileprivate var mySource: String = ""
    fileprivate var saveCalled: Bool = false
    fileprivate var myTeamID: Int = 0
    
    var updateDate: Date
    {
        get
        {
            return myUpdateDate
        }
    }
    
    var displayUpdateDate: String
    {
        get
        {
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateStyle = DateFormatter.Style.medium
            myDateFormatter.timeStyle = DateFormatter.Style.short
            return myDateFormatter.string(from: myUpdateDate)
        }
    }
    
    var displayShortUpdateDate: String
    {
        get
        {
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateStyle = DateFormatter.Style.medium
            return myDateFormatter.string(from: myUpdateDate)
        }
    }
    
    var displayShortUpdateTime: String
    {
        get
        {
            let myDateFormatter = DateFormatter()
            myDateFormatter.timeStyle = DateFormatter.Style.short
            return myDateFormatter.string(from: myUpdateDate)
        }
    }
    
    var details: String
    {
        get
        {
            return myDetails
        }
        set
        {
            myDetails = newValue
        }
    }
    
    var source: String
    {
        get
        {
            return mySource
        }
        set
        {
            mySource = newValue
        }
    }
    
    init(taskID: Int, teamID: Int)
    {
        myTaskID = taskID
        myTeamID = teamID
    }
    
    init(updateObject: TaskUpdates)
    {
        myTaskID = Int(updateObject.taskID)
        myUpdateDate = updateObject.updateDate as Date!
        myDetails = updateObject.details!
        mySource = updateObject.source!
        myTeamID = Int(updateObject.teamID)
    }
    
    func save()
    {
        myDatabaseConnection.saveTaskUpdate(myTaskID, details: myDetails, source: mySource, teamID: myTeamID)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        
        let myUpdate = myDatabaseConnection.getTaskUpdates(myTaskID, teamID: myTeamID)[0]
        
        myCloudDB.saveTaskUpdatesRecordToCloudKit(myUpdate)
        saveCalled = false
    }
}

extension coreDatabase
{
    func saveTaskUpdate(_ taskID: Int, details: String, source: String, teamID: Int, updateDate: Date =  Date(), updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myTaskUpdate: TaskUpdates!
        
        if getTaskUpdate(taskID, updateDate: updateDate as NSDate, teamID: teamID).count == 0
        {
            myTaskUpdate = TaskUpdates(context: objectContext)
            myTaskUpdate.taskID = Int64(taskID)
            myTaskUpdate.updateDate = updateDate as NSDate
            myTaskUpdate.details = details
            myTaskUpdate.source = source
            myTaskUpdate.teamID = Int64(teamID)
            
            if updateType == "CODE"
            {
                myTaskUpdate.updateTime =  NSDate()
                myTaskUpdate.updateType = "Add"
            }
            else
            {
                myTaskUpdate.updateTime = updateTime as NSDate
                myTaskUpdate.updateType = updateType
            }
            
            saveContext()
        }
        self.recordsProcessed += 1
    }
    
    func getTaskUpdate(_ taskID: Int, updateDate: NSDate, teamID: Int)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\") && (updateDate == %@)", updateDate as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
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
    
    func getTaskUpdates(_ taskID: Int, teamID: Int)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
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
    
    func resetTaskUpdateRecords()
    {
        let fetchRequest4 = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        do
        {
            let fetchResults4 = try objectContext.fetch(fetchRequest4)
            for myMeeting4 in fetchResults4
            {
                myMeeting4.updateTime =  NSDate()
                myMeeting4.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearDeletedTaskUpdates(predicate: NSPredicate)
    {
        let fetchRequest19 = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Set the predicate on the fetch request
        fetchRequest19.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults19 = try objectContext.fetch(fetchRequest19)
            for myItem19 in fetchResults19
            {
                objectContext.delete(myItem19 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedTaskUpdates(predicate: NSPredicate)
    {
        let fetchRequest19 = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Set the predicate on the fetch request
        fetchRequest19.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults19 = try objectContext.fetch(fetchRequest19)
            for myItem19 in fetchResults19
            {
                myItem19.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getTaskUpdatesForSync(_ syncDate: Date) -> [TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
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

    func deleteAllTaskUpdateRecords()
    {
        let fetchRequest19 = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults19 = try objectContext.fetch(fetchRequest19)
            for myItem19 in fetchResults19
            {
                self.objectContext.delete(myItem19 as NSManagedObject)
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
    func saveTaskUpdatesToCloudKit()
    {
        for myItem in myDatabaseConnection.getTaskUpdatesForSync(getSyncDateForTable(tableName: "TaskUpdates"))
        {
            saveTaskUpdatesRecordToCloudKit(myItem)
        }
    }

    func updateTaskUpdatesInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "TaskUpdates") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateTaskUpdatesRecord(record)
            }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "TaskUpdates", queryOperation: operation, onOperationQueue: operationQueue)
    }

//    func deleteTaskUpdates(teamID: Int)
//    {
//        let sem = DispatchSemaphore(value: 0);
//        
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
//        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
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

    func saveTaskUpdatesRecordToCloudKit(_ sourceRecord: TaskUpdates)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID)) && (updateDate == %@) AND (teamID == \(sourceRecord.teamID))", sourceRecord.updateDate!) // better be accurate to get only the record you need
        let query = CKQuery(recordType: "TaskUpdates", predicate: predicate)
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
                    record!.setValue(sourceRecord.details, forKey: "details")
                    record!.setValue(sourceRecord.source, forKey: "source")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
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
                    let record = CKRecord(recordType: "TaskUpdates")
                    record.setValue(sourceRecord.taskID, forKey: "taskID")
                    record.setValue(sourceRecord.updateDate, forKey: "updateDate")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.details, forKey: "details")
                    record.setValue(sourceRecord.source, forKey: "source")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
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

    func updateTaskUpdatesRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
        let updateDate = sourceRecord.object(forKey: "updateDate") as! Date
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
        let details = sourceRecord.object(forKey: "details") as! String
        let source = sourceRecord.object(forKey: "source") as! String
        
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
        myDatabaseConnection.saveTaskUpdate(taskID, details: details, source: source, teamID: teamID, updateDate: updateDate, updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
}
