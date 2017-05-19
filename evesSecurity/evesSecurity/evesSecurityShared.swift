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
let appName = "EvesMeeting"

var userName: String = ""
var userEmail: String = ""

extension coreDatabase
{
    func clearDeletedItems()
    {
        let predicate = NSPredicate(format: "(updateType == \"Delete\")")
        
        clearDeletedTeam(predicate: predicate)
    }
    
    func clearSyncedItems()
    {
        let predicate = NSPredicate(format: "(updateType != \"\")")
        
        clearSyncedTeam(predicate: predicate)
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
    func syncToCloudKit(teamID: Int)
    {
        progressMessage("syncToCloudKit Team")
        myCloudDB.saveTeamToCloudKit()
        progressMessage("syncToCloudKit Decode")
        myCloudDB.saveDecodesToCloudKit()
        progressMessage("syncToCloudKit Addresses")
        myCloudDB.saveAddressToCloudKit()
        progressMessage("syncToCloudKit Clients")
        myCloudDB.saveClientToCloudKit(teamID: teamID)
        progressMessage("syncToCloudKit Contacts")
        myCloudDB.saveContactToCloudKit()
        progressMessage("syncToCloudKit ContractsShiftComponents")
        myCloudDB.saveContractShiftComponentToCloudKit()
        progressMessage("syncToCloudKit Dropdowns")
        myCloudDB.saveDropdownsToCloudKit()
        progressMessage("syncToCloudKit Person")
        myCloudDB.savePersonToCloudKit()
        progressMessage("syncToCloudKit PersonAdditionalInfo")
        myCloudDB.savePersonAdditionalInfoToCloudKit()
        progressMessage("syncToCloudKit PersonAdditionalItem")
        myCloudDB.savePersonAddInfoEntryToCloudKit()
        progressMessage("syncToCloudKit Projects")
        myCloudDB.saveProjectsToCloudKit()
        progressMessage("syncToCloudKit Rates")
        myCloudDB.saveRatesToCloudKit()
        progressMessage("syncToCloudKit ReportingMonth")
        myCloudDB.saveReportingMonthToCloudKit()
        progressMessage("syncToCloudKit Shifts")
        myCloudDB.saveShiftsToCloudKit()
        progressMessage("syncToCloudKit UserRoles")
        myCloudDB.saveUserRolesToCloudKit()
        progressMessage("syncToCloudKit ContractShifts")
        myCloudDB.saveContractShiftsToCloudKit()
        
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func syncFromCloudKit(teamID: Int)
    {
        progressMessage("syncFromCloudKit Team")
        myCloudDB.updateTeamInCoreData()
        progressMessage("updateDecodesInCoreData Decode")
        myCloudDB.updateDecodesInCoreData()
        progressMessage("updateAddressInCoreData Addresses")
        myCloudDB.updateAddressInCoreData()
        progressMessage("updateClientInCoreData Clients")
        myCloudDB.updateClientInCoreData()
        progressMessage("updateContactInCoreData Contacts")
        myCloudDB.updateContactInCoreData()
        progressMessage("updateContractShiftComponentInCoreData ContractsShiftComponents")
        myCloudDB.updateContractShiftComponentInCoreData()
        progressMessage("updateDropdownsInCoreData Dropdowns")
        myCloudDB.updateDropdownsInCoreData()
        progressMessage("updatePersonInCoreData Person")
        myCloudDB.updatePersonInCoreData()
        progressMessage("updatePersonAdditionalInfoInCoreData PersonAdditionalInfo")
        myCloudDB.updatePersonAdditionalInfoInCoreData()
        progressMessage("updatePersonAddInfoEntryInCoreData PersonAdditionalItem")
        myCloudDB.updatePersonAddInfoEntryInCoreData()
        progressMessage("updateProjectsInCoreData Projects")
        myCloudDB.updateProjectsInCoreData(teamID: teamID)
        progressMessage("updateRatesInCoreData Rates")
        myCloudDB.updateRatesInCoreData()
        progressMessage("updateReportingMonthInCoreData ReportingMonth")
        myCloudDB.updateReportingMonthInCoreData()
        progressMessage("updateShiftsInCoreData Shifts")
        myCloudDB.updateShiftsInCoreData()
        progressMessage("updateUserRolesInCoreData UserRoles")
        myCloudDB.updateUserRolesInCoreData()
        progressMessage("updateContractShiftsInCoreData ContractShifts")
        myCloudDB.updateContractShiftsInCoreData()
        
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func replaceWithCloudKit()
    {
        progressMessage("replaceWithCloudKit Team")
        myCloudDB.replaceTeamInCoreData()
        
        
        progressMessage("replaceDecodesInCoreData Decode")
        myCloudDB.replaceDecodesInCoreData()
        progressMessage("replaceAddressInCoreData Addresses")
        myCloudDB.updateAddressInCoreData()
        progressMessage("replaceClientInCoreData Clients")
        myCloudDB.replaceClientInCoreData()
        progressMessage("replaceContactInCoreData Contacts")
        myCloudDB.replaceContactInCoreData()
        progressMessage("replaceContractShiftComponentInCoreData ContractsShiftComponents")
        myCloudDB.replaceContractShiftComponentInCoreData()
        progressMessage("replaceDropdownsInCoreData Dropdowns")
        myCloudDB.replaceDropdownsInCoreData()
        progressMessage("replacePersonInCoreData Person")
        myCloudDB.replacePersonInCoreData()
        progressMessage("replacePersonAdditionalInfoInCoreData PersonAdditionalInfo")
        myCloudDB.replacePersonAdditionalInfoInCoreData()
        progressMessage("replacePersonAddInfoEntryInCoreData PersonAdditionalItem")
        myCloudDB.replacePersonAddInfoEntryInCoreData()
        progressMessage("replaceProjectsInCoreData Projects")
        myCloudDB.replaceProjectsInCoreData()
        progressMessage("replaceRatesInCoreData Rates")
        myCloudDB.replaceRatesInCoreData()
        progressMessage("replaceReportingMonthInCoreData ReportingMonth")
        myCloudDB.replaceReportingMonthInCoreData()
        progressMessage("replaceShiftsInCoreData Shifts")
        myCloudDB.replaceShiftsInCoreData()
        progressMessage("replaceUserRolesInCoreData UserRoles")
        myCloudDB.replaceUserRolesInCoreData()
        progressMessage("replaceContractShiftsInCoreData ContractShifts")
        myCloudDB.replaceContractShiftsInCoreData()
        
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
        progressMessage("syncToCloudKit ContractsShiftComponents")
        myCloudDB.deleteContractShiftComponent()
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
        myCloudDB.deleteContractShifts()

   */
        
    }
    
    func setLastSyncDates(syncDate: Date)
    {
        progressMessage("setLastSyncDates Team")
        myDatabaseConnection.setSyncDateforTable(tableName: "Team", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates Decode")
        myDatabaseConnection.setSyncDateforTable(tableName: "Decode", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates Addresses")
        myDatabaseConnection.setSyncDateforTable(tableName: "Addresses", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates Clients")
        myDatabaseConnection.setSyncDateforTable(tableName: "Clients", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates Contacts")
        myDatabaseConnection.setSyncDateforTable(tableName: "Contacts", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates ContractsShiftComponents")
        myDatabaseConnection.setSyncDateforTable(tableName: "ContractsShiftComponents", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates Dropdowns")
        myDatabaseConnection.setSyncDateforTable(tableName: "Dropdowns", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates Person")
        myDatabaseConnection.setSyncDateforTable(tableName: "Person", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates PersonAdditionalInfo")
        myDatabaseConnection.setSyncDateforTable(tableName: "PersonAdditionalInfo", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates PersonAdditionalItem")
        myDatabaseConnection.setSyncDateforTable(tableName: "PersonAdditionalItem", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates Projects")
        myDatabaseConnection.setSyncDateforTable(tableName: "Projects", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates Rates")
        myDatabaseConnection.setSyncDateforTable(tableName: "Rates", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates ReportingMonth")
        myDatabaseConnection.setSyncDateforTable(tableName: "ReportingMonth", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates Shifts")
        myDatabaseConnection.setSyncDateforTable(tableName: "Shifts", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates UserRoles")
        myDatabaseConnection.setSyncDateforTable(tableName: "UserRoles", syncDate: syncDate, updateCloud: false)
        progressMessage("setLastSyncDates ContractShifts")
        myDatabaseConnection.setSyncDateforTable(tableName: "ContractShifts", syncDate: syncDate, updateCloud: true)
    }
}


