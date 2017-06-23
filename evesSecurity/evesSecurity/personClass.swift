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

struct monthlyPersonFinancialsStruct
{
    var month: String
    var year: String
    var wage: Double
    var hours: Double
}

class people: NSObject
{
    var myPeople:[person] = Array()
    
    init(teamID: Int)
    {
        super.init()
        
        for myItem in myDatabaseConnection.getPeople(teamID: teamID)
        {
            let dob: Date = myItem.dob! as Date
            
            let myObject = person(personID: Int(myItem.personID),
                                  name: myItem.name!,
                                  dob: dob,
                                  teamID: Int(myItem.teamID),
                                  gender: myItem.gender!,
                                  note: myItem.note!,
                                  clientID: Int(myItem.clientID),
                                  projectID: Int(myItem.projectID),
                                  canRoster: myItem.canRoster!
                                   )
            myPeople.append(myObject)
        }
        sortArray()
    }
    
    init(teamID: Int, canRoster: Bool)
    {
        super.init()
        
        for myItem in myDatabaseConnection.getPeople(teamID: teamID, canRoster: canRoster)
        {
            let dob: Date = myItem.dob! as Date
            
            let myObject = person(personID: Int(myItem.personID),
                                  name: myItem.name!,
                                  dob: dob,
                                  teamID: Int(myItem.teamID),
                                  gender: myItem.gender!,
                                  note: myItem.note!,
                                  clientID: Int(myItem.clientID),
                                  projectID: Int(myItem.projectID),
                                  canRoster: myItem.canRoster!
            )
            myPeople.append(myObject)
        }
        sortArray()
    }
    
    init(clientID: Int)
    {
        super.init()
        
        for myItem in myDatabaseConnection.getPeopleForClient(clientID: clientID)
        {
            let dob: Date = myItem.dob! as Date
            
            let myObject = person(personID: Int(myItem.personID),
                                  name: myItem.name!,
                                  dob: dob,
                                  teamID: Int(myItem.teamID),
                                  gender: myItem.gender!,
                                  note: myItem.note!,
                                  clientID: Int(myItem.clientID),
                                  projectID: Int(myItem.projectID),
                                  canRoster: myItem.canRoster!
            )
            myPeople.append(myObject)
        }
        sortArray()
    }
    
    init(projectID: Int)
    {
        super.init()
        
        for myItem in myDatabaseConnection.getPeopleForProject(projectID: projectID)
        {
            let dob: Date = myItem.dob! as Date
            
            let myObject = person(personID: Int(myItem.personID),
                                  name: myItem.name!,
                                  dob: dob,
                                  teamID: Int(myItem.teamID),
                                  gender: myItem.gender!,
                                  note: myItem.note!,
                                  clientID: Int(myItem.clientID),
                                  projectID: Int(myItem.projectID),
                                  canRoster: myItem.canRoster!
            )
            myPeople.append(myObject)
        }
        sortArray()
    }
    
    func sortArray()
    {
        if myPeople.count > 0
        {
            myPeople.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.name == $1.name
                    {
                        return $0.dob < $1.dob
                    }
                    else
                    {
                        return $0.name < $1.name
                    }
            }
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
    fileprivate var myPersonID: Int = 0
    fileprivate var myClientID: Int = 0
    fileprivate var myProjectID: Int = 0
    fileprivate var myName: String = ""
    fileprivate var myGender: String = ""
    fileprivate var myNote: String = ""
    fileprivate var myDob: Date = getDefaultDate()
    fileprivate var myAddresses: personAddresses!
    fileprivate var myContacts: personContacts!
    fileprivate var myAddInfo: personAddInfoEntries!
    fileprivate var myTeamID: Int = 0
    fileprivate var myCanRoster: String = ""
    var tempArray: [Any] = Array()
    
    var personID: Int
    {
        get
        {
            return myPersonID
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
            myClientID = newValue
            save()
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
            myProjectID = newValue
            save()
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
    
    var gender: String
    {
        get
        {
            if myGender == ""
            {
                return "Select"
            }
            else
            {
                return myGender
            }
        }
        set
        {
            myGender = newValue
            save()
        }
    }
    
    var note: String
    {
        get
        {
            return myNote
        }
        set
        {
            myNote = newValue
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
    
    var contacts: [contactItem]
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
    
    var dobText: String
    {
        get
        {
            if myDob == getDefaultDate()
            {
                return "Select"
            }
            else
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                
                return dateFormatter.string(from: myDob)
            }
        }
    }
    
    var canRoster: String
    {
        get
        {
            return myCanRoster
        }
        set
        {
            myCanRoster = newValue
            save()
        }
    }
    
    init(teamID: Int)
    {
        super.init()
        
        myPersonID = myDatabaseConnection.getNextID("Person", teamID: teamID)
        myTeamID = teamID
        
        save()
    }
    
    init(personID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getPersonDetails(personID)
        
        for myItem in myReturn
        {
            myPersonID = Int(myItem.personID)
            myName = myItem.name!
            myDob = myItem.dob! as Date
            myTeamID = Int(myItem.teamID)
            myGender = myItem.gender!
            myNote = myItem.note!
            myClientID = Int(myItem.clientID)
            myProjectID = Int(myItem.projectID)
            myCanRoster = myItem.canRoster!
        }
    }
    
    init(personID: Int,
         name: String,
         dob: Date,
         teamID: Int,
         gender: String,
         note: String,
         clientID: Int,
         projectID: Int,
         canRoster: String
         )
    {
        super.init()
        
        myPersonID = personID
        myName = name
        myDob = dob
        myTeamID = teamID
        myGender = gender
        myNote = note
        myClientID = clientID
        myProjectID = projectID
        myCanRoster = canRoster
    }
    
    func save()
    {
        if currentUser.checkPermission(hrRoleType) == writePermission
        {
            myDatabaseConnection.savePerson(myPersonID,
                                             name: name,
                                             dob: dob,
                                             teamID: myTeamID,
                                             gender: myGender,
                                             note: myNote,
                                             clientID: myClientID,
                                             projectID: myProjectID,
                                             canRoster: myCanRoster
                                             )
        }
    }
    
    func delete()
    {
        if currentUser.checkPermission(hrRoleType) == writePermission
        {
            myDatabaseConnection.deletePerson(myPersonID)
        }
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
    func savePerson(_ personID: Int,
                    name: String,
                    dob: Date,
                    teamID: Int,
                    gender: String,
                    note: String,
                    clientID: Int,
                    projectID: Int,
                    canRoster: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Person!
        
        let myReturn = getPersonDetails(personID)
        
        if myReturn.count == 0
        { // Add
            myItem = Person(context: objectContext)
            myItem.personID = Int64(personID)
            myItem.name = name
            myItem.dob = dob as NSDate
            myItem.teamID = Int64(teamID)
            myItem.gender = gender
            myItem.note = note
            myItem.clientID = Int64(clientID)
            myItem.projectID = Int64(projectID)
            myItem.canRoster = canRoster
            
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
            myItem.gender = gender
            myItem.note = note
            myItem.clientID = Int64(clientID)
            myItem.projectID = Int64(projectID)
            myItem.canRoster = canRoster
            
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
    
    func deletePerson(_ personID: Int)
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
    
    func getPersonDetails(_ personID: Int)->[Person]
    {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(personID == \(personID))")
        
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
 
    func getPeople(teamID: Int)->[Person]
    {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") AND (teamID == \(teamID))")
        
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
    
    func getPeople(teamID: Int, canRoster: Bool)->[Person]
    {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        var predicate: NSPredicate!
        
        if canRoster
        {
            predicate = NSPredicate(format: "(updateType != \"Delete\") AND (teamID == \(teamID)) AND (canRoster == \"True\")")
        }
        else
        {
            predicate = NSPredicate(format: "(updateType != \"Delete\") AND (teamID == \(teamID))")
        }
        
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
    
    func getPeopleForClient(clientID: Int)->[Person]
    {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") AND (clientID == \(clientID))")
        
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
    
    func getPeopleForProject(projectID: Int)->[Person]
    {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") AND (projectID == \(projectID))")
        
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
    
    func quickFixPerson()
    {
        let fetchRequest2 = NSFetchRequest<Person>(entityName: "Person")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem in fetchResults2
            {
                myItem.canRoster = ""
                
                myItem.updateTime =  NSDate()
                if myItem.updateType != "Add"
                {
                    myItem.updateType = "Update"
                }
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
}

extension CloudKitInteraction
{
    func savePersonToCloudKit()
    {
        for myItem in myDatabaseConnection.getPersonForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Person"))
        {
            savePersonRecordToCloudKit(myItem)
        }
    }
    
    func updatePersonInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "Person") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Person", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)

        operation.recordFetchedBlock = { (record) in
            self.updatePersonRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Person", queryOperation: operation, onOperationQueue: operationQueue)
    }
    
//    func deletePerson(personID: Int)
//    {
//        let sem = DispatchSemaphore(value: 0);
//        
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (personID == \(personID)) ")
//        let query: CKQuery = CKQuery(recordType: "Person", predicate: predicate)
//        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
//            for record in results!
//            {
//                myRecordList.append(record.recordID)
//            }
//            self.performPublicDelete(myRecordList)
//            sem.signal()
//        })
//        
//        sem.wait()
//    }
    
    func savePersonRecordToCloudKit(_ sourceRecord: Person)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(personID == \(sourceRecord.personID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
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
                    record!.setValue(sourceRecord.gender, forKey: "gender")
                    record!.setValue(sourceRecord.note, forKey: "note")
                    record!.setValue(sourceRecord.clientID, forKey: "clientID")
                    record!.setValue(sourceRecord.projectID, forKey: "projectID")
                    record!.setValue(sourceRecord.canRoster, forKey: "canRoster")
                    
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
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "Person")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.dob, forKey: "dob")
                    record.setValue(sourceRecord.gender, forKey: "gender")
                    record.setValue(sourceRecord.note, forKey: "note")
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.canRoster, forKey: "canRoster")
                    
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
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
        let gender = sourceRecord.object(forKey: "gender") as! String
        let note = sourceRecord.object(forKey: "note") as! String
        let canRoster = sourceRecord.object(forKey: "canRoster") as! String

        var personID: Int = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int
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
        
        myDatabaseConnection.recordsToChange += 1
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
        
        self.recordCount += 1
        
        myDatabaseConnection.savePerson(personID,
                                         name: name,
                                         dob: dob, teamID: teamID,
                                         gender: gender,
                                         note: note,
                                         clientID: clientID,
                                         projectID: projectID,
                                         canRoster: canRoster
                                         , updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
}

