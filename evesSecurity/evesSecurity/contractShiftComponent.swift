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
    
    init(contractShiftID: Int)
    {
        for myItem in myDatabaseConnection.getContractShiftComponents(contractShiftID: contractShiftID)
        {
            let myObject = contractShiftComponent(contractShiftID: Int(myItem.contractShiftID),
                                                  dayOfWeek: myItem.dayOfWeek!,
                                                  endTime: myItem.endTime! as Date,
                                                  startTime: myItem.startTime! as Date,
                                                  teamID: Int(myItem.teamID))
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
    fileprivate var myContractShiftID: Int = 0
    fileprivate var myDayOfWeek: String = ""
    fileprivate var myEndTime: Date = getDefaultDate()
    fileprivate var myStartTime: Date = getDefaultDate()
    fileprivate var myTeamID: Int = 0
    
    var contractShiftID: Int
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
    
    init(contractShiftID: Int, dayOfWeek: String)
    {
        super.init()
        let myReturn = myDatabaseConnection.getContractShiftComponentDetails(contractShiftID, dayOfWeek: dayOfWeek)
        
        for myItem in myReturn
        {
            myContractShiftID = Int(myItem.contractShiftID)
            myDayOfWeek = myItem.dayOfWeek!
            myEndTime = myItem.endTime! as Date
            myStartTime = myItem.startTime! as Date
            myTeamID = Int(myItem.teamID)
        }
    }
    
    init(contractShiftID: Int,
         dayOfWeek: String,
         endTime: Date,
         startTime: Date,
         teamID: Int
         )
    {
        super.init()
        
        myContractShiftID = contractShiftID
        myDayOfWeek = dayOfWeek
        myEndTime = endTime
        myStartTime = startTime
        myTeamID = teamID
    }
    
    func save()
    {
        myDatabaseConnection.saveContractShiftComponent(myContractShiftID,
                                         dayOfWeek: myDayOfWeek,
                                         startTime: myStartTime,
                                         endTime: myEndTime,
                                         teamID: myTeamID
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deleteContractShiftComponent(myContractShiftID, dayOfWeek: dayOfWeek)
    }
}

extension coreDatabase
{
    func saveContractShiftComponent(_ contractShiftID: Int,
                     dayOfWeek: String,
                     startTime: Date,
                     endTime: Date,
                     teamID: Int,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: ContractShiftComponent!
        
        let myReturn = getContractShiftComponentDetails(contractShiftID, dayOfWeek: dayOfWeek)
        
        if myReturn.count == 0
        { // Add
            myItem = ContractShiftComponent(context: objectContext)
            myItem.contractShiftID = Int64(contractShiftID)
            myItem.dayOfWeek = dayOfWeek
            myItem.startTime = startTime as NSDate
            myItem.endTime = endTime as NSDate
            myItem.teamID = Int64(teamID)
            
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
    
    func replaceContractShiftComponent(_ contractShiftID: Int,
                                       dayOfWeek: String,
                                       startTime: Date,
                                       endTime: Date,
                                       teamID: Int,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = ContractShiftComponent(context: objectContext)
        myItem.contractShiftID = Int64(contractShiftID)
        myItem.dayOfWeek = dayOfWeek
        myItem.startTime = startTime as NSDate
        myItem.endTime = endTime as NSDate
        myItem.teamID = Int64(teamID)

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
    
    func deleteContractShiftComponent(_ contractShiftID: Int, dayOfWeek: String)
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
    
    func getContractShiftComponents(contractShiftID: Int)->[ContractShiftComponent]
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
    
    func getContractShiftComponentDetails(_ contractShiftID: Int, dayOfWeek: String)->[ContractShiftComponent]
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
            saveContractShiftComponentRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateContractShiftComponentInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "ContractShiftComponent") as CVarArg)
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
    
    func deleteContractShiftComponent(contractShiftID:Int, dayOfWeek: String)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (contractShiftID == \(contractShiftID)) AND (dayOfWeek == \"\(dayOfWeek)\")")
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
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "ContractShiftComponent", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let dayOfWeek = record.object(forKey: "dayOfWeek") as! String

            var contractShiftID: Int = 0
            if record.object(forKey: "contractShiftID") != nil
            {
                contractShiftID = record.object(forKey: "contractShiftID") as! Int
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
            
            var teamID: Int = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int
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
                                                endTime: endTime,
                                                teamID: teamID
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
    
    func saveContractShiftComponentRecordToCloudKit(_ sourceRecord: ContractShiftComponent, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(contractShiftID == \(sourceRecord.contractShiftID)) AND (dayOfWeek == \"\(sourceRecord.dayOfWeek!)\") AND \(buildTeamList(currentUser.userID))") // better be accurate to get only the record you need
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
                    
                    record.setValue(teamID, forKey: "teamID")
                    
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
        
        var contractShiftID: Int = 0
        if sourceRecord.object(forKey: "contractShiftID") != nil
        {
            contractShiftID = sourceRecord.object(forKey: "contractShiftID") as! Int
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
        
        var teamID: Int = 0
        if sourceRecord.object(forKey: "teamID") != nil
        {
            teamID = sourceRecord.object(forKey: "teamID") as! Int
        }
        
        myDatabaseConnection.saveContractShiftComponent(contractShiftID,
                                         dayOfWeek: dayOfWeek,
                                         startTime: startTime,
                                         endTime: endTime,
                                         teamID: teamID
                                         , updateTime: updateTime, updateType: updateType)
    }
}

