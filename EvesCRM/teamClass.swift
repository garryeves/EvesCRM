//
//  teamClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 27/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class team: NSObject
{
    fileprivate var myTeamID: Int32 = 0
    fileprivate var myName: String = "New"
    fileprivate var myNote: String = ""
    fileprivate var myStatus: String = ""
    fileprivate var myType: String = ""
    fileprivate var myPredecessor: Int32 = 0
    fileprivate var myExternalID: Int32 = 0
    fileprivate var myRoles: [Roles]!
    fileprivate var myStages:[Stages]!
    fileprivate var myGTD: [workingGTDLevel] = Array()
    fileprivate var myGTDTopLevel: [workingGTDItem] = Array()
    fileprivate var myContexts: [context] = Array()
    fileprivate var saveCalled: Bool = false
    
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
    
    var externalID: Int32
    {
        get
        {
            return myExternalID
        }
        set
        {
            myExternalID = newValue
            save()
        }
    }
    
    var type: String
    { // Type should be either "private" or "shared"
        get
        {
            return myType
        }
        set
        {
            myType = newValue
            save()
        }
    }

    var roles: [Roles]
    {
        get
        {
            return myRoles
        }
    }
    
    var stages: [Stages]
    {
        get
        {
            return myStages
        }
    }

    var GTDLevels: [workingGTDLevel]
    {
        get
        {
            return myGTD
        }
    }

    var GTDTopLevel: [workingGTDItem]
    {
        get
        {
            return myGTDTopLevel
        }
    }

    var contexts: [context]
    {
        get
        {
            return myContexts
        }
    }

    init(inTeamID: Int32)
    {
        super.init()
        
        // Load the details
        
        let myTeam = myDatabaseConnection.getTeam(inTeamID)
        
        for myItem in myTeam
        {
            myTeamID = myItem.teamID
            myName = myItem.name!
            myStatus = myItem.status!
            myType = myItem.type!
            myNote = myItem.note!
            myPredecessor = myItem.predecessor
            myExternalID = myItem.externalID
        }
 
        loadRoles()
        
        loadStages()
        
        loadGTDLevels()
        
        loadContexts()
    }

    override init()
    {
        super.init()
        
        let currentNumberofEntries = myDatabaseConnection.getTeamsCount()
        
        myTeamID = myDatabaseConnection.getNextID("Team")
        
        save()
        
        if currentNumberofEntries == 0
        {
            // Initial load.  As belt and braces, in case updating from previous version of the database, Initialise any existing tables with this team ID
            
            myDatabaseConnection.initialiseTeamForContext(myTeamID)
            myDatabaseConnection.initialiseTeamForMeetingAgenda(myTeamID)
            myDatabaseConnection.initialiseTeamForProject(myTeamID)
            myDatabaseConnection.initialiseTeamForRoles(myTeamID)
            myDatabaseConnection.initialiseTeamForStages(myTeamID)
            myDatabaseConnection.initialiseTeamForTask(myTeamID)
        }
        
        createGTDLevels()
        
        createRoles()
        
        createStages()

        loadRoles()
        
        loadStages()
        
        loadGTDLevels()
    }
    
    fileprivate func createGTDLevels()
    {
        // Create Initial GTD Levels
        
        myDatabaseConnection.saveGTDLevel(1, inLevelName: "Purpose and Core Values", inTeamID: myTeamID)
        myDatabaseConnection.saveGTDLevel(2, inLevelName: "Vision", inTeamID: myTeamID)
        myDatabaseConnection.saveGTDLevel(3, inLevelName: "Goals and Objectives", inTeamID: myTeamID)
        myDatabaseConnection.saveGTDLevel(4, inLevelName: "Areas of Responsibility", inTeamID: myTeamID)
    }
    
    fileprivate func createRoles()
    {
        if myDatabaseConnection.getRoles(myTeamID).count == 0
        {
            // There are no roles defined so we need to go in and create them
            
            populateRoles(myTeamID)
        }
    }
    
    fileprivate func createStages()
    {
        if myDatabaseConnection.getStages(myTeamID).count == 0
        {
            // There are no roles defined so we need to go in and create them
            
            populateStages(myTeamID)
        }
    }
    
    func loadRoles()
    {
        myRoles = myDatabaseConnection.getRoles(myTeamID)
    }
    
    func loadStages()
    {
        myStages = myDatabaseConnection.getVisibleStages(myTeamID)
    }
    
    func loadGTDLevels()
    {
        myGTD.removeAll()
        for myItem in myDatabaseConnection.getGTDLevels(myTeamID)
        {
            let myWorkingLevel = workingGTDLevel(inGTDLevel: myItem.gTDLevel, inTeamID: myTeamID)
            myGTD.append(myWorkingLevel)
        }

        loadGTDTopLevel()
    }
    
    func loadGTDTopLevel()
    {
        myGTDTopLevel.removeAll()
        for myItem in myDatabaseConnection.getGTDItemsForLevel(1, inTeamID: myTeamID)
        {
            let myWorkingLevel = workingGTDItem(inGTDItemID: myItem.gTDItemID, inTeamID: myTeamID)
            myGTDTopLevel.append(myWorkingLevel)
        }
    }
    
    func loadContexts()
    {
        myContexts.removeAll()
        for myItem in myDatabaseConnection.getContexts(myTeamID)
        {
            let myWorkingContext = context(inContext: myItem)
            myContexts.append(myWorkingContext)
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveTeam(myTeamID, inName: myName, inStatus: myStatus, inNote: myNote, inType: myType, inPredecessor: myPredecessor, inExternalID: myExternalID)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myTeam = myDatabaseConnection.getTeam(myTeamID)[0]
    
        myCloudDB.saveTeamRecordToCloudKit(myTeam)
        
        saveCalled = false
    }
}

extension coreDatabase
{
    func clearDeletedTeam(predicate: NSPredicate)
    {
        let fetchRequest22 = NSFetchRequest<Team>(entityName: "Team")
        
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        do
        {
            let fetchResults22 = try objectContext.fetch(fetchRequest22)
            for myItem22 in fetchResults22
            {
                objectContext.delete(myItem22 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedTeam(predicate: NSPredicate)
    {
        let fetchRequest22 = NSFetchRequest<Team>(entityName: "Team")
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults22 = try objectContext.fetch(fetchRequest22)
            for myItem22 in fetchResults22
            {
                myItem22.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func saveTeam(_ inTeamID: Int32, inName: String, inStatus: String, inNote: String, inType: String, inPredecessor: Int32, inExternalID: Int32, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myTeam: Team!
        
        let myTeams = getTeam(inTeamID)
        
        if myTeams.count == 0
        { // Add
            myTeam = Team(context: objectContext)
            myTeam.teamID = inTeamID
            myTeam.name = inName
            myTeam.status = inStatus
            myTeam.note = inNote
            myTeam.type = inType
            myTeam.predecessor = inPredecessor
            myTeam.externalID = inExternalID
            if inUpdateType == "CODE"
            {
                myTeam.updateTime =  NSDate()
                myTeam.updateType = "Add"
            }
            else
            {
                myTeam.updateTime = inUpdateTime as NSDate
                myTeam.updateType = inUpdateType
            }
        }
        else
        { // Update
            myTeam = myTeams[0]
            myTeam.name = inName
            myTeam.status = inStatus
            myTeam.note = inNote
            myTeam.type = inType
            myTeam.predecessor = inPredecessor
            myTeam.externalID = inExternalID
            if inUpdateType == "CODE"
            {
                if myTeam.updateType != "Add"
                {
                    myTeam.updateType = "Update"
                }
                myTeam.updateTime =  NSDate()
            }
            else
            {
                myTeam.updateTime = inUpdateTime as NSDate
                myTeam.updateType = inUpdateType
            }
        }
        
        saveContext()
    }
    
    func replaceTeam(_ inTeamID: Int32, inName: String, inStatus: String, inNote: String, inType: String, inPredecessor: Int32, inExternalID: Int32, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myTeam = Team(context: persistentContainer.viewContext)
        myTeam.teamID = inTeamID
        myTeam.name = inName
        myTeam.status = inStatus
        myTeam.note = inNote
        myTeam.type = inType
        myTeam.predecessor = inPredecessor
        myTeam.externalID = inExternalID
        if inUpdateType == "CODE"
        {
            myTeam.updateTime =  NSDate()
            myTeam.updateType = "Add"
        }
        else
        {
            myTeam.updateTime = inUpdateTime as NSDate
            myTeam.updateType = inUpdateType
        }
        
        saveContext()
        self.refreshObject(myTeam)
    }
    
    func getTeam(_ inTeamID: Int32)->[Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
    
    func getAllTeams()->[Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
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
    
    func getMyTeams(_ myID: String)->[Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
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
    
    func getTeamsCount() -> Int
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        fetchRequest.shouldRefreshRefetchedObjects = true
        
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
    
    func deleteAllTeams()
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                objectContext.delete(myItem as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        deleteAllGTDLevelRecords()
    }
    
    func getTeamsForSync(_ syncDate: Date) -> [Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
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

    func deleteAllTeamRecords()
    {
        let fetchRequest22 = NSFetchRequest<Team>(entityName: "Team")
        
        do
        {
            let fetchResults22 = try objectContext.fetch(fetchRequest22)
            for myItem22 in fetchResults22
            {
                self.objectContext.delete(myItem22 as NSManagedObject)
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
    func saveTeamToCloudKit()
    {
        for myItem in myDatabaseConnection.getTeamsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Team"))
        {
            saveTeamRecordToCloudKit(myItem)
        }
    }
    
    func updateTeamInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", myDatabaseConnection.getSyncDateForTable(tableName: "Team") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateTeamRecord(record)
                usleep(100)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func deleteTeam()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
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

    func replaceTeamInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(value: true)
        
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let teamID = record.object(forKey: "teamID") as! Int32
                var updateTime = Date()
                if record.object(forKey: "updateTime") != nil
                {
                    updateTime = record.object(forKey: "updateTime") as! Date
                }
                let updateType = record.object(forKey: "updateType") as! String
                let name = record.object(forKey: "name") as! String
                let note = record.object(forKey: "note") as! String
                let status = record.object(forKey: "status") as! String
                let type = record.object(forKey: "type") as! String
                let predecessor = record.object(forKey: "predecessor") as! Int32
                let externalID = record.object(forKey: "externalID") as! Int32
                
                myDatabaseConnection.replaceTeam(teamID, inName: name, inStatus: status, inNote: note, inType: type, inPredecessor: predecessor, inExternalID: externalID, inUpdateTime: updateTime, inUpdateType: updateType)
                usleep(100)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func saveTeamRecordToCloudKit(_ sourceRecord: Team)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Team", predicate: predicate)
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
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.note, forKey: "note")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    record!.setValue(sourceRecord.type, forKey: "type")
                    record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record!.setValue(sourceRecord.externalID, forKey: "externalID")
                    
                    
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
                    let record = CKRecord(recordType: "Team")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.note, forKey: "note")
                    record.setValue(sourceRecord.status, forKey: "status")
                    record.setValue(sourceRecord.type, forKey: "type")
                    record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record.setValue(sourceRecord.externalID, forKey: "externalID")
                    
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
    
    func updateTeamRecord(_ sourceRecord: CKRecord)
    {
        let teamID = sourceRecord.object(forKey: "teamID") as! Int32
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
        let name = sourceRecord.object(forKey: "name") as! String
        let note = sourceRecord.object(forKey: "note") as! String
        let status = sourceRecord.object(forKey: "status") as! String
        let type = sourceRecord.object(forKey: "type") as! String
        let predecessor = sourceRecord.object(forKey: "predecessor") as! Int32
        let externalID = sourceRecord.object(forKey: "externalID") as! Int32
        
        myDatabaseConnection.saveTeam(teamID, inName: name, inStatus: status, inNote: note, inType: type, inPredecessor: predecessor, inExternalID: externalID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
}
