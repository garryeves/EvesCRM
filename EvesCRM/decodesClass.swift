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
    func getDecodeValue(_ codeKey: String) -> String
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        //     let predicate = NSPredicate(format: "(decode_name == \"\(codeKey)\") && (updateType != \"Delete\")")
        let predicate = NSPredicate(format: "(decode_name == \"\(codeKey)\")")
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count == 0
            {
                return ""
            }
            else
            {
                return fetchResults[0].decode_value!
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return ""
        }
    }
    
    func getSyncDecodeValue(_ codeKey: String) -> String
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        //     let predicate = NSPredicate(format: "(decode_name == \"\(codeKey)\") && (updateType != \"Delete\")")
        let predicate = NSPredicate(format: "(decode_name == \"\(codeKey)\")")
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count == 0
            {
                return ""
            }
            else
            {
                return fetchResults[0].decode_value!
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return ""
        }
    }
    
    func getVisibleDecodes() -> [Decodes]
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        let predicate = NSPredicate(format: "(decodeType != \"hidden\") && (updateType != \"Delete\")")
        
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
 
    func updateDecodeValue(_ codeKey: String, codeValue: String, codeType: String, decode_privacy: String, updateCloud: Bool = true, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        // first check to see if decode exists, if not we create
        var myDecode: Decodes!
        
        if getDecodeValue(codeKey) == ""
        { // Add
            myDecode = Decodes(context: objectContext)
            
            myDecode.decode_name = codeKey
            myDecode.decode_value = codeValue
            myDecode.decodeType = codeType
            myDecode.decode_privacy = decode_privacy
            
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
            let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
            let predicate = NSPredicate(format: "(decode_name == \"\(codeKey)\") && (updateType != \"Delete\")")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
            
            // Execute the fetch request, and cast the results to an array of  objects
            do
            {
                let myDecodes = try objectContext.fetch(fetchRequest)
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
            catch
            {
                print("Error occurred during execution: \(error)")
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
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        let predicate = NSPredicate(format: "(decode_name == \"Device\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        var storeInt: Int = 1
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            {
                // Increment table value by 1 and save back to database
                storeInt = Int(fetchResults[0].decode_value!)! + 1
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            storeInt = 0
        }
        
        if storeInt > 0
        {
            let myValue = "\(coreDatabaseName) Sync \(storeInt)"
            
            writeDefaultString(coreDatabaseName, value: myValue)

            updateDecodeValue("Device", codeValue:  "\(storeInt)", codeType: "hidden", decode_privacy: "Private", updateCloud: false)
        }
    }

    func getNextID(_ tableName: String, saveToCloud: Bool = true, initialValue: Int = 1) -> Int
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        let predicate = NSPredicate(format: "(decode_name == \"\(tableName)\") && (updateType != \"Delete\")")
        
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
                updateDecodeValue(tableName, codeValue: storeKey, codeType: "hidden", decode_privacy: "Public", updateCloud: saveToCloud)
                return initialValue
            }
            else
            {
                // Increment table value by 1 and save back to database
                let storeint = Int(fetchResults[0].decode_value!)! + 1
                
                let storeKey = "\(storeint)"
                updateDecodeValue(tableName, codeValue: storeKey, codeType: "hidden", decode_privacy: "Public", updateCloud: saveToCloud)
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
    
    func setSyncDateforTable(tableName: String, syncDate: Date, updateCloud: Bool = true)
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = .full
        myDateFormatter.timeStyle = .full
        
        let dateString = myDateFormatter.string(from: syncDate)
        
        myDatabaseConnection.updateDecodeValue(myDBSync.getSyncString(tableName), codeValue: dateString, codeType: "hidden", decode_privacy: "Private", updateCloud: updateCloud)
    }
    
    func getSyncDateForTable(tableName: String) -> Date
    {
        let syncDateText = getSyncDecodeValue(myDBSync.getSyncString(tableName))
        var syncDate: Date = Date()
        let myDateFormatter = DateFormatter()
        
        if syncDateText == ""
        {
            myDateFormatter.dateStyle = DateFormatter.Style.short
            myDateFormatter.timeStyle = .none
            
            syncDate = myDateFormatter.date(from: "01/01/15")!
        }
        else
        {
            myDateFormatter.dateStyle = .full
            myDateFormatter.timeStyle = .full
            
            syncDate = myDateFormatter.date(from: syncDateText)!
        }

        return syncDate
    }
}

extension CloudKitInteraction
{
    func saveDecodesToCloudKit()
    {
        let syncDate = Date()
        
//        for myTeam in userTeams(userID: currentUser.userID).UserTeams
//        {
            for myItem in myDatabaseConnection.getDecodesForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Decodes"))
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
            myDatabaseConnection.setSyncDateforTable(tableName: "Decodes", syncDate: syncDate, updateCloud: false)
//        }
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
        let predicate = NSPredicate(format: "(decode_name == \"\(sourceRecord.decode_name!)\")") // better be accurate to get only the record you need
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

        myDatabaseConnection.updateDecodeValue(decodeName, codeValue: decodeValue, codeType: decodeType, decode_privacy: decode_privacy, updateCloud: false, updateTime: updateTime, updateType: updateType)
        
        self.recordCount -= 1
    }

}
