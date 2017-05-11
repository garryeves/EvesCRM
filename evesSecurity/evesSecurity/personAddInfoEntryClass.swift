//
//  personAddInfoEntryClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class personAddInfoEntries: NSObject
{
    fileprivate var myPersonAddEntries:[personAddInfoEntry] = Array()
    
    init(personID: Int32)
    {
        for myItem in myDatabaseConnection.getPersonAddInfoEntryForPerson(personID)
        {
            let myObject = personAddInfoEntry(addInfoName: myItem.addInfoName!,
                                              dateValue: myItem.dateValue! as Date,
                                              personID: myItem.personID,
                                              stringValue: myItem.stringValue!
                                   )
            myPersonAddEntries.append(myObject)
        }
    }
    
    var personAddEntries: [personAddInfoEntry]
    {
        get
        {
            return myPersonAddEntries
        }
    }
}

class personAddInfoEntry: NSObject
{
    fileprivate var myAddInfoName: String = ""
    fileprivate var myDateValue: Date = getDefaultDate()
    fileprivate var myPersonID: Int32 = 0
    fileprivate var myStringValue: String = ""
    
    var addInfoName: String
    {
        get
        {
            return myAddInfoName
        }
    }
    
    var personID: Int32
    {
        get
        {
            return myPersonID
        }
    }
    
    var dateValue: Date
    {
        get
        {
            return myDateValue
        }
        set
        {
            myDateValue = newValue
            save()
        }
    }
    
    var stringValue: String
    {
        get
        {
            return myStringValue
        }
        set
        {
            myStringValue = newValue
            save()
        }
    }
    
    init(addInfoName: String, personID: Int32)
    {
        super.init()
        let myReturn = myDatabaseConnection.getPersonAddInfoEntryDetails(addInfoName, personID: personID)
        
        for myItem in myReturn
        {
            myAddInfoName = myItem.addInfoName!
            myDateValue = myItem.dateValue! as Date
            myPersonID = myItem.personID
            myStringValue = myItem.stringValue!
        }
    }
    
    init(addInfoName: String,
         dateValue: Date,
         personID: Int32,
         stringValue: String
         )
    {
        super.init()
        
        myAddInfoName = addInfoName
        myDateValue = dateValue
        myPersonID = personID
        myStringValue = stringValue
    }
    
    func save()
    {
        myDatabaseConnection.savePersonAddInfoEntry(myAddInfoName,
                                                    dateValue: myDateValue,
                                                    personID: myPersonID,
                                                    stringValue: myStringValue
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deletePersonAddInfoEntry(addInfoName,
                                                      personID: personID)
    }
}

extension coreDatabase
{
    func savePersonAddInfoEntry(_ addInfoName: String,
                                dateValue: Date,
                                personID: Int32,
                                stringValue: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: PersonAddInfoEntry!
        
        let myReturn = getPersonAddInfoEntryDetails(addInfoName, personID: personID)
        
        if myReturn.count == 0
        { // Add
            myItem = PersonAddInfoEntry(context: objectContext)
            myItem.addInfoName = addInfoName
            myItem.dateValue = dateValue as NSDate
            myItem.personID = personID
            myItem.stringValue = stringValue
            
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
            myItem.dateValue = dateValue as NSDate
            myItem.stringValue = stringValue
            
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
    
    func replacePersonAddInfoEntry(_ addInfoName: String,
                                   dateValue: Date,
                                   personID: Int32,
                                   stringValue: String,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = PersonAddInfoEntry(context: objectContext)
        myItem.addInfoName = addInfoName
        myItem.dateValue = dateValue as NSDate
        myItem.personID = personID
        myItem.stringValue = stringValue
        
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
    
    func deletePersonAddInfoEntry(_ addInfoName: String,
                                  personID: Int32)
    {
        let myReturn = getPersonAddInfoEntryDetails(addInfoName, personID: personID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getPersonAddInfoEntryForPerson(_ personID: Int32)->[PersonAddInfoEntry]
    {
        let fetchRequest = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(personID == \(personID)) && (updateType != \"Delete\")")
        
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

    
    func getPersonAddInfoEntryDetails(_ addInfoName: String, personID: Int32)->[PersonAddInfoEntry]
    {
        let fetchRequest = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(personID == \(personID)) && (addInfoName == \"\(addInfoName)\") AND (updateType != \"Delete\")")
        
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
    
    func resetAllPersonAddInfoEntries()
    {
        let fetchRequest = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
        
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
    
    func clearDeletedPersonAddInfoEntries(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
        
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
    
    func clearSyncedPersonAddInfoEntries(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
        
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
    
    func getPersonAddInfoEntriesForSync(_ syncDate: Date) -> [PersonAddInfoEntry]
    {
        let fetchRequest = NSFetchRequest<PersonAddInfoEntry>(entityName: "AddrePersonAddInfoEntrysses")
        
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
    
    func deleteAllPersonAddInfoEntries()
    {
        let fetchRequest2 = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
        
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
    func savePersonAddInfoEntryToCloudKit()
    {
        for myItem in myDatabaseConnection.getPersonAddInfoEntriesForSync(myDatabaseConnection.getSyncDateForTable(tableName: "PersonAddInfoEntry"))
        {
            savePersonAddInfoEntryRecordToCloudKit(myItem)
        }
    }
    
    func updatePersonAddInfoEntryInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "PersonAddInfoEntry") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updatePersonAddInfoEntryRecord(record)
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
    
    func deletePersonAddInfoEntry(personID: Int32, addInfoName: Int32)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID)) AND (personID == \(personID)) AND (addInfoName == \"\(addInfoName)\") ")
        let query: CKQuery = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
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
    
    func replacePersonAddInfoEntryInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            
            let addInfoName = record.object(forKey: "addInfoName") as! String
            let stringValue = record.object(forKey: "stringValue") as! String
            
            var personID: Int32 = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int32
            }
            
            var dateValue = Date()
            if record.object(forKey: "dateValue") != nil
            {
                dateValue = record.object(forKey: "dateValue") as! Date
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
            
            myDatabaseConnection.replacePersonAddInfoEntry(addInfoName,
                                                           dateValue: dateValue,
                                                           personID: personID,
                                                           stringValue: stringValue
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
    
    func savePersonAddInfoEntryRecordToCloudKit(_ sourceRecord: PersonAddInfoEntry)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(addInfoName == \"\(sourceRecord.addInfoName!)\") AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
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

                    record!.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record!.setValue(sourceRecord.stringValue, forKey: "stringValue")
                    record!.setValue(sourceRecord.personID, forKey: "personID")
                    record!.setValue(sourceRecord.dateValue, forKey: "dateValue")
                    
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
                    let record = CKRecord(recordType: "PersonAddInfoEntry")
                    record.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record.setValue(sourceRecord.stringValue, forKey: "stringValue")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.dateValue, forKey: "dateValue")
                    
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
    
    func updatePersonAddInfoEntryRecord(_ sourceRecord: CKRecord)
    {
        let addInfoName = sourceRecord.object(forKey: "addInfoName") as! String
        let stringValue = sourceRecord.object(forKey: "stringValue") as! String
        
        var personID: Int32 = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int32
        }
        
        var dateValue = Date()
        if sourceRecord.object(forKey: "dateValue") != nil
        {
            dateValue = sourceRecord.object(forKey: "dateValue") as! Date
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
        
        myDatabaseConnection.savePersonAddInfoEntry(addInfoName,
                                         dateValue: dateValue,
                                         personID: personID,
                                         stringValue: stringValue
                                         , updateTime: updateTime, updateType: updateType)
    }
    
}

