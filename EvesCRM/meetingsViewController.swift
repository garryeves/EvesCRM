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

class meetingsViewController: UIViewController {

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
    @IBOutlet weak var txtAttendeeStatus: UITextField!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
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
        
        if event.attendees.count == 0
        {
            event.populateAttendeesFromInvite()
        }

        lblLocation.text = event.location
        lblStartTime.text = event.displayScheduledDate
        lblMeetingName.text = event.title
        myPicker.hidden = true
        
        event.loadAgenda()
        
        if event.chair != ""
        {
            btnChair.setTitle(event.chair, forState: .Normal)
        }
        
        if event.minutes != ""
        {
            btnMinutes.setTitle(event.minutes, forState: .Normal)
        }

        txtAttendeeStatus.text = "Added"
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
            retVal = event.attendees.count
        }
        
        if collectionView == colAgenda
        {
            retVal = 2
        }
        
        return retVal
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        var retVal: Int = 0
        
        if collectionView == colAttendees
        {
            retVal = 3
        }
        
        if collectionView == colAgenda
        {
            retVal = 4
        }
        
        return retVal
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell : MyDisplayCollectionViewCell!
    
        if collectionView == colAttendees
        {
            if indexPath.indexAtPosition(1) == 0
            {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAttendeeIdentifier, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
                cell.Label.text = event.attendees[indexPath.indexAtPosition(0)].name
            }
        
            if indexPath.indexAtPosition(1) == 1
            {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAttendeeStatusIdentifier, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
                cell.Label.text = event.attendees[indexPath.indexAtPosition(0)].status
            }
        
            if indexPath.indexAtPosition(1) == 2
            {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAttendeeAction, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
                cell.Label.text = "Remove"
            }
    
            cell.Label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
        
        if collectionView == colAgenda
        {
            if indexPath.indexAtPosition(1) == 0
            {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAgendaTime, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
                cell.Label.text = event.attendees[indexPath.indexAtPosition(0)].name
            }
            
            if indexPath.indexAtPosition(1) == 1
            {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAgendaTitle, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
                cell.Label.text = event.attendees[indexPath.indexAtPosition(0)].status
            }
            
            if indexPath.indexAtPosition(1) == 2
            {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAgendaOwner, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
                cell.Label.text = "Remove"
            }

            if indexPath.indexAtPosition(1) == 3
            {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAgendaAction, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
                cell.Label.text = "Remove"
            }

            cell.Label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
        
        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        if (indexPath.indexAtPosition(0) % 2 == 0)  // was .row
        {
            cell.backgroundColor = swiftColor
        }
        else
        {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    
    
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

    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        if collectionView == colAttendees
        {
            if indexPath.indexAtPosition(1) == 0
            {
                retVal = CGSize(width: 200, height: 40)
            }
            if indexPath.indexAtPosition(1) == 1
            {
                retVal = CGSize(width: 100, height: 40)
            }
            if indexPath.indexAtPosition(1) == 2
            {
                retVal = CGSize(width: 80, height: 40)
            }
        }
        
        
        if collectionView == colAgenda
        {
            if indexPath.indexAtPosition(1) == 0
            {
                retVal = CGSize(width: 100, height: 40)
            }
            if indexPath.indexAtPosition(1) == 1
            {
                retVal = CGSize(width: 200, height: 40)
            }
            if indexPath.indexAtPosition(1) == 2
            {
                let myWidth = colAgenda.bounds.size.width - 50 - 100 - 200 - 100
                
                retVal = CGSize(width: myWidth, height: 40)
            }
            if indexPath.indexAtPosition(1) == 3
            {
                retVal = CGSize(width: 100, height: 40)
            }
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
            event.addAttendee(txtAttendeeName.text, inEmailAddress: txtAttendeeEmail.text, inType: "Participant" , inStatus: txtAttendeeStatus.text)
            colAttendees.reloadData()
            
            event.saveAgenda()
            
            txtAttendeeName.text = ""
            txtAttendeeEmail.text = ""
        }
    }
    
    
    @IBAction func txtAttendeeStatus(sender: UITextField)
    {
        
        // need to display a picker here
    }
    
    @IBAction func btnAddAgendaItem(sender: UIButton)
    {
    
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
        txtAttendeeStatus.hidden = true
        lblName.hidden = true
        lblEmail.hidden = true
        lblStatus.hidden = true
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
        txtAttendeeStatus.hidden = false
        lblName.hidden = false
        lblEmail.hidden = false
        lblStatus.hidden = false
        btnPreviousMinutes.hidden = false
        lblPreviousMeeting.hidden = false
        lblAgendaItems.hidden = false
        colAgenda.hidden = false
        btnAddAgendaItem.hidden = false
        lblNextMeeting.hidden = false
        lnlNextMeetingDetails.hidden = false
        btnSave.hidden = false
    }
}


