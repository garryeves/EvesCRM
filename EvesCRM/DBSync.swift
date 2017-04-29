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
//    let defaultsName = "76YDDNPU7W.group.com.garryeves.EvesCRM"
    let defaultsName = "group.com.garryeves.EvesCRM"

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
                    syncToCloudKit()
        
                    syncFromCloudKit()
        
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

        myDatabaseConnection.updateDecodeValue("\(appName) Sync", inCodeValue: dateString, inCodeType: "hidden")
        
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
    
    func writeDefaultString(_  keyName: String, value: String)
    {
        let defaults = UserDefaults(suiteName: defaultsName)!
        
        defaults.set(value, forKey: keyName)
        
        defaults.synchronize()
    }
    
    func readDefaultString(_  keyName: String) -> String
    {
        let defaults = UserDefaults(suiteName: defaultsName)!
        
        if defaults.string(forKey: keyName) != nil
        {
            return (defaults.string(forKey: keyName))!
        }
        else
        {
            return ""
        }
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
