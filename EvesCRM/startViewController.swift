//
//  startViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 26/09/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation

class startViewController: UIViewController
{
    @IBOutlet weak var lblDebug: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myID = "dummy" // this is here for when I enable multiuser, to make it easy to implement
        
        lblDebug.text = ""
        
        myDatabaseConnection = coreDatabase()
        myCloudDB = CloudKitInteraction()
        
        dispatch_async(dispatch_get_main_queue())
        {
            self.performInitialSync()
        }
    }
    
    func performInitialSync()
    {
  //      NSNotificationCenter.defaultCenter().addObserver(self, selector: "DBUpdateMessage:", name:"NotificationSyncMessage", object: nil)
        
        myDBSync.sync()

//        NSNotificationCenter.defaultCenter().removeObserver(self, name:"NotificationSyncMessage", object: nil)
        initialPopulationOfTables()

        let deviceIdiom = UIDevice.currentDevice().userInterfaceIdiom
        
        if deviceIdiom == UIUserInterfaceIdiom.Pad
        {
            let myStart = self.storyboard?.instantiateViewControllerWithIdentifier("iPadStart") as! ViewController
        
            self.presentViewController(myStart, animated: true, completion: nil)
        }
        else if  deviceIdiom == UIUserInterfaceIdiom.Pad
        {
            NSLog("Phone")
        }
        else
        {
            NSLog("unknown device")
        }
    }
    
    func DBUpdateMessage(notification: NSNotification)
    {
        let workingText = notification.userInfo!["displayMessage"] as! String
        NSLog("working text = \(workingText)")
        self.lblDebug.text = workingText
    }
    
    func initialPopulationOfTables()
    {
        var decodeString: String = ""
        
        //  For testing purposes, this will remove all the teams and GTD levels
        // myDatabaseConnection.deleteAllTeams()
        
        if myDatabaseConnection.getTeamsCount() == 0
        {
            let myNewTeam = team()
            myNewTeam.name = "My Life"
            myNewTeam.type = "private"
            myNewTeam.status = "Open"
            
            // Store the ID for the default team
            myDatabaseConnection.updateDecodeValue("Default Team", inCodeValue: "\(myNewTeam.teamID)", inCodeType: "hidden")
            
            myCurrentTeam = myNewTeam
        }
        else
        {
            // Load up the default team
            
            decodeString = myDatabaseConnection.getDecodeValue("Default Team")
            
            let tempID = Int(decodeString)
            
            if tempID == nil
            {
                myCurrentTeam = team(inTeamID: 1)
            }
            else
            {
                myCurrentTeam = team(inTeamID: tempID!)
            }
        }
        
        //  For testing purposes, this will reset decodes
        // myDatabaseConnection.tidyDecodes()
        //      myDatabaseConnection.resetDecodes()
        
        decodeString = myDatabaseConnection.getDecodeValue("Calendar - Weeks before current date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Calendar - Weeks before current date", inCodeValue: "1", inCodeType: "stepper")
        }
        
        decodeString = myDatabaseConnection.getDecodeValue("Calendar - Weeks after current date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Calendar - Weeks after current date", inCodeValue: "4", inCodeType: "stepper")
        }
    }
}