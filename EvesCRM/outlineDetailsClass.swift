//
//  outlineDetailsClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 24/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension coreDatabase
{
    func clearDeletedOutlineDetails(predicate: NSPredicate)
    {
        let fetchRequest29 = NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
        
        // Set the predicate on the fetch request
        fetchRequest29.predicate = predicate
        do
        {
            let fetchResults29 = try objectContext.fetch(fetchRequest29)
            for myItem29 in fetchResults29
            {
                objectContext.delete(myItem29 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedOutlineDetails(predicate: NSPredicate)
    {
        let fetchRequest29 = NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
        // Set the predicate on the fetch request
        fetchRequest29.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults29 = try objectContext.fetch(fetchRequest29)
            for myItem29 in fetchResults29
            {
                myItem29.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getOutlineDetailsForSync(_ syncDate: Date) -> [OutlineDetails]
    {
        let fetchRequest = NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
        
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
    
    func deleteAllOutLineDetailRecords()
    {
        let fetchRequest29 = NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
        
        do
        {
            let fetchResults29 = try objectContext.fetch(fetchRequest29)
            for myItem29 in fetchResults29
            {
                self.objectContext.delete(myItem29 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func saveOutlineDetail(_ outlineID: Int32, lineID: Int32, lineOrder: Int32, parentLine: Int32, lineText: String, lineType: String, checkBoxValue: Bool, updateTime: Date = Date(), updateType: String = "CODE")
    {
        var myOutline: OutlineDetails!
        
        let myOutlineItems = getOutlineDetails(outlineID, lineID: lineID)
        
        if myOutlineItems.count == 0
        { // Add
            myOutline = OutlineDetails(context: objectContext)
            myOutline.outlineID = outlineID
            myOutline.lineID = lineID
            myOutline.lineOrder = lineOrder
            myOutline.parentLine = parentLine
            myOutline.lineText = lineText
            myOutline.lineType = lineType
            myOutline.checkBoxValue = checkBoxValue as NSNumber?
            
            if updateType == "CODE"
            {
                myOutline.updateTime = NSDate()
                myOutline.updateType = "Add"
            }
            else
            {
                myOutline.updateTime = updateTime as NSDate
                myOutline.updateType = updateType
            }
        }
        else
        { // Update
            myOutline = myOutlineItems[0]
            myOutline.lineOrder = lineOrder
            myOutline.parentLine = parentLine
            myOutline.lineText = lineText
            myOutline.lineType = lineType
            myOutline.checkBoxValue = checkBoxValue as NSNumber?
            
            if updateType == "CODE"
            {
                if myOutline.updateType != "Add"
                {
                    myOutline.updateType = "Update"
                }
            }
            else
            {
                myOutline.updateTime = updateTime as NSDate
                myOutline.updateType = updateType
            }
        }
        
        saveContext()
        
        myCloudDB.saveOutlineDetailsRecordToCloudKit(myOutline)
    }
    
    func replaceOutlineDetails(_ outlineID: Int32, lineID: Int32, lineOrder: Int32, parentLine: Int32, lineText: String, lineType: String, checkBoxValue: Bool, updateTime: Date = Date(), updateType: String = "CODE")
    {
        let myOutline = OutlineDetails(context: objectContext)
        myOutline.outlineID = outlineID
        myOutline.lineID = lineID
        myOutline.lineOrder = lineOrder
        myOutline.parentLine = parentLine
        myOutline.lineText = lineText
        myOutline.lineType = lineType
        myOutline.checkBoxValue = checkBoxValue as NSNumber?
        
        if updateType == "CODE"
        {
            myOutline.updateTime = NSDate()
            myOutline.updateType = "Add"
        }
        else
        {
            myOutline.updateTime = updateTime as NSDate
            myOutline.updateType = updateType
        }
        
        saveContext()
    }
    
    func deleteOutlineDetails(_ outlineID: Int32, lineID: Int32)
    {
        var myOutline: OutlineDetails!
        
        let myOutlineItems = getOutlineDetails(outlineID, lineID: lineID)
        
        if myOutlineItems.count > 0
        { // Update
            myOutline = myOutlineItems[0]
            myOutline.updateTime = NSDate()
            myOutline.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getOutlineDetails(_ outlineID: Int32, lineID: Int32)->[OutlineDetails]
    {
        let fetchRequest = NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(outlineID == \"\(outlineID)\") && (lineID == \"\(lineID)\")")
        
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
}

extension CloudKitInteraction
{
    func saveOutlineDetailsToCloudKit()
    {
        for myItem in myDatabaseConnection.getOutlineDetailsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "OutlineDetails"))
        {
            saveOutlineDetailsRecordToCloudKit(myItem)
        }
    }

    func updateOutlineDetailsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "OutlineDetails") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "OutlineDetails", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.updateOutlineDetailsRecord(record)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func deleteOutlineDetails()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "OutlineDetails", predicate: predicate)
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

    func replaceOutlineDetailsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "OutlineDetails", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let outlineID = record.object(forKey: "outlineID") as! Int32
            let lineID = record.object(forKey: "lineID") as! Int32
            let lineOrder = record.object(forKey: "lineOrder") as! Int32
            let parentLine = record.object(forKey: "parentLine") as! Int32
            let lineText = record.object(forKey: "lineText") as! String
            let lineType = record.object(forKey: "lineType") as! String
            
            let checkBox = record.object(forKey: "checkBoxValue") as! String
            
            var checkBoxValue: Bool = false
            
            if checkBox == "True"
            {
                checkBoxValue = true
            }
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
            myDatabaseConnection.replaceOutlineDetails(outlineID, lineID: lineID, lineOrder: lineOrder, parentLine: parentLine, lineText: lineText, lineType: lineType, checkBoxValue: checkBoxValue, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveOutlineDetailsRecordToCloudKit(_ sourceRecord: OutlineDetails)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(outlineID == \(sourceRecord.outlineID)) && (lineID == \(sourceRecord.lineID)) AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "OutlineDetails", predicate: predicate)
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
                    record!.setValue(sourceRecord.lineOrder, forKey: "lineOrder")
                    record!.setValue(sourceRecord.parentLine, forKey: "parentLine")
                    record!.setValue(sourceRecord.lineText, forKey: "lineText")
                    record!.setValue(sourceRecord.lineType, forKey: "lineType")
                    
                    if sourceRecord.checkBoxValue == true
                    {
                        record!.setValue("True", forKey: "checkBoxValue")
                    }
                    else
                    {
                        record!.setValue("False", forKey: "checkBoxValue")
                    }
                    
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
                    let record = CKRecord(recordType: "OutlineDetails")
                    record.setValue(sourceRecord.outlineID, forKey: "outlineID")
                    record.setValue(sourceRecord.lineID, forKey: "lineID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.lineOrder, forKey: "lineOrder")
                    record.setValue(sourceRecord.parentLine, forKey: "parentLine")
                    record.setValue(sourceRecord.lineText, forKey: "lineText")
                    record.setValue(sourceRecord.lineType, forKey: "lineType")
                    record.setValue(myTeamID, forKey: "teamID")
                    
                    if sourceRecord.checkBoxValue == true
                    {
                        record.setValue("True", forKey: "checkBoxValue")
                    }
                    else
                    {
                        record.setValue("False", forKey: "checkBoxValue")
                    }
                    
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

    func updateOutlineDetailsRecord(_ sourceRecord: CKRecord)
    {
        let outlineID = sourceRecord.object(forKey: "outlineID") as! Int32
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
        let lineID = sourceRecord.object(forKey: "lineID") as! Int32
        let lineOrder = sourceRecord.object(forKey: "lineOrder") as! Int32
        let parentLine = sourceRecord.object(forKey: "parentLine") as! Int32
        let lineText = sourceRecord.object(forKey: "lineText") as! String
        let lineType = sourceRecord.object(forKey: "lineType") as! String
        
        let checkBox = sourceRecord.object(forKey: "checkBoxValue") as! String
        
        var checkBoxValue: Bool = false
        
        if checkBox == "True"
        {
            checkBoxValue = true
        }
        
        myDatabaseConnection.saveOutlineDetail(outlineID, lineID: lineID, lineOrder: lineOrder, parentLine: parentLine, lineText: lineText, lineType: lineType, checkBoxValue: checkBoxValue, updateTime: updateTime, updateType: updateType)
    }
}
