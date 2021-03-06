//
//  TaskAttachmentClass.swift
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
    func clearDeletedTaskAttachments(predicate: NSPredicate)
    {
        let fetchRequest17 = NSFetchRequest<TaskAttachment>(entityName: "TaskAttachment")
        
        // Set the predicate on the fetch request
        fetchRequest17.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults17 = try objectContext.fetch(fetchRequest17)
            for myItem17 in fetchResults17
            {
                objectContext.delete(myItem17 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedTaskAttachments(predicate: NSPredicate)
    {
        let fetchRequest17 = NSFetchRequest<TaskAttachment>(entityName: "TaskAttachment")
        
        // Set the predicate on the fetch request
        fetchRequest17.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults17 = try objectContext.fetch(fetchRequest17)
            for myItem17 in fetchResults17
            {
                myItem17.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    func getTaskAttachmentsForSync(_ syncDate: Date) -> [TaskAttachment]
    {
        let fetchRequest = NSFetchRequest<TaskAttachment>(entityName: "TaskAttachment")
        
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
    
    func deleteAllTaskAttachmentRecords()
    {
        let fetchRequest17 = NSFetchRequest<TaskAttachment>(entityName: "TaskAttachment")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults17 = try objectContext.fetch(fetchRequest17)
            for myItem17 in fetchResults17
            {
                self.objectContext.delete(myItem17 as NSManagedObject)
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
    func saveTaskAttachmentToCloudKit()
    {
        for myItem in myDatabaseConnection.getTaskAttachmentsForSync(getSyncDateForTable(tableName: "TaskAttachment"))
        {
            saveTaskAttachmentRecordToCloudKit(myItem)
        }
    }

    func updateTaskAttachmentInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "TaskAttachment") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskAttachment", predicate: predicate)
        let operation = CKQueryOperation(query: query)

        operation.recordFetchedBlock = { (record) in
            self.updateTaskAttachmentRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "TaskAttachment", queryOperation: operation, onOperationQueue: operationQueue)
    }

//    func deleteTaskAttachment()
//    {
//        let sem = DispatchSemaphore(value: 0);
//        
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
//        let query: CKQuery = CKQuery(recordType: "TaskAttachment", predicate: predicate)
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

    func saveTaskAttachmentRecordToCloudKit(_ sourceRecord: TaskAttachment)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID)) && (title == \"\(sourceRecord.title!)\") AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "TaskAttachment", predicate: predicate)
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
                    record!.setValue(sourceRecord.attachment, forKey: "attachment")
                    
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
                    let record = CKRecord(recordType: "TaskAttachment")
                    record.setValue(sourceRecord.taskID, forKey: "taskID")
                    record.setValue(sourceRecord.title, forKey: "title")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.attachment, forKey: "attachment")
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

    func updateTaskAttachmentRecord(_ sourceRecord: CKRecord)
    {
        //    let taskID = sourceRecord.objectForKey("taskID") as! Int
        //    let title = sourceRecord.objectForKey("title") as! String
        //        var updateTime = NSDate()
        //        if sourceRecord.objectForKey("updateTime") != nil
        //        {
        //            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        //        }
        
        //        var updateType = ""
        
        //       if sourceRecord.objectForKey("updateType") != nil
        //       {
        //           updateType = sourceRecord.objectForKey("updateType") as! String
        //       }
        //    let attachment = sourceRecord.objectForKey("attachment") as! NSData
        NSLog("updateTaskAttachmentInCoreData - Still to be coded")
        
//        myDatabaseConnection.recordsToChange += 1
//        
//        while self.recordCount > 0
//        {
//            usleep(self.sleepTime)
//        }
//        
//        self.recordCount += 1
        //   myDatabaseConnection.updateDecodeValue(decodeName! as! String, codeValue: decodeValue! as! String, codeType: decodeType! as! String)
//        self.recordCount -= 1
    }
}
