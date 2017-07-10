//
//  eventTemplateClass.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 23/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//


import Foundation
import CoreData
import CloudKit

class eventTemplates: NSObject
{
    fileprivate var myEventTemplate:[eventTemplate] = Array()
    
    init(eventID: Int, teamID: Int)
    {
        for myItem in myDatabaseConnection.getEventTemplateItems(eventID: eventID, teamID: teamID)
        {
            let myObject = eventTemplate(eventID: Int(myItem.eventID),
                                         role: myItem.role!,
                                         numRequired: Int(myItem.numRequired),
                                         dateModifier: Int(myItem.dateModifier),
                                         startTime: myItem.startTime! as Date,
                                         endTime: myItem.endTime! as Date,
                                         teamID: Int(myItem.teamID))
            
            myEventTemplate.append(myObject)
        }
    }
    
    var roles: [eventTemplate]?
    {
        get
        {
            return myEventTemplate
        }
    }
}

class eventTemplate: NSObject
{
    fileprivate var myEventID: Int = 0
    fileprivate var myRole: String = ""
    fileprivate var myNumRequired: Int = 0
    fileprivate var myDateModifier: Int = 0
    fileprivate var myStartTime: Date = getDefaultDate()
    fileprivate var myEndTime: Date = getDefaultDate()
    fileprivate var myTeamID: Int = 0

    var eventID: Int
    {
        get
        {
            return myEventID
        }
    }
    
    var role: String
    {
        get
        {
            return myRole
        }
    }

    var numRequired: Int
    {
        get
        {
            return myNumRequired
        }
        set
        {
            myNumRequired = newValue
            save()
        }
    }
    
    var dateModifier: Int
    {
        get
        {
            return myDateModifier
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
            save()
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
            save()
        }
    }
    
    init(eventID: Int,
         role: String,
         dateModifier: Int,
         startTime: Date,
         endTime: Date,
         teamID: Int)
    {
        super.init()
        
        myEventID = eventID
        myDateModifier = dateModifier
        myStartTime = startTime
        myEndTime = endTime
        myRole = role
        myTeamID = teamID
    }
    
    init(eventID: Int,
         role: String,
         numRequired: Int,
         dateModifier: Int,
         startTime: Date,
         endTime: Date,
         teamID: Int)
    {
        super.init()
        
        myEventID = eventID
        myRole = role
        myNumRequired = numRequired
        myDateModifier = dateModifier
        myStartTime = startTime
        myEndTime = endTime
        myTeamID = teamID
    }
    
    func save()
    {
        if currentUser.checkPermission(rosteringRoleType) == writePermission
        {
            myDatabaseConnection.saveEventTemplate(myEventID,
                                               role: myRole,
                                               numRequired: myNumRequired,
                                               dateModifier: myDateModifier,
                                               startTime: myStartTime,
                                               endTime: myEndTime,
                                               teamID: myTeamID)
        }
    }
    
    func delete()
    {
        if currentUser.checkPermission(rosteringRoleType) == writePermission
        {
            myDatabaseConnection.deleteEventTemplate(myEventID,
                                                 role: myRole,
                                                 dateModifier: myDateModifier,
                                                 startTime: myStartTime,
                                                 endTime: myEndTime,
                                                 teamID: myTeamID)
        }
    }
}

extension coreDatabase
{
    func saveEventTemplate(_ eventID: Int,
                       role: String,
                       numRequired: Int,
                       dateModifier: Int,
                       startTime: Date,
                       endTime: Date,
                       teamID: Int,
                       updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: EventTemplate!
        
        let myReturn = getEventTemplate(eventID: eventID,
                                        role: role,
                                        dateModifier: dateModifier,
                                        startTime: startTime,
                                        endTime: endTime,
                                        teamID: teamID)
        
        if myReturn.count == 0
        { // Add
            myItem = EventTemplate(context: objectContext)
            myItem.eventID = Int64(eventID)
            myItem.role = role
            myItem.numRequired = Int64(numRequired)
            myItem.dateModifier = Int64(dateModifier)
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
            myItem.numRequired = Int64(numRequired)
            
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

        self.recordsProcessed += 1
    }
    
    func deleteEventTemplate(_ eventID: Int,
                         role: String,
                         dateModifier: Int,
                         startTime: Date,
                         endTime: Date,
                         teamID: Int)
    {
        let myReturn = getEventTemplate(eventID: eventID,
                                        role: role,
                                        dateModifier: dateModifier,
                                        startTime: startTime,
                                        endTime: endTime,
                                        teamID: teamID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    
    func getEventTemplateItems(eventID: Int, teamID: Int)->[EventTemplate]
    {
        let fetchRequest = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "eventID == \(eventID) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
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

    func getEventTemplate(eventID: Int,
                      role: String,
                      dateModifier: Int,
                      startTime: Date,
                      endTime: Date,
                      teamID: Int)->[EventTemplate]
    {
        let fetchRequest = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(role == \"\(role)\") AND (eventID == \(eventID)) AND (dateModifier == \(dateModifier)) AND (teamID == \(teamID)) AND (startTime == %@) AND (endTime == %@) AND (updateType != \"Delete\")", startTime as CVarArg, endTime as CVarArg)
        
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
    
    func resetAllEventTemplate()
    {
        let fetchRequest = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
        
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
    
    func clearDeletedEventTemplate(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
        
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
    
    func clearSyncedEventTemplate(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
        
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
    
    func getEventTemplateForSync(_ syncDate: Date) -> [EventTemplate]
    {
        let fetchRequest = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
  
        
        
//let workingdate = Date().add(.hour, amount: -2)
//        
//        let predicate = NSPredicate(format: "(updateTime >= %@)", workingdate as CVarArg)
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
    
    func deleteAllEventTemplate()
    {
        let fetchRequest2 = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
        
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
    
    func quickFixEventTemplate()
    {
        let fetchRequest2 = NSFetchRequest<EventTemplate>(entityName: "EventTemplate")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                myItem2.role = "Steward"
                myItem2.updateTime = NSDate()
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: J \(error.localizedDescription)")
        }
    }
}

extension CloudKitInteraction
{
    func saveEventTemplateToCloudKit()
    {
        for myItem in myDatabaseConnection.getEventTemplateForSync(getSyncDateForTable(tableName: "EventTemplate"))
        {
            saveEventTemplateRecordToCloudKit(myItem)
        }
    }
    
    func updateEventTemplateInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "EventTemplate") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "EventTemplate", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)

        operation.recordFetchedBlock = { (record) in
            self.updateEventTemplateRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "EventTemplate", queryOperation: operation, onOperationQueue: operationQueue)
    }
    
//    func deleteEventTemplate(eventID: Int,
//                             role: String,
//                             dateModifier: Int,
//                             startTime: Date,
//                             endTime: Date)
//    {
//        let sem = DispatchSemaphore(value: 0);
//        
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (role == \"\(role)\") AND (eventID == \(eventID)) AND (dateModifier == \(dateModifier)) AND (startTime == %@) AND (endTime == %@)", startTime as CVarArg, endTime as CVarArg)
//        let query: CKQuery = CKQuery(recordType: "EventTemplate", predicate: predicate)
//        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
//            for record in results!
//            {
//                myRecordList.append(record.recordID)
//            }
//            self.performPublicDelete(myRecordList)
//            sem.signal()
//        })
//        
//        sem.wait()
//    }
    
    func saveEventTemplateRecordToCloudKit(_ sourceRecord: EventTemplate)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(teamID == \(sourceRecord.teamID)) AND (role == \"\(sourceRecord.role!)\") AND (eventID == \(sourceRecord.eventID)) AND (dateModifier == \(sourceRecord.dateModifier)) AND (startTime == %@) AND (endTime == %@)", sourceRecord.startTime!, sourceRecord.endTime!) // better be accurate to get only the record you need
        let query = CKQuery(recordType: "EventTemplate", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.numRequired, forKey: "numRequired")

                    
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
                            self.saveOK = false
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
                    let record = CKRecord(recordType: "EventTemplate")
                    record.setValue(sourceRecord.eventID, forKey: "eventID")
                    record.setValue(sourceRecord.role, forKey: "role")
                    record.setValue(sourceRecord.numRequired, forKey: "numRequired")
                    record.setValue(sourceRecord.dateModifier, forKey: "dateModifier")
                    record.setValue(sourceRecord.startTime, forKey: "startTime")
                    record.setValue(sourceRecord.endTime, forKey: "endTime")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: C \(saveError!.localizedDescription)")
                            self.saveOK = false
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
    
    func updateEventTemplateRecord(_ sourceRecord: CKRecord)
    {
        let role = sourceRecord.object(forKey: "role") as! String
        
        var eventID: Int = 0
        if sourceRecord.object(forKey: "eventID") != nil
        {
            eventID = sourceRecord.object(forKey: "eventID") as! Int
        }
        
        var numRequired: Int = 0
        if sourceRecord.object(forKey: "numRequired") != nil
        {
            numRequired = sourceRecord.object(forKey: "numRequired") as! Int
        }
        
        var dateModifier: Int = 0
        if sourceRecord.object(forKey: "dateModifier") != nil
        {
            dateModifier = sourceRecord.object(forKey: "dateModifier") as! Int
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
        
        myDatabaseConnection.recordsToChange += 1
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
        
        self.recordCount += 1
        
        myDatabaseConnection.saveEventTemplate(eventID,
                                               role: role,
                                               numRequired: numRequired,
                                               dateModifier: dateModifier,
                                               startTime: startTime,
                                               endTime: endTime,
                                               teamID: teamID
            , updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
}


