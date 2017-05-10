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
        progressMessage("syncToCloudKit Team")
        myCloudDB.saveTeamToCloudKit()
        
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func syncFromCloudKit()
    {
        progressMessage("syncFromCloudKit Team")
        myCloudDB.updateTeamInCoreData()
        
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func replaceWithCloudKit()
    {
        progressMessage("replaceWithCloudKit Team")
        myCloudDB.replaceTeamInCoreData()
        
        notificationCenter.post(name: NotificationCloudSyncFinished, object: nil)
    }
    
    func deleteAllFromCloudKit()
    {
        myCloudDB.deleteTeam()
    }
    
    func setLastSyncDates(syncDate: Date)
    {
        progressMessage("setLastSyncDates Team")
        myDatabaseConnection.setSyncDateforTable(tableName: "Team", syncDate: syncDate)
    }
}


