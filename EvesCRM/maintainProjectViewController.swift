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
}

class MaintainProjectViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate
{
   
    @IBOutlet weak var projectList: UITableView!
    @IBOutlet weak var teamMembersTable: UITableView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var teamMembersLabel: UILabel!
    @IBOutlet weak var projectNameText: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var statusPicker: UIPickerView!
    @IBOutlet weak var buttonAddTeamMember: UIButton!
    @IBOutlet weak var labelTeamMemberName: UILabel!
    @IBOutlet weak var pickerPersonRole: UIPickerView!
    @IBOutlet weak var buttonConfirmTeamMember: UIButton!
    @IBOutlet weak var buttonDeleteTeamMember: UIButton!
    
    @IBOutlet weak var switchArchive: UISwitch!
    @IBOutlet weak var labelSwitchArchive: UILabel!
    @IBOutlet weak var lableNoProjects: UILabel!
    var delegate: MyMaintainProjectDelegate?
    
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    private var statusOptions: [Stages]!
    
    var myActionType: String = "Add"
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        self.projectList.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifierProject)
        self.teamMembersTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifierTeam)

        getProjects()
        
        myRoles = myDatabaseConnection.getRoles()
        
        statusOptions = myDatabaseConnection.getStages()
        
        if myProjects.count > 0
        {
            // Populate the collection view
            projectList.hidden = false
            lableNoProjects.hidden = true
            switchArchive.hidden = false
            labelSwitchArchive.hidden = false
            switchArchive.setOn(false, animated: true)
        }
        else
        {
            // Hide the collection view as there is nothing to display
            projectList.hidden = true
            lableNoProjects.hidden = false
            switchArchive.hidden = true
            labelSwitchArchive.hidden = true
        }
        
        buttonAddTeamMember.hidden = false
        
        statusSelected = statusOptions[0].stageDescription
        teamMembersTable.hidden = false
        teamMembersLabel.hidden = false
        labelTeamMemberName.hidden = true
        pickerPersonRole.hidden = true
        buttonConfirmTeamMember.hidden = true
        buttonDeleteTeamMember.hidden = true
        
        teamMembersTable.tableFooterView = UIView(frame:CGRectZero)
        projectList.tableFooterView = UIView(frame:CGRectZero)
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        hideFields()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        projectNameText.endEditing(true)
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            delegate?.myMaintainProjectDidFinish(self, actionType: "Cancel")        }
    }

    func numberOfComponentsInPickerView(inPicker: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(inPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if inPicker == statusPicker
        {
            return statusOptions.count
        }
        else if inPicker == pickerPersonRole
        {
            return myRoles.count
        }
        else
        {
            return 0
        }
    }
    
    func pickerView(inPicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        if inPicker == statusPicker
        {
            return statusOptions[row].stageDescription
        }
        else if inPicker == pickerPersonRole
        {
            return myRoles[row].roleDescription
        }
        else
        {
            return "Empty"
        }
    }
    
    func pickerView(inPicker: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // actionSelection()
        if projectNameText.text == ""
        {
            var alert = UIAlertController(title: "Project Maintenance", message:
                "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
            
            projectNameText.becomeFirstResponder()
        }
        else
        {
            if inPicker == statusPicker
            {
                statusSelected = statusOptions[row].stageDescription
                mySelectedProject.projectStatus = statusSelected
            }
            else if inPicker == pickerPersonRole
            {
                roleSelected = myRoles[row].roleID as Int
            }
        }
    }
    
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
            titleText += myDatabaseConnection.getRoleDescription(mySelectedRoles[indexPath.row].roleID)
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
                titleText += myDatabaseConnection.getRoleDescription(mySelectedRoles[indexPath.row].roleID)
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
            
            if myProjects[indexPath.row].projectStartDate.compare(myProjects[indexPath.row].getDefaultDate()) != NSComparisonResult.OrderedSame
            {
                startDatePicker.date = myProjects[indexPath.row].projectStartDate
            }
            
            if myProjects[indexPath.row].projectEndDate.compare(myProjects[indexPath.row].getDefaultDate()) != NSComparisonResult.OrderedSame
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
    
    @IBAction func buttonAddTeamMember(sender: UIButton)
    {
        buttonAddTeamMember.hidden = true
        // Save current changes
        myActionType = "Edit"
        if switchArchive.on
        {
            getProjects(inArchiveFlag: true)
        }
        else
        {
            getProjects()
        }
        projectList.reloadData()
        teamMemberAction = "Add"
        buttonConfirmTeamMember.setTitle("Add to Project Team Members", forState: UIControlState.Normal)
        
        pickerPersonRole.selectRow(0, inComponent: 0, animated: true)
        roleSelected = 1
        
        let picker = ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func buttonConfirmTeamMember(sender: UIButton)
    {
        // We are now going to add in the team member and redisplay the team member grid

        var myProjectTeam: projectTeamMember
        
        if teamMemberAction == "Add"
        {
            myProjectTeam = projectTeamMember(inProjectID: mySelectedProject.projectID, inTeamMember: labelTeamMemberName.text!, inRoleID: roleSelected)
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
        teamMembersTable.reloadData()

        labelTeamMemberName.hidden = true
        pickerPersonRole.hidden = true
        buttonConfirmTeamMember.hidden = true
        buttonDeleteTeamMember.hidden = true
        buttonAddTeamMember.hidden = false
        teamMembersTable.hidden = false
    }
    
    // Peoplepicker code
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!)
    {
        personSelected = person as ABRecord
     
        let myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
        
        labelTeamMemberName.text = myFullName
        
        labelTeamMemberName.hidden = false
        pickerPersonRole.hidden = false
        buttonConfirmTeamMember.hidden = false
        buttonAddTeamMember.hidden = true
        teamMembersTable.hidden = true
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!)
    {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func buttonDeleteTeamMember(sender: UIButton)
    {
        mySelectedTeamMember.delete()
        
        mySelectedProject.loadTeamMembers()
        mySelectedRoles = mySelectedProject.teamMembers
        teamMembersTable.reloadData()
        
        labelTeamMemberName.hidden = true
        pickerPersonRole.hidden = true
        buttonConfirmTeamMember.hidden = true
        buttonDeleteTeamMember.hidden = true
        buttonAddTeamMember.hidden = false
        teamMembersTable.hidden = false
    }
    
    @IBAction func txtProjectName(sender: UITextField)
    {
        if projectNameText.text == ""
        {
            var alert = UIAlertController(title: "Project Maintenance", message:
                "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
            
            projectNameText.becomeFirstResponder()
        }
        else
        {
            if myActionType == "Add"
            {
                mySelectedProject = project()
                mySelectedProject.projectName = projectNameText.text
            }
            else
            {
                mySelectedProject.projectName = projectNameText.text
            }
            showFields()
        }
    }
    
    @IBAction func dteStart(sender: UIDatePicker)
    {
        if projectNameText.text == ""
        {
            var alert = UIAlertController(title: "Project Maintenance", message:
                "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
            
            projectNameText.becomeFirstResponder()
        }
        else
        {
            mySelectedProject.projectStartDate = startDatePicker.date
        }
    }
    
    @IBAction func dteEnd(sender: UIDatePicker)
    {
        if projectNameText.text == ""
        {
            var alert = UIAlertController(title: "Project Maintenance", message:
                "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
            
            projectNameText.becomeFirstResponder()
        }
        else
        {
            mySelectedProject.projectEndDate = endDatePicker.date
        }
    }
    
    @IBAction func switchArchive(sender: UISwitch)
    {
        if switchArchive.on
        {
            getProjects(inArchiveFlag: true)
        }
        else
        {
            getProjects()
        }

        projectList.reloadData()
    }
    
    func getProjects(inArchiveFlag: Bool = false)
    {
        var myProjectList: [Projects]
        if inArchiveFlag
        {
            myProjectList = myDatabaseConnection.getProjects(inArchiveFlag: true)
        }
        else
        {
            myProjectList = myDatabaseConnection.getProjects()
        }
        
        myProjects.removeAll()
        
        for myProjectRecord in myProjectList
        {
            let myNewProject = project()
            myNewProject.load(myProjectRecord.projectID as Int)
            myProjects.append(myNewProject)
        }
    }
    
    func hideFields()
    {
        teamMembersTable.hidden = true
        startDateLabel.hidden = true
        endDateLabel.hidden = true
        statusLabel.hidden = true
        teamMembersLabel.hidden = true
        startDatePicker.hidden = true
        endDatePicker.hidden = true
        statusPicker.hidden = true
        buttonAddTeamMember.hidden = true
    }
    
    func showFields()
    {
        teamMembersTable.hidden = false
        startDateLabel.hidden = false
        endDateLabel.hidden = false
        statusLabel.hidden = false
        teamMembersLabel.hidden = false
        startDatePicker.hidden = false
        endDatePicker.hidden = false
        statusPicker.hidden = false
        buttonAddTeamMember.hidden = false
    }

}
