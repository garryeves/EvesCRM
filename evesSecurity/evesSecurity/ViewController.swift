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
    @IBOutlet weak var progressbar: UIProgressView!
    
    override func viewDidLoad()
    {
        myDatabaseConnection = coreDatabase()
        myCloudDB = CloudKitInteraction()

        progressbar.progress = 0.0
        progressbar.progressViewStyle = .bar
        
        progressbar.layer.borderWidth = 2
        progressbar.layer.borderColor = UIColor.black.cgColor
        
        
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
        callLoadMainScreen()
    }
    
    func showPasswordScreen()
    {
        let passwordViewControl = loginStoryboard.instantiateViewController(withIdentifier: "enterPassword") as! validatePasswordViewController
        passwordViewControl.communicationDelegate = self
        self.present(passwordViewControl, animated: true, completion: nil)
    }
    
    func callLoadMainScreen()
    {
        DispatchQueue.main.async
        {
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.loadMainScreen), userInfo: nil, repeats: false)
        }
    }
    
    func loadMainScreen()
    {
//        let myDateFormatter = DateFormatter()
//        myDateFormatter.dateFormat = "dd MMM yy"
//        
//        let startArray = ["27 Mar 17",
//                          "03 Apr 17",
//                          "10 Apr 17",
//                          "17 Apr 17",
//                          "24 Apr 17",
//                          "01 May 17",
//                          "08 May 17",
//                          "15 May 17",
//                          "22 May 17",
//                          "29 May 17",
//                          "05 Jun 17",
//                          "12 Jun 17",
//                          "19 Jun 17",
//                          "16 Jun 17"]
//                          
//        
//        
//        for myDate in startArray
//        {
//            // Monday
//            let originalDate = myDateFormatter.date(from: myDate)!
//            var startDate = originalDate.add(.day, amount: 1).startOfDay
//print("Start = \(startDate)")
//            var endDate = originalDate.add(.day, amount: 2).startOfDay
//            
//            let WEndDate = endDate.getWeekEndingDate
//print("Orig = \(endDate) WE = \(WEndDate)")
//            myDatabaseConnection.fixWorkDates(searchFrom: startDate, searchTo: endDate, newDate: startDate, newWEEndate: WEndDate)
//            // Tuesday
//            startDate = originalDate.add(.day, amount: 2).startOfDay
//            endDate = originalDate.add(.day, amount: 3).startOfDay
//            myDatabaseConnection.fixWorkDates(searchFrom: startDate, searchTo: endDate, newDate: startDate, newWEEndate: WEndDate)
//            // Wednesday
//            startDate = originalDate.add(.day, amount: 3).startOfDay
//            endDate = originalDate.add(.day, amount: 4).startOfDay
//            myDatabaseConnection.fixWorkDates(searchFrom: startDate, searchTo: endDate, newDate: startDate, newWEEndate: WEndDate)
//            // Thursday
//            startDate = originalDate.add(.day, amount: 4).startOfDay
//            endDate = originalDate.add(.day, amount: 5).startOfDay
//            myDatabaseConnection.fixWorkDates(searchFrom: startDate, searchTo: endDate, newDate: startDate, newWEEndate: WEndDate)
//            // Friday
//            startDate = originalDate.add(.day, amount: 5).startOfDay
//            endDate = originalDate.add(.day, amount: 6).startOfDay
//            myDatabaseConnection.fixWorkDates(searchFrom: startDate, searchTo: endDate, newDate: startDate, newWEEndate: WEndDate)
//            // Saturday
//            startDate = originalDate.add(.day, amount: 6).startOfDay
//            endDate = originalDate.add(.day, amount: 7).startOfDay
//            myDatabaseConnection.fixWorkDates(searchFrom: startDate, searchTo: endDate, newDate: startDate, newWEEndate: WEndDate)
//            // Sunday
//            startDate = originalDate.add(.day, amount: 7).startOfDay
//            endDate = originalDate.add(.day, amount: 8).startOfDay
//            myDatabaseConnection.fixWorkDates(searchFrom: startDate, searchTo: endDate, newDate: startDate, newWEEndate: WEndDate)
//        }
//        
//    

        myDatabaseConnection.recordsProcessed = 0
        
        let myReachability = Reachability()
        if myReachability.isConnectedToNetwork()
        {
            DispatchQueue.global().async
            {
                myDBSync.sync()
            }
            
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.progressBarStatus), userInfo: nil, repeats: false)
        }
        else
        {
            DispatchQueue.main.async
            {
                let mainViewControl = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! securityViewController
                mainViewControl.communicationDelegate = self
                self.present(mainViewControl, animated: true, completion: nil)
            }
        }
    }
    
    func progressBarStatus()
    {
        if myDBSync.syncProgress < myDBSync.syncTotal
        {
            progressbar.progress = Float(myDBSync.syncProgress) / Float(myDBSync.syncTotal)
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.progressBarStatus), userInfo: nil, repeats: false)
        }
        else
        {
            sleep(3)
            
            DispatchQueue.main.async
            {
                let mainViewControl = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! securityViewController
                mainViewControl.communicationDelegate = self
                self.present(mainViewControl, animated: true, completion: nil)
            }
        }
    }
    
    func passwordCorrect()
    {
        notificationCenter.addObserver(self, selector: #selector(self.userLoaded), name: NotificationUserLoaded, object: nil)
        currentUser = userItem(userID: Int(readDefaultString(userDefaultName))!)
        currentUser.getUserDetails()
    }
}

