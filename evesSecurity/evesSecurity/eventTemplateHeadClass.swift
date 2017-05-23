//
//  EventTemplateHeadClass.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 23/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class eventTemplateHeads: NSObject
{
    fileprivate var myEventTemplateHead:[eventTemplateHead] = Array()
    
    init(teamID: Int)
    {
        for myItem in myDatabaseConnection.getEventTemplateHeadItems(teamID: teamID)
        {
            let myObject = eventTemplateHead(eventID: Int(myItem.eventID),
                                         eventName: myItem.eventName!,
                                         teamID: Int(myItem.teamID))
            
            myEventTemplateHead.append(myObject)
        }
    }
    
    var templates: [eventTemplateHead]
    {
        get
        {
            return myEventTemplateHead
        }
    }
}

class eventTemplateHead: NSObject
{
    fileprivate var myEventID: Int = 0
    fileprivate var myEventName: String = ""
    fileprivate var myTeamID: Int = 0
    fileprivate var myRoles: eventTemplates!
    
    var eventID: Int
    {
        get
        {
            return myEventID
        }
    }
    
    var eventName: String
    {
        get
        {
            return myEventName
        }
        set
        {
            myEventName = newValue
        }
    }
    
    var roles: eventTemplates?
    {
        get
        {
            return myRoles
        }
    }
    
    init(teamID: Int)
    {
        super.init()
        
        myEventID = myDatabaseConnection.getNextID("EventTemplateHead")
        myTeamID = teamID
        save()
    }
    
    init(eventID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getEventTemplateHead(eventID: eventID)
        
        for myItem in myReturn
        {
            myEventID = Int(myItem.eventID)
            myEventName = myItem.eventName!
            myTeamID = Int(myItem.teamID)
        }
    }
    
    init(eventID: Int,
         eventName: String,
         teamID: Int)
    {
        super.init()
        
        myEventID = eventID
        myEventName = eventName
        myTeamID = teamID
    }
    
    func save()
    {
        myDatabaseConnection.saveEventTemplateHead(myEventID,
                                               eventName: myEventName,
                                               teamID: myTeamID)
    }
    
    func delete()
    {
        myDatabaseConnection.deleteEventTemplateHead(myEventID)
    }
    
    func loadRoles()
    {
        myRoles = eventTemplates(eventID: myEventID)
    }
    
    func addRole(role: String,
                 numRequired: Int,
                 dateModifier: Int,
                 startTime: Date,
                 endTime: Date)
    {
        let newRole = eventTemplate(eventID: myEventID, role: role, dateModifier: dateModifier, startTime: startTime, endTime: endTime, teamID: myTeamID)
        newRole.numRequired = numRequired
        
        newRole.save()
    }
}

extension coreDatabase
{
    func saveEventTemplateHead(_ eventID: Int,
                           eventName: String,
                           teamID: Int,
                           updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: EventTemplateHead!
        
        let myReturn = getEventTemplateHead(eventID: eventID)
        
        if myReturn.count == 0
        { // Add
            myItem = EventTemplateHead(context: objectContext)
            myItem.eventID = Int64(eventID)
            myItem.eventName = eventName
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
            myItem.eventName = eventName
            
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
    
    func replaceEventTemplateHead(_ eventID: Int,
                           eventName: String,
                              teamID: Int,
                              updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = EventTemplateHead(context: objectContext)
        myItem.eventID = Int64(eventID)
        myItem.eventName = eventName
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
    
    func deleteEventTemplateHead(_ eventID: Int)
    {
        let myReturn = getEventTemplateHead(eventID: eventID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getEventTemplateHeadItems(teamID: Int)->[EventTemplateHead]
    {
        let fetchRequest = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "teamID == \(teamID)")
        
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
            print("Error occurred during execution: E \(error.localizedDescription)")
            return []
        }
    }

    
    func getEventTemplateHead(eventID: Int)->[EventTemplateHead]
    {
        let fetchRequest = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "eventID == \(eventID)")
        
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
            print("Error occurred during execution: E \(error.localizedDescription)")
            return []
        }
    }
    
    func resetAllEventTemplateHead()
    {
        let fetchRequest = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
        
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
            print("Error occurred during execution: F \(error.localizedDescription)")
        }
        
        saveContext()
    }
    
    func clearDeletedEventTemplateHead(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
        
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
            print("Error occurred during execution: G \(error.localizedDescription)")
        }
        saveContext()
    }
    
    func clearSyncedEventTemplateHead(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
        
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
            print("Error occurred during execution: H \(error.localizedDescription)")
        }
        
        saveContext()
    }
    
    func getEventTemplateHeadForSync(_ syncDate: Date) -> [EventTemplateHead]
    {
        let fetchRequest = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
        
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
            print("Error occurred during execution: I \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAllEventTemplateHead()
    {
        let fetchRequest2 = NSFetchRequest<EventTemplateHead>(entityName: "EventTemplateHead")
        
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
            print("Error occurred during execution: J \(error.localizedDescription)")
        }
        
        saveContext()
    }
}

extension CloudKitInteraction
{
    func saveEventTemplateHeadToCloudKit()
    {
        for myItem in myDatabaseConnection.getEventTemplateHeadForSync(myDatabaseConnection.getSyncDateForTable(tableName: "EventTemplateHead"))
        {
            saveEventTemplateHeadRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateEventTemplateHeadInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "EventTemplateHead") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "EventTemplateHead", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateEventTemplateHeadRecord(record)
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
    
    func deleteEventTemplateHead(eventID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (eventID == \(eventID))")
        let query: CKQuery = CKQuery(recordType: "EventTemplateHead", predicate: predicate)
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
    
    func replaceEventTemplateHeadInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "EventTemplateHead", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            
            let eventName = record.object(forKey: "eventName") as! String
            
            var eventID: Int = 0
            if record.object(forKey: "eventID") != nil
            {
                eventID = record.object(forKey: "eventID") as! Int
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
            
            var teamID: Int = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int
            }
            
            myDatabaseConnection.replaceEventTemplateHead(eventID,
                                                      eventName: eventName,
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
    
    func saveEventTemplateHeadRecordToCloudKit(_ sourceRecord: EventTemplateHead, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (eventID == \(sourceRecord.eventID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "EventTemplateHead", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: A \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.eventName, forKey: "eventName")
                    
                    
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: B \(saveError!.localizedDescription)")
                            print("next level = \(saveError!)")
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
                    let record = CKRecord(recordType: "EventTemplateHead")
                    record.setValue(sourceRecord.eventID, forKey: "eventID")
                    record.setValue(sourceRecord.eventName, forKey: "eventName")
                    record.setValue(teamID, forKey: "teamID")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: C \(saveError!.localizedDescription)")
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
    
    func updateEventTemplateHeadRecord(_ sourceRecord: CKRecord)
    {
        let eventName = sourceRecord.object(forKey: "eventName") as! String
        
        var eventID: Int = 0
        if sourceRecord.object(forKey: "eventID") != nil
        {
            eventID = sourceRecord.object(forKey: "eventID") as! Int
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
        
        myDatabaseConnection.saveEventTemplateHead(eventID,
                                               eventName: eventName,
                                               teamID: teamID
            , updateTime: updateTime, updateType: updateType)
    }
}



