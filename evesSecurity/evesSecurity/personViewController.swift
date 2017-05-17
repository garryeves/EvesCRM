//
//  personViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 16/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class personViewController: UIViewController, UIPopoverPresentationControllerDelegate, myCommunicationDelegate, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate
{
    @IBOutlet weak var tblPeople: UITableView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnDOB: UIButton!
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
    @IBOutlet weak var lblGener: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnAddresses: UIButton!
    @IBOutlet weak var btnContacts: UIButton!
    @IBOutlet weak var lblAddInfo: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var tblAddInfo: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnImport: UIButton!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    
    var communicationDelegate: myCommunicationDelegate?
    
    private var myPeople: people!
    private var myAddInfo: [personAddInfoEntry] = Array()
    private var keyboardDisplayed: Bool = false
    private var selectedPerson: person!
    private var displayList: [String] = Array()
    
    override func viewDidLoad()
    {
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        
        hideFields()
        
        refreshScreen()
        
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
                return myAddInfo.count
            
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
                return UITableViewCell()
                
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
                selectedPerson = myPeople.people[indexPath.row]
                loadDetails()
            
            case tblAddInfo:
                let _ = 1
                
            default:
                let _ = 1
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
        
        displayList.append("")
        displayList.append("Female")
        displayList.append("Male")
        displayList.append("Other")
        
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
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnAdd(_ sender: UIButton)
    {
        selectedPerson = person(teamID: currentUser.currentTeam!.teamID)
        
        showFields()
        
        txtName.text = ""
        btnDOB.setTitle("Select", for: .normal)
        btnGender.setTitle("Select", for: .normal)
        txtNotes.text = ""
        
        clearAddInfo()
        tblAddInfo.reloadData()
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
        if selectedPerson != nil
        {
            selectedPerson.name = txtName.text!
            selectedPerson.note = txtNotes.text
                
            selectedPerson.save()
            
            refreshScreen()
        }
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
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
        communicationDelegate?.refreshScreen!()
    }
    
    @IBAction func btnImport(_ sender: UIButton)
    {
    }
    
    @IBAction func txtName(_ sender: UITextField)
    {
        if sender.text == ""
        {
            btnSave.isHidden = true
        }
        else
        {
            btnSave.isHidden = false
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "gender"
        {
            selectedPerson.gender = displayList[selectedItem]
            btnGender.setTitle(displayList[selectedItem], for: .normal)
            btnSave.isHidden = false
        }
    }

    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        if source == "DOB"
        {
            selectedPerson.dob = selectedDate
            btnDOB.setTitle(selectedPerson.dobText, for: .normal)
            btnSave.isHidden = false
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
        btnSave.isHidden = true
        btnAddresses.isHidden = true
        btnContacts.isHidden = true
        lblAddInfo.isHidden = true
        lblNotes.isHidden = true
        txtNotes.isHidden = true
        tblAddInfo.isHidden = true
        btnImport.isHidden = true
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
        btnImport.isHidden = false
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
        myPeople = people()
        
        tblPeople.reloadData()
        loadDetails()
    }
    
    func loadDetails()
    {
        if selectedPerson != nil
        {
            txtName.text = selectedPerson.name
            btnDOB.setTitle(selectedPerson.dobText, for: .normal)
            btnGender.setTitle(selectedPerson.gender, for: .normal)
            txtNotes.text = selectedPerson.note
            btnAddresses.setTitle("Addresses (\(selectedPerson.addresses.count))", for: .normal)
            btnContacts.setTitle("Contact Details (\(selectedPerson.contacts.count))", for: .normal)
            loadAddInfo()
            tblAddInfo.reloadData()
        }
    }
    
    func clearAddInfo()
    {
        myAddInfo.removeAll()
    }
    
    func loadAddInfo()
    {
        myAddInfo = selectedPerson.addInfo
    }
}

class personListItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
}



