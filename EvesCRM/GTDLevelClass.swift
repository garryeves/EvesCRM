//
//  GTDLevelClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class workingGTDLevel: NSObject
{
    fileprivate var myTitle: String = "New"
    fileprivate var myTeamID: Int = 0
    fileprivate var myGTDLevel: Int = 0
    fileprivate var saveCalled: Bool = false
    
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
    
    var teamID: Int
    {
        get
        {
            return myTeamID
        }
    }
    
    init(inGTDLevel: Int, inTeamID: Int)
    {
        super.init()
        
        // Load the details
        
        let myGTDDetail = myDatabaseConnection.getGTDLevel(inGTDLevel, inTeamID: inTeamID)
        
        for myItem in myGTDDetail
        {
            myTitle = myItem.levelName!
            myTeamID = myItem.teamID as! Int
            myGTDLevel = inGTDLevel
        }
    }
    
    init(inGTDLevel: Int, inLevelName: String, inTeamID: Int)
    {
        super.init()
        
        myGTDLevel = inGTDLevel
        myTitle = inLevelName
        myTeamID = inTeamID
        
        save()
    }
    
    init(inLevelName: String, inTeamID: Int)
    {
        super.init()
        
        let myGTDDetail = myDatabaseConnection.getGTDLevels(inTeamID)
        
        myGTDLevel = myGTDDetail.count + 1
        myTeamID = inTeamID
        myTitle = inLevelName
        
        save()
    }
    
    func save()
    {
        myDatabaseConnection.saveGTDLevel(myGTDLevel, inLevelName: myTitle, inTeamID: myTeamID)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(workingGTDLevel.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myGTD = myDatabaseConnection.getGTDLevel(myGTDLevel, inTeamID: myTeamID)[0]
        
        myCloudDB.saveGTDLevelRecordToCloudKit(myGTD)
        
        saveCalled = false
    }
    
    func delete()
    { // Delete the current GTD Level and move the remaining ones up a level
        myDatabaseConnection.deleteGTDLevel(myGTDLevel, inTeamID: myTeamID)
        
        var currentLevel = myGTDLevel
        var boolLoop: Bool = true
        
        while boolLoop
        {
            let tempLevel = myDatabaseConnection.getGTDLevel(currentLevel + 1, inTeamID: myTeamID)
            
            if tempLevel.count == 0
            {  // reached the end, so do nothing
                boolLoop = false
            }
            else
            {  // There is another level so need to decrement the level count
                myDatabaseConnection.changeGTDLevel(currentLevel + 1, newGTDLevel: currentLevel, inTeamID: myTeamID)
                
                currentLevel += 1
            }
        }
    }
    
    func moveLevel(_ newLevel: Int)
    {
        if myGTDLevel > newLevel
        {
            // Move the existing entries first
            var levelCount: Int = myGTDLevel - 1
            // Dirty workaround.  Set the level for the one we are moving to a so weirdwe can reset it at the end
            
            myDatabaseConnection.changeGTDLevel(myGTDLevel, newGTDLevel: -99, inTeamID: myTeamID)
            
            while levelCount >= newLevel
            {
                NSLog("Move level \(levelCount)")
                let nextLevel = levelCount + 1
                myDatabaseConnection.changeGTDLevel(levelCount, newGTDLevel: nextLevel, inTeamID: myTeamID)
                levelCount -= 1
            }
            myDatabaseConnection.changeGTDLevel(-99, newGTDLevel: newLevel, inTeamID: myTeamID)
        }
        else
        {
            NSLog("Moving down from location = \(myGTDLevel) name \(myTitle) new location = \(newLevel)")
            
            // Move the existing entries first
            var levelCount: Int = myGTDLevel + 1
            // Dirty workaround.  Set the level for the one we are moving to a so weirdwe can reset it at the end
            
            myDatabaseConnection.changeGTDLevel(myGTDLevel, newGTDLevel: -99, inTeamID: myTeamID)
            
            while levelCount <= newLevel
            {
                NSLog("Move level \(levelCount)")
                let nextLevel = levelCount - 1
                myDatabaseConnection.changeGTDLevel(levelCount, newGTDLevel: nextLevel, inTeamID: myTeamID)
                levelCount += 1
            }
            myDatabaseConnection.changeGTDLevel(-99, newGTDLevel: newLevel, inTeamID: myTeamID)
            
        }
    }
}

extension coreDatabase
{
    func saveGTDLevel(_ inGTDLevel: Int, inLevelName: String, inTeamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myGTD: GTDLevel!
        
        let myGTDItems = getGTDLevel(inGTDLevel, inTeamID: inTeamID)
        
        if myGTDItems.count == 0
        { // Add
            myGTD = GTDLevel(context: objectContext)
            myGTD.gTDLevel = inGTDLevel as NSNumber?
            myGTD.levelName = inLevelName
            myGTD.teamID = inTeamID as NSNumber?
            
            if inUpdateType == "CODE"
            {
                myGTD.updateType = "Add"
                myGTD.updateTime =  Date()
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
            myGTD.levelName = inLevelName
            if inUpdateType == "CODE"
            {
                myGTD.updateTime =  Date()
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
    
    func replaceGTDLevel(_ inGTDLevel: Int, inLevelName: String, inTeamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myGTD = GTDLevel(context: objectContext)
        myGTD.gTDLevel = inGTDLevel as NSNumber?
        myGTD.levelName = inLevelName
        myGTD.teamID = inTeamID as NSNumber?
        
        if inUpdateType == "CODE"
        {
            myGTD.updateType = "Add"
            myGTD.updateTime =  Date()
        }
        else
        {
            myGTD.updateTime = inUpdateTime
            myGTD.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func getGTDLevel(_ inGTDLevel: Int, inTeamID: Int)->[GTDLevel]
    {
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(inGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
    
    func changeGTDLevel(_ oldGTDLevel: Int, newGTDLevel: Int, inTeamID: Int)
    {
        var myGTD: GTDLevel!
        
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(oldGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            { // Update
                myGTD = fetchResults[0]
                //   myGTD.gTDLevel = newGTDLevel
                myGTD.setValue(newGTDLevel, forKey: "gTDLevel")
                myGTD.updateTime =  Date()
                if myGTD.updateType != "Add"
                {
                    myGTD.updateType = "Update"
                }
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func deleteGTDLevel(_ inGTDLevel: Int, inTeamID: Int)
    {
        var myGTD: GTDLevel!
        
        let myGTDItems = getGTDLevel(inGTDLevel, inTeamID: inTeamID)
        
        if myGTDItems.count > 0
        { // Update
            myGTD = myGTDItems[0]
            myGTD.updateTime =  Date()
            myGTD.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getGTDLevels(_ inTeamID: Int)->[GTDLevel]
    {
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "gTDLevel", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
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
   
    func clearDeletedGTDLevels(predicate: NSPredicate)
    {
        let fetchRequest26 = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Set the predicate on the fetch request
        fetchRequest26.predicate = predicate
        do
        {
            let fetchResults26 = try objectContext.fetch(fetchRequest26)
            for myItem26 in fetchResults26
            {
                objectContext.delete(myItem26 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedGTDLevels(predicate: NSPredicate)
    {
        let fetchRequest26 = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        // Set the predicate on the fetch request
        fetchRequest26.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults26 = try objectContext.fetch(fetchRequest26)
            for myItem26 in fetchResults26
            {
                myItem26.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func deleteAllGTDLevelRecords()
    {
        let fetchRequest2 = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
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
    
    func getGTDLevelsForSync(_ inLastSyncDate: NSDate) -> [GTDLevel]
    {
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
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
}

extension CloudKitInteraction
{
    func saveGTDLevelToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing GTDLevel")
        for myItem in myDatabaseConnection.getGTDLevelsForSync(inLastSyncDate)
        {
            saveGTDLevelRecordToCloudKit(myItem)
        }
    }

    func updateGTDLevelInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateGTDLevelRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteGTDLevel()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
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

    func replaceGTDLevelInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let gTDLevel = record.object(forKey: "gTDLevel") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object( forKey: "updateType") as! String
                let teamID = record.object(forKey: "teamID") as! Int
                let levelName = record.object(forKey: "levelName") as! String
                
                myDatabaseConnection.replaceGTDLevel(gTDLevel, inLevelName: levelName, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveGTDLevelRecordToCloudKit(_ sourceRecord: GTDLevel)
    {
        let predicate = NSPredicate(format: "(gTDLevel == \(sourceRecord.gTDLevel as! Int)) && (teamID == \(sourceRecord.teamID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "GTDLevel", predicate: predicate)
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
                    record!.setValue(sourceRecord.levelName, forKey: "levelName")
                    
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
                    let record = CKRecord(recordType: "GTDLevel")
                    record.setValue(sourceRecord.gTDLevel, forKey: "gTDLevel")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.levelName, forKey: "levelName")
                    
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

    func updateGTDLevelRecord(_ sourceRecord: CKRecord)
    {
        let gTDLevel = sourceRecord.object(forKey: "gTDLevel") as! Int
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
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        let levelName = sourceRecord.object(forKey: "levelName") as! String
        
        myDatabaseConnection.saveGTDLevel(gTDLevel, inLevelName: levelName, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }

}
