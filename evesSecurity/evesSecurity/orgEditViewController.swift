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
            txtExternalID.text = "\(workingOrganisation!.externalID ?? 0)"
            txtNotes.text = workingOrganisation!.note
            btnCancel.isHidden = false
            btnSave.isHidden = false
            btnUsers.isHidden = false
            btnStatus.isHidden = false
            btnStatus.setTitle(workingOrganisation!.status, for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCancel(_ sender: UIButton)
    {
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
        if workingOrganisation != nil
        {
            workingOrganisation!.name = txtOrgName.text!
            
            var extID: Int32 = 0
            
            if txtExternalID.text! != ""
            {
                extID = Int32(txtExternalID.text!)!
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

        currentUser = userItem()

        notificationCenter.addObserver(self, selector: #selector(self.addTeamToUser), name: NotificationUserCreated, object: nil)
    }
    
    func addTeamToUser()
    {
        notificationCenter.removeObserver(NotificationUserCreated)
        currentUser.addTeamToUser(workingOrganisation!)
        
        btnSave.isEnabled = true
        btnUsers.isEnabled = true
    }
}

