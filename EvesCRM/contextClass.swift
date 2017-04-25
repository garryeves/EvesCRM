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
            let myItemDetails = myDatabaseConnection.getContextDetails(myItem.contextID as! Int)
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: myItem.contextID as! Int)
                myPeopleContexts.append(myContext)
                myContexts.append(myContext)
            }
        }
        
        myPeopleContexts.sort { $0.name < $1.name }
        
        for myItem in myDatabaseConnection.getContextsForType("Place")
        {
            let myItemDetails = myDatabaseConnection.getContextDetails(myItem.contextID as! Int)
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: myItem.contextID as! Int)
                myPlaceContexts.append(myContext)
                myContexts.append(myContext)
            }
        }
        
        myPlaceContexts.sort { $0.name < $1.name }
        
        for myItem in myDatabaseConnection.getContextsForType("Tool")
        {
            let myItemDetails = myDatabaseConnection.getContextDetails(myItem.contextID as! Int)
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: myItem.contextID as! Int)
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
    
    
    /*
     var contextsByHierarchy: [context]
     {
     get
     {
     var workingArray: [context] = Array()
     
     workingArray = myContexts
     
     workingArray.sortInPlace { $0.contextHierarchy < $1.contextHierarchy }
     
     return workingArray
     }
     }
     
     var peopleContextsByHierarchy: [context]
     {
     get
     {
     var workingArray: [context] = Array()
     
     for myContext in myContexts
     {
     if myContext.personID != 0
     {
     workingArray.append(myContext)
     }
     }
     
     workingArray.sortInPlace { $0.contextHierarchy < $1.contextHierarchy }
     
     return workingArray
     }
     }
     
     var nonPeopleContextsByHierarchy: [context]
     {
     get
     {
     var workingArray: [context] = Array()
     
     for myContext in myContexts
     {
     if myContext.personID == 0
     {
     workingArray.append(myContext)
     }
     }
     
     workingArray.sortInPlace { $0.contextHierarchy < $1.contextHierarchy }
     
     return workingArray
     }
     }
     */
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
    
    
    init(inTeamID: Int)
    {
        super.init()
        
        myContextID = myDatabaseConnection.getNextID("Context")
        myTeamID = inTeamID
        
        save()
    }
    
    init(inContextName: String)
    {
        super.init()
        //       var matchFound: Bool = false
        
        let myContextList = contexts()
        
        // String of any unneeded whilespace
        
        let strippedContext = removeWhitespace(inContextName)
        
        for myContext in myContextList.allContexts
        {
            if myContext.name.lowercased() == strippedContext.lowercased()
            {
                // Existing context found, so use this record
                
                myContextID = myContext.contextID as Int
                myName = myContext.name
                myEmail = myContext.email
                myAutoEmail = myContext.autoEmail
                myParentContext = myContext.parentContext as Int
                myStatus = myContext.status
                myPersonID = myContext.personID
                myTeamID = myContext.teamID
                myContextType = myContext.contextType
                
                //               matchFound = true
                
                getContext1_1()
                
                break
            }
        }
        
        /*
         // if no match then create context
         
         if !matchFound
         {
         let currentNumberofEntries = myDatabaseConnection.getContextCount()
         myContextID = currentNumberofEntries + 1
         
         save()
         
         // Now we need to check the Addressbook to see if there is a match for the person, so we can store the personID
         
         let myPerson: ABRecord! = findPersonRecord(inContextName) as ABRecord!
         
         if myPerson == nil
         { // No match on Name so check on Email Addresses
         let myPersonEmail:ABRecord! = findPersonbyEmail(inContextName)
         
         if myPersonEmail != nil
         {
         myName = ABRecordCopyCompositeName(myPersonEmail).takeRetainedValue() as String
         myEmail = inContextName
         myPersonID = Int(ABRecordGetRecordID(myPersonEmail))
         }
         else
         {  // No match so use text passed in
         myName = strippedContext
         }
         }
         else
         {
         myName = ABRecordCopyCompositeName(myPerson).takeRetainedValue() as String
         myPersonID = Int(ABRecordGetRecordID(myPerson))
         }
         save()
         }
         */
    }
    
    init(contextID: Int)
    {
        super.init()
        let myContexts = myDatabaseConnection.getContextDetails(contextID)
        
        for myContext in myContexts
        {
            myContextID = myContext.contextID as! Int
            myName = myContext.name!
            myEmail = myContext.email!
            myAutoEmail = myContext.autoEmail!
            myParentContext = myContext.parentContext as! Int
            myStatus = myContext.status!
            myPersonID = myContext.personID as! Int
            myTeamID = myContext.teamID as! Int
            
            getContext1_1()
        }
    }
    
    init(inContext: Context)
    {
        super.init()
        myContextID = inContext.contextID as! Int
        myName = inContext.name!
        myEmail = inContext.email!
        myAutoEmail = inContext.autoEmail!
        myParentContext = inContext.parentContext as! Int
        myStatus = inContext.status!
        myPersonID = inContext.personID as! Int
        myTeamID = inContext.teamID as! Int
        
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
                myPredecessor = myItem.predecessor as! Int
                myContextType = myItem.contextType!
            }
        }
        
    }
    
    func save()
    {
        myDatabaseConnection.saveContext(myContextID, inName: myName, inEmail: myEmail, inAutoEmail: myAutoEmail, inParentContext: myParentContext, inStatus: myStatus, inPersonID: myPersonID, inTeamID: myTeamID)
        
        myDatabaseConnection.saveContext1_1(myContextID, predecessor: myPredecessor, contextType: myContextType)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(workingGTDLevel.performSave), userInfo: nil, repeats: false)
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
            //myDatabaseConnection.deleteContext(myContextID, inTeamID: myTeamID)
            myStatus = "Deleted"
            save()
            return true
        }
    }
}

extension coreDatabase
{
    func saveContext(_ inContextID: Int, inName: String, inEmail: String, inAutoEmail: String, inParentContext: Int, inStatus: String, inPersonID: Int, inTeamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myContext: Context!
        
        let myContexts = getContextDetails(inContextID)
        
        if myContexts.count == 0
        { // Add
            myContext = Context(context: objectContext)
            myContext.contextID = NSNumber(value: inContextID)
            myContext.name = inName
            myContext.email = inEmail
            myContext.autoEmail = inAutoEmail
            myContext.parentContext = NSNumber(value: inParentContext)
            myContext.status = inStatus
            myContext.personID = NSNumber(value: inPersonID)
            myContext.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myContext.updateTime =  NSDate()
                
                myContext.updateType = "Add"
            }
            else
            {
                myContext.updateTime = inUpdateTime as NSDate
                myContext.updateType = inUpdateType
            }
        }
        else
        {
            myContext = myContexts[0]
            myContext.name = inName
            myContext.email = inEmail
            myContext.autoEmail = inAutoEmail
            myContext.parentContext = NSNumber(value: inParentContext)
            myContext.status = inStatus
            myContext.personID = NSNumber(value: inPersonID)
            myContext.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myContext.updateTime =  NSDate()
                if myContext.updateType != "Add"
                {
                    myContext.updateType = "Update"
                }
            }
            else
            {
                myContext.updateTime = inUpdateTime as NSDate
                myContext.updateType = inUpdateType
            }
        }
        
        saveContext()
    }
    
    func replaceContext(_ inContextID: Int, inName: String, inEmail: String, inAutoEmail: String, inParentContext: Int, inStatus: String, inPersonID: Int, inTeamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myContext = Context(context: objectContext)
        myContext.contextID = NSNumber(value: inContextID)
        myContext.name = inName
        myContext.email = inEmail
        myContext.autoEmail = inAutoEmail
        myContext.parentContext = NSNumber(value: inParentContext)
        myContext.status = inStatus
        myContext.personID = NSNumber(value: inPersonID)
        myContext.teamID = NSNumber(value: inTeamID)
        if inUpdateType == "CODE"
        {
            myContext.updateTime =  NSDate()
            myContext.updateType = "Add"
        }
        else
        {
            myContext.updateTime = inUpdateTime as NSDate
            myContext.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func deleteContext(_ inContextID: Int, inTeamID: Int)
    {
        let myContexts = getContextDetails(inContextID)
        
        if myContexts.count > 0
        {
            let myContext = myContexts[0]
            myContext.updateTime =  NSDate()
            myContext.updateType = "Delete"
        }
        
        saveContext()
        
        let myContexts2 = getContext1_1(inContextID)
        
        if myContexts2.count > 0
        {
            let myContext = myContexts[0]
            myContext.updateTime =  NSDate()
            myContext.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getContexts(_ inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(status != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
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
    
    func getAllContexts(_ inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
    
    func initialiseTeamForContext(_ inTeamID: Int)
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
                    myItem.teamID = NSNumber(value: inTeamID)
                    maxID = myItem.contextID as! Int
                }
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Context", inCodeValue: tempInt, inCodeType: "hidden")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func saveContext1_1(_ contextID: Int, predecessor: Int, contextType: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myContext: Context1_1!
        
        let myContexts = getContext1_1(contextID)
        
        if myContexts.count == 0
        { // Add
            myContext = Context1_1(context: objectContext)
            myContext.contextID = contextID as NSNumber?
            myContext.predecessor = predecessor as NSNumber?
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
            myContext.predecessor = predecessor as NSNumber?
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
    
    func replaceContext1_1(_ contextID: Int, predecessor: Int, contextType: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myContext = Context1_1(context: objectContext)
        myContext.contextID = contextID as NSNumber?
        myContext.predecessor = predecessor as NSNumber?
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
    
    func getContext1_1(_ inContextID: Int)->[Context1_1]
    {
        let fetchRequest = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (contextID == \(inContextID))")
        
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
    
    func getContextsForSync(_ inLastSyncDate: NSDate) -> [Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
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
    
    func getContexts1_1ForSync(_ inLastSyncDate: NSDate) -> [Context1_1]
    {
        let fetchRequest = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
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
    func saveContextToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing Contexts")
        for myItem in myDatabaseConnection.getContextsForSync(inLastSyncDate)
        {
            saveContextRecordToCloudKit(myItem)
        }
        
        for myItem in myDatabaseConnection.getContexts1_1ForSync(inLastSyncDate)
        {
            saveContext1_1RecordToCloudKit(myItem)
        }
    }

    func updateContextInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateContextRecord(record)
            }
            sem.signal()
        })
        
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
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        var predecessor: Int = 0
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
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
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                
                myDatabaseConnection.replaceContext(contextID, inName: name, inEmail: email, inAutoEmail: autoEmail, inParentContext: parentContext, inStatus: status, inPersonID: personID, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
                
                
                myDatabaseConnection.replaceContext1_1(contextID, predecessor: predecessor, contextType: contextType, updateTime: updateTime, updateType: updateType)
                
            }
            sem.signal()
        })
    }
    
    func saveContextRecordToCloudKit(_ sourceRecord: Context)
    {
        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID as! Int)) && (teamID == \(sourceRecord.teamID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Context", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                let tempContext1_1 = myDatabaseConnection.getContext1_1(sourceRecord.contextID as! Int)
                
                var myPredecessor: Int = 0
                var myContextType: String = ""
                
                if tempContext1_1.count > 0
                {
                    myPredecessor = tempContext1_1[0].predecessor as! Int
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
                    record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
        })
    }
    
    func saveContext1_1RecordToCloudKit(_ sourceRecord: Context1_1)
    {
        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID as! Int))") // better be accurate to get only the record you need
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
                    record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
        })
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
        
        myDatabaseConnection.saveContext(contextID, inName: name, inEmail: email, inAutoEmail: autoEmail, inParentContext: parentContext, inStatus: status, inPersonID: personID, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
        
        myDatabaseConnection.saveContext1_1(contextID, predecessor: predecessor, contextType: contextType, updateTime: updateTime, updateType: updateType)
    }

}
