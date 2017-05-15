//
//  ViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 9/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

protocol myLoginDelegate
{
    func orgEdit(_ organisation: team?)
    func userCreated(_ userRecord: userItem?)
    func loadMainScreen()
    func passwordCorrect()
}

class ViewController: UIViewController, myLoginDelegate
{
    override func viewDidLoad()
    {
        myDatabaseConnection = coreDatabase()
        myCloudDB = CloudKitInteraction()

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
        loginViewControl.loginDelegate = self
        self.present(loginViewControl, animated: true, completion: nil)
    }
    
    func orgEdit(_ organisation: team?)
    {
        let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
        orgEditViewControl.loginDelegate = self
        orgEditViewControl.workingOrganisation = organisation
        self.present(orgEditViewControl, animated: true, completion: nil)
    }
    
    func userCreated(_ userRecord: userItem?)
    {
        let userEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "userForm") as! userFormViewController
        userEditViewControl.workingUser = userRecord
        userEditViewControl.loginDelegate = self
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
        passwordViewControl.loginDelegate = self
        self.present(passwordViewControl, animated: true, completion: nil)
    }
    
    func loadMainScreen()
    {
        currentUser.syncDatabase()
        
        let mainViewControl = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! securityViewController
        self.present(mainViewControl, animated: true, completion: nil)
    }
    
    func passwordCorrect()
    {
        notificationCenter.addObserver(self, selector: #selector(self.userLoaded), name: NotificationUserLoaded, object: nil)
        currentUser = userItem(userID: Int(readDefaultString(userDefaultName))!)
        currentUser.getUserDetails()
    }
}

