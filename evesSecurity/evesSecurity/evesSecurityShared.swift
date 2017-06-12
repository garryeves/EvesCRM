//
//  evesSecurityShared.swift
//  evesSecurity
//
//  Created by Garry Eves on 9/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import UIKit

let coreDatabaseName = "EvesCRM"
let appName = "EvesSecurity"

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
        syncTotal = 17
        syncProgress = 0
        
        let syncDate = Date()

        myCloudDB.saveOK = true
        
        myCloudDB.saveTeamToCloudKit()
        myCloudDB.updateTeamInCoreData()
        
        if myCloudDB.saveOK
        {
            myDatabaseConnection.setSyncDateforTable(tableName: "Team", syncDate: syncDate, updateCloud: false)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveDecodesToCloudKit()
        myCloudDB.updateDecodesInCoreData()
        if myCloudDB.saveOK
        {
            myDatabaseConnection.setSyncDateforTable(tableName: "Decode", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "Addresses", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "Clients", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "Contacts", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "Dropdowns", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "Person", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "PersonAdditionalInfo", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "PersonAddInfoEntry", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "Projects", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "Rates", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "Shifts", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "UserRoles", syncDate: syncDate, updateCloud: false)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveEventTemplateToCloudKit()
        myCloudDB.updateEventTemplateInCoreData()
        if myCloudDB.saveOK
        {
            myDatabaseConnection.setSyncDateforTable(tableName: "EventTemplate", syncDate: syncDate, updateCloud: false)
        }
        
        myCloudDB.saveOK = true
        
        syncProgress += 1
        sleep(syncTime)
        
        if myDatabaseConnection.recordsProcessed < myDatabaseConnection.recordsToChange
        {
            sleep(1)
        }
        
        myCloudDB.saveEventTemplateHeadToCloudKit()
        myCloudDB.updateEventTemplateHeadInCoreData()
        if myCloudDB.saveOK
        {
            myDatabaseConnection.setSyncDateforTable(tableName: "EventTemplateHead", syncDate: syncDate, updateCloud: false)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "UserTeams", syncDate: syncDate, updateCloud: true)
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
            myDatabaseConnection.setSyncDateforTable(tableName: "Reports", syncDate: syncDate, updateCloud: true)
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


