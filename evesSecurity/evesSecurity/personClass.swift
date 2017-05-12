//
//  personClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class people: NSObject
{
    fileprivate var myPeople:[person] = Array()
    
    override init()
    {
        for myItem in myDatabaseConnection.getPeople()
        {
            let dob: Date = myItem.dob! as Date
            
            let myObject = person(personID: myItem.personID,
                                  name: myItem.name!,
                                  dob: dob
                                   )
            myPeople.append(myObject)
        }
    }
    
    var people: [person]
    {
        get
        {
            return myPeople
        }
    }
}

class person: NSObject
{
    fileprivate var myPersonID: Int32 = 0
    fileprivate var myName: String = ""
    fileprivate var myDob: Date = getDefaultDate()
    fileprivate var myAddresses: personAddresses!
    fileprivate var myContacts: personContacts!
    fileprivate var myAddInfo: personAddInfoEntries!
    
    var personID: Int32
    {
        get
        {
            return myPersonID
        }
    }
    
    var name: String
    {
        get
        {
            return myName
        }
        set
        {
            myName = newValue
            save()
        }
    }
    
    var dob: Date
    {
        get
        {
            return myDob
        }
        set
        {
            myDob = newValue
            save()
        }
    }
    
    var addresses: [address]
    {
        get
        {
            if myAddresses == nil
            {
                return []
            }
            else
            {
                return myAddresses.addresses
            }
        }
    }
    
    var contacts: [contact]
    {
        get
        {
            if myContacts == nil
            {
                return []
            }
            else
            {
                return myContacts.contacts
            }
        }
    }
    
    var addInfo: [personAddInfoEntry]
    {
        get
        {
            if myAddInfo == nil
            {
                return []
            }
            else
            {
                return myAddInfo.personAddEntries
            }
        }
    }
    
    override init()
    {
        super.init()
        
        myPersonID = myDatabaseConnection.getNextID("Person")
        
        save()
    }
    
    init(personID: Int32)
    {
        super.init()
        let myReturn = myDatabaseConnection.getPersonDetails(personID)
        
        for myItem in myReturn
        {
            myPersonID = myItem.personID
            myName = myItem.name!
            myDob = myItem.dob! as Date
            
            loadAddresses()
            
            loadContacts()
            
            loadAddInfo()
        }
    }
    
    init(personID: Int32,
         name: String,
         dob: Date
         )
    {
        super.init()
        
        myPersonID = personID
        myName = name
        myDob = dob
        
        loadAddresses()
        
        loadContacts()
        
        loadAddInfo()
    }
    
    func save()
    {
        myDatabaseConnection.savePerson(myPersonID,
                                         name: name,
                                         dob: dob
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deletePerson(myPersonID)
    }
    
    func deleteAddress(addressType: String)
    {
        for myItem in myAddresses.addresses
        {
            if myItem.addressType == addressType
            {
                myItem.delete()
                break
            }
        }
        
        loadAddresses()
    }
    
    func loadAddresses()
    {
        myAddresses = personAddresses(personID: myPersonID)
    }
    
    func removeContact(contactType: String)
    {
        for myItem in myContacts.contacts
        {
            if myItem.contactType == contactType
            {
                myItem.delete()
                break
            }
        }
        
        loadContacts()
    }
    
    func loadContacts()
    {
        myContacts = personContacts(personID: myPersonID)
    }
    
    func removeAddInfo(addInfoType: String)
    {
        for myItem in myAddInfo.personAddEntries
        {
            if myItem.addInfoName == addInfoType
            {
                myItem.delete()
                break
            }
        }
        
        loadAddInfo()
    }
    
    func loadAddInfo()
    {
        myAddInfo = personAddInfoEntries(personID: myPersonID)
    }
}

extension coreDatabase
{
    func savePerson(_ personID: Int32,
                    name: String,
                    dob: Date,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Person!
        
        let myReturn = getPersonDetails(personID)
        
        if myReturn.count == 0
        { // Add
            myItem = Person(context: objectContext)
            myItem.personID = personID
            myItem.name = name
            myItem.dob = dob as NSDate
            
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
            myItem.name = name
            myItem.dob = dob as NSDate
            
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
    
    func replacePerson(_ personID: Int32,
                       name: String,
                       dob: Date,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = Person(context: objectContext)
        myItem.personID = personID
        myItem.name = name
        myItem.dob = dob as NSDate
        
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
    
    func deletePerson(_ personID: Int32)
    {
        let myReturn = getPersonDetails(personID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getPersonDetails(_ personID: Int32)->[Person]
    {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
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
    
    func getPeople()->[Person]
    {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
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
    
    func resetAllPerson()
    {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
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
    
    func clearDeletedPerson(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Person>(entityName: "Person")
        
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
    
    func clearSyncedPerson(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Person>(entityName: "Person")
        
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
    
    func getPersonForSync(_ syncDate: Date) -> [Person]
    {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
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
    
    func deleteAllPerson()
    {
        let fetchRequest2 = NSFetchRequest<Person>(entityName: "Person")
        
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
    func savePersonToCloudKit()
    {
        for myItem in myDatabaseConnection.getPersonForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Person"))
        {
            savePersonRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updatePersonInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(teamID))", myDatabaseConnection.getSyncDateForTable(tableName: "Person") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Person", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updatePersonRecord(record)
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
    
    func deletePerson(personID: Int32, teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID)) AND (personID == \(personID)) ")
        let query: CKQuery = CKQuery(recordType: "Person", predicate: predicate)
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
    
    func replacePersonInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "Person", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let name = record.object(forKey: "name") as! String
            
            var personID: Int32 = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int32
            }
            
            var dob = Date()
            if record.object(forKey: "dob") != nil
            {
                dob = record.object(forKey: "dob") as! Date
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
            
            myDatabaseConnection.replacePerson(personID,
                                                name: name,
                                                dob: dob
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
    
    func savePersonRecordToCloudKit(_ sourceRecord: Person, teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(personID == \(sourceRecord.personID)) AND (teamID == \(teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Person", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.dob, forKey: "dob")
                    
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
                    let record = CKRecord(recordType: "People")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.dob, forKey: "dob")
                    
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
    
    func updatePersonRecord(_ sourceRecord: CKRecord)
    {
        let name = sourceRecord.object(forKey: "name") as! String
        
        var personID: Int32 = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int32
        }
        
        var dob = Date()
        if sourceRecord.object(forKey: "dob") != nil
        {
            dob = sourceRecord.object(forKey: "dob") as! Date
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
        
        myDatabaseConnection.savePerson(personID,
                                         name: name,
                                         dob: dob
                                         , updateTime: updateTime, updateType: updateType)
    }
}

