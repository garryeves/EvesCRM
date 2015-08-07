//
//  AgendaItemViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 17/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MyAgendaItemDelegate
{
    func myAgendaItemDidFinish(controller:agendaItemViewController, actionType: String)
}

class agendaItemViewController: UIViewController, MyTaskDelegate, UITextViewDelegate
{
    var delegate: MyAgendaItemDelegate?

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var lblTimeAllocation: UILabel!
    @IBOutlet weak var txtTimeAllocation: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var txtDiscussionNotes: UITextView!
    @IBOutlet weak var lblDecisionMade: UILabel!
    @IBOutlet weak var txtDecisionMade: UITextView!
    @IBOutlet weak var lblActions: UILabel!
    @IBOutlet weak var btnAddAction: UIButton!
    @IBOutlet weak var colActions: UICollectionView!
    @IBOutlet weak var myPicker: UIPickerView!
    
    private let cellTaskName = "cellTaskName"
    
    var event: myCalendarItem!
    var agendaItem: meetingAgendaItem!
    var actionType: String = ""
    
    private var pickerOptions: [String] = Array()
    private var pickerTarget: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if actionType == "Agenda"
        {
            txtDiscussionNotes.editable = false
            txtDecisionMade.editable = false
            btnAddAction.enabled = false
        }
        
        if agendaItem.agendaID != 0
        {
            btnStatus.setTitle(agendaItem.status, forState: .Normal)
            txtDecisionMade.text = agendaItem.decisionMade
            txtDiscussionNotes.text = agendaItem.discussionNotes
            txtTimeAllocation.text = "\(agendaItem.timeAllocation)"
            if agendaItem.owner == ""
            {
                btnOwner.setTitle("Select Item Owner", forState: .Normal)
            }
            else
            {
                btnOwner.setTitle(agendaItem.owner, forState: .Normal)
            }
            txtTitle.text = agendaItem.title
        }
        
        myPicker.hidden = true
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTask:", name:"NotificationUpdateAgendaTask", object: nil)
        
        txtDiscussionNotes.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtDiscussionNotes.layer.borderWidth = 0.5
        txtDiscussionNotes.layer.cornerRadius = 5.0
        txtDiscussionNotes.layer.masksToBounds = true
        txtDiscussionNotes.delegate = self
        
        txtDecisionMade.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtDecisionMade.layer.borderWidth = 0.5
        txtDecisionMade.layer.cornerRadius = 5.0
        txtDecisionMade.layer.masksToBounds = true
        txtDecisionMade.delegate = self
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        colActions.collectionViewLayout.invalidateLayout()
        
        colActions.reloadData()
    }

    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            delegate?.myAgendaItemDidFinish(self, actionType: "Cancel")
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return agendaItem.tasks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell : myTaskItem!
 
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellTaskName, forIndexPath: indexPath) as! myTaskItem

        if agendaItem.tasks.count == 0
        {
            cell.lblTaskName.text = ""
            cell.lblTaskStatus.text = ""
            cell.lblTaskOwner.text = ""
            cell.lblTaskTargetDate.text = ""
            cell.btnAction.setTitle("", forState: .Normal)
        }
        else
        {
            cell.lblTaskName.text = agendaItem.tasks[indexPath.row].title
            cell.lblTaskStatus.text = agendaItem.tasks[indexPath.row].status
            cell.lblTaskOwner.text = "Owner"
            cell.lblTaskTargetDate.text = agendaItem.tasks[indexPath.row].displayDueDate
            cell.btnAction.setTitle("Update", forState: .Normal)
            cell.btnAction.tag = agendaItem.tasks[indexPath.row].taskID
        }
        
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

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var headerView:UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader
        {
            headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "taskItemHeader", forIndexPath: indexPath) as! UICollectionReusableView
        }

        return headerView
    }
    
    /*
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if collectionView == colAttendees
        {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MyDisplayCollectionViewCell
            
            if indexPath.indexAtPosition(1) == 2
            {
                event.removeAttendee(indexPath.indexAtPosition(0))
                colAttendees.reloadData()
                event.saveAgenda()
            }
        }
        
        
        if collectionView == colAgenda
        {
            
        }
    }
*/
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colActions.bounds.size.width, height: 39)
        
        return retVal
    }

    func numberOfComponentsInPickerView(TableTypeSelection1: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerOptions[row]
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Write code for select
        if pickerTarget == "Owner"
        {
            btnOwner.setTitle(pickerOptions[row], forState: .Normal)
            agendaItem.owner = btnOwner.currentTitle!
        }
        
        if pickerTarget == "Status"
        {
            btnStatus.setTitle(pickerOptions[row], forState: .Normal)
            agendaItem.status = btnStatus.currentTitle!
        }
        
        myPicker.hidden = true
        showFields()
    }
    
    @IBAction func btnAddAction(sender: UIButton)
    {
        let taskViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("taskTab") as! tasksTabViewController
        
        var myPassedTask = TaskModel()
        myPassedTask.taskType = "minutes"
        let workingTask = task()
        myPassedTask.currentTask = workingTask
        myPassedTask.delegate = self
        myPassedTask.event = event
 
        taskViewControl.myPassedTask = myPassedTask
        
        self.presentViewController(taskViewControl, animated: true, completion: nil)
    }
    
    func updateTask(notification: NSNotification)
    {
        let itemToUpdate = notification.userInfo!["itemNo"] as! Int
        
        let taskViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("taskTab") as! tasksTabViewController
        
        var myPassedTask = TaskModel()
        myPassedTask.taskType = "minutes"
        let workingTask = task(inTaskID: itemToUpdate)
        myPassedTask.currentTask = workingTask
        myPassedTask.delegate = self
        myPassedTask.event = event
        
        taskViewControl.myPassedTask = myPassedTask
        
        self.presentViewController(taskViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnOwner(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)

        pickerOptions.append("")
        for attendee in event.attendees
        {
            pickerOptions.append(attendee.name)
        }
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Owner"
    }
    
    @IBAction func btnStatus(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("Open")
        pickerOptions.append("Closed")
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Status"
    }
    
    @IBAction func txtTitle(sender: UITextField)
    {
        if txtTitle.text != ""
        {
            agendaItem.title = txtTitle.text
        }
    }
    
    @IBAction func txtTimeAllocation(sender: UITextField)
    {
        agendaItem.timeAllocation = txtTimeAllocation.text.toInt()!
    }
    
    func textViewDidEndEditing(textView: UITextView)
    { //Handle the text changes here
        if textView == txtDiscussionNotes
        {
            agendaItem.discussionNotes = txtDiscussionNotes.text
        }
        if textView == txtDecisionMade
        {
            agendaItem.decisionMade = txtDecisionMade.text
        }

    }
    
    func hideFields()
    {
        lblDescription.hidden = true
        txtTitle.hidden = true
        lblOwner.hidden = true
        btnOwner.hidden = true
        lblTimeAllocation.hidden = true
        txtTimeAllocation.hidden = true
        lblStatus.hidden = true
        btnStatus.hidden = true
        lblNotes.hidden = true
        txtDiscussionNotes.hidden = true
        lblDecisionMade.hidden = true
        txtDecisionMade.hidden = true
        lblActions.hidden = true
        btnAddAction.hidden = true
        colActions.hidden = true
    }
    
    func showFields()
    {
        lblDescription.hidden = false
        txtTitle.hidden = false
        lblOwner.hidden = false
        btnOwner.hidden = false
        lblTimeAllocation.hidden = false
        txtTimeAllocation.hidden = false
        lblStatus.hidden = false
        btnStatus.hidden = false
        lblNotes.hidden = false
        txtDiscussionNotes.hidden = false
        lblDecisionMade.hidden = false
        txtDecisionMade.hidden = false
        lblActions.hidden = false
        btnAddAction.hidden = false
        colActions.hidden = false
    }

    func myTaskDidFinish(controller:taskViewController, actionType: String, currentTask: task)
    {
        // reload the task Items collection view
            
        // Associate the task with the meeting
            
        agendaItem.addTask(currentTask)
        colActions.reloadData()
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func myTaskUpdateDidFinish(controller:taskUpdatesViewController, actionType: String, currentTask: task)
    {
        colActions.reloadData()
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}

class myTaskItemHeader: UICollectionReusableView
{
    @IBOutlet weak var lblTaskStatus: UILabel!
    @IBOutlet weak var lblTaskTargetDate: UILabel!
    @IBOutlet weak var lblTaskOwner: UILabel!
    @IBOutlet weak var lblTaskName: UILabel!
    @IBOutlet weak var lblAction: UILabel!
}

class myTaskItem: UICollectionViewCell
{
    @IBOutlet weak var lblTaskStatus: UILabel!
    @IBOutlet weak var lblTaskTargetDate: UILabel!
    @IBOutlet weak var lblTaskOwner: UILabel!
    @IBOutlet weak var lblTaskName: UILabel!
    @IBOutlet weak var btnAction: UIButton!

    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnAction(sender: UIButton)
    {
        if btnAction.currentTitle == "Update"
        {
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationUpdateAgendaTask", object: nil, userInfo:["itemNo":btnAction.tag])
        }
    }
}
