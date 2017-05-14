//
//  GTDItemClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class workingGTDItem: NSObject
{
    fileprivate var myGTDItemID: Int = 0
    fileprivate var myGTDParentID: Int = 0
    fileprivate var myTitle: String = "New"
    fileprivate var myStatus: String = ""
    fileprivate var myChildren: [AnyObject] = Array()
    fileprivate var myTeamID: Int = 0
    fileprivate var myNote: String = ""
    fileprivate var myLastReviewDate: Date!
    fileprivate var myReviewFrequency: Int = 0
    fileprivate var myReviewPeriod: String = ""
    fileprivate var myPredecessor: Int = 0
    fileprivate var myGTDID: Int = 0
    fileprivate var myGTDLevel: Int = 0
    fileprivate var myStoreGTDLevel: Int = 0
    fileprivate var saveCalled: Bool = false
    
    var GTDItemID: Int
    {
        get
        {
            return myGTDItemID
        }
        set
        {
            myGTDItemID = newValue
            save()
        }
    }
    
    var GTDLevelID: Int
    {
        get
        {
            return myGTDID
        }
        set
        {
            myGTDID = newValue
            save()
        }
    }
    
    var GTDParentID: Int
    {
        get
        {
            return myGTDParentID
        }
        set
        {
            myGTDParentID = newValue
            save()
        }
    }
    
    var GTDLevel: Int
    {
        get
        {
            return myGTDLevel
        }
        set
        {
            myGTDLevel = newValue
            save()
        }
    }
    
    var title: String
    {
        get
        {
            return myTitle
        }
        set
        {
            myTitle = newValue
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
    
    var children: [AnyObject]
    {
        get
        {
            return myChildren
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
    
    var lastReviewDate: Date
    {
        get
        {
            return myLastReviewDate
        }
        set
        {
            myLastReviewDate = newValue
            save()
        }
    }
    
    var displayLastReviewDate: String
    {
        get
        {
            if myLastReviewDate == nil
            {
                myLastReviewDate = getDefaultDate() as Date!
                save()
                return ""
            }
            else if myLastReviewDate == getDefaultDate() as Date
            {
                return ""
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = DateFormatter.Style.medium
                return myDateFormatter.string(from: myLastReviewDate)
            }
        }
    }
    
    var reviewFrequency: Int
    {
        get
        {
            return myReviewFrequency
        }
        set
        {
            myReviewFrequency = newValue
            save()
        }
    }
    
    var reviewPeriod: String
    {
        get
        {
            return myReviewPeriod
        }
        set
        {
            myReviewPeriod = newValue
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
    
    init(GTDItemID: Int, teamID: Int)
    {
        super.init()
        
        // Load the details
        
        if GTDItemID == 0
        {
            // this is top level so have no details
            myTeamID = teamID
            myGTDLevel = 1
        }
        else
        {
            let myGTDDetail = myDatabaseConnection.getGTDItem(GTDItemID, teamID: teamID)
            
            for myItem in myGTDDetail
            {
                myGTDItemID = Int(myItem.gTDItemID)
                myTitle = myItem.title!
                myStatus = myItem.status!
                myTeamID = Int(myItem.teamID)
                myNote = myItem.note!
                myLastReviewDate = myItem.lastReviewDate! as Date
                myReviewFrequency = Int(myItem.reviewFrequency)
                myReviewPeriod = myItem.reviewPeriod!
                myPredecessor = Int(myItem.predecessor)
                myGTDLevel = Int(myItem.gTDLevel)
                myGTDParentID = Int(myItem.gTDParentID)
            }
        }
        
        if myStoreGTDLevel == 0
        { // We only wantto do this once per instantiation of the object
            let tempTeam = myDatabaseConnection.getGTDLevels(teamID)
            
            myStoreGTDLevel = Int(tempTeam.count)
        }
        
        // Load the Members
        loadChildren()
    }
    
    init(teamID: Int, parentID: Int)
    {
        super.init()
        
        myGTDItemID = myDatabaseConnection.getNextID("GTDItem")
        myGTDParentID = parentID
        myLastReviewDate = getDefaultDate() as Date!
        myTeamID = teamID
        
        if myStoreGTDLevel == 0
        { // We only wantto do this once per instantiation of the object
            let tempTeam = myDatabaseConnection.getGTDLevels(teamID)
            
            myStoreGTDLevel = Int(tempTeam.count)
        }
        
        save()
    }
    
    func save()
    {
        myDatabaseConnection.saveGTDItem(myGTDItemID, parentID: myGTDParentID, title: myTitle, status: myStatus, teamID: myTeamID, note: myNote, lastReviewDate: myLastReviewDate, reviewFrequency: myReviewFrequency, reviewPeriod: myReviewPeriod, predecessor: myPredecessor, GTDLevel: myGTDLevel)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myGTDItem = myDatabaseConnection.checkGTDItem(myGTDItemID, teamID: myTeamID)[0]
        
        myCloudDB.saveGTDItemRecordToCloudKit(myGTDItem, teamID: currentUser.currentTeam!.teamID)
        
        saveCalled = false
    }
    
    func addChild(_ child: workingGTDItem)
    {
        child.GTDParentID = myGTDItemID
        loadChildren()
    }
    
    func removeChild(_ child: workingGTDItem)
    {
        child.GTDParentID = 0
        loadChildren()
    }
    
    func loadChildren()
    {
        // check to see if this is the bottom of the GTD hierarchy
        
        if myGTDLevel != myStoreGTDLevel
        { // Not bottom of hierarchy so get GTDITem as children
            let myChildrenList = myDatabaseConnection.getOpenGTDChildItems(myGTDItemID, teamID: myTeamID)
            myChildren.removeAll()
            
            for myItem in myChildrenList
            {
                let myNewChild = workingGTDItem(GTDItemID: Int(myItem.gTDItemID), teamID: myTeamID)
                myChildren.append(myNewChild)
            }
        }
        else
        {  // Bottom of GTD Hierarchy, so children are projects
            
            myChildren.removeAll()
            
            let myChildrenList = myDatabaseConnection.getOpenProjectsForGTDItem(myGTDItemID, teamID: myTeamID)
            
            for myItem in myChildrenList
            {
                // Check to see if the start date is in the future
                var boolAddProject: Bool = true
                
                if myItem.projectStartDate! != (getDefaultDate() as NSDate)
                {
                    if myItem.projectStartDate?.compare(Date()) == ComparisonResult.orderedDescending
                    {  // Start date is in future
                        boolAddProject = false
                    }
                }
                
                if boolAddProject
                {
                    let myNewChild = project(projectID: Int(myItem.projectID))
                    myChildren.append(myNewChild)
                }
            }
        }
    }
    
    func delete() -> Bool
    {
        if myChildren.count > 0
        {
            return false
        }
        else
        {
            myStatus = "Deleted"
            save()
            
            // Need to see if this is in a predessor tree, if it is then we need to update so that this is skipped
            
            // Go and see if another item has set as its predecessor
            
            let fromCurrentPredecessor = myDatabaseConnection.getGTDItemSuccessor(myGTDItemID)
            
            if fromCurrentPredecessor > 0
            {  // This item is a predecessor
                let tempSuccessor = workingGTDItem(GTDItemID: fromCurrentPredecessor, teamID: myTeamID)
                tempSuccessor.predecessor = myPredecessor
            }
            
            return true
        }
    }
}

extension coreDatabase
{
    func getGTDItemSuccessor(_ projectID: Int)->Int
    {
        
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(predecessor == \(projectID)) && (updateType != \"Delete\") && (status != \"Closed\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return Int(fetchResults[0].gTDItemID)
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
    
    func saveGTDItem(_ GTDItemID: Int, parentID: Int, title: String, status: String, teamID: Int, note: String, lastReviewDate: Date, reviewFrequency: Int, reviewPeriod: String, predecessor: Int, GTDLevel: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myGTD: GTDItem!
        
        let myGTDItems = checkGTDItem(GTDItemID, teamID: teamID)
        
        if myGTDItems.count == 0
        { // Add
            myGTD = GTDItem(context: objectContext)
            myGTD.gTDItemID = Int64(GTDItemID)
            myGTD.gTDParentID = Int64(parentID)
            myGTD.title = title
            myGTD.status = status
            myGTD.teamID = Int64(teamID)
            myGTD.note = note
            myGTD.lastReviewDate = lastReviewDate as NSDate
            myGTD.reviewFrequency = Int64(reviewFrequency)
            myGTD.reviewPeriod = reviewPeriod
            myGTD.predecessor = Int64(predecessor)
            myGTD.gTDLevel = Int64(GTDLevel)
            if updateType == "CODE"
            {
                myGTD.updateTime =  NSDate()
                myGTD.updateType = "Add"
            }
            else
            {
                myGTD.updateTime = updateTime as NSDate
                myGTD.updateType = updateType
            }
        }
        else
        { // Update
            myGTD = myGTDItems[0]
            myGTD.gTDParentID = Int64(parentID)
            myGTD.title = title
            myGTD.status = status
            myGTD.updateTime =  NSDate()
            myGTD.teamID = Int64(teamID)
            myGTD.note = note
            myGTD.lastReviewDate = lastReviewDate as NSDate
            myGTD.reviewFrequency = Int64(reviewFrequency)
            myGTD.reviewPeriod = reviewPeriod
            myGTD.predecessor = Int64(predecessor)
            myGTD.gTDLevel = Int64(GTDLevel)
            if updateType == "CODE"
            {
                if myGTD.updateType != "Add"
                {
                    myGTD.updateType = "Update"
                }
            }
            else
            {
                myGTD.updateTime = updateTime as NSDate
                myGTD.updateType = updateType
            }
        }
        
        saveContext()
    }
    
    func replaceGTDItem(_ GTDItemID: Int, parentID: Int, title: String, status: String, teamID: Int, note: String, lastReviewDate: Date, reviewFrequency: Int, reviewPeriod: String, predecessor: Int, GTDLevel: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myGTD = GTDItem(context: objectContext)
        myGTD.gTDItemID = Int64(GTDItemID)
        myGTD.gTDParentID = Int64(parentID)
        myGTD.title = title
        myGTD.status = status
        myGTD.teamID = Int64(teamID)
        myGTD.note = note
        myGTD.lastReviewDate = lastReviewDate as NSDate
        myGTD.reviewFrequency = Int64(reviewFrequency)
        myGTD.reviewPeriod = reviewPeriod
        myGTD.predecessor = Int64(predecessor)
        myGTD.gTDLevel = Int64(GTDLevel)
        if updateType == "CODE"
        {
            myGTD.updateTime =  NSDate()
            myGTD.updateType = "Add"
        }
        else
        {
            myGTD.updateTime = updateTime as NSDate
            myGTD.updateType = updateType
        }
        
        saveContext()
    }
    
    func deleteGTDItem(_ GTDItemID: Int, teamID: Int)
    {
        var myGTD: GTDItem!
        
        let myGTDItems = checkGTDItem(GTDItemID, teamID: teamID)
        
        if myGTDItems.count > 0
        { // Update
            myGTD = myGTDItems[0]
            myGTD.updateTime =  NSDate()
            myGTD.updateType = "Delete"
        }
        saveContext()
    }
    
    func getGTDItem(_ GTDItemID: Int, teamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDItemID == \(GTDItemID)) && (updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
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
    
    func getGTDItemsForLevel(_ GTDLevel: Int, teamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(GTDLevel)) && (updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
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
    
    func getGTDItemCount() -> Int
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
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
    
    func getOpenGTDChildItems(_ GTDItemID: Int, teamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDParentID == \(GTDItemID)) && (updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
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
    
    func checkGTDItem(_ GTDItemID: Int, teamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDItemID == \(GTDItemID)) && (updateType != \"Delete\") && (teamID == \(teamID))")
        
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
    
    func clearDeletedGTDItems(predicate: NSPredicate)
    {
        let fetchRequest25 = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Set the predicate on the fetch request
        fetchRequest25.predicate = predicate
        do
        {
            let fetchResults25 = try objectContext.fetch(fetchRequest25)
            for myItem25 in fetchResults25
            {
                objectContext.delete(myItem25 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func clearSyncedGTDItems(predicate: NSPredicate)
    {
        let fetchRequest25 = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        // Set the predicate on the fetch request
        fetchRequest25.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults25 = try objectContext.fetch(fetchRequest25)
            for myItem25 in fetchResults25
            {
                myItem25.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getGTDItemsForSync(_ syncDate: Date) -> [GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
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

    func deleteAllGTDItemRecords()
    {
        let fetchRequest25 = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        do
        {
            let fetchResults25 = try objectContext.fetch(fetchRequest25)
            for myItem25 in fetchResults25
            {
                self.objectContext.delete(myItem25 as NSManagedObject)
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
    func saveGTDItemToCloudKit()
    {
        for myItem in myDatabaseConnection.getGTDItemsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "GTDItem"))
        {
            saveGTDItemRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }

    func updateGTDItemInCoreData(teamID: Int)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "GTDItem") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1

            self.updateGTDItemRecord(record)
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

    func deleteGTDItem(teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
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

    func replaceGTDItemInCoreData(teamID: Int)
    {
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let gTDItemID = record.object(forKey: "gTDItemID") as! Int
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
            let gTDParentID = record.object(forKey: "gTDParentID") as! Int
            let lastReviewDate = record.object(forKey: "lastReviewDate") as! Date
            let note = record.object(forKey: "note") as! String
            let predecessor = record.object(forKey: "predecessor") as! Int
            let reviewFrequency = record.object(forKey: "reviewFrequency") as! Int
            let reviewPeriod = record.object(forKey: "reviewPeriod") as! String
            let status = record.object(forKey: "status") as! String
            let teamID = record.object(forKey: "teamID") as! Int
            let title = record.object(forKey: "title") as! String
            let gTDLevel = record.object(forKey: "gTDLevel") as! Int
            
            myDatabaseConnection.replaceGTDItem(gTDItemID, parentID: gTDParentID, title: title, status: status, teamID: teamID, note: note, lastReviewDate: lastReviewDate, reviewFrequency: reviewFrequency, reviewPeriod: reviewPeriod, predecessor: predecessor, GTDLevel: gTDLevel, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveGTDItemRecordToCloudKit(_ sourceRecord: GTDItem, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(gTDItemID == \(sourceRecord.gTDItemID)) AND \(buildTeamList(currentUser.userID))")
        let query = CKQuery(recordType: "GTDItem", predicate: predicate)
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
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.gTDParentID, forKey: "gTDParentID")
                    record!.setValue(sourceRecord.lastReviewDate, forKey: "lastReviewDate")
                    record!.setValue(sourceRecord.note, forKey: "note")
                    record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record!.setValue(sourceRecord.reviewFrequency, forKey: "reviewFrequency")
                    record!.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    record!.setValue(sourceRecord.title, forKey: "title")
                    record!.setValue(sourceRecord.gTDLevel, forKey: "gTDLevel")
                    
                    
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
                    let record = CKRecord(recordType: "GTDItem")
                    record.setValue(sourceRecord.gTDItemID, forKey: "gTDItemID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.gTDParentID, forKey: "gTDParentID")
                    record.setValue(sourceRecord.lastReviewDate, forKey: "lastReviewDate")
                    record.setValue(sourceRecord.note, forKey: "note")
                    record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record.setValue(sourceRecord.reviewFrequency, forKey: "reviewFrequency")
                    record.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                    record.setValue(sourceRecord.status, forKey: "status")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.title, forKey: "title")
                    record.setValue(sourceRecord.gTDLevel, forKey: "gTDLevel")
                    record.setValue(teamID, forKey: "teamID")
                    
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

    func updateGTDItemRecord(_ sourceRecord: CKRecord)
    {
        let gTDItemID = sourceRecord.object(forKey: "gTDItemID") as! Int
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
        let gTDParentID = sourceRecord.object(forKey: "gTDParentID") as! Int
        let lastReviewDate = sourceRecord.object(forKey: "lastReviewDate") as! Date
        let note = sourceRecord.object(forKey: "note") as! String
        let predecessor = sourceRecord.object(forKey: "predecessor") as! Int
        let reviewFrequency = sourceRecord.object(forKey: "reviewFrequency") as! Int
        let reviewPeriod = sourceRecord.object(forKey: "reviewPeriod") as! String
        let status = sourceRecord.object(forKey: "status") as! String
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        let title = sourceRecord.object(forKey: "title") as! String
        let gTDLevel = sourceRecord.object(forKey: "gTDLevel") as! Int
        
        myDatabaseConnection.saveGTDItem(gTDItemID, parentID: gTDParentID, title: title, status: status, teamID: teamID, note: note, lastReviewDate: lastReviewDate, reviewFrequency: reviewFrequency, reviewPeriod: reviewPeriod, predecessor: predecessor, GTDLevel: gTDLevel, updateTime: updateTime, updateType: updateType)
    }
}
