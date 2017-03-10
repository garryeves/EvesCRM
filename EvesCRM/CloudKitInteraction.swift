//
//  CloudKitInteraction.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 15/09/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol ModelDelegate {
    func errorUpdating(_ error: Error)
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
            container = CKContainer.default()
        #elseif os(OSX)
            container = CKContainer.init(identifier: "iCloud.com.garryeves.EvesCRM")
        #else
            NSLog("Unexpected OS")
        #endif

        publicDB = container.publicCloudDatabase // data saved here can be seen by all users
        privateDB = container.privateCloudDatabase // this is the one to use to save the data
        
        userInfo = UserInfo(container: container)        
    }
    
    func saveContextToCloudKit(_ inLastSyncDate: NSDate)
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

    func saveDecodesToCloudKit(_ inLastSyncDate: NSDate, syncName: String)
    {
//        NSLog("Syncing Decodes")
        for myItem in myDatabaseConnection.getDecodesForSync(inLastSyncDate)
        {
            saveDecodesRecordToCloudKit(myItem, syncName: syncName)
        }
    }

    func saveGTDItemToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing GTDItem")
        for myItem in myDatabaseConnection.getGTDItemsForSync(inLastSyncDate)
        {
            saveGTDItemRecordToCloudKit(myItem)
        }
    }
    
    func saveGTDLevelToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing GTDLevel")
        for myItem in myDatabaseConnection.getGTDLevelsForSync(inLastSyncDate)
        {
            saveGTDLevelRecordToCloudKit(myItem)
        }
    }

    func saveMeetingAgendaToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Meeting Agenda")
        for myItem in myDatabaseConnection.getMeetingAgendasForSync(inLastSyncDate)
        {
            saveMeetingAgendaRecordToCloudKit(myItem)
        }
    }
    
    func saveMeetingAgendaItemToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing meetingAgendaItems")
        for myItem in myDatabaseConnection.getMeetingAgendaItemsForSync(inLastSyncDate)
        {
            saveMeetingAgendaItemRecordToCloudKit(myItem)
        }
    }
    
    func saveMeetingAttendeesToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing MeetingAttendees")
        for myItem in myDatabaseConnection.getMeetingAttendeesForSync(inLastSyncDate)
        {
            saveMeetingAttendeesRecordToCloudKit(myItem)
        }
    }
    
    func saveMeetingSupportingDocsToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing MeetingSupportingDocs")
        for myItem in myDatabaseConnection.getMeetingSupportingDocsForSync(inLastSyncDate)
        {
            saveMeetingSupportingDocsRecordToCloudKit(myItem)
        }
    }
    
    func saveMeetingTasksToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing MeetingTasks")
        for myItem in myDatabaseConnection.getMeetingTasksForSync(inLastSyncDate)
        {
            saveMeetingTasksRecordToCloudKit(myItem)
        }
    }
    
    func savePanesToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Panes")
        for myItem in myDatabaseConnection.getPanesForSync(inLastSyncDate)
        {
            savePanesRecordToCloudKit(myItem)
        }
    }
    
    func saveProjectsToCloudKit(_ inLastSyncDate: NSDate)
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
    
    func saveProjectTeamMembersToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing ProjectTeamMembers")
        for myItem in myDatabaseConnection.getProjectTeamMembersForSync(inLastSyncDate)
        {
            saveProjectTeamMembersRecordToCloudKit(myItem)
        }
    }
    
    func saveRolesToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Roles")
        for myItem in myDatabaseConnection.getRolesForSync(inLastSyncDate)
        {
            saveRolesRecordToCloudKit(myItem)
        }
    }
    
    func saveStagesToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Stages")
        for myItem in myDatabaseConnection.getStagesForSync(inLastSyncDate)
        {
            saveStagesRecordToCloudKit(myItem)
        }
    }
    
    func saveTaskToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Task")
        for myItem in myDatabaseConnection.getTaskForSync(inLastSyncDate)
        {
            saveTaskRecordToCloudKit(myItem)
        }
    }
    
    func saveTaskAttachmentToCloudKit(_ inLastSyncDate: NSDate)
    {
 //       NSLog("Syncing taskAttachments")
        for myItem in myDatabaseConnection.getTaskAttachmentsForSync(inLastSyncDate)
        {
            saveTaskAttachmentRecordToCloudKit(myItem)
        }
    }
    
    func saveTaskContextToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing TaskContext")
        for myItem in myDatabaseConnection.getTaskContextsForSync(inLastSyncDate)
        {
            saveTaskContextRecordToCloudKit(myItem)
        }
    }
    
    func saveTaskPredecessorToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing TaskPredecessor")
        for myItem in myDatabaseConnection.getTaskPredecessorsForSync(inLastSyncDate)
        {
            saveTaskPredecessorRecordToCloudKit(myItem)
        }
    }
    
    func saveTaskUpdatesToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing TaskUpdates")
        for myItem in myDatabaseConnection.getTaskUpdatesForSync(inLastSyncDate)
        {
            saveTaskUpdatesRecordToCloudKit(myItem)
        }
    }
    
    func saveTeamToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing Team")
        for myItem in myDatabaseConnection.getTeamsForSync(inLastSyncDate)
        {
            saveTeamRecordToCloudKit(myItem)
        }
    }
    
    func saveProcessedEmailsToCloudKit(_ inLastSyncDate: NSDate)
    {
//        NSLog("Syncing ProcessedEmails")
        for myItem in myDatabaseConnection.getProcessedEmailsForSync(inLastSyncDate)
        {
            saveProcessedEmailsRecordToCloudKit(myItem)
        }
    }
    
    func saveOutlineToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing ProcessedEmails")
        for myItem in myDatabaseConnection.getOutlineForSync(inLastSyncDate)
        {
            saveOutlineRecordToCloudKit(myItem)
        }
    }
    
    func saveOutlineDetailsToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing ProcessedEmails")
        for myItem in myDatabaseConnection.getOutlineDetailsForSync(inLastSyncDate)
        {
            saveOutlineDetailsRecordToCloudKit(myItem)
        }
    }
    
    func updateContextInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateContextRecord(record)
            }
            sem.signal()
        })
        
    }
    
    func updateDecodesInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);

        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Decodes", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateDecodeRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateGTDItemInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateGTDItemRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateGTDLevelInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateGTDLevelRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateMeetingAgendaInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateMeetingAgendaRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateMeetingAgendaItemInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateMeetingAgendaItemRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateMeetingAttendeesInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAttendees", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateMeetingAttendeesRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateMeetingSupportingDocsInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingSupportingDocs", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
           // for record in results!
            for _ in results!
            {
  //              self.updateMeetingSupportingDocsRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateMeetingTasksInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateMeetingTasksRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updatePanesInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Panes", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updatePanesRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateProjectsInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateProjectsRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateProjectTeamMembersInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateProjectTeamMembersRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateRolesInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateRolesRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateStagesInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Stages", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateStagesRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateTaskInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateTaskRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateTaskAttachmentInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskAttachment", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
         //   for record in results!
            for record in results!
            {
                self.updateTaskAttachmentRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateTaskContextInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateTaskContextRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateTaskPredecessorInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateTaskPredecessorRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateTaskUpdatesInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateTaskUpdatesRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateTeamInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateTeamRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateProcessedEmailsInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "ProcessedEmails", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateProcessedEmailsRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateOutlineInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Outline", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateOutlineRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func updateOutlineDetailsInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "OutlineDetails", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateOutlineDetailsRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func deleteContext()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            sem.signal()
        })
        
        sem.wait()
        
        var myRecordList2: [CKRecordID] = Array()
        let predicate2: NSPredicate = NSPredicate(value: true)
        let query2: CKQuery = CKQuery(recordType: "Context1_1", predicate: predicate2)
        privateDB.perform(query2, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList2.append(record.recordID)
            }
            self.performDelete(myRecordList2)
            sem.signal()
        })
        sem.wait()
    }
    
    func deleteDecodes()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Decodes", predicate: predicate)
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
    
    func deleteGTDItem()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
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
    
    func deleteGTDLevel()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
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
    
    func deleteMeetingAgenda()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
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
    
    func deleteMeetingAgendaItem()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
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
    
    func deleteMeetingSupportingDocs()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingSupportingDocs", predicate: predicate)
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
    
    func deleteMeetingTasks()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
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
    
    func deletePanes()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Panes", predicate: predicate)
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
    
    func deleteProjects()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            sem.signal()
        })
        sem.wait()
        
        var myRecordList2: [CKRecordID] = Array()
        let predicate2: NSPredicate = NSPredicate(value: true)
        let query2: CKQuery = CKQuery(recordType: "ProjectNote", predicate: predicate2)
        privateDB.perform(query2, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList2.append(record.recordID)
            }
            self.performDelete(myRecordList2)
            sem.signal()
        })
        sem.wait()
    }
    
    func deleteProjectTeamMembers()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
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
    
    func deleteRoles()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
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
    
    func deleteStages()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Stages", predicate: predicate)
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
    
    func deleteTask()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
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
    
    func deleteTaskAttachment()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskAttachment", predicate: predicate)
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
    
    func deleteTaskContext()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
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
    
    func deleteTaskPredecessor()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
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
    
    func deleteTaskUpdates()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
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
    
    func deleteProcessedEmails()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "ProcessedEmails", predicate: predicate)
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
 
    func deleteOutline()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Outline", predicate: predicate)
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
    
    func deleteOutlineDetails()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "OutlineDetails", predicate: predicate)
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

    func performDelete(_ inRecordSet: [CKRecordID])
    {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: inRecordSet)
        operation.savePolicy = .allKeys
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
        
        let queue = OperationQueue()
        queue.addOperations([operation], waitUntilFinished: true)
      //  privateDB.addOperation(operation, waitUntilFinished: true)
     //   NSLog("finished delete")
    }
    
    func replaceContextInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "Context", predicate: predicate)
        var predecessor: Int = 0
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let contextID = record.object(forKey: "contextID") as! Int
                let autoEmail = record.object(forKey: "autoEmail") as! String
                let email = record.object(forKey: "email") as! String
                let name = record.object(forKey: "name") as! String
                let parentContext = record.object(forKey: "parentContext") as! Int
                let personID = record.object(forKey: "personID") as! Int
                let status = record.object(forKey: "status") as! String
                let teamID = record.object(forKey: "teamID") as! Int
                let contextType = record.object(forKey: "contextType") as! String
                
                
                if record.object(forKey: "predecessor") != nil
                {
                    predecessor = record.object(forKey: "predecessor") as! Int
                }
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                
                myDatabaseConnection.replaceContext(contextID, inName: name, inEmail: email, inAutoEmail: autoEmail, inParentContext: parentContext, inStatus: status, inPersonID: personID, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
                
                
                myDatabaseConnection.replaceContext1_1(contextID, predecessor: predecessor, contextType: contextType, updateTime: updateTime, updateType: updateType)
                
            }
            sem.signal()
        })
    }
    
    func replaceDecodesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "Decodes", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateDecodeRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceGTDItemInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "GTDItem", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let gTDItemID = record.object(forKey: "gTDItemID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let gTDParentID = record.object(forKey: "gTDParentID") as! Int
                let lastReviewDate = record.object(forKey: "lastReviewDate") as! Date
                let note = record.object(forKey: "note") as! String
                let predecessor = record.object(forKey: "predecessor") as! Int
                let reviewFrequency = record.object(forKey: "reviewFrequency") as! Int
                let reviewPeriod = record.object(forKey: "reviewPeriod") as! String
                let status = record.object(forKey: "status") as! String
                let teamID = record.object(forKey: "teamID") as! Int
                let title = record.object(forKey: "title") as! String
                let gTDLevel = record.object(forKey: "gTDLevel") as! Int
                
                myDatabaseConnection.replaceGTDItem(gTDItemID, inParentID: gTDParentID, inTitle: title, inStatus: status, inTeamID: teamID, inNote: note, inLastReviewDate: lastReviewDate, inReviewFrequency: reviewFrequency, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inGTDLevel: gTDLevel, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceGTDLevelInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "GTDLevel", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let gTDLevel = record.object(forKey: "gTDLevel") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object( forKey: "updateType") as! String
                let teamID = record.object(forKey: "teamID") as! Int
                let levelName = record.object(forKey: "levelName") as! String
                
                myDatabaseConnection.replaceGTDLevel(gTDLevel, inLevelName: levelName, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceMeetingAgendaInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let meetingID = record.object(forKey: "meetingID") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let chair = record.object(forKey: "chair") as! String
                let endTime = record.object(forKey: "endTime") as! Date
                let location = record.object(forKey: "location") as! String
                let minutes = record.object(forKey: "minutes") as! String
                let minutesType = record.object(forKey: "minutesType") as! String
                let name = record.object(forKey: "name") as! String
                let previousMeetingID = record.object(forKey: "previousMeetingID") as! String
                let startTime = record.object(forKey: "meetingStartTime") as! Date
                let teamID = record.object(forKey: "actualTeamID") as! Int
                
                myDatabaseConnection.replaceAgenda(meetingID, inPreviousMeetingID : previousMeetingID, inName: name, inChair: chair, inMinutes: minutes, inLocation: location, inStartTime: startTime, inEndTime: endTime, inMinutesType: minutesType, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceMeetingAgendaItemInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let meetingID = record.object(forKey: "meetingID") as! String
                let agendaID = record.object(forKey: "agendaID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let actualEndTime = record.object(forKey: "actualEndTime") as! Date
                let actualStartTime = record.object(forKey: "actualStartTime") as! Date
                let decisionMade = record.object(forKey: "decisionMade") as! String
                let discussionNotes = record.object(forKey: "discussionNotes") as! String
                let owner = record.object(forKey: "owner") as! String
                let status = record.object(forKey: "status") as! String
                let timeAllocation = record.object(forKey: "timeAllocation") as! Int
                let title = record.object(forKey: "title") as! String
                let meetingOrder = record.object(forKey: "meetingOrder") as! Int
                
                myDatabaseConnection.replaceAgendaItem(meetingID, actualEndTime: actualEndTime, actualStartTime: actualStartTime, status: status, decisionMade: decisionMade, discussionNotes: discussionNotes, timeAllocation: timeAllocation, owner: owner, title: title, agendaID: agendaID, meetingOrder: meetingOrder, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceMeetingAttendeesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAttendees", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let meetingID = record.object(forKey: "meetingID") as! String
                let name  = record.object(forKey: "name") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let attendenceStatus = record.object(forKey: "attendenceStatus") as! String
                let email = record.object(forKey: "email") as! String
                let type = record.object(forKey: "type") as! String
                
                myDatabaseConnection.replaceAttendee(meetingID, name: name, email: email,  type: type, status: attendenceStatus, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceMeetingSupportingDocsInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingSupportingDocs", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
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
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceMeetingTasksInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingTasks", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let meetingID = record.object(forKey: "meetingID") as! String
                let agendaID = record.object(forKey: "agendaID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let taskID = record.object(forKey: "taskID") as! Int
                
                myDatabaseConnection.replaceMeetingTask(agendaID, meetingID: meetingID, taskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replacePanesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "Panes", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let pane_name = record.object(forKey: "pane_name") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let pane_available = record.object(forKey: "pane_available") as! Bool
                let pane_order = record.object(forKey: "pane_order") as! Int
                let pane_visible = record.object(forKey: "pane_visible") as! Bool
                
                myDatabaseConnection.replacePane(pane_name, inPaneAvailable: pane_available, inPaneVisible: pane_visible, inPaneOrder: pane_order, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceProjectsInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let projectID = record.object(forKey: "projectID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let areaID = record.object(forKey: "areaID") as! Int
                let lastReviewDate = record.object(forKey: "lastReviewDate") as! Date
                let projectEndDate = record.object(forKey: "projectEndDate") as! Date
                let projectName = record.object(forKey: "projectName") as! String
                let projectStartDate = record.object(forKey: "projectStartDate") as! Date
                let projectStatus = record.object(forKey: "projectStatus") as! String
                let repeatBase = record.object(forKey: "repeatBase") as! String
                let repeatInterval = record.object(forKey: "repeatInterval") as! Int
                let repeatType = record.object(forKey: "repeatType") as! String
                let reviewFrequency = record.object(forKey: "reviewFrequency") as! Int
                let teamID = record.object(forKey: "teamID") as! Int
                let note = record.object(forKey: "note") as! String
                let reviewPeriod = record.object(forKey: "reviewPeriod") as! String
                let predecessor = record.object(forKey: "predecessor") as! Int
                
                myDatabaseConnection.replaceProject(projectID, inProjectEndDate: projectEndDate, inProjectName: projectName, inProjectStartDate: projectStartDate, inProjectStatus: projectStatus, inReviewFrequency: reviewFrequency, inLastReviewDate: lastReviewDate, inGTDItemID: areaID, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
                
                myDatabaseConnection.replaceProjectNote(projectID, inNote: note, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceProjectTeamMembersInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let projectID = record.object(forKey: "projectID") as! Int
                let teamMember = record.object(forKey: "teamMember") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let roleID = record.object(forKey: "roleID") as! Int
                let projectMemberNotes = record.object(forKey: "projectMemberNotes") as! String
                
                myDatabaseConnection.replaceTeamMember(projectID, inRoleID: roleID, inPersonName: teamMember, inNotes: projectMemberNotes, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceRolesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let roleID = record.object(forKey: "roleID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let teamID = record.object(forKey: "teamID") as! Int
                let roleDescription = record.object(forKey: "roleDescription") as! String
                
                myDatabaseConnection.replaceRole(roleDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType, roleID: roleID)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceStagesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "Stages", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let stageDescription = record.object(forKey: "stageDescription") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let teamID = record.object(forKey: "teamID") as! Int
                
                myDatabaseConnection.replaceStage(stageDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceTaskInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let taskID = record.object(forKey: "taskID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let completionDate = record.object(forKey: "completionDate") as! Date
                let details = record.object(forKey: "details") as! String
                let dueDate = record.object(forKey: "dueDate") as! Date
                let energyLevel = record.object(forKey: "energyLevel") as! String
                let estimatedTime = record.object(forKey: "estimatedTime") as! Int
                let estimatedTimeType = record.object(forKey: "estimatedTimeType") as! String
                let flagged = record.object(forKey: "flagged") as! Bool
                let priority = record.object(forKey: "priority") as! String
                let repeatBase = record.object(forKey: "repeatBase") as! String
                let repeatInterval = record.object(forKey: "repeatInterval") as! Int
                let repeatType = record.object(forKey: "repeatType") as! String
                let startDate = record.object(forKey: "startDate") as! Date
                let status = record.object(forKey: "status") as! String
                let teamID = record.object(forKey: "teamID") as! Int
                let title = record.object(forKey: "title") as! String
                let urgency = record.object(forKey: "urgency") as! String
                let projectID = record.object(forKey: "projectID") as! Int
                
                myDatabaseConnection.replaceTask(taskID, inTitle: title, inDetails: details, inDueDate: dueDate, inStartDate: startDate, inStatus: status, inPriority: priority, inEnergyLevel: energyLevel, inEstimatedTime: estimatedTime, inEstimatedTimeType: estimatedTimeType, inProjectID: projectID, inCompletionDate: completionDate, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inFlagged: flagged, inUrgency: urgency, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceTaskAttachmentInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskAttachment", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
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
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceTaskContextInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskContext", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let taskID = record.object(forKey: "taskID") as! Int
                let contextID = record.object(forKey: "contextID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                
                myDatabaseConnection.replaceTaskContext(contextID, inTaskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceTaskPredecessorInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let taskID = record.object(forKey: "taskID") as! Int
                let predecessorID = record.object(forKey: "predecessorID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let predecessorType = record.object(forKey: "predecessorType") as! String
                
                myDatabaseConnection.replacePredecessorTask(taskID, inPredecessorID: predecessorID, inPredecessorType: predecessorType, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceTaskUpdatesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "TaskUpdates", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let taskID = record.object(forKey: "taskID") as! Int
                let updateDate = record.object(forKey: "updateDate") as! Date
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let details = record.object(forKey: "details") as! String
                let source = record.object(forKey: "source") as! String
                
                myDatabaseConnection.replaceTaskUpdate(taskID, inDetails: details, inSource: source, inUpdateDate: updateDate, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceTeamInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)

        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let teamID = record.object(forKey: "teamID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let name = record.object(forKey: "name") as! String
                let note = record.object(forKey: "note") as! String
                let status = record.object(forKey: "status") as! String
                let type = record.object(forKey: "type") as! String
                let predecessor = record.object(forKey: "predecessor") as! Int
                let externalID = record.object(forKey: "externalID") as! Int

                myDatabaseConnection.replaceTeam(teamID, inName: name, inStatus: status, inNote: note, inType: type, inPredecessor: predecessor, inExternalID: externalID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceProcessedEmailsInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "ProcessedEmails", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let emailID = record.object(forKey: "emailID") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let emailType = record.object(forKey: "emailType") as! String
                let processedDate = record.object(forKey: "processedDate") as! Date
                
                myDatabaseConnection.replaceProcessedEmail(emailID, emailType: emailType, processedDate: processedDate, updateTime: updateTime, updateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceOutlineInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "Outline", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let outlineID = record.object(forKey: "outlineID") as! Int
                let parentID = record.object(forKey: "parentID") as! Int
                let parentType = record.object(forKey: "parentType") as! String
                let title = record.object(forKey: "title") as! String
                let status = record.object(forKey: "status") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                
                myDatabaseConnection.replaceOutline(outlineID, parentID: parentID, parentType: parentType, title: title, status: status, updateTime: updateTime, updateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func replaceOutlineDetailsInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as! CVarArg)
        let query: CKQuery = CKQuery(recordType: "OutlineDetails", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let outlineID = record.object(forKey: "outlineID") as! Int
                let lineID = record.object(forKey: "lineID") as! Int
                let lineOrder = record.object(forKey: "lineOrder") as! Int
                let parentLine = record.object(forKey: "parentLine") as! Int
                let lineText = record.object(forKey: "lineText") as! String
                let lineType = record.object(forKey: "lineType") as! String
                
                let checkBox = record.object(forKey: "checkBoxValue") as! String
                
                var checkBoxValue: Bool = false
                
                if checkBox == "True"
                {
                    checkBoxValue = true
                }
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                
                myDatabaseConnection.replaceOutlineDetails(outlineID, lineID: lineID, lineOrder: lineOrder, parentLine: parentLine, lineText: lineText, lineType: lineType, checkBoxValue: checkBoxValue, updateTime: updateTime, updateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    
    func saveContextRecordToCloudKit(_ sourceRecord: Context)
    {
        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID as! Int)) && (teamID == \(sourceRecord.teamID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Context", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if error != nil
                {
                    NSLog("Error querying records: \(error!.localizedDescription)")
                }
                else
                {
                    // Lets go and get the additional details from the context1_1 table
                    
                    let tempContext1_1 = myDatabaseConnection.getContext1_1(sourceRecord.contextID as! Int)
                    
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
            })
    }
    
    func saveContext1_1RecordToCloudKit(_ sourceRecord: Context1_1)
    {
        let predicate = NSPredicate(format: "(contextID == \(sourceRecord.contextID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Context", predicate: predicate)
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
                        record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        record!.setValue(sourceRecord.contextType, forKey: "contextType")
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        
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
                        let record = CKRecord(recordType: "Context")
                        record.setValue(sourceRecord.contextID, forKey: "contextID")
                        record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        record.setValue(sourceRecord.contextType, forKey: "contextType")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        
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
            })
    }
    
    func saveDecodesRecordToCloudKit(_ sourceRecord: Decodes, syncName: String)
    {
        let predicate = NSPredicate(format: "(decode_name == \"\(sourceRecord.decode_name)\")") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Decodes", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
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
                            let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
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
                            let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
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
                            let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
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
                            let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
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
                            let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
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
                            let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
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
                            let tempValue = record!.object(forKey: "decode_value")! as CKRecordValue
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
                    }
                    else
                    {  // Insert
                        let todoRecord = CKRecord(recordType: "Decodes")
                        todoRecord.setValue(sourceRecord.decode_name, forKey: "decode_name")
                        todoRecord.setValue(sourceRecord.decodeType, forKey: "decodeType")
                        todoRecord.setValue(sourceRecord.decode_value, forKey: "decode_value")
                        todoRecord.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        todoRecord.setValue(sourceRecord.updateType, forKey: "updateType")
                        
                        self.privateDB.save(todoRecord, completionHandler: { (savedRecord, saveError) in
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
    
    func saveGTDItemRecordToCloudKit(_ sourceRecord: GTDItem)
    {
        let predicate = NSPredicate(format: "(gTDItemID == \(sourceRecord.gTDItemID as! Int)) && (teamID == \(sourceRecord.teamID as! Int))")
        let query = CKQuery(recordType: "GTDItem", predicate: predicate)
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
            })
    }
    
    func saveGTDLevelRecordToCloudKit(_ sourceRecord: GTDLevel)
    {
        let predicate = NSPredicate(format: "(gTDLevel == \(sourceRecord.gTDLevel as! Int)) && (teamID == \(sourceRecord.teamID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "GTDLevel", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.levelName, forKey: "levelName")
                        
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
                        let record = CKRecord(recordType: "GTDLevel")
                        record.setValue(sourceRecord.gTDLevel, forKey: "gTDLevel")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
                        record.setValue(sourceRecord.levelName, forKey: "levelName")
                        
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
            })
    }
    
    func saveMeetingAgendaRecordToCloudKit(_ sourceRecord: MeetingAgenda)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID)\") && (actualTeamID == \(sourceRecord.teamID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
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
            })
    }
    
    func saveMeetingAgendaItemRecordToCloudKit(_ sourceRecord: MeetingAgendaItem)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID!)\") && (agendaID == \(sourceRecord.agendaID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "MeetingAgendaItem", predicate: predicate)
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
            })
    }
    
    func saveMeetingAttendeesRecordToCloudKit(_ sourceRecord: MeetingAttendees)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID)\") && (name = \"\(sourceRecord.name)\")") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
            })
    }
    
    func saveMeetingSupportingDocsRecordToCloudKit(_ sourceRecord: MeetingSupportingDocs)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID)\") && (agendaID == \(sourceRecord.agendaID as! Int))") // better be accurate to get only the
        let query = CKQuery(recordType: "MeetingSupportingDocs", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.attachmentPath, forKey: "attachmentPath")
                        record!.setValue(sourceRecord.title, forKey: "title")
                        
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
                        let record = CKRecord(recordType: "MeetingSupportingDocs")
                        record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                        record.setValue(sourceRecord.agendaID, forKey: "agendaID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.attachmentPath, forKey: "attachmentPath")
                        record.setValue(sourceRecord.title, forKey: "title")
                        
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
            })
    }
    
    func saveMeetingTasksRecordToCloudKit(_ sourceRecord: MeetingTasks)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID)\") && (agendaID == \(sourceRecord.agendaID as! Int)) && (taskID == \(sourceRecord.taskID as! Int))") // better be accurate to get only the
        let query = CKQuery(recordType: "MeetingTasks", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.taskID, forKey: "taskID")
                        
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
                        let record = CKRecord(recordType: "MeetingTasks")
                        record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                        record.setValue(sourceRecord.agendaID, forKey: "agendaID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        
                        
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
            })
    }
    
    func savePanesRecordToCloudKit(_ sourceRecord: Panes)
    {
        let predicate = NSPredicate(format: "(pane_name == \"\(sourceRecord.pane_name)\")") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Panes", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.pane_available, forKey: "pane_available")
                        record!.setValue(sourceRecord.pane_order, forKey: "pane_order")
                        record!.setValue(sourceRecord.pane_visible, forKey: "pane_visible")
                        
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
                        let record = CKRecord(recordType: "Panes")
                        record.setValue(sourceRecord.pane_name, forKey: "pane_name")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.pane_available, forKey: "pane_available")
                        record.setValue(sourceRecord.pane_order, forKey: "pane_order")
                        record.setValue(sourceRecord.pane_visible, forKey: "pane_visible")
                        
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
            })
    }
    
    func saveProjectsRecordToCloudKit(_ sourceRecord: Projects)
    {
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if error != nil
                {
                    NSLog("Error querying records: \(error!.localizedDescription)")
                }
                else
                {
                    
                    // First need to get additional info from other table
                    
                    let tempProjectNote = myDatabaseConnection.getProjectNote(sourceRecord.projectID as! Int)
                    
                    var myNote: String = ""
                    var myReviewPeriod: String = ""
                    var myPredecessor: Int = 0
                    
                    if tempProjectNote.count > 0
                    {
                        myNote = tempProjectNote[0].note
                        myReviewPeriod = tempProjectNote[0].reviewPeriod
                        myPredecessor = tempProjectNote[0].predecessor as! Int
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
            })
    }
    
    func saveProjectNoteRecordToCloudKit(_ sourceRecord: ProjectNote)
    {
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Projects", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.note, forKey: "note")
                        record!.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                        record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        
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
                        let record = CKRecord(recordType: "Projects")
                        record.setValue(sourceRecord.projectID, forKey: "projectID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.note, forKey: "note")
                        record.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                        record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                        
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
            })
    }

    func saveProjectTeamMembersRecordToCloudKit(_ sourceRecord: ProjectTeamMembers)
    {
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID as! Int)) && (teamMember == \"\(sourceRecord.teamMember)\")") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.roleID, forKey: "roleID")
                        record!.setValue(sourceRecord.projectMemberNotes, forKey: "projectMemberNotes")
                        
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
                        let record = CKRecord(recordType: "ProjectTeamMembers")
                        record.setValue(sourceRecord.projectID, forKey: "projectID")
                        record.setValue(sourceRecord.teamMember, forKey: "teamMember")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.roleID, forKey: "roleID")
                        record.setValue(sourceRecord.projectMemberNotes, forKey: "projectMemberNotes")
                        
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
            })
    }
    
    func saveRolesRecordToCloudKit(_ sourceRecord: Roles)
    {
        let predicate = NSPredicate(format: "(roleID == \(sourceRecord.roleID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Roles", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.roleDescription, forKey: "roleDescription")
                        
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
                        let record = CKRecord(recordType: "Roles")
                        record.setValue(sourceRecord.roleID, forKey: "roleID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
                        record.setValue(sourceRecord.roleDescription, forKey: "roleDescription")
                        
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
            })
    }
    
    func saveStagesRecordToCloudKit(_ sourceRecord: Stages)
    {
        let predicate = NSPredicate(format: "(stageDescription == \"\(sourceRecord.stageDescription)\") && (teamID == \(sourceRecord.teamID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Stages", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        
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
                        let record = CKRecord(recordType: "Stages")
                        record.setValue(sourceRecord.stageDescription, forKey: "stageDescription")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.teamID, forKey: "teamID")
                        
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
            })
    }

    func saveTaskRecordToCloudKit(_ sourceRecord: Task)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Task", predicate: predicate)
        
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
            })
    }
    
    func saveTaskAttachmentRecordToCloudKit(_ sourceRecord: TaskAttachment)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as! Int)) && (title == \"\(sourceRecord.title)\")") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "TaskAttachment", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.attachment, forKey: "attachment")
                        
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
                        let record = CKRecord(recordType: "TaskAttachment")
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        record.setValue(sourceRecord.title, forKey: "title")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.attachment, forKey: "attachment")
                        
                        
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
            })
    }
    
    func saveTaskContextRecordToCloudKit(_ sourceRecord: TaskContext)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as! Int)) && (contextID == \(sourceRecord.contextID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "TaskContext", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        
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
                        let record = CKRecord(recordType: "TaskContext")
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        record.setValue(sourceRecord.contextID, forKey: "contextID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        
                        
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
            })
    }
    
    func saveTaskPredecessorRecordToCloudKit(_ sourceRecord: TaskPredecessor)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as! Int)) && (predecessorID == \(sourceRecord.predecessorID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "TaskPredecessor", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.predecessorType, forKey: "predecessorType")
                        
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
                        let record = CKRecord(recordType: "TaskPredecessor")
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        record.setValue(sourceRecord.predecessorID, forKey: "predecessorID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.predecessorType, forKey: "predecessorType")
                        
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
            })
    }
    
    func saveTaskUpdatesRecordToCloudKit(_ sourceRecord: TaskUpdates)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as! Int)) && (updateDate == %@)", sourceRecord.updateDate as! CVarArg) // better be accurate to get only the record you need
        let query = CKQuery(recordType: "TaskUpdates", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.details, forKey: "details")
                        record!.setValue(sourceRecord.source, forKey: "source")
                        
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
                        let record = CKRecord(recordType: "TaskUpdates")
                        record.setValue(sourceRecord.taskID, forKey: "taskID")
                        record.setValue(sourceRecord.updateDate, forKey: "updateDate")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.details, forKey: "details")
                        record.setValue(sourceRecord.source, forKey: "source")
                        
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
            })
    }
    
    func saveTeamRecordToCloudKit(_ sourceRecord: Team)
    {
        let predicate = NSPredicate(format: "(teamID == \(sourceRecord.teamID as! Int))") // better be accurate to get only the record you need
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
            })
    }
    
    func saveProcessedEmailsRecordToCloudKit(_ sourceRecord: ProcessedEmails)
    {
        let predicate = NSPredicate(format: "(emailID == \"\(sourceRecord.emailID!)\")") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "ProcessedEmails", predicate: predicate)
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
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record!.setValue(sourceRecord.updateType, forKey: "updateType")
                        record!.setValue(sourceRecord.emailType, forKey: "emailType")
                        record!.setValue(sourceRecord.processedDate, forKey: "processedDate")
                        
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
                        let record = CKRecord(recordType: "ProcessedEmails")
                        record.setValue(sourceRecord.emailID, forKey: "emailID")
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                        record.setValue(sourceRecord.updateType, forKey: "updateType")
                        record.setValue(sourceRecord.emailType, forKey: "emailType")
                        record.setValue(sourceRecord.processedDate, forKey: "processedDate")
                        
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
            })
    }

    func saveOutlineRecordToCloudKit(_ sourceRecord: Outline)
    {
        let predicate = NSPredicate(format: "(outlineID == \(sourceRecord.outlineID!))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Outline", predicate: predicate)
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
                    record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.parentID, forKey: "parentID")
                    record!.setValue(sourceRecord.parentType, forKey: "parentType")
                    record!.setValue(sourceRecord.title, forKey: "title")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    
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
                    let record = CKRecord(recordType: "Outline")
                    record.setValue(sourceRecord.outlineID, forKey: "outlineID")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.parentID, forKey: "parentID")
                    record.setValue(sourceRecord.parentType, forKey: "parentType")
                    record.setValue(sourceRecord.title, forKey: "title")
                    record.setValue(sourceRecord.status, forKey: "status")
                    
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
        })
    }

    func saveOutlineDetailsRecordToCloudKit(_ sourceRecord: OutlineDetails)
    {
        let predicate = NSPredicate(format: "(outlineID == \(sourceRecord.outlineID!)) && (lineID == \(sourceRecord.lineID!))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "OutlineDetails", predicate: predicate)
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
                    record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.lineOrder, forKey: "lineOrder")
                    record!.setValue(sourceRecord.parentLine, forKey: "parentLine")
                    record!.setValue(sourceRecord.lineText, forKey: "lineText")
                    record!.setValue(sourceRecord.lineType, forKey: "lineType")
                    
                    if sourceRecord.checkBoxValue == true
                    {
                        record!.setValue("True", forKey: "checkBoxValue")
                    }
                    else
                    {
                        record!.setValue("False", forKey: "checkBoxValue")
                    }
                    
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
                    let record = CKRecord(recordType: "OutlineDetails")
                    record.setValue(sourceRecord.outlineID, forKey: "outlineID")
                    record.setValue(sourceRecord.lineID, forKey: "lineID")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.lineOrder, forKey: "lineOrder")
                    record.setValue(sourceRecord.parentLine, forKey: "parentLine")
                    record.setValue(sourceRecord.lineText, forKey: "lineText")
                    record.setValue(sourceRecord.lineType, forKey: "lineType")
                    
                    if sourceRecord.checkBoxValue == true
                    {
                        record.setValue("True", forKey: "checkBoxValue")
                    }
                    else
                    {
                        record.setValue("False", forKey: "checkBoxValue")
                    }
                    
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
        })
    }
    
    fileprivate func updateContextRecord(_ sourceRecord: CKRecord)
    {
        var predecessor: Int = 0
        
        let contextID = sourceRecord.object(forKey: "contextID") as! Int
        let autoEmail = sourceRecord.object(forKey: "autoEmail") as! String
        let email = sourceRecord.object(forKey: "email") as! String
        let name = sourceRecord.object(forKey: "name") as! String
        let parentContext = sourceRecord.object(forKey: "parentContext") as! Int
        let personID = sourceRecord.object(forKey: "personID") as! Int
        let status = sourceRecord.object(forKey: "status") as! String
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        let contextType = sourceRecord.object(forKey: "contextType") as! String
        
        if sourceRecord.object(forKey: "predecessor") != nil
        {
            predecessor = sourceRecord.object(forKey: "predecessor") as! Int
        }
        
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

        myDatabaseConnection.saveContext(contextID, inName: name, inEmail: email, inAutoEmail: autoEmail, inParentContext: parentContext, inStatus: status, inPersonID: personID, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
        
        myDatabaseConnection.saveContext1_1(contextID, predecessor: predecessor, contextType: contextType, updateTime: updateTime, updateType: updateType)
    }

    fileprivate func updateDecodeRecord(_ sourceRecord: CKRecord)
    {
        let decodeName = sourceRecord.object(forKey: "decode_name") as! String
        let decodeValue = sourceRecord.object(forKey: "decode_value") as! String
        let decodeType = sourceRecord.object(forKey: "decodeType") as! String

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

        myDatabaseConnection.updateDecodeValue(decodeName, inCodeValue: decodeValue, inCodeType: decodeType, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateGTDItemRecord(_ sourceRecord: CKRecord)
    {
        let gTDItemID = sourceRecord.object(forKey: "gTDItemID") as! Int
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
        let gTDParentID = sourceRecord.object(forKey: "gTDParentID") as! Int
        let lastReviewDate = sourceRecord.object(forKey: "lastReviewDate") as! Date
        let note = sourceRecord.object(forKey: "note") as! String
        let predecessor = sourceRecord.object(forKey: "predecessor") as! Int
        let reviewFrequency = sourceRecord.object(forKey: "reviewFrequency") as! Int
        let reviewPeriod = sourceRecord.object(forKey: "reviewPeriod") as! String
        let status = sourceRecord.object(forKey: "status") as! String
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        let title = sourceRecord.object(forKey: "title") as! String
        let gTDLevel = sourceRecord.object(forKey: "gTDLevel") as! Int
        
        myDatabaseConnection.saveGTDItem(gTDItemID, inParentID: gTDParentID, inTitle: title, inStatus: status, inTeamID: teamID, inNote: note, inLastReviewDate: lastReviewDate, inReviewFrequency: reviewFrequency, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inGTDLevel: gTDLevel, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateGTDLevelRecord(_ sourceRecord: CKRecord)
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
        
        myDatabaseConnection.saveGTDLevel(gTDLevel, inLevelName: levelName, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateMeetingAgendaRecord(_ sourceRecord: CKRecord)
    {
        let meetingID = sourceRecord.object(forKey: "meetingID") as! String
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
        let chair = sourceRecord.object(forKey: "chair") as! String
        let endTime = sourceRecord.object(forKey: "endTime") as! Date
        let location = sourceRecord.object(forKey: "location") as! String
        let minutes = sourceRecord.object(forKey: "minutes") as! String
        let minutesType = sourceRecord.object(forKey: "minutesType") as! String
        let name = sourceRecord.object(forKey: "name") as! String
        let previousMeetingID = sourceRecord.object(forKey: "previousMeetingID") as! String
        let startTime = sourceRecord.object(forKey: "meetingStartTime") as! Date
        let teamID = sourceRecord.object(forKey: "actualTeamID") as! Int
        
        myDatabaseConnection.saveAgenda(meetingID, inPreviousMeetingID : previousMeetingID, inName: name, inChair: chair, inMinutes: minutes, inLocation: location, inStartTime: startTime, inEndTime: endTime, inMinutesType: minutesType, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateMeetingAgendaItemRecord(_ sourceRecord: CKRecord)
    {
        let meetingID = sourceRecord.object(forKey: "meetingID") as! String
        let agendaID = sourceRecord.object(forKey: "agendaID") as! Int
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
        var actualEndTime: Date!
        if sourceRecord.object(forKey: "actualEndTime") != nil
        {
            actualEndTime = sourceRecord.object(forKey: "actualEndTime") as! Date
        }
        else
        {
            actualEndTime = getDefaultDate() as Date!
        }
        var actualStartTime: Date!
        if sourceRecord.object(forKey: "actualStartTime") != nil
        {
            actualStartTime = sourceRecord.object(forKey: "actualStartTime") as! Date
        }
        else
        {
            actualStartTime = getDefaultDate() as Date!
        }
        let decisionMade = sourceRecord.object(forKey: "decisionMade") as! String
        let discussionNotes = sourceRecord.object(forKey: "discussionNotes") as! String
        let owner = sourceRecord.object(forKey: "owner") as! String
        let status = sourceRecord.object(forKey: "status") as! String
        let timeAllocation = sourceRecord.object(forKey: "timeAllocation") as! Int
        let title = sourceRecord.object(forKey: "title") as! String
        let meetingOrder = sourceRecord.object(forKey: "meetingOrder") as! Int
        
        myDatabaseConnection.saveAgendaItem(meetingID, actualEndTime: actualEndTime, actualStartTime: actualStartTime, status: status, decisionMade: decisionMade, discussionNotes: discussionNotes, timeAllocation: timeAllocation, owner: owner, title: title, agendaID: agendaID, meetingOrder: meetingOrder, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateMeetingAttendeesRecord(_ sourceRecord: CKRecord)
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
    
    fileprivate func updateMeetingSupportingDocsRecord(_ sourceRecord: CKRecord)
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
    
    fileprivate func updateMeetingTasksRecord(_ sourceRecord: CKRecord)
    {
        let meetingID = sourceRecord.object(forKey: "meetingID") as! String
        let agendaID = sourceRecord.object(forKey: "agendaID") as! Int
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
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
        
        myDatabaseConnection.saveMeetingTask(agendaID, meetingID: meetingID, taskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updatePanesRecord(_ sourceRecord: CKRecord)
    {
        let pane_name = sourceRecord.object(forKey: "pane_name") as! String
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
        let pane_available = sourceRecord.object(forKey: "pane_available") as! Bool
        let pane_order = sourceRecord.object(forKey: "pane_order") as! Int
        let pane_visible = sourceRecord.object(forKey: "pane_visible") as! Bool
        
        myDatabaseConnection.savePane(pane_name, inPaneAvailable: pane_available, inPaneVisible: pane_visible, inPaneOrder: pane_order, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateProjectsRecord(_ sourceRecord: CKRecord)
    {
        let projectID = sourceRecord.object(forKey: "projectID") as! Int
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
        let areaID = sourceRecord.object(forKey: "areaID") as! Int
        let lastReviewDate = sourceRecord.object(forKey: "lastReviewDate") as! Date
        let projectEndDate = sourceRecord.object(forKey: "projectEndDate") as! Date
        let projectName = sourceRecord.object(forKey: "projectName") as! String
        let projectStartDate = sourceRecord.object(forKey: "projectStartDate") as! Date
        let projectStatus = sourceRecord.object(forKey: "projectStatus") as! String
        let repeatBase = sourceRecord.object(forKey: "repeatBase") as! String
        let repeatInterval = sourceRecord.object(forKey: "repeatInterval") as! Int
        let repeatType = sourceRecord.object(forKey: "repeatType") as! String
        let reviewFrequency = sourceRecord.object(forKey: "reviewFrequency") as! Int
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        let note = sourceRecord.object(forKey: "note") as! String
        let reviewPeriod = sourceRecord.object(forKey: "reviewPeriod") as! String
        let predecessor = sourceRecord.object(forKey: "predecessor") as! Int
        
        myDatabaseConnection.saveProject(projectID, inProjectEndDate: projectEndDate, inProjectName: projectName, inProjectStartDate: projectStartDate, inProjectStatus: projectStatus, inReviewFrequency: reviewFrequency, inLastReviewDate: lastReviewDate, inGTDItemID: areaID, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
        
        myDatabaseConnection.saveProjectNote(projectID, inNote: note, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateProjectTeamMembersRecord(_ sourceRecord: CKRecord)
    {
        let projectID = sourceRecord.object(forKey: "projectID") as! Int
        let teamMember = sourceRecord.object(forKey: "teamMember") as! String
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
        let roleID = sourceRecord.object(forKey: "roleID") as! Int
        let projectMemberNotes = sourceRecord.object(forKey: "projectMemberNotes") as! String
        
        myDatabaseConnection.saveTeamMember(projectID, inRoleID: roleID, inPersonName: teamMember, inNotes: projectMemberNotes, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateRolesRecord(_ sourceRecord: CKRecord)
    {
        let roleID = sourceRecord.object(forKey: "roleID") as! Int
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
        let roleDescription = sourceRecord.object(forKey: "roleDescription") as! String
        
        myDatabaseConnection.saveCloudRole(roleDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType, roleID: roleID)
    }
    
    fileprivate func updateStagesRecord(_ sourceRecord: CKRecord)
    {
        let stageDescription = sourceRecord.object(forKey: "stageDescription") as! String
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
        
        myDatabaseConnection.saveStage(stageDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateTaskRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
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
        let completionDate = sourceRecord.object(forKey: "completionDate") as! Date
        let details = sourceRecord.object(forKey: "details") as! String
        let dueDate = sourceRecord.object(forKey: "dueDate") as! Date
        let energyLevel = sourceRecord.object(forKey: "energyLevel") as! String
        let estimatedTime = sourceRecord.object(forKey: "estimatedTime") as! Int
        let estimatedTimeType = sourceRecord.object(forKey: "estimatedTimeType") as! String
        let flagged = sourceRecord.object(forKey: "flagged") as! Bool
        let priority = sourceRecord.object(forKey: "priority") as! String
        let repeatBase = sourceRecord.object(forKey: "repeatBase") as! String
        let repeatInterval = sourceRecord.object(forKey: "repeatInterval") as! Int
        let repeatType = sourceRecord.object(forKey: "repeatType") as! String
        let startDate = sourceRecord.object(forKey: "startDate") as! Date
        let status = sourceRecord.object(forKey: "status") as! String
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        let title = sourceRecord.object(forKey: "title") as! String
        let urgency = sourceRecord.object(forKey: "urgency") as! String
        let projectID = sourceRecord.object(forKey: "projectID") as! Int
        
        myDatabaseConnection.saveTask(taskID, inTitle: title, inDetails: details, inDueDate: dueDate, inStartDate: startDate, inStatus: status, inPriority: priority, inEnergyLevel: energyLevel, inEstimatedTime: estimatedTime, inEstimatedTimeType: estimatedTimeType, inProjectID: projectID, inCompletionDate: completionDate, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inFlagged: flagged, inUrgency: urgency, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateTaskAttachmentRecord(_ sourceRecord: CKRecord)
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
    
    fileprivate func updateTaskContextRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
        let contextID = sourceRecord.object(forKey: "contextID") as! Int
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
        
        myDatabaseConnection.saveTaskContext(contextID, inTaskID: taskID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateTaskPredecessorRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
        let predecessorID = sourceRecord.object(forKey: "predecessorID") as! Int
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
        let predecessorType = sourceRecord.object(forKey: "predecessorType") as! String
        
        myDatabaseConnection.savePredecessorTask(taskID, inPredecessorID: predecessorID, inPredecessorType: predecessorType, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateTaskUpdatesRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
        let updateDate = sourceRecord.object(forKey: "updateDate") as! Date
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
        let details = sourceRecord.object(forKey: "details") as! String
        let source = sourceRecord.object(forKey: "source") as! String
        
        myDatabaseConnection.saveTaskUpdate(taskID, inDetails: details, inSource: source, inUpdateDate: updateDate, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateTeamRecord(_ sourceRecord: CKRecord)
    {
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
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
        let predecessor = sourceRecord.object(forKey: "predecessor") as! Int
        let externalID = sourceRecord.object(forKey: "externalID") as! Int
        
        myDatabaseConnection.saveTeam(teamID, inName: name, inStatus: status, inNote: note, inType: type, inPredecessor: predecessor, inExternalID: externalID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
    
    fileprivate func updateProcessedEmailsRecord(_ sourceRecord: CKRecord)
    {
        let emailID = sourceRecord.object(forKey: "emailID") as! String
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
        let emailType = sourceRecord.object(forKey: "emailType") as! String
        let processedDate = sourceRecord.object(forKey: "processedDate") as! Date
        
        myDatabaseConnection.saveProcessedEmail(emailID, emailType: emailType, processedDate: processedDate, updateTime: updateTime, updateType: updateType)
    }
    
    fileprivate func updateOutlineRecord(_ sourceRecord: CKRecord)
    {
        let outlineID = sourceRecord.object(forKey: "outlineID") as! Int
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
        let parentID = sourceRecord.object(forKey: "parentID") as! Int
        let parentType = sourceRecord.object(forKey: "parentType") as! String
        let title = sourceRecord.object(forKey: "title") as! String
        let status = sourceRecord.object(forKey: "status") as! String
        
        myDatabaseConnection.saveOutline(outlineID, parentID: parentID, parentType: parentType, title: title, status: status, updateTime: updateTime, updateType: updateType)
    }
    
    fileprivate func updateOutlineDetailsRecord(_ sourceRecord: CKRecord)
    {
        let outlineID = sourceRecord.object(forKey: "outlineID") as! Int
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
        let lineID = sourceRecord.object(forKey: "lineID") as! Int
        let lineOrder = sourceRecord.object(forKey: "lineOrder") as! Int
        let parentLine = sourceRecord.object(forKey: "parentLine") as! Int
        let lineText = sourceRecord.object(forKey: "lineText") as! String
        let lineType = sourceRecord.object(forKey: "lineType") as! String
        
        let checkBox = sourceRecord.object(forKey: "checkBoxValue") as! String
        
        var checkBoxValue: Bool = false
        
        if checkBox == "True"
        {
            checkBoxValue = true
        }
        
        myDatabaseConnection.saveOutlineDetail(outlineID, lineID: lineID, lineOrder: lineOrder, parentLine: parentLine, lineText: lineText, lineType: lineType, checkBoxValue: checkBoxValue, updateTime: updateTime, updateType: updateType)
    }
    
    fileprivate func createSubscription(_ sourceTable:String, sourceQuery: String)
    {
        let predicate: NSPredicate = NSPredicate(format: sourceQuery)
        let subscription = CKQuerySubscription(recordType: sourceTable, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        let notification = CKNotificationInfo()
        
        subscription.notificationInfo = notification
        
        let sem = DispatchSemaphore(value: 0);
        
        NSLog("Creating subscription for \(sourceTable)")
        
        self.privateDB.save(subscription, completionHandler: { (result, error) -> Void in
            if error != nil
            {
                print("Table = \(sourceTable)  Error = \(error!.localizedDescription)")
            }
            
            sem.signal()
        }) 

        sem.wait()
    }
    
    func setupSubscriptions()
    {
        // Setup notification
        
        let sem = DispatchSemaphore(value: 0);
        
        privateDB.fetchAllSubscriptions() { [unowned self] (subscriptions, error) -> Void in
            if error == nil
            {
                if let subscriptions = subscriptions
                {
                    for subscription in subscriptions
                    {
                        self.privateDB.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { (str, error) -> Void in
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
            sem.signal()
        }
    
        sem.wait()
        
        createSubscription("Context", sourceQuery: "contextID > -1")
        
        createSubscription("Decodes", sourceQuery: "decode_name != ''")
        
        createSubscription("GTDItem", sourceQuery: "gTDItemID > -1")
        
        createSubscription("GTDLevel", sourceQuery: "gTDLevel > -1")
        
        createSubscription("MeetingTasks", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingAgenda", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingAgendaItem", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingAttendees", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingSupportingDocs", sourceQuery: "meetingID != ''")
        
        createSubscription("Outline", sourceQuery: "outlineID > -1")
        
        createSubscription("OutlineDetails", sourceQuery: "outlineID > -1")
        
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
    
    func getRecords(_ sourceID: CKRecordID)
    {
  //      NSLog("source record = \(sourceID)")
        
        privateDB.fetch(withRecordID: sourceID)
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
                
                    case "Outline" :
                        self.updateOutlineRecord(record!)
                
                    case "OutlineDetails" :
                        self.updateOutlineDetailsRecord(record!)
                    
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
                NSLog("Error = \(String(describing: error))")
            }
        }
    }
}
