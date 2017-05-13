//
//  ratesClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class rates: NSObject
{
    fileprivate var myRates:[rate] = Array()
    
    init(projectID: Int)
    {
        for myItem in myDatabaseConnection.getRates(projectID: projectID)
        {
            let myObject = rate(rateID: Int(myItem.rateID),
                                projectID: Int(myItem.projectID),
                                rateName: myItem.rateName!,
                                rateAmount: myItem.rateAmount,
                                chargeAmount: myItem.chargeAmount,
                                startDate: myItem.startDate! as Date,
            teamID: Int(myItem.teamID))
            myRates.append(myObject)
        }
    }
    
    var Rates: [rate]
    {
        get
        {
            return myRates
        }
    }
}

class rate: NSObject
{
    fileprivate var myRateID: Int = 0
    fileprivate var myProjectID: Int = 0
    fileprivate var myRateName: String = ""
    fileprivate var myRateAmount: Double = 0.0
    fileprivate var myChargeAmount: Double = 0.0
    fileprivate var myStartDate: Date = getDefaultDate()
    fileprivate var myTeamID: Int = 0
    
    var rateID: Int
    {
        get
        {
            return myRateID
        }
    }
    
    var projectID: Int
    {
        get
        {
            return myProjectID
        }
    }
    
    var rateName: String
    {
        get
        {
            return myRateName
        }
        set
        {
            myRateName = newValue
            save()
        }
    }
    
    var rateAmount: Double
    {
        get
        {
            return myRateAmount
        }
        set
        {
            myRateAmount = newValue
            save()
        }
    }

    var chargeAmount: Double
    {
        get
        {
            return myChargeAmount
        }
        set
        {
            myChargeAmount = newValue
            save()
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
            save()
        }
    }

    init(projectID: Int, teamID: Int)
    {
        super.init()
        
        myRateID = myDatabaseConnection.getNextID("Rates", teamID: teamID)
        myProjectID = projectID
        myTeamID = teamID
        
        save()
    }
    
    init(rateID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getRatesDetails(rateID)
        
        for myItem in myReturn
        {
            myRateID = Int(myItem.rateID)
            myProjectID = Int(myItem.projectID)
            myRateName = myItem.rateName!
            myRateAmount = myItem.rateAmount
            myChargeAmount = myItem.chargeAmount
            myStartDate = myItem.startDate! as Date
            myTeamID = Int(myItem.teamID)
        }
    }
    
    init(rateID: Int,
         projectID: Int,
         rateName: String,
         rateAmount: Double,
         chargeAmount: Double,
         startDate: Date,
         teamID: Int
         )
    {
        super.init()
        
        myRateID = rateID
        myProjectID = projectID
        myRateName = rateName
        myRateAmount = rateAmount
        myChargeAmount = chargeAmount
        myStartDate = startDate
        myTeamID = teamID
    }
    
    func save()
    {
        myDatabaseConnection.saveRates(myRateID,
                                       projectID: myProjectID,
                                        rateName: myRateName,
                                        rateAmount: myRateAmount,
                                        chargeAmount: myChargeAmount,
                                        startDate: myStartDate,
                                        teamID: myTeamID
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deleteRates(myRateID)
    }
}

extension coreDatabase
{
    func saveRates(_ rateID: Int,
                   projectID: Int,
                   rateName: String,
                   rateAmount: Double,
                   chargeAmount: Double,
                   startDate: Date,
                   teamID: Int,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Rates!
        
        let myReturn = getRatesDetails(rateID)
        
        if myReturn.count == 0
        { // Add
            myItem = Rates(context: objectContext)
            myItem.rateID = Int64(rateID)
            myItem.projectID = Int64(projectID)
            myItem.rateName = rateName
            myItem.rateAmount = rateAmount
            myItem.chargeAmount = chargeAmount
            myItem.startDate = startDate as NSDate
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
            myItem.projectID = Int64(projectID)
            myItem.rateName = rateName
            myItem.rateAmount = rateAmount
            myItem.chargeAmount = chargeAmount
            myItem.startDate = startDate as NSDate
            
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
    
    func replaceRates(_ rateID: Int,
                      projectID: Int,
                      rateName: String,
                      rateAmount: Double,
                      chargeAmount: Double,
                      startDate: Date,
                      teamID: Int,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = Rates(context: objectContext)
        myItem.rateID = Int64(rateID)
        myItem.projectID = Int64(projectID)
        myItem.rateName = rateName
        myItem.rateAmount = rateAmount
        myItem.chargeAmount = chargeAmount
        myItem.startDate = startDate as NSDate
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
    
    func deleteRates(_ rateID: Int)
    {
        let myReturn = getRatesDetails(rateID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getRates(projectID: Int)->[Rates]
    {
        let fetchRequest = NSFetchRequest<Rates>(entityName: "Rates")
        
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
    
    func getRatesDetails(_ rateID: Int)->[Rates]
    {
        let fetchRequest = NSFetchRequest<Rates>(entityName: "Rates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(rateID == \(rateID)) && (updateType != \"Delete\")")
        
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
    
    func resetAllRates()
    {
        let fetchRequest = NSFetchRequest<Rates>(entityName: "Rates")
        
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
    
    func clearDeletedRates(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Rates>(entityName: "Rates")
        
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
    
    func clearSyncedRates(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Rates>(entityName: "Rates")
        
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
    
    func getRatesForSync(_ syncDate: Date) -> [Rates]
    {
        let fetchRequest = NSFetchRequest<Rates>(entityName: "Rates")
        
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
    
    func deleteAllRates()
    {
        let fetchRequest2 = NSFetchRequest<Rates>(entityName: "Rates")
        
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
    func saveRatesToCloudKit()
    {
        for myItem in myDatabaseConnection.getRatesForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Rates"))
        {
            saveRatesRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateRatesInCoreData(teamID: Int)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(teamID))", myDatabaseConnection.getSyncDateForTable(tableName: "Rates") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Rates", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateRatesRecord(record)
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
    
    func deleteRates(rateID: Int, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID)) AND (rateID == \(rateID))")
        let query: CKQuery = CKQuery(recordType: "Rates", predicate: predicate)
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

    func replaceratesInCoreData(teamID: Int)
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "Rates", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let rateName = record.object(forKey: "rateName") as! String
            
            var rateID: Int = 0
            if record.object(forKey: "rateID") != nil
            {
                rateID = record.object(forKey: "rateID") as! Int
            }
            
            var projectID: Int = 0
            if record.object(forKey: "projectID") != nil
            {
                projectID = record.object(forKey: "projectID") as! Int
            }
            
            var rateAmount: Double = 0.0
            if record.object(forKey: "rateAmount") != nil
            {
                rateAmount = record.object(forKey: "rateAmount") as! Double
            }
            
            var chargeAmount: Double = 0.0
            if record.object(forKey: "chargeAmount") != nil
            {
                chargeAmount = record.object(forKey: "chargeAmount") as! Double
            }
            
            var startDate: Date = getDefaultDate()
            if record.object(forKey: "startDate") != nil
            {
                startDate = record.object(forKey: "startDate") as! Date
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
            
            myDatabaseConnection.replaceRates(rateID,
                                                projectID: projectID,
                                                rateName: rateName,
                                                rateAmount: rateAmount,
                                                chargeAmount: chargeAmount,
                                                startDate: startDate,
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

    func saveRatesRecordToCloudKit(_ sourceRecord: Rates, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(ratesID == \(sourceRecord.rateID)) AND (teamID == \(teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Rates", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.projectID, forKey: "projectID")
                    record!.setValue(sourceRecord.rateName, forKey: "rateName")
                    record!.setValue(sourceRecord.rateAmount, forKey: "rateAmount")
                    record!.setValue(sourceRecord.chargeAmount, forKey: "chargeAmount")
                    record!.setValue(sourceRecord.startDate, forKey: "startDate")
                    
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
                    let record = CKRecord(recordType: "Rates")
                    record.setValue(sourceRecord.rateID, forKey: "rateID")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.rateName, forKey: "rateName")
                    record.setValue(sourceRecord.rateAmount, forKey: "rateAmount")
                    record.setValue(sourceRecord.chargeAmount, forKey: "chargeAmount")
                    record.setValue(sourceRecord.startDate, forKey: "startDate")
                    
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

    func updateRatesRecord(_ sourceRecord: CKRecord)
    {
        let rateName = sourceRecord.object(forKey: "rateName") as! String
        
        var rateID: Int = 0
        if sourceRecord.object(forKey: "rateID") != nil
        {
            rateID = sourceRecord.object(forKey: "rateID") as! Int
        }
        
        var projectID: Int = 0
        if sourceRecord.object(forKey: "projectID") != nil
        {
            projectID = sourceRecord.object(forKey: "projectID") as! Int
        }
        
        var rateAmount: Double = 0.0
        if sourceRecord.object(forKey: "rateAmount") != nil
        {
            rateAmount = sourceRecord.object(forKey: "rateAmount") as! Double
        }
        
        var chargeAmount: Double = 0.0
        if sourceRecord.object(forKey: "chargeAmount") != nil
        {
            chargeAmount = sourceRecord.object(forKey: "chargeAmount") as! Double
        }
        
        var startDate: Date = getDefaultDate()
        if sourceRecord.object(forKey: "startDate") != nil
        {
            startDate = sourceRecord.object(forKey: "startDate") as! Date
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
        
        myDatabaseConnection.saveRates(rateID,
                                         projectID: projectID,
                                         rateName: rateName,
                                         rateAmount: rateAmount,
                                         chargeAmount: chargeAmount,
                                         startDate: startDate,
                                         teamID: teamID
                                         , updateTime: updateTime, updateType: updateType)
    }
}

