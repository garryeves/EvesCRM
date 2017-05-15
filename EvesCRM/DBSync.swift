//
//  DBSync.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 18/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

let NotificationDBSyncCompleted = Notification.Name("MeetingDBSyncCompleted")
let NotificationCloudSyncFinished = Notification.Name("MeetingCloudSyncFinished")
let myNotificationCloudSyncDone = Notification.Name("myNotificationCloudSyncDone")
let myNotificationCloudQueryDone = Notification.Name("myNotificationCloudQueryDone")

class DBSync: NSObject
{
//    let defaultsName = "76YDDNPU7W.group.com.garryeves.EvesCRM"
    var refreshRunning: Bool = false
    var firstRun: Bool = true
    
    func startTimer()
    {
       // _ = NSTimer(timeInterval: 300, target: self, selector: "timerSync:", userInfo: nil, repeats: true)
//         NSTimer.scheduledTimerWithTimeInterval(300, target: self, selector: Selector("timerSync:"), userInfo: nil, repeats: true)
    }
    
    func timerSync(_ timer:Timer)
    {
        DispatchQueue.main.async
        {
            self.sync()
        }
    }
    
    func sync()
    {
        if !refreshRunning
        {
            let myReachability = Reachability()
            if myReachability.isConnectedToNetwork()
            {
                if myDatabaseConnection.getTeamsCount() == 0
                {  // Nothing in teams table so lets do a full sync
                    notificationCenter.addObserver(self, selector: #selector(self.DBReplaceDone), name: NotificationDBReplaceDone, object: nil)
                    replaceWithCloudKit()
                    
                    setLastSyncDates(syncDate: Date())
                    
                    notificationCenter.post(name: NotificationDBReplaceDone, object: nil)
                }
                else
                {
                    let syncDate = Date()
                    
                    syncToCloudKit(teamID: currentUser.currentTeam!.teamID)
        
                    syncFromCloudKit(teamID: currentUser.currentTeam!.teamID)
                    setLastSyncDates(syncDate: syncDate)
                    
                    myDatabaseConnection.clearDeletedItems()
                    myDatabaseConnection.clearSyncedItems()

//                    if firstRun
//                    {
//                        myCloudDB.setupSubscriptions()
//                        firstRun = false
//                    }
                    
                    notificationCenter.post(name: NotificationDBSyncCompleted, object: nil)
                }
            }
        }
    }

    func DBReplaceDone()
    {
        notificationCenter.removeObserver(self, name: NotificationDBReplaceDone, object: nil)
        
        // Convert string to date
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        
        let syncDate: Date = myDateFormatter.date(from: "01/01/15")!
        let dateString = "\(syncDate)"

        myDatabaseConnection.updateDecodeValue("\(appName) Sync", codeValue: dateString, codeType: "hidden", decode_privacy: "Private")
        
        myDatabaseConnection.clearDeletedItems()
        myDatabaseConnection.clearSyncedItems()
        
        notificationCenter.post(name: NotificationDBSyncCompleted, object: nil)
    }
    
    func deleteAllFromCoreData()
    {
        myDatabaseConnection.deleteAllCoreData()
    }
    
    func progressMessage(_ displayString: String)
    {
        NSLog(displayString)
        
//        let selectedDictionary = ["displayMessage" : displayString]
        
//        NSnotificationCenterCenter().postNotificationName("NotificationSyncMessage", object: nil, userInfo:selectedDictionary)
        
//        sleep(1)
    }
        
    func getSyncID() -> String
    {
        let checkName = readDefaultString(coreDatabaseName)
        
        if checkName != ""
        {
            return checkName
        }
        else
        {
            // get the next device ID
            myDatabaseConnection.setNextDeviceID()
            
            let name = readDefaultString(coreDatabaseName)
            
            return name
        }
    }
    
    func getSyncString(_  sourceString: String) -> String
    {
        return("\(getSyncID()) \(sourceString) Sync")
    }
}
