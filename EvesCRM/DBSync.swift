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
            let iCloudConnected = myCloudDB.userInfo.loggedInToICloud()
        
            if iCloudConnected == .available
            {
                if myDatabaseConnection.getTeamsCount() == 0
                {  // Nothing in teams table so lets do a full sync
                    notificationCenter.addObserver(self, selector: #selector(self.DBReplaceDone), name: NotificationDBReplaceDone, object: nil)
                    replaceWithCloudKit()
                    
                    notificationCenter.post(name: NotificationDBReplaceDone, object: nil)

                }
                else
                {                
                    let newSyncDate = Date()
                    
                    syncToCloudKit()
        
                    syncFromCloudKit()
        
                    myDatabaseConnection.clearDeletedItems()
                    myDatabaseConnection.clearSyncedItems()

                    setLastSyncDates(syncDate: newSyncDate)
                    
                    if firstRun
                    {
                        myCloudDB.setupSubscriptions()
                        firstRun = false
                    }
                    
                    notificationCenter.post(name: NotificationDBSyncCompleted, object: nil)
                }

            }
            else if iCloudConnected == .couldNotDetermine
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
    
    func getSyncID() -> String
    {
        let defaults = UserDefaults.standard
        
        if let name = defaults.string(forKey: appName)
        {
            return name
        }
        else
        {
            // get the next device ID
            myDatabaseConnection.setNextDeviceID()
            
            let name = defaults.string(forKey: appName)
            
            return name!
        }
    }
}
