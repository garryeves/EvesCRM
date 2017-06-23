//
//  personViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 16/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit
import ContactsUI

class personViewController: UIViewController, UIPopoverPresentationControllerDelegate, myCommunicationDelegate, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate, CNContactPickerDelegate, UITextViewDelegate
{
    @IBOutlet weak var tblPeople: UITableView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnDOB: UIButton!
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
    @IBOutlet weak var lblGener: UILabel!
    @IBOutlet weak var btnAddresses: UIButton!
    @IBOutlet weak var btnContacts: UIButton!
    @IBOutlet weak var lblAddInfo: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var tblAddInfo: UITableView!
    @IBOutlet weak var btnImport: UIButton!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnAdd: UIBarButtonItem!
    @IBOutlet weak var tblContacts: UITableView!
    @IBOutlet weak var tblAddresses: UITableView!
    @IBOutlet weak var tblShifts: UITableView!
    @IBOutlet weak var lblRoster: UILabel!
    @IBOutlet weak var switchRoster: UISwitch!
    
    var communicationDelegate: myCommunicationDelegate?
    var clientID: Int!
    var projectID: Int!
    
    private var myPeople: people!
    private var keyboardDisplayed: Bool = false
    private var selectedPerson: person!
    private var displayList: [String] = Array()
    fileprivate var addInfoRecords: personAdditionalInfos!
    
    override func viewDidLoad()
    {
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        txtNotes.delegate = self
        
        addInfoRecords = personAdditionalInfos(teamID: currentUser!.currentTeam!.teamID)
        
        hideFields()
        
        refreshScreen()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshAddInfo), name: NotificationAddInfoDone, object: nil)

        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblPeople:
                if myPeople == nil
                {
                    return 0
                }
                else
                {
                    return myPeople.people.count
                }
            
            case tblAddInfo:
                return addInfoRecords.personAdditionalInfos.count
            
            case tblContacts:
                if selectedPerson == nil
                {
                    return 0
                }
                else
                {
                    return selectedPerson.contacts.count
                }
                
            case tblAddresses:
                if selectedPerson == nil
                {
                    return 0
                }
                else
                {
                    return selectedPerson.addresses.count
                }
            
            case tblShifts:
                if selectedPerson == nil
                {
                    return 0
                }
                else
                {
                    return selectedPerson.shiftArray.count
                }
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblPeople:
                let cell = tableView.dequeueReusableCell(withIdentifier:"personCell", for: indexPath) as! personListItem
                
                cell.lblName.text = myPeople.people[indexPath.row].name
                
                if myPeople.people[indexPath.row].dobText == "Select"
                {
                    cell.lblDOB.text = ""
                }
                else
                {
                    cell.lblDOB.text = myPeople.people[indexPath.row].dobText
                }
                
                return cell
                
            case tblAddInfo:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellAddInfo", for: indexPath) as! personAddInfoListItem

                if selectedPerson != nil
                {
                    cell.lblDescription.text = addInfoRecords.personAdditionalInfos[indexPath.row].addInfoName
                    
                    switch addInfoRecords.personAdditionalInfos[indexPath.row].addInfoType
                    {
                        case perInfoText:
                            cell.btnDate.isHidden = true
                            cell.btnYesNo.isHidden = true
                            cell.txtValue.isHidden = false
                            
                            // Get the value, if one exists
                            
                            let tempItem = personAddInfoEntry(addInfoName: addInfoRecords.personAdditionalInfos[indexPath.row].addInfoName, personID: selectedPerson.personID, teamID: currentUser.currentTeam!.teamID)
                            
                            cell.txtValue.text = tempItem.stringValue
                            cell.addInfoEntry = tempItem
                        
                        case perInfoDate:
                            cell.btnDate.isHidden = false
                            cell.btnYesNo.isHidden = true
                            cell.txtValue.isHidden = true
                        
                            // Get the value, if one exists
                            
                            let tempItem = personAddInfoEntry(addInfoName: addInfoRecords.personAdditionalInfos[indexPath.row].addInfoName, personID: selectedPerson.personID, teamID: currentUser.currentTeam!.teamID)
                            
                            cell.btnDate.setTitle(tempItem.dateString, for: .normal)
                            cell.addInfoEntry = tempItem
                        
                        case perInfoYesNo:
                            cell.btnDate.isHidden = true
                            cell.btnYesNo.isHidden = false
                            cell.txtValue.isHidden = true
                            
                            // Get the value, if one exists
                            
                            let tempItem = personAddInfoEntry(addInfoName: addInfoRecords.personAdditionalInfos[indexPath.row].addInfoName, personID: selectedPerson.personID, teamID: currentUser.currentTeam!.teamID)
                            
                            if tempItem.stringValue == ""
                            {
                                cell.btnYesNo.setTitle("Select", for: .normal)
                            }
                            else
                            {
                                cell.btnYesNo.setTitle(tempItem.stringValue, for: .normal)
                            }
                            
                            cell.addInfoEntry = tempItem
                        
                        default:
                            cell.btnDate.isHidden = true
                            cell.btnYesNo.isHidden = true
                            cell.txtValue.isHidden = true
                    }
            
                    cell.parentViewController = self
                }
                return cell
            
            case tblContacts:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellContact", for: indexPath) as! contactDetailsItem
                cell.lblType.text = selectedPerson.contacts[indexPath.row].contactType
                cell.lblDetail.text = selectedPerson.contacts[indexPath.row].contactValue
                return cell
            
            case tblAddresses:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellAddress", for: indexPath) as! contactDetailsItem
                cell.lblType.text = selectedPerson.addresses[indexPath.row].addressType
                cell.lblDetail.text = selectedPerson.addresses[indexPath.row].addressLine1
                return cell
            
            case tblShifts:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellShift", for: indexPath) as! contactDetailsItem
                
                // Build the display string
                
                let dateString = "\(selectedPerson.shiftArray[indexPath.row].workDateString) \(selectedPerson.shiftArray[indexPath.row].startTimeString) - \(selectedPerson.shiftArray[indexPath.row].endTimeString)"
                cell.lblType.text = dateString
                
                let tempProject = project(projectID: selectedPerson.shiftArray[indexPath.row].projectID)
                cell.lblDetail.text = tempProject.projectName
                
            return cell
            
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblPeople:
                showFields()
                if selectedPerson != nil
                {
                    if txtName.isFirstResponder
                    {
                        validateName("")
                    }
                }
                selectedPerson = myPeople.people[indexPath.row]
                
                loadDetails()
            
            case tblAddInfo:
                let _ = 1
            
            case tblContacts:
                let contactsView = personStoryboard.instantiateViewController(withIdentifier: "contactsForm") as! contactsViewController
                contactsView.modalPresentationStyle = .popover
                
                let popover = contactsView.popoverPresentationController!
                popover.delegate = self
                popover.sourceView = btnContacts
                popover.sourceRect = btnContacts.bounds
                popover.permittedArrowDirections = .any
                
                contactsView.workingPerson = selectedPerson
                contactsView.preferredContentSize = CGSize(width: 700,height: 120)
                
                self.present(contactsView, animated: true, completion: nil)
            
            case tblAddresses:
                let addressView = personStoryboard.instantiateViewController(withIdentifier: "addressView") as! addressesViewController
                addressView.modalPresentationStyle = .popover
                
                let popover = addressView.popoverPresentationController!
                popover.delegate = self
                popover.sourceView = btnAddresses
                popover.sourceRect = btnAddresses.bounds
                popover.permittedArrowDirections = .any
                
                addressView.workingPerson = selectedPerson
                addressView.preferredContentSize = CGSize(width: 700,height: 300)
                
                self.present(addressView, animated: true, completion: nil)
            
            default:
                let _ = 1
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        if tableView == tblPeople
        {
            return UITableViewCellEditingStyle.delete
        }
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            if tableView == tblPeople
            {
                myPeople.people[indexPath.row].delete()
            }
            
            refreshScreen()
        }
    }
    
    @IBAction func switchRoster(_ sender: UISwitch)
    {
        if sender.isOn
        {
            selectedPerson.canRoster = "True"
        }
        else
        {
            selectedPerson.canRoster = "False"
        }
    }
    
    @IBAction func btnDOB(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "DOB"
        pickerView.delegate = self
        if selectedPerson.dob == getDefaultDate()
        {
            pickerView.currentDate = Date()
        }
        else
        {
            pickerView.currentDate = selectedPerson.dob
        }
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnGender(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("Female")
        displayList.append("Male")
        displayList.append("Other")
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            //      pickerView.isModalInPopover = true
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "gender"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAdd(_ sender: UIBarButtonItem)
    {
        selectedPerson = person(teamID: currentUser.currentTeam!.teamID)
        
        if clientID != nil
        {
            selectedPerson.clientID = clientID
        }
        
        if projectID != nil
        {
            selectedPerson.projectID = projectID
        }
        
        showFields()
        
        txtName.text = selectedPerson.name
        btnDOB.setTitle("Select", for: .normal)
        btnGender.setTitle("Select", for: .normal)
        txtNotes.text = selectedPerson.note
        switchRoster.isOn = false
        
        tblAddInfo.reloadData()
    }
    
    @IBAction func btnAddresses(_ sender: UIButton)
    {
        let addressView = personStoryboard.instantiateViewController(withIdentifier: "addressView") as! addressesViewController
        addressView.modalPresentationStyle = .popover
        
        let popover = addressView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        addressView.workingPerson = selectedPerson
        addressView.preferredContentSize = CGSize(width: 700,height: 300)
        
        self.present(addressView, animated: true, completion: nil)
    }
    
    @IBAction func btnContacts(_ sender: UIButton)
    {
        let contactsView = personStoryboard.instantiateViewController(withIdentifier: "contactsForm") as! contactsViewController
        contactsView.modalPresentationStyle = .popover
        
        let popover = contactsView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        contactsView.workingPerson = selectedPerson
        contactsView.preferredContentSize = CGSize(width: 700,height: 120)
        
        self.present(contactsView, animated: true, completion: nil)
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView == txtNotes
        {
            selectedPerson.note = txtNotes.text!
        }
    }

    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        if txtName.isFirstResponder
        {
            validateName("exit")
        }
        else
        {
            if txtNotes.isFirstResponder
            {
                selectedPerson.note = txtNotes.text!
            }
            
            self.dismiss(animated: true, completion: nil)
            communicationDelegate?.refreshScreen!()
        }
    }
    
    @IBAction func btnImport(_ sender: UIButton)
    {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact])
    {
        contacts.forEach{ contact in
            
            let workingContact = iOSContact(contactRecord: contact)
            
            let workingRecord = person(teamID: currentUser.currentTeam!.teamID)
            if clientID != nil
            {
                workingRecord.clientID = clientID
            }
            
            if projectID != nil
            {
                workingRecord.projectID = projectID
            }
            
            workingRecord.name = workingContact.fullName
            
            if workingContact.dateOfBirth != nil
            {
                workingRecord.dob  = workingContact.dateOfBirth!
            }
            
            workingRecord.save()
            
            for myItem in workingContact.addresses
            {
                for myType in ["Home", "Office", "Other"]
                {
                    if myItem.type == myType
                    {
                        let workingAddress = address(teamID: currentUser.currentTeam!.teamID)
                        workingAddress.personID = workingRecord.personID
                        workingAddress.addressType = myItem.type
                        workingAddress.addressLine1 = myItem.line1
                        workingAddress.addressLine2 = myItem.line2
                        workingAddress.city = myItem.city
                        workingAddress.state = myItem.state
                        workingAddress.country = myItem.country
                        workingAddress.postcode = myItem.postcode
                        
                        workingAddress.save()
                        break
                    }
                }
            }
            
            for myItem in workingContact.phoneNumbers
            {
                for myType in ["Home Phone", "Office Phone", "Mobile Phone"]
                {
                    if myItem.type == myType
                    {
                        let workingDetail = contactItem(teamID: currentUser.currentTeam!.teamID)
                        workingDetail.personID = workingRecord.personID
                        workingDetail.contactType = myItem.type
                        workingDetail.contactValue = myItem.detail
                        
                        workingDetail.save()
                        break
                    }
                }
            }
            
            for myItem in workingContact.emailAddresses
            {
                for myType in ["Home Email", "Office Email"]
                {
                    if myItem.type == myType
                    {
                        let workingDetail = contactItem(teamID: currentUser.currentTeam!.teamID)
                        workingDetail.personID = workingRecord.personID
                        workingDetail.contactType = myItem.type
                        workingDetail.contactValue = myItem.detail
                        
                        workingDetail.save()
                        break
                    }
                }
            }
            
            sleep(1)
        }
        
        hideFields()
        refreshScreen()
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController)
    {
        print("Cancel Contact Picker")
    }
    
    @IBAction func txtName(_ sender: UITextField)
    {
        validateName("refresh")
    }
    
    func validateName(_ postAction: String)
    {
        let workingPerson = selectedPerson!
        let currentName = workingPerson.name
        let newName = txtName.text!
        
        if currentName != "" && newName != currentName
        {
            let alert = UIAlertController(title: "Change Name", message:
                "Change name from \(currentName) to \(txtName.text!)", preferredStyle: UIAlertControllerStyle.alert)
            
            let yesOption = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler:  {(action: UIAlertAction) -> () in
                workingPerson.name = newName
                
                if postAction == "refresh"
                {
                    self.refreshScreen()
                }
                else if postAction == "exit"
                {
                    self.dismiss(animated: true, completion: nil)
                    self.communicationDelegate?.refreshScreen!()
                }
                else
                {
                    self.tblPeople.reloadData()
                }
            })
            
            let noOption = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> () in
                if postAction == "refresh"
                {
                    self.txtName.text! = currentName
                }
                else if postAction == "exit"
                {
                    self.dismiss(animated: true, completion: nil)
                    self.communicationDelegate?.refreshScreen!()
                }
                else
                {
                    self.tblPeople.reloadData()
                }
            })
            
            alert.addAction(yesOption)
            alert.addAction(noOption)
            self.present(alert, animated: false, completion: nil)
        }
        else if workingPerson.name == "" && newName != ""
        {
            workingPerson.name = newName
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "gender"
        {
            selectedPerson.gender = displayList[selectedItem]
            btnGender.setTitle(displayList[selectedItem], for: .normal)
        }
    }

    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        if source == "DOB"
        {
            selectedPerson.dob = selectedDate
            btnDOB.setTitle(selectedPerson.dobText, for: .normal)
        }
    }
    
    func hideFields()
    {
        txtName.isHidden = true
        btnDOB.isHidden = true
        btnGender.isHidden = true
        lblName.isHidden = true
        lblDOB.isHidden = true
        lblGener.isHidden = true
        btnAddresses.isHidden = true
        btnContacts.isHidden = true
        lblAddInfo.isHidden = true
        lblNotes.isHidden = true
        txtNotes.isHidden = true
        tblAddInfo.isHidden = true
        btnImport.isHidden = false
        tblContacts.isHidden = true
        tblAddresses.isHidden = true
        tblShifts.isHidden = true
        lblRoster.isHidden = true
        switchRoster.isHidden = true
    }
    
    func showFields()
    {
        txtName.isHidden = false
        btnDOB.isHidden = false
        btnGender.isHidden = false
        lblName.isHidden = false
        lblDOB.isHidden = false
        lblGener.isHidden = false
        btnAddresses.isHidden = false
        btnContacts.isHidden = false
        lblAddInfo.isHidden = false
        lblNotes.isHidden = false
        txtNotes.isHidden = false
        tblAddInfo.isHidden = false
        btnImport.isHidden = true
        tblContacts.isHidden = false
        tblAddresses.isHidden = false
        tblShifts.isHidden = false
        lblRoster.isHidden = false
        switchRoster.isHidden = false
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        let deviceIdiom = getDeviceType()
        
        if deviceIdiom == .pad
        {
            if !keyboardDisplayed
            {
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
                {
                    bottomContraint.constant = CGFloat(20) + keyboardSize.height
                }
                
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
            bottomContraint.constant = 20
            
            keyboardDisplayed = false
        }
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
    }
    
    func refreshScreen()
    {
        if clientID != nil
        {
            myPeople = people(clientID: clientID)
        }
        else if projectID != nil
        {
            myPeople = people(projectID: projectID)
        }
        else
        {
            myPeople = people(teamID: currentUser.currentTeam!.teamID)
        }
        
        tblPeople.reloadData()
        loadDetails()
    }
    
    func loadDetails()
    {
        if selectedPerson != nil
        {
            selectedPerson.loadAddresses()
            selectedPerson.loadContacts()
            selectedPerson.loadAddInfo()
            selectedPerson.loadShifts()
            
            txtName.text = selectedPerson.name
            btnDOB.setTitle(selectedPerson.dobText, for: .normal)
            btnGender.setTitle(selectedPerson.gender, for: .normal)
            txtNotes.text = selectedPerson.note
            btnAddresses.setTitle("Addresses (\(selectedPerson.addresses.count))", for: .normal)
            btnContacts.setTitle("Contact Details (\(selectedPerson.contacts.count))", for: .normal)
            if selectedPerson.canRoster == "True"
            {
                switchRoster.isOn = true
            }
            else
            {
                switchRoster.isOn = false
            }
            tblAddInfo.reloadData()
            tblAddresses.reloadData()
            tblContacts.reloadData()
            tblShifts.reloadData()
        }
    }
    
    func refreshAddInfo()
    {
        tblAddInfo.reloadData()
    }
}

class personListItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
}

class personAddInfoListItem: UITableViewCell, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnYesNo: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var txtValue: UITextField!
    
    var parentViewController: personViewController!
    var addInfoEntry: personAddInfoEntry!

    fileprivate var displayList: [String] = Array()
    
    @IBAction func btnYesNo(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("Yes")
        displayList.append("No")
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "YesNo"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            parentViewController.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "Date"
        pickerView.delegate = self
        pickerView.currentDate = Date()
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        parentViewController.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func txtValue(_ sender: UITextField)
    {
        addInfoEntry.stringValue = sender.text!
        addInfoEntry.save()
        NotificationCenter.default.post(name: NotificationAddInfoDone, object: nil)
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "YesNo"
        {
            if selectedItem >= 0
            {
                addInfoEntry.stringValue = displayList[selectedItem]
                addInfoEntry.save()
                NotificationCenter.default.post(name: NotificationAddInfoDone, object: nil)
            }
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        if source == "Date"
        {
            addInfoEntry.dateValue = selectedDate
            addInfoEntry.save()
            NotificationCenter.default.post(name: NotificationAddInfoDone, object: nil)
        }
    }
}

class contactDetailsItem: UITableViewCell
{
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

