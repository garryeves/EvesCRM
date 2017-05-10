//
//  clientsClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class clients: NSObject
{
    fileprivate var myClients:[client] = Array()
    
    override init()
    {
        for myItem in myDatabaseConnection.getClients()
        {
            let myObject = client(clientID: myItem.clientID,
                                    clientName: myItem.clientName!,
                                    clientContact: myItem.clientContact!)
            myClients.append(myObject)
        }
    }
    
    var clients: [client]
    {
        get
        {
            return myClients
        }
    }
}

class client: NSObject
{
    fileprivate var myClientID: Int32 = 0
    fileprivate var myClientName: String = ""
    fileprivate var myClientContact: String = ""
    
    var clientID: Int32
    {
        get
        {
            return myClientID
        }
    }
    
    var clientName: String
    {
        get
        {
            return myClientName
        }
        set
        {
            myClientName = newValue
            save()
        }
    }
    
    var clientContact: String
    {
        get
        {
            return myClientContact
        }
        set
        {
            myClientContact = newValue
            save()
        }
    }
    
    override init()
    {
        super.init()
        
        myClientID = myDatabaseConnection.getNextID("Client")
        
        save()
    }
    
    init(clientID: Int32)
    {
        super.init()
        let myReturn = myDatabaseConnection.getClientDetails(clientID: clientID)
        
        for myItem in myReturn
        {
            myClientID = myItem.clientID
            myClientName = myItem.clientName!
            myClientContact = myItem.clientContact!
        }
    }
    
    init(clientID: Int32,
         clientName: String,
         clientContact: String)
    {
        super.init()
        
        myClientID = clientID
        myClientName = clientName
        myClientContact = clientContact

    }
    
    func save()
    {
        myDatabaseConnection.saveClient(myClientID,
                                        clientName: myClientName,
                                        clientContact: myClientContact)
    }
    
    func delete()
    {
        myDatabaseConnection.deleteClient(myClientID)
    }
}

extension coreDatabase
{
    func saveClient(_ clientID: Int32,
                    clientName: String,
                    clientContact: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Clients!
        
        let myReturn = getClientDetails(clientID: clientID)
        
        if myReturn.count == 0
        { // Add
            myItem = Clients(context: objectContext)
            myItem.clientID = clientID
            myItem.clientName = clientName
            myItem.clientContact = clientContact

            
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
            myItem.clientName = clientName
            myItem.clientContact = clientContact
            
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
    
    func replaceClient(_ clientID: Int32,
                        clientName: String,
                        clientContact: String,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = Clients(context: objectContext)
        myItem.clientID = clientID
        myItem.clientName = clientName
        myItem.clientContact = clientContact
        
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
    
    func deleteClient(_ clientID: Int32)
    {
        let myReturn = getClientDetails(clientID: clientID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getClientDetails(clientID: Int32)->[Clients]
    {
        let fetchRequest = NSFetchRequest<Clients>(entityName: "Clients")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(personID != \(clientID)) && (updateType != \"Delete\")")
        
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

    
    func getClients() -> [Clients]
    {
        let fetchRequest = NSFetchRequest<Clients>(entityName: "Clients")
        
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
    
    func resetAllClients()
    {
        let fetchRequest = NSFetchRequest<Clients>(entityName: "Clients")
        
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
    
    func clearDeletedClients(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Clients>(entityName: "Clients")
        
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
    
    func clearSyncedClients(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Clients>(entityName: "Clients")
        
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
    
    func getClientsForSync(_ syncDate: Date) -> [Clients]
    {
        let fetchRequest = NSFetchRequest<Clients>(entityName: "Clients")
        
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
    
    func deleteAllClients()
    {
        let fetchRequest2 = NSFetchRequest<Clients>(entityName: "Clients")
        
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
    func saveClientToCloudKit()
    {
        for myItem in myDatabaseConnection.getClientsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Clients"))
        {
            saveClientRecordToCloudKit(myItem)
        }
    }
    
    func updateClientInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "Clients") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Clients", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateClientRecord(record)
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
    
    func deleteClient()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "Clients", predicate: predicate)
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
    
    func replaceClientInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "Clients", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let clientName = record.object(forKey: "clientName") as! String
            let clientContact = record.object(forKey: "clientContact") as! String
        
            var clientID: Int32 = 0
            if record.object(forKey: "clientID") != nil
            {
                clientID = record.object(forKey: "clientID") as! Int32
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
            
            myDatabaseConnection.replaceClient(clientID,
                                               clientName: clientName,
                                               clientContact: clientContact
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
    
    func saveClientRecordToCloudKit(_ sourceRecord: Clients)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(clientID == \(sourceRecord.clientID)) AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Clients", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.clientID, forKey: "clientID")
                    record!.setValue(sourceRecord.clientName, forKey: "clientName,")
                    record!.setValue(sourceRecord.clientContact, forKey: "clientContact")
                    
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
                    let record = CKRecord(recordType: "Clients")
                    
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.clientName, forKey: "clientName,")
                    record.setValue(sourceRecord.clientContact, forKey: "clientContact")

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
    
    func updateClientRecord(_ sourceRecord: CKRecord)
    {
        let clientName = sourceRecord.object(forKey: "clientName") as! String
        let clientContact = sourceRecord.object(forKey: "clientContact") as! String
        
        var clientID: Int32 = 0
        if sourceRecord.object(forKey: "clientID") != nil
        {
            clientID = sourceRecord.object(forKey: "clientID") as! Int32
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
        
        myDatabaseConnection.saveClient(clientID,
                                         clientName: clientName,
                                         clientContact: clientContact
            , updateTime: updateTime, updateType: updateType)
    }
    
}

