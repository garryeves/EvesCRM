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

class taskViewController: UIViewController,  UITextViewDelegate, SMTEFillDelegate
{
    var passedTask: task!
    var passedEvent: myCalendarItem!
    var passedTaskType: String = "Task"
    
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
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var lblrepeatEvery: UILabel!
    @IBOutlet weak var lblFromActivity: UILabel!
    @IBOutlet weak var txtRepeatInterval: UITextField!
    @IBOutlet weak var btnRepeatPeriod: UIButton!
    @IBOutlet weak var btnRepeatBase: UIButton!

    private var pickerOptions: [String] = Array()
    private var pickerTarget: String = ""
    private var myStartDate: NSDate!
    private var myDueDate: NSDate!
    private var myProjectID: Int = 0
    private var myProjectDetails: [Projects] = Array()
    private var mySelectedRow: Int = 0
    private var kbHeight: CGFloat!
    private var colContextsHeight: CGFloat!
    private var constraintArray: [NSLayoutConstraint] = Array()
    
    lazy var activityPopover:UIPopoverController = {
        return UIPopoverController(contentViewController: self.activityViewController)
        }()
    
    lazy var activityViewController:UIActivityViewController = {
        return self.createActivityController()
        }()

    // Textexpander
    
    private var snippetExpanded: Bool = false
    
    var textExpander: SMTEDelegateController!
    
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
        
        toolbar.translucent = false
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: self, action: nil)
        
        let share = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share:")
        
        self.toolbar.items=[spacer, share]
        
        if passedTask.taskID != 0
        {
            // Lets load up the fields
            txtTaskTitle.text = passedTask.title
            txtTaskDescription.text = passedTask.details
            if passedTask.displayDueDate == ""
            {
                btnTargetDate.setTitle("None", forState: .Normal)
            }
            else
            {
                setDisplayDate(btnTargetDate, targetDate: passedTask.dueDate)
            }

            if passedTask.displayStartDate == ""
            {
                btnStart.setTitle("None", forState: .Normal)
            }
            else
            {
                setDisplayDate(btnStart, targetDate: passedTask.startDate)
            }

            if passedTask.status == ""
            {
                btnStatus.setTitle("Open", forState: .Normal)
            }
            else
            {
                btnStatus.setTitle(passedTask.status, forState: .Normal)
            }
            
            myStartDate = passedTask.startDate
            myDueDate = passedTask.dueDate
            
            if passedTask.priority == ""
            {
                btnPriority.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnPriority.setTitle(passedTask.priority, forState: .Normal)
            }
            
            if passedTask.energyLevel == ""
            {
                btnEnergy.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnEnergy.setTitle(passedTask.energyLevel, forState: .Normal)
            }
            
            if passedTask.urgency == ""
            {
                btnUrgency.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnUrgency.setTitle(passedTask.urgency, forState: .Normal)
            }

            
            if passedTask.estimatedTimeType == ""
            {
                btnEstTimeInterval.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnEstTimeInterval.setTitle(passedTask.estimatedTimeType, forState: .Normal)
            }
            
            if passedTask.projectID == 0
            {
                btnProject.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                // Go an get the project name
                getProjectName(passedTask.projectID)
            }

            if passedTask.repeatType == ""
            {
                btnRepeatPeriod.setTitle("Set Period", forState: UIControlState.Normal)
            }
            else
            {
                btnRepeatPeriod.setTitle(passedTask.repeatType, forState: UIControlState.Normal)
            }
            
            if passedTask.repeatBase == ""
            {
                btnRepeatBase.setTitle("Set Base", forState: UIControlState.Normal)
            }
            else
            {
                btnRepeatBase.setTitle(passedTask.repeatBase, forState: UIControlState.Normal)
            }
            
            txtRepeatInterval.text = "\(passedTask.repeatInterval)"
            txtEstTime.text = "\(passedTask.estimatedTime)"
            
            lblNewContext.hidden = true
            txtNewContext.hidden = true
            btnNewContext.hidden = true
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeTaskContext:", name:"NotificationRemoveTaskContext", object: nil)
            
            txtTaskDescription.delegate = self
            
            // TextExpander
            textExpander = SMTEDelegateController()
            txtTaskDescription.delegate = textExpander
            txtTaskTitle.delegate = textExpander
            txtNewContext.delegate = textExpander
            textExpander.clientAppName = "EvesCRM"
            textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
            textExpander.fillDelegate = self
            textExpander.nextDelegate = self
            myCurrentViewController = taskViewController()
            myCurrentViewController = self
        }
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
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        colContexts.collectionViewLayout.invalidateLayout()
        
        colContexts.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return passedTask.contexts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell: myContextItem!

        cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseContext", forIndexPath: indexPath) as! myContextItem
        
        cell.lblContext.text = passedTask.contexts[indexPath.row].name
        cell.btnRemove.setTitle("Remove", forState: .Normal)
        cell.btnRemove.tag = passedTask.contexts[indexPath.row].contextID
         
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
        var myOptions: UIAlertController!
        
        myOptions = delayTime("Due")
        
        myOptions.popoverPresentationController!.sourceView = self.view
        
        myOptions.popoverPresentationController!.sourceRect = CGRectMake(btnTargetDate.frame.origin.x, btnTargetDate.frame.origin.y + 20, 0, 0)
        
        self.presentViewController(myOptions, animated: true, completion: nil)
    }
    
    @IBAction func btnOwner(sender: UIButton)
    {
        if txtTaskTitle.text == ""
        {
            let alert = UIAlertController(title: "Add Task", message:
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
            
            for myContext in myContextList.allContexts
            {
                pickerOptions.append(myContext.contextHierarchy)
            }
            /*  Need to look at this as this needs to provide a better way of select contexts for the task
            
            if passedTaskType == "minutes"
            { // a meeting task
                // First need to loop through the meetings attendees
                
                for myAttendee in passedEvent.attendees
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
                for myContext in myContextList.people
                {
                    pickerOptions.append(myContext.contextHierarchy)
                }
            }
            else
            { // Not a meeting task
                for myContext in myContextList.people
                {
                    pickerOptions.append(myContext.contextHierarchy)
                }
            }
*/
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
        pickerOptions.append("Pause")
        pickerOptions.append("Complete")
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
        if pickerTarget == "TargetDate"
        {
            setDisplayDate(btnTargetDate, targetDate: myDatePicker.date)
            myDueDate = myDatePicker.date
            passedTask.dueDate = myDueDate
        }
        else
        {
            setDisplayDate(btnStart, targetDate: myDatePicker.date)
            myStartDate = myDatePicker.date
            passedTask.startDate = myStartDate
        }
        
        btnSetTargetDate.hidden = true
        myDatePicker.hidden = true
        
        showFields()
    }
    
    @IBAction func btnStart(sender: UIButton)
    {
        var myOptions: UIAlertController!

        myOptions = delayTime("Start")
        
        myOptions.popoverPresentationController!.sourceView = self.view
        
        myOptions.popoverPresentationController!.sourceRect = CGRectMake(btnStart.frame.origin.x, btnStart.frame.origin.y + 20, 0, 0)
        
        self.presentViewController(myOptions, animated: true, completion: nil)
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
        if txtNewContext.text == ""
        {
            let alert = UIAlertController(title: "Add Context", message:
                "You must provide a description for the Context before you can Add it", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alert, animated: false, completion: nil)
        }
        else
        {
            /*
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
*/
            
            let myNewContext = context(inContextName: txtNewContext.text!)
            
            setContext(myNewContext.contextID)
            lblNewContext.hidden = true
            txtNewContext.hidden = true
            btnNewContext.hidden = true
            myPicker.hidden = true
            btnSelect.hidden = true
            showFields()
        }
    }
    
    @IBAction func btnProject(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        myProjectDetails.removeAll(keepCapacity: false)
        
        pickerOptions.append("")
        
        // Get the projects for the tasks current team ID
        let myProjects = myDatabaseConnection.getProjects(passedTask.teamID)
        
        for myProject in myProjects
        {
            pickerOptions.append(myProject.projectName)
            myProjectDetails.append(myProject)
        }
        
        // Now also add in the users projects for other team Ids they have access to
        
        for myTeamItem in myDatabaseConnection.getMyTeams(myID)
        {
            if myTeamItem.teamID as Int != passedTask.teamID
            {
                let myProjects = myDatabaseConnection.getProjects(myTeamItem.teamID as Int)
                for myProject in myProjects
                {
                    pickerOptions.append(myProject.projectName)
                    myProjectDetails.append(myProject)
                }
            }
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
            passedTask.title = txtTaskTitle.text!
        }
    }
    
    @IBAction func txtEstTime(sender: UITextField)
    {
        passedTask.estimatedTime = Int(txtEstTime.text!)!
    }
    
    @IBAction func btnSelect(sender: UIButton)
    {
        // Write code for select

        if mySelectedRow != 0
        {
            if pickerTarget == "Status"
            {
                btnStatus.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedTask.status = btnStatus.currentTitle!
            }
        
            if pickerTarget == "TimeInterval"
            {
                btnEstTimeInterval.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedTask.estimatedTimeType = btnEstTimeInterval.currentTitle!
            }
        
            if pickerTarget == "Priority"
            {
                btnPriority.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedTask.priority = btnPriority.currentTitle!
            }
        
            if pickerTarget == "Energy"
            {
                btnEnergy.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedTask.energyLevel = btnEnergy.currentTitle!
            }
        
            if pickerTarget == "Urgency"
            {
                btnUrgency.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedTask.urgency = btnUrgency.currentTitle!
            }
        
            if pickerTarget == "Project"
            {
                getProjectName(myProjectDetails[mySelectedRow - 1].projectID as Int)
                passedTask.projectID = myProjectDetails[mySelectedRow - 1].projectID as Int
            }
        
            if pickerTarget == "RepeatPeriod"
            {
                passedTask.repeatType = myRepeatPeriods[mySelectedRow]
                btnRepeatPeriod.setTitle(passedTask.repeatType, forState: UIControlState.Normal)
            }
            
            if pickerTarget == "RepeatBase"
            {
                passedTask.repeatBase = myRepeatBases[mySelectedRow]
                btnRepeatBase.setTitle(passedTask.repeatBase, forState: UIControlState.Normal)
            }
            
            if pickerTarget == "Context"
            {
                let myNewContext = context(inContextName: pickerOptions[mySelectedRow])
                
                setContext(myNewContext.contextID)
                
                /*
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
*/
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
            passedTask.details = textView.text
        }
    }
    
    @IBAction func txtRepeatInterval(sender: UITextField)
    {
        passedTask.repeatInterval = Int(txtRepeatInterval.text!)!
    }
    
    @IBAction func btnrepeatPeriod(sender: UIButton)
    {
        var selectedRow: Int = 0
        var rowCount: Int = 0
        pickerOptions.removeAll()
        
        for myItem in myRepeatPeriods
        {
            pickerOptions.append(myItem)
            if myItem == passedTask.repeatType
            {
                selectedRow = rowCount
            }
            rowCount++
        }
        btnSelect.setTitle("Select Repeating type", forState: .Normal)
        pickerTarget = "RepeatPeriod"
        myPicker.reloadAllComponents()
        myPicker.hidden = false
        btnSelect.hidden = false
        mySelectedRow = -1
        myPicker.selectRow(selectedRow, inComponent: 0, animated: true)
        hideFields()
    }
    
    @IBAction func btnRepeatBase(sender: UIButton)
    {
        var selectedRow: Int = 0
        var rowCount: Int = 0

        pickerOptions.removeAll()
        
        for myItem in myRepeatBases
        {
            pickerOptions.append(myItem)
            if myItem == passedTask.repeatBase
            {
                selectedRow = rowCount
            }
            rowCount++
        }
        btnSelect.setTitle("Select Repeating base", forState: .Normal)
        pickerTarget = "RepeatBase"
        myPicker.reloadAllComponents()
        myPicker.hidden = false
        btnSelect.hidden = false
        mySelectedRow = -1
        myPicker.selectRow(selectedRow, inComponent: 0, animated: true)
        hideFields()
    }
    
    func changeViewHeight(viewName: UIView, newHeight: CGFloat)
    {
//        viewName.frame = CGRectMake(
////            viewName.frame.origin.x,
//            viewName.frame.origin.y,
//            viewName.frame.size.width,
//            newHeight
//        )
    }
    
    func showKeyboardFields()
    {
        lblTargetDate.hidden = false
        changeViewHeight(lblTargetDate, newHeight: 30)
        btnTargetDate.hidden = false
        changeViewHeight(btnTargetDate, newHeight: 30)
        lblStart.hidden = false
        changeViewHeight(lblStart, newHeight: 30)
        btnStart.hidden = false
        changeViewHeight(btnStart, newHeight: 30)
        lblContexts.hidden = false
        changeViewHeight(lblContexts, newHeight: 30)
        colContexts.hidden = false
        changeViewHeight(colContexts, newHeight: 190)
        lblPriority.hidden = false
        changeViewHeight(lblPriority, newHeight: 30)
        btnPriority.hidden = false
        changeViewHeight(btnPriority, newHeight: 30)
        lblEnergy.hidden = false
        changeViewHeight(lblEnergy, newHeight: 30)
        btnEnergy.hidden = false
        changeViewHeight(btnEnergy, newHeight: 30)
        lblUrgency.hidden = false
        changeViewHeight(lblUrgency, newHeight: 30)
        btnUrgency.hidden = false
        changeViewHeight(btnUrgency, newHeight: 30)
        btnOwner.hidden = false
        changeViewHeight(btnOwner, newHeight: 30)
        lblStatus.hidden = false
        changeViewHeight(lblStatus, newHeight: 30)
        btnStatus.hidden = false
        changeViewHeight(btnStatus, newHeight: 30)
        lblProject.hidden = false
        changeViewHeight(lblProject, newHeight: 30)
        btnProject.hidden = false
        changeViewHeight(btnProject, newHeight: 30)
    }
    
    func hideKeyboardFields()
    {
        lblTargetDate.hidden = true
        changeViewHeight(lblTargetDate, newHeight: 30)
        btnTargetDate.hidden = true
        changeViewHeight(btnTargetDate, newHeight: 30)
        lblStart.hidden = true
        changeViewHeight(lblStart, newHeight: 30)
        btnStart.hidden = true
        changeViewHeight(btnStart, newHeight: 30)
        lblContexts.hidden = true
        changeViewHeight(lblContexts, newHeight: 30)
        colContexts.hidden = true
        changeViewHeight(colContexts, newHeight: 190)
        lblPriority.hidden = true
        changeViewHeight(lblPriority, newHeight: 30)
        btnPriority.hidden = true
        changeViewHeight(btnPriority, newHeight: 30)
        lblEnergy.hidden = true
        changeViewHeight(lblEnergy, newHeight: 30)
        btnEnergy.hidden = true
        changeViewHeight(btnEnergy, newHeight: 30)
        lblUrgency.hidden = true
        changeViewHeight(lblUrgency, newHeight: 30)
        btnUrgency.hidden = true
        changeViewHeight(btnUrgency, newHeight: 30)
        btnOwner.hidden = true
        changeViewHeight(btnOwner, newHeight: 30)
        lblStatus.hidden = true
        changeViewHeight(lblStatus, newHeight: 30)
        btnStatus.hidden = true
        changeViewHeight(btnStatus, newHeight: 30)
        lblProject.hidden = true
        changeViewHeight(lblProject, newHeight: 30)
        btnProject.hidden = true
        changeViewHeight(btnProject, newHeight: 30)
    }
    
    func showFields()
    {
        showKeyboardFields()
        lblTaskTitle.hidden = false
        lblTaskDescription.hidden = false
        txtTaskTitle.hidden = false
        txtTaskDescription.hidden = false
        txtEstTime.hidden = false
        btnEstTimeInterval.hidden = false
        lblEstTime.hidden = false
        lblrepeatEvery.hidden = false
        lblFromActivity.hidden = false
        txtRepeatInterval.hidden = false
        btnRepeatPeriod.hidden = false
        btnRepeatBase.hidden = false
    }
    
    func hideFields()
    {
        hideKeyboardFields()
        lblTaskTitle.hidden = true
        lblTaskDescription.hidden = true
        txtTaskTitle.hidden = true
        txtTaskDescription.hidden = true
        txtEstTime.hidden = true
        btnEstTimeInterval.hidden = true
        lblEstTime.hidden = true
        lblrepeatEvery.hidden = false
        lblFromActivity.hidden = false
        txtRepeatInterval.hidden = false
        btnRepeatPeriod.hidden = false
        btnRepeatBase.hidden = false
    }
    
    func getProjectName(projectID: Int)
    {
        let myProjects = myDatabaseConnection.getProjectDetails(projectID)
        
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
    }
    
    func setContext(inContextID: Int)
    {
        passedTask.addContext(inContextID)
        
        // Reload the collection data
        
        colContexts.reloadData()
    }
    
    func removeTaskContext(notification: NSNotification)
    {
        let contextToRemove = notification.userInfo!["itemNo"] as! Int
        
        passedTask.removeContext(contextToRemove)
        
        // Reload the collection data
        
        colContexts.reloadData()
    }
    
    func createActivityController() -> UIActivityViewController
    {
        // Build up the details we want to share
        
        let inString: String = ""
        let sharingActivityProvider: SharingActivityProvider = SharingActivityProvider(placeholderItem: inString)
        
        let myTmp1 = passedTask.buildShareHTMLString().stringByReplacingOccurrencesOfString("\n", withString: "<p>")
        sharingActivityProvider.HTMLString = myTmp1
        sharingActivityProvider.plainString = passedTask.buildShareString()
        
        sharingActivityProvider.messageSubject = "Task: \(passedTask.title)"
        
        let activityItems : Array = [sharingActivityProvider];
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // you can specify these if you'd like.
        activityViewController.excludedActivityTypes =  [
            UIActivityTypePostToTwitter,
            UIActivityTypePostToFacebook,
            UIActivityTypePostToWeibo,
            UIActivityTypeMessage,
            //        UIActivityTypeMail,
            //        UIActivityTypePrint,
            //        UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        
        return activityViewController
    }
    
    func doNothing()
    {
        // as it says, do nothing
    }
    
    func delayTime(actionType: String) -> UIAlertController
    {
        var messagePrefix: String = ""
        
        if actionType == "Start"
        {
            messagePrefix = "Defer :"
        }
        else
        { // actionType = Due
            messagePrefix = "Due :"
        }
        
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .ActionSheet)

        let myOption1 = UIAlertAction(title: "\(messagePrefix) 1 Hour", style: .Default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Hour,
                    value: 1,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Hour,
                    value: 1,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })
        
        let myOption2 = UIAlertAction(title: "\(messagePrefix) 4 Hours", style: .Default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Hour,
                    value: 4,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Hour,
                    value: 4,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })
        
        let myOption3 = UIAlertAction(title: "\(messagePrefix) 1 Day", style: .Default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Day,
                    value: 1,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Day,
                    value: 1,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })
        
        let myOption4 = UIAlertAction(title: "\(messagePrefix) 1 Week", style: .Default, handler: { (action: UIAlertAction) -> () in

            if actionType == "Start"
            {
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Day,
                    value: 7,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Day,
                    value: 7,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })
        
        let myOption5 = UIAlertAction(title: "\(messagePrefix) 1 Month", style: .Default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Month,
                    value: 1,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Month,
                    value: 1,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })
        
        let myOption6 = UIAlertAction(title: "\(messagePrefix) 1 Year", style: .Default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Year,
                    value: 1,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = NSCalendar.currentCalendar()
                
                let newTime = myCalendar.dateByAddingUnit(
                    .Year,
                    value: 1,
                    toDate: NSDate(),
                    options: [])!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })

        let myOption7 = UIAlertAction(title: "\(messagePrefix) Custom", style: .Default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                self.btnSetTargetDate.setTitle("Set Start Date", forState: .Normal)
                self.pickerTarget = "StartDate"
                if self.passedTask.displayStartDate == ""
                {
                    self.myDatePicker.date = NSDate()
                }
                else
                {
                    self.myDatePicker.date = self.passedTask.startDate
                }
            }
            else
            { // actionType = Due
                self.btnSetTargetDate.setTitle("Set Target Date", forState: .Normal)
                self.pickerTarget = "TargetDate"
                if self.passedTask.displayDueDate == ""
                {
                    self.myDatePicker.date = NSDate()
                }
                else
                {
                    self.myDatePicker.date = self.passedTask.dueDate
                }
            }
        
            self.myDatePicker.datePickerMode = UIDatePickerMode.DateAndTime
            self.hideFields()
            self.myDatePicker.hidden = false
            self.btnSetTargetDate.hidden = false
        })
        
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        myOptions.addAction(myOption3)
        myOptions.addAction(myOption4)
        myOptions.addAction(myOption5)
        myOptions.addAction(myOption6)
        myOptions.addAction(myOption7)
        
        return myOptions
    }
    
    func setDisplayDate(targetButton: UIButton, targetDate: NSDate)
    {
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        targetButton.setTitle(myDateFormatter.stringFromDate(targetDate), forState: .Normal)
    }

    func share(sender: AnyObject)
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // actually, you don't have to do this. But if you do want a popover, this is how to do it.
            iPad(sender)
        }
    }
    
    func iPad(sender: AnyObject) {
        if !self.activityPopover.popoverVisible {
            if sender is UIBarButtonItem {
                self.activityPopover.presentPopoverFromBarButtonItem(sender as! UIBarButtonItem,
                    permittedArrowDirections:.Any,
                    animated:true)
            } else {
                let b = sender as! UIButton
                self.activityPopover.presentPopoverFromRect(b.frame,
                    inView: self.view,
                    permittedArrowDirections:.Any,
                    animated:true)
            }
        } else {
            self.activityPopover.dismissPopoverAnimated(true)
        }
    }
    
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

        if txtTaskTitle.isFirstResponder()
        {
            //  This is at the top, so we do not need to do anything
            boolActionMove = true
        }
        else if txtRepeatInterval.isFirstResponder()
        {
            boolActionMove = true
        }
        else if txtTaskDescription.isFirstResponder()
        {
            boolActionMove = true
        }
        else if txtEstTime.isFirstResponder()
        {
            boolActionMove = true
        }
        else if txtNewContext.isFirstResponder()
        {
            boolActionMove = true
        }
        
        if boolActionMove
        {
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, movement)
                
            })
            
            let myConstraints = [
                "constraintContexts",
                "constraintContexts1",
                "constraintContexts2",
                "constraintContexts3",
                "constraintStart",
                "constraintDue",
                "constraintPriority",
                "constraintUrgency",
                "constraintEnergy",
                "constraintContextTable",
                "constraintOwner",
                "constraintLabelStart",
                "constraintLabelDue",
                "constraintLabelPriority",
                "constraintLabelUrgency",
                "constraintLabelEnergy",
                "constraintProjectButton1",
                "constraintProjectButton2",
                "constraintProjectButton3",
                "constraintProjectButton4",
                "constraintProjectButton5",
                "constraintProjectButton6",
                "constraintProjectDesc1",
                "constraintProjectDesc2",
                "constraintProjectDesc3"
            ]
            
            if up
            {
                if constraintArray.count == 0
                {
                    // Populate the array
                    for myItem in self.view.constraints
                    {
                        if myItem.identifier != nil
                        {
                            if myConstraints.contains(myItem.identifier!)
                            {
                                constraintArray.append(myItem)
                            }
                        }
                    }
                }
                
                NSLayoutConstraint.deactivateConstraints(constraintArray)
                hideKeyboardFields()
            }
            else
            {
                showKeyboardFields()
                NSLayoutConstraint.activateConstraints(constraintArray)
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
                result = "txtNewContext"
            }
            
            if uiTextObject.tag == 2
            {
                result = "txtTaskTitle"
            }
        }
        
        if uiTextObject.isKindOfClass(UITextView)
        {
            if uiTextObject.tag == 1
            {
                result = "txtTaskDescription"
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
        
        passedTask.title = txtTaskTitle.text!
        passedTask.details = txtTaskDescription.text
        
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
        
        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.memory // grab the data and cast it to a Swift Int8
        
        if "txtTaskDescription" == textIdentifier
        {
            txtTaskDescription.becomeFirstResponder()
            let theLoc = txtTaskDescription.positionFromPosition(txtTaskDescription.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtTaskDescription.selectedTextRange = txtTaskDescription.textRangeFromPosition(theLoc!, toPosition: theLoc!)
            }
            return txtTaskDescription
        }
        else if "txtTaskTitle" == textIdentifier
        {
            txtTaskTitle.becomeFirstResponder()
            let theLoc = txtTaskTitle.positionFromPosition(txtTaskTitle.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtTaskTitle.selectedTextRange = txtTaskTitle.textRangeFromPosition(theLoc!, toPosition: theLoc!)
            }
            return txtTaskTitle
        }
        else if "txtNewContext" == textIdentifier
        {
            txtNewContext.becomeFirstResponder()
            let theLoc = txtNewContext.positionFromPosition(txtNewContext.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtNewContext.selectedTextRange = txtNewContext.textRangeFromPosition(theLoc!, toPosition: theLoc!)
            }
            return txtNewContext
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