//
//  meetingTaskViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 22/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import AddressBook

protocol MyTaskDelegate
{
    func myTaskDidFinish(controller:taskViewController, actionType: String, currentTask: task)
    func myTaskUpdateDidFinish(controller:taskUpdatesViewController, actionType: String, currentTask: task)
}

class taskViewController: UIViewController,  UITextViewDelegate
{
    private var passedTask: TaskModel!
    
    @IBOutlet weak var lblTaskTitle: UILabel!
    @IBOutlet weak var lblTaskDescription: UILabel!
    @IBOutlet weak var lblTargetDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var txtTaskTitle: UITextField!
    @IBOutlet weak var txtTaskDescription: UITextView!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var btnTargetDate: UIButton!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var btnSetTargetDate: UIButton!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblContexts: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var colContexts: UICollectionView!
    @IBOutlet weak var lblPriority: UILabel!
    @IBOutlet weak var txtEstTime: UITextField!
    @IBOutlet weak var btnEstTimeInterval: UIButton!
    @IBOutlet weak var lblEstTime: UILabel!
    @IBOutlet weak var btnPriority: UIButton!
    @IBOutlet weak var lblEnergy: UILabel!
    @IBOutlet weak var btnEnergy: UIButton!
    @IBOutlet weak var lblNewContext: UILabel!
    @IBOutlet weak var txtNewContext: UITextField!
    @IBOutlet weak var btnNewContext: UIButton!
    @IBOutlet weak var lblProject: UILabel!
    @IBOutlet weak var btnProject: UIButton!
    @IBOutlet weak var lblUrgency: UILabel!
    @IBOutlet weak var btnUrgency: UIButton!
    @IBOutlet weak var btnSelect: UIButton!
    
    private var pickerOptions: [String] = Array()
    private var pickerTarget: String = ""
    private var myStartDate: NSDate!
    private var myDueDate: NSDate!
    private var myProjectID: Int = 0
    private var myProjectDetails: [Projects] = Array()
    private var mySelectedRow: Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        myDatePicker.hidden = true
        myPicker.hidden = true
        btnSelect.hidden = true
        btnSetTargetDate.hidden = true
        
        txtTaskDescription.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtTaskDescription.layer.borderWidth = 0.5
        txtTaskDescription.layer.cornerRadius = 5.0
        txtTaskDescription.layer.masksToBounds = true
        
        passedTask = (tabBarController as! tasksTabViewController).myPassedTask
        
        if passedTask.currentTask.taskID != 0
        {
            // Lets load up the fields
            txtTaskTitle.text = passedTask.currentTask.title
            txtTaskDescription.text = passedTask.currentTask.details
            if passedTask.currentTask.displayDueDate == ""
            {
                btnTargetDate.setTitle("None", forState: .Normal)
            }
            else
            {
                btnTargetDate.setTitle(passedTask.currentTask.displayDueDate, forState: .Normal)
            }

            if passedTask.currentTask.displayStartDate == ""
            {
                btnStart.setTitle("None", forState: .Normal)
            }
            else
            {
                btnStart.setTitle(passedTask.currentTask.displayStartDate, forState: .Normal)
            }

            if passedTask.currentTask.status == ""
            {
                btnStatus.setTitle("Open", forState: .Normal)
            }
            else
            {
                btnStatus.setTitle(passedTask.currentTask.status, forState: .Normal)
            }
            
            myStartDate = passedTask.currentTask.startDate
            myDueDate = passedTask.currentTask.dueDate
            
            if passedTask.currentTask.priority == ""
            {
                btnPriority.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnPriority.setTitle(passedTask.currentTask.priority, forState: .Normal)
            }
            
            if passedTask.currentTask.energyLevel == ""
            {
                btnEnergy.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnEnergy.setTitle(passedTask.currentTask.energyLevel, forState: .Normal)
            }
            
            if passedTask.currentTask.urgency == ""
            {
                btnUrgency.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnUrgency.setTitle(passedTask.currentTask.urgency, forState: .Normal)
            }

            
            if passedTask.currentTask.estimatedTimeType == ""
            {
                btnEstTimeInterval.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnEstTimeInterval.setTitle(passedTask.currentTask.estimatedTimeType, forState: .Normal)
            }
            
            if passedTask.currentTask.projectID == 0
            {
                btnProject.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                // Go an get the project name
                setProjectName(passedTask.currentTask.projectID)
            }

            txtEstTime.text = "\(passedTask.currentTask.estimatedTime)"
            
            lblNewContext.hidden = true
            txtNewContext.hidden = true
            btnNewContext.hidden = true
            
            let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
            showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
            self.view.addGestureRecognizer(showGestureRecognizer)
            
            let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
            hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
            self.view.addGestureRecognizer(hideGestureRecognizer)

            NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeTaskContext:", name:"NotificationRemoveTaskContext", object: nil)
            
            txtTaskDescription.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        colContexts.collectionViewLayout.invalidateLayout()
        
        colContexts.reloadData()
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Move to next item in tab hierarchy
            
            let myCurrentTab = self.tabBarController
            
            myCurrentTab!.selectedIndex = myCurrentTab!.selectedIndex + 1
        }
        else
        {
            passedTask.delegate.myTaskDidFinish(self, actionType: "Cancel", currentTask: passedTask.currentTask)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return passedTask.currentTask.contexts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell: myContextItem!

        cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseContext", forIndexPath: indexPath) as! myContextItem
        
        cell.lblContext.text = passedTask.currentTask.contexts[indexPath.row].name
        cell.btnRemove.setTitle("Remove", forState: .Normal)
        cell.btnRemove.tag = passedTask.currentTask.contexts[indexPath.row].contextID
         
        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = swiftColor
        }
        else
        {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        cell.layoutSubviews()
        
        return cell
    }
/*
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {  // Leaving stub in here for use in other collections
        
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var headerView:UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader
        {
            headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "agendaItemHeader", forIndexPath: indexPath) as! UICollectionReusableView
        }
        return headerView
    }
*/
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSize(width: colContexts.bounds.size.width, height: 39)
    }

    func numberOfComponentsInPickerView(TableTypeSelection1: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerOptions.count
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return pickerOptions[row]
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        mySelectedRow = row
    }
    
    @IBAction func btnTargetDate(sender: UIButton)
    {
        btnSetTargetDate.setTitle("Set Target Date", forState: .Normal)
        pickerTarget = "TargetDate"
        myDatePicker.datePickerMode = UIDatePickerMode.Date
        hideFields()
        myDatePicker.hidden = false
        btnSetTargetDate.hidden = false
    }
    
    @IBAction func btnOwner(sender: UIButton)
    {
        if txtTaskTitle.text == ""
        {
            var alert = UIAlertController(title: "Add Task", message:
                "You must provide a description for the Task before you can add a Context to it", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alert, animated: false, completion: nil)
        }
        else
        {
            lblNewContext.hidden = false
            txtNewContext.hidden = false
            btnNewContext.hidden = false
            txtNewContext.text = ""
        
            let myContextList = contexts()
            
            pickerOptions.removeAll(keepCapacity: false)
            
            pickerOptions.append("")
            
            if passedTask.taskType == "minutes"
            { // a meeting task
                // First need to loop through the meetings attendees
                
                for myAttendee in passedTask.event.attendees
                {
                    // check in the address book to see if we have a person for this email address, this is so we make sure we try and use consistent Context names
                    let person:ABRecord! = findPersonbyEmail(myAttendee.emailAddress)
                    
                    if person != nil
                    {
                        let personName = ABRecordCopyCompositeName(person).takeRetainedValue() as String
                        pickerOptions.append(personName)
                    }
                    else
                    {
                        pickerOptions.append(myAttendee.name)
                    }
                }
            }
            else
            { // Not a meeting task
                for myContext in myContextList.contextsByHierarchy
                {
                    pickerOptions.append(myContext.contextHierarchy)
                }
            }

            hideFields()
            
            if pickerOptions.count > 0
            {
                myPicker.hidden = false
                btnSelect.hidden = false
                myPicker.reloadAllComponents()
                btnSelect.setTitle("Set Context", forState: .Normal)
                myPicker.selectRow(0,inComponent: 0, animated: true)
                mySelectedRow = 0
            }
            
            pickerTarget = "Context"
        }
    }
    
    @IBAction func btnStatus(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("")
        pickerOptions.append("Open")
        pickerOptions.append("Closed")
        hideFields()
        myPicker.hidden = false
        btnSelect.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Status"
        btnSelect.setTitle("Set Status", forState: .Normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func btnSetTargetDate(sender: UIButton)
    {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        if pickerTarget == "TargetDate"
        {
            btnTargetDate.setTitle(dateFormatter.stringFromDate(myDatePicker.date), forState: .Normal)
            myDueDate = myDatePicker.date
            passedTask.currentTask.dueDate = myDueDate
            btnSetTargetDate.hidden = true
        }
        else
        {
            btnStart.setTitle(dateFormatter.stringFromDate(myDatePicker.date), forState: .Normal)
            myStartDate = myDatePicker.date
            passedTask.currentTask.startDate = myStartDate
            btnSetTargetDate.hidden = true
        }
        
        myDatePicker.hidden = true
        
        showFields()
    }
    
    @IBAction func btnStart(sender: UIButton)
    {
        btnSetTargetDate.setTitle("Set Start Date", forState: .Normal)
        pickerTarget = "StartDate"
        myDatePicker.datePickerMode = UIDatePickerMode.Date
        hideFields()
        myDatePicker.hidden = false
        btnSetTargetDate.hidden = false
    }
    
    @IBAction func btnEstTimeInterval(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("")
        pickerOptions.append("Minutes")
        pickerOptions.append("Hours")
        pickerOptions.append("Days")
        pickerOptions.append("Weeks")
        pickerOptions.append("Months")
        pickerOptions.append("Years")
        hideFields()
        myPicker.hidden = false
        btnSelect.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "TimeInterval"
        btnSelect.setTitle("Set Time Interval", forState: .Normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func btnPriority(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("")
        pickerOptions.append("High")
        pickerOptions.append("Medium")
        pickerOptions.append("Low")
        hideFields()
        myPicker.hidden = false
        btnSelect.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Priority"
        btnSelect.setTitle("Set Priority", forState: .Normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func btnEnergy(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("")
        pickerOptions.append("High")
        pickerOptions.append("Medium")
        pickerOptions.append("Low")
        hideFields()
        myPicker.hidden = false
        btnSelect.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Energy"
        btnSelect.setTitle("Set Energy", forState: .Normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func btnNewContext(sender: UIButton)
    {
        var matchFound: Bool = false
        
        if txtNewContext.text == ""
        {
            var alert = UIAlertController(title: "Add Context", message:
                "You must provide a description for the Context before you can Add it", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alert, animated: false, completion: nil)
        }
        else
        {
            // first lets see if there is already a context with this name
            let myContextList = contexts()
        
            for myContext in myContextList.contexts
            {
                if myContext.name.lowercaseString == txtNewContext.text.lowercaseString
                {
                    // Exisiting context found, so use this record
              
                    setContext(myContext.contextID)
                    matchFound = true
                    break
                }
            }
        
            // if no match then create context

            if !matchFound
            {
                let myNewContext = context(inContextName: txtNewContext.text)
            
                setContext(myNewContext.contextID)
            }
        }
        lblNewContext.hidden = true
        txtNewContext.hidden = true
        btnNewContext.hidden = true
        myPicker.hidden = true
        btnSelect.hidden = true
        showFields()
    }
    
    @IBAction func btnProject(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        myProjectDetails.removeAll(keepCapacity: false)
        
        pickerOptions.append("")
        
        let myProjects = myDatabaseConnection.getAllOpenProjects()
        
        for myProject in myProjects
        {
            pickerOptions.append(myProject.projectName)
            myProjectDetails.append(myProject)
        }
        hideFields()
        myPicker.hidden = false
        btnSelect.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Project"
        btnSelect.setTitle("Set Project", forState: .Normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func btnUrgency(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("")
        pickerOptions.append("High")
        pickerOptions.append("Medium")
        pickerOptions.append("Low")
        hideFields()
        myPicker.hidden = false
        btnSelect.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Urgency"
        btnSelect.setTitle("Set Urgency", forState: .Normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func txtTaskDetail(sender: UITextField)
    {
        if txtTaskTitle.text != ""
        {
            passedTask.currentTask.title = txtTaskTitle.text
        }
    }
    
    @IBAction func txtEstTime(sender: UITextField)
    {
        passedTask.currentTask.estimatedTime = txtEstTime.text.toInt()!
    }
    
    @IBAction func btnSelect(sender: UIButton)
    {
        // Write code for select

        if mySelectedRow != 0
        {
            if pickerTarget == "Context"
            {
                btnOwner.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                lblNewContext.hidden = true
                txtNewContext.hidden = true
                btnNewContext.hidden = true
            }
        
            if pickerTarget == "Status"
            {
                btnStatus.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedTask.currentTask.status = btnStatus.currentTitle!
            }
        
            if pickerTarget == "TimeInterval"
            {
                btnEstTimeInterval.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedTask.currentTask.estimatedTimeType = btnEstTimeInterval.currentTitle!
            }
        
            if pickerTarget == "Priority"
            {
                btnPriority.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedTask.currentTask.priority = btnPriority.currentTitle!
            }
        
            if pickerTarget == "Energy"
            {
                btnEnergy.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedTask.currentTask.energyLevel = btnEnergy.currentTitle!
            }
        
            if pickerTarget == "Urgency"
            {
                btnUrgency.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedTask.currentTask.urgency = btnUrgency.currentTitle!
            }
        
            if pickerTarget == "Project"
            {
                setProjectName(myProjectDetails[mySelectedRow - 1].projectID as Int)
            }
        
            if pickerTarget == "Context"
            {
                var matchFound: Bool = false
                // if we have just selected an "unknown" context then we need ot create it
            
                // first lets see if there is already a context with this name
                let myContextList = contexts()
            
                for myContext in myContextList.contexts
                {
                    if myContext.name.lowercaseString == pickerOptions[mySelectedRow].lowercaseString
                    {
                        // Existing context found, so use this record
                    
                        setContext(myContext.contextID)
                        matchFound = true
                        break
                    }
                }
            
                // if no match then create context
            
                if !matchFound
                {
                    let myNewContext = context(inContextName: pickerOptions[mySelectedRow])
                
                    setContext(myNewContext.contextID)
                }
            }
        }
        myPicker.hidden = true
        btnSelect.hidden = true
        lblNewContext.hidden = true
        txtNewContext.hidden = true
        btnNewContext.hidden = true
        showFields()
    }
    
    func textViewDidEndEditing(textView: UITextView)
    { //Handle the text changes here
        
        if textView == txtTaskDescription
        {
            passedTask.currentTask.details = textView.text
        }
    }
    
    func showFields()
    {
        lblTaskTitle.hidden = false
        lblTaskDescription.hidden = false
        lblTargetDate.hidden = false
        lblStatus.hidden = false
        txtTaskTitle.hidden = false
        txtTaskDescription.hidden = false
        btnTargetDate.hidden = false
        btnOwner.hidden = false
        btnStatus.hidden = false
        lblStart.hidden = false
        lblContexts.hidden = false
        btnStart.hidden = false
        colContexts.hidden = false
        lblPriority.hidden = false
        txtEstTime.hidden = false
        btnEstTimeInterval.hidden = false
        lblEstTime.hidden = false
        btnPriority.hidden = false
        lblEnergy.hidden = false
        btnEnergy.hidden = false
        lblProject.hidden = false
        btnProject.hidden = false
        lblUrgency.hidden = false
        btnUrgency.hidden = false
    }
    
    func hideFields()
    {
        lblTaskTitle.hidden = true
        lblTaskDescription.hidden = true
        lblTargetDate.hidden = true
        lblStatus.hidden = true
        txtTaskTitle.hidden = true
        txtTaskDescription.hidden = true
        btnTargetDate.hidden = true
        btnOwner.hidden = true
        btnStatus.hidden = true
        lblStart.hidden = true
        lblContexts.hidden = true
        btnStart.hidden = true
        colContexts.hidden = true
        lblPriority.hidden = true
        txtEstTime.hidden = true
        btnEstTimeInterval.hidden = true
        lblEstTime.hidden = true
        btnPriority.hidden = true
        lblEnergy.hidden = true
        btnEnergy.hidden = true
        lblProject.hidden = true
        btnProject.hidden = true
        lblUrgency.hidden = true
        btnUrgency.hidden = true
    }
    
    func setProjectName(inProjectID: Int)
    {
        let myProjects = myDatabaseConnection.getProjectDetails(inProjectID)
        
        if myProjects.count == 0
        {
            btnProject.setTitle("Click to set", forState: .Normal)
            myProjectID = 0
        }
        else
        {
            btnProject.setTitle(myProjects[0].projectName, forState: .Normal)
            myProjectID = myProjects[0].projectID as Int
        }
        passedTask.currentTask.projectID = myProjectID
    }
    
    func setContext(inContextID: Int)
    {
        passedTask.currentTask.addContextToTask(inContextID)
        
        // Reload the collection data
        
        colContexts.reloadData()
    }
    
    func removeTaskContext(notification: NSNotification)
    {
        let contextToRemove = notification.userInfo!["itemNo"] as! Int
        
        passedTask.currentTask.removeContextFromTask(contextToRemove)
        
        // Reload the collection data
        
        colContexts.reloadData()
    }
}

class myContextItem: UICollectionViewCell
{
    @IBOutlet weak var lblContext: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
  
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnRemove(sender: UIButton)
    {
        if btnRemove.currentTitle == "Remove"
        {
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationRemoveTaskContext", object: nil, userInfo:["itemNo":btnRemove.tag])
        }
    }
}