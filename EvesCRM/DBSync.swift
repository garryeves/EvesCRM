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
    func sync()
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
        myCloudDB.updateContextInCoreData(inDate)
        myCloudDB.updateDecodesInCoreData(inDate)
        myCloudDB.updateGTDItemInCoreData(inDate)
        myCloudDB.updateGTDLevelInCoreData(inDate)
        myCloudDB.updateMeetingAgendaInCoreData(inDate)
        myCloudDB.updateMeetingAgendaItemInCoreData(inDate)
        myCloudDB.updateMeetingAttendeesInCoreData(inDate)
        myCloudDB.updateMeetingSupportingDocsInCoreData(inDate)
        myCloudDB.updateMeetingTasksInCoreData(inDate)
        myCloudDB.updatePanesInCoreData(inDate)
        myCloudDB.updateProjectsInCoreData(inDate)
        myCloudDB.updateProjectTeamMembersInCoreData(inDate)
        myCloudDB.updateRolesInCoreData(inDate)
        myCloudDB.updateStagesInCoreData(inDate)
        myCloudDB.updateTaskInCoreData(inDate)
        myCloudDB.updateTaskAttachmentInCoreData(inDate)
        myCloudDB.updateTaskContextInCoreData(inDate)
        myCloudDB.updateTaskPredecessorInCoreData(inDate)
        myCloudDB.updateTaskUpdatesInCoreData(inDate)
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
}
