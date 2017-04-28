//
//  meetingAttendeeClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class meetingAttendee
{
    fileprivate var myMeetingID: String = ""
    fileprivate var myName: String = ""
    fileprivate var myEmailAddress: String = ""
    fileprivate var myType: String = ""
    fileprivate var myStatus: String = ""
    fileprivate var saveCalled: Bool = false
    
    var name: String
    {
        get
        {
            return myName
        }
        set
        {
            myName = newValue
        }
    }
    
    var emailAddress: String
    {
        get
        {
            return myEmailAddress
        }
        set
        {
            myEmailAddress = newValue
        }
    }
    
    var type: String
    {
        get
        {
            return myType
        }
        set
        {
            myType = newValue
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
        }
    }
    
    var meetingID: String
    {
        get
        {
            return myMeetingID
        }
        set
        {
            myMeetingID = newValue
        }
    }
    
    func load(_ meetingID: String, name: String)
    {
        let myAttendees = myDatabaseConnection.checkMeetingsForAttendee(name, meetingID: meetingID)
        
        if myAttendees.count > 0
        {
            for myItem in myAttendees
            {
                myMeetingID = myItem.meetingID!
                myName = myItem.name!
                myEmailAddress = myItem.email!
                myType = myItem.type!
                myStatus = myItem.attendenceStatus!
            }
        }
    }
    
    func delete()
    {
        myDatabaseConnection.deleteAttendee(myMeetingID, name: myName)
    }
    
    func save()
    {
        myDatabaseConnection.saveAttendee(myMeetingID, name: myName, email: myEmailAddress,  type: myType, status: myStatus)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
        }
    }
    
    @objc func performSave()
    {
        let myMeeting = myDatabaseConnection.checkMeetingsForAttendee(myName, meetingID: myMeetingID)[0]
        
        myCloudDB.saveMeetingAttendeesRecordToCloudKit(myMeeting)
        
        saveCalled = false
    }
}

extension coreDatabase
{
    func loadAttendees(_ inMeetingID: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
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
    
    func loadMeetingsForAttendee(_ inAttendeeName: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name == \"\(inAttendeeName)\") && (updateType != \"Delete\")")
        
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
    
    func checkMeetingsForAttendee(_ attendeeName: String, meetingID: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name == \"\(attendeeName)\") && (updateType != \"Delete\") && (meetingID == \"\(meetingID)\")")
        
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
    
    func saveAttendee(_ meetingID: String, name: String, email: String,  type: String, status: String, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myPerson: MeetingAttendees!
        
        let myMeeting = checkMeetingsForAttendee(name, meetingID: meetingID)
        
        if myMeeting.count == 0
        {
            myPerson = MeetingAttendees(context: objectContext)
            myPerson.meetingID = meetingID
            myPerson.name = name
            myPerson.attendenceStatus = status
            myPerson.email = email
            myPerson.type = type
            if inUpdateType == "CODE"
            {
                myPerson.updateTime =  NSDate()
                myPerson.updateType = "Add"
            }
            else
            {
                myPerson.updateTime = inUpdateTime as NSDate
                myPerson.updateType = inUpdateType
            }
        }
        else
        {
            myPerson = myMeeting[0]
            myPerson.attendenceStatus = status
            myPerson.email = email
            myPerson.type = type
            if inUpdateType == "CODE"
            {
                myPerson.updateTime =  NSDate()
                if myPerson.updateType != "Add"
                {
                    myPerson.updateType = "Update"
                }
            }
            else
            {
                myPerson.updateTime = inUpdateTime as NSDate
                myPerson.updateType = inUpdateType
            }
        }
        
        saveContext()
    }
    
    func replaceAttendee(_ meetingID: String, name: String, email: String,  type: String, status: String, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myPerson = MeetingAttendees(context: objectContext)
        myPerson.meetingID = meetingID
        myPerson.name = name
        myPerson.attendenceStatus = status
        myPerson.email = email
        myPerson.type = type
        if inUpdateType == "CODE"
        {
            myPerson.updateTime =  NSDate()
            myPerson.updateType = "Add"
        }
        else
        {
            myPerson.updateTime = inUpdateTime as NSDate
            myPerson.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func deleteAttendee(_ meetingID: String, name: String)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") && (name == \"\(name)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myMeeting in fetchResults
            {
                myMeeting.updateTime =  NSDate()
                myMeeting.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func resetMeetingAttendees()
    {
        let fetchRequest2 = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myMeeting2 in fetchResults2
            {
                myMeeting2.updateTime =  NSDate()
                myMeeting2.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearDeletedMeetingAttendees(predicate: NSPredicate)
    {
        let fetchRequest7 = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Set the predicate on the fetch request
        fetchRequest7.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults7 = try objectContext.fetch(fetchRequest7)
            for myItem7 in fetchResults7
            {
                objectContext.delete(myItem7 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedMeetingAttendee(predicate: NSPredicate)
    {
        let fetchRequest7 = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Set the predicate on the fetch request
        fetchRequest7.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults7 = try objectContext.fetch(fetchRequest7)
            for myItem7 in fetchResults7
            {
                myItem7.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getMeetingAttendeesForSync(_ syncDate: Date) -> [MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
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

    func deleteAllMeetingAttendeeRecords()
    {
        let fetchRequest7 = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        
        do
        {
            let fetchResults7 = try objectContext.fetch(fetchRequest7)
            for myItem7 in fetchResults7
            {
                self.objectContext.delete(myItem7 as NSManagedObject)
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
    func saveMeetingAttendeesToCloudKit()
    {
        for myItem in myDatabaseConnection.getMeetingAttendeesForSync(myDatabaseConnection.getSyncDateForTable(tableName: "MeetingAttendees"))
        {
            saveMeetingAttendeesRecordToCloudKit(myItem)
        }
    }

    func updateMeetingAttendeesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", myDatabaseConnection.getSyncDateForTable(tableName: "MeetingAttendees") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAttendees", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateMeetingAttendeesRecord(record)
                usleep(100)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteMeetingAttendees()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingAttendees", predicate: predicate)
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

    func replaceMeetingAttendeesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingAttendees", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let meetingID = record.object(forKey: "meetingID") as! String
                let name  = record.object(forKey: "name") as! String
                var updateTime = Date()
                if record.object(forKey: "updateTime") != nil
                {
                    updateTime = record.object(forKey: "updateTime") as! Date
                }
                let updateType = record.object(forKey: "updateType") as! String
                let attendenceStatus = record.object(forKey: "attendenceStatus") as! String
                let email = record.object(forKey: "email") as! String
                let type = record.object(forKey: "type") as! String
                
                myDatabaseConnection.replaceAttendee(meetingID, name: name, email: email,  type: type, status: attendenceStatus, inUpdateTime: updateTime, inUpdateType: updateType)
                usleep(100)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveMeetingAttendeesRecordToCloudKit(_ sourceRecord: MeetingAttendees)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID!)\") && (name = \"\(sourceRecord.name!)\")") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "MeetingAttendees", predicate: predicate)
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
                    record!.setValue(sourceRecord.attendenceStatus, forKey: "attendenceStatus")
                    record!.setValue(sourceRecord.email, forKey: "email")
                    record!.setValue(sourceRecord.type, forKey: "type")
                    
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
                    let record = CKRecord(recordType: "MeetingAttendees")
                    record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                    record.setValue(sourceRecord.name, forKey: "name")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.attendenceStatus, forKey: "attendenceStatus")
                    record.setValue(sourceRecord.email, forKey: "email")
                    record.setValue(sourceRecord.type, forKey: "type")
                    
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

    func updateMeetingAttendeesRecord(_ sourceRecord: CKRecord)
    {
        let meetingID = sourceRecord.object(forKey: "meetingID") as! String
        let name  = sourceRecord.object(forKey: "name") as! String
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
        let attendenceStatus = sourceRecord.object(forKey: "attendenceStatus") as! String
        let email = sourceRecord.object(forKey: "email") as! String
        let type = sourceRecord.object(forKey: "type") as! String
        
        myDatabaseConnection.saveAttendee(meetingID, name: name, email: email,  type: type, status: attendenceStatus, inUpdateTime: updateTime, inUpdateType: updateType)
    }
}
