//
//  reminderViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 26/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit

protocol MyReminderDelegate{
    func myReminderDidFinish(controller:reminderViewController, actionType: String)
}


class reminderViewController: UIViewController {

    var delegate: MyReminderDelegate?
    var inAction: String!
    var inReminderID: String!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    println("Passed in table = \(inAction)")
        println("Passed in ID = \(inReminderID)")
        
        
       // lblValueIn.text = dataPassedIn
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     @IBAction func cancelButtonPressed(sender: UIButton) {
        delegate?.myReminderDidFinish(self, actionType: "Cancel")
    }
    
 }
