//
//  outlineClass.swift
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
    func clearDeletedOutlines(predicate: NSPredicate)
    {
        let fetchRequest28 = NSFetchRequest<Outline>(entityName: "Outline")
        
        // Set the predicate on the fetch request
        fetchRequest28.predicate = predicate
        do
        {
            let fetchResults28 = try objectContext.fetch(fetchRequest28)
            for myItem28 in fetchResults28
            {
                objectContext.delete(myItem28 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedOutlines(predicate: NSPredicate)
    {
        let fetchRequest28 = NSFetchRequest<Outline>(entityName: "Outline")
        // Set the predicate on the fetch request
        fetchRequest28.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults28 = try objectContext.fetch(fetchRequest28)
            for myItem28 in fetchResults28
            {
                myItem28.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getOutlineForSync(_ inLastSyncDate: NSDate) -> [Outline]
    {
        let fetchRequest = NSFetchRequest<Outline>(entityName: "Outline")
        
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
    
    func deleteAllOutlineRecords()
    {
        let fetchRequest28 = NSFetchRequest<Outline>(entityName: "Outline")
        
        do
        {
            let fetchResults28 = try objectContext.fetch(fetchRequest28)
            for myItem28 in fetchResults28
            {
                self.objectContext.delete(myItem28 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func saveOutline(_ outlineID: Int, parentID: Int, parentType: String, title: String, status: String, updateTime: Date = Date(), updateType: String = "CODE")
    {
        var myOutline: Outline!
        
        let myOutlineItems = getOutline(outlineID)
        
        if myOutlineItems.count == 0
        { // Add
            myOutline = Outline(context: objectContext)
            myOutline.outlineID = outlineID as NSNumber?
            myOutline.parentID = parentID as NSNumber?
            myOutline.parentType = parentType
            myOutline.title = title
            myOutline.status = status
            
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
            myOutline.parentID = parentID as NSNumber?
            myOutline.parentType = parentType
            myOutline.title = title
            myOutline.status = status
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
        
        myCloudDB.saveOutlineRecordToCloudKit(myOutline)
    }
    
    func replaceOutline(_ outlineID: Int, parentID: Int, parentType: String, title: String, status: String, updateTime: Date = Date(), updateType: String = "CODE")
    {
        let myOutline = Outline(context: objectContext)
        myOutline.outlineID = outlineID as NSNumber?
        myOutline.parentID = parentID as NSNumber?
        myOutline.parentType = parentType
        myOutline.title = title
        myOutline.status = status
        
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
    
    func deleteOutline(_ outlineID: Int)
    {
        var myOutline: Outline!
        
        let myOutlineItems = getOutline(outlineID)
        
        if myOutlineItems.count > 0
        { // Update
            myOutline = myOutlineItems[0]
            myOutline.updateTime = NSDate()
            myOutline.updateType = "Delete"
        }
        saveContext()
    }
    
    func getOutline(_ outlineID: Int)->[Outline]
    {
        let fetchRequest = NSFetchRequest<Outline>(entityName: "Outline")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(outlineID == \"\(outlineID)\")")
        
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
    func saveOutlineToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing ProcessedEmails")
        for myItem in myDatabaseConnection.getOutlineForSync(inLastSyncDate)
        {
            saveOutlineRecordToCloudKit(myItem)
        }
    }

    func updateOutlineInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Outline", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateOutlineRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteOutline()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Outline", predicate: predicate)
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

    func replaceOutlineInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Outline", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let outlineID = record.object(forKey: "outlineID") as! Int
                let parentID = record.object(forKey: "parentID") as! Int
                let parentType = record.object(forKey: "parentType") as! String
                let title = record.object(forKey: "title") as! String
                let status = record.object(forKey: "status") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                
                myDatabaseConnection.replaceOutline(outlineID, parentID: parentID, parentType: parentType, title: title, status: status, updateTime: updateTime, updateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveOutlineRecordToCloudKit(_ sourceRecord: Outline)
    {
        let predicate = NSPredicate(format: "(outlineID == \(sourceRecord.outlineID!))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Outline", predicate: predicate)
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
                    record!.setValue(sourceRecord.parentID, forKey: "parentID")
                    record!.setValue(sourceRecord.parentType, forKey: "parentType")
                    record!.setValue(sourceRecord.title, forKey: "title")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    
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
                    let record = CKRecord(recordType: "Outline")
                    record.setValue(sourceRecord.outlineID, forKey: "outlineID")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.parentID, forKey: "parentID")
                    record.setValue(sourceRecord.parentType, forKey: "parentType")
                    record.setValue(sourceRecord.title, forKey: "title")
                    record.setValue(sourceRecord.status, forKey: "status")
                    
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

    func updateOutlineRecord(_ sourceRecord: CKRecord)
    {
        let outlineID = sourceRecord.object(forKey: "outlineID") as! Int
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
        let parentID = sourceRecord.object(forKey: "parentID") as! Int
        let parentType = sourceRecord.object(forKey: "parentType") as! String
        let title = sourceRecord.object(forKey: "title") as! String
        let status = sourceRecord.object(forKey: "status") as! String
        
        myDatabaseConnection.saveOutline(outlineID, parentID: parentID, parentType: parentType, title: title, status: status, updateTime: updateTime, updateType: updateType)
    }
}
