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
                        record!.setValue(myItem.decode_value, forKey: "decode_value")
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
                        todoRecord.setValue(myItem.decode_value, forKey: "decode_value")
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

    }
    
    func updateDecodesInCoreData(inLastSyncDate: NSDate)
    {
    }
    
    func updateGTDItemInCoreData(inLastSyncDate: NSDate)
    {

    }
    
    func updateGTDLevelInCoreData(inLastSyncDate: NSDate)
    {

    }
    
    func updateMeetingAgendaInCoreData(inLastSyncDate: NSDate)
    {
    }
    
    func updateMeetingAgendaItemInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateMeetingAttendeesInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateMeetingSupportingDocsInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateMeetingTasksInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateGPanesInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateProjectsInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateProjectTeamMembersInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateRolesInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateStagesInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateTaskInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateTaskAttachmentInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateTaskContextInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateTaskPredecessorInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateTaskUpdatesInCoreData(inLastSyncDate: NSDate)
    {
        
    }
    
    func updateTeamInCoreData(inLastSyncDate: NSDate)
    {
        
    }
}
