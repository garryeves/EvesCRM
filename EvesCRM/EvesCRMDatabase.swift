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

let coreDatabaseName = "EvesCRM"

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

extension DBSync
{
    func syncToCloudKit(_ inDate: NSDate)
    {
        progressMessage("syncToCloudKit Context")
        myCloudDB.saveContextToCloudKit(inDate)
        progressMessage("syncToCloudKit Decodes")
        myCloudDB.saveDecodesToCloudKit(inDate, syncName: getSyncID())
        progressMessage("syncToCloudKit GTD Item")
        myCloudDB.saveGTDItemToCloudKit(inDate)
        progressMessage("syncToCloudKit GTD Level")
        myCloudDB.saveGTDLevelToCloudKit(inDate)
        progressMessage("syncToCloudKit MeetingAgenda")
        myCloudDB.saveMeetingAgendaToCloudKit(inDate)
        progressMessage("syncToCloudKit MeetingAGendaItem")
        myCloudDB.saveMeetingAgendaItemToCloudKit(inDate)
        progressMessage("syncToCloudKit MeetingAttendees")
        myCloudDB.saveMeetingAttendeesToCloudKit(inDate)
        progressMessage("syncToCloudKit MeetingSupportingDocs")
        myCloudDB.saveMeetingSupportingDocsToCloudKit(inDate)
        progressMessage("syncToCloudKit MeetingTasks")
        myCloudDB.saveMeetingTasksToCloudKit(inDate)
        progressMessage("syncToCloudKit Panes")
        myCloudDB.savePanesToCloudKit(inDate)
        progressMessage("syncToCloudKit Projects")
        myCloudDB.saveProjectsToCloudKit(inDate)
        progressMessage("syncToCloudKit ProjectTeamMembers")
        myCloudDB.saveProjectTeamMembersToCloudKit(inDate)
        progressMessage("syncToCloudKit Roles")
        myCloudDB.saveRolesToCloudKit(inDate)
        progressMessage("syncToCloudKit Stages")
        myCloudDB.saveStagesToCloudKit(inDate)
        progressMessage("syncToCloudKit Task")
        myCloudDB.saveTaskToCloudKit(inDate)
        progressMessage("syncToCloudKit TaskAttachment")
        myCloudDB.saveTaskAttachmentToCloudKit(inDate)
        progressMessage("syncToCloudKit TaskContext")
        myCloudDB.saveTaskContextToCloudKit(inDate)
        progressMessage("syncToCloudKit TaskPredecessor")
        myCloudDB.saveTaskPredecessorToCloudKit(inDate)
        progressMessage("syncToCloudKit TaskUpdates")
        myCloudDB.saveTaskUpdatesToCloudKit(inDate)
        progressMessage("syncToCloudKit Team")
        myCloudDB.saveTeamToCloudKit(inDate)
        progressMessage("syncToCloudKit ProcessedEmails")
        myCloudDB.saveProcessedEmailsToCloudKit(inDate)
        progressMessage("syncToCloudKit Outline")
        myCloudDB.saveOutlineToCloudKit(inDate)
        progressMessage("syncToCloudKit OutlineDetails")
        myCloudDB.saveOutlineDetailsToCloudKit(inDate)
        
        
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func syncFromCloudKit(_ inDate: NSDate)
    {
        progressMessage("syncFromCloudKit Context")
        myCloudDB.updateContextInCoreData(inDate)
        progressMessage("syncFromCloudKit Decodes")
        myCloudDB.updateDecodesInCoreData(inDate)
        progressMessage("syncFromCloudKit GTD Item")
        myCloudDB.updateGTDItemInCoreData(inDate)
        progressMessage("syncFromCloudKit GTD Level")
        myCloudDB.updateGTDLevelInCoreData(inDate)
        progressMessage("syncFromCloudKit MeetingAgenda")
        myCloudDB.updateMeetingAgendaInCoreData(inDate)
        progressMessage("syncFromCloudKit MeetingAgendaItem")
        myCloudDB.updateMeetingAgendaItemInCoreData(inDate)
        progressMessage("syncFromCloudKit MeetingAttendess")
        myCloudDB.updateMeetingAttendeesInCoreData(inDate)
        progressMessage("syncFromCloudKit MeetingSupportingDocs")
        myCloudDB.updateMeetingSupportingDocsInCoreData(inDate)
        progressMessage("syncFromCloudKit MeetingTasks")
        myCloudDB.updateMeetingTasksInCoreData(inDate)
        progressMessage("syncFromCloudKit Panes")
        myCloudDB.updatePanesInCoreData(inDate)
        progressMessage("syncFromCloudKit Projects")
        myCloudDB.updateProjectsInCoreData(inDate)
        progressMessage("syncFromCloudKit ProjectTeamMembers")
        myCloudDB.updateProjectTeamMembersInCoreData(inDate)
        progressMessage("syncFromCloudKit Roles")
        myCloudDB.updateRolesInCoreData(inDate)
        progressMessage("syncFromCloudKit Stages")
        myCloudDB.updateStagesInCoreData(inDate)
        progressMessage("syncFromCloudKit Task")
        myCloudDB.updateTaskInCoreData(inDate)
        progressMessage("syncFromCloudKit TaskAttachment")
        myCloudDB.updateTaskAttachmentInCoreData(inDate)
        progressMessage("syncFromCloudKit TaskContext")
        myCloudDB.updateTaskContextInCoreData(inDate)
        progressMessage("syncFromCloudKit TaskPredecessor")
        myCloudDB.updateTaskPredecessorInCoreData(inDate)
        progressMessage("syncFromCloudKit TaskUpdates")
        myCloudDB.updateTaskUpdatesInCoreData(inDate)
        progressMessage("syncFromCloudKit Team")
        myCloudDB.updateTeamInCoreData(inDate)
        progressMessage("syncFromCloudKit ProcessedEmails")
        myCloudDB.updateProcessedEmailsInCoreData(inDate)
        progressMessage("syncFromCloudKit Outline")
        myCloudDB.updateOutlineInCoreData(inDate)
        progressMessage("syncFromCloudKit OutlineDetails")
        myCloudDB.updateOutlineDetailsInCoreData(inDate)
        
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func replaceWithCloudKit()
    {
        progressMessage("replaceWithCloudKit Team")
        myCloudDB.replaceTeamInCoreData()
        progressMessage("replaceWithCloudKit Context")
        myCloudDB.replaceContextInCoreData()
        progressMessage("replaceWithCloudKit Decodes")
        myCloudDB.replaceDecodesInCoreData()
        progressMessage("replaceWithCloudKit GTD Item")
        myCloudDB.replaceGTDItemInCoreData()
        progressMessage("replaceWithCloudKit GTD Level")
        myCloudDB.replaceGTDLevelInCoreData()
        progressMessage("replaceWithCloudKit MeetingAgenda")
        myCloudDB.replaceMeetingAgendaInCoreData()
        progressMessage("replaceWithCloudKit MeetingAgendaItem")
        myCloudDB.replaceMeetingAgendaItemInCoreData()
        progressMessage("replaceWithCloudKit MeetingAttendess")
        myCloudDB.replaceMeetingAttendeesInCoreData()
        progressMessage("replaceWithCloudKit MeetingSupportingDocs")
        myCloudDB.replaceMeetingSupportingDocsInCoreData()
        progressMessage("replaceWithCloudKit MeetingTasks")
        myCloudDB.replaceMeetingTasksInCoreData()
        progressMessage("replaceWithCloudKit Panes")
        myCloudDB.replacePanesInCoreData()
        progressMessage("replaceWithCloudKit Projects")
        myCloudDB.replaceProjectsInCoreData()
        progressMessage("replaceWithCloudKit ProjectTeamMembers")
        myCloudDB.replaceProjectTeamMembersInCoreData()
        progressMessage("replaceWithCloudKit Roles")
        myCloudDB.replaceRolesInCoreData()
        progressMessage("replaceWithCloudKit Stages")
        myCloudDB.replaceStagesInCoreData()
        progressMessage("replaceWithCloudKit Task")
        myCloudDB.replaceTaskInCoreData()
        progressMessage("replaceWithCloudKit TaskAttachment")
        myCloudDB.replaceTaskAttachmentInCoreData()
        progressMessage("replaceWithCloudKit TaskContext")
        myCloudDB.replaceTaskContextInCoreData()
        progressMessage("replaceWithCloudKit TaskPredecessor")
        myCloudDB.replaceTaskPredecessorInCoreData()
        progressMessage("replaceWithCloudKit TaskUpdates")
        myCloudDB.replaceTaskUpdatesInCoreData()
        progressMessage("replaceWithCloudKit ProcessedEmails")
        myCloudDB.replaceProcessedEmailsInCoreData()
        progressMessage("replaceWithCloudKit Outline")
        myCloudDB.replaceOutlineInCoreData()
        progressMessage("replaceWithCloudKit OutlineDetails")
        myCloudDB.replaceOutlineDetailsInCoreData()
        
        //      refreshObject()
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func deleteAllFromCloudKit()
    {
        myCloudDB.deleteContext()
        myCloudDB.deleteDecodes()
        myCloudDB.deleteGTDItem()
        myCloudDB.deleteGTDLevel()
        myCloudDB.deleteMeetingAgenda()
        myCloudDB.deleteMeetingAgendaItem()
        myCloudDB.deleteMeetingAttendees()
        myCloudDB.deleteMeetingSupportingDocs()
        myCloudDB.deleteMeetingTasks()
        myCloudDB.deletePanes()
        myCloudDB.deleteProjects()
        myCloudDB.deleteProjectTeamMembers()
        myCloudDB.deleteRoles()
        myCloudDB.deleteStages()
        myCloudDB.deleteTask()
        myCloudDB.deleteTaskAttachment()
        myCloudDB.deleteTaskContext()
        myCloudDB.deleteTaskPredecessor()
        myCloudDB.deleteTaskUpdates()
        myCloudDB.deleteTeam()
        myCloudDB.deleteProcessedEmails()
        myCloudDB.deleteOutline()
        myCloudDB.deleteOutlineDetails()
    }
}
