//
//  orgEditViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class orgEditViewController: UIViewController
{
    @IBOutlet weak var txtOrgName: UITextField!
    @IBOutlet weak var txtExternalID: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnUsers: UIButton!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!

    var workingOrganisation: team?
    var loginDelegate: myLoginDelegate?
    @IBOutlet weak var btnStatus: UIButton!
    
    override func viewDidLoad()
    {
        
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        
        if workingOrganisation == nil
        {
            notificationCenter.addObserver(self, selector: #selector(self.teamCreated(_:)), name: NotificationTeamCreated, object: nil)

            workingOrganisation = team()
            // Step 1 is to create a new team
            
            btnSave.isEnabled = false
            btnUsers.isEnabled = false
        }
        else
        {
            txtOrgName.text = workingOrganisation!.name
            txtExternalID.text = workingOrganisation!.externalID
            txtNotes.text = workingOrganisation!.note
            btnCancel.isEnabled = true
            btnSave.isEnabled = true
            btnUsers.isEnabled = true
            btnStatus.isEnabled = true
            btnStatus.setTitle(workingOrganisation!.status, for: .normal)
        }
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCancel(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
        if workingOrganisation != nil
        {
            workingOrganisation!.name = txtOrgName.text!
            
            var extID: String = ""
            
            if txtExternalID.text! != ""
            {
                extID = txtExternalID.text!
            }
            
            workingOrganisation!.externalID = extID
            
            workingOrganisation!.note = txtNotes.text
            workingOrganisation!.status = btnStatus.currentTitle!
            
            workingOrganisation?.save()
        }
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
    }
    
    @IBAction func btnUsers(_ sender: UIButton)
    {
    }
    
    func teamCreated(_ notification: Notification)
    {
        notificationCenter.removeObserver(NotificationTeamCreated)
        
        // Now lets go and create an initial user

        currentUser = userItem(teamID: workingOrganisation!.teamID)

        notificationCenter.addObserver(self, selector: #selector(self.addTeamToUser), name: NotificationUserCreated, object: nil)
    }
    
    func addTeamToUser()
    {
        notificationCenter.removeObserver(NotificationUserCreated)
        currentUser.addTeamToUser(workingOrganisation!)
   
        addInitialUserRoles()
        
        DispatchQueue.main.async
        {
            self.btnSave.isEnabled = true
            self.btnUsers.isEnabled = true
        }
    }
    
    func addInitialUserRoles()
    {
        for myItem in (currentUser.currentTeam?.getRoleTypes())!
        {
            currentUser.addRoleToUser(roleType: myItem, accessLevel: "Write")
        }
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        let deviceIdiom = getDeviceType()
        
        if deviceIdiom == .pad
        {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            {
                bottomContraint.constant = CGFloat(20) + keyboardSize.height
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        let deviceIdiom = getDeviceType()
        
        if deviceIdiom == .pad
        {
            bottomContraint.constant = CGFloat(20)
        }
    }
}

