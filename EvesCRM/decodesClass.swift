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
    func getDecodeValue(_ inCodeKey: String) -> String
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        //     let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\") && (updateType != \"Delete\")")
        let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\")")
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
    
    func updateDecodeValue(_ inCodeKey: String, inCodeValue: String, inCodeType: String, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        // first check to see if decode exists, if not we create
        var myDecode: Decodes!
 print("Decode = \(inCodeKey)")
        if getDecodeValue(inCodeKey) == ""
        { // Add
            myDecode = Decodes(context: objectContext)
            
            myDecode.decode_name = inCodeKey
            myDecode.decode_value = inCodeValue
            myDecode.decodeType = inCodeType
            if inUpdateType == "CODE"
            {
                myDecode.updateTime =  NSDate()
                myDecode.updateType = "Add"
            }
            else
            {
                myDecode.updateTime = inUpdateTime as NSDate
                myDecode.updateType = inUpdateType
            }
        }
        else
        { // Update
            let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
            let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\") && (updateType != \"Delete\")")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
            
            // Execute the fetch request, and cast the results to an array of  objects
            do
            {
                let myDecodes = try objectContext.fetch(fetchRequest)
                myDecode = myDecodes[0]
                myDecode.decode_value = inCodeValue
                myDecode.decodeType = inCodeType
                if inUpdateType == "CODE"
                {
                    myDecode.updateTime =  NSDate()
                    if myDecode.updateType != "Add"
                    {
                        myDecode.updateType = "Update"
                    }
                }
                else
                {
                    myDecode.updateTime = inUpdateTime as NSDate
                    myDecode.updateType = inUpdateType
                }
            }
            catch
            {
                print("Error occurred during execution: \(error)")
            }
        }
        
        saveContext()
        
        myCloudDB.saveDecodesRecordToCloudKit(myDecode)
print("Done")
    }
    
    func replaceDecodeValue(_ inCodeKey: String, inCodeValue: String, inCodeType: String, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myDecode = Decodes(context: objectContext)
        
        myDecode.decode_name = inCodeKey
        myDecode.decode_value = inCodeValue
        myDecode.decodeType = inCodeType
        if inUpdateType == "CODE"
        {
            myDecode.updateTime =  NSDate()
            myDecode.updateType = "Add"
        }
        else
        {
            myDecode.updateTime = inUpdateTime as NSDate
            myDecode.updateType = inUpdateType
        }
        
        saveContext()
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
        let defaults = UserDefaults.standard
        
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
            let myValue = "\(appName) Sync \(storeInt)"
            defaults.set(myValue, forKey: appName)
            
            updateDecodeValue("Device", inCodeValue:  "\(storeInt)", inCodeType: "hidden")
        }
    }
    
    func getNextID(_ inTableName: String, inInitialValue: Int32 = 1) -> Int32
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        let predicate = NSPredicate(format: "(decode_name == \"\(inTableName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count == 0
            {
                // Create table entry
                let storeKey = "\(inInitialValue)"
                updateDecodeValue(inTableName, inCodeValue: storeKey, inCodeType: "hidden")
                return inInitialValue
            }
            else
            {
                // Increment table value by 1 and save back to database
                let storeint = Int32(fetchResults[0].decode_value!)! + 1
                
                let storeKey = "\(storeint)"
                updateDecodeValue(inTableName, inCodeValue: storeKey, inCodeType: "hidden")
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
    
    func performTidyDecodes(_ inString: String)
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: inString)
        
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
    
    func tidyDecodes()
    {
        performTidyDecodes("(decode_name == \"Context\") && (decode_value == \"1\")")
        performTidyDecodes("(decode_name == \"Projects\") && (decode_value == \"2\")")
        performTidyDecodes("(decode_name == \"Roles\") && (decode_value == \"8\")")
        performTidyDecodes("(decode_name == \"Vision\")")
        performTidyDecodes("(decode_name == \"PurposeAndCoreValue\")")
        performTidyDecodes("(decode_name == \"GoalAndObjective\")")
        performTidyDecodes("(decode_name == \"AreaOfResponsibility\")")
        performTidyDecodes("(decode_name == \"Outline\")")
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
    
    func setSyncDateforTable(tableName: String, syncDate: Date)
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = .full
        myDateFormatter.timeStyle = .full
        
        let dateString = myDateFormatter.string(from: syncDate)
        myDatabaseConnection.updateDecodeValue("\(tableName) Sync", inCodeValue: dateString, inCodeType: "hidden")
    }
    
    func getSyncDateForTable(tableName: String) -> Date
    {
        let syncDateText = getDecodeValue("\(tableName) Sync")
        var syncDate: Date!
        let myDateFormatter = DateFormatter()
        
        if syncDateText == ""
        {
            myDateFormatter.dateStyle = DateFormatter.Style.short
            
            syncDate = myDateFormatter.date(from: "01/01/15")
        }
        else
        {
            myDateFormatter.dateStyle = .full
            myDateFormatter.timeStyle = .full
            
            syncDate = myDateFormatter.date(from: syncDateText)
        }
        
        return syncDate
    }
}

extension CloudKitInteraction
{
    func saveDecodesToCloudKit()
    {
        for myItem in myDatabaseConnection.getDecodesForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Decodes"))
        {
            saveDecodesRecordToCloudKit(myItem)
        }
    }

    func updateDecodesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Decodes", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateDecodeRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteDecodes()
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
            self.performDelete(myRecordList)
            sem.signal()
        })
        
        sem.wait()
    }

    func replaceDecodesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Decodes", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateDecodeRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveDecodesRecordToCloudKit(_ sourceRecord: Decodes)
    {
print("gre1")
        let predicate = NSPredicate(format: "(decode_name == \"\(sourceRecord.decode_name!)\")") // better be accurate to get only the record you need
print("gre2")
        let query = CKQuery(recordType: "Decodes", predicate: predicate)
print("gre3")
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
print("gre4")
                if records!.count > 0
                {
                    // We need to do a check of the number for the tables, as otherwise we risk overwriting the changes
print("gre5")
                    
                    var updateRecord: Bool = true
                    
                    let record = records!.first// as! CKRecord
print("gre6")
                    
                    switch sourceRecord.decode_name!
                    {
                    case "Context" :
print("gre7")

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
print("gre8")

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
print("gre9")

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
print("gre10")

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
print("gre11")

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
print("gre12")

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
print("gre13")

                        let localValue = Int(sourceRecord.decode_value!)
print("gre14")
                        let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
print("gre15")
                        let remoteValue = Int(tempValue as! String)
print("gre16")
                        
                        if localValue! > remoteValue!
                        {
print("gre17")
                            updateRecord = true
                        }
                        else
                        {
print("gre18")
                            updateRecord = false
                        }
                        
                    case "Decodes":
print("gre19")
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
print("gre20")
                        updateRecord = true
                        
                        if sourceRecord.decode_name!.hasPrefix("\(appName) Sync")
                        {
                            updateRecord = true
                        }
                    }
                    
                    if updateRecord
                    {
print("gre21")

                        // Now you have grabbed your existing record from iCloud
                        // Apply whatever changes you want
                        record!.setValue(sourceRecord.decode_value, forKey: "decode_value")
                        record!.setValue(sourceRecord.decodeType, forKey: "decodeType")
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
print("gre22")
                       
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
                }
                else
                {  // Insert
                    let todoRecord = CKRecord(recordType: "Decodes")
                    todoRecord.setValue(sourceRecord.decode_name, forKey: "decode_name")
                    todoRecord.setValue(sourceRecord.decodeType, forKey: "decodeType")
                    todoRecord.setValue(sourceRecord.decode_value, forKey: "decode_value")
                    todoRecord.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    todoRecord.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.privateDB.save(todoRecord, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully saved record! \(sourceRecord.decode_name!)")
                            }
                        }
                    })
                }
            }
        })
        
    }

    func updateDecodeRecord(_ sourceRecord: CKRecord)
    {
        let decodeName = sourceRecord.object(forKey: "decode_name") as! String
        let decodeValue = sourceRecord.object(forKey: "decode_value") as! String
        let decodeType = sourceRecord.object(forKey: "decodeType") as! String
        
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
        
        myDatabaseConnection.updateDecodeValue(decodeName, inCodeValue: decodeValue, inCodeType: decodeType, inUpdateTime: updateTime, inUpdateType: updateType)
    }

}
