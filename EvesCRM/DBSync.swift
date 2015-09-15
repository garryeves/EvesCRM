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
            myDateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss ZZZZ"

            
            syncDate = myDateFormatter.dateFromString(lastSyncDate)   
        }

        // Load
        myCloudDB.saveContextToCloudKit(syncDate)
        myCloudDB.saveDecodesToCloudKit(syncDate)
        
        myCloudDB.saveGTDItemToCloudKit(syncDate)
        
        myCloudDB.saveGTDLevelToCloudKit(syncDate)
        
        myCloudDB.saveMeetingAgendaToCloudKit(syncDate)
        
        myCloudDB.saveMeetingAgendaItemToCloudKit(syncDate)
        
        myCloudDB.saveMeetingAttendeesToCloudKit(syncDate)
        
        myCloudDB.saveMeetingSupportingDocsToCloudKit(syncDate)
        
        myCloudDB.saveMeetingTasksToCloudKit(syncDate)
        
        myCloudDB.savePanesToCloudKit(syncDate)
        
        myCloudDB.saveProjectsToCloudKit(syncDate)
        
        myCloudDB.saveProjectTeamMembersToCloudKit(syncDate)
        
        myCloudDB.saveRolesToCloudKit(syncDate)
        
        myCloudDB.saveStagesToCloudKit(syncDate)
        
        myCloudDB.saveTaskToCloudKit(syncDate)
        
        myCloudDB.saveTaskAttachmentToCloudKit(syncDate)
        
        myCloudDB.saveTaskContextToCloudKit(syncDate)
        
        myCloudDB.saveTaskPredecessorToCloudKit(syncDate)
        
        myCloudDB.saveTaskUpdatesToCloudKit(syncDate)
        
        myCloudDB.saveTeamToCloudKit(syncDate)
        
        myCloudDB.updateContextInCoreData(syncDate)
        
        myCloudDB.updateDecodesInCoreData(syncDate)
        
        myCloudDB.updateGTDItemInCoreData(syncDate)
        
        myCloudDB.updateGTDLevelInCoreData(syncDate)
        
        myCloudDB.updateMeetingAgendaInCoreData(syncDate)
        
        myCloudDB.updateMeetingAgendaItemInCoreData(syncDate)
        
        myCloudDB.updateMeetingAttendeesInCoreData(syncDate)
        
        myCloudDB.updateMeetingSupportingDocsInCoreData(syncDate)
        
        myCloudDB.updateMeetingTasksInCoreData(syncDate)
        
        myCloudDB.updateGPanesInCoreData(syncDate)
       
        myCloudDB.updateProjectsInCoreData(syncDate)
        
        myCloudDB.updateProjectTeamMembersInCoreData(syncDate)
        
        myCloudDB.updateRolesInCoreData(syncDate)
        
        myCloudDB.updateStagesInCoreData(syncDate)
        
        myCloudDB.updateTaskInCoreData(syncDate)
        
        myCloudDB.updateTaskAttachmentInCoreData(syncDate)
       
        myCloudDB.updateTaskContextInCoreData(syncDate)
        
        myCloudDB.updateTaskPredecessorInCoreData(syncDate)
        
        myCloudDB.updateTaskUpdatesInCoreData(syncDate)
  
        myCloudDB.updateTeamInCoreData(syncDate)
        
        // Update last sync date
        
        let dateString = "\(syncStart)"
        
        myDatabaseConnection.updateDecodeValue("CloudKit Sync", inCodeValue: dateString, inCodeType: "hidden")
        
        myDatabaseConnection.clearDeletedItems()
        myDatabaseConnection.clearSyncedItems()
    }
}
