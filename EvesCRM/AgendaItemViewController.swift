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

class agendaItemViewController: UIViewController, MyMeetingTaskDelegate
{
    var delegate: MyAgendaItemDelegate?

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
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
        
        if agendaItem.agendaID == ""
        {
            btnSave.setTitle("Save", forState: .Normal)
        }
        else
        {
            btnSave.setTitle("Update", forState: .Normal)
            
            btnStatus.setTitle(agendaItem.status, forState: .Normal)
            txtDecisionMade.text = agendaItem.decisionMade
            txtDiscussionNotes.text = agendaItem.discussionNotes
            txtTimeAllocation.text = "\(agendaItem.timeAllocation)"
            btnOwner.setTitle(agendaItem.owner, forState: .Normal)
            txtTitle.text = agendaItem.title
            
        }
        
        myPicker.hidden = true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        colActions.collectionViewLayout.invalidateLayout()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
   /*     var retVal: Int = 0
        
        if collectionView == colAttendees
        {
            retVal = event.attendees.count
        }
        
        if collectionView == colAgenda
        {
            retVal = 2
        }
        
        return retVal
*/
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
/*        var retVal: Int = 0
        
        if collectionView == colAttendees
        {
            retVal = 3
        }
        
        if collectionView == colAgenda
        {
            retVal = 4
        }

        return retVal
*/
    return 4
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell : myTaskItem!
 
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellTaskName, forIndexPath: indexPath) as! myTaskItem
        cell.lblTaskName.text = "Name"
        cell.lblTaskStatus.text = "Status"
        cell.lblTaskOwner.text = "Owner"
        cell.lblTaskTargetDate.text = "Target date"
        
        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = swiftColor
        }
        else
        {
            cell.backgroundColor = UIColor.clearColor()
        }
       
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
        }
        
        if pickerTarget == "Status"
        {
            btnStatus.setTitle(pickerOptions[row], forState: .Normal)
        }
        
        myPicker.hidden = true
        showFields()
    }

    @IBAction func btnBack(sender: UIButton)
    {
        delegate?.myAgendaItemDidFinish(self, actionType: "Cancel")
    }
    
    @IBAction func btnSave(sender: UIButton)
    {
        agendaItem.status = btnStatus.currentTitle!
        agendaItem.decisionMade = txtDecisionMade.text
        agendaItem.discussionNotes = txtDiscussionNotes.text
        agendaItem.timeAllocation = txtTimeAllocation.text.toInt()!
        agendaItem.owner = btnOwner.currentTitle!
        agendaItem.title = txtTitle.text

        if btnSave.currentTitle == "Save"
        {
            agendaItem.save(event.eventID)
        }
        else
        {
            // Perform update work
            agendaItem.update(event.eventID)
        }
        
        delegate?.myAgendaItemDidFinish(self, actionType: "Changed")
    }
    
    @IBAction func btnAddAction(sender: UIButton)
    {
        let taskViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("meetingTasks") as! meetingTaskViewController
        taskViewControl.delegate = self
 //       taskViewControl.event = event
 //       taskViewControl.actionType = actionType
        
 //       let newAgendaItem = meetingAgendaItem()
 //       taskViewControl.agendaItem = newAgendaItem
        
        self.presentViewController(taskViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnOwner(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
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
    
    func hideFields()
    {
        btnBack.hidden = true
        btnSave.hidden = true
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
        btnBack.hidden = false
        btnSave.hidden = false
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

    func myMeetingTaskDidFinish(controller:meetingTaskViewController, actionType: String)
    {
        if actionType == "Cancel"
        {
            // Do nothing.  Including for calrity
        }
        else
        {
            // reload the task Items collection view
        }
        
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
    
    @IBAction func btnAction(sender: UIButton)
    {
      //  if btnAction.currentTitle == "Update"
      //  {
      //      NSNotificationCenter.defaultCenter().postNotificationName("NotificationUpdateAgendaItem", object: nil, userInfo:["itemNo":btnAction.tag])
      //  }
    }
}
