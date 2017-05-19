//
//  contractShift.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class contractShifts: NSObject
{
    fileprivate var myContractShifts:[contractShift] = Array()
    
    init(projectID: Int)
    {
        for myItem in myDatabaseConnection.getContractShifts(projectID: projectID)
        {
            let myObject = contractShift(contractShiftID: Int(myItem.contractShiftID),
                                          projectID: Int(myItem.projectID),
                                          startDate: myItem.startDate! as Date,
                                          endDate: myItem.endDate! as Date,
            teamID: Int(myItem.teamID))
            myContractShifts.append(myObject)
        }
    }
    
    var contractShifts: [contractShift]
    {
        get
        {
            return myContractShifts
        }
    }
}

class contractShift: NSObject
{
    fileprivate var myContractShiftID: Int = 0
    fileprivate var myProjectID: Int = 0
    fileprivate var myStartDate: Date = getDefaultDate()
    fileprivate var myEndDate: Date = getDefaultDate()
    fileprivate var myTeamID: Int = 0
    
    var ontractShiftID: Int
    {
        get
        {
            return myContractShiftID
        }
    }
    
    var projectID: Int
    {
        get
        {
            return myProjectID
        }
    }
    
    var startDate: Date
    {
        get
        {
            return myStartDate
        }
        set
        {
            myStartDate = newValue
        }
    }
    
    var endDate: Date
    {
        get
        {
            return myEndDate
        }
        set
        {
            myEndDate = newValue
        }
    }
    
    init(projectID: Int, teamID: Int)
    {
        super.init()
        
        myContractShiftID = myDatabaseConnection.getNextID("ContractShift")
        myProjectID = projectID
        myTeamID = teamID
        
        save()
    }
    
    init(contractShiftID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getContractShiftsDetails(contractShiftID)
        
        for myItem in myReturn
        {
            myContractShiftID = Int(myItem.contractShiftID)
            myProjectID = Int(myItem.projectID)
            myStartDate = myItem.startDate! as Date
            myEndDate = myItem.endDate! as Date
            myTeamID = Int(myItem.teamID)
        }
    }
    
    init(contractShiftID: Int,
         projectID: Int,
         startDate: Date,
         endDate: Date,
         teamID: Int
         )
    {
        super.init()
        
        myContractShiftID = contractShiftID
        myProjectID = projectID
        myStartDate = startDate
        myEndDate = endDate
        myTeamID = teamID
    }
    
    func save()
    {
        myDatabaseConnection.saveContractShifts(myContractShiftID,
                                                projectID: myProjectID,
                                                startDate: myStartDate,
                                                endDate: myEndDate,
                                                teamID: myTeamID
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deleteContractShifts(myContractShiftID)
    }
}

extension coreDatabase
{
    func saveContractShifts(_ contractShiftID: Int,
                            projectID: Int,
                            startDate: Date,
                            endDate: Date,
                            teamID: Int,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: ContractShifts!
        
        let myReturn = getContractShiftsDetails(contractShiftID)
        
        if myReturn.count == 0
        { // Add
            myItem = ContractShifts(context: objectContext)
            myItem.contractShiftID = Int64(contractShiftID)
            myItem.projectID = Int64(projectID)
            myItem.startDate = startDate as NSDate
            myItem.endDate = endDate as NSDate
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
            myItem.startDate = startDate as NSDate
            myItem.endDate = endDate as NSDate
            
            
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
    
    func replaceContractShifts(_ contractShiftID: Int,
                               projectID: Int,
                               startDate: Date,
                               endDate: Date,
                               teamID: Int,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = ContractShifts(context: objectContext)
        myItem.contractShiftID = Int64(contractShiftID)
        myItem.projectID = Int64(projectID)
        myItem.startDate = startDate as NSDate
        myItem.endDate = endDate as NSDate
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
    
    func deleteContractShifts(_ contractShiftID: Int)
    {
        let myReturn = getContractShiftsDetails(contractShiftID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getContractShifts(projectID: Int)->[ContractShifts]
    {
        let fetchRequest = NSFetchRequest<ContractShifts>(entityName: "ContractShifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) && (updateType != \"Delete\")")
        
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
    
    func getContractShiftsDetails(_ contractShiftID: Int)->[ContractShifts]
    {
        let fetchRequest = NSFetchRequest<ContractShifts>(entityName: "ContractShifts")
        
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
    
    func resetAllContractShifts()
    {
        let fetchRequest = NSFetchRequest<ContractShifts>(entityName: "ContractShifts")
        
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
    
    func clearDeletedContractShifts(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<ContractShifts>(entityName: "ContractShifts")
        
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
    
    func clearSyncedContractShifts(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<ContractShifts>(entityName: "ContractShifts")
        
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
    
    func getContractShiftsForSync(_ syncDate: Date) -> [ContractShifts]
    {
        let fetchRequest = NSFetchRequest<ContractShifts>(entityName: "ContractShifts")
        
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
    
    func deleteAllContractShifts()
    {
        let fetchRequest2 = NSFetchRequest<ContractShifts>(entityName: "ContractShifts")
        
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
    func saveContractShiftsToCloudKit()
    {
        for myItem in myDatabaseConnection.getContractShiftsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "ContractShifts"))
        {
            saveContractShiftsRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateContractShiftsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "ContractShifts") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "ContractShifts", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateContractShiftsRecord(record)
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
    
    func deleteContractShifts(contractShiftID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))AND (contractShiftID == \(contractShiftID))")
        let query: CKQuery = CKQuery(recordType: "ContractShifts", predicate: predicate)
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
    
    func replaceContractShiftsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "ContractShifts", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            var contractShiftID: Int = 0
            if record.object(forKey: "contractShiftID") != nil
            {
                contractShiftID = record.object(forKey: "contractShiftID") as! Int
            }

            var projectID: Int = 0
            if record.object(forKey: "projectID") != nil
            {
                projectID = record.object(forKey: "projectID") as! Int
            }
            
            var startDate = Date()
            if record.object(forKey: "startDate") != nil
            {
                startDate = record.object(forKey: "startDate") as! Date
            }
            
            var endDate = Date()
            if record.object(forKey: "endDate") != nil
            {
                endDate = record.object(forKey: "endDate") as! Date
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
            
            myDatabaseConnection.replaceContractShifts(contractShiftID,
                                                projectID: projectID,
                                                startDate: startDate,
                                                endDate: endDate,
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
    
    func saveContractShiftsRecordToCloudKit(_ sourceRecord: ContractShifts, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(contractShiftID == \(sourceRecord.contractShiftID)) AND (projectID == \(sourceRecord.projectID)) AND \(buildTeamList(currentUser.userID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "ContractShifts", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.startDate, forKey: "startDate")
                    record!.setValue(sourceRecord.endDate, forKey: "endDate")
                    
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
                    let record = CKRecord(recordType: "ContractShifts")
                    record.setValue(sourceRecord.contractShiftID, forKey: "contractShiftID")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.startDate, forKey: "startDate")
                    record.setValue(sourceRecord.endDate, forKey: "endDate")
                    
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
    
    func updateContractShiftsRecord(_ sourceRecord: CKRecord)
    {
        var contractShiftID: Int = 0
        if sourceRecord.object(forKey: "contractShiftID") != nil
        {
            contractShiftID = sourceRecord.object(forKey: "contractShiftID") as! Int
        }
        
        var projectID: Int = 0
        if sourceRecord.object(forKey: "projectID") != nil
        {
            projectID = sourceRecord.object(forKey: "projectID") as! Int
        }
        
        var startDate = Date()
        if sourceRecord.object(forKey: "startDate") != nil
        {
            startDate = sourceRecord.object(forKey: "startDate") as! Date
        }
        
        var endDate = Date()
        if sourceRecord.object(forKey: "endDate") != nil
        {
            endDate = sourceRecord.object(forKey: "endDate") as! Date
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
        
        myDatabaseConnection.saveContractShifts(contractShiftID,
                                         projectID: projectID,
                                         startDate: startDate,
                                         endDate: endDate,
                                         teamID: teamID
                                         , updateTime: updateTime, updateType: updateType)
    }
}

