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
let appName = "EvesCRM"

// Storyboards

let contextsStoryboard = UIStoryboard(name: "contexts", bundle: nil)
let projectsStoryboard = UIStoryboard(name: "projects", bundle: nil)
let meetingStoryboard = UIStoryboard(name: "meetings", bundle: nil)
let tasksStoryboard = UIStoryboard(name: "tasks", bundle: nil)
let teamStoryboard = UIStoryboard(name: "team", bundle: nil)
let GTDStoryboard = UIStoryboard(name: "GTD", bundle: nil)


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
/*        // Setup notification
        
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
 */
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
    func syncToCloudKit()
    {
        progressMessage("syncToCloudKit Context")
        myCloudDB.saveContextToCloudKit()
        progressMessage("syncToCloudKit Decodes")
        myCloudDB.saveDecodesToCloudKit()
        progressMessage("syncToCloudKit GTD Item")
        myCloudDB.saveGTDItemToCloudKit()
        progressMessage("syncToCloudKit GTD Level")
        myCloudDB.saveGTDLevelToCloudKit()
        progressMessage("syncToCloudKit MeetingAgenda")
        myCloudDB.saveMeetingAgendaToCloudKit()
        progressMessage("syncToCloudKit MeetingAGendaItem")
        myCloudDB.saveMeetingAgendaItemToCloudKit()
        progressMessage("syncToCloudKit MeetingAttendees")
        myCloudDB.saveMeetingAttendeesToCloudKit()
        progressMessage("syncToCloudKit MeetingSupportingDocs")
        myCloudDB.saveMeetingSupportingDocsToCloudKit()
        progressMessage("syncToCloudKit MeetingTasks")
        myCloudDB.saveMeetingTasksToCloudKit()
        progressMessage("syncToCloudKit Panes")
        myCloudDB.savePanesToCloudKit()
        progressMessage("syncToCloudKit Projects")
        myCloudDB.saveProjectsToCloudKit()
        progressMessage("syncToCloudKit ProjectTeamMembers")
        myCloudDB.saveProjectTeamMembersToCloudKit()
        progressMessage("syncToCloudKit Roles")
        myCloudDB.saveRolesToCloudKit()
        progressMessage("syncToCloudKit Stages")
        myCloudDB.saveStagesToCloudKit()
        progressMessage("syncToCloudKit Task")
        myCloudDB.saveTaskToCloudKit()
        progressMessage("syncToCloudKit TaskAttachment")
        myCloudDB.saveTaskAttachmentToCloudKit()
        progressMessage("syncToCloudKit TaskContext")
        myCloudDB.saveTaskContextToCloudKit()
        progressMessage("syncToCloudKit TaskPredecessor")
        myCloudDB.saveTaskPredecessorToCloudKit()
        progressMessage("syncToCloudKit TaskUpdates")
        myCloudDB.saveTaskUpdatesToCloudKit()
        progressMessage("syncToCloudKit Team")
        myCloudDB.saveTeamToCloudKit()
        progressMessage("syncToCloudKit ProcessedEmails")
        myCloudDB.saveProcessedEmailsToCloudKit()
        progressMessage("syncToCloudKit Outline")
        myCloudDB.saveOutlineToCloudKit()
        progressMessage("syncToCloudKit OutlineDetails")
        myCloudDB.saveOutlineDetailsToCloudKit()
        
        
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func syncFromCloudKit()
    {
        progressMessage("syncFromCloudKit Context")
        myCloudDB.updateContextInCoreData()
        progressMessage("syncFromCloudKit Decodes")
        myCloudDB.updateDecodesInCoreData()
        progressMessage("syncFromCloudKit GTD Item")
        myCloudDB.updateGTDItemInCoreData()
        progressMessage("syncFromCloudKit GTD Level")
        myCloudDB.updateGTDLevelInCoreData()
        progressMessage("syncFromCloudKit MeetingAgenda")
        myCloudDB.updateMeetingAgendaInCoreData()
        progressMessage("syncFromCloudKit MeetingAgendaItem")
        myCloudDB.updateMeetingAgendaItemInCoreData()
        progressMessage("syncFromCloudKit MeetingAttendees")
        myCloudDB.updateMeetingAttendeesInCoreData()
        progressMessage("syncFromCloudKit MeetingSupportingDocs")
        myCloudDB.updateMeetingSupportingDocsInCoreData()
        progressMessage("syncFromCloudKit MeetingTasks")
        myCloudDB.updateMeetingTasksInCoreData()
        progressMessage("syncFromCloudKit Panes")
        myCloudDB.updatePanesInCoreData()
        progressMessage("syncFromCloudKit Projects")
        myCloudDB.updateProjectsInCoreData()
        progressMessage("syncFromCloudKit ProjectTeamMembers")
        myCloudDB.updateProjectTeamMembersInCoreData()
        progressMessage("syncFromCloudKit Roles")
        myCloudDB.updateRolesInCoreData()
        progressMessage("syncFromCloudKit Stages")
        myCloudDB.updateStagesInCoreData()
        progressMessage("syncFromCloudKit Task")
        myCloudDB.updateTaskInCoreData()
        progressMessage("syncFromCloudKit TaskAttachment")
        myCloudDB.updateTaskAttachmentInCoreData()
        progressMessage("syncFromCloudKit TaskContext")
        myCloudDB.updateTaskContextInCoreData()
        progressMessage("syncFromCloudKit TaskPredecessor")
        myCloudDB.updateTaskPredecessorInCoreData()
        progressMessage("syncFromCloudKit TaskUpdates")
        myCloudDB.updateTaskUpdatesInCoreData()
        progressMessage("syncFromCloudKit Team")
        myCloudDB.updateTeamInCoreData()
        progressMessage("syncFromCloudKit ProcessedEmails")
        myCloudDB.updateProcessedEmailsInCoreData()
        progressMessage("syncFromCloudKit Outline")
        myCloudDB.updateOutlineInCoreData()
        progressMessage("syncFromCloudKit OutlineDetails")
        myCloudDB.updateOutlineDetailsInCoreData()
        
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
        progressMessage("replaceWithCloudKit MeetingAttendees")
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
    
    func setLastSyncDates(syncDate: Date)
    {
        progressMessage("setLastSyncDates Team")
        myDatabaseConnection.setSyncDateforTable(tableName: "Team", syncDate: syncDate)
        progressMessage("setLastSyncDates Context")
        myDatabaseConnection.setSyncDateforTable(tableName: "Context", syncDate: syncDate)
        progressMessage("setLastSyncDates Decodes")
        myDatabaseConnection.setSyncDateforTable(tableName: "Decodes", syncDate: syncDate)
        progressMessage("setLastSyncDates GTD Item")
        myDatabaseConnection.setSyncDateforTable(tableName: "GTDItem", syncDate: syncDate)
        progressMessage("setLastSyncDates GTD Level")
        myDatabaseConnection.setSyncDateforTable(tableName: "GTDLevel", syncDate: syncDate)
        progressMessage("setLastSyncDates MeetingAgenda")
        myDatabaseConnection.setSyncDateforTable(tableName: "MeetingAgenda", syncDate: syncDate)
        progressMessage("setLastSyncDates MeetingAgendaItem")
        myDatabaseConnection.setSyncDateforTable(tableName: "MeetingAgendaItem", syncDate: syncDate)
        progressMessage("setLastSyncDates MeetingAttendees")
        myDatabaseConnection.setSyncDateforTable(tableName: "MeetingAttendees", syncDate: syncDate)
        progressMessage("setLastSyncDates MeetingSupportingDocs")
        myDatabaseConnection.setSyncDateforTable(tableName: "MeetingSupportingDocs", syncDate: syncDate)
        progressMessage("setLastSyncDates MeetingTasks")
        myDatabaseConnection.setSyncDateforTable(tableName: "MeetingTasks", syncDate: syncDate)
        progressMessage("setLastSyncDates Panes")
        myDatabaseConnection.setSyncDateforTable(tableName: "Panes", syncDate: syncDate)
        progressMessage("setLastSyncDates Projects")
        myDatabaseConnection.setSyncDateforTable(tableName: "Projects", syncDate: syncDate)
        progressMessage("setLastSyncDates ProjectTeamMembers")
        myDatabaseConnection.setSyncDateforTable(tableName: "ProjectTeamMembers", syncDate: syncDate)
        progressMessage("setLastSyncDates Roles")
        myDatabaseConnection.setSyncDateforTable(tableName: "Roles", syncDate: syncDate)
        progressMessage("setLastSyncDates Stages")
        myDatabaseConnection.setSyncDateforTable(tableName: "Stages", syncDate: syncDate)
        progressMessage("setLastSyncDates Task")
        myDatabaseConnection.setSyncDateforTable(tableName: "Task", syncDate: syncDate)
        progressMessage("setLastSyncDates TaskAttachment")
        myDatabaseConnection.setSyncDateforTable(tableName: "TaskAttachment", syncDate: syncDate)
        progressMessage("setLastSyncDates TaskContext")
        myDatabaseConnection.setSyncDateforTable(tableName: "TaskContext", syncDate: syncDate)
        progressMessage("setLastSyncDates TaskPredecessor")
        myDatabaseConnection.setSyncDateforTable(tableName: "TaskPredecessor", syncDate: syncDate)
        progressMessage("setLastSyncDates TaskUpdates")
        myDatabaseConnection.setSyncDateforTable(tableName: "TaskUpdates", syncDate: syncDate)
        progressMessage("setLastSyncDates ProcessedEmails")
        myDatabaseConnection.setSyncDateforTable(tableName: "ProcessedEmails", syncDate: syncDate)
        progressMessage("setLastSyncDates Outline")
        myDatabaseConnection.setSyncDateforTable(tableName: "Outline", syncDate: syncDate)
        progressMessage("setLastSyncDates OutlineDetails")
        myDatabaseConnection.setSyncDateforTable(tableName: "OutlineDetails", syncDate: syncDate)
    }
}

struct EvernoteData
{
    fileprivate var myTitle: String
    fileprivate var myUpdateDate: Date!
    fileprivate var myCreateDate: Date!
    fileprivate var myIdentifier: String
    #if os(iOS)
    fileprivate var myNoteRef: ENNoteRef!
    #elseif os(OSX)
    // NSLog("Evernote to be determined")
    #else
    //NSLog("Unexpected OS")
    #endif
    
    
    var title: String
    {
        get {
            return myTitle
        }
        set {
            myTitle = newValue
        }
    }
    
    var updateDate: Date
    {
        get {
            return myUpdateDate
        }
        set {
            myUpdateDate = newValue
        }
    }
    
    var createDate: Date
    {
        get {
            return myCreateDate
        }
        set {
            myCreateDate = newValue
        }
    }
    
    var identifier: String
    {
        get {
            return myIdentifier
        }
        set {
            myIdentifier = newValue
        }
    }
    
    #if os(iOS)
    var NoteRef: ENNoteRef
    {
        get
        {
            return myNoteRef
        }
        set
        {
            myNoteRef = newValue
        }
    }
    
    #elseif os(OSX)
    // Evernote to do
    #else
    //    NSLog("Unexpected OS")
    #endif
    
    init()
    {
        self.myTitle = ""
        self.myIdentifier = ""
    }
    
}
