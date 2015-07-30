//
//  meetingsViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 7/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MyMeetingsDelegate{
    func myMeetingsDidFinish(controller:meetingsViewController)
}

class meetingsViewController: UIViewController, MyAgendaItemDelegate
{

    var delegate: MyMeetingsDelegate?
    
    @IBOutlet weak var lblMeetingHead: UILabel!
    @IBOutlet weak var lblLocationHead: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblAT: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblMeetingName: UILabel!
    @IBOutlet weak var lblChairHead: UILabel!
    @IBOutlet weak var lblMinutesHead: UILabel!
    @IBOutlet weak var lblAttendeesHead: UILabel!
    @IBOutlet weak var colAttendees: UICollectionView!
    @IBOutlet weak var btnChair: UIButton!
    @IBOutlet weak var btnMinutes: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblAddAttendee: UILabel!
    @IBOutlet weak var txtAttendeeName: UITextField!
    @IBOutlet weak var txtAttendeeEmail: UITextField!
    @IBOutlet weak var btnAddAttendee: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnPreviousMinutes: UIButton!
    @IBOutlet weak var lblPreviousMeeting: UILabel!
    @IBOutlet weak var lblAgendaItems: UILabel!
    @IBOutlet weak var colAgenda: UICollectionView!
    @IBOutlet weak var btnAddAgendaItem: UIButton!
    @IBOutlet weak var lblNextMeeting: UILabel!
    @IBOutlet weak var lnlNextMeetingDetails: UILabel!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var btnSave: UIButton!
    
    var event: myCalendarItem!
    var actionType: String = ""
    
    private let reuseAttendeeIdentifier = "AttendeeCell"
    private let reuseAttendeeStatusIdentifier = "AttendeeStatusCell"
    private let reuseAttendeeAction = "AttendeeActionCell"
    
    private let reuseAgendaTime = "reuseAgendaTime"
    private let reuseAgendaTitle = "reuseAgendaTitle"
    private let reuseAgendaOwner = "reuseAgendaOwner"
    private let reuseAgendaAction = "reuseAgendaAction"
    private var pickerOptions: [String] = Array()
    private var pickerTarget: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        lblMeetingHead.text = actionType
        if actionType != "Agenda"
        {
            btnAddAgendaItem.hidden = true
        }
        
        lblLocation.text = event.location
        lblStartTime.text = event.displayScheduledDate
        lblMeetingName.text = event.title
        myPicker.hidden = true
        
        event.loadAgenda()
 println("Note = \(event.event.notes)")
 println("ID = \(event.eventID)")
        if event.chair != ""
        {
            btnChair.setTitle(event.chair, forState: .Normal)
        }
        
        if event.minutes != ""
        {
            btnMinutes.setTitle(event.minutes, forState: .Normal)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "attendeeRemoved:", name:"NotificationAttendeeRemoved", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAgendaItem:", name:"NotificationUpdateAgendaItem", object: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        colAgenda.collectionViewLayout.invalidateLayout()
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
        if pickerTarget == "chair"
        {
            btnChair.setTitle(pickerOptions[row], forState: .Normal)
            event.chair = pickerOptions[row]
        }

        if pickerTarget == "minutes"
        {
            btnMinutes.setTitle(pickerOptions[row], forState: .Normal)
            event.minutes = pickerOptions[row]
        }

        myPicker.hidden = true
        showFields()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        var retVal: Int = 0
        
        if collectionView == colAttendees
        {
            retVal = 1
        }
        
        if collectionView == colAgenda
        {
            retVal = 1
        }
        
        return retVal
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        var retVal: Int = 0
        
        if collectionView == colAttendees
        {
            retVal = event.attendees.count
        }
        
        if collectionView == colAgenda
        {
            retVal = event.agendaItems.count
        }
        
        return retVal
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if collectionView == colAttendees
        {
            var cell : myAttendeeDisplayItem!
            
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAttendeeIdentifier, forIndexPath: indexPath) as! myAttendeeDisplayItem
            cell.lblName.text = event.attendees[indexPath.row].name
            cell.lblStatus.text = event.attendees[indexPath.row].status
            cell.btnAction.setTitle("Remove", forState: .Normal)
            cell.btnAction.tag = indexPath.row
            
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
        else // collectionView == colAgenda
        {
            var cell: myAgendaItem!

            cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAgendaTime, forIndexPath: indexPath) as! myAgendaItem
            cell.lblTime.text = "\(event.agendaItems[indexPath.row].timeAllocation)"
            cell.lblItem.text = event.agendaItems[indexPath.row].title
            cell.lblOwner.text = event.agendaItems[indexPath.row].owner
            cell.btnAction.setTitle("Update", forState: .Normal)
            cell.btnAction.tag = indexPath.row

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
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {  // Leaving stub in here for use in other collections

    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var headerView:UICollectionReusableView!
        if collectionView == colAttendees
        {
            if kind == UICollectionElementKindSectionHeader
            {
                headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "attendeeHeader", forIndexPath: indexPath) as! UICollectionReusableView
            }
        }
        
        if collectionView == colAgenda
        {
            if kind == UICollectionElementKindSectionHeader
            {
                headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "agendaItemHeader", forIndexPath: indexPath) as! UICollectionReusableView
            }
        }
        return headerView
     }
    
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
    
        if collectionView == colAttendees
        {
            retVal = CGSize(width: 400, height: 39)
        }
    
        if collectionView == colAgenda
        {
            retVal = CGSize(width: colAgenda.bounds.size.width, height: 39)
        }
        
        return retVal
    }
    
    @IBAction func btnChairClick(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        for attendee in event.attendees
        {
            pickerOptions.append(attendee.name)
        }
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "chair"
    }
    
    @IBAction func btnMinutes(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        for attendee in event.attendees
        {
            pickerOptions.append(attendee.name)
        }
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "minutes"
    }
    
    @IBAction func btnBackClick(sender: UIButton)
    {
        delegate?.myMeetingsDidFinish(self)
    }
    
    @IBAction func btnAddAttendee(sender: UIButton)
    {
        if txtAttendeeName.text == ""
        {
            var alert = UIAlertController(title: "Agenda", message:
                "You need to enter the name of the attendee", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        }
        else
        {
            event.addAttendee(txtAttendeeName.text, inEmailAddress: txtAttendeeEmail.text, inType: "Participant" , inStatus: "Added")
            colAttendees.reloadData()
            
            event.saveAgenda()
            
            txtAttendeeName.text = ""
            txtAttendeeEmail.text = ""
        }
    }
    
    @IBAction func btnAddAgendaItem(sender: UIButton)
    {
        event.saveAgenda()
        let agendaViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("AgendaItems") as! agendaItemViewController
        agendaViewControl.delegate = self
        agendaViewControl.event = event
        agendaViewControl.actionType = actionType
        
        let newAgendaItem = meetingAgendaItem(inMeetingID: event.eventID)
        agendaViewControl.agendaItem = newAgendaItem
        
        self.presentViewController(agendaViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnSaveClick(sender: UIButton)
    {
        event.saveAgenda()
    }
    
    func hideFields()
    {
        lblMeetingHead.hidden = true
        lblLocationHead.hidden = true
        lblLocation.hidden = true
        lblAT.hidden = true
        lblStartTime.hidden = true
        lblMeetingName.hidden = true
        lblChairHead.hidden = true
        lblMinutesHead.hidden = true
        lblAttendeesHead.hidden = true
        colAttendees.hidden = true
        btnChair.hidden = true
        btnMinutes.hidden = true
        btnBack.hidden = true
        lblAddAttendee.hidden = true
        txtAttendeeName.hidden = true
        txtAttendeeEmail.hidden = true
        btnAddAttendee.hidden = true
        lblName.hidden = true
        lblEmail.hidden = true
        btnPreviousMinutes.hidden = true
        lblPreviousMeeting.hidden = true
        lblAgendaItems.hidden = true
        colAgenda.hidden = true
        btnAddAgendaItem.hidden = true
        lblNextMeeting.hidden = true
        lnlNextMeetingDetails.hidden = true
        btnSave.hidden = true
    }
    
    func showFields()
    {
        lblMeetingHead.hidden = false
        lblLocationHead.hidden = false
        lblLocation.hidden = false
        lblAT.hidden = false
        lblStartTime.hidden = false
        lblMeetingName.hidden = false
        lblChairHead.hidden = false
        lblMinutesHead.hidden = false
        lblAttendeesHead.hidden = false
        colAttendees.hidden = false
        btnChair.hidden = false
        btnMinutes.hidden = false
        btnBack.hidden = false
        lblAddAttendee.hidden = false
        txtAttendeeName.hidden = false
        txtAttendeeEmail.hidden = false
        btnAddAttendee.hidden = false
        lblName.hidden = false
        lblEmail.hidden = false
        btnPreviousMinutes.hidden = false
        lblPreviousMeeting.hidden = false
        lblAgendaItems.hidden = false
        colAgenda.hidden = false
        btnAddAgendaItem.hidden = false
        lblNextMeeting.hidden = false
        lnlNextMeetingDetails.hidden = false
        btnSave.hidden = false
    }
    
    func myAgendaItemDidFinish(controller:agendaItemViewController, actionType: String)
    {
        if actionType == "Cancel"
        {
            // Do nothing.  Including for calrity
        }
        else
        {
            // reload the Agenda Items collection view
            event.loadAgendaItems()
            colAgenda.reloadData()
            event.saveAgenda()
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func attendeeRemoved(notification: NSNotification)
    {
        let itemToRemove = notification.userInfo!["itemNo"] as! Int
        
        event.removeAttendee(itemToRemove)
        event.saveAgenda()
        colAttendees.reloadData()
    }
    
    func updateAgendaItem(notification: NSNotification)
    {
        event.saveAgenda()
        let itemToUpdate = notification.userInfo!["itemNo"] as! Int
        
        let agendaViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("AgendaItems") as! agendaItemViewController
        agendaViewControl.delegate = self
        agendaViewControl.event = event
        agendaViewControl.actionType = actionType
        
        let agendaItem = event.agendaItems[itemToUpdate]
        agendaViewControl.agendaItem = agendaItem
        
        self.presentViewController(agendaViewControl, animated: true, completion: nil)
    }
}

class myAttendeeHeader: UICollectionReusableView
{
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblAction: UILabel!
    
}

class myAgendaItemHeader: UICollectionReusableView
{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblAction: UILabel!
}

class myAgendaItem: UICollectionViewCell
{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    
    @IBAction func btnAction(sender: UIButton)
    {
        if btnAction.currentTitle == "Update"
        {
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationUpdateAgendaItem", object: nil, userInfo:["itemNo":btnAction.tag])
        }
    }
}

class myAttendeeDisplayItem: UICollectionViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    
    @IBAction func btnAction(sender: UIButton)
    {
        if btnAction.currentTitle == "Remove"
        {
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationAttendeeRemoved", object: nil, userInfo:["itemNo":btnAction.tag])
        }
    }
}

