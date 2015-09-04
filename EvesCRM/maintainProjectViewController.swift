//
//  maintainProjectViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 4/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import AddressBook
import AddressBookUI

protocol MyMaintainProjectDelegate{
    func myMaintainProjectDidFinish(controller:MaintainProjectViewController, actionType: String)
    func myGTDPlanningDidFinish(controller:MaintainGTDPlanningViewController)
}

class MaintainProjectViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate, MyMaintainProjectDelegate, SMTEFillDelegate
{
   private var passedGTD: GTDModel!
    
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var teamMembersLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var statusPicker: UIPickerView!
    @IBOutlet weak var buttonAddTeamMember: UIButton!
    @IBOutlet weak var labelTeamMemberName: UILabel!
    @IBOutlet weak var buttonConfirmTeamMember: UIButton!
    @IBOutlet weak var buttonDeleteTeamMember: UIButton!
    @IBOutlet weak var btnStartDate: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var btnProjectStage: UIButton!
    @IBOutlet weak var btnPersonRole: UIButton!
    @IBOutlet weak var btnSelectPicker: UIButton!
    @IBOutlet weak var colTeamMembers: UICollectionView!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var txtTitle: UITextField!

 //   var delegate: MyMaintainProjectDelegate?
    
    private var statusOptions: [Stages]!
    
    var myActionType: String = "Add"
    var inProjectObject: project!
    private var statusSelected: String = ""
    private var roleSelected: Int = 0
    private var myProjects: [project] = Array()
    private let reuseIdentifierProject = "ProjectCell"
    private let reuseIdentifierTeam = "TeamMemberCell"
    private var mySelectedProject: project!
    private var myRoles: [Roles]!
    private var mySelectedRoles: [projectTeamMember]!
    private var mySelectedTeamMember: projectTeamMember!
    private var personSelected: ABRecord!
    private var teamMemberAction: String = ""
    
    // Textexpander
    
    private var snippetExpanded: Bool = false
    
    var textExpander: SMTEDelegateController!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        myRoles = myDatabaseConnection.getRoles(myTeamID)
        
        statusOptions = myDatabaseConnection.getStages(myTeamID)
        
        buttonAddTeamMember.hidden = false
        
        statusSelected = statusOptions[0].stageDescription
        teamMembersLabel.hidden = false
        labelTeamMemberName.hidden = true
        buttonConfirmTeamMember.hidden = true
        buttonDeleteTeamMember.hidden = true
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        hideFields()
        
        // Set the initial values
        

        startDatePicker.hidden = true
        btnSelectPicker.hidden = true
        statusPicker.hidden = true
        
        btnPersonRole.hidden = true
        
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
            btnEndDate.setTitle("Set Start Date", forState: UIControlState.Normal)
        }
        else
        {
            btnEndDate.setTitle(inProjectObject.displayProjectEndDate, forState: UIControlState.Normal)
        }
        
        if inProjectObject.projectStatus == ""
        {
            btnProjectStage.setTitle("Set Start Date", forState: UIControlState.Normal)
        }
        else
        {
            btnProjectStage.setTitle(inProjectObject.projectStatus, forState: UIControlState.Normal)
        }
        
        txtNotes.text = inProjectObject.note
        txtTitle.text = inProjectObject.projectName
        
        colTeamMembers.hidden = false

        
        
        
        
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
 //       if inPicker == statusPicker
 //       {
 //           return statusOptions.count
 //       }
 //       else if inPicker == pickerPersonRole
 //       {
  //          return myRoles.count
  //      }
  //      else
  //      {
  //          return 0
  //      }
        
        return 0
    }
    
    func pickerView(inPicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
   //     if inPicker == statusPicker
   //     {
   //         return statusOptions[row].stageDescription
   //     }
   //     else if inPicker == pickerPersonRole
   //     {
   //         return myRoles[row].roleDescription
   //     }
   //     else
   //     {
            return "Empty"
    //    }
    }
    
    func pickerView(inPicker: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // actionSelection()
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
            if inPicker == statusPicker
            {
                statusSelected = statusOptions[row].stageDescription
                mySelectedProject.projectStatus = statusSelected
            }
 //           else if inPicker == pickerPersonRole
 //           {
 //               roleSelected = myRoles[row].roleID as Int
 //           }
        }
    }
 /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        var retVal: CGFloat = 0.0
        
        if (tableView == projectList)
        {
            let cell = projectList.dequeueReusableCellWithIdentifier(reuseIdentifierProject) as! UITableViewCell
            var titleText: String = ""
            if myProjects.count != 0
            {
                titleText = myProjects[indexPath.row].projectName
                titleText += " : "
                titleText += myProjects[indexPath.row].projectStatus
            }
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        if (tableView == teamMembersTable)
        {
            let cell = teamMembersTable.dequeueReusableCellWithIdentifier(reuseIdentifierTeam) as! UITableViewCell
            var titleText: String = ""
            titleText = mySelectedRoles[indexPath.row].teamMember
            titleText += " : "
            titleText += myDatabaseConnection.getRoleDescription(mySelectedRoles[indexPath.row].roleID, inTeamID: myTeamID)
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        return retVal + 24.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        var retVal: Int = 0
        
        if (tableView == projectList)
        {
            if myProjects.count != 0
            {
                retVal = self.myProjects.count ?? 0
            }
        }
        else if (tableView == teamMembersTable)
        {
            if mySelectedRoles != nil
            {
                retVal = self.mySelectedRoles.count ?? 0
            }
        }
        return retVal
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (tableView == projectList)
        {
            let cell = projectList.dequeueReusableCellWithIdentifier(reuseIdentifierProject) as! UITableViewCell
            var titleText: String = ""
            if myProjects.count != 0
            {
                titleText = myProjects[indexPath.row].projectName
                titleText += " : "
                titleText += myProjects[indexPath.row].projectStatus
                cell.textLabel!.text = titleText
            }
            return cell
            
        }
        else if (tableView == teamMembersTable)
        {
            let cell = teamMembersTable.dequeueReusableCellWithIdentifier(reuseIdentifierTeam) as! UITableViewCell
            var titleText: String = ""
            if mySelectedRoles != nil
            {
                titleText = mySelectedRoles[indexPath.row].teamMember
                titleText += " : "
                titleText += myDatabaseConnection.getRoleDescription(mySelectedRoles[indexPath.row].roleID, inTeamID: myTeamID)
            }
           
            cell.textLabel!.text = titleText
            return cell
        }
        else
        {
            // Dummy statements to allow use of else
            let cell = projectList.dequeueReusableCellWithIdentifier(reuseIdentifierProject) as! UITableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == projectList
        {
            
            mySelectedProject = myProjects[indexPath.row]
            
            projectNameText.text = myProjects[indexPath.row].projectName
           // statusPicker.currentText = myProjects[indexPath.row].projectStatus
            
            if myProjects[indexPath.row].projectStartDate.compare(getDefaultDate()) != NSComparisonResult.OrderedSame
            {
                startDatePicker.date = myProjects[indexPath.row].projectStartDate
            }
            
            if myProjects[indexPath.row].projectEndDate.compare(getDefaultDate()) != NSComparisonResult.OrderedSame
            {
                endDatePicker.date = myProjects[indexPath.row].projectEndDate
            }
            
            myActionType = "Edit"
            buttonAddTeamMember.hidden = false
            
            teamMembersTable.hidden = false
            teamMembersLabel.hidden = false
            
            mySelectedProject.loadTeamMembers()
            mySelectedRoles = mySelectedProject.teamMembers
            teamMembersTable.reloadData()
            labelTeamMemberName.hidden = true
            pickerPersonRole.hidden = true
            buttonConfirmTeamMember.hidden = true
            buttonDeleteTeamMember.hidden = true
            
            // Due to the way the Picker works, I need to know the Index of the entry to display.
            // So parse through the array to find the entry that matches the saved text and then display that one
            
            var textItemIndex: Int = 0
            statusPicker.selectRow(textItemIndex, inComponent: 0, animated: true)
            for textItem in statusOptions
            {
                if textItem.stageDescription == myProjects[indexPath.row].projectStatus
                {
                    statusPicker.selectRow(textItemIndex, inComponent: 0, animated: true)
                    break
                }
                else
                {
                    textItemIndex = textItemIndex + 1
                }
            }
            showFields()
        }
        else if tableView == teamMembersTable
        {
            buttonDeleteTeamMember.hidden = false
            buttonConfirmTeamMember.hidden = false
            labelTeamMemberName.hidden = false
            teamMembersTable.hidden = true
            pickerPersonRole.hidden = false
            mySelectedTeamMember = mySelectedRoles[indexPath.row]
            labelTeamMemberName.text = mySelectedRoles[indexPath.row].teamMember
            let myRoleRow = mySelectedRoles[indexPath.row].roleID - 1
            pickerPersonRole.selectRow(myRoleRow, inComponent: 0, animated: true)
            teamMemberAction = "Edit"
            buttonAddTeamMember.hidden = true
            buttonConfirmTeamMember.setTitle("Update Project Team Member", forState: UIControlState.Normal)
        }
    }
    

*/
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
       // return 1
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
     //   return agendaItem.tasks.count
        return 0
    }
  
    
    
    
    
    @IBAction func buttonAddTeamMember(sender: UIButton)
    {
        buttonAddTeamMember.hidden = true
        // Save current changes
        myActionType = "Edit"
        
        teamMemberAction = "Add"
        buttonConfirmTeamMember.setTitle("Add to Project Team Members", forState: UIControlState.Normal)
        
  //      pickerPersonRole.selectRow(0, inComponent: 0, animated: true)
        roleSelected = 1
        
        let picker = ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func buttonConfirmTeamMember(sender: UIButton)
    {
        // We are now going to add in the team member and redisplay the team member grid

        if teamMemberAction == "Add"
        {
            _ = projectTeamMember(inProjectID: mySelectedProject.projectID, inTeamMember: labelTeamMemberName.text!, inRoleID: roleSelected)
        }
        else
        {
            for myTeamMember in mySelectedProject.teamMembers
            {
                if myTeamMember.teamMember == labelTeamMemberName.text! && myTeamMember.roleID == roleSelected
                {
                    myTeamMember.projectMemberNotes = ""
                }
            }
        }
        
        mySelectedProject.loadTeamMembers()
        mySelectedRoles = mySelectedProject.teamMembers
        colTeamMembers.reloadData()

        labelTeamMemberName.hidden = true
        buttonConfirmTeamMember.hidden = true
        buttonDeleteTeamMember.hidden = true
        buttonAddTeamMember.hidden = false
    }
    
    // Peoplepicker code
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecordRef)
    {
        personSelected = person as ABRecord
     
        let myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as String) ?? ""
        
        labelTeamMemberName.text = myFullName
        
        labelTeamMemberName.hidden = false
        buttonConfirmTeamMember.hidden = false
        buttonAddTeamMember.hidden = true
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController)
    {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func buttonDeleteTeamMember(sender: UIButton)
    {
        mySelectedTeamMember.delete()
        
        mySelectedProject.loadTeamMembers()
        mySelectedRoles = mySelectedProject.teamMembers
        colTeamMembers.reloadData()
        
        labelTeamMemberName.hidden = true

        buttonConfirmTeamMember.hidden = true
        buttonDeleteTeamMember.hidden = true
        buttonAddTeamMember.hidden = false
        colTeamMembers.hidden = false
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
            if myActionType == "Add"
            {
                mySelectedProject = project(inTeamID: myTeamID)
                mySelectedProject.projectName = txtTitle.text!
            }
            else
            {
                mySelectedProject.projectName = txtTitle.text!
            }
            showFields()
        }
    }
    
    @IBAction func dteStart(sender: UIDatePicker)
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
            mySelectedProject.projectStartDate = startDatePicker.date
        }
    }
    
    @IBAction func dteEnd(sender: UIDatePicker)
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
      //      mySelectedProject.projectEndDate = endDatePicker.date
        }
    }
    
    func getProjects(inArchiveFlag: Bool = false)
    {
        var myProjectList: [Projects]
        if inArchiveFlag
        {
            myProjectList = myDatabaseConnection.getProjects(myTeamID, inArchiveFlag: true)
        }
        else
        {
            myProjectList = myDatabaseConnection.getProjects(myTeamID)
        }
        
        myProjects.removeAll()
        
        for myProjectRecord in myProjectList
        {
            let myNewProject = project(inProjectID: myProjectRecord.projectID as Int, inTeamID: myTeamID)
            myProjects.append(myNewProject)
        }
    }
    
    func hideFields()
    {
        startDateLabel.hidden = true
        endDateLabel.hidden = true
        statusLabel.hidden = true
        teamMembersLabel.hidden = true
        startDatePicker.hidden = true
        statusPicker.hidden = true
        buttonAddTeamMember.hidden = true
        btnStartDate.hidden = true
        btnEndDate.hidden = true
        btnProjectStage.hidden = true
        btnPersonRole.hidden = true
        colTeamMembers.hidden = true
        lblNotes.hidden = true
        txtNotes.hidden = true
        txtTitle.hidden = true
    }
    
    func showFields()
    {
        startDateLabel.hidden = false
        endDateLabel.hidden = false
        statusLabel.hidden = false
        teamMembersLabel.hidden = false
        startDatePicker.hidden = false
        statusPicker.hidden = false
        buttonAddTeamMember.hidden = false
        btnStartDate.hidden = false
        btnEndDate.hidden = false
        btnProjectStage.hidden = false
        btnPersonRole.hidden = false
        colTeamMembers.hidden = false
        lblNotes.hidden = false
        txtNotes.hidden = false
        txtTitle.hidden = false
    }
    
    func myGTDPlanningDidFinish(controller:MaintainGTDPlanningViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func myMaintainProjectDidFinish(controller:MaintainProjectViewController, actionType: String)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
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
