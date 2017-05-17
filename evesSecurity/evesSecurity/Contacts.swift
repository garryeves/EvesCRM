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

class personContacts: NSObject
{
    fileprivate var myContacts:[contact] = Array()
    
    init(personID: Int)
    {
        for myItem in myDatabaseConnection.getContactDetailsForPerson(personID)
        {
            let myObject = contact(personID: Int(myItem.personID),
                                   contactType: myItem.contactType!,
                                   contactValue: myItem.contactValue!,
                                   teamID: Int(myItem.teamID),
                                   clientID: Int(myItem.clientID),
                                   projectID: Int(myItem.projectID))
            myContacts.append(myObject)
        }
    }
    
    init(clientID: Int)
    {
        for myItem in myDatabaseConnection.getContactDetailsForClient(clientID)
        {
            let myObject = contact(personID: Int(myItem.personID),
                                   contactType: myItem.contactType!,
                                   contactValue: myItem.contactValue!,
                                   teamID: Int(myItem.teamID),
                                   clientID: Int(myItem.clientID),
                                   projectID: Int(myItem.projectID))
            myContacts.append(myObject)
        }
    }
    
    init(projectID: Int)
    {
        for myItem in myDatabaseConnection.getContactDetailsForProject(projectID)
        {
            let myObject = contact(personID: Int(myItem.personID),
                                   contactType: myItem.contactType!,
                                   contactValue: myItem.contactValue!,
                                   teamID: Int(myItem.teamID),
                                   clientID: Int(myItem.clientID),
                                   projectID: Int(myItem.projectID))
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
    fileprivate var myPersonID: Int = 0
    fileprivate var myContactType: String = ""
    fileprivate var myContactValue: String = ""
    fileprivate var myTeamID: Int = 0
    fileprivate var myClientID: Int = 0
    fileprivate var myProjectID: Int = 0
    
    var personID: Int
    {
        get
        {
            return myPersonID
        }
        set
        {
            return myPersonID = newValue
        }
    }
    
    var clientID: Int
    {
        get
        {
            return myClientID
        }
        set
        {
            return myClientID = newValue
        }
    }
    
    var projectID: Int
    {
        get
        {
            return myProjectID
        }
        set
        {
            return myProjectID = newValue
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
    
    init(teamID: Int)
    {
        super.init()
        
        myPersonID = myDatabaseConnection.getNextID("Contact")
        myTeamID = teamID
        
        save()
    }
    
    init(personID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getContactDetailsForPerson(personID)
        
        for myItem in myReturn
        {
            myPersonID = Int(myItem.personID)
            myContactType = myItem.contactType!
            myContactValue = myItem.contactValue!
            myTeamID = Int(myItem.teamID)
            myClientID = Int(myItem.clientID)
            myProjectID = Int(myItem.projectID)
        }
    }
    
    init(clientID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getContactDetailsForClient(clientID)
        
        for myItem in myReturn
        {
            myPersonID = Int(myItem.personID)
            myContactType = myItem.contactType!
            myContactValue = myItem.contactValue!
            myTeamID = Int(myItem.teamID)
            myClientID = Int(myItem.clientID)
            myProjectID = Int(myItem.projectID)
        }
    }
    
    init(projectID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getContactDetailsForProject(projectID)
        
        for myItem in myReturn
        {
            myPersonID = Int(myItem.personID)
            myContactType = myItem.contactType!
            myContactValue = myItem.contactValue!
            myTeamID = Int(myItem.teamID)
            myClientID = Int(myItem.clientID)
            myProjectID = Int(myItem.projectID)
        }
    }
    
    init(personID: Int,
         contactType: String,
         contactValue: String,
         teamID: Int,
         clientID: Int,
         projectID: Int)
    {
        super.init()
        
        myPersonID = personID
        myContactType = contactType
        myContactValue = contactValue
        myTeamID = teamID
        myClientID = clientID
        myProjectID = projectID
    }
    
    func save()
    {
        myDatabaseConnection.saveContact(myPersonID,
                                         contactType: myContactType,
                                         contactValue: myContactValue,
                                         teamID: myTeamID,
                                         clientID: myClientID,
                                         projectID: myProjectID)
    }
    
    func delete()
    {
        if myPersonID != 0
        {
            myDatabaseConnection.deleteContactForPerson(myPersonID, contactType: myContactType)
        }
        
        if myClientID != 0
        {
            myDatabaseConnection.deleteContactForClient(myClientID, contactType: myContactType)
        }
        
        if myProjectID != 0
        {
            myDatabaseConnection.deleteContactForProject(myProjectID, contactType: myContactType)
        }

    }
}

extension coreDatabase
{
    func saveContact(_ personID: Int,
                     contactType: String,
                     contactValue: String,
                     teamID: Int,
                     clientID: Int,
                     projectID: Int,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Contacts!
        
        var myReturn: [Contacts]!
        
        if personID != 0
        {
            myReturn = getContactDetailsForPerson(personID, contactType: contactType)
        }
        else if clientID != 0
        {
            myReturn = getContactDetailsForClient(clientID, contactType: contactType)
        }
        else if projectID != 0
        {
            myReturn = getContactDetailsForProject(projectID, contactType: contactType)
        }

        if myReturn.count == 0
        { // Add
            myItem = Contacts(context: objectContext)
            myItem.personID = Int64(personID)
            myItem.contactType = contactType
            myItem.contactValue = contactValue
            myItem.teamID = Int64(teamID)
            myItem.clientID = Int64(clientID)
            myItem.projectID = Int64(projectID)
            
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
            myItem.clientID = Int64(clientID)
            myItem.projectID = Int64(projectID)
            myItem.personID = Int64(personID)
            
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
    
    func replaceContact(_ personID: Int,
                        contactType: String,
                        contactValue: String,
                        teamID: Int,
                        clientID: Int,
                        projectID: Int,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = Contacts(context: objectContext)
        myItem.personID = Int64(personID)
        myItem.contactType = contactType
        myItem.contactValue = contactValue
        myItem.teamID = Int64(teamID)
        myItem.clientID = Int64(clientID)
        myItem.projectID = Int64(projectID)
        
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
    
    func deleteContactForPerson(_ personID: Int, contactType: String)
    {
        let myReturn = getContactDetailsForPerson(personID, contactType: contactType)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }

    func deleteContactForClient(_ clientID: Int, contactType: String)
    {
        let myReturn = getContactDetailsForClient(clientID, contactType: contactType)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }

    func deleteContactForProject(_ projectID: Int, contactType: String)
    {
        let myReturn = getContactDetailsForProject(projectID, contactType: contactType)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }

    func getContactDetailsForPerson(_ personID: Int, contactType: String)->[Contacts]
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
    
    func getContactDetailsForClient(_ clientID: Int, contactType: String)->[Contacts]
    {
        let fetchRequest = NSFetchRequest<Contacts>(entityName: "Contacts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(clientID == \(clientID)) && (contactType = \"\(contactType)\") AND (updateType != \"Delete\")")
        
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
    
    func getContactDetailsForProject(_ projectID: Int, contactType: String)->[Contacts]
    {
        let fetchRequest = NSFetchRequest<Contacts>(entityName: "Contacts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) && (contactType = \"\(contactType)\") AND (updateType != \"Delete\")")
        
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

    func getContactDetailsForPerson(_ personID: Int)->[Contacts]
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
    
    func getContactDetailsForClient(_ clientID: Int)->[Contacts]
    {
        let fetchRequest = NSFetchRequest<Contacts>(entityName: "Contacts")
        
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
    
    func getContactDetailsForProject(_ projectID: Int)->[Contacts]
    {
        let fetchRequest = NSFetchRequest<Contacts>(entityName: "Contacts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) && (updateType != \"Delete\")")
        
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
            saveContactRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateContactInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "Contacts") as CVarArg)
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
    
    func deleteContact(personID: Int, clientID: Int, projectID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (personID == \(personID)) AND (clientID == \(clientID)) AND (projectID == \(projectID))")
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
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "Contacts", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let contactType = record.object(forKey: "contactType") as! String
            let contactValue = record.object(forKey: "contactValue") as! String
            
            var personID: Int = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int
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
            
            var teamID: Int = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int
            }
            
            var clientID: Int = 0
            if record.object(forKey: "clientID") != nil
            {
                clientID = record.object(forKey: "clientID") as! Int
            }
            
            var projectID: Int = 0
            if record.object(forKey: "projectID") != nil
            {
                projectID = record.object(forKey: "projectID") as! Int
            }
            
            myDatabaseConnection.replaceContact(personID,
                                                contactType: contactType,
                                                contactValue: contactValue,
                                                teamID: teamID,
                                                clientID: clientID,
                                                projectID:  projectID
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
    
    func saveContactRecordToCloudKit(_ sourceRecord: Contacts, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(personID == \(sourceRecord.personID)) AND (clientID == \(sourceRecord.clientID)) AND (projectID == \(sourceRecord.projectID)) AND \(buildTeamList(currentUser.userID))") // better be accurate to get only the record you need
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
                    record!.setValue(sourceRecord.clientID, forKey: "clientID")
                    record!.setValue(sourceRecord.projectID, forKey: "projectID")
                    
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
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
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
    
    func updateContactRecord(_ sourceRecord: CKRecord)
    {
        let contactType = sourceRecord.object(forKey: "contactType") as! String
        let contactValue = sourceRecord.object(forKey: "contactValue") as! String
        
        var personID: Int = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int
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
        
        var clientID: Int = 0
        if sourceRecord.object(forKey: "clientID") != nil
        {
            clientID = sourceRecord.object(forKey: "clientID") as! Int
        }
        
        var projectID: Int = 0
        if sourceRecord.object(forKey: "projectID") != nil
        {
            projectID = sourceRecord.object(forKey: "projectID") as! Int
        }
        
        myDatabaseConnection.saveContact(personID,
                                         contactType: contactType,
                                         contactValue: contactValue,
                                         teamID: teamID,
                                         clientID: clientID,
                                         projectID: projectID
            , updateTime: updateTime, updateType: updateType)
    }
}
