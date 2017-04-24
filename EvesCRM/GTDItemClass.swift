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
    
    init(inGTDItemID: Int, inTeamID: Int)
    {
        super.init()
        
        // Load the details
        
        if inGTDItemID == 0
        {
            // this is top level so have no details
            myTeamID = inTeamID
            myGTDLevel = 1
        }
        else
        {
            let myGTDDetail = myDatabaseConnection.getGTDItem(inGTDItemID, inTeamID: inTeamID)
            
            for myItem in myGTDDetail
            {
                myGTDItemID = myItem.gTDItemID as! Int
                myTitle = myItem.title!
                myStatus = myItem.status!
                myTeamID = myItem.teamID as! Int
                myNote = myItem.note!
                myLastReviewDate = myItem.lastReviewDate
                myReviewFrequency = myItem.reviewFrequency as! Int
                myReviewPeriod = myItem.reviewPeriod!
                myPredecessor = myItem.predecessor as! Int
                myGTDLevel = myItem.gTDLevel as! Int
                myGTDParentID = myItem.gTDParentID as! Int
            }
        }
        
        if myStoreGTDLevel == 0
        { // We only wantto do this once per instantiation of the object
            let tempTeam = myDatabaseConnection.getGTDLevels(myTeamID)
            
            myStoreGTDLevel = tempTeam.count
        }
        
        // Load the Members
        loadChildren()
    }
    
    init(inTeamID: Int, inParentID: Int)
    {
        super.init()
        
        myGTDItemID = myDatabaseConnection.getNextID("GTDItem")
        myGTDParentID = inParentID
        myLastReviewDate = getDefaultDate() as Date!
        myTeamID = inTeamID
        
        if myStoreGTDLevel == 0
        { // We only wantto do this once per instantiation of the object
            let tempTeam = myDatabaseConnection.getGTDLevels(myTeamID)
            
            myStoreGTDLevel = tempTeam.count
        }
        
        save()
    }
    
    func save()
    {
        myDatabaseConnection.saveGTDItem(myGTDItemID, inParentID: myGTDParentID, inTitle: myTitle, inStatus: myStatus, inTeamID: myTeamID, inNote: myNote, inLastReviewDate: myLastReviewDate, inReviewFrequency: myReviewFrequency, inReviewPeriod: myReviewPeriod, inPredecessor: myPredecessor, inGTDLevel: myGTDLevel)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(workingGTDLevel.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myGTDItem = myDatabaseConnection.checkGTDItem(myGTDItemID, inTeamID: myTeamID)[0]
        
        myCloudDB.saveGTDItemRecordToCloudKit(myGTDItem)
        
        saveCalled = false
    }
    
    func addChild(_ inChild: workingGTDItem)
    {
        inChild.GTDParentID = myGTDItemID
        loadChildren()
    }
    
    func removeChild(_ inChild: workingGTDItem)
    {
        inChild.GTDParentID = 0
        loadChildren()
    }
    
    func loadChildren()
    {
        // check to see if this is the bottom of the GTD hierarchy
        
        if myGTDLevel != myStoreGTDLevel
        { // Not bottom of hierarchy so get GTDITem as children
            let myChildrenList = myDatabaseConnection.getOpenGTDChildItems(myGTDItemID, inTeamID: myTeamID)
            myChildren.removeAll()
            
            for myItem in myChildrenList
            {
                let myNewChild = workingGTDItem(inGTDItemID: myItem.gTDItemID as! Int, inTeamID: myTeamID)
                myChildren.append(myNewChild)
            }
        }
        else
        {  // Bottom of GTD Hierarchy, so children are projects
            
            myChildren.removeAll()
            
            let myChildrenList = myDatabaseConnection.getOpenProjectsForGTDItem(myGTDItemID, inTeamID: myTeamID)
            
            for myItem in myChildrenList
            {
                // Check to see if the start date is in the future
                var boolAddProject: Bool = true
                
                if myItem.projectStartDate != getDefaultDate()
                {
                    if myItem.projectStartDate.compare(Date()) == ComparisonResult.orderedDescending
                    {  // Start date is in future
                        boolAddProject = false
                    }
                }
                
                if boolAddProject
                {
                    let myNewChild = project(inProjectID: myItem.projectID as! Int)
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
                let tempSuccessor = workingGTDItem(inGTDItemID: fromCurrentPredecessor, inTeamID: myTeamID)
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
            return fetchResults[0].gTDItemID as! Int
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
    
    func saveGTDItem(_ inGTDItemID: Int, inParentID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: Date, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int, inGTDLevel: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myGTD: GTDItem!
        
        let myGTDItems = checkGTDItem(inGTDItemID, inTeamID: inTeamID)
        
        if myGTDItems.count == 0
        { // Add
            myGTD = GTDItem(context: objectContext)
            myGTD.gTDItemID = inGTDItemID as NSNumber?
            myGTD.gTDParentID = inParentID as NSNumber?
            myGTD.title = inTitle
            myGTD.status = inStatus
            myGTD.teamID = inTeamID as NSNumber?
            myGTD.note = inNote
            myGTD.lastReviewDate = inLastReviewDate
            myGTD.reviewFrequency = inReviewFrequency as NSNumber?
            myGTD.reviewPeriod = inReviewPeriod
            myGTD.predecessor = inPredecessor as NSNumber?
            myGTD.gTDLevel = inGTDLevel as NSNumber?
            if inUpdateType == "CODE"
            {
                myGTD.updateTime =  Date()
                myGTD.updateType = "Add"
            }
            else
            {
                myGTD.updateTime = inUpdateTime
                myGTD.updateType = inUpdateType
            }
        }
        else
        { // Update
            myGTD = myGTDItems[0]
            myGTD.gTDParentID = inParentID as NSNumber?
            myGTD.title = inTitle
            myGTD.status = inStatus
            myGTD.updateTime =  Date()
            myGTD.teamID = inTeamID as NSNumber?
            myGTD.note = inNote
            myGTD.lastReviewDate = inLastReviewDate
            myGTD.reviewFrequency = inReviewFrequency as NSNumber?
            myGTD.reviewPeriod = inReviewPeriod
            myGTD.predecessor = inPredecessor as NSNumber?
            myGTD.gTDLevel = inGTDLevel as NSNumber?
            if inUpdateType == "CODE"
            {
                if myGTD.updateType != "Add"
                {
                    myGTD.updateType = "Update"
                }
            }
            else
            {
                myGTD.updateTime = inUpdateTime
                myGTD.updateType = inUpdateType
            }
        }
        
        saveContext()
    }
    
    func replaceGTDItem(_ inGTDItemID: Int, inParentID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: Date, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int, inGTDLevel: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myGTD = GTDItem(context: objectContext)
        myGTD.gTDItemID = inGTDItemID as NSNumber?
        myGTD.gTDParentID = inParentID as NSNumber?
        myGTD.title = inTitle
        myGTD.status = inStatus
        myGTD.teamID = inTeamID as NSNumber?
        myGTD.note = inNote
        myGTD.lastReviewDate = inLastReviewDate
        myGTD.reviewFrequency = inReviewFrequency as NSNumber?
        myGTD.reviewPeriod = inReviewPeriod
        myGTD.predecessor = inPredecessor as NSNumber?
        myGTD.gTDLevel = inGTDLevel as NSNumber?
        if inUpdateType == "CODE"
        {
            myGTD.updateTime =  Date()
            myGTD.updateType = "Add"
        }
        else
        {
            myGTD.updateTime = inUpdateTime
            myGTD.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func deleteGTDItem(_ inGTDItemID: Int, inTeamID: Int)
    {
        var myGTD: GTDItem!
        
        let myGTDItems = checkGTDItem(inGTDItemID, inTeamID: inTeamID)
        
        if myGTDItems.count > 0
        { // Update
            myGTD = myGTDItems[0]
            myGTD.updateTime =  Date()
            myGTD.updateType = "Delete"
        }
        saveContext()
    }
    
    func getGTDItem(_ inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDItemID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
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
    
    func getGTDItemsForLevel(_ inGTDLevel: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(inGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
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
    
    func getOpenGTDChildItems(_ inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDParentID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
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
    
    func checkGTDItem(_ inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDItemID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
    
    func getGTDItemsForSync(_ inLastSyncDate: NSDate) -> [GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
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
    func saveGTDItemToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing GTDItem")
        for myItem in myDatabaseConnection.getGTDItemsForSync(inLastSyncDate)
        {
            saveGTDItemRecordToCloudKit(myItem)
        }
    }

    func updateGTDItemInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateGTDItemRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteGTDItem()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            sem.signal()
        })
        sem.wait()
    }

    func replaceGTDItemInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let gTDItemID = record.object(forKey: "gTDItemID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
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
                
                myDatabaseConnection.replaceGTDItem(gTDItemID, inParentID: gTDParentID, inTitle: title, inStatus: status, inTeamID: teamID, inNote: note, inLastReviewDate: lastReviewDate, inReviewFrequency: reviewFrequency, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inGTDLevel: gTDLevel, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveGTDItemRecordToCloudKit(_ sourceRecord: GTDItem)
    {
        let predicate = NSPredicate(format: "(gTDItemID == \(sourceRecord.gTDItemID as! Int)) && (teamID == \(sourceRecord.teamID as! Int))")
        let query = CKQuery(recordType: "GTDItem", predicate: predicate)
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
                    record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
                    let record = CKRecord(recordType: "GTDItem")
                    record.setValue(sourceRecord.gTDItemID, forKey: "gTDItemID")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
        
        myDatabaseConnection.saveGTDItem(gTDItemID, inParentID: gTDParentID, inTitle: title, inStatus: status, inTeamID: teamID, inNote: note, inLastReviewDate: lastReviewDate, inReviewFrequency: reviewFrequency, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inGTDLevel: gTDLevel, inUpdateTime: updateTime, inUpdateType: updateType)
    }
}
