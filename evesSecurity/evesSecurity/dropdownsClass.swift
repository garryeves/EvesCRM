//
//  dropdownsClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class dropdowns: NSObject
{
    fileprivate var myDropdowns:[dropdownItem] = Array()
    
    init(dropdownType: String)
    {
        for myItem in myDatabaseConnection.getDropdowns(dropdownType: dropdownType)
        {
            let myObject = dropdownItem(dropdownType: myItem.dropDownType!,
                                    dropdownName: myItem.dropDownName!,
                                   dropdownValue: myItem.dropDownValue!
                                   )
            myDropdowns.append(myObject)
        }
    }
    
    var dropdowns: [dropdownItem]
    {
        get
        {
            return myDropdowns
        }
    }
}

class dropdownItem: NSObject
{
    fileprivate var myDropdownName: String = ""
    fileprivate var myDropdownValue: String = ""
    fileprivate var myDropdownType: String = ""
  
    var dropdownType: String
    {
        get
        {
            return myDropdownType
        }
    }
    
    var dropdownName: String
    {
        get
        {
            return myDropdownName
        }
    }
    
    var dropdownValue: String
    {
        get
        {
            return myDropdownValue
        }
        set
        {
            myDropdownValue = newValue
            save()
        }
    }
    
    init(dropdownName: String, dropdownType: String)
    {
        super.init()
        
        myDropdownName = dropdownName
        myDropdownType = dropdownType
        save()
    }
    
    init(dropdownType: String, dropdownName: String, dropdownValue: String)
    {
        super.init()
        
        myDropdownName = dropdownName
        myDropdownType = dropdownType
        myDropdownValue = dropdownValue
        save()
    }
    
    func save()
    {
        myDatabaseConnection.saveDropdowns(myDropdownType, dropdownName: myDropdownName, dropdownValue: myDropdownValue)
    }
    
    func delete()
    {
        myDatabaseConnection.deleteDropdowns(myDropdownType, dropdownName: myDropdownName)
    }
}

extension coreDatabase
{
    func saveDropdowns(_ dropdownType: String,
                        dropdownName: String,
                        dropdownValue: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Dropdowns!
        
        let myReturn = getDropdownsDetails(dropdownType, dropdownName: dropdownName)
        
        if myReturn.count == 0
        { // Add
            myItem = Dropdowns(context: objectContext)
            myItem.dropDownType = dropdownType
            myItem.dropDownName = dropdownName
            myItem.dropDownValue = dropdownValue
            
            if updateType == "CODE"
            {
                myItem.updateTime =  NSDate()
                
                myItem.updateType = "Add"
            }
            else
            {
                myItem.updateTime = updateTime as NSDate
                myItem.updateType = updateType
            }
        }
        else
        {
            myItem = myReturn[0]
            myItem.dropDownValue = dropdownValue
            
            if updateType == "CODE"
            {
                myItem.updateTime =  NSDate()
                if myItem.updateType != "Add"
                {
                    myItem.updateType = "Update"
                }
            }
            else
            {
                myItem.updateTime = updateTime as NSDate
                myItem.updateType = updateType
            }
        }
        
        saveContext()
    }
    
    func replaceDropdowns(_ dropdownType: String,
                          dropdownName: String,
                          dropdownValue: String,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = Dropdowns(context: objectContext)
        myItem.dropDownType = dropdownType
        myItem.dropDownName = dropdownName
        myItem.dropDownValue = dropdownValue
        
        if updateType == "CODE"
        {
            myItem.updateTime =  NSDate()
            myItem.updateType = "Add"
        }
        else
        {
            myItem.updateTime = updateTime as NSDate
            myItem.updateType = updateType
        }
        
        saveContext()
    }
    
    func deleteDropdowns(_ dropdownType: String, dropdownName: String)
    {
        let myReturn = getDropdownsDetails(dropdownType, dropdownName: dropdownName)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getDropdowns(dropdownType: String)->[Dropdowns]
    {
        let fetchRequest = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(dropDownType == \"\(dropdownType)\") && (updateType != \"Delete\")")
        
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
    
    func getDropdownsDetails(_ dropdownType: String, dropdownName: String)->[Dropdowns]
    {
        let fetchRequest = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(dropDownType == \"\(dropdownType)\") AND (dropDownName == \"\(dropdownName)\") && (updateType != \"Delete\")")
        
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
    
    func resetAllDropdowns()
    {
        let fetchRequest = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
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
    
    func clearDeletedDropdowns(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                objectContext.delete(myItem2 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func clearSyncedDropdowns(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                myItem2.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getDropdownsForSync(_ syncDate: Date) -> [Dropdowns]
    {
        let fetchRequest = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
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
    
    func deleteAllDropdowns()
    {
        let fetchRequest2 = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                self.objectContext.delete(myItem2 as NSManagedObject)
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
    func saveDropdownsToCloudKit()
    {
        for myItem in myDatabaseConnection.getDropdownsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Dropdowns"))
        {
            saveDropdownsRecordToCloudKit(myItem)
        }
    }
    
    func updateDropdownsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "Dropdowns") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Dropdowns", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateDropdownsRecord(record)
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
    
    func deleteDropdowns(dropdownType: String, dropdownName: String)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID)) AND (dropDownType == \"\(dropdownType)\") AND (dropDownName == \"\(dropdownName)\")")
        let query: CKQuery = CKQuery(recordType: "Dropdowns", predicate: predicate)
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
    
    func replaceDropdownsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "Dropdowns", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in

            let dropdownType = record.object(forKey: "dropDownType") as! String
            let dropDownName = record.object(forKey: "dropDownName") as! String
            let dropDownValue = record.object(forKey: "dropDownValue") as! String
            
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
            
            myDatabaseConnection.replaceDropdowns(dropdownType,
                                                dropdownName: dropDownName,
                                                dropdownValue: dropDownValue
                                                , updateTime: updateTime, updateType: updateType)
            
            usleep(useconds_t(self.sleepTime))
        }
        
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }
    
    func saveDropdownsRecordToCloudKit(_ sourceRecord: Dropdowns)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(dropDownType == \"\(sourceRecord.dropDownType!)\") AND (dropDownName == \"\(sourceRecord.dropDownName!)\") AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Dropdowns", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.dropDownValue, forKey: "dropDownValue")
                    
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
                    let record = CKRecord(recordType: "Dropdowns")
                    record.setValue(sourceRecord.dropDownType, forKey: "dropDownType")
                    record.setValue(sourceRecord.dropDownName, forKey: "dropDownName")
                    record.setValue(sourceRecord.dropDownValue, forKey: "dropDownValue")
                    
                    record.setValue(myTeamID, forKey: "teamID")
                    
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
    
    func updateDropdownsRecord(_ sourceRecord: CKRecord)
    {
        let dropdownType = sourceRecord.object(forKey: "dropDownType") as! String
        let dropDownName = sourceRecord.object(forKey: "dropDownName") as! String
        let dropDownValue = sourceRecord.object(forKey: "dropDownValue") as! String
        
        var updateTime = Date()
        if sourceRecord.object(forKey: "updateTime") != nil
        {
            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
        }
        
        var updateType: String = ""
        if sourceRecord.object(forKey: "updateType") != nil
        {
            updateType = sourceRecord.object(forKey: "updateType") as! String
        }
        
        myDatabaseConnection.saveDropdowns(dropdownType,
                                         dropdownName: dropDownName,
                                         dropdownValue: dropDownValue
                                         , updateTime: updateTime, updateType: updateType)
    }
}

