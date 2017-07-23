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

let NotificationRemoveTaskContext = Notification.Name("NotificationRemoveTaskContext")
class taskViewController: UIViewController,  UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate, UIPopoverPresentationControllerDelegate  //, SMTEFillDelegate
{
    var passedTask: task!
    var passedMeeting: calendarItem!
    var passedTaskType: String = "Task"
    
    @IBOutlet weak var lblTaskTitle: UILabel!
    @IBOutlet weak var lblTaskDescription: UILabel!
    @IBOutlet weak var lblTargetDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var txtTaskTitle: UITextField!
    @IBOutlet weak var txtTaskDescription: UITextView!
    @IBOutlet weak var btnTargetDate: UIButton!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblContexts: UILabel!
    @IBOutlet weak var btnStart: UIButton!
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
    @IBOutlet weak var lblrepeatEvery: UILabel!
    @IBOutlet weak var lblFromActivity: UILabel!
    @IBOutlet weak var txtRepeatInterval: UITextField!
    @IBOutlet weak var btnRepeatPeriod: UIButton!
    @IBOutlet weak var btnRepeatBase: UIButton!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var tblContexts: UITableView!
    
    fileprivate var myStartDate: Date!
    fileprivate var myDueDate: Date!
    fileprivate var myProjectID: Int = 0
    fileprivate var myProjectDetails: [project] = Array()
    fileprivate var kbHeight: CGFloat!
    fileprivate var constraintArray: [NSLayoutConstraint] = Array()
    
    fileprivate var displayList: [String] = Array()
    
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
        
        txtTaskDescription.layer.borderColor = UIColor.lightGray.cgColor
        txtTaskDescription.layer.borderWidth = 0.5
        txtTaskDescription.layer.cornerRadius = 5.0
        txtTaskDescription.layer.masksToBounds = true
        
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
            
            if passedMeeting != nil
            {
                lblEstTime.isHidden = true
                txtEstTime.isHidden = true
                btnEstTimeInterval.isHidden = true
                lblrepeatEvery.isHidden = true
                txtRepeatInterval.isHidden = true
                btnRepeatPeriod.isHidden = true
                lblFromActivity.isHidden = true
                btnRepeatBase.isHidden = true
                btnOwner.isHidden = true
            }
            
//            // TextExpander
//            textExpander = SMTEDelegateController()
//            txtTaskDescription.delegate = textExpander
//            txtTaskTitle.delegate = textExpander
//            txtNewContext.delegate = textExpander
//            textExpander.clientAppName = "EvesCRM"
//            textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
//            textExpander.fillDelegate = self
//            textExpander.nextDelegate = self
            myCurrentViewController = self
        }
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
         return passedTask.contexts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cellContext", for: indexPath) as! myContextItem
        
        cell.lblContext.text = passedTask.contexts[indexPath.row].name
        cell.btnRemove.setTitle("Remove", for: .normal)
         
        return cell
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
            displayList.removeAll(keepingCapacity: false)
            displayList.append("")
            if passedMeeting != nil
            {
                // Come in from a meeting so just show meeting attendees
                for attendee in passedMeeting.attendees
                {
                    displayList.append(attendee.name)
                }
            }
            else
            {
                // List from people table
                for attendee in people(teamID: currentUser.currentTeam!.teamID).people
                {
                    displayList.append(attendee.name)
                }
            }
            
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "owner"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
       
        for myItem in myTaskStatus
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "Status"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
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
        displayList.removeAll(keepingCapacity: false)
        
        for myItem in myTimeInterval
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "TimeInterval"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnPriority(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        for myItem in myTaskPriority
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "Priority"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnEnergy(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        for myItem in myTaskEnergy
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "Energy"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
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
            
            let myNewContext = context(contextName: txtNewContext.text!, teamID: currentUser.currentTeam!.teamID, contextType: "Garry - get the context type")
            
            setContext(myNewContext.contextID, contextType: myNewContext.contextType)
            lblNewContext.isHidden = true
            txtNewContext.isHidden = true
            btnNewContext.isHidden = true
            showFields()
        }
    }
    
    @IBAction func btnProject(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        myProjectDetails.removeAll(keepingCapacity: false)
        
        for myProject in projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true).projects
        {
            displayList.append(myProject.projectName)
            myProjectDetails.append(myProject)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "Project"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnUrgency(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        for myItem in myTaskUrgency
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "Urgency"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        switch source
        {
            case "Status":
                btnStatus.setTitle(displayList[selectedItem], for: .normal)
                passedTask.status = displayList[selectedItem]
            
            case "TimeInterval":
                btnEstTimeInterval.setTitle(displayList[selectedItem], for: .normal)
                passedTask.estimatedTimeType = displayList[selectedItem]
            
            case "Priority":
                btnPriority.setTitle(displayList[selectedItem], for: .normal)
                passedTask.priority = displayList[selectedItem]
            
            case "Energy":
                btnEnergy.setTitle(displayList[selectedItem], for: .normal)
                passedTask.energyLevel = displayList[selectedItem]
            
            case "Urgency":
                btnUrgency.setTitle(displayList[selectedItem], for: .normal)
                passedTask.urgency = displayList[selectedItem]
            
            case "Project":
                getProjectName(myProjectDetails[selectedItem].projectID)
                passedTask.projectID = myProjectDetails[selectedItem].projectID
            
            case "RepeatPeriod":
                passedTask.repeatType = displayList[selectedItem]
                btnRepeatPeriod.setTitle(passedTask.repeatType, for: .normal)
            
            case "RepeatBase":
                passedTask.repeatBase = displayList[selectedItem]
                btnRepeatBase.setTitle(passedTask.repeatBase, for: .normal)
            
            case "Context":
                let myNewContext = context(contextName: displayList[selectedItem], teamID: currentUser.currentTeam!.teamID, contextType: "Garry - get the context type")
                
                setContext(myNewContext.contextID, contextType: myNewContext.contextType)
            
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
            
            default:
                print("myPickerDidFinish selectedItem - unknown source = \(source)")
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        if source == "TargetDate"
        {
            setDisplayDate(btnTargetDate, targetDate: selectedDate)
            myDueDate = selectedDate
            passedTask.dueDate = myDueDate
        }
        else
        {
            setDisplayDate(btnStart, targetDate: selectedDate)
            myStartDate = selectedDate
            passedTask.startDate = myStartDate
        }
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
        if txtEstTime.text != nil
        {
            if txtEstTime.text != ""
            {
                passedTask.estimatedTime = Int(txtEstTime.text!)!
            }
        }
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
        if txtRepeatInterval.text != nil
        {
            if txtRepeatInterval.text != ""
            {
                passedTask.repeatInterval = Int(txtRepeatInterval.text!)!
            }
        }
    }
    
    @IBAction func btnrepeatPeriod(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        for myItem in myRepeatPeriods
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "RepeatPeriod"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnRepeatBase(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        for myItem in myRepeatBases
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "RepeatBase"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
    }
    
//    func changeViewHeight(_ viewName: UIView, newHeight: CGFloat)
//    {
////        viewName.frame = CGRectMake(
//////            viewName.frame.origin.x,
////            viewName.frame.origin.y,
////            viewName.frame.size.width,
////            newHeight
////        )
//    }
    
    func showKeyboardFields()
    {
        lblTargetDate.isHidden = false
        btnTargetDate.isHidden = false
        lblStart.isHidden = false
        btnStart.isHidden = false
        lblContexts.isHidden = false
        tblContexts.isHidden = false
        lblPriority.isHidden = false
        btnPriority.isHidden = false
        lblEnergy.isHidden = false
        btnEnergy.isHidden = false
        lblUrgency.isHidden = false
        btnUrgency.isHidden = false
        btnOwner.isHidden = false
        lblStatus.isHidden = false
        btnStatus.isHidden = false
        lblProject.isHidden = false
        btnProject.isHidden = false
    }
    
    func hideKeyboardFields()
    {
        lblTargetDate.isHidden = true
        btnTargetDate.isHidden = true
        lblStart.isHidden = true
        btnStart.isHidden = true
        lblContexts.isHidden = true
        tblContexts.isHidden = true
        lblPriority.isHidden = true
        btnPriority.isHidden = true
        lblEnergy.isHidden = true
        btnEnergy.isHidden = true
        lblUrgency.isHidden = true
        btnUrgency.isHidden = true
        btnOwner.isHidden = true
        lblStatus.isHidden = true
        btnStatus.isHidden = true
        lblProject.isHidden = true
        btnProject.isHidden = true
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
    
    func getProjectName(_ projectID: Int)
    {
        let tempProject = project(projectID: projectID, teamID: currentUser.currentTeam!.teamID)
        
        if tempProject.projectName == ""
        {
            btnProject.setTitle("Click to set", for: .normal)
            myProjectID = 0
        }
        else
        {
            btnProject.setTitle(tempProject.projectName, for: .normal)
            myProjectID = tempProject.projectID
        }
    }
    
    func setContext(_ contextID: Int, contextType: String)
    {
        passedTask.addContext(contextID, contextType: contextType)
        
        // Reload the collection data
        
        tblContexts.reloadData()
    }
    
    func removeTaskContext(_ notification: Notification)
    {
        let contextToRemove = notification.userInfo!["itemNo"] as! Int
        
        passedTask.removeContext(contextToRemove)
        
        // Reload the collection data
        
        tblContexts.reloadData()
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
                let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
                pickerView.modalPresentationStyle = .popover
                //      pickerView.isModalInPopover = true
                
                let popover = pickerView.popoverPresentationController!
                popover.delegate = self
                popover.sourceView = self.btnStart
                popover.sourceRect = self.btnStart.bounds
                popover.permittedArrowDirections = .any
                
                pickerView.source = "StartDate"
                pickerView.delegate = self
                if self.passedTask.startDate == getDefaultDate()
                {
                    pickerView.currentDate = Date()
                }
                else
                {
                    pickerView.currentDate = self.passedTask.startDate
                }
                pickerView.showTimes = true
                
                pickerView.preferredContentSize = CGSize(width: 400,height: 400)
                
                self.present(pickerView, animated: true, completion: nil)
            }
            else
            { // actionType = Due
                
                let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
                pickerView.modalPresentationStyle = .popover
                //      pickerView.isModalInPopover = true
                
                let popover = pickerView.popoverPresentationController!
                popover.delegate = self
                popover.sourceView = self.btnTargetDate
                popover.sourceRect = self.btnTargetDate.bounds
                popover.permittedArrowDirections = .any
                
                pickerView.source = "TargetDate"
                pickerView.delegate = self
                if self.passedTask.dueDate == getDefaultDate()
                {
                    pickerView.currentDate = Date()
                }
                else
                {
                    pickerView.currentDate = self.passedTask.dueDate
                }
                pickerView.showTimes = true
                
                pickerView.preferredContentSize = CGSize(width: 400,height: 400)
                
                self.present(pickerView, animated: true, completion: nil)
            }
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

    @IBAction func btnShare(_ sender: UIBarButtonItem)
    {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let activityViewController: UIActivityViewController = createActivityController()
            activityViewController.popoverPresentationController!.sourceView = self.view
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
    }
    
//    func keyboardWillShow(_ notification: Notification)
//    {
//        self.updateViewConstraints()
//    }
//    
//    func keyboardWillHide(_ notification: Notification)
//    {
//        self.updateViewConstraints()
//    }
//    
//    func animateTextField(_ up: Bool)
//    {
//        var boolActionMove = false
//        let movement = (up ? -kbHeight : kbHeight)
//
//        if txtTaskTitle.isFirstResponder
//        {
//            //  This is at the top, so we do not need to do anything
//            boolActionMove = true
//        }
//        else if txtRepeatInterval.isFirstResponder
//        {
//            boolActionMove = true
//        }
//        else if txtTaskDescription.isFirstResponder
//        {
//            boolActionMove = true
//        }
//        else if txtEstTime.isFirstResponder
//        {
//            boolActionMove = true
//        }
//        else if txtNewContext.isFirstResponder
//        {
//            boolActionMove = true
//        }
//        
//        if boolActionMove
//        {
//            UIView.animate(withDuration: 0.3, animations: {
//                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement!)
//                
//            })
//            
//            let myConstraints = [
//                "constraintContexts",
//                "constraintContexts1",
//                "constraintContexts2",
//                "constraintContexts3",
//                "constraintStart",
//                "constraintDue",
//                "constraintPriority",
//                "constraintUrgency",
//                "constraintEnergy",
//                "constraintContextTable",
//                "constraintOwner",
//                "constraintLabelStart",
//                "constraintLabelDue",
//                "constraintLabelPriority",
//                "constraintLabelUrgency",
//                "constraintLabelEnergy",
//                "constraintProjectButton1",
//                "constraintProjectButton2",
//                "constraintProjectButton3",
//                "constraintProjectButton4",
//                "constraintProjectButton5",
//                "constraintProjectButton6",
//                "constraintProjectDesc1",
//                "constraintProjectDesc2",
//                "constraintProjectDesc3"
//            ]
//            
//            if up
//            {
//                if constraintArray.count == 0
//                {
//                    // Populate the array
//                    for myItem in self.view.constraints
//                    {
//                        if myItem.identifier != nil
//                        {
//                            if myConstraints.contains(myItem.identifier!)
//                            {
//                                constraintArray.append(myItem)
//                            }
//                        }
//                    }
//                }
//                
//                NSLayoutConstraint.deactivate(constraintArray)
//                hideKeyboardFields()
//            }
//            else
//            {
//                showKeyboardFields()
//                NSLayoutConstraint.activate(constraintArray)
//            }
//        }
//    }

    @IBAction func btnSave(_ sender: UIBarButtonItem)
    {
        if txtTaskTitle.text != ""
        {
            passedTask.title = txtTaskTitle.text!
        }

        if txtTaskDescription.text != ""
        {
            passedTask.details = txtTaskDescription.text!
        }

        if txtEstTime.text != ""
        {
            passedTask.estimatedTime = Int(txtEstTime.text!)!
        }
        
        if txtRepeatInterval.text != ""
        {
            passedTask.repeatInterval = Int(txtRepeatInterval.text!)!
        }
        
        passedTask.save()
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

class myContextItem: UITableViewCell
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
