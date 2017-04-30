//
//  meetingTaskViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 22/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
import AddressBook
//import TextExpander

protocol MyTaskDelegate
{
    func myTaskDidFinish(_ controller:taskViewController, actionType: String, currentTask: task)
    func myTaskUpdateDidFinish(_ controller:taskUpdatesViewController, actionType: String, currentTask: task)
}

class taskViewController: UIViewController,  UITextViewDelegate//, SMTEFillDelegate
{
    var passedTask: task!
    var passedEvent: calendarItem!
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

    fileprivate var pickerOptions: [String] = Array()
    fileprivate var pickerTarget: String = ""
    fileprivate var myStartDate: Date!
    fileprivate var myDueDate: Date!
    fileprivate var myProjectID: Int32 = 0
    fileprivate var myProjectDetails: [Projects] = Array()
    fileprivate var mySelectedRow: Int = 0
    fileprivate var kbHeight: CGFloat!
    fileprivate var colContextsHeight: CGFloat!
    fileprivate var constraintArray: [NSLayoutConstraint] = Array()
    
//    lazy var activityPopover:UIPopoverController = {
//        return UIPopoverController(contentViewController: self.activityViewController)
//        }()
    
//    lazy var activityViewController:UIActivityViewController = {
//        return self.createActivityController()
//        }()

//    // Textexpander
//    
//    fileprivate var snippetExpanded: Bool = false
//    
//    var textExpander: SMTEDelegateController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        myDatePicker.isHidden = true
        myPicker.isHidden = true
        btnSelect.isHidden = true
        btnSetTargetDate.isHidden = true
        
        txtTaskDescription.layer.borderColor = UIColor.lightGray.cgColor
        txtTaskDescription.layer.borderWidth = 0.5
        txtTaskDescription.layer.cornerRadius = 5.0
        txtTaskDescription.layer.masksToBounds = true
        
        toolbar.isTranslucent = false
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
            target: self, action: nil)
        
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share(_:)))
        
        self.toolbar.items=[spacer, share]
        
        if passedTask.taskID != 0
        {
            // Lets load up the fields
            txtTaskTitle.text = passedTask.title
            txtTaskDescription.text = passedTask.details
            if passedTask.displayDueDate == ""
            {
                btnTargetDate.setTitle("None", for: .normal)
            }
            else
            {
                setDisplayDate(btnTargetDate, targetDate: passedTask.dueDate)
            }

            if passedTask.displayStartDate == ""
            {
                btnStart.setTitle("None", for: .normal)
            }
            else
            {
                setDisplayDate(btnStart, targetDate: passedTask.startDate)
            }

            if passedTask.status == ""
            {
                btnStatus.setTitle("Open", for: .normal)
            }
            else
            {
                btnStatus.setTitle(passedTask.status, for: .normal)
            }
            
            myStartDate = passedTask.startDate as Date!
            myDueDate = passedTask.dueDate as Date!
            
            if passedTask.priority == ""
            {
                btnPriority.setTitle("Click to set", for: .normal)
            }
            else
            {
                btnPriority.setTitle(passedTask.priority, for: .normal)
            }
            
            if passedTask.energyLevel == ""
            {
                btnEnergy.setTitle("Click to set", for: .normal)
            }
            else
            {
                btnEnergy.setTitle(passedTask.energyLevel, for: .normal)
            }
            
            if passedTask.urgency == ""
            {
                btnUrgency.setTitle("Click to set", for: .normal)
            }
            else
            {
                btnUrgency.setTitle(passedTask.urgency, for: .normal)
            }

            
            if passedTask.estimatedTimeType == ""
            {
                btnEstTimeInterval.setTitle("Click to set", for: .normal)
            }
            else
            {
                btnEstTimeInterval.setTitle(passedTask.estimatedTimeType, for: .normal)
            }
            
            if passedTask.projectID == 0
            {
                btnProject.setTitle("Click to set", for: .normal)
            }
            else
            {
                // Go an get the project name
                getProjectName(passedTask.projectID)
            }

            if passedTask.repeatType == ""
            {
                btnRepeatPeriod.setTitle("Set Period", for: .normal)
            }
            else
            {
                btnRepeatPeriod.setTitle(passedTask.repeatType, for: .normal)
            }
            
            if passedTask.repeatBase == ""
            {
                btnRepeatBase.setTitle("Set Base", for: .normal)
            }
            else
            {
                btnRepeatBase.setTitle(passedTask.repeatBase, for: .normal)
            }
            
            txtRepeatInterval.text = "\(passedTask.repeatInterval)"
            txtEstTime.text = "\(passedTask.estimatedTime)"
            
            lblNewContext.isHidden = true
            txtNewContext.isHidden = true
            btnNewContext.isHidden = true
            
            notificationCenter.addObserver(self, selector: #selector(self.removeTaskContext(_:)), name: NotificationRemoveTaskContext, object: nil)
            
            txtTaskDescription.delegate = self
            
//            // TextExpander
//            textExpander = SMTEDelegateController()
//            txtTaskDescription.delegate = textExpander
//            txtTaskTitle.delegate = textExpander
//            txtNewContext.delegate = textExpander
//            textExpander.clientAppName = "EvesCRM"
//            textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
//            textExpander.fillDelegate = self
//            textExpander.nextDelegate = self
            myCurrentViewController = taskViewController()
            myCurrentViewController = self
        }
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
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        colContexts.collectionViewLayout.invalidateLayout()
        
        colContexts.reloadData()
    }
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return passedTask.contexts.count
    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell: myContextItem!

        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseContext", for: indexPath as IndexPath) as! myContextItem
        
        cell.lblContext.text = passedTask.contexts[indexPath.row].name
        cell.btnRemove.setTitle("Remove", for: .normal)
        cell.btnRemove.tag = Int(passedTask.contexts[indexPath.row].contextID)
         
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
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSize(width: colContexts.bounds.size.width, height: 39)
    }

    func numberOfComponentsInPickerView(_ TableTypeSelection1: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ TableTypeSelection1: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerOptions.count
    }
    
    func pickerView(_ TableTypeSelection1: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return pickerOptions[row]
    }
    
    func pickerView(_ TableTypeSelection1: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        mySelectedRow = row
    }
    
    @IBAction func btnTargetDate(_ sender: UIButton)
    {
        var myOptions: UIAlertController!
        
        myOptions = delayTime("Due")
        
        myOptions.popoverPresentationController!.sourceView = self.view
        
        myOptions.popoverPresentationController!.sourceRect = CGRect(x: btnTargetDate.frame.origin.x, y: btnTargetDate.frame.origin.y + 20, width: 0, height: 0)
        
        self.present(myOptions, animated: true, completion: nil)
    }
    
    @IBAction func btnOwner(_ sender: UIButton)
    {
        if txtTaskTitle.text == ""
        {
            let alert = UIAlertController(title: "Add Task", message:
                "You must provide a description for the Task before you can add a Context to it", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alert, animated: false, completion: nil)
        }
        else
        {
       //     lblNewContext.isHidden = false
      //      txtNewContext.isHidden = false
      //      btnNewContext.isHidden = false
      //      txtNewContext.text = ""
        
            let myContextList = contexts()
            
            pickerOptions.removeAll(keepingCapacity: false)
            
            pickerOptions.append("")

            for myContext in myContextList.people
            {
                pickerOptions.append(myContext.contextHierarchy)
            }
            
            for myContext in myContextList.places
            {
                pickerOptions.append(myContext.contextHierarchy)
            }
            
            for myContext in myContextList.tools
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
                myPicker.isHidden = false
                btnSelect.isHidden = false
                myPicker.reloadAllComponents()
                btnSelect.setTitle("Set Context", for: .normal)
                myPicker.selectRow(0,inComponent: 0, animated: true)
                mySelectedRow = 0
            }
            
            pickerTarget = "Context"
        }
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        for myItem in myTaskStatus
        {
            pickerOptions.append(myItem)
        }

        hideFields()
        myPicker.isHidden = false
        btnSelect.isHidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Status"
        btnSelect.setTitle("Set Status", for: .normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func btnSetTargetDate(_ sender: UIButton)
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
        
        btnSetTargetDate.isHidden = true
        myDatePicker.isHidden = true
        
        showFields()
    }
    
    @IBAction func btnStart(_ sender: UIButton)
    {
        var myOptions: UIAlertController!

        myOptions = delayTime("Start")
        
        myOptions.popoverPresentationController!.sourceView = self.view
        
        myOptions.popoverPresentationController!.sourceRect = CGRect(x: btnStart.frame.origin.x, y: btnStart.frame.origin.y + 20, width: 0, height: 0)
        
        self.present(myOptions, animated: true, completion: nil)
    }
    
    @IBAction func btnEstTimeInterval(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        for myItem in myTimeInterval
        {
            pickerOptions.append(myItem)
        }

        hideFields()
        myPicker.isHidden = false
        btnSelect.isHidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "TimeInterval"
        btnSelect.setTitle("Set Time Interval", for: .normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func btnPriority(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        
        for myItem in myTaskPriority
        {
            pickerOptions.append(myItem)
        }

        
        hideFields()
        myPicker.isHidden = false
        btnSelect.isHidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Priority"
        btnSelect.setTitle("Set Priority", for: .normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func btnEnergy(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        
        for myItem in myTaskEnergy
        {
            pickerOptions.append(myItem)
        }

        hideFields()
        myPicker.isHidden = false
        btnSelect.isHidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Energy"
        btnSelect.setTitle("Set Energy", for: .normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func btnNewContext(_ sender: UIButton)
    {
        if txtNewContext.text == ""
        {
            let alert = UIAlertController(title: "Add Context", message:
                "You must provide a description for the Context before you can Add it", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alert, animated: false, completion: nil)
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
                let myNewContext = context(contextName: txtNewContext.text)
            
                setContext(myNewContext.contextID)
            }
*/
            
            let myNewContext = context(contextName: txtNewContext.text!)
            
            setContext(myNewContext.contextID)
            lblNewContext.isHidden = true
            txtNewContext.isHidden = true
            btnNewContext.isHidden = true
            myPicker.isHidden = true
            btnSelect.isHidden = true
            showFields()
        }
    }
    
    @IBAction func btnProject(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        myProjectDetails.removeAll(keepingCapacity: false)
        
        pickerOptions.append("")
        
        // Get the projects for the tasks current team ID
        let myProjects = myDatabaseConnection.getProjects(passedTask.teamID)
        
        for myProject in myProjects
        {
            pickerOptions.append(myProject.projectName!)
            myProjectDetails.append(myProject)
        }
        
        // Now also add in the users projects for other team Ids they have access to
        
        for myTeamItem in myDatabaseConnection.getMyTeams(myID)
        {
            if myTeamItem.teamID != passedTask.teamID
            {
                let myProjects = myDatabaseConnection.getProjects(myTeamItem.teamID)
                for myProject in myProjects
                {
                    pickerOptions.append(myProject.projectName!)
                    myProjectDetails.append(myProject)
                }
            }
        }
        
        hideFields()
        myPicker.isHidden = false
        btnSelect.isHidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Project"
        btnSelect.setTitle("Set Project", for: .normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func btnUrgency(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        
        for myItem in myTaskUrgency
        {
            pickerOptions.append(myItem)
        }

        hideFields()
        myPicker.isHidden = false
        btnSelect.isHidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Urgency"
        btnSelect.setTitle("Set Urgency", for: .normal)
        myPicker.selectRow(0,inComponent: 0, animated: true)
        mySelectedRow = 0
    }
    
    @IBAction func txtTaskDetail(_ sender: UITextField)
    {
        if txtTaskTitle.text != ""
        {
            passedTask.title = txtTaskTitle.text!
        }
    }
    
    @IBAction func txtEstTime(_ sender: UITextField)
    {
        passedTask.estimatedTime = Int16(txtEstTime.text!)!
    }
    
    @IBAction func btnSelect(_ sender: UIButton)
    {
        // Write code for select

        if mySelectedRow != 0
        {
            if pickerTarget == "Status"
            {
                btnStatus.setTitle(pickerOptions[mySelectedRow], for: .normal)
                passedTask.status = btnStatus.currentTitle!
            }
        
            if pickerTarget == "TimeInterval"
            {
                btnEstTimeInterval.setTitle(pickerOptions[mySelectedRow], for: .normal)
                passedTask.estimatedTimeType = btnEstTimeInterval.currentTitle!
            }
        
            if pickerTarget == "Priority"
            {
                btnPriority.setTitle(pickerOptions[mySelectedRow], for: .normal)
                passedTask.priority = btnPriority.currentTitle!
            }
        
            if pickerTarget == "Energy"
            {
                btnEnergy.setTitle(pickerOptions[mySelectedRow], for: .normal)
                passedTask.energyLevel = btnEnergy.currentTitle!
            }
        
            if pickerTarget == "Urgency"
            {
                btnUrgency.setTitle(pickerOptions[mySelectedRow], for: .normal)
                passedTask.urgency = btnUrgency.currentTitle!
            }
        
            if pickerTarget == "Project"
            {
                getProjectName(myProjectDetails[mySelectedRow - 1].projectID)
                passedTask.projectID = myProjectDetails[mySelectedRow - 1].projectID
            }
        
            if pickerTarget == "RepeatPeriod"
            {
                passedTask.repeatType = myRepeatPeriods[mySelectedRow]
                btnRepeatPeriod.setTitle(passedTask.repeatType, for: .normal)
            }
            
            if pickerTarget == "RepeatBase"
            {
                passedTask.repeatBase = myRepeatBases[mySelectedRow]
                btnRepeatBase.setTitle(passedTask.repeatBase, for: .normal)
            }
            
            if pickerTarget == "Context"
            {
                let myNewContext = context(contextName: pickerOptions[mySelectedRow])
                
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
                    let myNewContext = context(contextName: pickerOptions[mySelectedRow])
                
                    setContext(myNewContext.contextID)
                }
*/
            }
        }
        myPicker.isHidden = true
        btnSelect.isHidden = true
        lblNewContext.isHidden = true
        txtNewContext.isHidden = true
        btnNewContext.isHidden = true
        showFields()
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    { //Handle the text changes here
        
        if textView == txtTaskDescription
        {
            passedTask.details = textView.text
        }
    }
    
    @IBAction func txtRepeatInterval(_ sender: UITextField)
    {
        passedTask.repeatInterval = Int16(txtRepeatInterval.text!)!
    }
    
    @IBAction func btnrepeatPeriod(_ sender: UIButton)
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
            rowCount += 1
        }
        btnSelect.setTitle("Select Repeating type", for: .normal)
        pickerTarget = "RepeatPeriod"
        myPicker.reloadAllComponents()
        myPicker.isHidden = false
        btnSelect.isHidden = false
        mySelectedRow = -1
        myPicker.selectRow(selectedRow, inComponent: 0, animated: true)
        hideFields()
    }
    
    @IBAction func btnRepeatBase(_ sender: UIButton)
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
            rowCount += 1
        }
        btnSelect.setTitle("Select Repeating base", for: .normal)
        pickerTarget = "RepeatBase"
        myPicker.reloadAllComponents()
        myPicker.isHidden = false
        btnSelect.isHidden = false
        mySelectedRow = -1
        myPicker.selectRow(selectedRow, inComponent: 0, animated: true)
        hideFields()
    }
    
    func changeViewHeight(_ viewName: UIView, newHeight: CGFloat)
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
        lblTargetDate.isHidden = false
        changeViewHeight(lblTargetDate, newHeight: 30)
        btnTargetDate.isHidden = false
        changeViewHeight(btnTargetDate, newHeight: 30)
        lblStart.isHidden = false
        changeViewHeight(lblStart, newHeight: 30)
        btnStart.isHidden = false
        changeViewHeight(btnStart, newHeight: 30)
        lblContexts.isHidden = false
        changeViewHeight(lblContexts, newHeight: 30)
        colContexts.isHidden = false
        changeViewHeight(colContexts, newHeight: 190)
        lblPriority.isHidden = false
        changeViewHeight(lblPriority, newHeight: 30)
        btnPriority.isHidden = false
        changeViewHeight(btnPriority, newHeight: 30)
        lblEnergy.isHidden = false
        changeViewHeight(lblEnergy, newHeight: 30)
        btnEnergy.isHidden = false
        changeViewHeight(btnEnergy, newHeight: 30)
        lblUrgency.isHidden = false
        changeViewHeight(lblUrgency, newHeight: 30)
        btnUrgency.isHidden = false
        changeViewHeight(btnUrgency, newHeight: 30)
        btnOwner.isHidden = false
        changeViewHeight(btnOwner, newHeight: 30)
        lblStatus.isHidden = false
        changeViewHeight(lblStatus, newHeight: 30)
        btnStatus.isHidden = false
        changeViewHeight(btnStatus, newHeight: 30)
        lblProject.isHidden = false
        changeViewHeight(lblProject, newHeight: 30)
        btnProject.isHidden = false
        changeViewHeight(btnProject, newHeight: 30)
    }
    
    func hideKeyboardFields()
    {
        lblTargetDate.isHidden = true
        changeViewHeight(lblTargetDate, newHeight: 30)
        btnTargetDate.isHidden = true
        changeViewHeight(btnTargetDate, newHeight: 30)
        lblStart.isHidden = true
        changeViewHeight(lblStart, newHeight: 30)
        btnStart.isHidden = true
        changeViewHeight(btnStart, newHeight: 30)
        lblContexts.isHidden = true
        changeViewHeight(lblContexts, newHeight: 30)
        colContexts.isHidden = true
        changeViewHeight(colContexts, newHeight: 190)
        lblPriority.isHidden = true
        changeViewHeight(lblPriority, newHeight: 30)
        btnPriority.isHidden = true
        changeViewHeight(btnPriority, newHeight: 30)
        lblEnergy.isHidden = true
        changeViewHeight(lblEnergy, newHeight: 30)
        btnEnergy.isHidden = true
        changeViewHeight(btnEnergy, newHeight: 30)
        lblUrgency.isHidden = true
        changeViewHeight(lblUrgency, newHeight: 30)
        btnUrgency.isHidden = true
        changeViewHeight(btnUrgency, newHeight: 30)
        btnOwner.isHidden = true
        changeViewHeight(btnOwner, newHeight: 30)
        lblStatus.isHidden = true
        changeViewHeight(lblStatus, newHeight: 30)
        btnStatus.isHidden = true
        changeViewHeight(btnStatus, newHeight: 30)
        lblProject.isHidden = true
        changeViewHeight(lblProject, newHeight: 30)
        btnProject.isHidden = true
        changeViewHeight(btnProject, newHeight: 30)
    }
    
    func showFields()
    {
        showKeyboardFields()
        lblTaskTitle.isHidden = false
        lblTaskDescription.isHidden = false
        txtTaskTitle.isHidden = false
        txtTaskDescription.isHidden = false
        txtEstTime.isHidden = false
        btnEstTimeInterval.isHidden = false
        lblEstTime.isHidden = false
        lblrepeatEvery.isHidden = false
        lblFromActivity.isHidden = false
        txtRepeatInterval.isHidden = false
        btnRepeatPeriod.isHidden = false
        btnRepeatBase.isHidden = false
    }
    
    func hideFields()
    {
        hideKeyboardFields()
        lblTaskTitle.isHidden = true
        lblTaskDescription.isHidden = true
        txtTaskTitle.isHidden = true
        txtTaskDescription.isHidden = true
        txtEstTime.isHidden = true
        btnEstTimeInterval.isHidden = true
        lblEstTime.isHidden = true
        lblrepeatEvery.isHidden = true
        lblFromActivity.isHidden = true
        txtRepeatInterval.isHidden = true
        btnRepeatPeriod.isHidden = true
        btnRepeatBase.isHidden = true
    }
    
    func getProjectName(_ projectID: Int32)
    {
        let myProjects = myDatabaseConnection.getProjectDetails(projectID)
        
        if myProjects.count == 0
        {
            btnProject.setTitle("Click to set", for: .normal)
            myProjectID = 0
        }
        else
        {
            btnProject.setTitle(myProjects[0].projectName, for: .normal)
            myProjectID = myProjects[0].projectID
        }
    }
    
    func setContext(_ contextID: Int32)
    {
        passedTask.addContext(contextID)
        
        // Reload the collection data
        
        colContexts.reloadData()
    }
    
    func removeTaskContext(_ notification: Notification)
    {
        let contextToRemove = notification.userInfo!["itemNo"] as! Int32
        
        passedTask.removeContext(contextToRemove)
        
        // Reload the collection data
        
        colContexts.reloadData()
    }
    
    func createActivityController() -> UIActivityViewController
    {
        // Build up the details we want to share
        
        let sourceString: String = ""
        let sharingActivityProvider: SharingActivityProvider = SharingActivityProvider(placeholderItem: sourceString)
        
        let myTmp1 = passedTask.buildShareHTMLString().replacingOccurrences(of: "\n", with: "<p>")
        sharingActivityProvider.HTMLString = myTmp1
        sharingActivityProvider.plainString = passedTask.buildShareString()
        
        sharingActivityProvider.messageSubject = "Task: \(passedTask.title)"
        
        let activityItems : Array = [sharingActivityProvider];
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // you can specify these if you'd like.
        activityViewController.excludedActivityTypes =  [
            UIActivityType.postToTwitter,
            UIActivityType.postToFacebook,
            UIActivityType.postToWeibo,
            UIActivityType.message,
            //        UIActivityTypeMail,
            //        UIActivityTypePrint,
            //        UIActivityTypeCopyToPasteboard,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        
        return activityViewController
    }
    
    func doNothing()
    {
        // as it says, do nothing
    }
    
    func delayTime(_ actionType: String) -> UIAlertController
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
        
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .actionSheet)

        let myOption1 = UIAlertAction(title: "\(messagePrefix) 1 Hour", style: .default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .hour,
                    value: 1,
                    to: Date())!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .hour,
                    value: 1,
                    to: Date())!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })
        
        let myOption2 = UIAlertAction(title: "\(messagePrefix) 4 Hours", style: .default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .hour,
                    value: 4,
                    to: Date())!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .hour,
                    value: 4,
                    to: Date())!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })
        
        let myOption3 = UIAlertAction(title: "\(messagePrefix) 1 Day", style: .default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .day,
                    value: 1,
                    to: Date())!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .day,
                    value: 1,
                    to: Date())!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })
        
        let myOption4 = UIAlertAction(title: "\(messagePrefix) 1 Week", style: .default, handler: { (action: UIAlertAction) -> () in

            if actionType == "Start"
            {
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .day,
                    value: 7,
                    to: Date())!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .day,
                    value: 7,
                    to: Date())!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })
        
        let myOption5 = UIAlertAction(title: "\(messagePrefix) 1 Month", style: .default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .month,
                    value: 1,
                    to: Date())!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .month,
                    value: 1,
                    to: Date())!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })
        
        let myOption6 = UIAlertAction(title: "\(messagePrefix) 1 Year", style: .default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .year,
                    value: 1,
                    to: Date())!
                
                self.setDisplayDate(self.btnStart, targetDate: newTime)
                
                self.myStartDate = newTime
                self.passedTask.startDate = newTime
            }
            else
            { // actionType = Due
                let myCalendar = Calendar.current
                
                let newTime = myCalendar.date(byAdding:
                    .year,
                    value: 1,
                    to: Date())!
                
                self.setDisplayDate(self.btnTargetDate, targetDate: newTime)
                
                self.myDueDate = newTime
                self.passedTask.dueDate = newTime
            }
        })

        let myOption7 = UIAlertAction(title: "\(messagePrefix) Custom", style: .default, handler: { (action: UIAlertAction) -> () in
            if actionType == "Start"
            {
                self.btnSetTargetDate.setTitle("Set Start Date", for: .normal)
                self.pickerTarget = "StartDate"
                if self.passedTask.displayStartDate == ""
                {
                    self.myDatePicker.date = Date()
                }
                else
                {
                    self.myDatePicker.date = self.passedTask.startDate
                }
            }
            else
            { // actionType = Due
                self.btnSetTargetDate.setTitle("Set Target Date", for: .normal)
                self.pickerTarget = "TargetDate"
                if self.passedTask.displayDueDate == ""
                {
                    self.myDatePicker.date = Date()
                }
                else
                {
                    self.myDatePicker.date = self.passedTask.dueDate
                }
            }
        
            self.myDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
            self.hideFields()
            self.myDatePicker.isHidden = false
            self.btnSetTargetDate.isHidden = false
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
    
    func setDisplayDate(_ targetButton: UIButton, targetDate: Date)
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.timeStyle = DateFormatter.Style.short
        myDateFormatter.dateStyle = DateFormatter.Style.medium
        
        targetButton.setTitle(myDateFormatter.string(from: targetDate), for: .normal)
    }

    func share(_ sender: AnyObject)
    {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let activityViewController: UIActivityViewController = createActivityController()
            activityViewController.popoverPresentationController!.sourceView = sender.view
            present(activityViewController, animated:true, completion:nil)
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            // actually, you don't have to do this. But if you do want a popover, this is how to do it.
            iPad(sender)
        }
    }
    
    func iPad(_ sender: AnyObject)
    {
        let activityViewController: UIActivityViewController = createActivityController()
        activityViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        activityViewController.popoverPresentationController!.sourceView = sender.view
        present(activityViewController, animated:true, completion:nil)
        /*
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
*/
    }
    
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

        if txtTaskTitle.isFirstResponder
        {
            //  This is at the top, so we do not need to do anything
            boolActionMove = true
        }
        else if txtRepeatInterval.isFirstResponder
        {
            boolActionMove = true
        }
        else if txtTaskDescription.isFirstResponder
        {
            boolActionMove = true
        }
        else if txtEstTime.isFirstResponder
        {
            boolActionMove = true
        }
        else if txtNewContext.isFirstResponder
        {
            boolActionMove = true
        }
        
        if boolActionMove
        {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement!)
                
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
                
                NSLayoutConstraint.deactivate(constraintArray)
                hideKeyboardFields()
            }
            else
            {
                showKeyboardFields()
                NSLayoutConstraint.activate(constraintArray)
            }
        }
    }


//    //---------------------------------------------------------------
//    // These three methods implement the SMTEFillDelegate protocol to support fill-ins
//    
//    /* When an abbreviation for a snippet that looks like a fill-in snippet has been
//    * typed, SMTEDelegateController will call your fill delegate's implementation of
//    * this method.
//    * Provide some kind of identifier for the given UITextView/UITextField/UISearchBar/UIWebView
//    * The ID doesn't have to be fancy, "maintext" or "searchbar" will do.
//    * Return nil to avoid the fill-in app-switching process (the snippet will be expanded
//    * with "(field name)" where the fill fields are).
//    *
//    * Note that in the case of a UIWebView, the uiTextObject passed will actually be
//    * an NSDictionary with two of these keys:
//    *     - SMTEkWebView          The UIWebView object (key always present)
//    *     - SMTEkElementID        The HTML element's id attribute (if found, preferred over Name)
//    *     - SMTEkElementName      The HTML element's name attribute (if id not found and name found)
//    * (If no id or name attribute is found, fill-in's cannot be supported, as there is
//    * no way for TE to insert the filled-in text.)
//    * Unless there is only one editable area in your web view, this implies that the returned
//    * identifier string needs to include element id/name information. Eg. "webview-field2".
//    */
//    
// //   func identifierForTextArea(_ uiTextObject: AnyObject) -> String
//    public func identifier(forTextArea uiTextObject: Any!) -> String!
//    {
//        var result: String = ""
//   
//        if uiTextObject is UITextField
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "txtNewContext"
//            }
//            
//            if (uiTextObject as AnyObject).tag == 2
//            {
//                result = "txtTaskTitle"
//            }
//        }
//        
//        if uiTextObject is UITextView
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "txtTaskDescription"
//            }
//        }
//        
//        if uiTextObject is UISearchBar
//        {
//            result =  "mySearchBar"
//        }
//        
//        return result
//    }
//    
//    
//    
//    /* Usually called milliseconds after identifierForTextArea:, SMTEDelegateController is
//    * about to call [[UIApplication sharedApplication] openURL: "tetouch-xc: *x-callback-url/fillin?..."]
//    * In other words, the TEtouch is about to be activated. Your app should save state
//    * and make any other preparations.
//    *
//    * Return NO to cancel the process.
//    */
//
//    func prepare(forFillSwitch textIdentifier: String) -> Bool
//    {
//        // At this point the app should save state since TextExpander touch is about
//        // to activate.
//        // It especially needs to save the contents of the textview/textfield!
//        
//        passedTask.title = txtTaskTitle.text!
//        passedTask.details = txtTaskDescription.text
//        
//        return true
//    }
//    
//    /* Restore active typing location and insertion cursor position to a text item
//    * based on the identifier the fill delegate provided earlier.
//    * (This call is made from handleFillCompletionURL: )
//    *
//    * In the case of a UIWebView, this method should build and return an NSDictionary
//    * like the one sent to the fill delegate in identifierForTextArea: when the snippet
//    * was triggered.
//    * That is, you should make the UIWebView become first responder, then return an
//    * NSDictionary with two of these keys:
//    *     - SMTEkWebView          The UIWebView object (key must be present)
//    *     - SMTEkElementID        The HTML element's id attribute (preferred over Name)
//    *     - SMTEkElementName      The HTML element's name attribute (only if no id)
//    * TE will use the same Javascripts that it uses to expand normal snippets to focus the appropriate
//    * element and insert the filled text.
//    *
//    * Note 1: If your app is still loaded after returning from TEtouch's fill window,
//    * probably no work needs to be done (the text item will still be the first
//    * responder, and the insertion cursor position will still be the same).
//    * Note 2: If the requested insertionPointLocation cannot be honored (ie. text has
//    * been reset because of the app switching), then update it to whatever is reasonable.
//    *
//    * Return nil to cancel insertion of the fill-in text. Users will not expect a cancel
//    * at this point unless userCanceledFill is set. Even in the cancel case, they will likely
//    * expect the identified text object to become the first responder.
//    */
//    
//    // func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
//    public func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String!, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>!) -> Any!
//    {
//        snippetExpanded = true
//        
//        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.pointee // grab the data and cast it to a Swift Int8
//        
//        if "txtTaskDescription" == textIdentifier
//        {
//            txtTaskDescription.becomeFirstResponder()
//            let theLoc = txtTaskDescription.position(from: txtTaskDescription.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtTaskDescription.selectedTextRange = txtTaskDescription.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtTaskDescription
//        }
//        else if "txtTaskTitle" == textIdentifier
//        {
//            txtTaskTitle.becomeFirstResponder()
//            let theLoc = txtTaskTitle.position(from: txtTaskTitle.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtTaskTitle.selectedTextRange = txtTaskTitle.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtTaskTitle
//        }
//        else if "txtNewContext" == textIdentifier
//        {
//            txtNewContext.becomeFirstResponder()
//            let theLoc = txtNewContext.position(from: txtNewContext.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtNewContext.selectedTextRange = txtNewContext.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtNewContext
//        }
//            //        else if "mySearchBar" == textIdentifier
//            //        {
//            //            searchBar.becomeFirstResponder()
//            // Note: UISearchBar does not support cursor positioning.
//            // Since we don't save search bar text as part of our state, if our app was unloaded while TE was
//            // presenting the fill-in window, the search bar might now be empty to we should return
//            // insertionPointLocation of 0.
//            //            let searchTextLen = searchBar.text.length
//            //            if searchTextLen < ioInsertionPointLocation
//            //            {
//            //                ioInsertionPointLocation = searchTextLen
//            //            }
//            //            return searchBar
//            //        }
//        else
//        {
//            
//            //return nil
//            
//            return "" as AnyObject
//        }
//    }
//    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
//    {
//        if (textExpander.isAttemptingToExpandText)
//        {
//            snippetExpanded = true
//        }
//        return true
//    }
//    
//    // Workaround for what appears to be an iOS 7 bug which affects expansion of snippets
//    // whose content is greater than one line. The UITextView fails to update its display
//    // to show the full content. Try commenting this out and expanding "sig1" to see the issue.
//    //
//    // Given other oddities of UITextView on iOS 7, we had assumed this would be fixed along the way.
//    // Instead, we'll have to work up an isolated case and file a bug. We don't want to bake this kind
//    // of workaround into the SDK, so instead we provide an example here.
//    // If you have a better workaround suggestion, we'd love to hear it.
//    
//    func twiddleText(_ textView: UITextView)
//    {
//        let SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO = UIDevice.current.systemVersion
//        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO >= "7.0"
//        {
//            textView.textStorage.edited(NSTextStorageEditActions.editedCharacters,range:NSMakeRange(0, textView.textStorage.length),changeInLength:0)
//        }
//    }
//    
//    func textViewDidChange(_ textView: UITextView)
//    {
//        if snippetExpanded
//        {
//            usleep(10000)
//            twiddleText(textView)
//            
//            // performSelector(twiddleText:, withObject: textView, afterDelay:0.01)
//            snippetExpanded = false
//        }
//    }
//    
//    /*
//    // The following are the UITextViewDelegate methods; they simply write to the console log for demonstration purposes
//    
//    func textViewDidBeginEditing(textView: UITextView)
//    {
//    println("nextDelegate textViewDidBeginEditing")
//    }
//    func textViewShouldBeginEditing(textView: UITextView) -> Bool
//    {
//    println("nextDelegate textViewShouldBeginEditing")
//    return true
//    }
//    
//    func textViewShouldEndEditing(textView: UITextView) -> Bool
//    {
//    println("nextDelegate textViewShouldEndEditing")
//    return true
//    }
//    
//    func textViewDidEndEditing(textView: UITextView)
//    {
//    println("nextDelegate textViewDidEndEditing")
//    }
//    
//    func textViewDidChangeSelection(textView: UITextView)
//    {
//    println("nextDelegate textViewDidChangeSelection")
//    }
//    
//    // The following are the UITextFieldDelegate methods; they simply write to the console log for demonstration purposes
//    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldBeginEditing")
//    return true
//    }
//    
//    func textFieldDidBeginEditing(textField: UITextField)
//    {
//    println("nextDelegate textFieldDidBeginEditing")
//    }
//    
//    func textFieldShouldEndEditing(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldEndEditing")
//    return true
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField)
//    {
//    println("nextDelegate textFieldDidEndEditing")
//    }
//    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
//    {
//    println("nextDelegate textField:shouldChangeCharactersInRange: \(NSStringFromRange(range)) Original=\(textField.text), replacement = \(string)")
//    return true
//    }
//    
//    func textFieldShouldClear(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldClear")
//    return true
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldReturn")
//    return true
//    }
//    */
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
    
    @IBAction func btnRemove(_ sender: UIButton)
    {
        if btnRemove.currentTitle == "Remove"
        {
            notificationCenter.post(name: NotificationRemoveTaskContext, object: nil, userInfo:["itemNo":btnRemove.tag])
        }
    }
}
