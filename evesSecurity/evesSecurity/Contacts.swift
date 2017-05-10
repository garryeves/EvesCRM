//
//  Contacts.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import Foundation
import CoreData
import CloudKit

class contacts: NSObject
{
    fileprivate var myContacts:[contact] = Array()
    
    init(personID: Int32)
    {
        for myItem in myDatabaseConnection.getContactDetails(personID)
        {
            let myObject = contact(personID: myItem.personID,
                                   contactType: myItem.contactType!,
                                   contactValue: myItem.contactValue!)
            myContacts.append(myObject)
        }
    }
    
    var contacts: [contact]
    {
        get
        {
            return myContacts
        }
    }
}

class contact: NSObject
{
    fileprivate var myPersonID: Int32 = 0
    fileprivate var myContactType: String = ""
    fileprivate var myContactValue: String = ""
    
    var personID: Int32
    {
        get
        {
            return myPersonID
        }
    }
    
    var contactType: String
    {
        get
        {
            return myContactType
        }
        set
        {
            myContactType = newValue
            save()
        }
    }
    
    var contactValue: String
    {
        get
        {
            return myContactValue
        }
        set
        {
            myContactValue = newValue
            save()
        }
    }
    
    override init()
    {
        super.init()
        
        myPersonID = myDatabaseConnection.getNextID("Contact")
        
        save()
    }
    
    init(personID: Int32)
    {
        super.init()
        let myReturn = myDatabaseConnection.getContactDetails(personID)
        
        for myItem in myReturn
        {
            myPersonID = myItem.personID
            myContactType = myItem.contactType!
            myContactValue = myItem.contactValue!
        }
    }
    
    init(personID: Int32,
         contactType: String,
         contactValue: String)
    {
        super.init()
        
        myPersonID = personID
        myContactType = contactType
        myContactValue = contactValue
    }
    
    func save()
    {
        myDatabaseConnection.saveContact(myPersonID,
                                         contactType: myContactType,
                                         contactValue: myContactValue)
    }
    
    func delete()
    {
        myDatabaseConnection.deleteContact(myPersonID, contactType: myContactType)
    }
}

extension coreDatabase
{
    func saveContact(_ personID: Int32,
                     contactType: String,
                     contactValue: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Contacts!
        
        let myReturn = getContactDetails(personID, contactType: contactType)
        
        if myReturn.count == 0
        { // Add
            myItem = Contacts(context: objectContext)
            myItem.personID = personID
            myItem.contactType = contactType
            myItem.contactValue = contactValue
            
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
            myItem.contactValue = contactValue
            
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
    
    func replaceContact(_ personID: Int32,
                        contactType: String,
                        contactValue: String,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = Contacts(context: objectContext)
        myItem.personID = personID
        myItem.contactType = contactType
        myItem.contactValue = contactValue
        
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
    
    func deleteContact(_ personID: Int32, contactType: String)
    {
        let myReturn = getContactDetails(personID, contactType: contactType)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getContactDetails(_ personID: Int32, contactType: String)->[Contacts]
    {
        let fetchRequest = NSFetchRequest<Contacts>(entityName: "Contacts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(personID == \(personID)) && (contactType = \"\(contactType)\") AND (updateType != \"Delete\")")
        
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
    
    func getContactDetails(_ personID: Int32)->[Contacts]
    {
        let fetchRequest = NSFetchRequest<Contacts>(entityName: "Contacts")
        
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
    
    func resetAllContacts()
    {
        let fetchRequest = NSFetchRequest<Contacts>(entityName: "Contacts")
        
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
    
    func clearDeletedContacts(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Contacts>(entityName: "Contacts")
        
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
    
    func clearSyncedContacts(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Contacts>(entityName: "Contacts")
        
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
    
    func getContactsForSync(_ syncDate: Date) -> [Contacts]
    {
        let fetchRequest = NSFetchRequest<Contacts>(entityName: "Contacts")
        
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
    
    func deleteAllContacts()
    {
        let fetchRequest2 = NSFetchRequest<Contacts>(entityName: "Contacts")
        
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
    func saveContactToCloudKit()
    {
        for myItem in myDatabaseConnection.getContactsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Contacts"))
        {
            saveContactRecordToCloudKit(myItem)
        }
    }
    
    func updateContactInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "Contacts") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Contacts", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateContactRecord(record)
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
    
    func deleteContact()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "Contacts", predicate: predicate)
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
    
    func replaceContactInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "Contacts", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let contactType = record.object(forKey: "contactType") as! String
            let contactValue = record.object(forKey: "contactValue") as! String
            
            var personID: Int32 = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int32
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
            
            myDatabaseConnection.replaceContact(personID,
                                                contactType: contactType,
                                                contactValue: contactValue
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
    
    func saveContactRecordToCloudKit(_ sourceRecord: Contacts)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(addressID == \(sourceRecord.personID)) AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Contacts", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.personID, forKey: "personID")
                    record!.setValue(sourceRecord.contactType, forKey: "contactType")
                    record!.setValue(sourceRecord.contactValue, forKey: "contactValue")
                    
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
                    let record = CKRecord(recordType: "Contacts")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.contactType, forKey: "contactType")
                    record.setValue(sourceRecord.contactValue, forKey: "contactValue")

                    
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
    
    func updateContactRecord(_ sourceRecord: CKRecord)
    {
        let contactType = sourceRecord.object(forKey: "contactType") as! String
        let contactValue = sourceRecord.object(forKey: "contactValue") as! String
        
        var personID: Int32 = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int32
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
        
        myDatabaseConnection.saveContact(personID,
                                         contactType: contactType,
                                         contactValue: contactValue
            , updateTime: updateTime, updateType: updateType)
    }
    
}
