//
//  ViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 9/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class ViewController: UIViewController, myCommunicationDelegate
{
    override func viewDidLoad()
    {
        myDatabaseConnection = coreDatabase()
        myCloudDB = CloudKitInteraction()

        
//myDatabaseConnection.quickFixProjects()
//myDatabaseConnection.quickFixPerson()
//myDatabaseConnection.quickFixTeams()
//myDatabaseConnection.quickFixShifts()
        
        if readDefaultInt(userDefaultName) <= 0
        {
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loadNewUserScreen), userInfo: nil, repeats: false)
        }
        else
        {
            if readDefaultString(userDefaultPassword) != ""
            {
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.showPasswordScreen), userInfo: nil, repeats: false)
            }
            else
            {
                passwordCorrect()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func loadNewUserScreen()
    {
        let loginViewControl = loginStoryboard.instantiateViewController(withIdentifier: "newInstance") as! newInstanceViewController
        loginViewControl.communicationDelegate = self
        self.present(loginViewControl, animated: true, completion: nil)
    }
    
    func orgEdit(_ organisation: team?)
    {
        let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
        orgEditViewControl.communicationDelegate = self
        orgEditViewControl.workingOrganisation = organisation
        self.present(orgEditViewControl, animated: true, completion: nil)
    }
    
    func userCreated(_ userRecord: userItem, teamID: Int)
    {
        // Add the user/team combo to userteams
        
        let myItem = userTeamItem(userID: userRecord.userID, teamID: teamID)
        
        myItem.save()
        
        let userEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "userForm") as! userFormViewController
        userEditViewControl.workingUser = userRecord
        userEditViewControl.communicationDelegate = self
        userEditViewControl.initialUser = true
        self.present(userEditViewControl, animated: true, completion: nil)
    }
    
    func userLoaded()
    {
        notificationCenter.removeObserver(NotificationUserLoaded)
        loadMainScreen()
    }
    
    func showPasswordScreen()
    {
        let passwordViewControl = loginStoryboard.instantiateViewController(withIdentifier: "enterPassword") as! validatePasswordViewController
        passwordViewControl.communicationDelegate = self
        self.present(passwordViewControl, animated: true, completion: nil)
    }
    
    func callLoadMainScreen()
    {
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.loadMainScreen), userInfo: nil, repeats: false)
    }
    
    func loadMainScreen()
    {
//garry
//let myItem = userTeamItem(userID: currentUser.userID, teamID: currentUser.currentTeam!.teamID)
//
//myItem.save()
        
        currentUser.syncDatabase()
        
        DispatchQueue.main.async
        {
            let mainViewControl = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! securityViewController
            mainViewControl.communicationDelegate = self
            self.present(mainViewControl, animated: true, completion: nil)
        }
    }
    
    func passwordCorrect()
    {
        notificationCenter.addObserver(self, selector: #selector(self.userLoaded), name: NotificationUserLoaded, object: nil)
        currentUser = userItem(userID: Int(readDefaultString(userDefaultName))!)
        currentUser.getUserDetails()
    }
}

