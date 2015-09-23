//
//  DBSync.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 18/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit

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
        sync()
    }
    
    func sync()
    {
        if !refreshRunning
        {
            let iCloudConnected = myCloudDB.userInfo.loggedInToICloud()
        
            if iCloudConnected == .Available
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

                syncToCloudKit(syncDate)
        
                syncFromCloudKit(syncDate)
        
                // Update last sync date
        
                let dateString = "\(syncStart)"
        
                myDatabaseConnection.updateDecodeValue("CloudKit Sync", inCodeValue: dateString, inCodeType: "hidden")
        
                myDatabaseConnection.clearDeletedItems()
                myDatabaseConnection.clearSyncedItems()
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

    func syncToCloudKit(inDate: NSDate)
    {
        myCloudDB.saveContextToCloudKit(inDate)
        myCloudDB.saveDecodesToCloudKit(inDate)
        myCloudDB.saveGTDItemToCloudKit(inDate)
        myCloudDB.saveGTDLevelToCloudKit(inDate)
        myCloudDB.saveMeetingAgendaToCloudKit(inDate)
        myCloudDB.saveMeetingAgendaItemToCloudKit(inDate)
        myCloudDB.saveMeetingAttendeesToCloudKit(inDate)
        myCloudDB.saveMeetingSupportingDocsToCloudKit(inDate)
        myCloudDB.saveMeetingTasksToCloudKit(inDate)
        myCloudDB.savePanesToCloudKit(inDate)
        myCloudDB.saveProjectsToCloudKit(inDate)
        myCloudDB.saveProjectTeamMembersToCloudKit(inDate)
        myCloudDB.saveRolesToCloudKit(inDate)
        myCloudDB.saveStagesToCloudKit(inDate)
        myCloudDB.saveTaskToCloudKit(inDate)
        myCloudDB.saveTaskAttachmentToCloudKit(inDate)
        myCloudDB.saveTaskContextToCloudKit(inDate)
        myCloudDB.saveTaskPredecessorToCloudKit(inDate)
        myCloudDB.saveTaskUpdatesToCloudKit(inDate)
        myCloudDB.saveTeamToCloudKit(inDate)
        
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationCloudSyncFinished", object: nil)
    }
    
    func syncFromCloudKit(inDate: NSDate)
    {
        NSLog("Updating Context")
        myCloudDB.updateContextInCoreData(inDate)
        NSLog("Updating Decodes")
        myCloudDB.updateDecodesInCoreData(inDate)
        NSLog("Updating GTD Item")
        myCloudDB.updateGTDItemInCoreData(inDate)
        NSLog("Updating GTD Level")
        myCloudDB.updateGTDLevelInCoreData(inDate)
        NSLog("Updating MeetingAgenda")
        myCloudDB.updateMeetingAgendaInCoreData(inDate)
        NSLog("Updating MeetingAgendaItem")
        myCloudDB.updateMeetingAgendaItemInCoreData(inDate)
        NSLog("Updating MeetingAttendess")
        myCloudDB.updateMeetingAttendeesInCoreData(inDate)
        NSLog("Updating MeetingSupportingDocs")
        myCloudDB.updateMeetingSupportingDocsInCoreData(inDate)
        NSLog("Updating MeetingTasks")
        myCloudDB.updateMeetingTasksInCoreData(inDate)
        NSLog("Updating Panes")
        myCloudDB.updatePanesInCoreData(inDate)
        NSLog("Updating Projects")
        myCloudDB.updateProjectsInCoreData(inDate)
        NSLog("Updating ProjectTeamMembers")
        myCloudDB.updateProjectTeamMembersInCoreData(inDate)
        NSLog("Updating Roles")
        myCloudDB.updateRolesInCoreData(inDate)
        NSLog("Updating Stages")
        myCloudDB.updateStagesInCoreData(inDate)
        NSLog("Updating Task")
        myCloudDB.updateTaskInCoreData(inDate)
        NSLog("Updating TaskAttachment")
        myCloudDB.updateTaskAttachmentInCoreData(inDate)
        NSLog("Updating TaskContext")
        myCloudDB.updateTaskContextInCoreData(inDate)
        NSLog("Updating TaskPredecessor")
        myCloudDB.updateTaskPredecessorInCoreData(inDate)
        NSLog("Updating TaskUpdates")
        myCloudDB.updateTaskUpdatesInCoreData(inDate)
        NSLog("Updating Team")
        myCloudDB.updateTeamInCoreData(inDate)
        
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
    }
    
    func deleteAllFromCoreData()
    {
        myDatabaseConnection.deleteAllCoreData()
    }
}
