//
//  orgEditViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class orgEditViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var txtOrgName: UITextField!
    @IBOutlet weak var txtExternalID: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var btnUsers: UIButton!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak var txtCompanyNo: UITextField!
    @IBOutlet weak var txtTaxNo: UITextField!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnSave: UIBarButtonItem!

    private var newUserCreated: Bool = false
    private var displayList: [String] = Array()
    
    var workingOrganisation: team?
    var communicationDelegate: myCommunicationDelegate?
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
            
            btnStatus.setTitle("Open", for: .normal)
            btnSave.isEnabled = false
            btnUsers.isEnabled = false
            txtOrgName.isEnabled = false
        }
        else
        {
            txtOrgName.text = workingOrganisation!.name
            txtExternalID.text = workingOrganisation!.externalID
            txtNotes.text = workingOrganisation!.note
            txtCompanyNo.text = workingOrganisation!.taxNumber
            txtTaxNo.text = workingOrganisation!.companyRegNumber
            
            btnBack.isEnabled = true
            btnSave.isEnabled = true
            btnUsers.isEnabled = true
            btnStatus.isEnabled = true
            btnStatus.setTitle(workingOrganisation!.status, for: .normal)
        }
    
        let myReachability = Reachability()
        if myReachability.isConnectedToNetwork()
        {
            btnUsers.isEnabled = true
        }
        else
        {
            btnUsers.isEnabled = false
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
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                                          handler: { (action: UIAlertAction) -> () in
                                            self.dismiss(animated: true, completion: nil)
            }))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
        
        if newUserCreated
        {
            communicationDelegate?.userCreated!(currentUser, teamID: workingOrganisation!.teamID)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem)
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
            workingOrganisation!.taxNumber = txtCompanyNo.text!
            workingOrganisation!.companyRegNumber = txtTaxNo.text!
            
            workingOrganisation?.save()
        }
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in (workingOrganisation?.getDropDown(dropDownType: "TeamState"))!
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "status"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)

        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnUsers(_ sender: UIButton)
    {
        let userEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "userForm") as! userFormViewController
        self.present(userEditViewControl, animated: true, completion: nil)
    }
    
    func teamCreated(_ notification: Notification)
    {
        notificationCenter.removeObserver(NotificationTeamCreated)
        
        // Now lets go and create an initial user

        if currentUser == nil
        {
            currentUser = userItem(currentTeam: workingOrganisation!, userName: "", userEmail: "")
            
            notificationCenter.addObserver(self, selector: #selector(self.addTeamToUser), name: NotificationUserCreated, object: nil)
        }
        else
        {
            addTeamToUser()
        }
        
        DispatchQueue.main.async
        {
            self.btnSave.isEnabled = true
            self.btnUsers.isEnabled = true
            self.txtOrgName.isEnabled = true
        }
    }
    
    func addTeamToUser()
    {
        notificationCenter.removeObserver(NotificationUserCreated)
   
        addInitialUserRoles()
    }
    
    func addInitialUserRoles()
    {
        writeDefaultInt(userDefaultName, value: currentUser.userID)

        currentUser.addInitialUserRoles()
        newUserCreated = true
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "status"
        {
            btnStatus.setTitle(displayList[selectedItem], for: .normal)
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
    
//    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
//        return .none
//    }
}

