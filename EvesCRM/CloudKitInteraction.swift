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
        #if os(iOS)
            container = CKContainer.defaultContainer()
        #elseif os(OSX)
            container = CKContainer.init(identifier: "iCloud.com.garryeves.EvesCRM")
        #else
            NSLog("Unexpected OS")
        #endif

        publicDB = container.publicCloudDatabase // data saved here can be seen by all users
        privateDB = container.privateCloudDatabase // this is the one to use to save the data
        
        userInfo = UserInfo(container: container)        
    }
    
    func saveContextToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Contexts")
        for myItem in myDatabaseConnection.getContextsForSync(inLastSyncDate)
        {
            saveContextRecordToCloudKit(myItem)
        }
        
        for myItem in myDatabaseConnection.getContexts1_1ForSync(inLastSyncDate)
        {
            saveContext1_1RecordToCloudKit(myItem)
        }
    }

    func saveDecodesToCloudKit(inLastSyncDate: NSDate, syncName: String)
    {
//        NSLog("Syncing Decodes")
        for myItem in myDatabaseConnection.getDecodesForSync(inLastSyncDate)
        {
            saveDecodesRecordToCloudKit(myItem, syncName: syncName)
        }
    }

    func saveGTDItemToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing GTDItem")
        for myItem in myDatabaseConnection.getGTDItemsForSync(inLastSyncDate)
        {
            saveGTDItemRecordToCloudKit(myItem)
        }
    }
    
    func saveGTDLevelToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing GTDLevel")
        for myItem in myDatabaseConnection.getGTDLevelsForSync(inLastSyncDate)
        {
            saveGTDLevelRecordToCloudKit(myItem)
        }
    }

    func saveMeetingAgendaToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Meeting Agenda")
        for myItem in myDatabaseConnection.getMeetingAgendasForSync(inLastSyncDate)
        {
            saveMeetingAgendaRecordToCloudKit(myItem)
        }
    }
    
    func saveMeetingAgendaItemToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing meetingAgendaItems")
        for myItem in myDatabaseConnection.getMeetingAgendaItemsForSync(inLastSyncDate)
        {
            saveMeetingAgendaItemRecordToCloudKit(myItem)
        }
    }
    
    func saveMeetingAttendeesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing MeetingAttendees")
        for myItem in myDatabaseConnection.getMeetingAttendeesForSync(inLastSyncDate)
        {
            saveMeetingAttendeesRecordToCloudKit(myItem)
        }
    }
    
    func saveMeetingSupportingDocsToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing MeetingSupportingDocs")
        for myItem in myDatabaseConnection.getMeetingSupportingDocsForSync(inLastSyncDate)
        {
            saveMeetingSupportingDocsRecordToCloudKit(myItem)
        }
    }
    
    func saveMeetingTasksToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing MeetingTasks")
        for myItem in myDatabaseConnection.getMeetingTasksForSync(inLastSyncDate)
        {
            saveMeetingTasksRecordToCloudKit(myItem)
        }
    }
    
    func savePanesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Panes")
        for myItem in myDatabaseConnection.getPanesForSync(inLastSyncDate)
        {
            savePanesRecordToCloudKit(myItem)
        }
    }
    
    func saveProjectsToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Projects")
        for myItem in myDatabaseConnection.getProjectsForSync(inLastSyncDate)
        {
            saveProjectsRecordToCloudKit(myItem)
        }
        
        for myItem in myDatabaseConnection.getProjectNotesForSync(inLastSyncDate)
        {
            saveProjectNoteRecordToCloudKit(myItem)
        }
    }
    
    func saveProjectTeamMembersToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing ProjectTeamMembers")
        for myItem in myDatabaseConnection.getProjectTeamMembersForSync(inLastSyncDate)
        {
            saveProjectTeamMembersRecordToCloudKit(myItem)
        }
    }
    
    func saveRolesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Roles")
        for myItem in myDatabaseConnection.getRolesForSync(inLastSyncDate)
        {
            saveRolesRecordToCloudKit(myItem)
        }
    }
    
    func saveStagesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Stages")
        for myItem in myDatabaseConnection.getStagesForSync(inLastSyncDate)
        {
            saveStagesRecordToCloudKit(myItem)
        }
    }
    
    func saveTaskToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Task")
        for myItem in myDatabaseConnection.getTaskForSync(inLastSyncDate)
        {
            saveTaskRecordToCloudKit(myItem)
        }
    }
    
    func saveTaskAttachmentToCloudKit(inLastSyncDate: NSDate)
    {
 //       NSLog("Syncing taskAttachments")
        for myItem in myDatabaseConnection.getTaskAttachmentsForSync(inLastSyncDate)
        {
            saveTaskAttachmentRecordToCloudKit(myItem)
        }
    }
    
    func saveTaskContextToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing TaskContext")
        for myItem in myDatabaseConnection.getTaskContextsForSync(inLastSyncDate)
        {
            saveTaskContextRecordToCloudKit(myItem)
        }
    }
    
    func saveTaskPredecessorToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing TaskPredecessor")
        for myItem in myDatabaseConnection.getTaskPredecessorsForSync(inLastSyncDate)
        {
            saveTaskPredecessorRecordToCloudKit(myItem)
        }
    }
    
    func saveTaskUpdatesToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing TaskUpdates")
        for myItem in myDatabaseConnection.getTaskUpdatesForSync(inLastSyncDate)
        {
            saveTaskUpdatesRecordToCloudKit(myItem)
        }
    }
    
    func saveTeamToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Team")
        for myItem in myDatabaseConnection.getTeamsForSync(inLastSyncDate)
        {
            saveTeamRecordToCloudKit(myItem)
        }
    }
    
    func saveProcessedEmailsToCloudKit(inLastSyncDate: NSDate)
    {
//        NSLog("Syncing ProcessedEmails")
        for myItem in myDatabaseConnection.getProcessedEmailsForSync(inLastSyncDate)
        {
            saveProcessedEmailsRecordToCloudKit(myItem)
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
                self.updateContextRecord(record)
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
                self.updateDecodeRecord(record)
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
                self.updateGTDItemRecord(record)
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
                self.updateGTDLevelRecord(record)
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
                self.updateMeetingAgendaRecord(record)
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
                self.updateMeetingAgendaItemRecord(record)
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
                self.updateMeetingAttendeesRecord(record)
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
  //              self.updateMeetingSupportingDocsRecord(record)
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
                self.updateMeetingTasksRecord(record)
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
                self.updatePanesRecord(record)
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
                self.updateProjectsRecord(record)
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
                self.updateProjectTeamMembersRecord(record)
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
                self.updateRolesRecord(record)
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
                self.updateStagesRecord(record)
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
                self.updateTaskRecord(record)
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
            for record in results!
            {
                self.updateTaskAttachmentRecord(record)
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
                self.updateTaskContextRecord(record)
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
                self.updateTaskPredecessorRecord(record)
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
                self.updateTaskUpdatesRecord(record)
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
                self.updateTeamRecord(record)
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
                self.updateProcessedEmailsRecord(record)
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
                self.updateDecodeRecord(record)
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
    
    func saveContextRecordToCloudKit(sourceRecord: Context)
    {
        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID as Int)) && (teamID == \(sourceRecord.teamID as Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Context", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
                if error != nil
                {
                    NSLog("Error querying records: \(error!.localizedDescription)")
                }
                else
                {
                    // Lets go and get the additional details from the context1_1 table
                    
                    let tempContext1_1 = myDatabaseConnection.getContext1_1(sourceRecord.contextID as Int)
                    
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
                        record!.setValue(sourceRecord.autoEmail, forKey: "autoEmail")
                        record!.setValue(sourceRecord.email, forKey: "email")
                        record!.setValue(sourceRecord.name, forKey: "name")
                        record!.setValue(sourceRecord.parentContext, forKey: "parentContext")
                        record!.setValue(sourceRecord.personID, forKey: "personID")
                        record!.setValue(sourceRecord.status, forKey: "status")
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
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
                        record.setValue(sourceRecord.contextID, forKey: "contextID")
                        record.setValue(sourceRecord.autoEmail, forKey: "autoEmail")
                        record.setValue(sourceRecord.email, forKey: "email")
                        record.setValue(sourceRecord.name, forKey: "name")
                        record.setValue(sourceRecord.parentContext, forKey: "parentContext")
                        record.setValue(sourceRecord.personID, forKey: "personID")
                        record.setValue(sourceRecord.status, forKey: "status")
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
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
    }
    
    func saveContext1_1RecordToCloudKit(sourceRecord: Context1_1)
    {
        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID as! Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        record!.setValue(sourceRecord.contextType, forKey: "contextType")
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        
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
                        record.setValue(sourceRecord.contextID, forKey: "contextID")
                        record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        record.setValue(sourceRecord.contextType, forKey: "contextType")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        
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
    }
    
    func saveDecodesRecordToCloudKit(sourceRecord: Decodes, syncName: String)
    {
        let predicate = NSPredicate(format: "(decode_name == \"\(sourceRecord.decode_name)\")") // better be accurate to get only the record you need
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
                        // We need to do a check of the number for the tables, as otherwise we risk overwriting the changes
                        
                        var updateRecord: Bool = true
                        
                        let record = records!.first// as! CKRecord
                        
                        switch sourceRecord.decode_name
                        {
                        case "Context" :
                            let localValue = Int(sourceRecord.decode_value)
                            let tempValue = record!.objectForKey("decode_value")! as CKRecordValue
                            let remoteValue = Int(tempValue as! String)
                            
                            if localValue > remoteValue
                            {
                                updateRecord = true
                            }
                            else
                            {
                                updateRecord = false
                            }
                            
                        case "Projects" :
                            let localValue = Int(sourceRecord.decode_value)
                            let tempValue = record!.objectForKey("decode_value")! as CKRecordValue
                            let remoteValue = Int(tempValue as! String)
                            
                            if localValue > remoteValue
                            {
                                updateRecord = true
                            }
                            else
                            {
                                updateRecord = false
                            }
                            
                        case "GTDItem" :
                            let localValue = Int(sourceRecord.decode_value)
                            let tempValue = record!.objectForKey("decode_value")! as CKRecordValue
                            let remoteValue = Int(tempValue as! String)
                            
                            if localValue > remoteValue
                            {
                                updateRecord = true
                            }
                            else
                            {
                                updateRecord = false
                            }
                            
                        case "Team" :
                            let localValue = Int(sourceRecord.decode_value)
                            let tempValue = record!.objectForKey("decode_value")! as CKRecordValue
                            let remoteValue = Int(tempValue as! String)
                            
                            if localValue > remoteValue
                            {
                                updateRecord = true
                            }
                            else
                            {
                                updateRecord = false
                            }
                            
                        case "Roles" :
                            let localValue = Int(sourceRecord.decode_value)
                            let tempValue = record!.objectForKey("decode_value")! as CKRecordValue
                            let remoteValue = Int(tempValue as! String)
                            
                            if localValue > remoteValue
                            {
                                updateRecord = true
                            }
                            else
                            {
                                updateRecord = false
                            }
                            
                        case "Task" :
                            let localValue = Int(sourceRecord.decode_value)
                            let tempValue = record!.objectForKey("decode_value")! as CKRecordValue
                            let remoteValue = Int(tempValue as! String)
                            
                            if localValue > remoteValue
                            {
                                updateRecord = true
                            }
                            else
                            {
                                updateRecord = false
                            }
                            
                        case "Device" :
                            let localValue = Int(sourceRecord.decode_value)
                            let tempValue = record!.objectForKey("decode_value")! as CKRecordValue
                            let remoteValue = Int(tempValue as! String)
                            
                            if localValue > remoteValue
                            {
                                updateRecord = true
                            }
                            else
                            {
                                updateRecord = false
                            }
                            
                        default:
                            updateRecord = true
                            
                            if sourceRecord.decode_name.hasPrefix("CloudKit Sync")
                            {
                                if syncName == sourceRecord.decode_name
                                {
                                    updateRecord = true
                                }
                                else
                                {
                                    updateRecord = false
                                }
                            }
                        }
                        
                        if updateRecord
                        {
                            // Now you have grabbed your existing record from iCloud
                            // Apply whatever changes you want
                            record!.setValue(sourceRecord.decode_value, forKey: "decode_value")
                            record!.setValue(sourceRecord.decodeType, forKey: "decodeType")
                            record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                            record!.setValue(sourceRecord.updateType, forKey: "updateType")
                            
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
                    else
                    {  // Insert
                        let todoRecord = CKRecord(recordType: "Decodes")
                        todoRecord.setValue(sourceRecord.decode_name, forKey: "decode_name")
                        todoRecord.setValue(sourceRecord.decodeType, forKey: "decodeType")
                        todoRecord.setValue(sourceRecord.decode_value, forKey: "decode_value")
                        todoRecord.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        todoRecord.setValue(sourceRecord.updateType, forKey: "updateType")
                        
                        self.privateDB.saveRecord(todoRecord, completionHandler: { (savedRecord, saveError) in
                            if saveError != nil
                            {
                                NSLog("Error saving record: \(saveError!.localizedDescription)")
                            }
                            else
                            {
                                if debugMessages
                                {
                                    NSLog("Successfully saved record! \(sourceRecord.decode_name)")
                                }
                            }
                        })
                    }
                }
            })

    }
    
    func saveGTDItemRecordToCloudKit(sourceRecord: GTDItem)
    {
        let predicate = NSPredicate(format: "(gTDItemID == \(sourceRecord.gTDItemID as! Int)) && (teamID == \(sourceRecord.teamID as! Int))")
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.gTDParentID, forKey: "gTDParentID")
                        record!.setValue(sourceRecord.lastReviewDate, forKey: "lastReviewDate")
                        record!.setValue(sourceRecord.note, forKey: "note")
                        record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        record!.setValue(sourceRecord.reviewFrequency, forKey: "reviewFrequency")
                        record!.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                        record!.setValue(sourceRecord.status, forKey: "status")
                        record!.setValue(sourceRecord.title, forKey: "title")
                        record!.setValue(sourceRecord.gTDLevel, forKey: "gTDLevel")
                        
                        
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
                        record.setValue(sourceRecord.gTDItemID, forKey: "gTDItemID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.gTDParentID, forKey: "gTDParentID")
                        record.setValue(sourceRecord.lastReviewDate, forKey: "lastReviewDate")
                        record.setValue(sourceRecord.note, forKey: "note")
                        record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        record.setValue(sourceRecord.reviewFrequency, forKey: "reviewFrequency")
                        record.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                        record.setValue(sourceRecord.status, forKey: "status")
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
                        record.setValue(sourceRecord.title, forKey: "title")
                        record.setValue(sourceRecord.gTDLevel, forKey: "gTDLevel")
                        
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
    }
    
    func saveGTDLevelRecordToCloudKit(sourceRecord: GTDLevel)
    {
        let predicate = NSPredicate(format: "(gTDLevel == \(sourceRecord.gTDLevel as! Int)) && (teamID == \(sourceRecord.teamID as! Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.levelName, forKey: "levelName")
                        
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
                        record.setValue(sourceRecord.gTDLevel, forKey: "gTDLevel")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
                        record.setValue(sourceRecord.levelName, forKey: "levelName")
                        
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
    }
    
    func saveMeetingAgendaRecordToCloudKit(sourceRecord: MeetingAgenda)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID)\") && (actualTeamID == \(sourceRecord.teamID as Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.chair, forKey: "chair")
                        record!.setValue(sourceRecord.endTime, forKey: "endTime")
                        record!.setValue(sourceRecord.location, forKey: "location")
                        record!.setValue(sourceRecord.minutes, forKey: "minutes")
                        record!.setValue(sourceRecord.minutesType, forKey: "minutesType")
                        record!.setValue(sourceRecord.name, forKey: "name")
                        record!.setValue(sourceRecord.previousMeetingID, forKey: "previousMeetingID")
                        record!.setValue(sourceRecord.startTime, forKey: "meetingStartTime")
                        
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
                        record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.chair, forKey: "chair")
                        record.setValue(sourceRecord.endTime, forKey: "endTime")
                        record.setValue(sourceRecord.location, forKey: "location")
                        record.setValue(sourceRecord.minutes, forKey: "minutes")
                        record.setValue(sourceRecord.minutesType, forKey: "minutesType")
                        record.setValue(sourceRecord.name, forKey: "name")
                        record.setValue(sourceRecord.previousMeetingID, forKey: "previousMeetingID")
                        record.setValue(sourceRecord.startTime, forKey: "meetingStartTime")
                        record.setValue(sourceRecord.teamID, forKey: "actualTeamID")
                        
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
    }
    
    func saveMeetingAgendaItemRecordToCloudKit(sourceRecord: MeetingAgendaItem)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID!)\") && (agendaID == \(sourceRecord.agendaID as! Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.actualEndTime, forKey: "actualEndTime")
                        record!.setValue(sourceRecord.actualStartTime, forKey: "actualStartTime")
                        record!.setValue(sourceRecord.decisionMade, forKey: "decisionMade")
                        record!.setValue(sourceRecord.discussionNotes, forKey: "discussionNotes")
                        record!.setValue(sourceRecord.owner, forKey: "owner")
                        record!.setValue(sourceRecord.status, forKey: "status")
                        record!.setValue(sourceRecord.timeAllocation, forKey: "timeAllocation")
                        record!.setValue(sourceRecord.title, forKey: "title")
                        record!.setValue(sourceRecord.meetingOrder, forKey: "meetingOrder")
                        
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
                        record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                        record.setValue(sourceRecord.agendaID, forKey: "agendaID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.actualEndTime, forKey: "actualEndTime")
                        record.setValue(sourceRecord.actualStartTime, forKey: "actualStartTime")
                        record.setValue(sourceRecord.decisionMade, forKey: "decisionMade")
                        record.setValue(sourceRecord.discussionNotes, forKey: "discussionNotes")
                        record.setValue(sourceRecord.owner, forKey: "owner")
                        record.setValue(sourceRecord.status, forKey: "status")
                        record.setValue(sourceRecord.timeAllocation, forKey: "timeAllocation")
                        record.setValue(sourceRecord.title, forKey: "title")
                        record.setValue(sourceRecord.meetingOrder, forKey: "meetingOrder")
                        
                        
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
    }
    
    func saveMeetingAttendeesRecordToCloudKit(sourceRecord: MeetingAttendees)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID)\") && (name = \"\(sourceRecord.name)\")") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.attendenceStatus, forKey: "attendenceStatus")
                        record!.setValue(sourceRecord.email, forKey: "email")
                        record!.setValue(sourceRecord.type, forKey: "type")
                        
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
                        record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                        record.setValue(sourceRecord.name, forKey: "name")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.attendenceStatus, forKey: "attendenceStatus")
                        record.setValue(sourceRecord.email, forKey: "email")
                        record.setValue(sourceRecord.type, forKey: "type")
                        
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
    }
    
    func saveMeetingSupportingDocsRecordToCloudKit(sourceRecord: MeetingSupportingDocs)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID)\") && (agendaID == \(sourceRecord.agendaID as Int))") // better be accurate to get only the
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.attachmentPath, forKey: "attachmentPath")
                        record!.setValue(sourceRecord.title, forKey: "title")
                        
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
                        record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                        record.setValue(sourceRecord.agendaID, forKey: "agendaID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.attachmentPath, forKey: "attachmentPath")
                        record.setValue(sourceRecord.title, forKey: "title")
                        
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
    }
    
    func saveMeetingTasksRecordToCloudKit(sourceRecord: MeetingTasks)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID)\") && (agendaID == \(sourceRecord.agendaID as Int)) && (taskID == \(sourceRecord.taskID as Int))") // better be accurate to get only the
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.taskID, forKey: "taskID")
                        
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
                        record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                        record.setValue(sourceRecord.agendaID, forKey: "agendaID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        
                        
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
    }
    
    func savePanesRecordToCloudKit(sourceRecord: Panes)
    {
        let predicate = NSPredicate(format: "(pane_name == \"\(sourceRecord.pane_name)\")") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.pane_available, forKey: "pane_available")
                        record!.setValue(sourceRecord.pane_order, forKey: "pane_order")
                        record!.setValue(sourceRecord.pane_visible, forKey: "pane_visible")
                        
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
                        record.setValue(sourceRecord.pane_name, forKey: "pane_name")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.pane_available, forKey: "pane_available")
                        record.setValue(sourceRecord.pane_order, forKey: "pane_order")
                        record.setValue(sourceRecord.pane_visible, forKey: "pane_visible")
                        
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
    }
    
    func saveProjectsRecordToCloudKit(sourceRecord: Projects)
    {
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID as Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
                if error != nil
                {
                    NSLog("Error querying records: \(error!.localizedDescription)")
                }
                else
                {
                    
                    // First need to get additional info from other table
                    
                    let tempProjectNote = myDatabaseConnection.getProjectNote(sourceRecord.projectID as Int)
                    
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.areaID, forKey: "areaID")
                        record!.setValue(sourceRecord.lastReviewDate, forKey: "lastReviewDate")
                        record!.setValue(sourceRecord.projectEndDate, forKey: "projectEndDate")
                        record!.setValue(sourceRecord.projectName, forKey: "projectName")
                        record!.setValue(sourceRecord.projectStartDate, forKey: "projectStartDate")
                        record!.setValue(sourceRecord.projectStatus, forKey: "projectStatus")
                        record!.setValue(sourceRecord.repeatBase, forKey: "repeatBase")
                        record!.setValue(sourceRecord.repeatInterval, forKey: "repeatInterval")
                        record!.setValue(sourceRecord.repeatType, forKey: "repeatType")
                        record!.setValue(sourceRecord.reviewFrequency, forKey: "reviewFrequency")
                        record!.setValue(sourceRecord.teamID, forKey: "teamID")
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
                        record.setValue(sourceRecord.projectID, forKey: "projectID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.areaID, forKey: "areaID")
                        record.setValue(sourceRecord.lastReviewDate, forKey: "lastReviewDate")
                        record.setValue(sourceRecord.projectEndDate, forKey: "projectEndDate")
                        record.setValue(sourceRecord.projectName, forKey: "projectName")
                        record.setValue(sourceRecord.projectStartDate, forKey: "projectStartDate")
                        record.setValue(sourceRecord.projectStatus, forKey: "projectStatus")
                        record.setValue(sourceRecord.repeatBase, forKey: "repeatBase")
                        record.setValue(sourceRecord.repeatInterval, forKey: "repeatInterval")
                        record.setValue(sourceRecord.repeatType, forKey: "repeatType")
                        record.setValue(sourceRecord.reviewFrequency, forKey: "reviewFrequency")
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
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
    }
    
    func saveProjectNoteRecordToCloudKit(sourceRecord: ProjectNote)
    {
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID as Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.note, forKey: "note")
                        record!.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                        record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        
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
                        record.setValue(sourceRecord.projectID, forKey: "projectID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.note, forKey: "note")
                        record.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                        record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        
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
    }

    func saveProjectTeamMembersRecordToCloudKit(sourceRecord: ProjectTeamMembers)
    {
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID as Int)) && (teamMember == \"\(sourceRecord.teamMember)\")") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.roleID, forKey: "roleID")
                        record!.setValue(sourceRecord.projectMemberNotes, forKey: "projectMemberNotes")
                        
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
                        record.setValue(sourceRecord.projectID, forKey: "projectID")
                        record.setValue(sourceRecord.teamMember, forKey: "teamMember")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.roleID, forKey: "roleID")
                        record.setValue(sourceRecord.projectMemberNotes, forKey: "projectMemberNotes")
                        
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
    }
    
    func saveRolesRecordToCloudKit(sourceRecord: Roles)
    {
        let predicate = NSPredicate(format: "(roleID == \(sourceRecord.roleID as Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.roleDescription, forKey: "roleDescription")
                        
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
                        record.setValue(sourceRecord.roleID, forKey: "roleID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
                        record.setValue(sourceRecord.roleDescription, forKey: "roleDescription")
                        
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
    }
    
    func saveStagesRecordToCloudKit(sourceRecord: Stages)
    {
        let predicate = NSPredicate(format: "(stageDescription == \"\(sourceRecord.stageDescription)\") && (teamID == \(sourceRecord.teamID as Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        
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
                        record.setValue(sourceRecord.stageDescription, forKey: "stageDescription")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
                        
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
    }

    func saveTaskRecordToCloudKit(sourceRecord: Task)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.completionDate, forKey: "completionDate")
                        record!.setValue(sourceRecord.details, forKey: "details")
                        record!.setValue(sourceRecord.dueDate, forKey: "dueDate")
                        record!.setValue(sourceRecord.energyLevel, forKey: "energyLevel")
                        record!.setValue(sourceRecord.estimatedTime, forKey: "estimatedTime")
                        record!.setValue(sourceRecord.estimatedTimeType, forKey: "estimatedTimeType")
                        record!.setValue(sourceRecord.flagged, forKey: "flagged")
                        record!.setValue(sourceRecord.priority, forKey: "priority")
                        record!.setValue(sourceRecord.repeatBase, forKey: "repeatBase")
                        record!.setValue(sourceRecord.repeatInterval, forKey: "repeatInterval")
                        record!.setValue(sourceRecord.repeatType, forKey: "repeatType")
                        record!.setValue(sourceRecord.startDate, forKey: "startDate")
                        record!.setValue(sourceRecord.status, forKey: "status")
                        record!.setValue(sourceRecord.title, forKey: "title")
                        record!.setValue(sourceRecord.urgency, forKey: "urgency")
                        record!.setValue(sourceRecord.projectID, forKey: "projectID")
                        record!.setValue(sourceRecord.teamID, forKey: "teamID")
                        
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
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.completionDate, forKey: "completionDate")
                        record.setValue(sourceRecord.details, forKey: "details")
                        record.setValue(sourceRecord.dueDate, forKey: "dueDate")
                        record.setValue(sourceRecord.energyLevel, forKey: "energyLevel")
                        record.setValue(sourceRecord.estimatedTime, forKey: "estimatedTime")
                        record.setValue(sourceRecord.estimatedTimeType, forKey: "estimatedTimeType")
                        record.setValue(sourceRecord.flagged, forKey: "flagged")
                        record.setValue(sourceRecord.priority, forKey: "priority")
                        record.setValue(sourceRecord.repeatBase, forKey: "repeatBase")
                        record.setValue(sourceRecord.repeatInterval, forKey: "repeatInterval")
                        record.setValue(sourceRecord.repeatType, forKey: "repeatType")
                        record.setValue(sourceRecord.startDate, forKey: "startDate")
                        record.setValue(sourceRecord.status, forKey: "status")
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
                        record.setValue(sourceRecord.title, forKey: "title")
                        record.setValue(sourceRecord.urgency, forKey: "urgency")
                        record.setValue(sourceRecord.projectID, forKey: "projectID")
                        
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
    }
    
    func saveTaskAttachmentRecordToCloudKit(sourceRecord: TaskAttachment)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as Int)) && (title == \"\(sourceRecord.title)\")") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.attachment, forKey: "attachment")
                        
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
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        record.setValue(sourceRecord.title, forKey: "title")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.attachment, forKey: "attachment")
                        
                        
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
    }
    
    func saveTaskContextRecordToCloudKit(sourceRecord: TaskContext)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as Int)) && (contextID == \(sourceRecord.contextID as Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        
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
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        record.setValue(sourceRecord.contextID, forKey: "contextID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        
                        
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
    }
    
    func saveTaskPredecessorRecordToCloudKit(sourceRecord: TaskPredecessor)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as Int)) && (predecessorID == \(sourceRecord.predecessorID as Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.predecessorType, forKey: "predecessorType")
                        
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
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        record.setValue(sourceRecord.predecessorID, forKey: "predecessorID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.predecessorType, forKey: "predecessorType")
                        
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
    }
    
    func saveTaskUpdatesRecordToCloudKit(sourceRecord: TaskUpdates)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as Int)) && (updateDate == %@)", sourceRecord.updateDate) // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.details, forKey: "details")
                        record!.setValue(sourceRecord.source, forKey: "source")
                        
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
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        record.setValue(sourceRecord.updateDate, forKey: "updateDate")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.details, forKey: "details")
                        record.setValue(sourceRecord.source, forKey: "source")
                        
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
    }
    
    func saveTeamRecordToCloudKit(sourceRecord: Team)
    {
        let predicate = NSPredicate(format: "(teamID == \(sourceRecord.teamID as Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.name, forKey: "name")
                        record!.setValue(sourceRecord.note, forKey: "note")
                        record!.setValue(sourceRecord.status, forKey: "status")
                        record!.setValue(sourceRecord.type, forKey: "type")
                        record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        record!.setValue(sourceRecord.externalID, forKey: "externalID")
                        
                        
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
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.name, forKey: "name")
                        record.setValue(sourceRecord.note, forKey: "note")
                        record.setValue(sourceRecord.status, forKey: "status")
                        record.setValue(sourceRecord.type, forKey: "type")
                        record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        record.setValue(sourceRecord.externalID, forKey: "externalID")
                        
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
    }
    
    func saveProcessedEmailsRecordToCloudKit(sourceRecord: ProcessedEmails)
    {
        let predicate = NSPredicate(format: "(emailID == \"\(sourceRecord.emailID!)\")") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.emailType, forKey: "emailType")
                        record!.setValue(sourceRecord.processedDate, forKey: "processedDate")
                        
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
                        record.setValue(sourceRecord.emailID, forKey: "emailID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.emailType, forKey: "emailType")
                        record.setValue(sourceRecord.processedDate, forKey: "processedDate")
                        
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
    }

    private func updateContextRecord(sourceRecord: CKRecord)
    {
        var predecessor: Int = 0
        
        let contextID = sourceRecord.objectForKey("contextID") as! Int
        let autoEmail = sourceRecord.objectForKey("autoEmail") as! String
        let email = sourceRecord.objectForKey("email") as! String
        let name = sourceRecord.objectForKey("name") as! String
        let parentContext = sourceRecord.objectForKey("parentContext") as! Int
        let personID = sourceRecord.objectForKey("personID") as! Int
        let status = sourceRecord.objectForKey("status") as! String
        let teamID = sourceRecord.objectForKey("teamID") as! Int
        let contextType = sourceRecord.objectForKey("contextType") as! String
        
        if sourceRecord.objectForKey("predecessor") != nil
        {
            predecessor = sourceRecord.objectForKey("predecessor") as! Int
        }
        
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }

        myDatabaseConnection.saveContext(contextID, inName: name, inEmail: email, inAutoEmail: autoEmail, inParentContext: parentContext, inStatus: status, inPersonID: personID, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
        
        myDatabaseConnection.saveContext1_1(contextID, predecessor: predecessor, contextType: contextType, updateTime: updateTime, updateType: updateType)
    }

    private func updateDecodeRecord(sourceRecord: CKRecord)
    {
        let decodeName = sourceRecord.objectForKey("decode_name") as! String
        let decodeValue = sourceRecord.objectForKey("decode_value") as! String
        let decodeType = sourceRecord.objectForKey("decodeType") as! String
        
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
    
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        
        myDatabaseConnection.updateDecodeValue(decodeName, inCodeValue: decodeValue, inCodeType: decodeType, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateGTDItemRecord(sourceRecord: CKRecord)
    {
        let gTDItemID = sourceRecord.objectForKey("gTDItemID") as! Int
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let gTDParentID = sourceRecord.objectForKey("gTDParentID") as! Int
        let lastReviewDate = sourceRecord.objectForKey("lastReviewDate") as! NSDate
        let note = sourceRecord.objectForKey("note") as! String
        let predecessor = sourceRecord.objectForKey("predecessor") as! Int
        let reviewFrequency = sourceRecord.objectForKey("reviewFrequency") as! Int
        let reviewPeriod = sourceRecord.objectForKey("reviewPeriod") as! String
        let status = sourceRecord.objectForKey("status") as! String
        let teamID = sourceRecord.objectForKey("teamID") as! Int
        let title = sourceRecord.objectForKey("title") as! String
        let gTDLevel = sourceRecord.objectForKey("gTDLevel") as! Int
        
        myDatabaseConnection.saveGTDItem(gTDItemID, inParentID: gTDParentID, inTitle: title, inStatus: status, inTeamID: teamID, inNote: note, inLastReviewDate: lastReviewDate, inReviewFrequency: reviewFrequency, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inGTDLevel: gTDLevel, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateGTDLevelRecord(sourceRecord: CKRecord)
    {
        let gTDLevel = sourceRecord.objectForKey("gTDLevel") as! Int
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let teamID = sourceRecord.objectForKey("teamID") as! Int
        let levelName = sourceRecord.objectForKey("levelName") as! String
        
        myDatabaseConnection.saveGTDLevel(gTDLevel, inLevelName: levelName, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateMeetingAgendaRecord(sourceRecord: CKRecord)
    {
        let meetingID = sourceRecord.objectForKey("meetingID") as! String
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let chair = sourceRecord.objectForKey("chair") as! String
        let endTime = sourceRecord.objectForKey("endTime") as! NSDate
        let location = sourceRecord.objectForKey("location") as! String
        let minutes = sourceRecord.objectForKey("minutes") as! String
        let minutesType = sourceRecord.objectForKey("minutesType") as! String
        let name = sourceRecord.objectForKey("name") as! String
        let previousMeetingID = sourceRecord.objectForKey("previousMeetingID") as! String
        let startTime = sourceRecord.objectForKey("meetingStartTime") as! NSDate
        let teamID = sourceRecord.objectForKey("actualTeamID") as! Int
        
        myDatabaseConnection.saveAgenda(meetingID, inPreviousMeetingID : previousMeetingID, inName: name, inChair: chair, inMinutes: minutes, inLocation: location, inStartTime: startTime, inEndTime: endTime, inMinutesType: minutesType, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateMeetingAgendaItemRecord(sourceRecord: CKRecord)
    {
        let meetingID = sourceRecord.objectForKey("meetingID") as! String
        let agendaID = sourceRecord.objectForKey("agendaID") as! Int
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        var actualEndTime: NSDate!
        if sourceRecord.objectForKey("actualEndTime") != nil
        {
            actualEndTime = sourceRecord.objectForKey("actualEndTime") as! NSDate
        }
        else
        {
            actualEndTime = getDefaultDate()
        }
        var actualStartTime: NSDate!
        if sourceRecord.objectForKey("actualStartTime") != nil
        {
            actualStartTime = sourceRecord.objectForKey("actualStartTime") as! NSDate
        }
        else
        {
            actualStartTime = getDefaultDate()
        }
        let decisionMade = sourceRecord.objectForKey("decisionMade") as! String
        let discussionNotes = sourceRecord.objectForKey("discussionNotes") as! String
        let owner = sourceRecord.objectForKey("owner") as! String
        let status = sourceRecord.objectForKey("status") as! String
        let timeAllocation = sourceRecord.objectForKey("timeAllocation") as! Int
        let title = sourceRecord.objectForKey("title") as! String
        let meetingOrder = sourceRecord.objectForKey("meetingOrder") as! Int
        
        myDatabaseConnection.saveAgendaItem(meetingID, actualEndTime: actualEndTime, actualStartTime: actualStartTime, status: status, decisionMade: decisionMade, discussionNotes: discussionNotes, timeAllocation: timeAllocation, owner: owner, title: title, agendaID: agendaID, meetingOrder: meetingOrder, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateMeetingAttendeesRecord(sourceRecord: CKRecord)
    {
        let meetingID = sourceRecord.objectForKey("meetingID") as! String
        let name  = sourceRecord.objectForKey("name") as! String
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let attendenceStatus = sourceRecord.objectForKey("attendenceStatus") as! String
        let email = sourceRecord.objectForKey("email") as! String
        let type = sourceRecord.objectForKey("type") as! String
        
        myDatabaseConnection.saveAttendee(meetingID, name: name, email: email,  type: type, status: attendenceStatus, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateMeetingSupportingDocsRecord(sourceRecord: CKRecord)
    {
      //  let meetingID = sourceRecord.objectForKey("meetingID") as! String
        //              let agendaID = sourceRecord.objectForKey("agendaID") as! Int
        //        var updateTime = NSDate()
        //        if sourceRecord.objectForKey("updateTime") != nil
        //        {
        //            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        //        }
        
        //       var updateType = ""
        
        //      if sourceRecord.objectForKey("updateType") != nil
        //      {
        //          updateType = sourceRecord.objectForKey("updateType") as! String
        //      }
        //              let attachmentPath = sourceRecord.objectForKey("attachmentPath") as! String
        //              let title = sourceRecord.objectForKey("title") as! String
        
        NSLog("updateMeetingSupportingDocsInCoreData - Need to have the save for this")
        
        // myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
    }
    
    private func updateMeetingTasksRecord(sourceRecord: CKRecord)
    {
        let meetingID = sourceRecord.objectForKey("meetingID") as! String
        let agendaID = sourceRecord.objectForKey("agendaID") as! Int
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let taskID = sourceRecord.objectForKey("taskID") as! Int
        
        myDatabaseConnection.saveMeetingTask(agendaID, meetingID: meetingID, taskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updatePanesRecord(sourceRecord: CKRecord)
    {
        let pane_name = sourceRecord.objectForKey("pane_name") as! String
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let pane_available = sourceRecord.objectForKey("pane_available") as! Bool
        let pane_order = sourceRecord.objectForKey("pane_order") as! Int
        let pane_visible = sourceRecord.objectForKey("pane_visible") as! Bool
        
        myDatabaseConnection.savePane(pane_name, inPaneAvailable: pane_available, inPaneVisible: pane_visible, inPaneOrder: pane_order, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateProjectsRecord(sourceRecord: CKRecord)
    {
        let projectID = sourceRecord.objectForKey("projectID") as! Int
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let areaID = sourceRecord.objectForKey("areaID") as! Int
        let lastReviewDate = sourceRecord.objectForKey("lastReviewDate") as! NSDate
        let projectEndDate = sourceRecord.objectForKey("projectEndDate") as! NSDate
        let projectName = sourceRecord.objectForKey("projectName") as! String
        let projectStartDate = sourceRecord.objectForKey("projectStartDate") as! NSDate
        let projectStatus = sourceRecord.objectForKey("projectStatus") as! String
        let repeatBase = sourceRecord.objectForKey("repeatBase") as! String
        let repeatInterval = sourceRecord.objectForKey("repeatInterval") as! Int
        let repeatType = sourceRecord.objectForKey("repeatType") as! String
        let reviewFrequency = sourceRecord.objectForKey("reviewFrequency") as! Int
        let teamID = sourceRecord.objectForKey("teamID") as! Int
        let note = sourceRecord.objectForKey("note") as! String
        let reviewPeriod = sourceRecord.objectForKey("reviewPeriod") as! String
        let predecessor = sourceRecord.objectForKey("predecessor") as! Int
        
        myDatabaseConnection.saveProject(projectID, inProjectEndDate: projectEndDate, inProjectName: projectName, inProjectStartDate: projectStartDate, inProjectStatus: projectStatus, inReviewFrequency: reviewFrequency, inLastReviewDate: lastReviewDate, inGTDItemID: areaID, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
        
        myDatabaseConnection.saveProjectNote(projectID, inNote: note, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateProjectTeamMembersRecord(sourceRecord: CKRecord)
    {
        let projectID = sourceRecord.objectForKey("projectID") as! Int
        let teamMember = sourceRecord.objectForKey("teamMember") as! String
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let roleID = sourceRecord.objectForKey("roleID") as! Int
        let projectMemberNotes = sourceRecord.objectForKey("projectMemberNotes") as! String
        
        myDatabaseConnection.saveTeamMember(projectID, inRoleID: roleID, inPersonName: teamMember, inNotes: projectMemberNotes, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateRolesRecord(sourceRecord: CKRecord)
    {
        let roleID = sourceRecord.objectForKey("roleID") as! Int
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let teamID = sourceRecord.objectForKey("teamID") as! Int
        let roleDescription = sourceRecord.objectForKey("roleDescription") as! String
        
        myDatabaseConnection.saveCloudRole(roleDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType, roleID: roleID)
    }
    
    private func updateStagesRecord(sourceRecord: CKRecord)
    {
        let stageDescription = sourceRecord.objectForKey("stageDescription") as! String
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let teamID = sourceRecord.objectForKey("teamID") as! Int
        
        myDatabaseConnection.saveStage(stageDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateTaskRecord(sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.objectForKey("taskID") as! Int
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let completionDate = sourceRecord.objectForKey("completionDate") as! NSDate
        let details = sourceRecord.objectForKey("details") as! String
        let dueDate = sourceRecord.objectForKey("dueDate") as! NSDate
        let energyLevel = sourceRecord.objectForKey("energyLevel") as! String
        let estimatedTime = sourceRecord.objectForKey("estimatedTime") as! Int
        let estimatedTimeType = sourceRecord.objectForKey("estimatedTimeType") as! String
        let flagged = sourceRecord.objectForKey("flagged") as! Bool
        let priority = sourceRecord.objectForKey("priority") as! String
        let repeatBase = sourceRecord.objectForKey("repeatBase") as! String
        let repeatInterval = sourceRecord.objectForKey("repeatInterval") as! Int
        let repeatType = sourceRecord.objectForKey("repeatType") as! String
        let startDate = sourceRecord.objectForKey("startDate") as! NSDate
        let status = sourceRecord.objectForKey("status") as! String
        let teamID = sourceRecord.objectForKey("teamID") as! Int
        let title = sourceRecord.objectForKey("title") as! String
        let urgency = sourceRecord.objectForKey("urgency") as! String
        let projectID = sourceRecord.objectForKey("projectID") as! Int
        
        myDatabaseConnection.saveTask(taskID, inTitle: title, inDetails: details, inDueDate: dueDate, inStartDate: startDate, inStatus: status, inPriority: priority, inEnergyLevel: energyLevel, inEstimatedTime: estimatedTime, inEstimatedTimeType: estimatedTimeType, inProjectID: projectID, inCompletionDate: completionDate, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inFlagged: flagged, inUrgency: urgency, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateTaskAttachmentRecord(sourceRecord: CKRecord)
    {
        //    let taskID = sourceRecord.objectForKey("taskID") as! Int
        //    let title = sourceRecord.objectForKey("title") as! String
        //        var updateTime = NSDate()
        //        if sourceRecord.objectForKey("updateTime") != nil
        //        {
        //            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        //        }
        
        //        var updateType = ""
        
        //       if sourceRecord.objectForKey("updateType") != nil
        //       {
        //           updateType = sourceRecord.objectForKey("updateType") as! String
        //       }
        //    let attachment = sourceRecord.objectForKey("attachment") as! NSData
        NSLog("updateTaskAttachmentInCoreData - Still to be coded")
        //   myDatabaseConnection.updateDecodeValue(decodeName! as! String, inCodeValue: decodeValue! as! String, inCodeType: decodeType! as! String)
    }
    
    private func updateTaskContextRecord(sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.objectForKey("taskID") as! Int
        let contextID = sourceRecord.objectForKey("contextID") as! Int
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        
        myDatabaseConnection.saveTaskContext(contextID, inTaskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateTaskPredecessorRecord(sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.objectForKey("taskID") as! Int
        let predecessorID = sourceRecord.objectForKey("predecessorID") as! Int
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let predecessorType = sourceRecord.objectForKey("predecessorType") as! String
        
        myDatabaseConnection.savePredecessorTask(taskID, inPredecessorID: predecessorID, inPredecessorType: predecessorType, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateTaskUpdatesRecord(sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.objectForKey("taskID") as! Int
        let updateDate = sourceRecord.objectForKey("updateDate") as! NSDate
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let details = sourceRecord.objectForKey("details") as! String
        let source = sourceRecord.objectForKey("source") as! String
        
        myDatabaseConnection.saveTaskUpdate(taskID, inDetails: details, inSource: source, inUpdateDate: updateDate, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateTeamRecord(sourceRecord: CKRecord)
    {
        let teamID = sourceRecord.objectForKey("teamID") as! Int
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let name = sourceRecord.objectForKey("name") as! String
        let note = sourceRecord.objectForKey("note") as! String
        let status = sourceRecord.objectForKey("status") as! String
        let type = sourceRecord.objectForKey("type") as! String
        let predecessor = sourceRecord.objectForKey("predecessor") as! Int
        let externalID = sourceRecord.objectForKey("externalID") as! Int
        
        myDatabaseConnection.saveTeam(teamID, inName: name, inStatus: status, inNote: note, inType: type, inPredecessor: predecessor, inExternalID: externalID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    private func updateProcessedEmailsRecord(sourceRecord: CKRecord)
    {
        let emailID = sourceRecord.objectForKey("emailID") as! String
        var updateTime = NSDate()
        if sourceRecord.objectForKey("updateTime") != nil
        {
            updateTime = sourceRecord.objectForKey("updateTime") as! NSDate
        }
        
        var updateType = ""
        
        if sourceRecord.objectForKey("updateType") != nil
        {
            updateType = sourceRecord.objectForKey("updateType") as! String
        }
        let emailType = sourceRecord.objectForKey("emailType") as! String
        let processedDate = sourceRecord.objectForKey("processedDate") as! NSDate
        
        myDatabaseConnection.saveProcessedEmail(emailID, emailType: emailType, processedDate: processedDate, updateTime: updateTime, updateType: updateType)
    }
    
    private func createSubscription(sourceTable:String, sourceQuery: String)
    {
        let predicate: NSPredicate = NSPredicate(format: sourceQuery)
        let subscription = CKSubscription(recordType: sourceTable, predicate: predicate, options: [CKSubscriptionOptions.FiresOnRecordCreation, CKSubscriptionOptions.FiresOnRecordUpdate])
        
        let notification = CKNotificationInfo()
        
        subscription.notificationInfo = notification
        
        let sem = dispatch_semaphore_create(0);
        
        NSLog("Creating subscription for \(sourceTable)")
        
        self.privateDB.saveSubscription(subscription) { (result, error) -> Void in
            if error != nil
            {
                print("Table = \(sourceTable)  Error = \(error!.localizedDescription)")
            }
            
            dispatch_semaphore_signal(sem)
        }

        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
    }
    
    func setupSubscriptions()
    {
        // Setup notification
        
        let sem = dispatch_semaphore_create(0);
        
        privateDB.fetchAllSubscriptionsWithCompletionHandler() { [unowned self] (subscriptions, error) -> Void in
            if error == nil
            {
                if let subscriptions = subscriptions
                {
                    for subscription in subscriptions
                    {
                        self.privateDB.deleteSubscriptionWithID(subscription.subscriptionID, completionHandler: { (str, error) -> Void in
                            if error != nil
                            {
                                // do your error handling here!
                                print(error!.localizedDescription)
                            }
                        })

                    }
                }
            }
            else
            {
                // do your error handling here!
                print(error!.localizedDescription)
            }
            dispatch_semaphore_signal(sem)
        }
    
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
        createSubscription("Context", sourceQuery: "contextID > -1")
        
        createSubscription("Decodes", sourceQuery: "decode_name != ''")
        
        createSubscription("GTDItem", sourceQuery: "gTDItemID > -1")
        
        createSubscription("GTDLevel", sourceQuery: "gTDLevel > -1")
        
        createSubscription("MeetingTasks", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingAgenda", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingAgendaItem", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingAttendees", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingSupportingDocs", sourceQuery: "meetingID != ''")
        
        createSubscription("Panes", sourceQuery: "pane_name != ''")
        
        createSubscription("ProcessedEmails", sourceQuery: "emailID != ''")
        
        createSubscription("Projects", sourceQuery: "projectID > -1")
        
        createSubscription("ProjectTeamMembers", sourceQuery: "projectID > -1")
        
        createSubscription("Stages", sourceQuery: "stageDescription != ''")
        
        createSubscription("Roles", sourceQuery:  "roleDescription != ''")
        
        createSubscription("Task", sourceQuery: "taskID > -1")
            
        createSubscription("TaskAttachment", sourceQuery: "taskID > -1")
                
        createSubscription("TaskContext", sourceQuery: "taskID > -1")
                    
        createSubscription("TaskPredecessor", sourceQuery: "taskID > -1")
                        
        createSubscription("TaskUpdates", sourceQuery: "taskID > -1")
                            
        createSubscription("Team", sourceQuery: "teamID > -1")
    }
    
    func getRecords(sourceID: CKRecordID)
    {
  //      NSLog("source record = \(sourceID)")
        
        privateDB.fetchRecordWithID(sourceID)
        { (record, error) -> Void in
            if error == nil
            {
//                NSLog("record = \(record)")
                
//                NSLog("recordtype = \(record!.recordType)")

                switch record!.recordType
                {
                    case "Context" :
                        self.updateContextRecord(record!)

                    case "Decodes" :
                        self.updateDecodeRecord(record!)
                    
                    case "GTDItem" :
                        self.updateGTDItemRecord(record!)
                    
                    case "GTDLevel" :
                        self.updateGTDLevelRecord(record!)
                    
                    case "MeetingTasks" :
                        self.updateMeetingTasksRecord(record!)
                    
                    case "MeetingAgenda" :
                        self.updateMeetingAgendaRecord(record!)
                    
                    case "MeetingAgendaItem" :
                        self.updateMeetingAgendaItemRecord(record!)
                    
                    case "MeetingAttendees" :
                        self.updateMeetingAttendeesRecord(record!)
                    
                    case "MeetingSupportingDocs" :
                        self.updateMeetingSupportingDocsRecord(record!)
                    
                    case "Panes" :
                        self.updatePanesRecord(record!)
                    
                    case "ProcessedEmails" :
                        self.updateProcessedEmailsRecord(record!)
                    
                    case "Projects" :
                        self.updateProjectsRecord(record!)
                    
                    case "ProjectTeamMembers" :
                        self.updateProjectTeamMembersRecord(record!)
                    
                    case "Stages" :
                        self.updateStagesRecord(record!)
                    
                    case "Roles" :
                        self.updateRolesRecord(record!)
                    
                    case "Task" :
                        self.updateTaskRecord(record!)
                    
                    case "TaskAttachment" :
                        self.updateTaskAttachmentRecord(record!)
                    
                    case "TaskContext" :
                        self.updateTaskContextRecord(record!)
                    
                    case "TaskPredecessor" :
                        self.updateTaskPredecessorRecord(record!)
                    
                    case "TaskUpdates" :
                        self.updateTaskUpdatesRecord(record!)
                    
                    case "Team" :
                        self.updateTeamRecord(record!)
                    
                    default:
                        NSLog("getRecords error in switch")
                }
            }
            else
            {
                NSLog("Error = \(error)")
            }
        }
    }
}
