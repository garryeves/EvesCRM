//
//  maintainProjectViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 4/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import Contacts
import ContactsUI

protocol MyMaintainProjectDelegate{
    func myMaintainProjectDidFinish(controller:MaintainProjectViewController, actionType: String)
    func myGTDPlanningDidFinish(controller:MaintainGTDPlanningViewController)
}

class MaintainProjectViewController: UIViewController, CNContactPickerDelegate, MyMaintainProjectDelegate, SMTEFillDelegate, UITextViewDelegate, UITextFieldDelegate
{
   private var passedGTD: GTDModel!
    
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
    var inProjectObject: project!
    var mySelectedTeam: team!
    
    private var statusSelected: String = ""
    private var roleSelected: Int = 0
    private var myProjects: [project] = Array()
    private let reuseIdentifierProject = "ProjectCell"
    private let reuseIdentifierTeam = "TeamMemberCell"
    private var myRoles: [Roles]!
    private var myStages: [Stages]!
    private var mySelectedRoles: [projectTeamMember] = Array()
    private var mySelectedTeamMember: projectTeamMember!
    private var personSelected: CNContact!
    private var teamMemberAction: String = ""
    private var workingCell: Int = -1
    private var pickerTarget: String = ""
    private var pickerDisplayArray: [String] = Array()
    private var mySelectedRow: Int = -1
    private var kbHeight: CGFloat!
    
    // Textexpander
    
    private var snippetExpanded: Bool = false
    
    var textExpander: SMTEDelegateController!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let statusOptions = mySelectedTeam.stages
        
        statusSelected = statusOptions[0].stageDescription
        teamMembersLabel.hidden = false

        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        txtNotes.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        
        showFields()
        
        // Set the initial values

        startDatePicker.hidden = true
        btnSelectPicker.hidden = true
        statusPicker.hidden = true
        
        if inProjectObject.displayProjectStartDate == ""
        {
            btnStartDate.setTitle("Set Start Date", forState: UIControlState.Normal)
        }
        else
        {
            btnStartDate.setTitle(inProjectObject.displayProjectStartDate, forState: UIControlState.Normal)
        }
        
        if inProjectObject.displayProjectEndDate == ""
        {
            btnEndDate.setTitle("Set End Date", forState: UIControlState.Normal)
        }
        else
        {
            btnEndDate.setTitle(inProjectObject.displayProjectEndDate, forState: UIControlState.Normal)
        }
        
        if inProjectObject.projectStatus == ""
        {
            btnProjectStage.setTitle("Set Project Stage", forState: UIControlState.Normal)
        }
        else
        {
            btnProjectStage.setTitle(inProjectObject.projectStatus, forState: UIControlState.Normal)
        }
        
        txtNotes.text = inProjectObject.note
        txtTitle.text = inProjectObject.projectName
        
        if inProjectObject.displayLastReviewDate == ""
        {
            lblLastReviewedDate.text = "Never reviewed"
        }
        else
        {
            lblLastReviewedDate.text = inProjectObject.displayLastReviewDate
        }
        txtRepeatInterval.text = "\(inProjectObject.repeatInterval)"
        txtReviewFrquency.text = "\(inProjectObject.reviewFrequency)"
        
        if inProjectObject.repeatType == ""
        {
            btnRepeatPeriod.setTitle("Set Period", forState: UIControlState.Normal)
        }
        else
        {
            btnRepeatPeriod.setTitle(inProjectObject.repeatType, forState: UIControlState.Normal)
        }
        
        if inProjectObject.repeatBase == ""
        {
            btnRepeastBase.setTitle("Set Base", forState: UIControlState.Normal)
        }
        else
        {
            btnRepeastBase.setTitle(inProjectObject.repeatBase, forState: UIControlState.Normal)
        }
 
        if inProjectObject.reviewPeriod == ""
        {
            btnReviewPeriod.setTitle("Set Period", forState: UIControlState.Normal)
        }
        else
        {
            btnReviewPeriod.setTitle(inProjectObject.reviewPeriod, forState: UIControlState.Normal)
        }

        mySelectedRoles = inProjectObject.teamMembers
        
        colTeamMembers.hidden = false
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addTeamMember:", name:"NotificationAddTeamMember", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeRole:", name:"NotificationChangeRole", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "performDeleteTeamMember:", name:"NotificationPerformDelete", object: nil)

    }
    
    override func viewWillAppear(animated:Bool)
    {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        txtTitle.endEditing(true)
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            passedGTD.delegate.myMaintainProjectDidFinish(self, actionType: "Cancel")
        }
    }

    func numberOfComponentsInPickerView(inPicker: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(inPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerDisplayArray.count
    }
    
    func pickerView(inPicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return pickerDisplayArray[row]
    }

    func pickerView(inPicker: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        mySelectedRow = row
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return mySelectedRoles.count + 1
    }
 
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellTeamMembers", forIndexPath: indexPath) as! myProjectItem
        cell.btnAction.tag = indexPath.row
        
        if indexPath.row < mySelectedRoles.count
        {
            cell.btnTeamMember.setTitle(mySelectedRoles[indexPath.row].teamMember, forState: UIControlState.Normal)
            if mySelectedRoles[indexPath.row].roleName == ""
            {
                cell.btnRole.setTitle("Select Role", forState: UIControlState.Normal)
            }
            else
            {
                cell.btnRole.setTitle(mySelectedRoles[indexPath.row].roleName, forState: UIControlState.Normal)
            }
            cell.btnAction.setTitle("Delete", forState: UIControlState.Normal)
            
            cell.mySelectedTeamMember = mySelectedRoles[indexPath.row]
            cell.btnRole.hidden = false
            cell.btnAction.hidden = false
        }
        else
        {
            cell.btnTeamMember.setTitle("Select Person", forState: UIControlState.Normal)
            cell.btnRole.setTitle("Select Role", forState: UIControlState.Normal)
            cell.btnAction.setTitle("Add", forState: UIControlState.Normal)
            cell.btnRole.hidden = true
            cell.btnAction.hidden = true
            cell.mySelectedTeamMember = nil
        }
        
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = myRowColour
        }
        else
        {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        cell.layoutSubviews()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row < mySelectedRoles.count
        {
            mySelectedTeamMember = mySelectedRoles[indexPath.row]
        }
    }

    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSize(width: colTeamMembers.bounds.size.width, height: 39)
    }

    func addTeamMember(notification: NSNotification)
    {
        workingCell = notification.userInfo!["WorkingCell"] as! Int

        myActionType = "Edit"

        let picker = CNContactPickerViewController()
        
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }

    func changeRole(notification: NSNotification)
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
            pickerDisplayArray.append(myItem.roleDescription)
        }
        
        btnSelectPicker.setTitle("Select Role", forState: .Normal)
        pickerTarget = "Role"
        statusPicker.reloadAllComponents()
        btnSelectPicker.hidden = false
        statusPicker.hidden = false
        mySelectedRow = -1
        hideFields()
    }
    
    func performDeleteTeamMember(notification: NSNotification)
    {
        let workingObject = notification.userInfo!["Object"] as! projectTeamMember
        
        mySelectedTeamMember = workingObject
        // We are now going to add in the team member and redisplay the team member grid
        
        NSLog("Deleting \(workingObject.teamMember)")
        mySelectedTeamMember.delete()
                
        inProjectObject.loadTeamMembers()
        mySelectedRoles = inProjectObject.teamMembers
        colTeamMembers.reloadData()
    }

    // Peoplepicker code
    
    func contactPickerDidCancel(picker: CNContactPickerViewController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact)
    {
        personSelected = contact
     
        let myFullName = CNContactFormatter.stringFromContact(contact, style: CNContactFormatterStyle.FullName)
        
        _ = projectTeamMember(inProjectID: inProjectObject.projectID, inTeamMember: myFullName!, inRoleID: 0, inTeamID: mySelectedTeam.teamID)
        
        inProjectObject.loadTeamMembers()
        mySelectedRoles = inProjectObject.teamMembers
        colTeamMembers.reloadData()
    }
    
    @IBAction func txtTitle(sender: UITextField)
    {
        if txtTitle.text != ""
        {
            inProjectObject.projectName = txtTitle.text!
        }
    }
    
    
    @IBAction func txtProjectName(sender: UITextField)
    {
        if txtTitle.text == ""
        {
            let alert = UIAlertController(title: "Project Maintenance", message:
                "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
            
            txtTitle.becomeFirstResponder()
        }
        else
        {
            inProjectObject.projectName = txtTitle.text!
            showFields()
        }
    }
    
    @IBAction func btnProjectStage(sender: UIButton)
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
            pickerDisplayArray.append(myItem.stageDescription)
            if myItem.stageDescription == inProjectObject.projectStatus
            {
                selectedRow = rowCount
            }
            rowCount++
        }
        
        btnSelectPicker.setTitle("Select Stage", forState: .Normal)
        pickerTarget = "Stage"
        statusPicker.reloadAllComponents()
        btnSelectPicker.hidden = false
        statusPicker.hidden = false
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
    
    @IBAction func btnStartDate(sender: UIButton)
    {
        if txtTitle.text == ""
        {
            let alert = UIAlertController(title: "Project Maintenance", message:
                "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
            
            txtTitle.becomeFirstResponder()
        }
        else
        {
            pickerTarget = "StartDate"
            btnSelectPicker.setTitle("Set Start Date", forState: .Normal)
            startDatePicker.datePickerMode = UIDatePickerMode.Date
            if inProjectObject.displayProjectStartDate != ""
            {
                startDatePicker.date = inProjectObject.projectStartDate
            }
            else
            {
                startDatePicker.date = NSDate()
            }
            startDatePicker.hidden = false
            btnSelectPicker.hidden = false
            hideFields()
        }
    }
    
    @IBAction func btnEndDate(sender: UIButton)
    {
        if txtTitle.text == ""
        {
            let alert = UIAlertController(title: "Project Maintenance", message:
                "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
            
            txtTitle.becomeFirstResponder()
        }
        else
        {
            pickerTarget = "EndDate"
            btnSelectPicker.setTitle("Set End Date", forState: .Normal)
            startDatePicker.datePickerMode = UIDatePickerMode.Date
            if inProjectObject.displayProjectEndDate != ""
            {
                startDatePicker.date = inProjectObject.projectEndDate
            }
            else
            {
                startDatePicker.date = NSDate()
            }
            startDatePicker.hidden = false
            btnSelectPicker.hidden = false
            hideFields()
        }
    }
    
    @IBAction func btnRepeatPeriod(sender: UIButton)
    {
        var selectedRow: Int = 0
        var rowCount: Int = 0
        myActionType = "Edit"
        pickerDisplayArray.removeAll()
        
        for myItem in myRepeatPeriods
        {
            pickerDisplayArray.append(myItem)
            if myItem == inProjectObject.repeatType
            {
                selectedRow = rowCount
            }
            rowCount++
        }
        btnSelectPicker.setTitle("Select Repeating type", forState: .Normal)
        pickerTarget = "RepeatPeriod"
        statusPicker.reloadAllComponents()
        btnSelectPicker.hidden = false
        statusPicker.hidden = false
        mySelectedRow = -1
        statusPicker.selectRow(selectedRow, inComponent: 0, animated: true)
        hideFields()
    }
    
    @IBAction func btnRepeatBase(sender: UIButton)
    {
        var selectedRow: Int = 0
        var rowCount: Int = 0
        myActionType = "Edit"
        pickerDisplayArray.removeAll()
        
        for myItem in myRepeatBases
        {
            pickerDisplayArray.append(myItem)
            if myItem == inProjectObject.repeatBase
            {
                selectedRow = rowCount
            }
            rowCount++
        }
        btnSelectPicker.setTitle("Select Repeating base", forState: .Normal)
        pickerTarget = "RepeatBase"
        statusPicker.reloadAllComponents()
        btnSelectPicker.hidden = false
        statusPicker.hidden = false
        mySelectedRow = -1
        statusPicker.selectRow(selectedRow, inComponent: 0, animated: true)
        hideFields()
    }
    
    @IBAction func btnReviewPeriod(sender: UIButton)
    {
        var selectedRow: Int = 0
        var rowCount: Int = 0
        myActionType = "Edit"
        pickerDisplayArray.removeAll()
        
        for myItem in myRepeatPeriods
        {
            pickerDisplayArray.append(myItem)
            if myItem == inProjectObject.reviewPeriod
            {
                selectedRow = rowCount
            }
            rowCount++
        }
        btnSelectPicker.setTitle("Select Review Period", forState: .Normal)
        pickerTarget = "ReviewPeriod"
        statusPicker.reloadAllComponents()
        btnSelectPicker.hidden = false
        statusPicker.hidden = false
        mySelectedRow = -1
        statusPicker.selectRow(selectedRow, inComponent: 0, animated: true)
        hideFields()
    }
    
    @IBAction func btnMarkReviewed(sender: UIButton)
    {
        inProjectObject.lastReviewDate = NSDate()
        lblLastReviewedDate.text = inProjectObject.displayLastReviewDate
    }
    
    @IBAction func txtRepeatInterval(sender: UITextField)
    {
        inProjectObject.repeatInterval = Int(txtRepeatInterval.text!)!
    }
    
    @IBAction func txtReviewFrequency(sender: UITextField)
    {
        inProjectObject.reviewFrequency = Int(txtReviewFrquency.text!)!
    }
    
    @IBAction func btnSelectPicker(sender: UIButton)
    {
        if mySelectedRow >= 0
        {
            if pickerTarget == "Role"
            {
                let newPersonRole = mySelectedRow - 1
                
                mySelectedTeamMember.roleID = myRoles[newPersonRole].roleID as Int
                
                inProjectObject.loadTeamMembers()
                mySelectedRoles = inProjectObject.teamMembers
                colTeamMembers.reloadData()
            }
            
            if pickerTarget == "Stage"
            {
                inProjectObject.projectStatus = myStages[mySelectedRow - 1].stageDescription
                btnProjectStage.setTitle(inProjectObject.projectStatus, forState: UIControlState.Normal)
            }
            
            if pickerTarget == "RepeatPeriod"
            {
                inProjectObject.repeatType = myRepeatPeriods[mySelectedRow]
                btnRepeatPeriod.setTitle(inProjectObject.repeatType, forState: UIControlState.Normal)
            }
            
            if pickerTarget == "RepeatBase"
            {
                inProjectObject.repeatBase = myRepeatBases[mySelectedRow]
                btnRepeastBase.setTitle(inProjectObject.repeatBase, forState: UIControlState.Normal)
            }
            if pickerTarget == "ReviewPeriod"
            {
                inProjectObject.reviewPeriod = myRepeatPeriods[mySelectedRow]
                btnReviewPeriod.setTitle(inProjectObject.reviewPeriod, forState: UIControlState.Normal)
            }
            
            statusPicker.selectRow(0, inComponent: 0, animated: true)
        }
        
        if pickerTarget == "StartDate"
        {
            inProjectObject.projectStartDate = startDatePicker.date
            btnStartDate.setTitle(inProjectObject.displayProjectStartDate, forState: UIControlState.Normal)
        }
        
        if pickerTarget == "EndDate"
        {
            inProjectObject.projectEndDate = startDatePicker.date
            btnEndDate.setTitle(inProjectObject.displayProjectEndDate, forState: UIControlState.Normal)
        }
        
        startDatePicker.hidden = true
        statusPicker.hidden = true
        btnSelectPicker.hidden = true
        showFields()
    }
    
    func hideFields()
    {
        projectNameLabel.hidden = true
        startDateLabel.hidden = true
        endDateLabel.hidden = true
        statusLabel.hidden = true
        teamMembersLabel.hidden = true
        btnStartDate.hidden = true
        btnEndDate.hidden = true
        btnProjectStage.hidden = true
        colTeamMembers.hidden = true
        lblNotes.hidden = true
        txtNotes.hidden = true
        txtTitle.hidden = true
        lblRepeatEvery.hidden = true
        lblReviewEvery.hidden = true
        lblFromActivity.hidden = true
        lblLastReviewed.hidden = true
        lblLastReviewedDate.hidden = true
        txtRepeatInterval.hidden = true
        btnRepeatPeriod.hidden = true
        btnRepeastBase.hidden = true
        txtReviewFrquency.hidden = true
        btnReviewPeriod.hidden = true
        btnMarkReviewed.hidden = true
    }
    
    func showFields()
    {
        projectNameLabel.hidden = false
        startDateLabel.hidden = false
        endDateLabel.hidden = false
        statusLabel.hidden = false
        teamMembersLabel.hidden = false
        btnStartDate.hidden = false
        btnEndDate.hidden = false
        btnProjectStage.hidden = false
        colTeamMembers.hidden = false
        lblNotes.hidden = false
        txtNotes.hidden = false
        txtTitle.hidden = false
        lblRepeatEvery.hidden = false
        lblReviewEvery.hidden = false
        lblFromActivity.hidden = false
        lblLastReviewed.hidden = false
        lblLastReviewedDate.hidden = false
        txtRepeatInterval.hidden = false
        btnRepeatPeriod.hidden = false
        btnRepeastBase.hidden = false
        txtReviewFrquency.hidden = false
        btnReviewPeriod.hidden = false
        btnMarkReviewed.hidden = false
    }
    
    func textViewDidEndEditing(textView: UITextView)
    { //Handle the text changes here
        if textView == txtNotes
        {
            inProjectObject.note = textView.text
        }
    }
    
    func myGTDPlanningDidFinish(controller:MaintainGTDPlanningViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func myMaintainProjectDidFinish(controller:MaintainProjectViewController, actionType: String)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
 //   func textFieldShouldReturn(textField: UITextField) -> Bool
 //   {
 //       textField.resignFirstResponder()
        
 //       return true
 //   }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.animateTextField(false)
    }
    
    func animateTextField(up: Bool)
    {
        var boolActionMove = false
        let movement = (up ? -kbHeight : kbHeight)
        
        if txtTitle.isFirstResponder()
        {
            //  This is at the top, so we do not need to do anything
            boolActionMove = false
        }
        else if txtRepeatInterval.isFirstResponder()
        {
            boolActionMove = true
        }
        else if txtReviewFrquency.isFirstResponder()
        {
            boolActionMove = true
        }
        else if txtNotes.isFirstResponder()
        {
            boolActionMove = true
        }
        
        if boolActionMove
        {
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, movement)

            })

            if up
            {
                for myItem in colTeamMembers.constraints
                {
                    if myItem.firstAttribute == NSLayoutAttribute.Height && myItem.firstItem.isKindOfClass(UICollectionView)
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
                    if myItem.firstAttribute == NSLayoutAttribute.Height && myItem.firstItem.isKindOfClass(UICollectionView)
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
    
    func identifierForTextArea(uiTextObject: AnyObject) -> String
    {
        var result: String = ""
        
        if uiTextObject.isKindOfClass(UITextField)
        {
            if uiTextObject.tag == 1
            {
                result = "txtTitle"
            }
        }
        
        if uiTextObject.isKindOfClass(UITextView)
        {
            if uiTextObject.tag == 1
            {
                result = "txtNotes"
            }
        }
        
        if uiTextObject.isKindOfClass(UISearchBar)
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

    func prepareForFillSwitch(textIdentifier: String) -> Bool
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
    
    func makeIdentifiedTextObjectFirstResponder(textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
    {
        snippetExpanded = true

        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.memory
        
        if "txtTitle" == textIdentifier
        {
            txtTitle.becomeFirstResponder()
            let theLoc = txtTitle.positionFromPosition(txtTitle.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtTitle.selectedTextRange = txtTitle.textRangeFromPosition(theLoc!, toPosition: theLoc!)
            }
            return txtTitle
        }
        else if "txtNotes" == textIdentifier
        {
            txtNotes.becomeFirstResponder()
            let theLoc = txtNotes.positionFromPosition(txtNotes.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtNotes.selectedTextRange = txtNotes.textRangeFromPosition(theLoc!, toPosition: theLoc!)
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
            
            return ""
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
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
    
    func twiddleText(textView: UITextView)
    {
        let SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO = UIDevice.currentDevice().systemVersion
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO >= "7.0"
        {
            textView.textStorage.edited(NSTextStorageEditActions.EditedCharacters,range:NSMakeRange(0, textView.textStorage.length),changeInLength:0)
        }
    }
    
    func textViewDidChange(textView: UITextView)
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
    
    @IBAction func btnAction(sender: UIButton)
    {
        let selectedDictionary = ["Action" : btnAction.currentTitle!, "Object": mySelectedTeamMember]
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationPerformDelete", object: nil, userInfo:selectedDictionary)
    }
    
    @IBAction func btnTeamMember(sender: UIButton)
    {
        if btnAction.currentTitle == "Add"
        {
            let selectedDictionary = ["WorkingCell" : btnAction.tag]
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationAddTeamMember", object: nil, userInfo:selectedDictionary)
        }
    }
    
    @IBAction func btnRole(sender: UIButton)
    {
        let selectedDictionary = ["WorkingCell" : btnAction.tag, "Object": mySelectedTeamMember]
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationChangeRole", object: nil, userInfo:selectedDictionary)
    }
    
}
