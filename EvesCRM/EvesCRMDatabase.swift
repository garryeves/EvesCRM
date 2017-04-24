//
//  EvesCRMDatabase.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 24/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension coreDatabase
{
    func resetprojects()
    {
        resetProjectTeamMembers()
        
        resetProjectRecords()
    }
    
    func clearDeletedItems()
    {
        let predicate = NSPredicate(format: "(updateType == \"Delete\")")
        
        clearDeletedContexts(predicate: predicate)
        
        clearDeletedDecodes(predicate: predicate)
        
        clearDeletedMeetingAgenda(predicate: predicate)
        
        clearDeletedMeetingAgendaItems(predicate: predicate)
        
        clearDeletedMeetingAttendees(predicate: predicate)
        
        clearDeletedMeetingSupportingDocs(predicate: predicate)
        
        clearDeletedMeetingTasks(predicate: predicate)
        
        clearDeletedPanes(predicate: predicate)
        
        clearDeletedProjects(predicate: predicate)
        
        clearDeletedProjectTeamMembers(predicate: predicate)
        
        clearDeletedRoles(predicate: predicate)
        
        clearDeletedStages(predicate: predicate)
        
        clearDeletedTasks(predicate: predicate)
        
        clearDeletedTaskAttachments(predicate: predicate)
        
        clearDeletedTaskContexts(predicate: predicate)
        
        clearDeletedTaskUpdates(predicate: predicate)
        
        clearDeletedTaskPredecessor(predicate: predicate)
        
        clearDeletedTeam(predicate: predicate)
        
        clearDeletedGTDItems(predicate: predicate)
        
        clearDeletedGTDLevels(predicate: predicate)
        
        clearDeletedProcessedEmails(predicate: predicate)
        
        clearDeletedOutlines(predicate: predicate)
        
        clearDeletedOutlineDetails(predicate: predicate)
    }
    
    func clearSyncedItems()
    {
        let predicate = NSPredicate(format: "(updateType != \"\")")
        
        clearSyncedContexts(predicate: predicate)
        
        clearSyncedDecodes(predicate: predicate)
        
        clearSyncedMeetingAgenda(predicate: predicate)
        
        clearSyncedMeetingAgendaItems(predicate: predicate)
        
        clearSyncedMeetingAttendee(predicate: predicate)
        
        clearSyncedMeetingSupportingDocs(predicate: predicate)
        
        clearSyncedMeetingTasks(predicate: predicate)
        
        clearSyncedPanes(predicate: predicate)
        
        clearSyncedProjects(predicate: predicate)
        
        clearSyncedProjectTeamMembers(predicate: predicate)
        
        clearSyncedRoles(predicate: predicate)
        
        clearSyncedStages(predicate: predicate)
        
        clearSyncedTasks(predicate: predicate)
        
        clearSyncedTaskAttachments(predicate: predicate)
        
        clearSyncedTaskContexts(predicate: predicate)
        
        clearSyncedTaskUpdates(predicate: predicate)
        
        clearSyncedTaskPredecessor(predicate: predicate)
        
        clearSyncedTeam(predicate: predicate)
        
        clearSyncedGTDItems(predicate: predicate)
        
        clearSyncedGTDLevels(predicate: predicate)
        
        clearSyncedProcessedEmails(predicate: predicate)
        
        clearSyncedOutlines(predicate: predicate)
        
        clearSyncedOutlineDetails(predicate: predicate)
    }
    
    func deleteAllCoreData()
    {
        deleteAllContexts()
        
        deleteAllDecodeRecords()
        
        deleteAllMeetingAgendaRecords()
        
        deleteAllMeetingAttendeeRecords()
        
        deleteAllMeetingSupportingDocRecords()
        
        deleteAllMeetingTaskRecords()
        
        deleteAllPaneRecords()
        
        deleteAllProjectRecords()
        
        deleteAllProjectTeamMemberRecords()
        
        deleteAllRoleRecords()
        
        deleteAllStageRecords()
        
        deleteAllTaskRecords()
        
        deleteAllTaskAttachmentRecords()
        
        deleteAllTaskContextRecords()
        
        deleteAllTaskUpdateRecords()
        
        deleteAllTaskPredecessorRecords()
        
        deleteAllTeamRecords()
        
        deleteAllGTDItemRecords()
        
        deleteAllGTDLevelRecords()
        
        deleteAllProcessedEmailRecords()
        
        deleteAllOutlineRecords()
        
        deleteAllOutLineDetailRecords()
    }
}

extension CloudKitInteraction
{
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
