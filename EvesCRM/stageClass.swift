//
//  stageClass.swift
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
    func getStages(_ teamID: Int32)->[Stages]
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID))")
        
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
    
    func getVisibleStages(_ teamID: Int32)->[Stages]
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
        let predicate = NSPredicate(format: "(stageDescription != \"Archived\") && (updateType != \"Delete\") && (teamID == \(teamID))")
        
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
    
    func deleteAllStages(_ teamID: Int32)
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        let predicate = NSPredicate(format: "(teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.updateTime =  NSDate()
                myStage.updateType = "Delete"
                
                myCloudDB.saveStagesRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func stageExists(_ stageDesc:String, teamID: Int32)-> Bool
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(stageDescription == \"\(stageDesc)\") && (teamID == \(teamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            {
                return true
            }
            else
            {
                return false
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return false
        }
    }
    
    func getStage(_ stageDesc:String, teamID: Int32)->[Stages]
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (stageDescription == \"\(stageDesc)\")")
        
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
    
    func saveStage(_ stageDesc: String, teamID: Int32, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myStage: Stages!
        
        let myStages = getStage(stageDesc, teamID: teamID)
        
        if myStages.count == 0
        {
            myStage = Stages(context: objectContext)
            
            myStage.stageDescription = stageDesc
            myStage.teamID = teamID
            if updateType == "CODE"
            {
                myStage.updateTime =  NSDate()
                myStage.updateType = "Add"
            }
            else
            {
                myStage.updateTime = updateTime as NSDate
                myStage.updateType = updateType
            }
        }
        else
        {
            myStage = myStages[0]
            if updateType == "CODE"
            {
                myStage.updateTime =  NSDate()
                if myStage.updateType != "Add"
                {
                    myStage.updateType = "Update"
                }
            }
            else
            {
                myStage.updateTime = updateTime as NSDate
                myStage.updateType = updateType
            }
        }
        
        saveContext()
        
        myCloudDB.saveStagesRecordToCloudKit(myStage)
    }
    
    func replaceStage(_ stageDesc: String, teamID: Int32, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myStage = Stages(context: objectContext)
        
        myStage.stageDescription = stageDesc
        myStage.teamID = teamID
        if updateType == "CODE"
        {
            myStage.updateTime =  NSDate()
            myStage.updateType = "Add"
        }
        else
        {
            myStage.updateTime = updateTime as NSDate
            myStage.updateType = updateType
        }
        
        saveContext()
    }
    
    func deleteStageEntry(_ stageDesc: String, teamID: Int32)
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
        let predicate = NSPredicate(format: "(stageDescription == \"\(stageDesc)\") && (teamID == \(teamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.updateTime =  NSDate()
                myStage.updateType = "Delete"
                
                myCloudDB.saveStagesRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }

    func clearDeletedStages(predicate: NSPredicate)
    {
        let fetchRequest15 = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Set the predicate on the fetch request
        fetchRequest15.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults15 = try objectContext.fetch(fetchRequest15)
            for myItem15 in fetchResults15
            {
                objectContext.delete(myItem15 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedStages(predicate: NSPredicate)
    {
        let fetchRequest15 = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Set the predicate on the fetch request
        fetchRequest15.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults15 = try objectContext.fetch(fetchRequest15)
            for myItem15 in fetchResults15
            {
                myItem15.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func initialiseTeamForStages(_ teamID: Int32)
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            {
                for myItem in fetchResults
                {
                    myItem.teamID = teamID
                }
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getStagesForSync(_ syncDate: Date) -> [Stages]
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
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
    
    func deleteAllStageRecords()
    {
        let fetchRequest15 = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults15 = try objectContext.fetch(fetchRequest15)
            for myItem15 in fetchResults15
            {
                self.objectContext.delete(myItem15 as NSManagedObject)
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
    func saveStagesToCloudKit()
    {
        for myItem in myDatabaseConnection.getStagesForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Stages"))
        {
            saveStagesRecordToCloudKit(myItem)
        }
    }

    func updateStagesInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", myDatabaseConnection.getSyncDateForTable(tableName: "Stages") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Stages", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.updateStagesRecord(record)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executeQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func deleteStages()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Stages", predicate: predicate)
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

    func replaceStagesInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Stages", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            var updateTime = Date()
            let stageDescription = record.object(forKey: "stageDescription") as! String
            if record.object(forKey: "updateTime") != nil
            {
                updateTime = record.object(forKey: "updateTime") as! Date
            }
            var updateType: String = ""
            if record.object(forKey: "updateType") != nil
            {
                updateType = record.object(forKey: "updateType") as! String
            }
            let teamID = record.object(forKey: "teamID") as! Int32
            
            myDatabaseConnection.replaceStage(stageDescription, teamID: teamID, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executeQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveStagesRecordToCloudKit(_ sourceRecord: Stages)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(stageDescription == \"\(sourceRecord.stageDescription!)\") && (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Stages", predicate: predicate)
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
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    
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
                    let record = CKRecord(recordType: "Stages")
                    record.setValue(sourceRecord.stageDescription, forKey: "stageDescription")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
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
            sem.signal()
        })
        sem.wait()
    }

    func updateStagesRecord(_ sourceRecord: CKRecord)
    {
        let stageDescription = sourceRecord.object(forKey: "stageDescription") as! String
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
        let teamID = sourceRecord.object(forKey: "teamID") as! Int32
        
        myDatabaseConnection.saveStage(stageDescription, teamID: teamID, updateTime: updateTime, updateType: updateType)
    }
}
