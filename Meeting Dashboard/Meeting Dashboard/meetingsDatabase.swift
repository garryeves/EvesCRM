//
//  meetingsDatabase.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 24/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import UIKit

let coreDatabaseName = "EvesCRM"
let appName = "EvesMeeting"

let meetingStoryboard = UIStoryboard(name: "meetings", bundle: nil)
let tasksStoryboard = UIStoryboard(name: "tasks", bundle: nil)

extension coreDatabase
{
    func resetprojects()
    {
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
        
        clearDeletedProjects(predicate: predicate)
        
        clearDeletedRoles(predicate: predicate)
        
        clearDeletedTasks(predicate: predicate)
        
        clearDeletedTaskContexts(predicate: predicate)
        
        clearDeletedTaskUpdates(predicate: predicate)
        
        clearDeletedTeam(predicate: predicate)
        
        clearDeletedTaskPredecessor(predicate: predicate)

        clearDeletedGTDItems(predicate: predicate)
        
        clearDeletedGTDLevels(predicate: predicate)

        clearDeletedStages(predicate: predicate)
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
        
        clearSyncedProjects(predicate: predicate)
        
        clearSyncedRoles(predicate: predicate)
        
        clearSyncedTasks(predicate: predicate)
        
        clearSyncedTaskContexts(predicate: predicate)
        
        clearSyncedTaskUpdates(predicate: predicate)
        
        clearSyncedTeam(predicate: predicate)
        
        clearSyncedStages(predicate: predicate)

        clearSyncedTaskPredecessor(predicate: predicate)

        clearSyncedGTDItems(predicate: predicate)
        
        clearSyncedGTDLevels(predicate: predicate)
    }
    
    func deleteAllCoreData()
    {
        deleteAllContexts()
        
        deleteAllDecodeRecords()
        
        deleteAllMeetingAgendaRecords()
        
        deleteAllMeetingAttendeeRecords()
        
        deleteAllMeetingSupportingDocRecords()
        
        deleteAllMeetingTaskRecords()
        
        deleteAllProjectRecords()
        
        deleteAllRoleRecords()
        
        deleteAllTaskRecords()
        
        deleteAllTaskContextRecords()
        
        deleteAllTaskUpdateRecords()
        
        deleteAllTeamRecords()
        
        deleteAllStageRecords()

        deleteAllTaskPredecessorRecords()

        deleteAllGTDItemRecords()
        
        deleteAllGTDLevelRecords()
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
        
        createSubscription("MeetingTasks", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingAgenda", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingAgendaItem", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingAttendees", sourceQuery: "meetingID != ''")
        
        createSubscription("MeetingSupportingDocs", sourceQuery: "meetingID != ''")
        
        createSubscription("Projects", sourceQuery: "projectID > -1")
        
        createSubscription("Roles", sourceQuery:  "roleDescription != ''")
        
        createSubscription("Task", sourceQuery: "taskID > -1")
        
        createSubscription("TaskContext", sourceQuery: "taskID > -1")
        
        createSubscription("TaskUpdates", sourceQuery: "taskID > -1")
        
        createSubscription("Team", sourceQuery: "teamID > -1")
        
        createSubscription("Stages", sourceQuery: "stageDescription != ''")

        createSubscription("TaskPredecessor", sourceQuery: "taskID > -1")

        createSubscription("GTDItem", sourceQuery: "gTDItemID > -1")
        
        createSubscription("GTDLevel", sourceQuery: "gTDLevel > -1")
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
                    
                case "Projects" :
                    self.updateProjectsRecord(record!)

                case "Roles" :
                    self.updateRolesRecord(record!)
                    
                case "Task" :
                    self.updateTaskRecord(record!)
                    
                case "TaskContext" :
                    self.updateTaskContextRecord(record!)
                    
                case "TaskUpdates" :
                    self.updateTaskUpdatesRecord(record!)
                    
                case "Team" :
                    self.updateTeamRecord(record!)
                    
                case "Stages" :
                    self.updateStagesRecord(record!)

                case "TaskPredecessor" :
                    self.updateTaskPredecessorRecord(record!)

                case "GTDItem" :
                    self.updateGTDItemRecord(record!)
                    
                case "GTDLevel" :
                    self.updateGTDLevelRecord(record!)
                    
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
        progressMessage("syncToCloudKit Projects")
        myCloudDB.saveProjectsToCloudKit()
        progressMessage("syncToCloudKit Roles")
        myCloudDB.saveRolesToCloudKit()
        progressMessage("syncToCloudKit Task")
        myCloudDB.saveTaskToCloudKit()
        progressMessage("syncToCloudKit TaskContext")
        myCloudDB.saveTaskContextToCloudKit()
        progressMessage("syncToCloudKit TaskUpdates")
        myCloudDB.saveTaskUpdatesToCloudKit()
        progressMessage("syncToCloudKit Team")
        myCloudDB.saveTeamToCloudKit()
        progressMessage("syncToCloudKit Stages")
        myCloudDB.saveStagesToCloudKit()
        progressMessage("syncToCloudKit TaskPredecessor")
        myCloudDB.saveTaskPredecessorToCloudKit()
        progressMessage("syncToCloudKit GTD Item")
        myCloudDB.saveGTDItemToCloudKit()
        progressMessage("syncToCloudKit GTD Level")
        myCloudDB.saveGTDLevelToCloudKit()
        
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func syncFromCloudKit()
    {
        progressMessage("syncFromCloudKit Context")
//        myCloudDB.updateContextInCoreData()
        progressMessage("syncFromCloudKit Decodes")
        myCloudDB.updateDecodesInCoreData()
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
        progressMessage("syncFromCloudKit Projects")
        myCloudDB.updateProjectsInCoreData()
        progressMessage("syncFromCloudKit Roles")
        myCloudDB.updateRolesInCoreData()
        progressMessage("syncFromCloudKit Task")
        myCloudDB.updateTaskInCoreData()
        progressMessage("syncFromCloudKit TaskContext")
        myCloudDB.updateTaskContextInCoreData()
        progressMessage("syncFromCloudKit TaskUpdates")
        myCloudDB.updateTaskUpdatesInCoreData()
        progressMessage("syncFromCloudKit Team")
        myCloudDB.updateTeamInCoreData()
        progressMessage("syncFromCloudKit Stages")
        myCloudDB.updateStagesInCoreData()
        progressMessage("syncFromCloudKit TaskPredecessor")
        myCloudDB.updateTaskPredecessorInCoreData()
        progressMessage("syncFromCloudKit GTD Item")
        myCloudDB.updateGTDItemInCoreData()
        progressMessage("syncFromCloudKit GTD Level")
        myCloudDB.updateGTDLevelInCoreData()
        
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
        progressMessage("replaceWithCloudKit Projects")
        myCloudDB.replaceProjectsInCoreData()
        progressMessage("replaceWithCloudKit Roles")
        myCloudDB.replaceRolesInCoreData()
        progressMessage("replaceWithCloudKit Task")
        myCloudDB.replaceTaskInCoreData()
        progressMessage("replaceWithCloudKit TaskContext")
        myCloudDB.replaceTaskContextInCoreData()
        progressMessage("replaceWithCloudKit TaskUpdates")
        myCloudDB.replaceTaskUpdatesInCoreData()
        progressMessage("replaceWithCloudKit Stages")
        myCloudDB.replaceStagesInCoreData()
        progressMessage("replaceWithCloudKit TaskPredecessor")
        myCloudDB.replaceTaskPredecessorInCoreData()
        progressMessage("replaceWithCloudKit GTD Item")
        myCloudDB.replaceGTDItemInCoreData()
        progressMessage("replaceWithCloudKit GTD Level")
        myCloudDB.replaceGTDLevelInCoreData()
        
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func deleteAllFromCloudKit()
    {
        myCloudDB.deleteContext()
        myCloudDB.deleteDecodes()
        myCloudDB.deleteMeetingAgenda()
        myCloudDB.deleteMeetingAgendaItem()
        myCloudDB.deleteMeetingAttendees()
        myCloudDB.deleteMeetingSupportingDocs()
        myCloudDB.deleteMeetingTasks()
        myCloudDB.deleteProjects()
        myCloudDB.deleteRoles()
        myCloudDB.deleteTask()
        myCloudDB.deleteTaskContext()
        myCloudDB.deleteTaskUpdates()
        myCloudDB.deleteTeam()
        myCloudDB.deleteStages()
        myCloudDB.deleteTaskPredecessor()
        myCloudDB.deleteGTDItem()
        myCloudDB.deleteGTDLevel()
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
        progressMessage("setLastSyncDates Projects")
        myDatabaseConnection.setSyncDateforTable(tableName: "Projects", syncDate: syncDate)
        progressMessage("setLastSyncDates Roles")
        myDatabaseConnection.setSyncDateforTable(tableName: "Roles", syncDate: syncDate)
        progressMessage("setLastSyncDates Stages")
        myDatabaseConnection.setSyncDateforTable(tableName: "Stages", syncDate: syncDate)
        progressMessage("setLastSyncDates Task")
        myDatabaseConnection.setSyncDateforTable(tableName: "Task", syncDate: syncDate)
        progressMessage("setLastSyncDates TaskContext")
        myDatabaseConnection.setSyncDateforTable(tableName: "TaskContext", syncDate: syncDate)
        progressMessage("setLastSyncDates TaskPredecessor")
        myDatabaseConnection.setSyncDateforTable(tableName: "TaskPredecessor", syncDate: syncDate)
        progressMessage("setLastSyncDates TaskUpdates")
        myDatabaseConnection.setSyncDateforTable(tableName: "TaskUpdates", syncDate: syncDate)
    }
}

