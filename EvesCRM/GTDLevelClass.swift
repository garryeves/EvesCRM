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
    
    init(sourceGTDLevel: Int, teamID: Int)
    {
        super.init()
        
        // Load the details
        
        let myGTDDetail = myDatabaseConnection.getGTDLevel(sourceGTDLevel, teamID: teamID)
        
        for myItem in myGTDDetail
        {
            myTitle = myItem.levelName!
            myTeamID = Int(myItem.teamID)
            myGTDLevel = sourceGTDLevel
        }
    }
    
    init(sourceGTDLevel: Int, levelName: String, teamID: Int)
    {
        super.init()
        
        myGTDLevel = sourceGTDLevel
        myTitle = levelName
        myTeamID = teamID
        
        save()
    }
    
    init(levelName: String, teamID: Int)
    {
        super.init()
        
        let myGTDDetail = myDatabaseConnection.getGTDLevels(teamID)
        
        myGTDLevel = Int(myGTDDetail.count + 1)
        myTeamID = teamID
        myTitle = levelName
        
        save()
    }
    
    func save()
    {
        myDatabaseConnection.saveGTDLevel(myGTDLevel, levelName: myTitle, teamID: myTeamID)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myGTD = myDatabaseConnection.getGTDLevel(myGTDLevel, teamID: myTeamID)[0]
        
        myCloudDB.saveGTDLevelRecordToCloudKit(myGTD, teamID: currentUser.currentTeam!.teamID)
        
        saveCalled = false
    }
    
    func delete()
    { // Delete the current GTD Level and move the remaining ones up a level
        myDatabaseConnection.deleteGTDLevel(myGTDLevel, teamID: myTeamID)
        
        var currentLevel = myGTDLevel
        var boolLoop: Bool = true
        
        while boolLoop
        {
            let tempLevel = myDatabaseConnection.getGTDLevel(currentLevel + 1, teamID: myTeamID)
            
            if tempLevel.count == 0
            {  // reached the end, so do nothing
                boolLoop = false
            }
            else
            {  // There is another level so need to decrement the level count
                myDatabaseConnection.changeGTDLevel(currentLevel + 1, newGTDLevel: currentLevel, teamID: myTeamID)
                
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
            
            myDatabaseConnection.changeGTDLevel(myGTDLevel, newGTDLevel: -99, teamID: myTeamID)
            
            while levelCount >= newLevel
            {
                NSLog("Move level \(levelCount)")
                let nextLevel = levelCount + 1
                myDatabaseConnection.changeGTDLevel(levelCount, newGTDLevel: nextLevel, teamID: myTeamID)
                levelCount -= 1
            }
            myDatabaseConnection.changeGTDLevel(-99, newGTDLevel: newLevel, teamID: myTeamID)
        }
        else
        {
            NSLog("Moving down from location = \(myGTDLevel) name \(myTitle) new location = \(newLevel)")
            
            // Move the existing entries first
            var levelCount: Int = myGTDLevel + Int(1)
            
            // Dirty workaround.  Set the level for the one we are moving to a so weirdwe can reset it at the end
            
            myDatabaseConnection.changeGTDLevel(myGTDLevel, newGTDLevel: -99, teamID: myTeamID)
            
            while levelCount <= newLevel
            {
                NSLog("Move level \(levelCount)")
                let nextLevel = levelCount - 1
                myDatabaseConnection.changeGTDLevel(levelCount, newGTDLevel: nextLevel, teamID: myTeamID)
                levelCount += 1
            }
            myDatabaseConnection.changeGTDLevel(-99, newGTDLevel: newLevel, teamID: myTeamID)
            
        }
    }
}

extension coreDatabase
{
    func saveGTDLevel(_ sourceGTDLevel: Int, levelName: String, teamID: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myGTD: GTDLevel!
        
        let myGTDItems = getGTDLevel(sourceGTDLevel, teamID: teamID)
        
        if myGTDItems.count == 0
        { // Add
            myGTD = GTDLevel(context: objectContext)
            myGTD.gTDLevel = Int64(sourceGTDLevel)
            myGTD.levelName = levelName
            myGTD.teamID = Int64(teamID)
            
            if updateType == "CODE"
            {
                myGTD.updateType = "Add"
                myGTD.updateTime =  NSDate()
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
            myGTD.levelName = levelName
            if updateType == "CODE"
            {
                myGTD.updateTime =  NSDate()
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
    
    func replaceGTDLevel(_ sourceGTDLevel: Int, levelName: String, teamID: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myGTD = GTDLevel(context: objectContext)
        myGTD.gTDLevel = Int64(sourceGTDLevel)
        myGTD.levelName = levelName
        myGTD.teamID = Int64(teamID)
        
        if updateType == "CODE"
        {
            myGTD.updateType = "Add"
            myGTD.updateTime =  NSDate()
        }
        else
        {
            myGTD.updateTime = updateTime as NSDate
            myGTD.updateType = updateType
        }
        
        saveContext()
    }
    
    func getGTDLevel(_ sourceGTDLevel: Int, teamID: Int)->[GTDLevel]
    {
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(sourceGTDLevel)) && (updateType != \"Delete\") && (teamID == \(teamID))")
        
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
    
    func changeGTDLevel(_ oldGTDLevel: Int, newGTDLevel: Int, teamID: Int)
    {
        var myGTD: GTDLevel!
        
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(oldGTDLevel)) && (updateType != \"Delete\") && (teamID == \(teamID))")
        
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
                myGTD.updateTime =  NSDate()
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
    
    func deleteGTDLevel(_ sourceGTDLevel: Int, teamID: Int)
    {
        var myGTD: GTDLevel!
        
        let myGTDItems = getGTDLevel(sourceGTDLevel, teamID: teamID)
        
        if myGTDItems.count > 0
        { // Update
            myGTD = myGTDItems[0]
            myGTD.updateTime =  NSDate()
            myGTD.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getGTDLevels(_ teamID: Int)->[GTDLevel]
    {
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID))")
        
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
    
    func getGTDLevelsForSync(_ syncDate: Date) -> [GTDLevel]
    {
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
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
}

extension CloudKitInteraction
{
    func saveGTDLevelToCloudKit()
    {
        for myItem in myDatabaseConnection.getGTDLevelsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "GTDLevel"))
        {
            saveGTDLevelRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }

    func updateGTDLevelInCoreData(teamID: Int)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(teamID))", myDatabaseConnection.getSyncDateForTable(tableName: "GTDLevel") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1

            self.updateGTDLevelRecord(record)
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

    func deleteGTDLevel(teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
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

    func replaceGTDLevelInCoreData(teamID: Int)
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let gTDLevel = record.object(forKey: "gTDLevel") as! Int
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
            let teamID = record.object(forKey: "teamID") as! Int
            let levelName = record.object(forKey: "levelName") as! String
            
            myDatabaseConnection.replaceGTDLevel(gTDLevel, levelName: levelName, teamID: teamID, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveGTDLevelRecordToCloudKit(_ sourceRecord: GTDLevel, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(gTDLevel == \(sourceRecord.gTDLevel)) && (teamID == \(sourceRecord.teamID)) AND (teamID == \(teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "GTDLevel", predicate: predicate)
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
                    record!.setValue(sourceRecord.levelName, forKey: "levelName")
                    
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
                    let record = CKRecord(recordType: "GTDLevel")
                    record.setValue(sourceRecord.gTDLevel, forKey: "gTDLevel")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.levelName, forKey: "levelName")
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
        
        myDatabaseConnection.saveGTDLevel(gTDLevel, levelName: levelName, teamID: teamID, updateTime: updateTime, updateType: updateType)
    }

}
