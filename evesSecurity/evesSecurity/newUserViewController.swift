//
//  newUserViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class newInstanceViewController: UIViewController, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var btnNew: UIButton!
    @IBOutlet weak var btnExisting: UIButton!
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var newTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var newButtonVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTextVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var ExistingHeightConstraint: NSLayoutConstraint!
    
    var communicationDelegate: myCommunicationDelegate?
    
    private var keyboardDisplayed: Bool = false
    private var originalTextHeight: CGFloat = 0.0
    
    override func viewDidLoad()
    {
        btnExisting.isEnabled = false
     
        let myReachability = Reachability()
        if myReachability.isConnectedToNetwork()
        {
            btnNew.isEnabled = true
            txtEmail.isEnabled = true
            txtCode.isEnabled = true
        }
        else
        {
            // Not connected to Internet

            btnNew.isEnabled = false
            txtEmail.isEnabled = false
            txtCode.isEnabled = false
        }
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let myReachability = Reachability()
        if !myReachability.isConnectedToNetwork()
        {
            let alert = UIAlertController(title: "Team Maintenance", message: "You must be connected to the Internet to create or edit teams", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnNew(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
        communicationDelegate?.orgEdit!(nil)
    }

    @IBAction func btnExisting(_ sender: UIButton)
    {
        // first lets check we have the fields
        
        if txtCode.text! == "" || txtEmail.text! == ""
        {
            let alert = UIAlertController(title: "Join a team", message: "You must provide both your email address, and the code provided by your Administrator", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
        else
        {
            btnExisting.isEnabled = false
            btnNew.isEnabled = false
            btnExisting.setTitle("Processing.  Please wait", for: .normal)

            notificationCenter.addObserver(self, selector: #selector(self.userValidated), name: NotificationValidateUser, object: nil)
            
            myCloudDB.validateUser(email: txtEmail.text!, passPhrase: txtCode.text!)
        }
    }
    
    func userValidated()
    {
        notificationCenter.removeObserver(NotificationValidateUser)
        
        sleep(2)
        
        let userList = myCloudDB.retrieveUserList()
        if userList.count > 0
        {

            currentUser = userItem(userID: userList[0].userID)
            writeDefaultInt(userDefaultName, value: currentUser.userID)
            
            myCloudDB.replaceUserTeamsInCoreData()
            
            sleep(2)
            myCloudDB.replaceTeamInCoreData()
            
            sleep(2)
            
//            myCloudDB.updatePublicDecodesInCoreData()
            
//            sleep(2)
            
//            currentUser.loadTeams()
            
//            currentUser.addInitialUserRoles()
            
            communicationDelegate!.callLoadMainScreen!()
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Join a team", message: "Your details do not match.  Please try again or contact your Administrator for a new code", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
            
            DispatchQueue.main.async
            {
                self.btnExisting.setTitle("Join an existing Organisation", for: .normal)
                self.btnExisting.isEnabled = true
                self.btnNew.isEnabled = true
            }
        }
    }
    
    @IBAction func txtEntry(_ sender: UITextField)
    {
        if txtCode.text!.characters.count > 0 && txtEmail.text!.characters.count > 0
        {
            btnExisting.isEnabled = true
        }
        else
        {
            btnExisting.isEnabled = false
        }
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        let deviceIdiom = getDeviceType()
        
        if deviceIdiom == .pad
        {
            if !keyboardDisplayed
            {
                if originalTextHeight == 0.0
                {
                    originalTextHeight = newTextHeightConstraint.constant
                }
                newTextHeightConstraint.constant = 0
                
                newButtonVerticalConstraint.constant = newButtonVerticalConstraint.constant - 100
                newTextVerticalConstraint.constant = newTextVerticalConstraint.constant - 100
                ExistingHeightConstraint.constant = 0
                
                keyboardDisplayed = true
            }
        }
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        let deviceIdiom = getDeviceType()
        
        if deviceIdiom == .pad
        {
            newTextHeightConstraint.constant = originalTextHeight
            newButtonVerticalConstraint.constant = newButtonVerticalConstraint.constant + 100
            newTextVerticalConstraint.constant = newTextVerticalConstraint.constant + 100
            ExistingHeightConstraint.constant = 150
            keyboardDisplayed = false
        }
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
    }
}
