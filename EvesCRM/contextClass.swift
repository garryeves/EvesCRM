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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
                
                //               matchFound = true
                
                getContext1_1()
                
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
            
            getContext1_1()
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
        
        getContext1_1()
    }
    
    
    fileprivate func getContext1_1()
    {
        // Get context1_1
        
        let myNotes = myDatabaseConnection.getContext1_1(myContextID)
        
        if myNotes.count == 0
        {
            myPredecessor = 0
            myContextType = ""
        }
        else
        {
            for myItem in myNotes
            {
                myPredecessor = Int(myItem.predecessor)
                myContextType = myItem.contextType!
            }
        }
        
    }

    func save()
    {
        myDatabaseConnection.saveContext(myContextID, name: myName, email: myEmail, autoEmail: myAutoEmail, parentContext: myParentContext, status: myStatus, personID: myPersonID, teamID: myTeamID)
        
        myDatabaseConnection.saveContext1_1(myContextID, predecessor: myPredecessor, contextType: myContextType, teamID: myTeamID)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myContext = myDatabaseConnection.getContextDetails(myContextID)[0]
        
        myCloudDB.saveContextRecordToCloudKit(myContext, teamID: currentUser.currentTeam!.teamID)
        
        let myContext1_1 = myDatabaseConnection.getContext1_1(myContextID)[0]
        
        myCloudDB.saveContext1_1RecordToCloudKit(myContext1_1, teamID: currentUser.currentTeam!.teamID)
        
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
    func saveContext(_ contextID: Int, name: String, email: String, autoEmail: String, parentContext: Int, status: String, personID: Int, teamID: Int, updateTime: Date =  Date(), updateType: String = "CODE")
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
    
    func replaceContext(_ contextID: Int, name: String, email: String, autoEmail: String, parentContext: Int, status: String, personID: Int, teamID: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myContext = Context(context: objectContext)
        myContext.contextID = Int64(contextID)
        myContext.name = name
        myContext.email = email
        myContext.autoEmail = autoEmail
        myContext.parentContext = Int64(parentContext)
        myContext.status = status
        myContext.personID = Int64(personID)
        myContext.teamID = Int64(teamID)
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
        
        let myContexts2 = getContext1_1(contextID)
        
        if myContexts2.count > 0
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
    
    func getContextsForType(_ contextType: String)->[Context1_1]
    {
        let fetchRequest = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
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

        let fetchRequest24 = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
        // Set the predicate on the fetch request
        fetchRequest24.predicate = predicate
        do
        {
            let fetchResults24 = try objectContext.fetch(fetchRequest24)
            for myItem24 in fetchResults24
            {
                objectContext.delete(myItem24 as NSManagedObject)
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
        
        let fetchRequest24 = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        // Set the predicate on the fetch request
        fetchRequest24.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults24 = try objectContext.fetch(fetchRequest24)
            for myItem24 in fetchResults24
            {
                myItem24.updateType = ""
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
            updateDecodeValue("Context", codeValue: tempInt, codeType: "hidden", decode_privacy: "Public", teamID: currentUser.currentTeam!.teamID)
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func saveContext1_1(_ contextID: Int, predecessor: Int, contextType: String, teamID: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myContext: Context1_1!
        
        let myContexts = getContext1_1(contextID)
        
        if myContexts.count == 0
        { // Add
            myContext = Context1_1(context: objectContext)
            myContext.contextID = Int64(contextID)
            myContext.predecessor = Int64(predecessor)
            myContext.contextType = contextType
            myContext.teamID = Int64(teamID)
            
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
    
    func replaceContext1_1(_ contextID: Int, predecessor: Int, contextType: String, teamID: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myContext = Context1_1(context: objectContext)
        myContext.contextID = Int64(contextID)
        myContext.predecessor = Int64(predecessor)
        myContext.contextType = contextType
        myContext.teamID = Int64(teamID)
        
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
        
        saveContext()
    }
    
    func getContext1_1(_ contextID: Int)->[Context1_1]
    {
        let fetchRequest = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (contextID == \(contextID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "contextID", ascending: true)
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
    
    func getContexts1_1ForSync(_ syncDate: Date) -> [Context1_1]
    {
        let fetchRequest = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
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

        let fetchRequest24 = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
        do
        {
            let fetchResults24 = try objectContext.fetch(fetchRequest24)
            for myItem24 in fetchResults24
            {
                self.objectContext.delete(myItem24 as NSManagedObject)
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
        for myItem in myDatabaseConnection.getContextsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Context"))
        {
            saveContextRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
        
        for myItem in myDatabaseConnection.getContexts1_1ForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Context"))
        {
            saveContext1_1RecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }

    func updateContextInCoreData(teamID: Int)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(teamID))", myDatabaseConnection.getSyncDateForTable(tableName: "Context") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1

            self.updateContextRecord(record)
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

    func deleteContext(teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performPublicDelete(myRecordList)
            sem.signal()
        })
        
        sem.wait()
        
        var myRecordList2: [CKRecordID] = Array()
        let predicate2: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query2: CKQuery = CKQuery(recordType: "Context1_1", predicate: predicate2)
        publicDB.perform(query2, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList2.append(record.recordID)
            }
            self.performPublicDelete(myRecordList2)
            sem.signal()
        })
        sem.wait()
    }

    func replaceContextInCoreData(teamID: Int)
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        var predecessor: Int = 0
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let contextID = record.object(forKey: "contextID") as! Int
            let autoEmail = record.object(forKey: "autoEmail") as! String
            let email = record.object(forKey: "email") as! String
            let name = record.object(forKey: "name") as! String
            let parentContext = record.object(forKey: "parentContext") as! Int
            let personID = record.object(forKey: "personID") as! Int
            let status = record.object(forKey: "status") as! String
            let teamID = record.object(forKey: "teamID") as! Int
            let contextType = record.object(forKey: "contextType") as! String
            
            if record.object(forKey: "predecessor") != nil
            {
                predecessor = record.object(forKey: "predecessor") as! Int
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
            myDatabaseConnection.replaceContext(contextID, name: name, email: email, autoEmail: autoEmail, parentContext: parentContext, status: status, personID: personID, teamID: teamID, updateTime: updateTime, updateType: updateType)
            
            
            myDatabaseConnection.replaceContext1_1(contextID, predecessor: predecessor, contextType: contextType, teamID: teamID, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
            
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }
    
    func saveContextRecordToCloudKit(_ sourceRecord: Context, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)

        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID)) && (teamID == \(sourceRecord.teamID)) AND (teamID == \(teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Context", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                let tempContext1_1 = myDatabaseConnection.getContext1_1(Int(sourceRecord.contextID))
                
                var myPredecessor: Int = 0
                var myContextType: String = ""
                
                if tempContext1_1.count > 0
                {
                    myPredecessor = Int(tempContext1_1[0].predecessor)
                    if tempContext1_1[0].contextType != nil
                    {
                        myContextType = tempContext1_1[0].contextType!
                    }
                    else
                    {
                        myContextType = "Person"
                    }
                }
                
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
                    record!.setValue(myPredecessor, forKey: "predecessor")
                    record!.setValue(myContextType, forKey: "contextType")
                    record!.setValue(teamID, forKey: "teamID")
                    
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
                    record.setValue(myPredecessor, forKey: "predecessor")
                    record.setValue(myContextType, forKey: "contextType")
                    
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
    
    func saveContext1_1RecordToCloudKit(_ sourceRecord: Context1_1, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID)) AND (teamID == \(teamID))") // better be accurate to get only the record you need
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
                    record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record!.setValue(sourceRecord.contextType, forKey: "contextType")
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
                    let record = CKRecord(recordType: "Context")
                    record.setValue(sourceRecord.contextID, forKey: "contextID")
                    record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record.setValue(sourceRecord.contextType, forKey: "contextType")
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
        
        myDatabaseConnection.saveContext(contextID, name: name, email: email, autoEmail: autoEmail, parentContext: parentContext, status: status, personID: personID, teamID: teamID, updateTime: updateTime, updateType: updateType)
        
        myDatabaseConnection.saveContext1_1(contextID, predecessor: predecessor, contextType: contextType, teamID: teamID, updateTime: updateTime, updateType: updateType)
    }

}
