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
    fileprivate var myTaskID: Int32 = 0
    fileprivate var myUpdateDate: Date!
    fileprivate var myDetails: String = ""
    fileprivate var mySource: String = ""
    fileprivate var saveCalled: Bool = false
    
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
    
    init(inTaskID: Int32)
    {
        myTaskID = inTaskID
        
    }
    
    init(inUpdate: TaskUpdates)
    {
        myTaskID = inUpdate.taskID
        myUpdateDate = inUpdate.updateDate as Date!
        myDetails = inUpdate.details!
        mySource = inUpdate.source!
    }
    
    func save()
    {
        myDatabaseConnection.saveTaskUpdate(myTaskID, inDetails: myDetails, inSource: mySource)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(workingGTDLevel.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        
        let myUpdate = myDatabaseConnection.getTaskUpdates(myTaskID)[0]
        
        myCloudDB.saveTaskUpdatesRecordToCloudKit(myUpdate)
        saveCalled = false
    }
}

extension coreDatabase
{
    func saveTaskUpdate(_ inTaskID: Int32, inDetails: String, inSource: String, inUpdateDate: Date =  Date(), inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myTaskUpdate: TaskUpdates!
        
        if getTaskUpdate(inTaskID, updateDate: inUpdateDate as NSDate).count == 0
        {
            myTaskUpdate = TaskUpdates(context: objectContext)
            myTaskUpdate.taskID = inTaskID
            myTaskUpdate.updateDate = inUpdateDate as NSDate
            myTaskUpdate.details = inDetails
            myTaskUpdate.source = inSource
            if inUpdateType == "CODE"
            {
                myTaskUpdate.updateTime =  NSDate()
                myTaskUpdate.updateType = "Add"
            }
            else
            {
                myTaskUpdate.updateTime = inUpdateTime as NSDate
                myTaskUpdate.updateType = inUpdateType
            }
            
            saveContext()
        }
    }
    
    func replaceTaskUpdate(_ inTaskID: Int32, inDetails: String, inSource: String, inUpdateDate: Date =  Date(), inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        
        let myTaskUpdate = TaskUpdates(context: objectContext)
        myTaskUpdate.taskID = inTaskID
        myTaskUpdate.updateDate = inUpdateDate as NSDate
        myTaskUpdate.details = inDetails
        myTaskUpdate.source = inSource
        if inUpdateType == "CODE"
        {
            myTaskUpdate.updateTime =  NSDate()
            myTaskUpdate.updateType = "Add"
        }
        else
        {
            myTaskUpdate.updateTime = inUpdateTime as NSDate
            myTaskUpdate.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func getTaskUpdate(_ taskID: Int32, updateDate: NSDate)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (updateDate == %@)", updateDate as CVarArg)
        
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
    
    func getTaskUpdates(_ inTaskID: Int32)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
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
    
    func getTaskUpdatesForSync(_ inLastSyncDate: NSDate) -> [TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
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
    func saveTaskUpdatesToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing TaskUpdates")
        for myItem in myDatabaseConnection.getTaskUpdatesForSync(inLastSyncDate)
        {
            saveTaskUpdatesRecordToCloudKit(myItem)
        }
    }

    func updateTaskUpdatesInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateTaskUpdatesRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteTaskUpdates()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
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

    func replaceTaskUpdatesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let taskID = record.object(forKey: "taskID") as! Int32
                let updateDate = record.object(forKey: "updateDate") as! Date
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let details = record.object(forKey: "details") as! String
                let source = record.object(forKey: "source") as! String
                
                myDatabaseConnection.replaceTaskUpdate(taskID, inDetails: details, inSource: source, inUpdateDate: updateDate, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveTaskUpdatesRecordToCloudKit(_ sourceRecord: TaskUpdates)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID)) && (updateDate == %@)", sourceRecord.updateDate!) // better be accurate to get only the record you need
        let query = CKQuery(recordType: "TaskUpdates", predicate: predicate)
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
                    record!.setValue(sourceRecord.details, forKey: "details")
                    record!.setValue(sourceRecord.source, forKey: "source")
                    
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
                    let record = CKRecord(recordType: "TaskUpdates")
                    record.setValue(sourceRecord.taskID, forKey: "taskID")
                    record.setValue(sourceRecord.updateDate, forKey: "updateDate")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.details, forKey: "details")
                    record.setValue(sourceRecord.source, forKey: "source")
                    
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

    func updateTaskUpdatesRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int32
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
        
        myDatabaseConnection.saveTaskUpdate(taskID, inDetails: details, inSource: source, inUpdateDate: updateDate, inUpdateTime: updateTime, inUpdateType: updateType)
    }
}
