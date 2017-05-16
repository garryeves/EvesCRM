//
//  personViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 16/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class personViewController: UIViewController, UIPopoverPresentationControllerDelegate, myCommunicationDelegate, UITableViewDataSource, UITableViewDelegate
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
                txtName.text = myPeople.people[indexPath.row].name
                btnDOB.setTitle(myPeople.people[indexPath.row].dobText, for: .normal)
                btnGender.setTitle(myPeople.people[indexPath.row].gender, for: .normal)
                txtNotes.text = myPeople.people[indexPath.row].note
                    
                loadAddInfo()
                tblAddInfo.reloadData()
                
            case tblAddInfo:
                let _ = 1
                
            default:
                let _ = 1
        }
    }
    
    @IBAction func btnDOB(_ sender: UIButton)
    {
    }
    
    @IBAction func btnGender(_ sender: UIButton)
    {
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



