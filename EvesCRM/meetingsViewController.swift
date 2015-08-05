//
//  meetingsViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 7/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MyMeetingsDelegate
{
    func myMeetingsDidFinish(controller:meetingsViewController)
    func myMeetingsAgendaDidFinish(controller:meetingAgendaViewController)

}

class meetingsViewController: UIViewController
{
    private var passedMeeting: MeetingModel!
    
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
    @IBOutlet weak var txtAttendeeName: UITextField!
    @IBOutlet weak var txtAttendeeEmail: UITextField!
    @IBOutlet weak var btnAddAttendee: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnPreviousMinutes: UIButton!
    @IBOutlet weak var lblPreviousMeeting: UILabel!
    @IBOutlet weak var lblNextMeeting: UILabel!
    @IBOutlet weak var lnlNextMeetingDetails: UILabel!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var btnSave: UIButton!
    
    private let reuseAttendeeIdentifier = "AttendeeCell"
    private let reuseAttendeeStatusIdentifier = "AttendeeStatusCell"
    private let reuseAttendeeAction = "AttendeeActionCell"
    
    private var pickerOptions: [String] = Array()
    private var pickerTarget: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        passedMeeting = (tabBarController as! meetingTabViewController).myPassedMeeting
        
        lblMeetingHead.text = passedMeeting.actionType
        
        lblLocation.text = passedMeeting.event.location
        lblStartTime.text = passedMeeting.event.displayScheduledDate
        lblMeetingName.text = passedMeeting.event.title
        myPicker.hidden = true
        
        passedMeeting.event.loadAgenda()

        if passedMeeting.event.chair != ""
        {
            btnChair.setTitle(passedMeeting.event.chair, forState: .Normal)
        }
        
        if passedMeeting.event.minutes != ""
        {
            btnMinutes.setTitle(passedMeeting.event.minutes, forState: .Normal)
        }
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "attendeeRemoved:", name:"NotificationAttendeeRemoved", object: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()

        colAttendees.collectionViewLayout.invalidateLayout()
        colAttendees.reloadData()
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
            passedMeeting.delegate.myMeetingsDidFinish(self)
        }
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
            passedMeeting.event.chair = pickerOptions[row]
        }

        if pickerTarget == "minutes"
        {
            btnMinutes.setTitle(pickerOptions[row], forState: .Normal)
            passedMeeting.event.minutes = pickerOptions[row]
        }

        myPicker.hidden = true
        showFields()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return passedMeeting.event.attendees.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell : myAttendeeDisplayItem!
            
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAttendeeIdentifier, forIndexPath: indexPath) as! myAttendeeDisplayItem
        cell.lblName.text = passedMeeting.event.attendees[indexPath.row].name
        cell.lblStatus.text = passedMeeting.event.attendees[indexPath.row].status
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
        
        cell.layoutSubviews()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {  // Leaving stub in here for use in other collections

    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var headerView:UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader
        {
            headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "attendeeHeader", forIndexPath: indexPath) as! UICollectionReusableView
        }
        
        return headerView
     }
    
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.size.width, height: 39)
    }
    
    @IBAction func btnChairClick(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        for attendee in passedMeeting.event.attendees
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
        for attendee in passedMeeting.event.attendees
        {
            pickerOptions.append(attendee.name)
        }
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "minutes"
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
            passedMeeting.event.addAttendee(txtAttendeeName.text, inEmailAddress: txtAttendeeEmail.text, inType: "Participant" , inStatus: "Added")
            colAttendees.reloadData()
            
            passedMeeting.event.saveAgenda()
            
            txtAttendeeName.text = ""
            txtAttendeeEmail.text = ""
        }
    }
    
    @IBAction func btnSaveClick(sender: UIButton)
    {
        passedMeeting.event.saveAgenda()
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
        txtAttendeeName.hidden = true
        txtAttendeeEmail.hidden = true
        btnAddAttendee.hidden = true
        lblName.hidden = true
        lblEmail.hidden = true
        btnPreviousMinutes.hidden = true
        lblPreviousMeeting.hidden = true
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
        txtAttendeeName.hidden = false
        txtAttendeeEmail.hidden = false
        btnAddAttendee.hidden = false
        lblName.hidden = false
        lblEmail.hidden = false
        btnPreviousMinutes.hidden = false
        lblPreviousMeeting.hidden = false
        lblNextMeeting.hidden = false
        lnlNextMeetingDetails.hidden = false
        btnSave.hidden = false
    }
    
    func attendeeRemoved(notification: NSNotification)
    {
        let itemToRemove = notification.userInfo!["itemNo"] as! Int
        
        passedMeeting.event.removeAttendee(itemToRemove)
        passedMeeting.event.saveAgenda()
        colAttendees.reloadData()
    }
}

class myAttendeeHeader: UICollectionReusableView
{
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblAction: UILabel!
    
}

class myAttendeeDisplayItem: UICollectionViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnAction: UIButton!

    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnAction(sender: UIButton)
    {
        if btnAction.currentTitle == "Remove"
        {
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationAttendeeRemoved", object: nil, userInfo:["itemNo":btnAction.tag])
        }
    }
}

