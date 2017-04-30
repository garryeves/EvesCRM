//
//  ViewController.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 22/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lblDebug: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
 
        myID = "dummy" // this is here for when I enable multiuser, to make it easy to implement
        
        lblDebug.text = ""
        
        myDatabaseConnection = coreDatabase()
        myCloudDB = CloudKitInteraction()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performInitialSync), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performInitialSync()
    {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.initialPopulationOfTables), userInfo: nil, repeats: false)
        myDBSync.sync()
    }
    
    func DBUpdateMessage(_ notification: Notification)
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
            
            myDatabaseConnection.updateDecodeValue("Default Team", codeValue: "\(myNewTeam.teamID)", codeType: "hidden")
            
            myCurrentTeam = myNewTeam
        }
        else
        {
            // Load up the default team
            
            decodeString = myDatabaseConnection.getDecodeValue("Default Team")
            
            let tempID = Int32(decodeString)
            
            if tempID == nil
            {
                myCurrentTeam = team(teamID: 1)
            }
            else
            {
                myCurrentTeam = team(teamID: tempID!)
            }
        }
        
        //  For testing purposes, this will reset decodes
        // myDatabaseConnection.tidyDecodes()
        //      myDatabaseConnection.resetDecodes()
        
        decodeString = myDatabaseConnection.getDecodeValue("Calendar - Weeks before current date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Calendar - Weeks before current date", codeValue: "1", codeType: "stepper")
        }
        
        decodeString = myDatabaseConnection.getDecodeValue("Calendar - Weeks after current date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Calendar - Weeks after current date", codeValue: "4", codeType: "stepper")
        }
        
        let deviceIdiom = UIDevice.current.userInterfaceIdiom
        
        if deviceIdiom == UIUserInterfaceIdiom.pad
        {
            let myStart = self.storyboard?.instantiateViewController(withIdentifier: "mainViewController") as! mainViewController
            
            self.present(myStart, animated: true, completion: nil)
        }
        else if  deviceIdiom == UIUserInterfaceIdiom.pad
        {
            NSLog("Phone")
        }
        else
        {
            NSLog("unknown device")
        }
        
    }

    
    
}

