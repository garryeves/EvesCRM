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
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var projectNameText: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var statusPicker: UIPickerView!
    @IBOutlet weak var buttonAddTeamMember: UIButton!
    @IBOutlet weak var labelTeamMemberName: UILabel!
    @IBOutlet weak var pickerPersonRole: UIPickerView!
    @IBOutlet weak var buttonConfirmTeamMember: UIButton!
    
    @IBOutlet weak var lableNoProjects: UILabel!
    var delegate: MyMaintainProjectDelegate?
    
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    private var statusOptions = ["Pre-Planning", "Planning", "Planned", "Scheduled", "In-progress", "Delayed", "Completed", "Archived"]
    
    var myActionType: String = "Add"
    private var statusSelected: String = ""
    private var roleSelected: Int = 0
    private var myProjects: [Projects]!
    private let reuseIdentifierProject = "ProjectCell"
    private let reuseIdentifierTeam = "TeamMemberCell"
    private var mySelectedProject: Projects!
    private var myRoles: [Roles]!
    private var mySelectedRoles: [ProjectTeamMembers]!
    private var personSelected: ABRecord!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        self.projectList.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifierProject)
        self.teamMembersTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifierTeam)
        
        myProjects = getProjects()
        
        myRoles = getRoles()
        
        if myRoles.count == 0
        {
            // There are no roles defined so we need to go in and create them
            
            populateRoles()
            
            myRoles = getRoles()
        }
        
        for disrole in myRoles
        {
            println("ID = \(disrole.roleID) name = \(disrole.roleDescription)")
        }
        
        
        if myProjects.count > 0
        {
            // Populate the collection view
            projectList.hidden = false
            lableNoProjects.hidden = true
        }
        else
        {
            // Hide the collection view as there is nothing to display
            projectList.hidden = true
            lableNoProjects.hidden = false
        }
        
        
        if myActionType == "Select"
        {
            projectNameText.enabled = false
            startDatePicker.enabled = false
            endDatePicker.enabled = false
        //    statusPicker.setUserInteractionEnabled = false
            
            buttonAddTeamMember.hidden = true
        }
        
        teamMembersTable.hidden = true
        buttonAddTeamMember.hidden = true
        teamMembersLabel.hidden = true
        labelTeamMemberName.hidden = true
        pickerPersonRole.hidden = true
        buttonConfirmTeamMember.hidden = true
        
        teamMembersTable.tableFooterView = UIView(frame:CGRectZero)
        projectList.tableFooterView = UIView(frame:CGRectZero)

        
        buttonSave.setTitle(myActionType, forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return statusOptions[row]
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
        if inPicker == statusPicker
        {
            statusSelected = statusOptions[row]
        }
        else if inPicker == pickerPersonRole
        {
            roleSelected = myRoles[row].roleID as Int
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        
        var retVal: CGFloat = 0.0
        
        if (tableView == projectList)
        {
            let cell = projectList.dequeueReusableCellWithIdentifier(reuseIdentifierProject) as! UITableViewCell
            var titleText: String = ""
            if myProjects != nil
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
            if mySelectedRoles != nil
            {
                titleText = mySelectedRoles[indexPath.row].teamMember
                titleText += " : "
                titleText += getRoleDescription(mySelectedRoles[indexPath.row].roleID)
            }
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
            if myProjects != nil
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
            if myProjects != nil
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
                
  println(mySelectedRoles[indexPath.row].teamMember)
  println(mySelectedRoles[indexPath.row].roleID)
                
                titleText = mySelectedRoles[indexPath.row].teamMember
                titleText += " : "
                titleText += getRoleDescription(mySelectedRoles[indexPath.row].roleID)
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
            startDatePicker.date = myProjects[indexPath.row].projectStartDate
            endDatePicker.date = myProjects[indexPath.row].projectEndDate
            
            myActionType = "Edit"
            
            buttonSave.setTitle("Save", forState: UIControlState.Normal)
            teamMembersTable.hidden = false
            buttonAddTeamMember.hidden = false
            teamMembersLabel.hidden = false
            
            mySelectedRoles = getTeamMembers(mySelectedProject.projectID)
            teamMembersTable.reloadData()
            
            // Due to the way the Picker works, I need to know the Index of the entry to display.
            // So parse through the array to find the entry that matches the saved text and then display that one
            
            var textItemIndex: Int = 0
            statusPicker.selectRow(textItemIndex, inComponent: 0, animated: true)
            for textItem in statusOptions
            {
                if textItem == myProjects[indexPath.row].projectStatus
                {
                    statusPicker.selectRow(textItemIndex, inComponent: 0, animated: true)
                    break
                }
                else
                {
                    textItemIndex = textItemIndex + 1
                }
            }
            
         }
 
        else if tableView == teamMembersTable
        {
          //  dataCellClicked(indexPath.row, inTable: "Table2", inRecord: table2Contents[indexPath.row])
        }
    }
    
 // when selecting an exisiting project set myActionType = Edit
    
    @IBAction func buttonCancel(sender: UIButton)
    {
        delegate?.myMaintainProjectDidFinish(self, actionType: "Cancel")
    }
    @IBAction func buttonSave(sender: UIButton)
    {
        
        if myActionType == "Select"
        {
        
    println("Hit the Select piece.  Still need to do the coding")
            delegate?.myMaintainProjectDidFinish(self, actionType: "Selected")
        }
        else
        {
            if projectNameText.text == ""
            {
                var alert = UIAlertController(title: "Project Maintenance", message:
                    "You need to provide a Project Name", preferredStyle: UIAlertControllerStyle.Alert)
                
                self.presentViewController(alert, animated: false, completion: nil)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                    handler: nil))
            }
            else
            {
                if myActionType == "Add"
                {
                    mySelectedProject = NSEntityDescription.insertNewObjectForEntityForName("Projects", inManagedObjectContext: self.managedObjectContext!) as! Projects
                    mySelectedProject.projectID = getProjects().count + 1
                }
            
                mySelectedProject.projectName = projectNameText.text
                mySelectedProject.projectStartDate = startDatePicker.date
                mySelectedProject.projectEndDate = endDatePicker.date
                mySelectedProject.projectStatus = statusSelected
            
                var error : NSError?
                if(managedObjectContext!.save(&error) )
                {
                    println(error?.localizedDescription)
                }
                delegate?.myMaintainProjectDidFinish(self, actionType: "Changed")
            }
        }
        
    }
        
    @IBAction func buttonAddTeamMember(sender: UIButton)
    {
        let picker = ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        presentViewController(picker, animated: true, completion: nil)

    }
    
    @IBAction func buttonConfirmTeamMember(sender: UIButton)
    {
        // We are now going to add in the team member and redisplay the team member grid

        
        let myProjectTeam = NSEntityDescription.insertNewObjectForEntityForName("ProjectTeamMembers", inManagedObjectContext: self.managedObjectContext!) as! ProjectTeamMembers
        
        myProjectTeam.projectID = mySelectedProject.projectID
        myProjectTeam.roleID = roleSelected
        myProjectTeam.teamMember = labelTeamMemberName.text!
        
        var error : NSError?
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
        
        mySelectedRoles = getTeamMembers(mySelectedProject.projectID)
        teamMembersTable.reloadData()

        labelTeamMemberName.hidden = true
        pickerPersonRole.hidden = true
        buttonConfirmTeamMember.hidden = true
        buttonAddTeamMember.hidden = false
        teamMembersTable.hidden = false
        buttonSave.hidden = false
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
        buttonSave.hidden = true
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!)
    {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    }
}
