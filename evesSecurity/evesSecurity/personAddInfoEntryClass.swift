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
    
    init(personID: Int)
    {
        for myItem in myDatabaseConnection.getPersonAddInfoEntryForPerson(personID)
        {
            let myObject = personAddInfoEntry(addInfoName: myItem.addInfoName!,
                                              dateValue: myItem.dateValue! as Date,
                                              personID: Int(myItem.personID),
                                              stringValue: myItem.stringValue!,
                                              teamID: Int(myItem.teamID)
                                   )
            myPersonAddEntries.append(myObject)
        }
    }
    
    init(addInfoName: String)
    {
        for myItem in myDatabaseConnection.getPersonAddInfoEntryList(addInfoName)
        {
            let myObject = personAddInfoEntry(addInfoName: myItem.addInfoName!,
                                              dateValue: myItem.dateValue! as Date,
                                              personID: Int(myItem.personID),
                                              stringValue: myItem.stringValue!,
                                              teamID: Int(myItem.teamID)
            )
            myPersonAddEntries.append(myObject)
        }
    }
    
    init(addInfoName: String, searchString: String)
    {
        for myItem in myDatabaseConnection.getPersonAddInfoEntryList(addInfoName, searchString: searchString)
        {
            let myObject = personAddInfoEntry(addInfoName: myItem.addInfoName!,
                                              dateValue: myItem.dateValue! as Date,
                                              personID: Int(myItem.personID),
                                              stringValue: myItem.stringValue!,
                                              teamID: Int(myItem.teamID)
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
    fileprivate var myPersonID: Int = 0
    fileprivate var myStringValue: String = ""
    fileprivate var myTeamID: Int = 0
    
    var addInfoName: String
    {
        get
        {
            return myAddInfoName
        }
    }
    
    var personID: Int
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
        }
    }
    
    var dateString: String
    {
        get
        {
            if myDateValue == getDefaultDate()
            {
               return "Select"
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = .short
                return myDateFormatter.string(from: myDateValue)
            }
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
        }
    }
    
    init(addInfoName: String, personID: Int, teamID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getPersonAddInfoEntryDetails(addInfoName, personID: personID)
        myTeamID = teamID
        myPersonID = personID
        myAddInfoName = addInfoName
        
        for myItem in myReturn
        {
            myAddInfoName = myItem.addInfoName!
            myDateValue = myItem.dateValue! as Date
            myPersonID = Int(myItem.personID)
            myStringValue = myItem.stringValue!
            myTeamID = Int(myItem.teamID)
        }
    }
    
    init(addInfoName: String,
         dateValue: Date,
         personID: Int,
         stringValue: String,
         teamID: Int
         )
    {
        super.init()
        
        myAddInfoName = addInfoName
        myDateValue = dateValue
        myPersonID = personID
        myStringValue = stringValue
        myTeamID = teamID
    }
    
    func save()
    {
        if currentUser.checkPermission("HR") == writePermission
        {
            myDatabaseConnection.savePersonAddInfoEntry(myAddInfoName,
                                                        dateValue: myDateValue,
                                                        personID: myPersonID,
                                                        stringValue: myStringValue,
                                                        teamID: myTeamID
                                             )
        }
    }
    
    func delete()
    {
        if currentUser.checkPermission("HR") == writePermission
        {
            myDatabaseConnection.deletePersonAddInfoEntry(addInfoName,
                                                      personID: personID)
        }
    }
}

extension coreDatabase
{
    func savePersonAddInfoEntry(_ addInfoName: String,
                                dateValue: Date,
                                personID: Int,
                                stringValue: String,
                                teamID: Int,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: PersonAddInfoEntry!
        
        let myReturn = getPersonAddInfoEntryDetails(addInfoName, personID: personID)
        
        if myReturn.count == 0
        { // Add
            myItem = PersonAddInfoEntry(context: objectContext)
            myItem.addInfoName = addInfoName
            myItem.dateValue = dateValue as NSDate
            myItem.personID = Int64(personID)
            myItem.stringValue = stringValue
            myItem.teamID = Int64(teamID)
            
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

        self.recordsProcessed += 1
    }
        
    func deletePersonAddInfoEntry(_ addInfoName: String,
                                  personID: Int)
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
    
    func getPersonAddInfoEntryList(_ addInfoName: String, searchString: String = "")->[PersonAddInfoEntry]
    {
        let fetchRequest = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate!
        
        if searchString == ""
        {
            predicate = NSPredicate(format: "(addInfoName == \"\(addInfoName)\") AND (teamID == \(currentUser.currentTeam!.teamID)) AND (updateType != \"Delete\")")
        }
        else
        {
            predicate = NSPredicate(format: "(addInfoName == \"\(addInfoName)\") AND (stringValue == \"\(searchString)\") AND (teamID == \(currentUser.currentTeam!.teamID)) AND (updateType != \"Delete\")")
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

    func getPersonAddInfoEntryForPerson(_ personID: Int)->[PersonAddInfoEntry]
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
    func getPersonAddInfoEntryDetails(_ addInfoName: String, personID: Int)->[PersonAddInfoEntry]
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
        let fetchRequest = NSFetchRequest<PersonAddInfoEntry>(entityName: "PersonAddInfoEntry")
        
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
            savePersonAddInfoEntryRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updatePersonAddInfoEntryInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "PersonAddInfoEntry") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updatePersonAddInfoEntryRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "PersonAddInfoEntry", queryOperation: operation, onOperationQueue: operationQueue)
    }
    
    func deletePersonAddInfoEntry(personID: Int, addInfoName: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (personID == \(personID)) AND (addInfoName == \"\(addInfoName)\") ")
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
    
    func savePersonAddInfoEntryRecordToCloudKit(_ sourceRecord: PersonAddInfoEntry, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(addInfoName == \"\(sourceRecord.addInfoName!)\") AND (personID == \(sourceRecord.personID)) AND \(buildTeamList(currentUser.userID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "PersonAddInfoEntry", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records:  GRE D - \(error!.localizedDescription)")
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
                            NSLog("Error saving record:  GRE E - \(saveError!.localizedDescription)")
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
                    let record = CKRecord(recordType: "PersonAddInfoEntry")
                    record.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record.setValue(sourceRecord.stringValue, forKey: "stringValue")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.dateValue, forKey: "dateValue")
                    
                    record.setValue(teamID, forKey: "teamID")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record:  GRE F - \(saveError!.localizedDescription)")
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
    
    func updatePersonAddInfoEntryRecord(_ sourceRecord: CKRecord)
    {
        let addInfoName = sourceRecord.object(forKey: "addInfoName") as! String
        let stringValue = sourceRecord.object(forKey: "stringValue") as! String
        
        var personID: Int = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int
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
        
        myDatabaseConnection.savePersonAddInfoEntry(addInfoName,
                                         dateValue: dateValue,
                                         personID: personID,
                                         stringValue: stringValue,
                                         teamID: teamID
                                         , updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
    
}

