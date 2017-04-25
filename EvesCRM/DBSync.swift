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
        var dateString: String = ""
        if !refreshRunning
        {
            let iCloudConnected = myCloudDB.userInfo.loggedInToICloud()
        
            if iCloudConnected == .available
            {
                if myDatabaseConnection.getTeamsCount() == 0
                {  // Nothing in teams table so lets do a full sync
                    notificationCenter.addObserver(self, selector: #selector(DBSync.DBReplaceDone), name: NotificationDBReplaceDone, object: nil)
                    replaceWithCloudKit()
                    
                    notificationCenter.post(name: NotificationDBReplaceDone, object: nil)

                }
                else
                {
                    var syncDate: NSDate!
                    let syncStart = NSDate()
        
                    // Get the last sync date
        
                    let lastSyncDate = myDatabaseConnection.getDecodeValue(getSyncID())
        
                    if lastSyncDate == "" || lastSyncDate == "nil" 
                    {
                        let myDateFormatter = DateFormatter()
                        myDateFormatter.dateStyle = DateFormatter.Style.short
            
                        syncDate = myDateFormatter.date(from: "01/01/15")! as NSDate
                    }
                    else
                    {
                        // Convert string to date
            
                        let myDateFormatter = DateFormatter()
                        myDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            
                        let tempSyncDate = myDateFormatter.date(from: lastSyncDate)! as NSDate
                        
                        // We want to sync everything changes in the last month so need to do some date math
                        
                        let myCalendar = Calendar.current
                        
                        syncDate = myCalendar.date(
                            byAdding: .hour,
                            value: -1,
                            to: tempSyncDate as Date)! as NSDate
                    }

                    // Load
                
   //             NEXT 3 LINES TEMP FIX
//let myDateFormatter = NSDateFormatter()
//myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
//syncDate = myDateFormatter.dateFromString("01/01/15")
                
                    syncToCloudKit(syncDate)
        
                    syncFromCloudKit(syncDate)
        
                    // Update last sync date
        
                    dateString = "\(syncStart)"

                    myDatabaseConnection.updateDecodeValue(getSyncID(), inCodeValue: dateString, inCodeType: "hidden")

                    myDatabaseConnection.clearDeletedItems()
                    myDatabaseConnection.clearSyncedItems()

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

        myDatabaseConnection.updateDecodeValue("\(coreDatabaseName) Sync", inCodeValue: dateString, inCodeType: "hidden")
        
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
        
        if let name = defaults.string(forKey: coreDatabaseName)
        {
            return name
        }
        else
        {
            // get the next device ID
            myDatabaseConnection.setNextDeviceID()
            
            let name = defaults.string(forKey: coreDatabaseName
            )
            
            return name!
        }
    }
}
