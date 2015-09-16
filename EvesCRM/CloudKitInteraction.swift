//
//  CloudKitInteraction.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 15/09/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

protocol ModelDelegate {
    func errorUpdating(error: NSError)
    func modelUpdated()
}

class CloudKitInteraction
{
    let userInfo : UserInfo
    let container : CKContainer
    let publicDB : CKDatabase
    let privateDB : CKDatabase
    
    init()
    {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase // data saved here can be seen by all users
        privateDB = container.privateCloudDatabase // this is the one to use to save the data
        
        userInfo = UserInfo(container: container)
    }
    
    func saveContextToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing Contexts")
        for myItem in myDatabaseConnection.getContextsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(contextID == \(myItem.contextID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Context", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.autoEmail, forKey: "autoEmail")
                        record!.setValue(myItem.email, forKey: "email")
                        record!.setValue(myItem.name, forKey: "name")
                        record!.setValue(myItem.parentContext, forKey: "parentContext")
                        record!.setValue(myItem.personID, forKey: "personID")
                        record!.setValue(myItem.status, forKey: "status")
                        record!.setValue(myItem.teamID, forKey: "teamID")
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "Context")
                        record.setValue(myItem.contextID, forKey: "contextID")
                        record.setValue(myItem.autoEmail, forKey: "autoEmail")
                        record.setValue(myItem.email, forKey: "email")
                        record.setValue(myItem.name, forKey: "name")
                        record.setValue(myItem.parentContext, forKey: "parentContext")
                        record.setValue(myItem.personID, forKey: "personID")
                        record.setValue(myItem.status, forKey: "status")
                        record.setValue(myItem.teamID, forKey: "teamID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")

                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
        
        for myItem in myDatabaseConnection.getContexts1_1ForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(contextID == \(myItem.contextID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Context", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.predecessor, forKey: "predecessor")
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                }
            })
            
            sleep(1)
        }
    }

    func saveDecodesToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing Decodes")
        for myItem in myDatabaseConnection.getDecodesForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(decode_name == \"\(myItem.decode_name)\")") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Decodes", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.decode_value, forKey: "decode_value")
                        record!.setValue(myItem.decodeType, forKey: "decodeType")
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let todoRecord = CKRecord(recordType: "Decodes")
                        todoRecord.setValue(myItem.decode_name, forKey: "decode_name")
                        todoRecord.setValue(myItem.decodeType, forKey: "decodeType")
                        todoRecord.setValue(myItem.decode_value, forKey: "decode_value")
                        todoRecord.setValue(myItem.updateTime, forKey: "updateTime")
                        todoRecord.setValue(myItem.updateType, forKey: "updateType")
                        
                        self.privateDB.saveRecord(todoRecord, completionHandler: { (savedRecord, saveError) in
                            if saveError != nil
                            {
                                NSLog("Error saving record: \(saveError!.localizedDescription)")
                            }
                            else
                            {
                                if debugMessages
                                {
                                NSLog("Successfully saved record! \(myItem.decode_name)")
                                }
                            }
                        })
                    }
                }
            })

            sleep(1)
        }
    }

    func saveGTDItemToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing GTDItem")
        for myItem in myDatabaseConnection.getGTDItemsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(gTDItemID == \(myItem.gTDItemID as! Int))")
            let query = CKQuery(recordType: "GTDItem", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.gTDParentID, forKey: "gTDParentID")
                        record!.setValue(myItem.lastReviewDate, forKey: "lastReviewDate")
                        record!.setValue(myItem.note, forKey: "note")
                        record!.setValue(myItem.predecessor, forKey: "predecessor")
                        record!.setValue(myItem.reviewFrequency, forKey: "reviewFrequency")
                        record!.setValue(myItem.reviewPeriod, forKey: "reviewPeriod")
                        record!.setValue(myItem.status, forKey: "status")
                        record!.setValue(myItem.teamID, forKey: "teamID")
                        record!.setValue(myItem.title, forKey: "title")
                        record!.setValue(myItem.gTDLevel, forKey: "gTDLevel")

                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        record.setValue(myItem.gTDItemID, forKey: "gTDItemID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.gTDParentID, forKey: "gTDParentID")
                        record.setValue(myItem.lastReviewDate, forKey: "lastReviewDate")
                        record.setValue(myItem.note, forKey: "note")
                        record.setValue(myItem.predecessor, forKey: "predecessor")
                        record.setValue(myItem.reviewFrequency, forKey: "reviewFrequency")
                        record.setValue(myItem.reviewPeriod, forKey: "reviewPeriod")
                        record.setValue(myItem.status, forKey: "status")
                        record.setValue(myItem.teamID, forKey: "teamID")
                        record.setValue(myItem.title, forKey: "title")
                        record.setValue(myItem.gTDLevel, forKey: "gTDLevel")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveGTDLevelToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing GTDLevel")
        for myItem in myDatabaseConnection.getGTDLevelsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(gTDLevel == \(myItem.gTDLevel as! Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "GTDLevel", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.teamID, forKey: "teamID")
                        record!.setValue(myItem.levelName, forKey: "levelName")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        record.setValue(myItem.gTDLevel, forKey: "gTDLevel")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.teamID, forKey: "teamID")
                        record.setValue(myItem.levelName, forKey: "levelName")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }

    func saveMeetingAgendaToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing Meeting Agenda")
        for myItem in myDatabaseConnection.getMeetingAgendasForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(meetingID == \"\(myItem.meetingID)\")") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.chair, forKey: "chair")
                        record!.setValue(myItem.endTime, forKey: "endTime")
                        record!.setValue(myItem.location, forKey: "location")
                        record!.setValue(myItem.minutes, forKey: "minutes")
                        record!.setValue(myItem.minutesType, forKey: "minutesType")
                        record!.setValue(myItem.name, forKey: "name")
                        record!.setValue(myItem.previousMeetingID, forKey: "previousMeetingID")
                        record!.setValue(myItem.startTime, forKey: "startTime")
                        record!.setValue(myItem.teamID, forKey: "teamID")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "MeetingAgenda")
                        record.setValue(myItem.meetingID, forKey: "meetingID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.chair, forKey: "chair")
                        record.setValue(myItem.endTime, forKey: "endTime")
                        record.setValue(myItem.location, forKey: "location")
                        record.setValue(myItem.minutes, forKey: "minutes")
                        record.setValue(myItem.minutesType, forKey: "minutesType")
                        record.setValue(myItem.name, forKey: "name")
                        record.setValue(myItem.previousMeetingID, forKey: "previousMeetingID")
                        record.setValue(myItem.startTime, forKey: "startTime")
                        record.setValue(myItem.teamID, forKey: "teamID")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveMeetingAgendaItemToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing meetingAgendaItems")
        for myItem in myDatabaseConnection.getMeetingAgendaItemsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(meetingID == \"\(myItem.meetingID)\") && (agendaID == \(myItem.agendaID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.actualEndTime, forKey: "actualEndTime")
                        record!.setValue(myItem.actualStartTime, forKey: "actualStartTime")
                        record!.setValue(myItem.decisionMade, forKey: "decisionMade")
                        record!.setValue(myItem.discussionNotes, forKey: "discussionNotes")
                        record!.setValue(myItem.owner, forKey: "owner")
                        record!.setValue(myItem.status, forKey: "status")
                        record!.setValue(myItem.timeAllocation, forKey: "timeAllocation")
                        record!.setValue(myItem.title, forKey: "title")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "MeetingAgendaItem")
                        record.setValue(myItem.meetingID, forKey: "meetingID")
                        record.setValue(myItem.agendaID, forKey: "agendaID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.actualEndTime, forKey: "actualEndTime")
                        record.setValue(myItem.actualStartTime, forKey: "actualStartTime")
                        record.setValue(myItem.decisionMade, forKey: "decisionMade")
                        record.setValue(myItem.discussionNotes, forKey: "discussionNotes")
                        record.setValue(myItem.owner, forKey: "owner")
                        record.setValue(myItem.status, forKey: "status")
                        record.setValue(myItem.timeAllocation, forKey: "timeAllocation")
                        record.setValue(myItem.title, forKey: "title")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveMeetingAttendeesToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing MeetingAttendees")
        for myItem in myDatabaseConnection.getMeetingAttendeesForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(meetingID == \"\(myItem.meetingID)\") && (name = \"\(myItem.name)\")") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "MeetingAttendees", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.attendenceStatus, forKey: "attendenceStatus")
                        record!.setValue(myItem.email, forKey: "email")
                        record!.setValue(myItem.type, forKey: "type")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        record.setValue(myItem.meetingID, forKey: "meetingID")
                        record.setValue(myItem.name, forKey: "name")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.attendenceStatus, forKey: "attendenceStatus")
                        record.setValue(myItem.email, forKey: "email")
                        record.setValue(myItem.type, forKey: "type")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveMeetingSupportingDocsToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing MeetingSupportingDocs")
        for myItem in myDatabaseConnection.getMeetingSupportingDocsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(meetingID == \"\(myItem.meetingID)\") && (agendaID == \(myItem.agendaID as Int))") // better be accurate to get only the
            let query = CKQuery(recordType: "MeetingSupportingDocs", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.attachmentPath, forKey: "attachmentPath")
                        record!.setValue(myItem.title, forKey: "title")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "MeetingSupportingDocs")
                        record.setValue(myItem.meetingID, forKey: "meetingID")
                        record.setValue(myItem.agendaID, forKey: "agendaID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.attachmentPath, forKey: "attachmentPath")
                        record.setValue(myItem.title, forKey: "title")

                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveMeetingTasksToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing MeetingTasks")
        for myItem in myDatabaseConnection.getMeetingTasksForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(meetingID == \"\(myItem.meetingID)\") && (agendaID == \(myItem.agendaID as Int)) && (taskID == \(myItem.taskID as Int))") // better be accurate to get only the
            let query = CKQuery(recordType: "MeetingTasks", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.taskID, forKey: "taskID")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "MeetingTasks")
                        record.setValue(myItem.meetingID, forKey: "meetingID")
                        record.setValue(myItem.agendaID, forKey: "agendaID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.taskID, forKey: "taskID")

                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func savePanesToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing Panes")
        for myItem in myDatabaseConnection.getPanesForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(pane_name == \"\(myItem.pane_name)\")") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Panes", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.pane_available, forKey: "pane_available")
                        record!.setValue(myItem.pane_order, forKey: "pane_order")
                        record!.setValue(myItem.pane_visible, forKey: "pane_visible")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        record.setValue(myItem.pane_name, forKey: "pane_name")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.pane_available, forKey: "pane_available")
                        record.setValue(myItem.pane_order, forKey: "pane_order")
                        record.setValue(myItem.pane_visible, forKey: "pane_visible")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveProjectsToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing Projects")
        for myItem in myDatabaseConnection.getProjectsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(projectID == \(myItem.projectID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Projects", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.areaID, forKey: "areaID")
                        record!.setValue(myItem.lastReviewDate, forKey: "lastReviewDate")
                        record!.setValue(myItem.projectEndDate, forKey: "projectEndDate")
                        record!.setValue(myItem.projectName, forKey: "projectName")
                        record!.setValue(myItem.projectStartDate, forKey: "projectStartDate")
                        record!.setValue(myItem.projectStatus, forKey: "projectStatus")
                        record!.setValue(myItem.repeatBase, forKey: "repeatBase")
                        record!.setValue(myItem.repeatInterval, forKey: "repeatInterval")
                        record!.setValue(myItem.repeatType, forKey: "repeatType")
                        record!.setValue(myItem.reviewFrequency, forKey: "reviewFrequency")
                        record!.setValue(myItem.teamID, forKey: "teamID")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "Projects")
                        record.setValue(myItem.projectID, forKey: "projectID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.areaID, forKey: "areaID")
                        record.setValue(myItem.lastReviewDate, forKey: "lastReviewDate")
                        record.setValue(myItem.projectEndDate, forKey: "projectEndDate")
                        record.setValue(myItem.projectName, forKey: "projectName")
                        record.setValue(myItem.projectStartDate, forKey: "projectStartDate")
                        record.setValue(myItem.projectStatus, forKey: "projectStatus")
                        record.setValue(myItem.repeatBase, forKey: "repeatBase")
                        record.setValue(myItem.repeatInterval, forKey: "repeatInterval")
                        record.setValue(myItem.repeatType, forKey: "repeatType")
                        record.setValue(myItem.reviewFrequency, forKey: "reviewFrequency")
                        record.setValue(myItem.teamID, forKey: "teamID")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
        
        for myItem in myDatabaseConnection.getProjectNotesForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(projectID == \(myItem.projectID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Projects", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.note, forKey: "note")
                        record!.setValue(myItem.reviewPeriod, forKey: "reviewPeriod")
                        record!.setValue(myItem.predecessor, forKey: "predecessor")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                }
            })
            
            sleep(1)
        }
    }
    
    func saveProjectTeamMembersToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing ProjectTeamMembers")
        for myItem in myDatabaseConnection.getProjectTeamMembersForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(projectID == \(myItem.projectID as Int)) && (teamMember == \"\(myItem.teamMember)\")") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.roleID, forKey: "roleID")
                        record!.setValue(myItem.projectMemberNotes, forKey: "projectMemberNotes")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "ProjectTeamMembers")
                        record.setValue(myItem.projectID, forKey: "projectID")
                        record.setValue(myItem.teamMember, forKey: "teamMember")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.roleID, forKey: "roleID")
                        record.setValue(myItem.projectMemberNotes, forKey: "projectMemberNotes")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveRolesToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing Roles")
        for myItem in myDatabaseConnection.getRolesForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(roleID == \(myItem.roleID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Roles", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.teamID, forKey: "teamID")
                        record!.setValue(myItem.roleDescription, forKey: "roleDescription")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "Roles")
                        record.setValue(myItem.roleID, forKey: "roleID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.teamID, forKey: "teamID")
                        record.setValue(myItem.roleDescription, forKey: "roleDescription")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveStagesToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing Stages")
        for myItem in myDatabaseConnection.getStagesForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(stageDescription == \"\(myItem.stageDescription)\")") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Stages", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.teamID, forKey: "teamID")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "Stages")
                        record.setValue(myItem.stageDescription, forKey: "stageDescription")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.teamID, forKey: "teamID")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveTaskToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing Task")
        for myItem in myDatabaseConnection.getTaskForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(taskID == \(myItem.taskID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Task", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.completionDate, forKey: "completionDate")
                        record!.setValue(myItem.details, forKey: "details")
                        record!.setValue(myItem.dueDate, forKey: "dueDate")
                        record!.setValue(myItem.energyLevel, forKey: "energyLevel")
                        record!.setValue(myItem.estimatedTime, forKey: "estimatedTime")
                        record!.setValue(myItem.estimatedTimeType, forKey: "estimatedTimeType")
                        record!.setValue(myItem.flagged, forKey: "flagged")
                        record!.setValue(myItem.priority, forKey: "priority")
                        record!.setValue(myItem.repeatBase, forKey: "repeatBase")
                        record!.setValue(myItem.repeatInterval, forKey: "repeatInterval")
                        record!.setValue(myItem.repeatType, forKey: "repeatType")
                        record!.setValue(myItem.startDate, forKey: "startDate")
                        record!.setValue(myItem.status, forKey: "status")
                        record!.setValue(myItem.teamID, forKey: "teamID")
                        record!.setValue(myItem.title, forKey: "title")
                        record!.setValue(myItem.urgency, forKey: "urgency")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "Task")
                        record.setValue(myItem.taskID, forKey: "taskID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.completionDate, forKey: "completionDate")
                        record.setValue(myItem.details, forKey: "details")
                        record.setValue(myItem.dueDate, forKey: "dueDate")
                        record.setValue(myItem.energyLevel, forKey: "energyLevel")
                        record.setValue(myItem.estimatedTime, forKey: "estimatedTime")
                        record.setValue(myItem.estimatedTimeType, forKey: "estimatedTimeType")
                        record.setValue(myItem.flagged, forKey: "flagged")
                        record.setValue(myItem.priority, forKey: "priority")
                        record.setValue(myItem.repeatBase, forKey: "repeatBase")
                        record.setValue(myItem.repeatInterval, forKey: "repeatInterval")
                        record.setValue(myItem.repeatType, forKey: "repeatType")
                        record.setValue(myItem.startDate, forKey: "startDate")
                        record.setValue(myItem.status, forKey: "status")
                        record.setValue(myItem.teamID, forKey: "teamID")
                        record.setValue(myItem.title, forKey: "title")
                        record.setValue(myItem.urgency, forKey: "urgency")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveTaskAttachmentToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing taskAttachments")
        for myItem in myDatabaseConnection.getTaskAttachmentsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(taskID == \(myItem.taskID as Int)) && (title == \"\(myItem.title)\")") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "TaskAttachment", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.attachment, forKey: "attachment")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "TaskAttachment")
                        record.setValue(myItem.taskID, forKey: "taskID")
                        record.setValue(myItem.title, forKey: "title")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.attachment, forKey: "attachment")

                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveTaskContextToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing TaskContext")
        for myItem in myDatabaseConnection.getTaskContextsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(taskID == \(myItem.taskID as Int)) && (contextID == \(myItem.contextID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "TaskContext", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "TaskContext")
                        record.setValue(myItem.taskID, forKey: "taskID")
                        record.setValue(myItem.contextID, forKey: "contextID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")

                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveTaskPredecessorToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing TaskPredecessor")
        for myItem in myDatabaseConnection.getTaskPredecessorsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(taskID == \(myItem.taskID as Int)) && (predecessorID == \(myItem.predecessorID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.predecessorType, forKey: "predecessorType")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "TaskPredecessor")
                        record.setValue(myItem.taskID, forKey: "taskID")
                        record.setValue(myItem.predecessorID, forKey: "predecessorID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.predecessorType, forKey: "predecessorType")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveTaskUpdatesToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing TaskUpdates")
        for myItem in myDatabaseConnection.getTaskUpdatesForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(taskID == \(myItem.taskID as Int)) && (updateDate == \(myItem.updateDate))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "TaskUpdates", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.details, forKey: "details")
                        record!.setValue(myItem.source, forKey: "source")
                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        let record = CKRecord(recordType: "TaskUpdates")
                        record.setValue(myItem.taskID, forKey: "taskID")
                        record.setValue(myItem.updateDate, forKey: "updateDate")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.details, forKey: "details")
                        record.setValue(myItem.source, forKey: "source")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func saveTeamToCloudKit(inLastSyncDate: NSDate)
    {
        NSLog("Syncing Team")
        for myItem in myDatabaseConnection.getTeamsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(teamID == \(myItem.teamID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Team", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myItem.name, forKey: "name")
                        record!.setValue(myItem.note, forKey: "note")
                        record!.setValue(myItem.status, forKey: "status")
                        record!.setValue(myItem.type, forKey: "type")
                        record!.setValue(myItem.predecessor, forKey: "predecessor")
                        record!.setValue(myItem.externalID, forKey: "externalID")

                        
                        // Save this record again
                        self.privateDB.saveRecord(record!, completionHandler: { (savedRecord, saveError) in
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
                        record.setValue(myItem.teamID, forKey: "teamID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.name, forKey: "name")
                        record.setValue(myItem.note, forKey: "note")
                        record.setValue(myItem.status, forKey: "status")
                        record.setValue(myItem.type, forKey: "type")
                        record.setValue(myItem.predecessor, forKey: "predecessor")
                        record.setValue(myItem.externalID, forKey: "externalID")
                        
                        self.privateDB.saveRecord(record, completionHandler: { (savedRecord, saveError) in
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
            
            sleep(1)
        }
    }
    
    func updateContextInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let contextID = record.objectForKey("contextID") as! Int
                let autoEmail = record.objectForKey("autoEmail") as! String
                let email = record.objectForKey("email") as! String
                let name = record.objectForKey("name") as! String
                let parentContext = record.objectForKey("parentContext") as! Int
                let personID = record.objectForKey("personID") as! Int32
                let status = record.objectForKey("status") as! String
                let teamID = record.objectForKey("teamID") as! Int
                let predecessor = record.objectForKey("predecessor") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                
                myDatabaseConnection.saveContext(contextID, inName: name, inEmail: email, inAutoEmail: autoEmail, inParentContext: parentContext, inStatus: status, inPersonID: personID, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
                
                
                myDatabaseConnection.saveContext1_1(contextID, inPredecessor: predecessor, inUpdateTime: updateTime, inUpdateType: updateType)
                
            }
            dispatch_semaphore_signal(sem)
        })
    }
    
    func updateDecodesInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);

        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "Decodes", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name") as! String
                let decodeValue = record.objectForKey("decode_value") as! String
                let decodeType = record.objectForKey("decodeType") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                
                myDatabaseConnection.updateDecodeValue(decodeName, inCodeValue: decodeValue, inCodeType: decodeType, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateGTDItemInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let gTDItemID = record.objectForKey("gTDItemID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let gTDParentID = record.objectForKey("gTDParentID") as! Int
                let lastReviewDate = record.objectForKey("lastReviewDate") as! NSDate
                let note = record.objectForKey("note") as! String
                let predecessor = record.objectForKey("predecessor") as! Int
                let reviewFrequency = record.objectForKey("reviewFrequency") as! Int
                let reviewPeriod = record.objectForKey("reviewPeriod") as! String
                let status = record.objectForKey("status") as! String
                let teamID = record.objectForKey("teamID") as! Int
                let title = record.objectForKey("title") as! String
                let gTDLevel = record.objectForKey("gTDLevel") as! Int
                
                myDatabaseConnection.saveGTDItem(gTDItemID, inParentID: gTDParentID, inTitle: title, inStatus: status, inTeamID: teamID, inNote: note, inLastReviewDate: lastReviewDate, inReviewFrequency: reviewFrequency, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inGTDLevel: gTDLevel, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateGTDLevelInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let gTDLevel = record.objectForKey("gTDLevel") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey( "updateType") as! String
                let teamID = record.objectForKey("teamID") as! Int
                let levelName = record.objectForKey("levelName") as! String
                
                myDatabaseConnection.saveGTDLevel(gTDLevel, inLevelName: levelName, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateMeetingAgendaInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let meetingID = record.objectForKey("meetingID") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let chair = record.objectForKey("chair") as! String
                let endTime = record.objectForKey("endTime") as! NSDate
                let location = record.objectForKey("location") as! String
                let minutes = record.objectForKey("minutes") as! String
                let minutesType = record.objectForKey("minutesType") as! String
                let name = record.objectForKey("name") as! String
                let previousMeetingID = record.objectForKey("previousMeetingID") as! String
                let startTime = record.objectForKey("startTime") as! NSDate
                let teamID = record.objectForKey("teamID") as! Int
                
                myDatabaseConnection.saveAgenda(meetingID, inPreviousMeetingID : previousMeetingID, inName: name, inChair: chair, inMinutes: minutes, inLocation: location, inStartTime: startTime, inEndTime: endTime, inMinutesType: minutesType, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateMeetingAgendaItemInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let meetingID = record.objectForKey("meetingID") as! String
                let agendaID = record.objectForKey("agendaID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let actualEndTime = record.objectForKey("actualEndTime") as! NSDate
                let actualStartTime = record.objectForKey("actualStartTime") as! NSDate
                let decisionMade = record.objectForKey("decisionMade") as! String
                let discussionNotes = record.objectForKey("discussionNotes") as! String
                let owner = record.objectForKey("owner") as! String
                let status = record.objectForKey("status") as! String
                let timeAllocation = record.objectForKey("timeAllocation") as! Int
                let title = record.objectForKey("title") as! String
                
                
                myDatabaseConnection.saveAgendaItem(meetingID, actualEndTime: actualEndTime, actualStartTime: actualStartTime, status: status, decisionMade: decisionMade, discussionNotes: discussionNotes, timeAllocation: timeAllocation, owner: owner, title: title, agendaID: agendaID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateMeetingAttendeesInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "MeetingAttendees", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let meetingID = record.objectForKey("meetingID") as! String
                let name  = record.objectForKey("name") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let attendenceStatus = record.objectForKey("attendenceStatus") as! String
                let email = record.objectForKey("email") as! String
                let type = record.objectForKey("type") as! String
                
                myDatabaseConnection.saveAttendee(meetingID, name: name, email: email,  type: type, status: attendenceStatus, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateMeetingSupportingDocsInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "MeetingSupportingDocs", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
           // for record in results!
            for _ in results!
            {
  //              let meetingID = record.objectForKey("meetingID") as! String
  //              let agendaID = record.objectForKey("agendaID") as! Int
  //              let updateTime = record.objectForKey("updateTime") as! NSDate
  //              let updateType = record.objectForKey("updateType") as! String
  //              let attachmentPath = record.objectForKey("attachmentPath") as! String
  //              let title = record.objectForKey("title") as! String
                
                NSLog("updateMeetingSupportingDocsInCoreData - Need to have the save for this")
                
                // myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateMeetingTasksInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let meetingID = record.objectForKey("meetingID") as! String
                let agendaID = record.objectForKey("agendaID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let taskID = record.objectForKey("taskID") as! Int
                
                myDatabaseConnection.saveMeetingTask(agendaID, meetingID: meetingID, taskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updatePanesInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "Panes", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateProjectsInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateProjectTeamMembersInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateRolesInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateStagesInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "Stages", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateTaskInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateTaskAttachmentInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "TaskAttachment", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateTaskContextInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateTaskPredecessorInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateTaskUpdatesInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateTeamInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name")
                let decodeValue = record.objectForKey("decode_value")
                let decodeType = record.objectForKey("decodeType")
                let updateTime = record.objectForKey("updateTime")
                let updateType = record.objectForKey("updateType")
                // myRecordList.append(record.recordID)
                NSLog("decodeName = \(decodeName!)")
                NSLog("decodeValue = \(decodeValue!)")
                NSLog("decodeType = \(decodeType!)")
                NSLog("updateTime = \(updateTime!)")
                NSLog("updateType = \(updateType!)")
                
                myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteContext()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
        var myRecordList2: [CKRecordID] = Array()
        let predicate2: NSPredicate = NSPredicate(value: true)
        let query2: CKQuery = CKQuery(recordType: "Context1_1", predicate: predicate2)
        privateDB.performQuery(query2, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList2.append(record.recordID)
            }
            self.performDelete(myRecordList2)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteDecodes()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Decodes", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteGTDItem()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteGTDLevel()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteMeetingAgenda()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteMeetingAgendaItem()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteMeetingAttendees()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingAttendees", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteMeetingSupportingDocs()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingSupportingDocs", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteMeetingTasks()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deletePanes()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Panes", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteProjects()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
        var myRecordList2: [CKRecordID] = Array()
        let predicate2: NSPredicate = NSPredicate(value: true)
        let query2: CKQuery = CKQuery(recordType: "ProjectNote", predicate: predicate2)
        privateDB.performQuery(query2, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList2.append(record.recordID)
            }
            self.performDelete(myRecordList2)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteProjectTeamMembers()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteRoles()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteStages()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Stages", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteTask()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteTaskAttachment()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskAttachment", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteTaskContext()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteTaskPredecessor()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteTaskUpdates()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func deleteTeam()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            dispatch_semaphore_signal(sem)
        })
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }

    func performDelete(inRecordSet: [CKRecordID])
    {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: inRecordSet)
        operation.savePolicy = .AllKeys
        operation.database = privateDB
        operation.modifyRecordsCompletionBlock = { (added, deleted, error) in
            if error != nil
            {
                NSLog(error!.localizedDescription) // print error if any
            }
            else
            {
                // no errors, all set!
            }
        }
        
        let queue = NSOperationQueue()
        queue.addOperations([operation], waitUntilFinished: true)
      //  privateDB.addOperation(operation, waitUntilFinished: true)
        NSLog("finished delete")
    }
}
