//
//  addressClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class addresses: NSObject
{
    fileprivate var myAddresses:[address] = Array()
    
    init(personID: Int32)
    {
        for myItem in myDatabaseConnection.getAddressForPerson(personID: personID)
        {
            let myContext = address(addressID: myItem.addressID,
                                    addressLine1: myItem.addressLine1!,
                                    addressLine2: myItem.addressLine2!,
                                    city: myItem.city!,
                                    clientID: myItem.clientID,
                                    country: myItem.country!,
                                    personID: myItem.personID,
                                    postcode: myItem.postcode!,
                                    projectID: myItem.projectID,
                                    state: myItem.state!)
                myAddresses.append(myContext)
        }
    }
    
    init(clientID: Int32)
    {
        for myItem in myDatabaseConnection.getAddressForClient(clientID: clientID)
        {
            let myContext = address(addressID: myItem.addressID,
                                    addressLine1: myItem.addressLine1!,
                                    addressLine2: myItem.addressLine2!,
                                    city: myItem.city!,
                                    clientID: myItem.clientID,
                                    country: myItem.country!,
                                    personID: myItem.personID,
                                    postcode: myItem.postcode!,
                                    projectID: myItem.projectID,
                                    state: myItem.state!)
            myAddresses.append(myContext)
        }
    }
    
    var addresses: [address]
    {
        get
        {
            return myAddresses
        }
    }
}

class address: NSObject
{
    fileprivate var myAddressID: Int32 = 0
    fileprivate var myAddressLine1: String = ""
    fileprivate var myAddressLine2: String = ""
    fileprivate var myCity: String = ""
    fileprivate var myClientID: Int32 = 0
    fileprivate var myCountry: String = ""
    fileprivate var myPersonID: Int32 = 0
    fileprivate var myPostcode: String = ""
    fileprivate var myProjectID: Int32 = 0
    fileprivate var myState: String = ""

    var addressID: Int32
    {
        get
        {
            return myAddressID
        }
    }
    
    var addressLine1: String
    {
        get
        {
            return myAddressLine1
        }
        set
        {
            myAddressLine1 = newValue
            save()
        }
    }
    
    var addressLine2: String
    {
        get
        {
            return myAddressLine2
        }
        set
        {
            myAddressLine2 = newValue
            save()
        }
    }
    
    var city: String
    {
        get
        {
            return myCity
        }
        set
        {
            myCity = newValue
            save()
        }
    }
    
    var clientID: Int32
    {
        get
        {
            return myClientID
        }
        set
        {
            myClientID = newValue
            save()
        }
    }
    
    var country: String
    {
        get
        {
            return myCountry
        }
        set
        {
            myCountry = newValue
            save()
        }
    }
    
    var personID: Int32
    {
        get
        {
            return myPersonID
        }
        set
        {
            myPersonID = newValue
            save()
        }
    }
    
    var postcode: String
    {
        get
        {
            return myPostcode
        }
        set
        {
            myPostcode = newValue
            save()
        }
    }
    
    var projectID: Int32
    {
        get
        {
            return myProjectID
        }
        set
        {
            myProjectID = newValue
            save()
        }
    }
    
    var state: String
    {
        get
        {
            return myState
        }
        set
        {
            myState = newValue
            save()
        }
    }
    
    override init()
    {
        super.init()
        
        myAddressID = myDatabaseConnection.getNextID("Person")
        
        save()
    }
    
    init(addressID: Int32)
    {
        super.init()
        let myReturn = myDatabaseConnection.getAddressDetails(addressID)
        
        for myItem in myReturn
        {
            myAddressID = myItem.addressID
            myAddressLine1 = myItem.addressLine1!
            myAddressLine2 = myItem.addressLine2!
            myCity = myItem.city!
            myClientID = myItem.clientID
            myCountry = myItem.country!
            myPersonID = myItem.personID
            myPostcode = myItem.postcode!
            myProjectID = myItem.projectID
            myState = myItem.state!
        }
    }
    
    init(addressID: Int32,
        addressLine1: String,
        addressLine2: String,
        city: String,
        clientID: Int32,
        country: String,
        personID: Int32,
        postcode: String,
        projectID: Int32,
        state: String)
    {
        super.init()
        
        myAddressID = addressID
        myAddressLine1 = addressLine1
        myAddressLine2 = addressLine2
        myCity = city
        myClientID = clientID
        myCountry = country
        myPersonID = personID
        myPostcode = postcode
        myProjectID = projectID
        myState = state
    }

    func save()
    {
        myDatabaseConnection.saveAddress(myAddressID,
            addressLine1: myAddressLine1,
            addressLine2: myAddressLine2,
            city: myCity,
            clientID: myClientID,
            country: myCountry,
            personID: myPersonID,
            postcode: myPostcode,
            projectID: myProjectID,
            state: myState)
    }
    
    func delete()
    {
        myDatabaseConnection.deleteAddress(myAddressID)
    }
}

extension coreDatabase
{
    func saveAddress(_ addressID: Int32,
                     addressLine1: String,
                     addressLine2: String,
                     city: String,
                     clientID: Int32,
                     country: String,
                     personID: Int32,
                     postcode: String,
                     projectID: Int32,
                     state: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Addresses!
        
        let myReturn = getAddressDetails(addressID)
        
        if myReturn.count == 0
        { // Add
            myItem = Addresses(context: objectContext)
            myItem.addressID = addressID
            myItem.addressLine1 = addressLine1
            myItem.addressLine2 = addressLine2
            myItem.city = city
            myItem.clientID = clientID
            myItem.country = country
            myItem.personID = personID
            myItem.postcode = postcode
            myItem.projectID = projectID
            myItem.state = state

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
            myItem.addressLine1 = addressLine1
            myItem.addressLine2 = addressLine2
            myItem.city = city
            myItem.clientID = clientID
            myItem.country = country
            myItem.personID = personID
            myItem.postcode = postcode
            myItem.projectID = projectID
            myItem.state = state
            
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
    
    func replaceAddress(_ addressID: Int32,
                        addressLine1: String,
                        addressLine2: String,
                        city: String,
                        clientID: Int32,
                        country: String,
                        personID: Int32,
                        postcode: String,
                        projectID: Int32,
                        state: String,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = Addresses(context: objectContext)
        myItem.addressID = addressID
        myItem.addressLine1 = addressLine1
        myItem.addressLine2 = addressLine2
        myItem.city = city
        myItem.clientID = clientID
        myItem.country = country
        myItem.personID = personID
        myItem.postcode = postcode
        myItem.projectID = projectID
        myItem.state = state
        
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
    
    func deleteAddress(_ addressID: Int32)
    {
        let myReturn = getAddressDetails(addressID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getAddressForPerson(personID: Int32)->[Addresses]
    {
        let fetchRequest = NSFetchRequest<Addresses>(entityName: "Addresses")
        
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
    
    func getAddressForClient(clientID: Int32)->[Addresses]
    {
        let fetchRequest = NSFetchRequest<Addresses>(entityName: "Addresses")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(clientID == \(clientID)) && (updateType != \"Delete\")")
        
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

    func getAddressDetails(_ addressID: Int32)->[Addresses]
    {
        let fetchRequest = NSFetchRequest<Addresses>(entityName: "Addresses")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(addressID == \(addressID)) && (updateType != \"Delete\")")
        
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
    
    func resetAllAddresses()
    {
        let fetchRequest = NSFetchRequest<Addresses>(entityName: "Addresses")
        
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
    
    func clearDeletedAddresses(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Addresses>(entityName: "Addresses")
        
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
    
    func clearSyncedAddresses(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Addresses>(entityName: "Addresses")
        
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
    
    func getAddressesForSync(_ syncDate: Date) -> [Addresses]
    {
        let fetchRequest = NSFetchRequest<Addresses>(entityName: "Addresses")
        
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
    
    func deleteAllAddresses()
    {
        let fetchRequest2 = NSFetchRequest<Addresses>(entityName: "Addresses")
        
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
    func saveAddressToCloudKit()
    {
        for myItem in myDatabaseConnection.getAddressesForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Addresses"))
        {
            saveAddressRecordToCloudKit(myItem)
        }
    }
    
    func updateAddressInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "Addresses") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Addresses", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateAddressRecord(record)
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
    
    func deleteAddress()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "Addresses", predicate: predicate)
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
    
    func replaceAddressInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "Addresses", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let addressLine1 = record.object(forKey: "addressLine1") as! String
            let addressLine2 = record.object(forKey: "addressLine2") as! String
            let city = record.object(forKey: "city") as! String
            let country = record.object(forKey: "country") as! String
            let postcode = record.object(forKey: "postcode") as! String
            let state = record.object(forKey: "state") as! String
            
            var addressID: Int32 = 0
            if record.object(forKey: "addressID") != nil
            {
                addressID = record.object(forKey: "addressID") as! Int32
            }

            var clientID: Int32 = 0
            if record.object(forKey: "clientID") != nil
            {
                clientID = record.object(forKey: "clientID") as! Int32
            }

            var personID: Int32 = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int32
            }
            
            var projectID: Int32 = 0
            if record.object(forKey: "projectID") != nil
            {
                projectID = record.object(forKey: "projectID") as! Int32
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
            
            myDatabaseConnection.replaceAddress(addressID,
                                                addressLine1: addressLine1,
                                                addressLine2: addressLine2,
                                                city: city,
                                                clientID: clientID,
                                                country: country,
                                                personID: personID,
                                                postcode: postcode,
                                                projectID: projectID,
                                                state: state
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
    
    func saveAddressRecordToCloudKit(_ sourceRecord: Addresses)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(addressID == \(sourceRecord.addressID)) AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Addresses", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.addressID, forKey: "addressID")
                    record!.setValue(sourceRecord.addressLine1, forKey: "addressLine1")
                    record!.setValue(sourceRecord.addressLine2, forKey: "addressLine2")
                    record!.setValue(sourceRecord.city, forKey: "city")
                    record!.setValue(sourceRecord.clientID, forKey: "clientID")
                    record!.setValue(sourceRecord.country, forKey: "country")
                    record!.setValue(sourceRecord.personID, forKey: "personID")
                    record!.setValue(sourceRecord.postcode, forKey: "postcode")
                    record!.setValue(sourceRecord.projectID, forKey: "projectID")
                    record!.setValue(sourceRecord.state, forKey: "state")
                    
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
                    let record = CKRecord(recordType: "Addresses")
                    record.setValue(sourceRecord.addressID, forKey: "addressID")
                    record.setValue(sourceRecord.addressLine1, forKey: "addressLine1")
                    record.setValue(sourceRecord.addressLine2, forKey: "addressLine2")
                    record.setValue(sourceRecord.city, forKey: "city")
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.country, forKey: "country")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.postcode, forKey: "postcode")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.state, forKey: "state")
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
    
    func updateAddressRecord(_ sourceRecord: CKRecord)
    {
        let addressLine1 = sourceRecord.object(forKey: "addressLine1") as! String
        let addressLine2 = sourceRecord.object(forKey: "addressLine2") as! String
        let city = sourceRecord.object(forKey: "city") as! String
        let country = sourceRecord.object(forKey: "country") as! String
        let postcode = sourceRecord.object(forKey: "postcode") as! String
        let state = sourceRecord.object(forKey: "state") as! String
        
        var addressID: Int32 = 0
        if sourceRecord.object(forKey: "addressID") != nil
        {
            addressID = sourceRecord.object(forKey: "addressID") as! Int32
        }
        
        var clientID: Int32 = 0
        if sourceRecord.object(forKey: "clientID") != nil
        {
            clientID = sourceRecord.object(forKey: "clientID") as! Int32
        }
        
        var personID: Int32 = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int32
        }
        
        var projectID: Int32 = 0
        if sourceRecord.object(forKey: "projectID") != nil
        {
            projectID = sourceRecord.object(forKey: "projectID") as! Int32
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
        
        myDatabaseConnection.saveAddress(addressID,
                                         addressLine1: addressLine1,
                                         addressLine2: addressLine2,
                                         city: city,
                                         clientID: clientID,
                                         country: country,
                                         personID: personID,
                                         postcode: postcode,
                                         projectID: projectID,
                                         state: state
                , updateTime: updateTime, updateType: updateType)
    }
    
}
