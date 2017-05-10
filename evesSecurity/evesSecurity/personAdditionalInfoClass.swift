//
//  personAdditionalInfoClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class personAdditionalInfos: NSObject
{
    fileprivate var myAdditional:[personAdditionalInfo] = Array()
    
    override init()
    {
        for myItem in myDatabaseConnection.getPersonAdditionalInfo()
        {
            let myObject = personAdditionalInfo(addInfoID: myItem.addInfoID,
                                   addInfoName: myItem.addInfoName!,
                addInfoType: myItem.addInfoType!
                                   )
            myAdditional.append(myObject)
        }
    }
    
    var personAdditionalInfos: [personAdditionalInfo]
    {
        get
        {
            return myAdditional
        }
    }
}

class personAdditionalInfo: NSObject
{
    fileprivate var myAddInfoID: Int32 = 0
    fileprivate var myAddInfoName: String = ""
    fileprivate var myAddInfoType: String = ""
    
    
    var addInfoID: Int32
    {
        get
        {
            return myAddInfoID
        }
    }
    
    var addInfoName: String
    {
        get
        {
            return myAddInfoName
        }
        set
        {
            myAddInfoName = newValue
            save()
        }
    }
    
    var addInfoType: String
    {
        get
        {
            return myAddInfoType
        }
        set
        {
            myAddInfoType = newValue
            save()
        }
    }
    
    override init()
    {
        super.init()
        
        myAddInfoID = myDatabaseConnection.getNextID("personAdditionalInfo")
        
        save()
    }
    
    init(addInfoID: Int32)
    {
        super.init()
        let myReturn = myDatabaseConnection.getPersonAdditionalInfoDetails(addInfoID)
        
        for myItem in myReturn
        {
            myAddInfoID = myItem.addInfoID
            myAddInfoName = myItem.addInfoName!
            myAddInfoType = myItem.addInfoType!
        }
    }
    
    init(addInfoID: Int32,
         addInfoName: String,
         addInfoType: String
         )
    {
        super.init()
        
        myAddInfoID = addInfoID
        myAddInfoName = addInfoName
        myAddInfoType = addInfoType
    }
    
    func save()
    {
        myDatabaseConnection.savePersonAdditionalInfo(myAddInfoID,
                                         addInfoName: myAddInfoName,
                                         addInfoType: myAddInfoType
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deletePersonAdditionalInfo(myAddInfoID)
    }
}

extension coreDatabase
{
    func savePersonAdditionalInfo(_ addInfoID: Int32,
                     addInfoName: String,
                     addInfoType: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: PersonAdditionalInfo!
        
        let myReturn = getPersonAdditionalInfoDetails(addInfoID)
        
        if myReturn.count == 0
        { // Add
            myItem = PersonAdditionalInfo(context: objectContext)
            myItem.addInfoID = addInfoID
            myItem.addInfoName = addInfoName
            myItem.addInfoType = addInfoType
            
            
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
            myItem.addInfoName = addInfoName
            myItem.addInfoType = addInfoType
            
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
    
    func replacePersonAdditionalInfo(_ addInfoID: Int32,
                        addInfoName: String,
                        addInfoType: String,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = PersonAdditionalInfo(context: objectContext)
        myItem.addInfoID = addInfoID
        myItem.addInfoName = addInfoName
        myItem.addInfoType = addInfoType
        
        
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
    
    func deletePersonAdditionalInfo(_ addInfoID: Int32)
    {
        let myReturn = getPersonAdditionalInfoDetails(addInfoID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getPersonAdditionalInfo()->[PersonAdditionalInfo]
    {
        let fetchRequest = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
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
    
    func getPersonAdditionalInfoDetails(_ addInfoID: Int32)->[PersonAdditionalInfo]
    {
        let fetchRequest = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(addInfoID == \(addInfoID)) && (updateType != \"Delete\")")
        
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
    
    func resetAllPersonAdditionalInfoDetails()
    {
        let fetchRequest = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
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
    
    func clearDeletedPersonAdditionalInfo(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
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
    
    func clearSyncedPersonAdditionalInfo(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
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
    
    func getPersonAdditionalInfoForSync(_ syncDate: Date) -> [PersonAdditionalInfo]
    {
        let fetchRequest = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
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
    
    func deleteAllPersonAdditionalInfo()
    {
        let fetchRequest2 = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
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
    func savePersonAdditionalInfoToCloudKit()
    {
        for myItem in myDatabaseConnection.getPersonAdditionalInfoForSync(myDatabaseConnection.getSyncDateForTable(tableName: "PersonAdditionalInfo"))
        {
            savePersonAdditionalInfoRecordToCloudKit(myItem)
        }
    }
    
    func updatePersonAdditionalInfoInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "PersonAdditionalInfo") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updatePersonAdditionalInfoRecord(record)
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
    
    func deletePersonAdditionalInfo()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
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
    
    func replacePersonAdditionalInfoInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true

        operation.recordFetchedBlock = { (record) in
            let addInfoName = record.object(forKey: "addInfoName") as! String
            let addInfoType = record.object(forKey: "addInfoType") as! String
            
            var addInfoID: Int32 = 0
            if record.object(forKey: "addInfoID") != nil
            {
                addInfoID = record.object(forKey: "addInfoID") as! Int32
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
            
            myDatabaseConnection.replacePersonAdditionalInfo(addInfoID,
                                                addInfoName: addInfoName,
                                                addInfoType: addInfoType
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
    
    func savePersonAdditionalInfoRecordToCloudKit(_ sourceRecord: PersonAdditionalInfo)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(addressID == \(sourceRecord.addInfoID)) AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.addInfoID, forKey: "addInfoID")
                    record!.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record!.setValue(sourceRecord.addInfoName, forKey: "addInfoType")
                    
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
                    let record = CKRecord(recordType: "PersonAdditionalInfo")
                    record.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record.setValue(sourceRecord.addInfoType, forKey: "addInfoType")
                    
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
    
    func updatePersonAdditionalInfoRecord(_ sourceRecord: CKRecord)
    {
        let addInfoName = sourceRecord.object(forKey: "addInfoName") as! String
        let addInfoType = sourceRecord.object(forKey: "addInfoType") as! String
        
        var addInfoID: Int32 = 0
        if sourceRecord.object(forKey: "addInfoID") != nil
        {
            addInfoID = sourceRecord.object(forKey: "addInfoID") as! Int32
        }
        
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
        
        myDatabaseConnection.savePersonAdditionalInfo(addInfoID,
                                         addInfoName: addInfoName,
                                         addInfoType: addInfoType
                                         , updateTime: updateTime, updateType: updateType)
    }
    
}
