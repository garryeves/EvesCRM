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
}

class ViewController: UIViewController, myLoginDelegate
{

    override func viewDidLoad()
    {
        myDatabaseConnection = coreDatabase()
        myCloudDB = CloudKitInteraction()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loadNewUserScreen), userInfo: nil, repeats: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func loadNewUserScreen()
    {
        let loginViewControl = loginStoryboard.instantiateViewController(withIdentifier: "newUser") as! newUserViewController
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
}

