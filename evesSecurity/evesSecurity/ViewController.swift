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
}

class ViewController: UIViewController, myLoginDelegate
{

    override func viewDidLoad()
    {
        myDatabaseConnection = coreDatabase()
        myCloudDB = CloudKitInteraction()

        if readDefaultString(userDefaultName) == ""
        {
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loadNewUserScreen), userInfo: nil, repeats: false)
        }
        else
        {
            notificationCenter.addObserver(self, selector: #selector(self.userLoaded), name: NotificationUserLoaded, object: nil)
            
            currentUser = userItem(userID: Int(readDefaultString(userDefaultName))!)

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
        self.present(userEditViewControl, animated: true, completion: nil)
    }
    
    func userLoaded()
    {
        notificationCenter.removeObserver(NotificationUserLoaded)
        
        print("User = \(currentUser.userID)  Name = \(currentUser.name)")
        // temp
        DispatchQueue.main.async
        {
            self.userCreated(currentUser)
        }
    }
}

