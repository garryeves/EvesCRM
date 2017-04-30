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
            let myItemDetails = myDatabaseConnection.getContextDetails(myItem.contextID)
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: myItem.contextID)
                myPeopleContexts.append(myContext)
                myContexts.append(myContext)
            }
        }
        
        myPeopleContexts.sort { $0.name < $1.name }
        
        for myItem in myDatabaseConnection.getContextsForType("Place")
        {
            let myItemDetails = myDatabaseConnection.getContextDetails(myItem.contextID)
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: myItem.contextID)
                myPlaceContexts.append(myContext)
                myContexts.append(myContext)
            }
        }
        
        myPlaceContexts.sort { $0.name < $1.name }
        
        for myItem in myDatabaseConnection.getContextsForType("Tool")
        {
            let myItemDetails = myDatabaseConnection.getContextDetails(myItem.contextID)
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: myItem.contextID)
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
    fileprivate var myContextID: Int32 = 0
    fileprivate var myName: String = "New context"
    fileprivate var myEmail: String = ""
    fileprivate var myAutoEmail: String = ""
    fileprivate var myParentContext: Int32 = 0
    fileprivate var myStatus: String = ""
    fileprivate var myPersonID: Int32 = 0
    fileprivate var myTeamID: Int32 = 0
    fileprivate var myPredecessor: Int32 = 0
    fileprivate var myContextType: String = ""
    fileprivate var saveCalled: Bool = false
    
    var contextID: Int32
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
    
    var parentContext: Int32
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
    
    var teamID: Int32
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
    
    var predecessor: Int32
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
    
    
    init(teamID: Int32)
    {
        super.init()
        
        myContextID = myDatabaseConnection.getNextID("Context")
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
    
    init(contextID: Int32)
    {
        super.init()
        let myContexts = myDatabaseConnection.getContextDetails(contextID)
        
        for myContext in myContexts
        {
            myContextID = myContext.contextID
            myName = myContext.name!
            myEmail = myContext.email!
            myAutoEmail = myContext.autoEmail!
            myParentContext = myContext.parentContext
            myStatus = myContext.status!
            myPersonID = myContext.personID
            myTeamID = myContext.teamID
            
            getContext1_1()
        }
    }
    
    init(sourceContext: Context)
    {
        super.init()
        myContextID = sourceContext.contextID
        myName = sourceContext.name!
        myEmail = sourceContext.email!
        myAutoEmail = sourceContext.autoEmail!
        myParentContext = sourceContext.parentContext
        myStatus = sourceContext.status!
        myPersonID = sourceContext.personID
        myTeamID = sourceContext.teamID
        
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
                myPredecessor = myItem.predecessor
                myContextType = myItem.contextType!
            }
        }
        
    }

    func save()
    {
        myDatabaseConnection.saveContext(myContextID, name: myName, email: myEmail, autoEmail: myAutoEmail, parentContext: myParentContext, status: myStatus, personID: myPersonID, teamID: myTeamID)
        
        myDatabaseConnection.saveContext1_1(myContextID, predecessor: myPredecessor, contextType: myContextType)
        
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
        
        let myContext1_1 = myDatabaseConnection.getContext1_1(myContextID)[0]
        
        myCloudDB.saveContext1_1RecordToCloudKit(myContext1_1)
        
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
    func saveContext(_ contextID: Int32, name: String, email: String, autoEmail: String, parentContext: Int32, status: String, personID: Int32, teamID: Int32, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myContext: Context!
        
        let myContexts = getContextDetails(contextID)
        
        if myContexts.count == 0
        { // Add
            myContext = Context(context: objectContext)
            myContext.contextID = contextID
            myContext.name = name
            myContext.email = email
            myContext.autoEmail = autoEmail
            myContext.parentContext = parentContext
            myContext.status = status
            myContext.personID = personID
            myContext.teamID = teamID
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
            myContext.parentContext = parentContext
            myContext.status = status
            myContext.personID = personID
            myContext.teamID = teamID
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
    
    func replaceContext(_ contextID: Int32, name: String, email: String, autoEmail: String, parentContext: Int32, status: String, personID: Int32, teamID: Int32, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myContext = Context(context: objectContext)
        myContext.contextID = contextID
        myContext.name = name
        myContext.email = email
        myContext.autoEmail = autoEmail
        myContext.parentContext = parentContext
        myContext.status = status
        myContext.personID = personID
        myContext.teamID = teamID
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
    
    func deleteContext(_ contextID: Int32, teamID: Int32)
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
    
    func getContexts(_ teamID: Int32)->[Context]
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
    
    func getContextByName(_ contextName: String)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(name = \"\(contextName)\") && (updateType != \"Delete\") && (status != \"Deleted\")")
        
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
    
    func getContextDetails(_ contextID: Int32)->[Context]
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
    
    func getAllContexts(_ teamID: Int32)->[Context]
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
    
    func initialiseTeamForContext(_ teamID: Int32)
    {
        var maxID: Int32 = 1
        
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
                    myItem.teamID = teamID
                    maxID = myItem.contextID
                }
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Context", codeValue: tempInt, codeType: "hidden")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func saveContext1_1(_ contextID: Int32, predecessor: Int32, contextType: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myContext: Context1_1!
        
        let myContexts = getContext1_1(contextID)
        
        if myContexts.count == 0
        { // Add
            myContext = Context1_1(context: objectContext)
            myContext.contextID = contextID
            myContext.predecessor = predecessor
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
            myContext.predecessor = predecessor
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
    
    func replaceContext1_1(_ contextID: Int32, predecessor: Int32, contextType: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myContext = Context1_1(context: objectContext)
        myContext.contextID = contextID
        myContext.predecessor = predecessor
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
        
        saveContext()
    }
    
    func getContext1_1(_ contextID: Int32)->[Context1_1]
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
            saveContextRecordToCloudKit(myItem)
        }
        
        for myItem in myDatabaseConnection.getContexts1_1ForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Context"))
        {
            saveContext1_1RecordToCloudKit(myItem)
        }
    }

    func updateContextInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", myDatabaseConnection.getSyncDateForTable(tableName: "Context") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateContextRecord(record)
                usleep(100)
            }
            sem.signal()
        })
        sem.wait()
    }

    func deleteContext()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            sem.signal()
        })
        
        sem.wait()
        
        var myRecordList2: [CKRecordID] = Array()
        let predicate2: NSPredicate = NSPredicate(value: true)
        let query2: CKQuery = CKQuery(recordType: "Context1_1", predicate: predicate2)
        privateDB.perform(query2, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList2.append(record.recordID)
            }
            self.performDelete(myRecordList2)
            sem.signal()
        })
        sem.wait()
    }

    func replaceContextInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        var predecessor: Int32 = 0
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let contextID = record.object(forKey: "contextID") as! Int32
                let autoEmail = record.object(forKey: "autoEmail") as! String
                let email = record.object(forKey: "email") as! String
                let name = record.object(forKey: "name") as! String
                let parentContext = record.object(forKey: "parentContext") as! Int32
                let personID = record.object(forKey: "personID") as! Int32
                let status = record.object(forKey: "status") as! String
                let teamID = record.object(forKey: "teamID") as! Int32
                let contextType = record.object(forKey: "contextType") as! String
                
                
                if record.object(forKey: "predecessor") != nil
                {
                    predecessor = record.object(forKey: "predecessor") as! Int32
                }
                var updateTime = Date()
                if record.object(forKey: "updateTime") != nil
                {
                    updateTime = record.object(forKey: "updateTime") as! Date
                }
                let updateType = record.object(forKey: "updateType") as! String
                
                myDatabaseConnection.replaceContext(contextID, name: name, email: email, autoEmail: autoEmail, parentContext: parentContext, status: status, personID: personID, teamID: teamID, updateTime: updateTime, updateType: updateType)
                
                
                myDatabaseConnection.replaceContext1_1(contextID, predecessor: predecessor, contextType: contextType, updateTime: updateTime, updateType: updateType)
                usleep(100)
            }
            sem.signal()
        })
        sem.wait()
    }
    
    func saveContextRecordToCloudKit(_ sourceRecord: Context)
    {
        let sem = DispatchSemaphore(value: 0)

        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID)) && (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Context", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                let tempContext1_1 = myDatabaseConnection.getContext1_1(sourceRecord.contextID)
                
                var myPredecessor: Int32 = 0
                var myContextType: String = ""
                
                if tempContext1_1.count > 0
                {
                    myPredecessor = tempContext1_1[0].predecessor
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
                    
                    // Save this record again
                    self.privateDB.save(record!, completionHandler: { (savedRecord, saveError) in
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
                    
                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
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
    
    func saveContext1_1RecordToCloudKit(_ sourceRecord: Context1_1)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Context", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
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
                    self.privateDB.save(record!, completionHandler: { (savedRecord, saveError) in
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
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
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
        var predecessor: Int32 = 0
        
        let contextID = sourceRecord.object(forKey: "contextID") as! Int32
        let autoEmail = sourceRecord.object(forKey: "autoEmail") as! String
        let email = sourceRecord.object(forKey: "email") as! String
        let name = sourceRecord.object(forKey: "name") as! String
        let parentContext = sourceRecord.object(forKey: "parentContext") as! Int32
        let personID = sourceRecord.object(forKey: "personID") as! Int32
        let status = sourceRecord.object(forKey: "status") as! String
        let teamID = sourceRecord.object(forKey: "teamID") as! Int32
        let contextType = sourceRecord.object(forKey: "contextType") as! String
        
        if sourceRecord.object(forKey: "predecessor") != nil
        {
            predecessor = sourceRecord.object(forKey: "predecessor") as! Int32
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
        
        myDatabaseConnection.saveContext1_1(contextID, predecessor: predecessor, contextType: contextType, updateTime: updateTime, updateType: updateType)
    }

}
