//
//  contractShiftComponent.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class contractShiftComponents: NSObject
{
    fileprivate var myComponents:[contractShiftComponent] = Array()
    
    init(contractShiftID: Int32)
    {
        for myItem in myDatabaseConnection.getContractShiftComponents(contractShiftID: contractShiftID)
        {
            let myObject = contractShiftComponent(contractShiftID: myItem.contractShiftID,
                                                  dayOfWeek: myItem.dayOfWeek!,
                                                  endTime: myItem.endTime! as Date,
                                                  startTime: myItem.startTime! as Date)
            myComponents.append(myObject)
        }
    }
    
    var components: [contractShiftComponent]
    {
        get
        {
            return myComponents
        }
    }
}

class contractShiftComponent: NSObject
{
    fileprivate var myContractShiftID: Int32 = 0
    fileprivate var myDayOfWeek: String = ""
    fileprivate var myEndTime: Date = getDefaultDate()
    fileprivate var myStartTime: Date = getDefaultDate()
    
    var contractShiftID: Int32
    {
        get
        {
            return myContractShiftID
        }
    }
    
    var dayOfWeek: String
    {
        get
        {
            return myDayOfWeek
        }
        set
        {
            myDayOfWeek = newValue
            save()
        }
    }
    
    var endTime: Date
    {
        get
        {
            return myEndTime
        }
        set
        {
            myEndTime = newValue
            save()
        }
    }
    
    var startTime: Date
    {
        get
        {
            return myStartTime
        }
        set
        {
            myStartTime = newValue
            save()
        }
    }
    
    init(contractShiftID: Int32, dayOfWeek: String)
    {
        super.init()
        let myReturn = myDatabaseConnection.getContractShiftComponentDetails(contractShiftID, dayOfWeek: dayOfWeek)
        
        for myItem in myReturn
        {
            myContractShiftID = myItem.contractShiftID
            myDayOfWeek = myItem.dayOfWeek!
            myEndTime = myItem.endTime! as Date
            myStartTime = myItem.startTime! as Date
        }
    }
    
    init(contractShiftID: Int32,
         dayOfWeek: String,
         endTime: Date,
         startTime: Date
         )
    {
        super.init()
        
        myContractShiftID = contractShiftID
        myDayOfWeek = dayOfWeek
        myEndTime = endTime
        myStartTime = startTime
    }
    
    func save()
    {
        myDatabaseConnection.saveContractShiftComponent(myContractShiftID,
                                         dayOfWeek: myDayOfWeek,
                                         startTime: myStartTime,
                                         endTime: myEndTime
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deleteContractShiftComponent(myContractShiftID, dayOfWeek: dayOfWeek)
    }
}

extension coreDatabase
{
    func saveContractShiftComponent(_ contractShiftID: Int32,
                     dayOfWeek: String,
                     startTime: Date,
                     endTime: Date,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: ContractShiftComponent!
        
        let myReturn = getContractShiftComponentDetails(contractShiftID, dayOfWeek: dayOfWeek)
        
        if myReturn.count == 0
        { // Add
            myItem = ContractShiftComponent(context: objectContext)
            myItem.contractShiftID = contractShiftID
            myItem.dayOfWeek = dayOfWeek
            myItem.startTime = startTime as NSDate
            myItem.endTime = endTime as NSDate
            
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
            myItem.startTime = startTime as NSDate
            myItem.endTime = endTime as NSDate
            
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
    
    func replaceContractShiftComponent(_ contractShiftID: Int32,
                                       dayOfWeek: String,
                                       startTime: Date,
                                       endTime: Date,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = ContractShiftComponent(context: objectContext)
        myItem.contractShiftID = contractShiftID
        myItem.dayOfWeek = dayOfWeek
        myItem.startTime = startTime as NSDate
        myItem.endTime = endTime as NSDate
        
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
    
    func deleteContractShiftComponent(_ contractShiftID: Int32, dayOfWeek: String)
    {
        let myReturn = getContractShiftComponentDetails(contractShiftID, dayOfWeek: dayOfWeek)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getContractShiftComponents(contractShiftID: Int32)->[ContractShiftComponent]
    {
        let fetchRequest = NSFetchRequest<ContractShiftComponent>(entityName: "ContractShiftComponent")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contractShiftID == \(contractShiftID)) && (updateType != \"Delete\")")
        
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
    
    func getContractShiftComponentDetails(_ contractShiftID: Int32, dayOfWeek: String)->[ContractShiftComponent]
    {
        let fetchRequest = NSFetchRequest<ContractShiftComponent>(entityName: "ContractShiftComponent")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contractShiftID == \(contractShiftID)) AND (dayOfWeek == \"\(dayOfWeek)\") && (updateType != \"Delete\")")
        
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
    
    func resetAllContractShiftComponent()
    {
        let fetchRequest = NSFetchRequest<ContractShiftComponent>(entityName: "ContractShiftComponent")
        
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
    
    func clearDeletedContractShiftComponent(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<ContractShiftComponent>(entityName: "ContractShiftComponent")
        
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
    
    func clearSyncedContractShiftComponent(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<ContractShiftComponent>(entityName: "ContractShiftComponent")
        
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
    
    func getContractShiftComponentForSync(_ syncDate: Date) -> [ContractShiftComponent]
    {
        let fetchRequest = NSFetchRequest<ContractShiftComponent>(entityName: "ContractShiftComponent")
        
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
    
    func deleteAllContractShiftComponent()
    {
        let fetchRequest2 = NSFetchRequest<ContractShiftComponent>(entityName: "ContractShiftComponent")
        
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
    func saveContractShiftComponentToCloudKit()
    {
        for myItem in myDatabaseConnection.getContractShiftComponentForSync(myDatabaseConnection.getSyncDateForTable(tableName: "ContractShiftComponent"))
        {
            saveContractShiftComponentRecordToCloudKit(myItem)
        }
    }
    
    func updateContractShiftComponentInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "ContractShiftComponent") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "ContractShiftComponent", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateContractShiftComponentRecord(record)
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
    
    func deleteContractShiftComponent(contractShiftID:Int32, dayOfWeek: String)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID)) AND (contractShiftID == \(contractShiftID)) AND (dayOfWeek == \"\(dayOfWeek)\")")
        let query: CKQuery = CKQuery(recordType: "ContractShiftComponent", predicate: predicate)
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
    
    func replaceContractShiftComponentInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "ContractShiftComponent", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let dayOfWeek = record.object(forKey: "dayOfWeek") as! String

            var contractShiftID: Int32 = 0
            if record.object(forKey: "contractShiftID") != nil
            {
                contractShiftID = record.object(forKey: "contractShiftID") as! Int32
            }
            
            var startTime = Date()
            if record.object(forKey: "startTime") != nil
            {
                startTime = record.object(forKey: "startTime") as! Date
            }
            
            var endTime = Date()
            if record.object(forKey: "endTime") != nil
            {
                endTime = record.object(forKey: "endTime") as! Date
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
            
            myDatabaseConnection.replaceContractShiftComponent(contractShiftID,
                                                dayOfWeek: dayOfWeek,
                                                startTime: startTime,
                                                endTime: endTime
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
    
    func saveContractShiftComponentRecordToCloudKit(_ sourceRecord: ContractShiftComponent)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(contractShiftID == \(sourceRecord.contractShiftID)) AND (dayOfWeek == \"\(sourceRecord.dayOfWeek!)\") AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "ContractShiftComponent", predicate: predicate)
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

                    record!.setValue(sourceRecord.startTime, forKey: "startTime")
                    record!.setValue(sourceRecord.endTime, forKey: "endTime")
                    
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
                    let record = CKRecord(recordType: "ContractShiftComponent")
                    
                    record.setValue(sourceRecord.contractShiftID, forKey: "contractShiftID")
                    record.setValue(sourceRecord.dayOfWeek, forKey: "dayOfWeek")
                    record.setValue(sourceRecord.startTime, forKey: "startTime")
                    record.setValue(sourceRecord.endTime, forKey: "endTime")
                    
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
    
    func updateContractShiftComponentRecord(_ sourceRecord: CKRecord)
    {
        let dayOfWeek = sourceRecord.object(forKey: "dayOfWeek") as! String
        
        var contractShiftID: Int32 = 0
        if sourceRecord.object(forKey: "contractShiftID") != nil
        {
            contractShiftID = sourceRecord.object(forKey: "contractShiftID") as! Int32
        }
        
        var startTime = Date()
        if sourceRecord.object(forKey: "startTime") != nil
        {
            startTime = sourceRecord.object(forKey: "startTime") as! Date
        }
        
        var endTime = Date()
        if sourceRecord.object(forKey: "endTime") != nil
        {
            endTime = sourceRecord.object(forKey: "endTime") as! Date
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
        
        myDatabaseConnection.saveContractShiftComponent(contractShiftID,
                                         dayOfWeek: dayOfWeek,
                                         startTime: startTime,
                                         endTime: endTime
                                         , updateTime: updateTime, updateType: updateType)
    }
}

