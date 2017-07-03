//
//  contextClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class contexts: NSObject
{
    fileprivate var myContexts:[context] = Array()
    fileprivate var myPeopleContexts:[context] = Array()
    fileprivate var myPlaceContexts:[context] = Array()
    fileprivate var myToolContexts:[context] = Array()
    
    override init()
    {
        for myItem in myDatabaseConnection.getContextsForType("Person")
        {
            let myItemDetails = myDatabaseConnection.getContextDetails(Int(myItem.contextID))
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: Int(myItem.contextID))
                myPeopleContexts.append(myContext)
                myContexts.append(myContext)
            }
        }
        
        myPeopleContexts.sort { $0.name < $1.name }
        
        for myItem in myDatabaseConnection.getContextsForType("Place")
        {
            let myItemDetails = myDatabaseConnection.getContextDetails(Int(myItem.contextID))
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: Int(myItem.contextID))
                myPlaceContexts.append(myContext)
                myContexts.append(myContext)
            }
        }
        
        myPlaceContexts.sort { $0.name < $1.name }
        
        for myItem in myDatabaseConnection.getContextsForType("Tool")
        {
            let myItemDetails = myDatabaseConnection.getContextDetails(Int(myItem.contextID))
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: Int(myItem.contextID))
                myToolContexts.append(myContext)
                myContexts.append(myContext)
            }
        }
        
        myToolContexts.sort { $0.name < $1.name }
        
        myContexts.sort { $0.name < $1.name }
    }
    
    
    var allContexts: [context]
    {
        get
        {
            return myContexts
        }
    }
    
    var people: [context]
    {
        get
        {
            return myPeopleContexts
        }
    }
    
    
    var places: [context]
    {
        get
        {
            return myPlaceContexts
        }
    }
    
    
    var tools: [context]
    {
        get
        {
            return myToolContexts
        }
    }
}

class context: NSObject
{
    fileprivate var myContextID: Int = 0
    fileprivate var myName: String = "New context"
    fileprivate var myEmail: String = ""
    fileprivate var myAutoEmail: String = ""
    fileprivate var myParentContext: Int = 0
    fileprivate var myStatus: String = ""
    fileprivate var myPersonID: Int = 0
    fileprivate var myTeamID: Int = 0
    fileprivate var myPredecessor: Int = 0
    fileprivate var myContextType: String = ""
    fileprivate var saveCalled: Bool = false
    
    var contextID: Int
    {
        get
        {
            return myContextID
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
        }
    }
    
    var contextType: String
    {
        get
        {
            return myContextType
        }
        set
        {
            myContextType = newValue
        }
    }
    
    var email: String
    {
        get
        {
            return myEmail
        }
        set
        {
            myEmail = newValue
        }
    }
    
    var autoEmail: String
    {
        get
        {
            return myAutoEmail
        }
        set
        {
            myAutoEmail = newValue
        }
    }
    
    var parentContext: Int
    {
        get
        {
            return myParentContext
        }
        set
        {
            myParentContext = newValue
        }
    }
    
    var status: String
    {
        get
        {
            return myStatus
        }
        set
        {
            myStatus = newValue
        }
    }
    
    var allTasks: [TaskContext]
    {
        get
        {
            return myDatabaseConnection.getTasksForContext(myContextID)
        }
    }
    
    var contextHierarchy: String
    {
        get
        {
            var retString: String = ""
            
            if myParentContext == 0
            {
                retString = myName
            }
            else
            { // Navigate to parent
                let theParent = context(contextID: myParentContext)
                retString = "\(theParent.contextHierarchy) - \(myName)"
            }
            
            return retString
        }
    }
    
    var personID: Int
    {
        get
        {
            return myPersonID
        }
        set
        {
            myPersonID = newValue
        }
    }
    
    var teamID: Int
    {
        get
        {
            return myTeamID
        }
        set
        {
            myTeamID = newValue
        }
    }
    
    var predecessor: Int
    {
        get
        {
            return myPredecessor
        }
        set
        {
            myPredecessor = newValue
        }
    }
    
    func removeWhitespace(_ string: String) -> String {
        let components = string.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter({!$0.characters.isEmpty})
        return components.joined(separator: " ")
    }
    
    
    init(teamID: Int)
    {
        super.init()
        
        myContextID = myDatabaseConnection.getNextID("Context", teamID: teamID)
        myTeamID = teamID
        
        save()
    }
    
    init(contextName: String)
    {
        super.init()
        //       var matchFound: Bool = false
        
        let myContextList = contexts()
        
        // String of any unneeded whilespace
        
        let strippedContext = removeWhitespace(contextName)
        
        for myContext in myContextList.allContexts
        {
            if myContext.name.lowercased() == strippedContext.lowercased()
            {
                // Existing context found, so use this record
                
                myContextID = myContext.contextID
                myName = myContext.name
                myEmail = myContext.email
                myAutoEmail = myContext.autoEmail
                myParentContext = myContext.parentContext
                myStatus = myContext.status
                myPersonID = myContext.personID
                myTeamID = myContext.teamID
                myContextType = myContext.contextType
                myPredecessor = Int(myContext.predecessor)
                myContextType = myContext.contextType
                
                break
            }
        }
    }
    
    init(contextID: Int)
    {
        super.init()
        let myContexts = myDatabaseConnection.getContextDetails(contextID)
        
        for myContext in myContexts
        {
            myContextID = Int(myContext.contextID)
            myName = myContext.name!
            myEmail = myContext.email!
            myAutoEmail = myContext.autoEmail!
            myParentContext = Int(myContext.parentContext)
            myStatus = myContext.status!
            myPersonID = Int(myContext.personID)
            myTeamID = Int(myContext.teamID)
            myPredecessor = Int(myContext.predecessor)
            myContextType = myContext.contextType!
        }
    }
    
    init(sourceContext: Context)
    {
        super.init()
        myContextID = Int(sourceContext.contextID)
        myName = sourceContext.name!
        myEmail = sourceContext.email!
        myAutoEmail = sourceContext.autoEmail!
        myParentContext = Int(sourceContext.parentContext)
        myStatus = sourceContext.status!
        myPersonID = Int(sourceContext.personID)
        myTeamID = Int(sourceContext.teamID)
        myPredecessor = Int(sourceContext.predecessor)
        myContextType = sourceContext.contextType!
    }
    
    func save()
    {
        myDatabaseConnection.saveContext(myContextID, name: myName, email: myEmail, autoEmail: myAutoEmail, parentContext: myParentContext, status: myStatus, personID: myPersonID, predecessor: myPredecessor, contextType: myContextType, teamID: myTeamID)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myContext = myDatabaseConnection.getContextDetails(myContextID)[0]
        
        myCloudDB.saveContextRecordToCloudKit(myContext)
        
        saveCalled = false
    }
    
    func delete() -> Bool
    {
        if allTasks.count > 0
        {
            return false
        }
        else
        {
            //myDatabaseConnection.deleteContext(myContextID, teamID: myTeamID)
            myStatus = "Deleted"
            save()
            return true
        }
    }
}

extension coreDatabase
{
    func saveContext(_ contextID: Int, name: String, email: String, autoEmail: String, parentContext: Int, status: String, personID: Int, predecessor: Int, contextType: String, teamID: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myContext: Context!
        
        let myContexts = getContextDetails(contextID)
        
        if myContexts.count == 0
        { // Add
            myContext = Context(context: objectContext)
            myContext.contextID = Int64(contextID)
            myContext.name = name
            myContext.email = email
            myContext.autoEmail = autoEmail
            myContext.parentContext = Int64(parentContext)
            myContext.status = status
            myContext.personID = Int64(personID)
            myContext.teamID = Int64(teamID)
            myContext.predecessor = Int64(predecessor)
            myContext.contextType = contextType
            
            if updateType == "CODE"
            {
                myContext.updateTime =  NSDate()
                
                myContext.updateType = "Add"
            }
            else
            {
                myContext.updateTime = updateTime as NSDate
                myContext.updateType = updateType
            }
        }
        else
        {
            myContext = myContexts[0]
            myContext.name = name
            myContext.email = email
            myContext.autoEmail = autoEmail
            myContext.parentContext = Int64(parentContext)
            myContext.status = status
            myContext.personID = Int64(personID)
            myContext.teamID = Int64(teamID)
            myContext.predecessor = Int64(predecessor)
            myContext.contextType = contextType
            
            if updateType == "CODE"
            {
                myContext.updateTime =  NSDate()
                if myContext.updateType != "Add"
                {
                    myContext.updateType = "Update"
                }
            }
            else
            {
                myContext.updateTime = updateTime as NSDate
                myContext.updateType = updateType
            }
        }
        
        saveContext()
    }
    
    func deleteContext(_ contextID: Int, teamID: Int)
    {
        let myContexts = getContextDetails(contextID)
        
        if myContexts.count > 0
        {
            let myContext = myContexts[0]
            myContext.updateTime =  NSDate()
            myContext.updateType = "Delete"
        }
        
        saveContext()

    }
    
    func getContexts(_ teamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(status != \"Archived\") && (updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
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
    
    func getContextsForType(_ contextType: String)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextType == \"\(contextType)\") && (updateType != \"Delete\")")
        
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
    
    func getContextByName(_ contextName: String, teamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(name = \"\(contextName)\") AND (teamID = \(teamID)) && (updateType != \"Delete\") && (status != \"Deleted\")")
        
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
    
    func getContextDetails(_ contextID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID == \(contextID)) && (updateType != \"Delete\") && (status != \"Deleted\")")
        
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
    
    func getAllContexts(_ teamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
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
    
    func objectContextCount()->Int
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults.count
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }

    func resetAllContexts()
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
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
    
    func clearDeletedContexts(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Context>(entityName: "Context")
        
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
    
    func clearSyncedContexts(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Context>(entityName: "Context")
        
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
    
    func initialiseTeamForContext(_ teamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        let sortDescriptor = NSSortDescriptor(key: "contextID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            {
                for myItem in fetchResults
                {
                    myItem.teamID = Int64(teamID)
                    maxID = Int(myItem.contextID)
                }
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Context", codeValue: tempInt, codeType: "hidden", decode_privacy: "Public", teamID: teamID)
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getContextsForSync(_ syncDate: Date) -> [Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
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
    
    func deleteAllContexts()
    {
        let fetchRequest2 = NSFetchRequest<Context>(entityName: "Context")
        
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
    
    func resetContexts()
    {
        resetAllContexts()
        
        resetTaskContextRecords()
    }
}

extension CloudKitInteraction
{
    func saveContextToCloudKit()
    {
        for myItem in myDatabaseConnection.getContextsForSync(getSyncDateForTable(tableName: "Context"))
        {
            saveContextRecordToCloudKit(myItem)
        }
    }

    func updateContextInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "Context") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateContextRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Context", queryOperation: operation, onOperationQueue: operationQueue)
    }

//    func deleteContext(teamID: Int)
//    {
//        let sem = DispatchSemaphore(value: 0);
//
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
//        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
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
    
    func saveContextRecordToCloudKit(_ sourceRecord: Context)
    {
        let sem = DispatchSemaphore(value: 0)

        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Context", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.autoEmail, forKey: "autoEmail")
                    record!.setValue(sourceRecord.email, forKey: "email")
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.parentContext, forKey: "parentContext")
                    record!.setValue(sourceRecord.personID, forKey: "personID")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record!.setValue(sourceRecord.contextType, forKey: "contextType")
                    record!.setValue(sourceRecord.teamID, forKey: "teamID")
                    
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
                    let record = CKRecord(recordType: "Context")
                    record.setValue(sourceRecord.contextID, forKey: "contextID")
                    record.setValue(sourceRecord.autoEmail, forKey: "autoEmail")
                    record.setValue(sourceRecord.email, forKey: "email")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.parentContext, forKey: "parentContext")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.status, forKey: "status")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record.setValue(sourceRecord.contextType, forKey: "contextType")
                    
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
    
    func updateContextRecord(_ sourceRecord: CKRecord)
    {
        var predecessor: Int = 0
        
        let contextID = sourceRecord.object(forKey: "contextID") as! Int
        let autoEmail = sourceRecord.object(forKey: "autoEmail") as! String
        let email = sourceRecord.object(forKey: "email") as! String
        let name = sourceRecord.object(forKey: "name") as! String
        let parentContext = sourceRecord.object(forKey: "parentContext") as! Int
        let personID = sourceRecord.object(forKey: "personID") as! Int
        let status = sourceRecord.object(forKey: "status") as! String
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        let contextType = sourceRecord.object(forKey: "contextType") as! String
        
        if sourceRecord.object(forKey: "predecessor") != nil
        {
            predecessor = sourceRecord.object(forKey: "predecessor") as! Int
        }
        
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
        
        myDatabaseConnection.recordsToChange += 1
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
        
        self.recordCount += 1
        
        myDatabaseConnection.saveContext(contextID, name: name, email: email, autoEmail: autoEmail, parentContext: parentContext, status: status, personID: personID, predecessor: predecessor, contextType: contextType, teamID: teamID, updateTime: updateTime, updateType: updateType)
        
        self.recordCount -= 1
    }
}
