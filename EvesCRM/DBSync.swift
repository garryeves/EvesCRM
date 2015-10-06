//
//  DBSync.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 18/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

class DBSync: NSObject
{
    var refreshRunning: Bool = false
    
    func startTimer()
    {
       // _ = NSTimer(timeInterval: 300, target: self, selector: "timerSync:", userInfo: nil, repeats: true)
         NSTimer.scheduledTimerWithTimeInterval(300, target: self, selector: Selector("timerSync:"), userInfo: nil, repeats: true)
    }
    
    func timerSync(timer:NSTimer)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.sync()
        }
    }
    
    func sync()
    {
        var dateString: String = ""
        if !refreshRunning
        {
            let iCloudConnected = myCloudDB.userInfo.loggedInToICloud()
        
            if iCloudConnected == .Available
            {
                if myDatabaseConnection.getTeamsCount() == 0
                {  // Nothing in teams table so lets do a full sync
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "DBReplaceDone", name:"NotificationDBReplaceDone", object: nil)
                    replaceWithCloudKit()
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("NotificationDBReplaceDone", object: nil)

                }
                else
                {
                    var syncDate: NSDate!
                    let syncStart = NSDate()
        
                    // Get the last sync date
        
                    let lastSyncDate = myDatabaseConnection.getDecodeValue("CloudKit Sync")
        
                    if lastSyncDate == ""
                    {
                        let myDateFormatter = NSDateFormatter()
                        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            
                        syncDate = myDateFormatter.dateFromString("01/01/15")
                    }
                    else
                    {
                        // Convert string to date
            
                        let myDateFormatter = NSDateFormatter()
                        myDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            
                        syncDate = myDateFormatter.dateFromString(lastSyncDate)
                    }

                    // Load
                
   //             NEXT 3 LINES TEMP FIX
//let myDateFormatter = NSDateFormatter()
//myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
//syncDate = myDateFormatter.dateFromString("01/01/15")
                
                    syncToCloudKit(syncDate)
        
                    syncFromCloudKit(syncDate)
        
                    // Update last sync date
        
                    dateString = "\(syncStart)"
                    
                    myDatabaseConnection.updateDecodeValue("CloudKit Sync", inCodeValue: dateString, inCodeType: "hidden")
                    
                    myDatabaseConnection.clearDeletedItems()
                    myDatabaseConnection.clearSyncedItems()

                    NSNotificationCenter.defaultCenter().postNotificationName("NotificationDBSyncCompleted", object: nil)
                }

            }
            else if iCloudConnected == .CouldNotDetermine
            {
                NSLog("CouldNotDetermine")
            }
            else
            {
                NSLog("Other status")
            }
        }
    }

    func DBReplaceDone()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"NotificationDBReplaceDone", object: nil)
        
        // Convert string to date
        
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        let syncDate: NSDate = myDateFormatter.dateFromString("01/01/15")!
        let dateString = "\(syncDate)"
        
        myDatabaseConnection.updateDecodeValue("CloudKit Sync", inCodeValue: dateString, inCodeType: "hidden")
        
        myDatabaseConnection.clearDeletedItems()
        myDatabaseConnection.clearSyncedItems()
        
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationDBSyncCompleted", object: nil)
    }
    
    func syncToCloudKit(inDate: NSDate)
    {
        progressMessage("syncToCloudKit Context")
        myCloudDB.saveContextToCloudKit(inDate)
        progressMessage("syncToCloudKit Decodes")
        myCloudDB.saveDecodesToCloudKit(inDate)
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

        NSNotificationCenter.defaultCenter().postNotificationName("NotificationCloudSyncFinished", object: nil)
    }
    
    func syncFromCloudKit(inDate: NSDate)
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
        
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationCloudSyncFinished", object: nil)
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
        
  //      refreshObject()
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationCloudSyncFinished", object: nil)
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
    }
    
    func deleteAllFromCoreData()
    {
        myDatabaseConnection.deleteAllCoreData()
    }
    
    func progressMessage(displayString: String)
    {
//        NSLog(displayString)
        
//        let selectedDictionary = ["displayMessage" : displayString]
        
//        NSNotificationCenter.defaultCenter().postNotificationName("NotificationSyncMessage", object: nil, userInfo:selectedDictionary)
        
//        sleep(1)
    }
}
