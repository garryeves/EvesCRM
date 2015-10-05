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
//        NSLog("Syncing Contexts")
        for myItem in myDatabaseConnection.getContextsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(contextID == \(myItem.contextID as Int)) && (teamID == \(myItem.teamID as Int))") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Context", predicate: predicate)
            privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
                if error != nil
                {
                    NSLog("Error querying records: \(error!.localizedDescription)")
                }
                else
                {
                    // Lets go and get the additional details from the context1_1 table
                    
                    let tempContext1_1 = myDatabaseConnection.getContext1_1(myItem.contextID as Int)
                    
                    var myPredecessor: Int = 0
                    var myContextType: String = ""
                    
                    if tempContext1_1.count > 0
                    {
                        myPredecessor = tempContext1_1[0].predecessor as! Int
                        if tempContext1_1[0].contextType != nil
                        {
                            myContextType = tempContext1_1[0].contextType!
                        }
                        else
                        {
                            myContextType = "Person"
                        }
                    }
                    
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
                        record!.setValue(myItem.updateTime, forKey: "updateTime")
                        record!.setValue(myItem.updateType, forKey: "updateType")
                        record!.setValue(myPredecessor, forKey: "predecessor")
                        record!.setValue(myContextType, forKey: "contextType")
                        
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
                        record.setValue(myPredecessor, forKey: "predecessor")
                        record.setValue(myContextType, forKey: "contextType")
                        
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
            
//            sleep(1)
        }
        
        for myItem in myDatabaseConnection.getContexts1_1ForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(contextID == \(myItem.contextID as! Int))") // better be accurate to get only the record you need
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
                        record!.setValue(myItem.contextType, forKey: "contextType")
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
            
//            sleep(1)
        }
    }

    func saveDecodesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Decodes")
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

//            sleep(1)
        }
    }

    func saveGTDItemToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing GTDItem")
        for myItem in myDatabaseConnection.getGTDItemsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(gTDItemID == \(myItem.gTDItemID as! Int)) && (teamID == \(myItem.teamID as! Int))")
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
            
//            sleep(1)
        }
    }
    
    func saveGTDLevelToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing GTDLevel")
        for myItem in myDatabaseConnection.getGTDLevelsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(gTDLevel == \(myItem.gTDLevel as! Int)) && (teamID == \(myItem.teamID as! Int))") // better be accurate to get only the record you need
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
            
//            sleep(1)
        }
    }

    func saveMeetingAgendaToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Meeting Agenda")
        for myItem in myDatabaseConnection.getMeetingAgendasForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(meetingID == \"\(myItem.meetingID)\") && (actualTeamID == \(myItem.teamID as Int))") // better be accurate to get only the record you need
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
                        record!.setValue(myItem.startTime, forKey: "meetingStartTime")
                        
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
                        record.setValue(myItem.startTime, forKey: "meetingStartTime")
                        record.setValue(myItem.teamID, forKey: "actualTeamID")
                        
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
            
//            sleep(1)
        }
    }
    
    func saveMeetingAgendaItemToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing meetingAgendaItems")
        for myItem in myDatabaseConnection.getMeetingAgendaItemsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(meetingID == \"\(myItem.meetingID!)\") && (agendaID == \(myItem.agendaID as! Int))") // better be accurate to get only the record you need
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
                        record!.setValue(myItem.meetingOrder, forKey: "meetingOrder")
                        
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
                        record.setValue(myItem.meetingOrder, forKey: "meetingOrder")

                        
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
            
//            sleep(1)
        }
    }
    
    func saveMeetingAttendeesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing MeetingAttendees")
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
            
//            sleep(1)
        }
    }
    
    func saveMeetingSupportingDocsToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing MeetingSupportingDocs")
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
            
//            sleep(1)
        }
    }
    
    func saveMeetingTasksToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing MeetingTasks")
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
            
//            sleep(1)
        }
    }
    
    func savePanesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Panes")
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
            
//            sleep(1)
        }
    }
    
    func saveProjectsToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Projects")
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
                    
                    // First need to get additional info from other table
                    
                    let tempProjectNote = myDatabaseConnection.getProjectNote(myItem.projectID as Int)
                    
                    var myNote: String = ""
                    var myReviewPeriod: String = ""
                    var myPredecessor: Int = 0
                    
                    if tempProjectNote.count > 0
                    {
                        myNote = tempProjectNote[0].note
                        myReviewPeriod = tempProjectNote[0].reviewPeriod
                        myPredecessor = tempProjectNote[0].predecessor as Int
                    }
                    
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
                        record!.setValue(myNote, forKey: "note")
                        record!.setValue(myReviewPeriod, forKey: "reviewPeriod")
                        record!.setValue(myPredecessor, forKey: "predecessor")
                        
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
                        record.setValue(myNote, forKey: "note")
                        record.setValue(myReviewPeriod, forKey: "reviewPeriod")
                        record.setValue(myPredecessor, forKey: "predecessor")
                        
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
            
//            sleep(1)
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
            
//            sleep(1)
        }
    }
    
    func saveProjectTeamMembersToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing ProjectTeamMembers")
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
            
//            sleep(1)
        }
    }
    
    func saveRolesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Roles")
        for myItem in myDatabaseConnection.getRolesForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(roleID == \(myItem.roleID as Int)) && (teamID == \(myItem.teamID as Int))") // better be accurate to get only the record you need
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
            
//            sleep(1)
        }
    }
    
    func saveStagesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Stages")
        for myItem in myDatabaseConnection.getStagesForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(stageDescription == \"\(myItem.stageDescription)\") && (teamID == \(myItem.teamID as Int))") // better be accurate to get only the record you need
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
            
//            sleep(1)
        }
    }
    
    func saveTaskToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Task")
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
                        record!.setValue(myItem.title, forKey: "title")
                        record!.setValue(myItem.urgency, forKey: "urgency")
                        record!.setValue(myItem.projectID, forKey: "projectID")
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
                        record.setValue(myItem.projectID, forKey: "projectID")
                        
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
            
//            sleep(1)
        }
    }
    
    func saveTaskAttachmentToCloudKit(inLastSyncDate: NSDate)
    {
 //       NSLog("Syncing taskAttachments")
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
            
//            sleep(1)
        }
    }
    
    func saveTaskContextToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing TaskContext")
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
            
//            sleep(1)
        }
    }
    
    func saveTaskPredecessorToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing TaskPredecessor")
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
            
//            sleep(1)
        }
    }
    
    func saveTaskUpdatesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing TaskUpdates")
        for myItem in myDatabaseConnection.getTaskUpdatesForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(taskID == \(myItem.taskID as Int)) && (updateDate == %@)", myItem.updateDate) // better be accurate to get only the record you need
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
            
//            sleep(1)
        }
    }
    
    func saveTeamToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Team")
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
            
//            sleep(1)
        }
    }
    
    func saveProcessedEmailsToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing ProcessedEmails")
        for myItem in myDatabaseConnection.getProcessedEmailsForSync(inLastSyncDate)
        {
            let predicate = NSPredicate(format: "(emailID == \"\(myItem.emailID!)\")") // better be accurate to get only the record you need
            let query = CKQuery(recordType: "ProcessedEmails", predicate: predicate)
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
                        record!.setValue(myItem.emailType, forKey: "emailType")
                        record!.setValue(myItem.processedDate, forKey: "processedDate")
                        
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
                        let record = CKRecord(recordType: "ProcessedEmails")
                        record.setValue(myItem.emailID, forKey: "emailID")
                        record.setValue(myItem.updateTime, forKey: "updateTime")
                        record.setValue(myItem.updateType, forKey: "updateType")
                        record.setValue(myItem.emailType, forKey: "emailType")
                        record.setValue(myItem.processedDate, forKey: "processedDate")
                        
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
            
//            sleep(1)
        }
    }

    
    func updateContextInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        var predecessor: Int = 0
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let contextID = record.objectForKey("contextID") as! Int
                let autoEmail = record.objectForKey("autoEmail") as! String
                let email = record.objectForKey("email") as! String
                let name = record.objectForKey("name") as! String
                let parentContext = record.objectForKey("parentContext") as! Int
                let personID = record.objectForKey("personID") as! Int
                let status = record.objectForKey("status") as! String
                let teamID = record.objectForKey("teamID") as! Int
                let contextType = record.objectForKey("contextType") as! String
                
                
                if record.objectForKey("predecessor") != nil
                {
                    predecessor = record.objectForKey("predecessor") as! Int
                }
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                
                myDatabaseConnection.saveContext(contextID, inName: name, inEmail: email, inAutoEmail: autoEmail, inParentContext: parentContext, inStatus: status, inPersonID: personID, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
                
                
                myDatabaseConnection.saveContext1_1(contextID, predecessor: predecessor, contextType: contextType, updateTime: updateTime, updateType: updateType)
                
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
                let startTime = record.objectForKey("meetingStartTime") as! NSDate
                let teamID = record.objectForKey("actualTeamID") as! Int
                
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
                var actualEndTime: NSDate!
                if record.objectForKey("actualEndTime") != nil
                {
                    actualEndTime = record.objectForKey("actualEndTime") as! NSDate
                }
                else
                {
                    actualEndTime = getDefaultDate()
                }
                var actualStartTime: NSDate!
                if record.objectForKey("actualStartTime") != nil
                {
                    actualStartTime = record.objectForKey("actualStartTime") as! NSDate
                }
                else
                {
                    actualStartTime = getDefaultDate()
                }
                let decisionMade = record.objectForKey("decisionMade") as! String
                let discussionNotes = record.objectForKey("discussionNotes") as! String
                let owner = record.objectForKey("owner") as! String
                let status = record.objectForKey("status") as! String
                let timeAllocation = record.objectForKey("timeAllocation") as! Int
                let title = record.objectForKey("title") as! String
                let meetingOrder = record.objectForKey("meetingOrder") as! Int

                
                myDatabaseConnection.saveAgendaItem(meetingID, actualEndTime: actualEndTime, actualStartTime: actualStartTime, status: status, decisionMade: decisionMade, discussionNotes: discussionNotes, timeAllocation: timeAllocation, owner: owner, title: title, agendaID: agendaID, meetingOrder: meetingOrder, inUpdateTime: updateTime, inUpdateType: updateType)
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
                let pane_name = record.objectForKey("pane_name") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let pane_available = record.objectForKey("pane_available") as! Bool
                let pane_order = record.objectForKey("pane_order") as! Int
                let pane_visible = record.objectForKey("pane_visible") as! Bool
                
                myDatabaseConnection.savePane(pane_name, inPaneAvailable: pane_available, inPaneVisible: pane_visible, inPaneOrder: pane_order, inUpdateTime: updateTime, inUpdateType: updateType)
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
                let projectID = record.objectForKey("projectID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let areaID = record.objectForKey("areaID") as! Int
                let lastReviewDate = record.objectForKey("lastReviewDate") as! NSDate
                let projectEndDate = record.objectForKey("projectEndDate") as! NSDate
                let projectName = record.objectForKey("projectName") as! String
                let projectStartDate = record.objectForKey("projectStartDate") as! NSDate
                let projectStatus = record.objectForKey("projectStatus") as! String
                let repeatBase = record.objectForKey("repeatBase") as! String
                let repeatInterval = record.objectForKey("repeatInterval") as! Int
                let repeatType = record.objectForKey("repeatType") as! String
                let reviewFrequency = record.objectForKey("reviewFrequency") as! Int
                let teamID = record.objectForKey("teamID") as! Int
                let note = record.objectForKey("note") as! String
                let reviewPeriod = record.objectForKey("reviewPeriod") as! String
                let predecessor = record.objectForKey("predecessor") as! Int
                
                myDatabaseConnection.saveProject(projectID, inProjectEndDate: projectEndDate, inProjectName: projectName, inProjectStartDate: projectStartDate, inProjectStatus: projectStatus, inReviewFrequency: reviewFrequency, inLastReviewDate: lastReviewDate, inGTDItemID: areaID, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
                
                myDatabaseConnection.saveProjectNote(projectID, inNote: note, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inUpdateTime: updateTime, inUpdateType: updateType)
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
                let projectID = record.objectForKey("projectID") as! Int
                let teamMember = record.objectForKey("teamMember") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let roleID = record.objectForKey("roleID") as! Int
                let projectMemberNotes = record.objectForKey("projectMemberNotes") as! String
                
                myDatabaseConnection.saveTeamMember(projectID, inRoleID: roleID, inPersonName: teamMember, inNotes: projectMemberNotes, inUpdateTime: updateTime, inUpdateType: updateType)
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
                let roleID = record.objectForKey("roleID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let teamID = record.objectForKey("teamID") as! Int
                let roleDescription = record.objectForKey("roleDescription") as! String
                
                myDatabaseConnection.saveRole(roleDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType, roleID: roleID)
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
                let stageDescription = record.objectForKey("stageDescription") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let teamID = record.objectForKey("teamID") as! Int
                
                myDatabaseConnection.saveStage(stageDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
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
                let taskID = record.objectForKey("taskID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let completionDate = record.objectForKey("completionDate") as! NSDate
                let details = record.objectForKey("details") as! String
                let dueDate = record.objectForKey("dueDate") as! NSDate
                let energyLevel = record.objectForKey("energyLevel") as! String
                let estimatedTime = record.objectForKey("estimatedTime") as! Int
                let estimatedTimeType = record.objectForKey("estimatedTimeType") as! String
                let flagged = record.objectForKey("flagged") as! Bool
                let priority = record.objectForKey("priority") as! String
                let repeatBase = record.objectForKey("repeatBase") as! String
                let repeatInterval = record.objectForKey("repeatInterval") as! Int
                let repeatType = record.objectForKey("repeatType") as! String
                let startDate = record.objectForKey("startDate") as! NSDate
                let status = record.objectForKey("status") as! String
                let teamID = record.objectForKey("teamID") as! Int
                let title = record.objectForKey("title") as! String
                let urgency = record.objectForKey("urgency") as! String
                let projectID = record.objectForKey("projectID") as! Int
                
                myDatabaseConnection.saveTask(taskID, inTitle: title, inDetails: details, inDueDate: dueDate, inStartDate: startDate, inStatus: status, inPriority: priority, inEnergyLevel: energyLevel, inEstimatedTime: estimatedTime, inEstimatedTimeType: estimatedTimeType, inProjectID: projectID, inCompletionDate: completionDate, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inFlagged: flagged, inUrgency: urgency, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
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
         //   for record in results!
            for _ in results!
            {
            //    let taskID = record.objectForKey("taskID") as! Int
            //    let title = record.objectForKey("title") as! String
            //    let updateTime = record.objectForKey("updateTime") as! NSDate
            //    let updateType = record.objectForKey("updateType") as! String
            //    let attachment = record.objectForKey("attachment") as! NSData
               NSLog("updateTaskAttachmentInCoreData - Still to be coded")
             //   myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
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
                let taskID = record.objectForKey("taskID") as! Int
                let contextID = record.objectForKey("contextID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                
                myDatabaseConnection.saveTaskContext(contextID, inTaskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
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
                let taskID = record.objectForKey("taskID") as! Int
                let predecessorID = record.objectForKey("predecessorID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let predecessorType = record.objectForKey("predecessorType") as! String
                
                myDatabaseConnection.savePredecessorTask(taskID, inPredecessorID: predecessorID, inPredecessorType: predecessorType, inUpdateTime: updateTime, inUpdateType: updateType)
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
                let taskID = record.objectForKey("taskID") as! Int
                let updateDate = record.objectForKey("updateDate") as! NSDate
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let details = record.objectForKey("details") as! String
                let source = record.objectForKey("source") as! String
                
                myDatabaseConnection.saveTaskUpdate(taskID, inDetails: details, inSource: source, inUpdateDate: updateDate, inUpdateTime: updateTime, inUpdateType: updateType)
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
                let teamID = record.objectForKey("teamID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let name = record.objectForKey("name") as! String
                let note = record.objectForKey("note") as! String
                let status = record.objectForKey("status") as! String
                let type = record.objectForKey("type") as! String
                let predecessor = record.objectForKey("predecessor") as! Int
                let externalID = record.objectForKey("externalID") as! Int
                
                myDatabaseConnection.saveTeam(teamID, inName: name, inStatus: status, inNote: note, inType: type, inPredecessor: predecessor, inExternalID: externalID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func updateProcessedEmailsInCoreData(inLastSyncDate: NSDate)
    {
        let sem = dispatch_semaphore_create(0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate)
        let query: CKQuery = CKQuery(recordType: "ProcessedEmails", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let emailID = record.objectForKey("emailID") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let emailType = record.objectForKey("emailType") as! String
                let processedDate = record.objectForKey("processedDate") as! NSDate
                
                myDatabaseConnection.saveProcessedEmail(emailID, emailType: emailType, processedDate: processedDate, updateTime: updateTime, updateType: updateType)
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
    
    func deleteProcessedEmails()
    {
        let sem = dispatch_semaphore_create(0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "ProcessedEmails", predicate: predicate)
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
     //   NSLog("finished delete")
    }
    
    func replaceContextInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        var predecessor: Int = 0
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let contextID = record.objectForKey("contextID") as! Int
                let autoEmail = record.objectForKey("autoEmail") as! String
                let email = record.objectForKey("email") as! String
                let name = record.objectForKey("name") as! String
                let parentContext = record.objectForKey("parentContext") as! Int
                let personID = record.objectForKey("personID") as! Int
                let status = record.objectForKey("status") as! String
                let teamID = record.objectForKey("teamID") as! Int
                let contextType = record.objectForKey("contextType") as! String
                
                
                if record.objectForKey("predecessor") != nil
                {
                    predecessor = record.objectForKey("predecessor") as! Int
                }
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                
                myDatabaseConnection.replaceContext(contextID, inName: name, inEmail: email, inAutoEmail: autoEmail, inParentContext: parentContext, inStatus: status, inPersonID: personID, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
                
                
                myDatabaseConnection.replaceContext1_1(contextID, predecessor: predecessor, contextType: contextType, updateTime: updateTime, updateType: updateType)
                
            }
            dispatch_semaphore_signal(sem)
        })
    }
    
    func replaceDecodesInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "Decodes", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                
                let decodeName = record.objectForKey("decode_name") as! String
                let decodeValue = record.objectForKey("decode_value") as! String
                let decodeType = record.objectForKey("decodeType") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                
                myDatabaseConnection.replaceDecodeValue(decodeName, inCodeValue: decodeValue, inCodeType: decodeType, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceGTDItemInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
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
                
                myDatabaseConnection.replaceGTDItem(gTDItemID, inParentID: gTDParentID, inTitle: title, inStatus: status, inTeamID: teamID, inNote: note, inLastReviewDate: lastReviewDate, inReviewFrequency: reviewFrequency, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inGTDLevel: gTDLevel, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceGTDLevelInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let gTDLevel = record.objectForKey("gTDLevel") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey( "updateType") as! String
                let teamID = record.objectForKey("teamID") as! Int
                let levelName = record.objectForKey("levelName") as! String
                
                myDatabaseConnection.replaceGTDLevel(gTDLevel, inLevelName: levelName, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceMeetingAgendaInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
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
                let startTime = record.objectForKey("meetingStartTime") as! NSDate
                let teamID = record.objectForKey("actualTeamID") as! Int
                
                myDatabaseConnection.replaceAgenda(meetingID, inPreviousMeetingID : previousMeetingID, inName: name, inChair: chair, inMinutes: minutes, inLocation: location, inStartTime: startTime, inEndTime: endTime, inMinutesType: minutesType, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceMeetingAgendaItemInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
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
                let meetingOrder = record.objectForKey("meetingOrder") as! Int
                
                myDatabaseConnection.replaceAgendaItem(meetingID, actualEndTime: actualEndTime, actualStartTime: actualStartTime, status: status, decisionMade: decisionMade, discussionNotes: discussionNotes, timeAllocation: timeAllocation, owner: owner, title: title, agendaID: agendaID, meetingOrder: meetingOrder, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceMeetingAttendeesInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
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
                
                myDatabaseConnection.replaceAttendee(meetingID, name: name, email: email,  type: type, status: attendenceStatus, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceMeetingSupportingDocsInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
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
                
                NSLog("replaceMeetingSupportingDocsInCoreData - Need to have the save for this")
                
                // myDatabaseConnection.replaceDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceMeetingTasksInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let meetingID = record.objectForKey("meetingID") as! String
                let agendaID = record.objectForKey("agendaID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let taskID = record.objectForKey("taskID") as! Int
                
                myDatabaseConnection.replaceMeetingTask(agendaID, meetingID: meetingID, taskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replacePanesInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "Panes", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let pane_name = record.objectForKey("pane_name") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let pane_available = record.objectForKey("pane_available") as! Bool
                let pane_order = record.objectForKey("pane_order") as! Int
                let pane_visible = record.objectForKey("pane_visible") as! Bool
                
                myDatabaseConnection.replacePane(pane_name, inPaneAvailable: pane_available, inPaneVisible: pane_visible, inPaneOrder: pane_order, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceProjectsInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let projectID = record.objectForKey("projectID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let areaID = record.objectForKey("areaID") as! Int
                let lastReviewDate = record.objectForKey("lastReviewDate") as! NSDate
                let projectEndDate = record.objectForKey("projectEndDate") as! NSDate
                let projectName = record.objectForKey("projectName") as! String
                let projectStartDate = record.objectForKey("projectStartDate") as! NSDate
                let projectStatus = record.objectForKey("projectStatus") as! String
                let repeatBase = record.objectForKey("repeatBase") as! String
                let repeatInterval = record.objectForKey("repeatInterval") as! Int
                let repeatType = record.objectForKey("repeatType") as! String
                let reviewFrequency = record.objectForKey("reviewFrequency") as! Int
                let teamID = record.objectForKey("teamID") as! Int
                let note = record.objectForKey("note") as! String
                let reviewPeriod = record.objectForKey("reviewPeriod") as! String
                let predecessor = record.objectForKey("predecessor") as! Int
                
                myDatabaseConnection.replaceProject(projectID, inProjectEndDate: projectEndDate, inProjectName: projectName, inProjectStartDate: projectStartDate, inProjectStatus: projectStatus, inReviewFrequency: reviewFrequency, inLastReviewDate: lastReviewDate, inGTDItemID: areaID, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
                
                myDatabaseConnection.replaceProjectNote(projectID, inNote: note, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceProjectTeamMembersInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let projectID = record.objectForKey("projectID") as! Int
                let teamMember = record.objectForKey("teamMember") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let roleID = record.objectForKey("roleID") as! Int
                let projectMemberNotes = record.objectForKey("projectMemberNotes") as! String
                
                myDatabaseConnection.replaceTeamMember(projectID, inRoleID: roleID, inPersonName: teamMember, inNotes: projectMemberNotes, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceRolesInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let roleID = record.objectForKey("roleID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let teamID = record.objectForKey("teamID") as! Int
                let roleDescription = record.objectForKey("roleDescription") as! String
                
                myDatabaseConnection.replaceRole(roleDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType, roleID: roleID)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceStagesInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "Stages", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let stageDescription = record.objectForKey("stageDescription") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let teamID = record.objectForKey("teamID") as! Int
                
                myDatabaseConnection.replaceStage(stageDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceTaskInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let taskID = record.objectForKey("taskID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let completionDate = record.objectForKey("completionDate") as! NSDate
                let details = record.objectForKey("details") as! String
                let dueDate = record.objectForKey("dueDate") as! NSDate
                let energyLevel = record.objectForKey("energyLevel") as! String
                let estimatedTime = record.objectForKey("estimatedTime") as! Int
                let estimatedTimeType = record.objectForKey("estimatedTimeType") as! String
                let flagged = record.objectForKey("flagged") as! Bool
                let priority = record.objectForKey("priority") as! String
                let repeatBase = record.objectForKey("repeatBase") as! String
                let repeatInterval = record.objectForKey("repeatInterval") as! Int
                let repeatType = record.objectForKey("repeatType") as! String
                let startDate = record.objectForKey("startDate") as! NSDate
                let status = record.objectForKey("status") as! String
                let teamID = record.objectForKey("teamID") as! Int
                let title = record.objectForKey("title") as! String
                let urgency = record.objectForKey("urgency") as! String
                let projectID = record.objectForKey("projectID") as! Int
                
                myDatabaseConnection.replaceTask(taskID, inTitle: title, inDetails: details, inDueDate: dueDate, inStartDate: startDate, inStatus: status, inPriority: priority, inEnergyLevel: energyLevel, inEstimatedTime: estimatedTime, inEstimatedTimeType: estimatedTimeType, inProjectID: projectID, inCompletionDate: completionDate, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inFlagged: flagged, inUrgency: urgency, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceTaskAttachmentInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "TaskAttachment", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            //   for record in results!
            for _ in results!
            {
                //    let taskID = record.objectForKey("taskID") as! Int
                //    let title = record.objectForKey("title") as! String
                //    let updateTime = record.objectForKey("updateTime") as! NSDate
                //    let updateType = record.objectForKey("updateType") as! String
                //    let attachment = record.objectForKey("attachment") as! NSData
                NSLog("replaceTaskAttachmentInCoreData - Still to be coded")
                //   myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceTaskContextInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let taskID = record.objectForKey("taskID") as! Int
                let contextID = record.objectForKey("contextID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                
                myDatabaseConnection.replaceTaskContext(contextID, inTaskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceTaskPredecessorInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let taskID = record.objectForKey("taskID") as! Int
                let predecessorID = record.objectForKey("predecessorID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let predecessorType = record.objectForKey("predecessorType") as! String
                
                myDatabaseConnection.replacePredecessorTask(taskID, inPredecessorID: predecessorID, inPredecessorType: predecessorType, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceTaskUpdatesInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let taskID = record.objectForKey("taskID") as! Int
                let updateDate = record.objectForKey("updateDate") as! NSDate
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let details = record.objectForKey("details") as! String
                let source = record.objectForKey("source") as! String
                
                myDatabaseConnection.replaceTaskUpdate(taskID, inDetails: details, inSource: source, inUpdateDate: updateDate, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceTeamInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let teamID = record.objectForKey("teamID") as! Int
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let name = record.objectForKey("name") as! String
                let note = record.objectForKey("note") as! String
                let status = record.objectForKey("status") as! String
                let type = record.objectForKey("type") as! String
                let predecessor = record.objectForKey("predecessor") as! Int
                let externalID = record.objectForKey("externalID") as! Int

                myDatabaseConnection.replaceTeam(teamID, inName: name, inStatus: status, inNote: note, inType: type, inPredecessor: predecessor, inExternalID: externalID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    func replaceProcessedEmailsInCoreData()
    {
        let sem = dispatch_semaphore_create(0);
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let inLastSyncDate = myDateFormatter.dateFromString("01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate!)
        let query: CKQuery = CKQuery(recordType: "ProcessedEmails", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results: [CKRecord]?, error: NSError?) in
            for record in results!
            {
                let emailID = record.objectForKey("emailID") as! String
                let updateTime = record.objectForKey("updateTime") as! NSDate
                let updateType = record.objectForKey("updateType") as! String
                let emailType = record.objectForKey("emailType") as! String
                let processedDate = record.objectForKey("processedDate") as! NSDate
                
                myDatabaseConnection.replaceProcessedEmail(emailID, emailType: emailType, processedDate: processedDate, updateTime: updateTime, updateType: updateType)
            }
            dispatch_semaphore_signal(sem)
        })
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
}
