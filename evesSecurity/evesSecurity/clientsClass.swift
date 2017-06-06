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
    
    init(teamID: Int)
    {
        for myItem in myDatabaseConnection.getClients(teamID: teamID)
        {
            let myObject = client(clientID: Int(myItem.clientID),
                                    clientName: myItem.clientName!,
                                    clientContact: Int(myItem.clientContact),
                                    teamID: Int(myItem.teamID),
                                    note: myItem.note!
            )
            myClients.append(myObject)
        }
    }
    
    init(query: String, teamID: Int)
    {
        var returnArray: [Clients] = Array()
        
        myClients.removeAll()
        
        switch query
        {
            case "client no project":
                for myItem in myDatabaseConnection.getClients(teamID: teamID)
                {
                    let myReturn = projects(clientID: Int(myItem.clientID))
                    
                    if myReturn.projects.count == 0
                    {
                        returnArray.append(myItem)
                    }
                }
            
            case "client no rate":
                for myItem in myDatabaseConnection.getClients(teamID: teamID)
                {
                    let myReturn = rates(clientID: Int(myItem.clientID))
                    
                    if myReturn.rates.count == 0
                    {
                        returnArray.append(myItem)
                    }
                }
            
            default:
                let _ = 1
        }
        
        for myItem in returnArray
        {
            let myObject = client(clientID: Int(myItem.clientID),
                                  clientName: myItem.clientName!,
                                  clientContact: Int(myItem.clientContact),
                                  teamID: Int(myItem.teamID),
                                  note: myItem.note!
            )
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
    fileprivate var myClientID: Int = 0
    fileprivate var myClientName: String = ""
    fileprivate var myClientContact: Int = 0
    fileprivate var myClientNote: String = ""
    fileprivate var myTeamID: Int = 0
    
    var clientID: Int
    {
        get
        {
            return myClientID
        }
    }
    
    var name: String
    {
        get
        {
            return myClientName
        }
        set
        {
            myClientName = newValue
        }
    }
    
    var note: String
    {
        get
        {
            return myClientNote
        }
        set
        {
            myClientNote = newValue
        }
    }
    
    var contact: Int
    {
        get
        {
            return myClientContact
        }
        set
        {
            myClientContact = newValue
        }
    }
    
    var projectList: [project]
    {
        return projects(clientID: myClientID, type: "").projects
    }
    
    init(teamID: Int)
    {
        super.init()
        
        myClientID = myDatabaseConnection.getNextID("Client")
        
        myTeamID = teamID
        
        save()
    }
    
    init(clientID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getClientDetails(clientID: clientID)
        
        for myItem in myReturn
        {
            myClientID = Int(myItem.clientID)
            myClientName = myItem.clientName!
            myClientContact = Int(myItem.clientContact)
            myTeamID = Int(myItem.teamID)
            myClientNote = myItem.note!
        }
    }
    
    init(clientID: Int,
         clientName: String,
         clientContact: Int,
         teamID: Int,
         note: String)
    {
        super.init()
        
        myClientID = clientID
        myClientName = clientName
        myClientContact = clientContact
        myTeamID = teamID
        myClientNote = note
    }
    
    func save()
    {
        myDatabaseConnection.saveClient(myClientID,
                                        clientName: myClientName,
                                        clientContact: myClientContact, teamID: myTeamID, note: myClientNote)
    }
    
    func delete()
    {
        myDatabaseConnection.deleteClient(myClientID)
    }
}

extension coreDatabase
{
    func saveClient(_ clientID: Int,
                    clientName: String,
                    clientContact: Int,
                    teamID: Int,
                    note: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Clients!
        
        let myReturn = getClientDetails(clientID: clientID)
        
        if myReturn.count == 0
        { // Add
            myItem = Clients(context: objectContext)
            myItem.clientID = Int64(clientID)
            myItem.clientName = clientName
            myItem.clientContact = Int64(clientContact)
            myItem.teamID = Int64(teamID)
            myItem.note = note
            
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
            myItem.clientContact = Int64(clientContact)
            myItem.note = note
            
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

        self.recordsProcessed += 1
    }
        
    func deleteClient(_ clientID: Int)
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
    
    func getClientDetails(clientID: Int)->[Clients]
    {
        let fetchRequest = NSFetchRequest<Clients>(entityName: "Clients")
        
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

    
    func getClients(teamID: Int) -> [Clients]
    {
        let fetchRequest = NSFetchRequest<Clients>(entityName: "Clients")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
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
            saveClientRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateClientInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "Clients") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Clients", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateClientRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Clients", queryOperation: operation, onOperationQueue: operationQueue)
    }
    
    func deleteClient(clientID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (client != \(clientID))")
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
    
    func saveClientRecordToCloudKit(_ sourceRecord: Clients, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(clientID == \(sourceRecord.clientID)) AND \(buildTeamList(currentUser.userID))") // better be accurate to get only the record you need
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
                    record!.setValue(sourceRecord.clientName, forKey: "clientName")
                    record!.setValue(sourceRecord.clientContact, forKey: "clientContact")
                    record!.setValue(sourceRecord.note, forKey: "note")
                    
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
                    record.setValue(sourceRecord.clientName, forKey: "clientName")
                    record.setValue(sourceRecord.clientContact, forKey: "clientContact")
                    record.setValue(sourceRecord.note, forKey: "note")

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
    
    func updateClientRecord(_ sourceRecord: CKRecord)
    {
        let clientName = sourceRecord.object(forKey: "clientName") as! String
        let clientNote = sourceRecord.object(forKey: "note") as! String
        
        var clientContact: Int = 0
        if sourceRecord.object(forKey: "clientContact") != nil
        {
            clientContact = sourceRecord.object(forKey: "clientContact") as! Int
        }
        
        var clientID: Int = 0
        if sourceRecord.object(forKey: "clientID") != nil
        {
            clientID = sourceRecord.object(forKey: "clientID") as! Int
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
        
        myDatabaseConnection.recordsToChange += 1
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
    
        self.recordCount += 1
        myDatabaseConnection.saveClient(clientID,
                                         clientName: clientName,
                                         clientContact: clientContact,
                                         teamID: teamID,
                                         note: clientNote
            , updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
    
}

