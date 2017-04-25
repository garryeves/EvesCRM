//
//  displayPanes.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 11/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class displayPanes
{
    fileprivate var myPanes: [displayPane]!
    
    init()
    {
        // Create a new pane
        // Put breakpoint on this to ensure only executed once
//        let myPane = displayPane()
//        myPane.createPane("DropBox")
        
        // Get the list of panes

        myPanes = Array()
        
        let tablePanes = myDatabaseConnection.getPanes()
        
        if tablePanes.count > 0
        {
            for myEntry in tablePanes
            {
                let myPane = displayPane()
                
                myPane.loadPane(myEntry.pane_name!)
                
                myPanes.append(myPane)
            }
        }
        else
        {
            populatePanes()
        }
    }
        
    fileprivate func populatePanes()
    {
        // Populate roles with initial values
        //  Do this by checking to see if it exists already, if it does then do nothing otherwise create the pane
//        var loadSet = ["Calendar", "Details", "Evernote", "GMail", "Hangouts", "Omnifocus", "OneNote", "Project Membership", "Reminders", "Tasks"]
        
        let loadSet = ["Calendar", "Details", "DropBox", "Evernote", "GMail", "Hangouts", "OneNote", "Project Membership", "Reminders", "Tasks"]
 
        for myItem in loadSet
        {
            let myPane = displayPane()
            
            myPane.loadPane(myItem)

            if myPane.paneName == ""
            {
                // Nothing was returned so lets create a new one
                myPane.createPane(myItem)
                myPanes.append(myPane)
            }
        }
    }
    
    var listPanes: [displayPane]
    {
        get
        {
            return myPanes
        }
    }
    
    var listVisiblePanes: [displayPane]
    {
            get
            {
                var myListPanes: [displayPane] = Array()
                for myItem in myPanes
                {
                    if myItem.paneVisible
                    {
                        myListPanes.append(myItem)
                    }
                }
                return myListPanes
            }
    }
    
    func toogleVisibleStatus(_ inPane: String)
    {
        // find the pane
        
        for myItem in myPanes
        {
            if myItem.paneName == inPane
            {
                myItem.toggleVisible()
            }
        }

    }
    
    func setDisplayPane(_ inPane: String, inPaneOrder: Int)
    {
        // find the pane
        
        for myItem in myPanes
        {
            // "unset" current selection
            if myItem.paneOrder == inPaneOrder
            {
                myItem.paneOrder = 0
            }
            
            // set the new order
            if myItem.paneName == inPane
            {
                myItem.paneOrder = inPaneOrder
            }
        }
    }
}

class displayPane
{
    // This is for an instance of a pane
     
    fileprivate var myPaneName: String = ""
    fileprivate var myPaneAvailable: Bool = true
    fileprivate var myPaneVisible: Bool = true
    fileprivate var myPaneOrder: Int = 0
    fileprivate var paneLoaded: Bool = false
    
    func savePane()
    {
        myDatabaseConnection.savePane(myPaneName, inPaneAvailable: myPaneAvailable, inPaneVisible: myPaneVisible, inPaneOrder: myPaneOrder)
        
        paneLoaded = true
    }
    
    func createPane(_ paneName:String)
    {
        // Check to see if the pane exists
        if !paneLoaded
        {
            // Currently no pane loaded for this instance so lets check to see if an exisiting one exists
            
            loadPane(paneName)
            
            if !paneLoaded
            {
                // No pane was found so lets go ahead and enter the new details
                myPaneName = paneName
                myPaneAvailable = true
                myPaneVisible = true
                myPaneOrder = 0

                savePane()
            }
        }
    }
    
    func loadPane(_ paneName:String)
    {
        paneLoaded = false
        let fetchResults = myDatabaseConnection.getPane(paneName)
        
        if fetchResults.count > 0
        {
            for myPane in fetchResults
            {
                myPaneName = paneName
                myPaneAvailable = myPane.pane_available as! Bool
                myPaneVisible = myPane.pane_visible as! Bool
                myPaneOrder = myPane.pane_order as! Int
                paneLoaded = true
            }
        }
    }
    
    func toggleVisible()
    {
        myDatabaseConnection.togglePaneVisible(myPaneName)
        
        myPaneVisible = !myPaneVisible
    }
    
    var paneName: String
    {
        get
        {
            return myPaneName
        }
        set
        {
            myPaneName = newValue
        }
    }

    var paneAvailable: Bool
    {
        get
        {
            return myPaneAvailable
        }
        set
        {
            myPaneAvailable = newValue
        }
    }

    var paneVisible: Bool
    {
        get
        {
            return myPaneVisible
        }
        set
        {
            myPaneVisible = newValue
        }
    }

    var paneOrder: Int
    {
        get
        {
            return myPaneOrder
        }
        set
        {
            myPaneOrder = newValue
            myDatabaseConnection.setPaneOrder(myPaneName, paneOrder: newValue)
        }
    }
}

extension coreDatabase
{
    func deleteAllPanes()
    {  // This is used to allow for testing of pane creation, so can delete all the panes if needed
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myPane in fetchResults
            {
                myPane.updateTime =  NSDate()
                myPane.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getPanes() -> [Panes]
    {
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
        let sortDescriptor = NSSortDescriptor(key: "pane_name", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(pane_available == true) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
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
    
    func getPane(_ paneName:String) -> [Panes]
    {
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "pane_name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Create a new fetch request using the entity
        
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
    
    func togglePaneVisible(_ paneName: String)
    {
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myPane in fetchResults
            {
                if myPane.pane_visible == true
                {
                    myPane.pane_visible = false
                }
                else
                {
                    myPane.pane_visible = true
                }
                
                myPane.updateTime =  NSDate()
                if myPane.updateType != "Add"
                {
                    myPane.updateType = "Update"
                }
                
                myCloudDB.savePanesRecordToCloudKit(myPane)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func setPaneOrder(_ paneName: String, paneOrder: Int)
    {
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myPane in fetchResults
            {
                myPane.pane_order = NSNumber(value: paneOrder)
                myPane.updateTime =  NSDate()
                if myPane.updateType != "Add"
                {
                    myPane.updateType = "Update"
                }
                
                myCloudDB.savePanesRecordToCloudKit(myPane)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func savePane(_ inPaneName:String, inPaneAvailable: Bool, inPaneVisible: Bool, inPaneOrder: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myPane: Panes!
        
        let myPanes = getPane(inPaneName)
        
        if myPanes.count == 0
        {
            // Save the details of this pane to the database
            myPane = Panes(context: objectContext)
            
            myPane.pane_name = inPaneName
            myPane.pane_available = inPaneAvailable as NSNumber
            myPane.pane_visible = inPaneVisible as NSNumber
            myPane.pane_order = NSNumber(value: inPaneOrder)
            if inUpdateType == "CODE"
            {
                myPane.updateTime =  NSDate()
                myPane.updateType = "Add"
            }
            else
            {
                myPane.updateTime = inUpdateTime as NSDate
                myPane.updateType = inUpdateType
            }
        }
        else
        {
            myPane = myPanes[0]
            myPane.pane_available = inPaneAvailable as NSNumber
            myPane.pane_visible = inPaneVisible as NSNumber
            myPane.pane_order = NSNumber(value: inPaneOrder)
            if inUpdateType == "CODE"
            {
                myPane.updateTime =  NSDate()
                if myPane.updateType != "Add"
                {
                    myPane.updateType = "Update"
                }
            }
            else
            {
                myPane.updateTime = inUpdateTime as NSDate
                myPane.updateType = inUpdateType
            }
        }
        
        saveContext()
        
        myCloudDB.savePanesRecordToCloudKit(myPane)
    }
    
    func replacePane(_ inPaneName:String, inPaneAvailable: Bool, inPaneVisible: Bool, inPaneOrder: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myPane = Panes(context: objectContext)
        
        myPane.pane_name = inPaneName
        myPane.pane_available = inPaneAvailable as NSNumber
        myPane.pane_visible = inPaneVisible as NSNumber
        myPane.pane_order = NSNumber(value: inPaneOrder)
        if inUpdateType == "CODE"
        {
            myPane.updateTime =  NSDate()
            myPane.updateType = "Add"
        }
        else
        {
            myPane.updateTime = inUpdateTime as NSDate
            myPane.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func clearDeletedPanes(predicate: NSPredicate)
    {
        let fetchRequest10 = NSFetchRequest<Panes>(entityName: "Panes")
        
        // Set the predicate on the fetch request
        fetchRequest10.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults10 = try objectContext.fetch(fetchRequest10)
            for myItem10 in fetchResults10
            {
                objectContext.delete(myItem10 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedPanes(predicate: NSPredicate)
    {
        let fetchRequest10 = NSFetchRequest<Panes>(entityName: "Panes")
        
        // Set the predicate on the fetch request
        fetchRequest10.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults10 = try objectContext.fetch(fetchRequest10)
            for myItem10 in fetchResults10
            {
                myItem10.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getPanesForSync(_ inLastSyncDate: NSDate) -> [Panes]
    {
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
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
    
    func deleteAllPaneRecords()
    {
        let fetchRequest10 = NSFetchRequest<Panes>(entityName: "Panes")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults10 = try objectContext.fetch(fetchRequest10)
            for myItem10 in fetchResults10
            {
                self.objectContext.delete(myItem10 as NSManagedObject)
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
    func savePanesToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing Panes")
        for myItem in myDatabaseConnection.getPanesForSync(inLastSyncDate)
        {
            savePanesRecordToCloudKit(myItem)
        }
    }

    func updatePanesInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Panes", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updatePanesRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deletePanes()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Panes", predicate: predicate)
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

    func replacePanesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Panes", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let pane_name = record.object(forKey: "pane_name") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let pane_available = record.object(forKey: "pane_available") as! Bool
                let pane_order = record.object(forKey: "pane_order") as! Int
                let pane_visible = record.object(forKey: "pane_visible") as! Bool
                
                myDatabaseConnection.replacePane(pane_name, inPaneAvailable: pane_available, inPaneVisible: pane_visible, inPaneOrder: pane_order, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func savePanesRecordToCloudKit(_ sourceRecord: Panes)
    {
        let predicate = NSPredicate(format: "(pane_name == \"\(sourceRecord.pane_name!)\")") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Panes", predicate: predicate)
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
                    record!.setValue(sourceRecord.pane_available, forKey: "pane_available")
                    record!.setValue(sourceRecord.pane_order, forKey: "pane_order")
                    record!.setValue(sourceRecord.pane_visible, forKey: "pane_visible")
                    
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
                    let record = CKRecord(recordType: "Panes")
                    record.setValue(sourceRecord.pane_name, forKey: "pane_name")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.pane_available, forKey: "pane_available")
                    record.setValue(sourceRecord.pane_order, forKey: "pane_order")
                    record.setValue(sourceRecord.pane_visible, forKey: "pane_visible")
                    
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

    func updatePanesRecord(_ sourceRecord: CKRecord)
    {
        let pane_name = sourceRecord.object(forKey: "pane_name") as! String
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
        let pane_available = sourceRecord.object(forKey: "pane_available") as! Bool
        let pane_order = sourceRecord.object(forKey: "pane_order") as! Int
        let pane_visible = sourceRecord.object(forKey: "pane_visible") as! Bool
        
        myDatabaseConnection.savePane(pane_name, inPaneAvailable: pane_available, inPaneVisible: pane_visible, inPaneOrder: pane_order, inUpdateTime: updateTime, inUpdateType: updateType)
    }
}
