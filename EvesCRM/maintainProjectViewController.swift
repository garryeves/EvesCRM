//
//  maintainProjectViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 4/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Contacts
import ContactsUI
import TextExpander

protocol MyMaintainProjectDelegate{
    func myMaintainProjectDidFinish(_ controller:MaintainProjectViewController, actionType: String)
    func myGTDPlanningDidFinish(_ controller:MaintainGTDPlanningViewController)
}

class MaintainProjectViewController: UIViewController, CNContactPickerDelegate, MyMaintainProjectDelegate, SMTEFillDelegate, UITextViewDelegate, UITextFieldDelegate
{
   fileprivate var passedGTD: GTDModel!
    
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var teamMembersLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var statusPicker: UIPickerView!
    @IBOutlet weak var btnStartDate: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var btnProjectStage: UIButton!
    @IBOutlet weak var btnSelectPicker: UIButton!
    @IBOutlet weak var colTeamMembers: UICollectionView!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var lblRepeatEvery: UILabel!
    @IBOutlet weak var lblReviewEvery: UILabel!
    @IBOutlet weak var lblFromActivity: UILabel!
    @IBOutlet weak var lblLastReviewed: UILabel!
    @IBOutlet weak var lblLastReviewedDate: UILabel!
    @IBOutlet weak var txtRepeatInterval: UITextField!
    @IBOutlet weak var btnRepeatPeriod: UIButton!
    @IBOutlet weak var btnRepeastBase: UIButton!
    @IBOutlet weak var txtReviewFrquency: UITextField!
    @IBOutlet weak var btnReviewPeriod: UIButton!
    @IBOutlet weak var btnMarkReviewed: UIButton!
    
 //   var delegate: MyMaintainProjectDelegate?

    var myActionType: String = "Add"
    var projectObject: project!
    var mySelectedTeam: team!
    
    fileprivate var statusSelected: String = ""
    fileprivate var roleSelected: Int = 0
    fileprivate var myProjects: [project] = Array()
    fileprivate let reuseIdentifierProject = "ProjectCell"
    fileprivate let reuseIdentifierTeam = "TeamMemberCell"
    fileprivate var myRoles: [Roles]!
    fileprivate var myStages: [Stages]!
    fileprivate var mySelectedRoles: [projectTeamMember] = Array()
    fileprivate var mySelectedTeamMember: projectTeamMember!
    fileprivate var personSelected: CNContact!
    fileprivate var teamMemberAction: String = ""
    fileprivate var workingCell: Int = -1
    fileprivate var pickerTarget: String = ""
    fileprivate var pickerDisplayArray: [String] = Array()
    fileprivate var mySelectedRow: Int = -1
    fileprivate var kbHeight: CGFloat!
    
    // Textexpander
    
    fileprivate var snippetExpanded: Bool = false
    
    var textExpander: SMTEDelegateController!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let statusOptions = mySelectedTeam.stages
        
        statusSelected = statusOptions[0].stageDescription!
        teamMembersLabel.isHidden = false

        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        
        showFields()
        
        // Set the initial values

        startDatePicker.isHidden = true
        btnSelectPicker.isHidden = true
        statusPicker.isHidden = true
        
        if projectObject.displayProjectStartDate == ""
        {
            btnStartDate.setTitle("Set Start Date", for: UIControlState())
        }
        else
        {
            btnStartDate.setTitle(projectObject.displayProjectStartDate, for: UIControlState())
        }
        
        if projectObject.displayProjectEndDate == ""
        {
            btnEndDate.setTitle("Set End Date", for: UIControlState())
        }
        else
        {
            btnEndDate.setTitle(projectObject.displayProjectEndDate, for: UIControlState())
        }
        
        if projectObject.projectStatus == ""
        {
            btnProjectStage.setTitle("Set Project Stage", for: UIControlState())
        }
        else
        {
            btnProjectStage.setTitle(projectObject.projectStatus, for: UIControlState())
        }
        
        txtNotes.text = projectObject.note
        txtTitle.text = projectObject.projectName
        
        if projectObject.displayLastReviewDate == ""
        {
            lblLastReviewedDate.text = "Never reviewed"
        }
        else
        {
            lblLastReviewedDate.text = projectObject.displayLastReviewDate
        }
        txtRepeatInterval.text = "\(projectObject.repeatInterval)"
        txtReviewFrquency.text = "\(projectObject.reviewFrequency)"
        
        if projectObject.repeatType == ""
        {
            btnRepeatPeriod.setTitle("Set Period", for: UIControlState())
        }
        else
        {
            btnRepeatPeriod.setTitle(projectObject.repeatType, for: UIControlState())
        }
        
        if projectObject.repeatBase == ""
        {
            btnRepeastBase.setTitle("Set Base", for: UIControlState())
        }
        else
        {
            btnRepeastBase.setTitle(projectObject.repeatBase, for: UIControlState())
        }
 
        if projectObject.reviewPeriod == ""
        {
            btnReviewPeriod.setTitle("Set Period", for: UIControlState())
        }
        else
        {
            btnReviewPeriod.setTitle(projectObject.reviewPeriod, for: UIControlState())
        }

        mySelectedRoles = projectObject.teamMembers
        
        colTeamMembers.isHidden = false
        
        txtRepeatInterval.delegate = self
        txtReviewFrquency.delegate = self
        
        // TextExpander
        textExpander = SMTEDelegateController()
        txtTitle.delegate = textExpander
        txtNotes.delegate = textExpander
        textExpander.clientAppName = "EvesCRM"
        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
        textExpander.fillDelegate = self
        textExpander.nextDelegate = self
        myCurrentViewController = MaintainProjectViewController()
        myCurrentViewController = self
        
        notificationCenter.addObserver(self, selector: #selector(self.addTeamMember(_:)), name: NotificationAddTeamMember, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.changeRole(_:)), name: NotificationChangeRole, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.performDeleteTeamMember(_:)), name: NotificationPerformDelete, object: nil)

    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        notificationCenter.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        txtTitle.endEditing(true)
    }
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
        {
            // Do nothing
        }
        else
        {
            passedGTD.delegate.myMaintainProjectDidFinish(self, actionType: "Cancel")
        }
    }

    func numberOfComponentsInPickerView(_ iicker: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ Picker: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerDisplayArray.count
    }
    
    func pickerView(_ Picker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return pickerDisplayArray[row]
    }

    func pickerView(_ Picker: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        mySelectedRow = row
    }

    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return mySelectedRoles.count + 1
    }
 
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellTeamMembers", for: indexPath) as! myProjectItem
        cell.btnAction.tag = indexPath.row
        
        if indexPath.row < mySelectedRoles.count
        {
            cell.btnTeamMember.setTitle(mySelectedRoles[indexPath.row].teamMember, for: UIControlState())
            if mySelectedRoles[indexPath.row].roleName == ""
            {
                cell.btnRole.setTitle("Select Role", for: UIControlState())
            }
            else
            {
                cell.btnRole.setTitle(mySelectedRoles[indexPath.row].roleName, for: UIControlState())
            }
            cell.btnAction.setTitle("Delete", for: UIControlState())
            
            cell.mySelectedTeamMember = mySelectedRoles[indexPath.row]
            cell.btnRole.isHidden = false
            cell.btnAction.isHidden = false
        }
        else
        {
            cell.btnTeamMember.setTitle("Select Person", for: UIControlState())
            cell.btnRole.setTitle("Select Role", for: UIControlState())
            cell.btnAction.setTitle("Add", for: UIControlState())
            cell.btnRole.isHidden = true
            cell.btnAction.isHidden = true
            cell.mySelectedTeamMember = nil
        }
        
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = myRowColour
        }
        else
        {
            cell.backgroundColor = UIColor.clear
        }
        
        cell.layoutSubviews()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath)
    {
        if indexPath.row < mySelectedRoles.count
        {
            mySelectedTeamMember = mySelectedRoles[indexPath.row]
        }
    }

    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:IndexPath) -> CGSize
    {
        return CGSize(width: colTeamMembers.bounds.size.width, height: 39)
    }

    func addTeamMember(_ notification: Notification)
    {
        workingCell = notification.userInfo!["WorkingCell"] as! Int

        myActionType = "Edit"

        let picker = CNContactPickerViewController()
        
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func changeRole(_ notification: Notification)
    {
        workingCell = notification.userInfo!["WorkingCell"] as! Int
        let workingObject = notification.userInfo!["Object"] as! projectTeamMember
        mySelectedTeamMember = workingObject
        
        myActionType = "Edit"
        myRoles = mySelectedTeam.roles
        pickerDisplayArray.removeAll()
        pickerDisplayArray.append("")
        for myItem in myRoles
        {
            pickerDisplayArray.append(myItem.roleDescription!)
        }
        
        btnSelectPicker.setTitle("Select Role", for: UIControlState())
        pickerTarget = "Role"
        statusPicker.reloadAllComponents()
        btnSelectPicker.isHidden = false
        statusPicker.isHidden = false
        mySelectedRow = -1
        hideFields()
    }
    
    func performDeleteTeamMember(_ notification: Notification)
    {
        let workingObject = notification.userInfo!["Object"] as! projectTeamMember
        
        mySelectedTeamMember = workingObject
        // We are now going to add in the team member and redisplay the team member grid
        
        NSLog("Deleting \(workingObject.teamMember)")
        mySelectedTeamMember.delete()
                
        projectObject.loadTeamMembers()
        mySelectedRoles = projectObject.teamMembers
        colTeamMembers.reloadData()
    }

    // Peoplepicker code
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact)
    {
        personSelected = contact
     
        let myFullName = CNContactFormatter.string(from: contact, style: CNContactFormatterStyle.fullName)
        
        _ = projectTeamMember(projectID: projectObject.projectID, teamMember: myFullName!, roleID: 0, teamID: mySelectedTeam.teamID)
        
        projectObject.loadTeamMembers()
        mySelectedRoles = projectObject.teamMembers
        colTeamMembers.reloadData()
    }
    
    @IBAction func txtTitle(_ sender: UITextField)
    {
        if txtTitle.text != ""
        {
            projectObject.projectName = txtTitle.text!
        }
    }
    
    
    @IBAction func txtProjectName(_ sender: UITextField)
    {
        if txtTitle.text == ""
        {
            let alert = UIAlertController(title: "Project Maintenance", message:
                "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                handler: nil))
            
            txtTitle.becomeFirstResponder()
        }
        else
        {
            projectObject.projectName = txtTitle.text!
            showFields()
        }
    }
    
    @IBAction func btnProjectStage(_ sender: UIButton)
    {
        var selectedRow: Int = 0
        var rowCount: Int = 0
        myActionType = "Edit"
        mySelectedTeam.loadStages()
        myStages = mySelectedTeam.stages
        pickerDisplayArray.removeAll()
        pickerDisplayArray.append("")
        
        for myItem in myStages
        {
            pickerDisplayArray.append(myItem.stageDescription!)
            if myItem.stageDescription == projectObject.projectStatus
            {
                selectedRow = rowCount
            }
            rowCount += 1
        }
        
        btnSelectPicker.setTitle("Select Stage", for: UIControlState())
        pickerTarget = "Stage"
        statusPicker.reloadAllComponents()
        btnSelectPicker.isHidden = false
        statusPicker.isHidden = false
        mySelectedRow = -1
        if selectedRow > 0
        {
            statusPicker.selectRow(selectedRow + 1, inComponent: 0, animated: true)
        }
        else
        {
            statusPicker.selectRow(0, inComponent: 0, animated: true)
        }
        hideFields()

    }
    
    @IBAction func btnStartDate(_ sender: UIButton)
    {
        if txtTitle.text == ""
        {
            let alert = UIAlertController(title: "Project Maintenance", message:
                "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                handler: nil))
            
            txtTitle.becomeFirstResponder()
        }
        else
        {
            pickerTarget = "StartDate"
            btnSelectPicker.setTitle("Set Start Date", for: UIControlState())
            startDatePicker.datePickerMode = UIDatePickerMode.date
            if projectObject.displayProjectStartDate != ""
            {
                startDatePicker.date = projectObject.projectStartDate as Date
            }
            else
            {
                startDatePicker.date = Date()
            }
            startDatePicker.isHidden = false
            btnSelectPicker.isHidden = false
            hideFields()
        }
    }
    
    @IBAction func btnEndDate(_ sender: UIButton)
    {
        if txtTitle.text == ""
        {
            let alert = UIAlertController(title: "Project Maintenance", message:
                "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                handler: nil))
            
            txtTitle.becomeFirstResponder()
        }
        else
        {
            pickerTarget = "EndDate"
            btnSelectPicker.setTitle("Set End Date", for: UIControlState())
            startDatePicker.datePickerMode = UIDatePickerMode.date
            if projectObject.displayProjectEndDate != ""
            {
                startDatePicker.date = projectObject.projectEndDate as Date
            }
            else
            {
                startDatePicker.date = Date()
            }
            startDatePicker.isHidden = false
            btnSelectPicker.isHidden = false
            hideFields()
        }
    }
    
    @IBAction func btnRepeatPeriod(_ sender: UIButton)
    {
        var selectedRow: Int = 0
        var rowCount: Int = 0
        myActionType = "Edit"
        pickerDisplayArray.removeAll()
        
        for myItem in myRepeatPeriods
        {
            pickerDisplayArray.append(myItem)
            if myItem == projectObject.repeatType
            {
                selectedRow = rowCount
            }
            rowCount += 1
        }
        btnSelectPicker.setTitle("Select Repeating type", for: UIControlState())
        pickerTarget = "RepeatPeriod"
        statusPicker.reloadAllComponents()
        btnSelectPicker.isHidden = false
        statusPicker.isHidden = false
        mySelectedRow = -1
        statusPicker.selectRow(selectedRow, inComponent: 0, animated: true)
        hideFields()
    }
    
    @IBAction func btnRepeatBase(_ sender: UIButton)
    {
        var selectedRow: Int = 0
        var rowCount: Int = 0
        myActionType = "Edit"
        pickerDisplayArray.removeAll()
        
        for myItem in myRepeatBases
        {
            pickerDisplayArray.append(myItem)
            if myItem == projectObject.repeatBase
            {
                selectedRow = rowCount
            }
            rowCount += 1
        }
        btnSelectPicker.setTitle("Select Repeating base", for: UIControlState())
        pickerTarget = "RepeatBase"
        statusPicker.reloadAllComponents()
        btnSelectPicker.isHidden = false
        statusPicker.isHidden = false
        mySelectedRow = -1
        statusPicker.selectRow(selectedRow, inComponent: 0, animated: true)
        hideFields()
    }
    
    @IBAction func btnReviewPeriod(_ sender: UIButton)
    {
        var selectedRow: Int = 0
        var rowCount: Int = 0
        myActionType = "Edit"
        pickerDisplayArray.removeAll()
        
        for myItem in myRepeatPeriods
        {
            pickerDisplayArray.append(myItem)
            if myItem == projectObject.reviewPeriod
            {
                selectedRow = rowCount
            }
            rowCount += 1
        }
        btnSelectPicker.setTitle("Select Review Period", for: UIControlState())
        pickerTarget = "ReviewPeriod"
        statusPicker.reloadAllComponents()
        btnSelectPicker.isHidden = false
        statusPicker.isHidden = false
        mySelectedRow = -1
        statusPicker.selectRow(selectedRow, inComponent: 0, animated: true)
        hideFields()
    }
    
    @IBAction func btnMarkReviewed(_ sender: UIButton)
    {
        projectObject.lastReviewDate = Date()
        lblLastReviewedDate.text = projectObject.displayLastReviewDate
    }
    
    @IBAction func txtRepeatInterval(_ sender: UITextField)
    {
        projectObject.repeatInterval = Int16(txtRepeatInterval.text!)!
    }
    
    @IBAction func txtReviewFrequency(_ sender: UITextField)
    {
        projectObject.reviewFrequency = Int16(txtReviewFrquency.text!)!
    }
    
    @IBAction func btnSelectPicker(_ sender: UIButton)
    {
        if mySelectedRow >= 0
        {
            if pickerTarget == "Role"
            {
                let newPersonRole = mySelectedRow - 1
                
                mySelectedTeamMember.roleID = myRoles[newPersonRole].roleID
                
                projectObject.loadTeamMembers()
                mySelectedRoles = projectObject.teamMembers
                colTeamMembers.reloadData()
            }
            
            if pickerTarget == "Stage"
            {
                projectObject.projectStatus = myStages[mySelectedRow - 1].stageDescription!
                btnProjectStage.setTitle(projectObject.projectStatus, for: UIControlState())
            }
            
            if pickerTarget == "RepeatPeriod"
            {
                projectObject.repeatType = myRepeatPeriods[mySelectedRow]
                btnRepeatPeriod.setTitle(projectObject.repeatType, for: UIControlState())
            }
            
            if pickerTarget == "RepeatBase"
            {
                projectObject.repeatBase = myRepeatBases[mySelectedRow]
                btnRepeastBase.setTitle(projectObject.repeatBase, for: UIControlState())
            }
            if pickerTarget == "ReviewPeriod"
            {
                projectObject.reviewPeriod = myRepeatPeriods[mySelectedRow]
                btnReviewPeriod.setTitle(projectObject.reviewPeriod, for: UIControlState())
            }
            
            statusPicker.selectRow(0, inComponent: 0, animated: true)
        }
        
        if pickerTarget == "StartDate"
        {
            projectObject.projectStartDate = startDatePicker.date
            btnStartDate.setTitle(projectObject.displayProjectStartDate, for: UIControlState())
        }
        
        if pickerTarget == "EndDate"
        {
            projectObject.projectEndDate = startDatePicker.date
            btnEndDate.setTitle(projectObject.displayProjectEndDate, for: UIControlState())
        }
        
        startDatePicker.isHidden = true
        statusPicker.isHidden = true
        btnSelectPicker.isHidden = true
        showFields()
    }
    
    func hideFields()
    {
        projectNameLabel.isHidden = true
        startDateLabel.isHidden = true
        endDateLabel.isHidden = true
        statusLabel.isHidden = true
        teamMembersLabel.isHidden = true
        btnStartDate.isHidden = true
        btnEndDate.isHidden = true
        btnProjectStage.isHidden = true
        colTeamMembers.isHidden = true
        lblNotes.isHidden = true
        txtNotes.isHidden = true
        txtTitle.isHidden = true
        lblRepeatEvery.isHidden = true
        lblReviewEvery.isHidden = true
        lblFromActivity.isHidden = true
        lblLastReviewed.isHidden = true
        lblLastReviewedDate.isHidden = true
        txtRepeatInterval.isHidden = true
        btnRepeatPeriod.isHidden = true
        btnRepeastBase.isHidden = true
        txtReviewFrquency.isHidden = true
        btnReviewPeriod.isHidden = true
        btnMarkReviewed.isHidden = true
    }
    
    func showFields()
    {
        projectNameLabel.isHidden = false
        startDateLabel.isHidden = false
        endDateLabel.isHidden = false
        statusLabel.isHidden = false
        teamMembersLabel.isHidden = false
        btnStartDate.isHidden = false
        btnEndDate.isHidden = false
        btnProjectStage.isHidden = false
        colTeamMembers.isHidden = false
        lblNotes.isHidden = false
        txtNotes.isHidden = false
        txtTitle.isHidden = false
        lblRepeatEvery.isHidden = false
        lblReviewEvery.isHidden = false
        lblFromActivity.isHidden = false
        lblLastReviewed.isHidden = false
        lblLastReviewedDate.isHidden = false
        txtRepeatInterval.isHidden = false
        btnRepeatPeriod.isHidden = false
        btnRepeastBase.isHidden = false
        txtReviewFrquency.isHidden = false
        btnReviewPeriod.isHidden = false
        btnMarkReviewed.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    { //Handle the text changes here
        if textView == txtNotes
        {
            projectObject.note = textView.text
        }
    }
    
    func myGTDPlanningDidFinish(_ controller:MaintainGTDPlanningViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func myMaintainProjectDidFinish(_ controller:MaintainProjectViewController, actionType: String)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
 //   func textFieldShouldReturn(textField: UITextField) -> Bool
 //   {
 //       textField.resignFirstResponder()
        
 //       return true
 //   }
    
    func keyboardWillShow(_ notification: Notification)
    {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        self.animateTextField(false)
    }
    
    func animateTextField(_ up: Bool)
    {
        var boolActionMove = false
        let movement = (up ? -kbHeight : kbHeight)
        
        if txtTitle.isFirstResponder
        {
            //  This is at the top, so we do not need to do anything
            boolActionMove = false
        }
        else if txtRepeatInterval.isFirstResponder
        {
            boolActionMove = true
        }
        else if txtReviewFrquency.isFirstResponder
        {
            boolActionMove = true
        }
        else if txtNotes.isFirstResponder
        {
            boolActionMove = true
        }
        
        if boolActionMove
        {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement!)

            })

            if up
            {
                for myItem in colTeamMembers.constraints
                {
                    if myItem.firstAttribute == NSLayoutAttribute.height && myItem.firstItem is UICollectionView
                    {
                        myItem.constant = 0
                        colTeamMembers.layoutIfNeeded()
                    }
                }
            }
            else
            {
                for myItem in colTeamMembers.constraints
                {
                    if myItem.firstAttribute == NSLayoutAttribute.height && myItem.firstItem is UICollectionView
                    {
                        myItem.constant = 250
                        colTeamMembers.layoutIfNeeded()
                    }
                }
            }
        

        }
    }
    
    //---------------------------------------------------------------
    // These three methods implement the SMTEFillDelegate protocol to support fill-ins
    
    /* When an abbreviation for a snippet that looks like a fill-in snippet has been
    * typed, SMTEDelegateController will call your fill delegate's implementation of
    * this method.
    * Provide some kind of identifier for the given UITextView/UITextField/UISearchBar/UIWebView
    * The ID doesn't have to be fancy, "maintext" or "searchbar" will do.
    * Return nil to avoid the fill-in app-switching process (the snippet will be expanded
    * with "(field name)" where the fill fields are).
    *
    * Note that in the case of a UIWebView, the uiTextObject passed will actually be
    * an NSDictionary with two of these keys:
    *     - SMTEkWebView          The UIWebView object (key always present)
    *     - SMTEkElementID        The HTML element's id attribute (if found, preferred over Name)
    *     - SMTEkElementName      The HTML element's name attribute (if id not found and name found)
    * (If no id or name attribute is found, fill-in's cannot be supported, as there is
    * no way for TE to insert the filled-in text.)
    * Unless there is only one editable area in your web view, this implies that the returned
    * identifier string needs to include element id/name information. Eg. "webview-field2".
    */
    
   // func identifierForTextArea(_ uiTextObject: AnyObject) -> String
    func identifier(forTextArea uiTextObject: Any) -> String
    {
        var result: String = ""
        
        if uiTextObject is UITextField
        {
            if (uiTextObject as AnyObject).tag == 1
            {
                result = "txtTitle"
            }
        }
        
        if uiTextObject is UITextView
        {
            if (uiTextObject as AnyObject).tag == 1
            {
                result = "txtNotes"
            }
        }
        
        if uiTextObject is UISearchBar
        {
            result =  "mySearchBar"
        }
        
        return result
    }
    
    /* Usually called milliseconds after identifierForTextArea:, SMTEDelegateController is
    * about to call [[UIApplication sharedApplication] openURL: "tetouch-xc: *x-callback-url/fillin?..."]
    * In other words, the TEtouch is about to be activated. Your app should save state
    * and make any other preparations.
    *
    * Return NO to cancel the process.
    */

    func prepare(forFillSwitch textIdentifier: String) -> Bool
    {
        // At this point the app should save state since TextExpander touch is about
        // to activate.
        // It especially needs to save the contents of the textview/textfield!
        
        return true
    }
    
    /* Restore active typing location and insertion cursor position to a text item
    * based on the identifier the fill delegate provided earlier.
    * (This call is made from handleFillCompletionURL: )
    *
    * In the case of a UIWebView, this method should build and return an NSDictionary
    * like the one sent to the fill delegate in identifierForTextArea: when the snippet
    * was triggered.
    * That is, you should make the UIWebView become first responder, then return an
    * NSDictionary with two of these keys:
    *     - SMTEkWebView          The UIWebView object (key must be present)
    *     - SMTEkElementID        The HTML element's id attribute (preferred over Name)
    *     - SMTEkElementName      The HTML element's name attribute (only if no id)
    * TE will use the same Javascripts that it uses to expand normal snippets to focus the appropriate
    * element and insert the filled text.
    *
    * Note 1: If your app is still loaded after returning from TEtouch's fill window,
    * probably no work needs to be done (the text item will still be the first
    * responder, and the insertion cursor position will still be the same).
    * Note 2: If the requested insertionPointLocation cannot be honored (ie. text has
    * been reset because of the app switching), then update it to whatever is reasonable.
    *
    * Return nil to cancel insertion of the fill-in text. Users will not expect a cancel
    * at this point unless userCanceledFill is set. Even in the cancel case, they will likely
    * expect the identified text object to become the first responder.
    */
    
    // func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
    public func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String!, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>!) -> Any!
    {
        snippetExpanded = true

        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.pointee
        
        if "txtTitle" == textIdentifier
        {
            txtTitle.becomeFirstResponder()
            let theLoc = txtTitle.position(from: txtTitle.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtTitle.selectedTextRange = txtTitle.textRange(from: theLoc!, to: theLoc!)
            }
            return txtTitle
        }
        else if "txtNotes" == textIdentifier
        {
            txtNotes.becomeFirstResponder()
            let theLoc = txtNotes.position(from: txtNotes.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtNotes.selectedTextRange = txtNotes.textRange(from: theLoc!, to: theLoc!)
            }
            return txtNotes
        }
            //        else if "mySearchBar" == textIdentifier
            //        {
            //            searchBar.becomeFirstResponder()
            // Note: UISearchBar does not support cursor positioning.
            // Since we don't save search bar text as part of our state, if our app was unloaded while TE was
            // presenting the fill-in window, the search bar might now be empty to we should return
            // insertionPointLocation of 0.
            //            let searchTextLen = searchBar.text.length
            //            if searchTextLen < ioInsertionPointLocation
            //            {
            //                ioInsertionPointLocation = searchTextLen
            //            }
            //            return searchBar
            //        }
        else
        {
            
            //return nil
            
            return "" as AnyObject
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if (textExpander.isAttemptingToExpandText)
        {
            snippetExpanded = true
        }
        return true
    }
    
    // Workaround for what appears to be an iOS 7 bug which affects expansion of snippets
    // whose content is greater than one line. The UITextView fails to update its display
    // to show the full content. Try commenting this out and expanding "sig1" to see the issue.
    //
    // Given other oddities of UITextView on iOS 7, we had assumed this would be fixed along the way.
    // Instead, we'll have to work up an isolated case and file a bug. We don't want to bake this kind
    // of workaround into the SDK, so instead we provide an example here.
    // If you have a better workaround suggestion, we'd love to hear it.
    
    func twiddleText(_ textView: UITextView)
    {
        let SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO = UIDevice.current.systemVersion
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO >= "7.0"
        {
            textView.textStorage.edited(NSTextStorageEditActions.editedCharacters,range:NSMakeRange(0, textView.textStorage.length),changeInLength:0)
        }
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        if snippetExpanded
        {
            usleep(10000)
            twiddleText(textView)
            
            // performSelector(twiddleText:, withObject: textView, afterDelay:0.01)
            snippetExpanded = false
        }
    }
    
    /*
    // The following are the UITextViewDelegate methods; they simply write to the console log for demonstration purposes
    
    func textViewDidBeginEditing(textView: UITextView)
    {
    println("nextDelegate textViewDidBeginEditing")
    }
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
    println("nextDelegate textViewShouldBeginEditing")
    return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool
    {
    println("nextDelegate textViewShouldEndEditing")
    return true
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
    println("nextDelegate textViewDidEndEditing")
    }
    
    func textViewDidChangeSelection(textView: UITextView)
    {
    println("nextDelegate textViewDidChangeSelection")
    }
    
    // The following are the UITextFieldDelegate methods; they simply write to the console log for demonstration purposes
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldBeginEditing")
    return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
    println("nextDelegate textFieldDidBeginEditing")
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldEndEditing")
    return true
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
    println("nextDelegate textFieldDidEndEditing")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
    println("nextDelegate textField:shouldChangeCharactersInRange: \(NSStringFromRange(range)) Original=\(textField.text), replacement = \(string)")
    return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldClear")
    return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldReturn")
    return true
    }
    */
}

class myProjectItem: UICollectionViewCell
{
    @IBOutlet weak var btnTeamMember: UIButton!
    @IBOutlet weak var btnRole: UIButton!
    @IBOutlet weak var btnAction: UIButton!
    var mySelectedTeamMember: projectTeamMember!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnAction(_ sender: UIButton)
    {
        let selectedDictionary = ["Action" : btnAction.currentTitle!, "Object": mySelectedTeamMember] as [String : Any]
        notificationCenter.post(name: NotificationPerformDelete, object: nil, userInfo:selectedDictionary)
    }
    
    @IBAction func btnTeamMember(_ sender: UIButton)
    {
        if btnAction.currentTitle == "Add"
        {
            let selectedDictionary = ["WorkingCell" : btnAction.tag]
            notificationCenter.post(name: NotificationAddTeamMember, object: nil, userInfo:selectedDictionary)
        }
    }
    
    @IBAction func btnRole(_ sender: UIButton)
    {
        let selectedDictionary = ["WorkingCell" : btnAction.tag, "Object": mySelectedTeamMember] as [String : Any]
        notificationCenter.post(name: NotificationChangeRole, object: nil, userInfo:selectedDictionary)
    }
    
}
