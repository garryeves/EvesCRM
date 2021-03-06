//
//  decodesClass.swift
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
    func getDecodeValue(_ codeKey: String, teamID: Int) -> [Decodes]
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        //     let predicate = NSPredicate(format: "(decode_name == \"\(codeKey)\") && (updateType != \"Delete\")")
        let predicate = NSPredicate(format: "(decode_name == \"\(codeKey)\") AND (teamID == \(teamID))")
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
    
//    func getSyncDecodeValue(_ codeKey: String) -> String
//    {
//        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
//        //     let predicate = NSPredicate(format: "(decode_name == \"\(codeKey)\") && (updateType != \"Delete\")")
//        let predicate = NSPredicate(format: "(decode_name == \"\(codeKey)\")")
//        // Set the predicate on the fetch request
//        fetchRequest.predicate = predicate
//        
//        // Execute the fetch request, and cast the results to an array of  objects
//        do
//        {
//            let fetchResults = try objectContext.fetch(fetchRequest)
//            if fetchResults.count == 0
//            {
//                return ""
//            }
//            else
//            {
//                return fetchResults[0].decode_value!
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: \(error)")
//            return ""
//        }
//    }
//    
    func getVisibleDecodes(teamID: Int) -> [Decodes]
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        let predicate = NSPredicate(format: "(decodeType != \"hidden\") && (updateType != \"Delete\") AND (teamID == \(teamID))")
        
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
    
    func getDecodes(teamID: Int) -> [Decodes]
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        let predicate = NSPredicate(format: "(updateType != \"Delete\") AND (teamID == \(teamID))")
        
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
 
    func updateDecodeValue(_ codeKey: String, codeValue: String, codeType: String, decode_privacy: String, teamID: Int, updateCloud: Bool = true, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myDecode: Decodes!
        
        // first check to see if decode exists, if not we create
        let myDecodes = getDecodeValue(codeKey, teamID: teamID)
        
        if myDecodes.count == 0
        { // Add
            myDecode = Decodes(context: objectContext)
            
            myDecode.decode_name = codeKey
            myDecode.decode_value = codeValue
            myDecode.decodeType = codeType
            myDecode.decode_privacy = decode_privacy
            myDecode.teamID = Int64(teamID)
            
            if updateType == "CODE"
            {
                myDecode.updateTime =  NSDate()
                myDecode.updateType = "Add"
            }
            else
            {
                myDecode.updateTime = updateTime as NSDate
                myDecode.updateType = updateType
            }
        }
        else
        { // Update
            myDecode = myDecodes[0]
            myDecode.decode_value = codeValue
            myDecode.decodeType = codeType
            myDecode.decode_privacy = decode_privacy

            if updateType == "CODE"
            {
                myDecode.updateTime =  NSDate()
                if myDecode.updateType != "Add"
                {
                    myDecode.updateType = "Update"
                }
            }
            else
            {
                myDecode.updateTime = updateTime as NSDate
                myDecode.updateType = updateType
            }
        }
        
        saveContext()

        if updateCloud
        {
            saveDecodeToCloud()
        }
    }
    
    func saveDecodeToCloud()
    {
        DispatchQueue.global(qos: .background).async
        {
            myCloudDB.saveDecodesToCloudKit()
        }
    }

    func clearDeletedDecodes(predicate: NSPredicate)
    {
        let fetchRequest3 = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults3 = try objectContext.fetch(fetchRequest3)
            for myItem3 in fetchResults3
            {
                objectContext.delete(myItem3 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedDecodes(predicate: NSPredicate)
    {
        let fetchRequest3 = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults3 = try objectContext.fetch(fetchRequest3)
            for myItem3 in fetchResults3
            {
                myItem3.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func setNextDeviceID()
    {
        // Not doing private decodes at the moment so can delete this out
//        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
//        let predicate = NSPredicate(format: "(decode_name == \"Device\") && (updateType != \"Delete\")")
//
//        // Set the predicate on the fetch request
//        fetchRequest.predicate = predicate
//
//        var storeInt: Int = 1
//
//        // Execute the fetch request, and cast the results to an array of  objects
//        do
//        {
//            let fetchResults = try objectContext.fetch(fetchRequest)
//            if fetchResults.count > 0
//            {
//                // Increment table value by 1 and save back to database
//                storeInt = Int(fetchResults[0].decode_value!)! + 1
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: \(error)")
//            storeInt = 0
//        }
//
//        if storeInt > 0
//        {
//            let myValue = "\(coreDatabaseName) Sync \(storeInt)"
//
//            writeDefaultString(coreDatabaseName, value: myValue)
//
//            updateDecodeValue("Device", codeValue:  "\(storeInt)", codeType: "hidden", decode_privacy: "Private", updateCloud: false)
//        }
    }

    func getNextID(_ tableName: String, teamID: Int, saveToCloud: Bool = true, initialValue: Int = 1) -> Int
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        let predicate = NSPredicate(format: "(decode_name == \"\(tableName)\") && (updateType != \"Delete\") AND (teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count == 0
            {
                // Create table entry
                let storeKey = "\(initialValue)"
                updateDecodeValue(tableName, codeValue: storeKey, codeType: "hidden", decode_privacy: "Public", teamID: teamID, updateCloud: saveToCloud)
                return initialValue
            }
            else
            {
                // Increment table value by 1 and save back to database
                let storeint = Int(fetchResults[0].decode_value!)! + 1
                
                let storeKey = "\(storeint)"
                updateDecodeValue(tableName, codeValue: storeKey, codeType: "hidden", decode_privacy: "Public", teamID: teamID, updateCloud: saveToCloud)
                return storeint
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
    
    func resetDecodes()
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(decodeType != \"hidden\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                objectContext.delete(myItem as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getDecodesForSync(_ syncDate: Date) -> [Decodes]
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        let predicate = NSPredicate(format: "(updateTime >= %@) AND (decode_privacy != \"Private\")", syncDate as CVarArg)
        
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
    
    func deleteAllDecodeRecords()
    {
        let fetchRequest3 = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults3 = try objectContext.fetch(fetchRequest3)
            for myItem3 in fetchResults3
            {
                self.objectContext.delete(myItem3 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func setDecodeForTeamID()
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        let predicate = NSPredicate(format: "(teamID == 0) AND (decode_privacy != \"Private\")")
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                self.objectContext.delete(myItem as NSManagedObject)
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
    func saveDecodesToCloudKit()
    {
        let syncDate = Date()
        
        for myItem in myDatabaseConnection.getDecodesForSync(getSyncDateForTable(tableName: "Decodes"))
        {
            if myItem.decode_privacy == "Public"
            {
                savePublicDecodesRecordToCloudKit(myItem)
            }
            else
            {
                // At this moment we do not need to sync private decodes, as they are only device specific items
//                savePrivateDecodesRecordToCloudKit(myItem)
            }
        }
        setSyncDateforTable(tableName: "Decodes", syncDate: syncDate)
    }

    func updatePublicDecodesInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(value: true)

        let query: CKQuery = CKQuery(recordType: "Decodes", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateDecodeRecord(record)
        }
        
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Decodes", queryOperation: operation, onOperationQueue: operationQueue)
    }
    
    func updateDecodesInCoreData()
    {  // Not currently using private decodes

    }

    func deletePrivateDecodes()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Decodes", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performPrivateDelete(myRecordList)
            sem.signal()
        })
        
        sem.wait()
    }
    
    func savePublicDecodesRecordToCloudKit(_ sourceRecord: Decodes)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(decode_name == \"\(sourceRecord.decode_name!)\") AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Decodes", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: GRE Decode 1 \(error!.localizedDescription)")
            }
            else
            {
                if records!.count > 0
                {
                    // We need to do a check of the number for the tables, as otherwise we risk overwriting the changes
                    var updateRecord: Bool = true
                    
                    let record = records!.first// as! CKRecord
                    
                    switch sourceRecord.decode_name!
                    {
                    case "Context" :
                        let localValue = Int(sourceRecord.decode_value!)
                        let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
                        let remoteValue = Int(tempValue as! String)
                        
                        if localValue! > remoteValue!
                        {
                            updateRecord = true
                        }
                        else
                        {
                            updateRecord = false
                        }
                        
                    case "Projects" :
                        let localValue = Int(sourceRecord.decode_value!)
                        let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
                        let remoteValue = Int(tempValue as! String)
                        
                        if localValue! > remoteValue!
                        {
                            updateRecord = true
                        }
                        else
                        {
                            updateRecord = false
                        }
                        
                    case "GTDItem" :
                        let localValue = Int(sourceRecord.decode_value!)
                        let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
                        let remoteValue = Int(tempValue as! String)
                        
                        if localValue! > remoteValue!
                        {
                            updateRecord = true
                        }
                        else
                        {
                            updateRecord = false
                        }
                        
                    case "Team" :
                        let localValue = Int(sourceRecord.decode_value!)
                        let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
                        let remoteValue = Int(tempValue as! String)
                        
                        if localValue! > remoteValue!
                        {
                            updateRecord = true
                        }
                        else
                        {
                            updateRecord = false
                        }
                        
                    case "Roles" :
                        let localValue = Int(sourceRecord.decode_value!)
                        let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
                        let remoteValue = Int(tempValue as! String)
                        
                        if localValue! > remoteValue!
                        {
                            updateRecord = true
                        }
                        else
                        {
                            updateRecord = false
                        }
                        
                    case "Task" :
                        let localValue = Int(sourceRecord.decode_value!)
                        let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
                        let remoteValue = Int(tempValue as! String)
                        
                        if localValue! > remoteValue!
                        {
                            updateRecord = true
                        }
                        else
                        {
                            updateRecord = false
                        }
                        
                    case "Device" :
                        let localValue = Int(sourceRecord.decode_value!)
                        let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
                        let remoteValue = Int(tempValue as! String)
                        
                        if localValue! > remoteValue!
                        {
                            updateRecord = true
                        }
                        else
                        {
                            updateRecord = false
                        }
                        
                    case "Decodes":
                        let localValue = Int(sourceRecord.decode_value!)
                        let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
                        let remoteValue = Int(tempValue as! String)
                        
                        if localValue! > remoteValue!
                        {
                            updateRecord = true
                        }
                        else
                        {
                            updateRecord = false
                        }
                        
                    default:
                        updateRecord = true
                        
                        if sourceRecord.decode_name!.hasPrefix("\(coreDatabaseName) Sync")
                        {
                            updateRecord = true
                        }
                    }
                    
                    if updateRecord
                    {
                        while self.recordCount > 0
                        {
                            usleep(self.sleepTime)
                        }
                        
                        self.recordCount += 1
                        
                        // Now you have grabbed your existing record from iCloud
                        // Apply whatever changes you want
                        record!.setValue(sourceRecord.decode_value, forKey: "decode_value")
                        record!.setValue(sourceRecord.decodeType, forKey: "decodeType")
                        record!.setValue(sourceRecord.decode_privacy, forKey: "decode_privacy")
                        
                        if sourceRecord.updateTime != nil
                        {
                            record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        }
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        
                        // Save this record again
                        self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                            if saveError != nil
                            {
                                NSLog("Error saving record: GRE Decode 2 \(saveError!.localizedDescription)")
                                self.saveOK = false
                            }
                            else
                            {
                                if debugMessages
                                {
                                    NSLog("Successfully updated record!")
                                }
                            }
                        })
                        self.recordCount -= 1
                    }
                }
                else
                {  // Insert
                    let todoRecord = CKRecord(recordType: "Decodes")
                    todoRecord.setValue(sourceRecord.decode_name, forKey: "decode_name")
                    todoRecord.setValue(sourceRecord.decodeType, forKey: "decodeType")
                    todoRecord.setValue(sourceRecord.decode_value, forKey: "decode_value")
                    todoRecord.setValue(sourceRecord.decode_privacy, forKey: "decode_privacy")
                    todoRecord.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    if sourceRecord.updateTime != nil
                    {
                        todoRecord.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    todoRecord.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    while self.recordCount > 0
                    {
                        usleep(self.sleepTime)
                    }
                    
                    self.recordCount += 1
                    
                    self.publicDB.save(todoRecord, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: GRE Decode 3 \(saveError!.localizedDescription)")
                            self.saveOK = false
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully saved record! \(sourceRecord.decode_name!)")
                            }
                        }
                    })
                    self.recordCount -= 1
                }
            }
            sem.signal()
        })
        sem.wait()
    }

    func savePrivateDecodesRecordToCloudKit(_ sourceRecord: Decodes)
    {
    }

    func updateDecodeRecord(_ sourceRecord: CKRecord)
    {
        let decodeName = sourceRecord.object(forKey: "decode_name") as! String
        let decodeValue = sourceRecord.object(forKey: "decode_value") as! String
        let decodeType = sourceRecord.object(forKey: "decodeType") as! String
        let decode_privacy = sourceRecord.object(forKey: "decode_privacy") as! String
        
        var updateTime = Date()
        if sourceRecord.object(forKey: "updateTime") != nil
        {
            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
        }
        
        var teamID: Int = 0
        if sourceRecord.object(forKey: "teamID") != nil
        {
            teamID = sourceRecord.object(forKey: "teamID") as! Int
        }
        
        var updateType = ""
        
        if sourceRecord.object(forKey: "updateType") != nil
        {
            updateType = sourceRecord.object(forKey: "updateType") as! String
        }
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
        
        self.recordCount += 1

        myDatabaseConnection.updateDecodeValue(decodeName, codeValue: decodeValue, codeType: decodeType, decode_privacy: decode_privacy, teamID: teamID, updateCloud: false, updateTime: updateTime, updateType: updateType)
        
        self.recordCount -= 1
    }

}
