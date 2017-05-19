//
//  shiftsClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class shifts: NSObject
{
    fileprivate var myShifts:[shift] = Array()
    
    init(personID: Int, searchFrom: Date, searchTo: Date)
    {
        for myItem in myDatabaseConnection.getShifts(personID: personID, searchFrom: searchFrom, searchTo: searchTo, teamID: currentUser.currentTeam!.teamID)
        {
            let myObject = shift(shiftID: Int(myItem.shiftID),
                                 projectID: Int(myItem.projectID),
                                 personID: Int(myItem.personID),
                                 workDate: myItem.workDate! as Date,
                                 dayOfWeek: myItem.dayOfWeek!,
                                 startTime: myItem.startTime! as Date,
                                 endTime: myItem.endTime! as Date,
                                 teamID: Int(myItem.teamID)
                                   )
            myShifts.append(myObject)
        }
    }
    
    init(projectID: Int, searchFrom: Date, searchTo: Date)
    {
        for myItem in myDatabaseConnection.getShifts(projectID: projectID, searchFrom: searchFrom, searchTo: searchTo, teamID: currentUser.currentTeam!.teamID)
        {
            let myObject = shift(shiftID: Int(myItem.shiftID),
                                 projectID: Int(myItem.projectID),
                                 personID: Int(myItem.personID),
                                 workDate: myItem.workDate! as Date,
                                 dayOfWeek: myItem.dayOfWeek!,
                                 startTime: myItem.startTime! as Date,
                                 endTime: myItem.endTime! as Date,
                                 teamID: Int(myItem.teamID)
            )
            myShifts.append(myObject)
        }
    }
    
    var shifts: [shift]
    {
        get
        {
            return myShifts
        }
    }
}

class shift: NSObject
{
    fileprivate var myShiftID: Int = 0
    fileprivate var myProjectID: Int = 0
    fileprivate var myPersonID: Int = 0
    fileprivate var myWorkDate: Date!
    fileprivate var myDayOfWeek: String = ""
    fileprivate var myStartTime: Date!
    fileprivate var myEndTime: Date!
    fileprivate var myTeamID: Int = 0
    
    var shiftID: Int
    {
        get
        {
            return myShiftID
        }
    }
    
    var projectID: Int
    {
        get
        {
            return myProjectID
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
    
    var workDate: Date
    {
        get
        {
            return myWorkDate
        }
    }
    
    var dayOfWeek: String
    {
        get
        {
            return myDayOfWeek
        }
    }
    
    var startTime: Date
    {
        get
        {
            return myStartTime
        }
        set
        {
            myStartTime = newValue
        }
    }
    
    var endTime: Date
    {
        get
        {
            return myEndTime
        }
        set
        {
            myEndTime = newValue
        }
    }
    
    init(projectID: Int, workDate: Date, teamID: Int)
    {
        super.init()
        
        myShiftID = myDatabaseConnection.getNextID("Shifts")
        myProjectID = projectID
        myTeamID = teamID
        
        
        myWorkDate = workDate
        
        // Determine the day of the week
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        myDayOfWeek = dateFormatter.string(from: workDate)
        
        save()
    }
    
    init(shiftID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getShiftDetails(shiftID)
        
        for myItem in myReturn
        {
            myShiftID = Int(myItem.shiftID)
            myProjectID = Int(myItem.projectID)
            myPersonID = Int(myItem.personID)
            myWorkDate = myItem.workDate! as Date
            myDayOfWeek = myItem.dayOfWeek!
            myStartTime = myItem.startTime! as Date
            myEndTime = myItem.endTime! as Date
            myTeamID = Int(myItem.teamID)
        }
    }
    
    init(shiftID: Int,
         projectID: Int,
         personID: Int,
         workDate: Date,
         dayOfWeek: String,
         startTime: Date,
         endTime: Date,
         teamID: Int
         )
    {
        super.init()
        
        myShiftID = shiftID
        myProjectID = projectID
        myPersonID = personID
        myWorkDate = workDate
        myDayOfWeek = dayOfWeek
        myStartTime = startTime
        myEndTime = endTime
        myTeamID = teamID
    }
    
    func save()
    {
        myDatabaseConnection.saveShifts(myShiftID,
                                        projectID: myProjectID,
                                        personID: myPersonID,
                                        workDate: myWorkDate,
                                        dayOfWeek: myDayOfWeek,
                                        startTime: myStartTime,
                                        endTime: myEndTime,
                                        teamID: myTeamID
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deleteShifts(myShiftID)
    }
}

extension coreDatabase
{
    func saveShifts(_ shiftID: Int,
                    projectID: Int,
                    personID: Int,
                    workDate: Date,
                    dayOfWeek: String,
                    startTime: Date,
                    endTime: Date,
                    teamID: Int,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Shifts!
        
        let myReturn = getShiftDetails(shiftID)
        
        if myReturn.count == 0
        { // Add
            myItem = Shifts(context: objectContext)
            myItem.shiftID = Int64(shiftID)
            myItem.projectID = Int64(projectID)
            myItem.personID = Int64(personID)
            myItem.workDate = workDate as NSDate
            myItem.dayOfWeek = dayOfWeek
            myItem.startTime = startTime as NSDate
            myItem.endTime = endTime as NSDate
            myItem.teamID = Int64(teamID)
            
            if updateType == "CODE"
            {
                myItem.updateTime =  NSDate()
                
                myItem.updateType = "Add"
            }
            else
            {
                myItem.updateTime = updateTime as NSDate
                myItem.updateType = updateType
            }
        }
        else
        {
            myItem = myReturn[0]
            myItem.personID = Int64(personID)
            myItem.dayOfWeek = dayOfWeek
            myItem.startTime = startTime as NSDate
            myItem.endTime = endTime as NSDate
            
            if updateType == "CODE"
            {
                myItem.updateTime =  NSDate()
                if myItem.updateType != "Add"
                {
                    myItem.updateType = "Update"
                }
            }
            else
            {
                myItem.updateTime = updateTime as NSDate
                myItem.updateType = updateType
            }
        }
        
        saveContext()
    }
    
    func replaceShifts(_ shiftID: Int,
                       projectID: Int,
                       personID: Int,
                       workDate: Date,
                       dayOfWeek: String,
                       startTime: Date,
                       endTime: Date,
                       teamID: Int,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = Shifts(context: objectContext)
        myItem.shiftID = Int64(shiftID)
        myItem.projectID = Int64(projectID)
        myItem.personID = Int64(personID)
        myItem.workDate = workDate as NSDate
        myItem.dayOfWeek = dayOfWeek
        myItem.startTime = startTime as NSDate
        myItem.endTime = endTime as NSDate
        myItem.teamID = Int64(teamID)
        
        if updateType == "CODE"
        {
            myItem.updateTime =  NSDate()
            myItem.updateType = "Add"
        }
        else
        {
            myItem.updateTime = updateTime as NSDate
            myItem.updateType = updateType
        }
        
        saveContext()
    }
    
    func deleteShifts(_ shiftID: Int)
    {
        let myReturn = getShiftDetails(shiftID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getShifts(personID: Int, searchFrom: Date, searchTo: Date, teamID: Int)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (workDate >= %@) AND (workDate <= %@) AND (teamID == \(teamID)) && (updateType != \"Delete\")", searchFrom as CVarArg, searchTo as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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
    
    func getShifts(projectID: Int, searchFrom: Date, searchTo: Date, teamID: Int)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (workDate >= %@) AND (workDate <= %@) AND (teamID == \(teamID)) && (updateType != \"Delete\")", searchFrom as CVarArg, searchTo as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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
    
    func getShiftDetails(_ shiftID: Int)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(shiftID == \(shiftID)) && (updateType != \"Delete\")")
        
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
    
    func resetAllShifts()
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
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
    
    func clearDeletedShifts(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Shifts>(entityName: "Shifts")
        
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
    
    func clearSyncedShifts(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Shifts>(entityName: "Shifts")
        
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
    
    func getShiftsForSync(_ syncDate: Date) -> [Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
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
    
    func deleteAllShifts()
    {
        let fetchRequest2 = NSFetchRequest<Shifts>(entityName: "Shifts")
        
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
}

extension CloudKitInteraction
{
    func saveShiftsToCloudKit()
    {
        for myItem in myDatabaseConnection.getShiftsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Shifts"))
        {
            saveShiftsRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateShiftsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "Shifts") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Shifts", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateShiftsRecord(record)
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
    
    func deleteShifts(shiftID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (shiftID == \(shiftID))")
        let query: CKQuery = CKQuery(recordType: "Shifts", predicate: predicate)
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
    
    func replaceShiftsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "Shifts", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let dayOfWeek = record.object(forKey: "dayOfWeek") as! String
            
            var shiftID: Int = 0
            if record.object(forKey: "shiftID") != nil
            {
                shiftID = record.object(forKey: "shiftID") as! Int
            }

            var projectID: Int = 0
            if record.object(forKey: "projectID") != nil
            {
                projectID = record.object(forKey: "projectID") as! Int
            }

            var personID: Int = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int
            }
            
            var workDate = Date()
            if record.object(forKey: "workDate") != nil
            {
                workDate = record.object(forKey: "workDate") as! Date
            }
            
            var startTime = Date()
            if record.object(forKey: "startTime") != nil
            {
                startTime = record.object(forKey: "startTime") as! Date
            }
            
            var endTime = Date()
            if record.object(forKey: "endTime") != nil
            {
                endTime = record.object(forKey: "endTime") as! Date
            }
            
            var teamID: Int = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int
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
            
            myDatabaseConnection.replaceShifts(shiftID,
                                               projectID: projectID,
                                               personID: personID,
                                               workDate: workDate,
                                               dayOfWeek: dayOfWeek,
                                               startTime: startTime,
                                               endTime: endTime,
                                               teamID: teamID
                                                , updateTime: updateTime, updateType: updateType)
            
            usleep(useconds_t(self.sleepTime))
        }
        
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }
    
    func saveShiftsRecordToCloudKit(_ sourceRecord: Shifts, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(shiftID == \(sourceRecord.shiftID)) AND \(buildTeamList(currentUser.userID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.personID, forKey: "personID")
                    record!.setValue(sourceRecord.startTime, forKey: "startTime")
                    record!.setValue(sourceRecord.endTime, forKey: "endTime")
                    
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
                    let record = CKRecord(recordType: "Shifts")
                    record.setValue(sourceRecord.shiftID, forKey: "shiftID")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.workDate, forKey: "workDate")
                    record.setValue(sourceRecord.dayOfWeek, forKey: "dayOfWeek")
                    record.setValue(sourceRecord.startTime, forKey: "startTime")
                    record.setValue(sourceRecord.endTime, forKey: "endTime")
                    
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

    func updateShiftsRecord(_ sourceRecord: CKRecord)
    {
        let dayOfWeek = sourceRecord.object(forKey: "dayOfWeek") as! String
        
        var shiftID: Int = 0
        if sourceRecord.object(forKey: "shiftID") != nil
        {
            shiftID = sourceRecord.object(forKey: "shiftID") as! Int
        }
        
        var projectID: Int = 0
        if sourceRecord.object(forKey: "projectID") != nil
        {
            projectID = sourceRecord.object(forKey: "projectID") as! Int
        }
        
        var personID: Int = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int
        }
        
        var workDate = Date()
        if sourceRecord.object(forKey: "workDate") != nil
        {
            workDate = sourceRecord.object(forKey: "workDate") as! Date
        }
        
        var startTime = Date()
        if sourceRecord.object(forKey: "startTime") != nil
        {
            startTime = sourceRecord.object(forKey: "startTime") as! Date
        }
        
        var endTime = Date()
        if sourceRecord.object(forKey: "endTime") != nil
        {
            endTime = sourceRecord.object(forKey: "endTime") as! Date
        }

        var updateTime = Date()
        if sourceRecord.object(forKey: "updateTime") != nil
        {
            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
        }
        
        var updateType: String = ""
        if sourceRecord.object(forKey: "updateType") != nil
        {
            updateType = sourceRecord.object(forKey: "updateType") as! String
        }
        
        var teamID: Int = 0
        if sourceRecord.object(forKey: "teamID") != nil
        {
            teamID = sourceRecord.object(forKey: "teamID") as! Int
        }
        
        myDatabaseConnection.saveShifts(shiftID,
                                        projectID: projectID,
                                        personID: personID,
                                        workDate: workDate,
                                        dayOfWeek: dayOfWeek,
                                        startTime: startTime,
                                        endTime: endTime,
                                        teamID: teamID
                                         , updateTime: updateTime, updateType: updateType)
    }
}

