//
//  EvesToolbox.swift
//  toolbox
//
//  Created by Garry Eves on 3/7/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation

let coreDatabaseName = "EvesCRM"
let appName = "EvesToolbox"

var userName: String = ""
var userEmail: String = ""

extension coreDatabase
{
    func clearDeletedItems()
    {
        //        let predicate = NSPredicate(format: "(updateType == \"Delete\")")
        //
        //        clearDeletedTeam(predicate: predicate)
    }
    
    func clearSyncedItems()
    {
        //        let predicate = NSPredicate(format: "(updateType != \"\")")
        //
        //        clearSyncedTeam(predicate: predicate)
    }
    
    func deleteAllCoreData()
    {
        deleteAllTeamRecords()
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
        
        createSubscription("Team", sourceQuery: "teamID > -1")
    }
}

extension DBSync
{
    func performSync()
    {
        syncTotal = 27
        syncProgress = 0
        
        let syncDate = Date()
        
        myCloudDB.saveOK = true
        
        myCloudDB.saveTeamToCloudKit()
        myCloudDB.updateTeamInCoreData()
        
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Team", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveDecodesToCloudKit()
        myCloudDB.updatePublicDecodesInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Decode", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveAddressToCloudKit()
        myCloudDB.updateAddressInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Addresses", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveClientToCloudKit()
        myCloudDB.updateClientInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Clients", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveContactToCloudKit()
        myCloudDB.updateContactInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Contacts", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveDropdownsToCloudKit()
        myCloudDB.updateDropdownsInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Dropdowns", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.savePersonToCloudKit()
        myCloudDB.updatePersonInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Person", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.savePersonAdditionalInfoToCloudKit()
        myCloudDB.updatePersonAdditionalInfoInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "PersonAdditionalInfo", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.savePersonAddInfoEntryToCloudKit()
        myCloudDB.updatePersonAddInfoEntryInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "PersonAddInfoEntry", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveProjectsToCloudKit()
        myCloudDB.updateProjectsInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Projects", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveRatesToCloudKit()
        myCloudDB.updateRatesInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Rates", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveShiftsToCloudKit()
        myCloudDB.updateShiftsInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Shifts", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveUserRolesToCloudKit()
        myCloudDB.updateUserRolesInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "UserRoles", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveUserTeamsToCloudKit()
        myCloudDB.updateUserTeamsInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "UserTeams", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveReportsToCloudKit()
        myCloudDB.updateReportsInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Reports", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }

        myCloudDB.saveContextToCloudKit()
        myCloudDB.updateContextInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Context", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveMeetingAgendaToCloudKit()
        myCloudDB.updateMeetingAgendaInCoreData()
        
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "MeetingAgenda", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveMeetingAgendaItemToCloudKit()
        myCloudDB.updateMeetingAgendaItemInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "MeetingAgendaItem", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveMeetingAttendeesToCloudKit()
        myCloudDB.updateMeetingAttendeesInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "MeetingAttendees", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveMeetingSupportingDocsToCloudKit()
        myCloudDB.updateMeetingSupportingDocsInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "MeetingSupportingDocs", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveMeetingTasksToCloudKit()
        myCloudDB.updateMeetingTasksInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "MeetingTasks", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveTaskToCloudKit()
        myCloudDB.updateTaskInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "Task", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveTaskUpdatesToCloudKit()
        myCloudDB.updateTaskUpdatesInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "TaskUpates", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveTaskAttachmentToCloudKit()
        myCloudDB.updateTaskAttachmentInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "TaskAttachment", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveTaskContextToCloudKit()
        myCloudDB.updateTaskContextInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "TaskContext", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveTaskPredecessorToCloudKit()
        myCloudDB.updateTaskPredecessorInCoreData()
        if myCloudDB.saveOK
        {
            setSyncDateforTable(tableName: "TaskPredecessor", syncDate: syncDate)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        syncProgress += 1
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func deleteAllFromCloudKit()
    {
        /*        progressMessage("deleteAllFromCloudKit Team")
         myCloudDB.deleteTeam()
         
         progressMessage("syncToCloudKit Decode")
         myCloudDB.deletePrivateDecodes()
         
         progressMessage("syncToCloudKit Addresses")
         myCloudDB.deleteAddresses()
         
         progressMessage("syncToCloudKit Clients")
         myCloudDB.deleteClients()
         
         progressMessage("syncToCloudKit Contacts")
         myCloudDB.deleteContacts)
         
         progressMessage("syncToCloudKit Dropdowns")
         myCloudDB.deleteDropdowns()
         
         progressMessage("syncToCloudKit Person")
         myCloudDB.deletePerson()
         
         progressMessage("syncToCloudKit PersonAdditionalInfo")
         myCloudDB.deletePersonAdditionalInfo()
         
         progressMessage("syncToCloudKit PersonAdditionalItem")
         myCloudDB.deletePersonAddInfoEntry()
         
         progressMessage("syncToCloudKit Projects")
         myCloudDB.deleteProjects()
         
         progressMessage("syncToCloudKit Rates")
         myCloudDB.deleteRates()
         
         progressMessage("syncToCloudKit ReportingMonth")
         myCloudDB.deleteReportingMonth()
         
         progressMessage("syncToCloudKit Shifts")
         myCloudDB.deleteShifts()
         progressMessage("syncToCloudKit UserRoles")
         myCloudDB.deleteUserRoles()
         
         progressMessage("syncToCloudKit ContractShifts")
         myCloudDB.deleteContractShifts()   eventtemplate
         
         progressMessage("syncToCloudKit ContractShifts")
         myCloudDB.deleteContractShifts() event template head
         
         progressMessage("syncToCloudKit ContractShifts")
         myCloudDB.deleteContractShifts() user teams
         
         */
        
    }
    
}


