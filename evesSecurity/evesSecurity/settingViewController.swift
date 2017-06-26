//
//  settingViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 15/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class settingsViewController: UIViewController, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    @IBOutlet weak var btnTeam: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    @IBOutlet weak var btnPerAddInfo: UIButton!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnDropbown: UIButton!
    @IBOutlet weak var btnSwitchUsers: UIButton!
    @IBOutlet weak var btnRestore: UIButton!
    
    var communicationDelegate: myCommunicationDelegate?
    
    private var displayList: [String] = Array()
    private var teamList: userTeams!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        refreshScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnTeam(_ sender: UIButton)
    {
        let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
        orgEditViewControl.workingOrganisation = currentUser!.currentTeam
        self.present(orgEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnPassword(_ sender: UIButton)
    {
        let passwordView = loginStoryboard.instantiateViewController(withIdentifier: "setPassword") as! setPasswordViewController
        passwordView.modalPresentationStyle = .popover
        
        let popover = passwordView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        passwordView.preferredContentSize = CGSize(width: 600,height: 500)
        
        self.present(passwordView, animated: true, completion: nil)
    }
    
    @IBAction func btnPerAddInfo(_ sender: UIButton)
    {
        let addPerInfoViewControl = personStoryboard.instantiateViewController(withIdentifier: "AddPersonInfo") as! addPerInfoMaintenanceViewController
        self.present(addPerInfoViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnDropdowns(_ sender: UIButton)
    {
        let dropdownEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "dropdownMaintenance") as! dropdownMaintenanceViewController
        self.present(dropdownEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnRestore(_ sender: UIButton)
    {
        let deletedItemsViewControl = self.storyboard?.instantiateViewController(withIdentifier: "securityDeletedItems") as! securityDeletedItemsViewController
        self.present(deletedItemsViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnSwitchUsers(_ sender: UIButton)
    {
        teamList = userTeams(userID: currentUser.userID)
        displayList.removeAll()
        
        for myItem in teamList.UserTeams
        {
            let tempTeam = team(teamID: myItem.teamID)
            displayList.append(tempTeam.name)
        }
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "TeamList"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "TeamList"
        {
            if selectedItem >= 0
            {
                currentUser.currentTeam = team(teamID: teamList.UserTeams[selectedItem].teamID)
                writeDefaultInt("teamID", value: currentUser.currentTeam!.teamID)
            }
        }
    }
    
    @IBAction func btnBack(_ sender: Any)
    {
        communicationDelegate!.refreshScreen!()
        dismiss(animated: true, completion: nil)
    }
    
    func refreshScreen()
    {
        if userTeams(userID: currentUser.userID).UserTeams.count > 1
        {
            btnSwitchUsers.isHidden = false
        }
        else
        {
            btnSwitchUsers.isHidden = true
        }
        
        if currentUser.checkPermission(adminRoleType) != noPermission
        {
            btnTeam.isEnabled = true
            btnPerAddInfo.isEnabled = true
            btnDropbown.isEnabled = true
            btnRestore.isEnabled = true
        }
        else
        {
            btnTeam.isEnabled = false
            btnPerAddInfo.isEnabled = false
            btnDropbown.isEnabled = false
            btnRestore.isEnabled = false
        }
    }
}

