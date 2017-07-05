//
//  meetingsViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 7/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
import EventKit
//import TextExpander

protocol MyMeetingsDelegate
{
    func myMeetingsDidFinish(_ controller:meetingsViewController)
    func myMeetingsAgendaDidFinish(_ controller:meetingAgendaViewController)
}

protocol meetingCommunicationDelegate
{
    func meetingUpdated()
    func callMeetingAgenda(_ meetingRecord: calendarItem)
    func displayTaskList(_ meetingRecord: calendarItem)
}

class meetingsViewController: UIViewController, MyMeetingsDelegate //, SMTEFillDelegate
{
    var passedMeeting: calendarItem!
    var meetingCommunication: meetingCommunicationDelegate!
    var meetingsDelegate: MyMeetingsDelegate!
    var actionType: String!
    
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
    @IBOutlet weak var btnNextMeeting: UIButton!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnHead: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var btnDisplayPreviousMeeting: UIButton!
    @IBOutlet weak var btnDisplayNextMeeting: UIButton!
    @IBOutlet weak var btnAgenda: UIButton!
    @IBOutlet weak var btnCompleted: UIButton!
    
    fileprivate let reuseAttendeeIdentifier = "AttendeeCell"
    fileprivate let reuseAttendeeStatusIdentifier = "AttendeeStatusCell"
    fileprivate let reuseAttendeeAction = "AttendeeActionCell"
    
    fileprivate var pickerOptions: [String] = Array()
    fileprivate var pickerEventArray: [String] = Array()
    fileprivate var pickerStartDateArray: [Date] = Array()
    fileprivate var pickerTarget: String = ""
    fileprivate var mySelectedRow: Int = 0
    fileprivate var rowToAction: Int = 0

//    // Textexpander
//    
//    fileprivate var snippetExpanded: Bool = false
//    
//    var textExpander: SMTEDelegateController!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        toolbar.isTranslucent = false
        
//        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
//            target: self, action: nil)
//
//        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share(_:)))
//
//        if passedMeetingModel != nil
//        {
//            let pageHead = UIBarButtonItem(title: passedMeetingModel.actionType, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doNothing))
//            pageHead.tintColor = UIColor.black
//            let spacer2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
//                                          target: self, action: nil)
//            self.toolbar.items=[spacer,pageHead, spacer2, share]
//        }
//        else
//        {
//            let spacer2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
//                target: self, action: nil)
//            self.toolbar.items=[spacer, spacer2, share]
//        }
        lblLocation.text = passedMeeting.location
        lblStartTime.text = passedMeeting.displayScheduledDate
        lblMeetingName.text = passedMeeting.title
        myPicker.isHidden = true
        btnSelect.isHidden = true
        
 //       passedMeeting.loadAgenda()
        
        if passedMeeting.chair != ""
        {
            btnChair.setTitle(passedMeeting.chair, for: .normal)
        }
        
        if passedMeeting.minutes != ""
        {
            btnMinutes.setTitle(passedMeeting.minutes, for: .normal)
        }

        if passedMeeting.previousMinutes != ""
        {
            // Get the previous meetings details

            let myItems = myDatabaseConnection.loadAgenda(passedMeeting.previousMinutes, teamID: currentUser.currentTeam!.teamID)
           
            for myItem in myItems
            {
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
            
                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
            
                btnPreviousMinutes.setTitle(myDisplayString, for: .normal)
            }
        }

        if passedMeeting.nextMeeting != ""
        {
            // Get the previous meetings details
            
            let myItems = myDatabaseConnection.loadAgenda(passedMeeting.nextMeeting, teamID: currentUser.currentTeam!.teamID)
            
            for myItem in myItems
            {
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                
                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                
                btnNextMeeting.setTitle(myDisplayString, for: .normal)
            }
        }
        
        if passedMeeting.previousMinutes != ""
        {
            btnDisplayPreviousMeeting.isHidden = false
        }
        else
        {
            btnDisplayPreviousMeeting.isHidden = true
        }
        
        if passedMeeting.nextMeeting != ""
        {
            btnDisplayNextMeeting.isHidden = false
        }
        else
        {
            btnDisplayNextMeeting.isHidden = true
        }
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        notificationCenter.addObserver(self, selector: #selector(self.attendeeRemoved(_:)), name: NotificationAttendeeRemoved, object: nil)

//        // TextExpander
//        textExpander = SMTEDelegateController()
//        txtAttendeeName.delegate = textExpander
//        txtAttendeeEmail.delegate = textExpander
//        textExpander.clientAppName = "EvesCRM"
//        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
//        textExpander.fillDelegate = self
//        textExpander.nextDelegate = self
        myCurrentViewController = self
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
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
        {
           // Move to next item in tab hierarchy
            
            let myCurrentTab = self.tabBarController
            
            myCurrentTab!.selectedIndex = myCurrentTab!.selectedIndex + 1
        }
        else
        {
            if meetingsDelegate != nil
            {
                meetingsDelegate.myMeetingsDidFinish(self)
            }
        }
    }
    
    func numberOfComponentsInPickerView(_ Picker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ Picker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(_ Picker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerOptions[row]
    }
    
    func pickerView(_ Picker: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Write code for select

        mySelectedRow = row
    }
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return passedMeeting.attendees.count
    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell : myAttendeeDisplayItem!
            
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseAttendeeIdentifier, for: indexPath as IndexPath) as! myAttendeeDisplayItem
        cell.lblName.text = passedMeeting.attendees[indexPath.row].name
        cell.lblStatus.text = passedMeeting.attendees[indexPath.row].status
        if actionType != nil
        {
            if actionType == "Agenda"
            {
                cell.btnAction.setTitle("Remove", for: .normal)
            }
            else
            {
                cell.btnAction.setTitle("Record Attendence", for: .normal)
            }
        }
        
        cell.btnAction.tag = indexPath.row
            
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = greenColour
        }
        else
        {
            cell.backgroundColor = UIColor.clear
        }
        
        cell.layoutSubviews()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath)
    {  // Leaving stub in here for use in other collections

    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var headerView:UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader
        {
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "attendeeHeader", for: indexPath as IndexPath) 
        }
        
        return headerView
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.size.width, height: 39)
    }
    
    @IBAction func btnChairClick(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        for attendee in passedMeeting.attendees
        {
            pickerOptions.append(attendee.name)
        }
        hideFields()
        myPicker.isHidden = false
        btnSelect.isHidden = false
        btnSelect.setTitle("Set Chairperson", for: .normal)
        myPicker.reloadAllComponents()
        pickerTarget = "chair"
    }
    
    @IBAction func btnMinutes(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        for attendee in passedMeeting.attendees
        {
            pickerOptions.append(attendee.name)
        }
        hideFields()
        myPicker.isHidden = false
        btnSelect.setTitle("Set Minutes taker", for: .normal)
        btnSelect.isHidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "minutes"
    }
    
    @IBAction func btnAddAttendee(_ sender: UIButton)
    {
        if txtAttendeeName.text == ""
        {
            let alert = UIAlertController(title: "Agenda", message:
                "You need to enter the name of the attendee", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        }
        else
        {
            passedMeeting.addAttendee(txtAttendeeName.text!, emailAddress: txtAttendeeEmail.text!, type: "Participant" , status: "Added")
            colAttendees.reloadData()
        
            txtAttendeeName.text = ""
            txtAttendeeEmail.text = ""
        }
    }
    
    @IBAction func btnPreviousMinutes(_ sender: UIButton)
    {
        getPreviousMeeting()
    }
    
    @IBAction func btnNextMeeting(_ sender: UIButton)
    {
        getNextMeeting()
    }
    
    @IBAction func btnSelect(_ sender: UIButton)
    {
        if pickerOptions.count > 0
        {
            if pickerTarget == "chair"
            {
                btnChair.setTitle(pickerOptions[mySelectedRow], for: .normal)
                passedMeeting.chair = pickerOptions[mySelectedRow]
            }
        
            if pickerTarget == "minutes"
            {
                btnMinutes.setTitle(pickerOptions[mySelectedRow], for: .normal)
                passedMeeting.minutes = pickerOptions[mySelectedRow]
            }
        
            if pickerTarget == "previousMeeting"
            {
                // Check to see if an existing meeting already has this previos ID
            
                let myItems = myDatabaseConnection.loadPreviousAgenda(pickerEventArray[mySelectedRow], teamID: currentUser.currentTeam!.teamID)
            
                if myItems.count > 0
                { // Existing meeting found
                    for myItem in myItems
                    {
                        let startDateFormatter = DateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                    
                        let calendarOption: UIAlertController = UIAlertController(title: "Existing meeting found", message: "A meeting \(myItem.name!) - \(myDisplayDate) has this set as previous meeting.  Do you want to continue, which will clear the previous meeting from the original meeting?  ", preferredStyle: .actionSheet)
                    
                        let myYes = UIAlertAction(title: "Yes, update the details", style: .default, handler: { (action: UIAlertAction) -> () in
                            // go and update the previous meeting
                        
                            myDatabaseConnection.updatePreviousAgendaID("", meetingID: myItem.meetingID!, teamID: currentUser.currentTeam!.teamID)
                        
                            self.passedMeeting.previousMinutes = self.pickerEventArray[self.mySelectedRow]
                        
                            if self.passedMeeting.previousMinutes != ""
                            {
                                // Get the previous meetings details
                            
                                let myDisplayItems = myDatabaseConnection.loadAgenda(self.passedMeeting.previousMinutes, teamID: currentUser.currentTeam!.teamID)
                            
                                for myDisplayItem in myDisplayItems
                                {
                                    let startDateFormatter = DateFormatter()
                                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                    let myDisplayDate = startDateFormatter.string(from: myDisplayItem.startTime! as Date)
                                
                                    let myDisplayString = "\(myDisplayItem.name!) - \(myDisplayDate)"
                                
                                    self.btnPreviousMinutes.setTitle(myDisplayString, for: .normal)
                                    self.btnDisplayPreviousMeeting.isHidden = false
                                }
                            }
                        })
                    
                        let myNo = UIAlertAction(title: "No, leave the existing details", style: .default, handler: { (action: UIAlertAction) -> () in
                            // do nothing
                        })
                    
                        calendarOption.addAction(myYes)
                        calendarOption.addAction(myNo)
                    
                        calendarOption.popoverPresentationController?.sourceView = self.view
                        calendarOption.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2.0, y: self.view.bounds.height / 2.0, width: 1.0, height: 1.0)
                    
                        self.present(calendarOption, animated: true, completion: nil)
                    }
                }
                else
                {
                    passedMeeting.previousMinutes = pickerEventArray[mySelectedRow]
                
                    if passedMeeting.previousMinutes != ""
                    {
                        // Get the previous meetings details
                    
                        let myDisplayItems = myDatabaseConnection.loadAgenda(passedMeeting.previousMinutes, teamID: currentUser.currentTeam!.teamID)
                    
                        for myDisplayItem in myDisplayItems
                        {
                            let startDateFormatter = DateFormatter()
                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                            let myDisplayDate = startDateFormatter.string(from: myDisplayItem.startTime! as Date)
                        
                            let myDisplayString = "\(myDisplayItem.name!) - \(myDisplayDate)"
                        
                            btnPreviousMinutes.setTitle(myDisplayString, for: .normal)
                            
                            btnDisplayPreviousMeeting.isHidden = false
                        }
                    }
                }
            }
        
            if pickerTarget == "nextMeeting"
            {
                var nextCalItem: calendarItem!
                // Check to see if an existing meeting already has this previos ID
            
                let myItems = myDatabaseConnection.loadAgenda(pickerEventArray[mySelectedRow], teamID: currentUser.currentTeam!.teamID)
            
                if myItems.count > 0
                {
                    for myItem in myItems
                    {
                        if myItem.previousMeetingID != ""
                        {
                            let startDateFormatter = DateFormatter()
                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                            let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                            let calendarOption: UIAlertController = UIAlertController(title: "Existing meeting found", message: "A meeting \(myItem.name!) - \(myDisplayDate) has this set as next meeting.  Do you want to continue, which will clear the next meeting from the original meeting?  ", preferredStyle: .actionSheet)
                        
                            let myYes = UIAlertAction(title: "Yes, update the details", style: .default, handler: { (action: UIAlertAction) -> () in
                            // go and update the previous meeting
                            
                                let myOriginalNextMeeting = self.passedMeeting.nextMeeting
                            
                                myDatabaseConnection.updatePreviousAgendaID("", meetingID: myOriginalNextMeeting, teamID: currentUser.currentTeam!.teamID)
                            
                                if self.pickerEventArray[self.mySelectedRow] != ""
                                {
                                    // Is there a database entry for the next meeting
                                    
                                    let myMeetingCheck = myDatabaseConnection.loadAgenda(self.pickerEventArray[self.mySelectedRow], teamID: currentUser.currentTeam!.teamID)
                                    
                                    if myMeetingCheck.count == 0
                                    { // No meeting found, so need to create
                                        let nextEvent = topCalendar()
                                        
                                        nextEvent.loadCalendarForEvent(self.pickerEventArray[self.mySelectedRow], startDate: self.pickerStartDateArray[self.mySelectedRow], teamID: currentUser.currentTeam!.teamID)
                                        
                                        nextCalItem = nextEvent.appointments[0].databaseItem
                                    }
                                    else
                                    { // meeting found use it
                                        nextCalItem = calendarItem( meetingAgenda: myMeetingCheck[0])
                                    }
                                    
                                    // Get the previous meetings details
                                    
                                    self.passedMeeting.setNextMeeting(nextCalItem)

                                    let myItems = myDatabaseConnection.loadAgenda(self.passedMeeting.nextMeeting, teamID: currentUser.currentTeam!.teamID)
                                    
                                    for myItem in myItems
                                    {
                                        let startDateFormatter = DateFormatter()
                                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                                    
                                        let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                                    
                                        self.btnNextMeeting.setTitle(myDisplayString, for: .normal)
                                        
                                        self.btnDisplayNextMeeting.isHidden = false

                                    }
                                }
                                else
                                {
                                    self.passedMeeting.nextMeeting = self.pickerEventArray[self.mySelectedRow]
                                }
                            })
                        
                            let myNo = UIAlertAction(title: "No, leave the existing details", style: .default, handler: { (action: UIAlertAction) -> () in
                                // do nothing
                            })
                        
                            calendarOption.addAction(myYes)
                            calendarOption.addAction(myNo)
                        
                            calendarOption.popoverPresentationController?.sourceView = self.view
                            calendarOption.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2.0, y: self.view.bounds.height / 2.0, width: 1.0, height: 1.0)
                        
                            self.present(calendarOption, animated: true, completion: nil)
                        }
                        else
                        {
                            let myOriginalNextMeeting = passedMeeting.nextMeeting
                        
                            myDatabaseConnection.updatePreviousAgendaID("", meetingID: myOriginalNextMeeting, teamID: currentUser.currentTeam!.teamID)

                            if pickerEventArray[mySelectedRow] != ""
                            {
                                // Is there a database entry for the next meeting
                                
                                let myMeetingCheck = myDatabaseConnection.loadAgenda(pickerEventArray[mySelectedRow], teamID: currentUser.currentTeam!.teamID)
                                
                                if myMeetingCheck.count == 0
                                { // No meeting found, so need to create
                                    let nextEvent = topCalendar()
                                    
                                    nextEvent.loadCalendarForEvent(pickerEventArray[mySelectedRow], startDate: pickerStartDateArray[mySelectedRow], teamID: currentUser.currentTeam!.teamID)
                                    
                                    nextCalItem = nextEvent.appointments[0].databaseItem
                                }
                                else
                                { // meeting found use it
                                    nextCalItem = calendarItem(meetingAgenda: myMeetingCheck[0])
                                }
                                
                                // Get the previous meetings details
                                
                                passedMeeting.setNextMeeting(nextCalItem)
                            
                                let myItems = myDatabaseConnection.loadAgenda(passedMeeting.nextMeeting, teamID: currentUser.currentTeam!.teamID)
                            
                                for myItem in myItems
                                {
                                    let startDateFormatter = DateFormatter()
                                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                    let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                                
                                    let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                                
                                    btnNextMeeting.setTitle(myDisplayString, for: .normal)
                                    btnDisplayNextMeeting.isHidden = false
                                }
                            }
                            else
                            {
                                passedMeeting.nextMeeting = pickerEventArray[mySelectedRow]
                            }
                        }
                    }
                }
                else
                {
                    if pickerEventArray[mySelectedRow] != ""
                    {
                        let myOriginalNextMeeting = self.passedMeeting.nextMeeting
                
                        myDatabaseConnection.updatePreviousAgendaID("", meetingID: myOriginalNextMeeting, teamID: currentUser.currentTeam!.teamID)

                        // Is there a database entry for the next meeting
         
                        let myMeetingCheck = myDatabaseConnection.loadAgenda(pickerEventArray[mySelectedRow], teamID: currentUser.currentTeam!.teamID)
                        
                        if myMeetingCheck.count == 0
                        { // No meeting found, so need to create
                            let nextEvent = topCalendar()
                        
                            nextEvent.loadCalendarForEvent(pickerEventArray[mySelectedRow], startDate: pickerStartDateArray[mySelectedRow], teamID: currentUser.currentTeam!.teamID)
                        
                            nextCalItem = nextEvent.appointments[0].databaseItem
                        }
                        else
                        { // meeting found use it
                            nextCalItem = calendarItem(meetingAgenda: myMeetingCheck[0])
                        }

                        // Get the previous meetings details
                        
                        passedMeeting.setNextMeeting(nextCalItem)
                        
                        let myItems = myDatabaseConnection.loadAgenda(passedMeeting.nextMeeting, teamID: currentUser.currentTeam!.teamID)
                    
                        for myItem in myItems
                        {
                            let startDateFormatter = DateFormatter()
                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                            let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                            let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                        
                            btnNextMeeting.setTitle(myDisplayString, for: .normal)
                        }
                    }
                    else
                    {
                        passedMeeting.nextMeeting = pickerEventArray[mySelectedRow]
                    }
                }
            }
        }
        
        if pickerTarget == "attendence"
        {
            
            passedMeeting.attendees[rowToAction].status = pickerOptions[mySelectedRow]
            passedMeeting.attendees[rowToAction].save()
            
            passedMeeting.loadAttendees()
            
            colAttendees.reloadData()

            rowToAction = 0
        }

        myPicker.isHidden = true
        btnSelect.isHidden = true
        showFields()
    }
    
    @IBAction func btnDisplayPreviousMeeting(_ sender: UIButton)
    {
//        let meetingViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "MeetingsTab") as! meetingTabViewController
print("gaza check this btnDisplayPreviousMeeting")
//        let targetPassedMeeting = MeetingModel()
//        if passedMeetingModel != nil
//        {
//            targetPassedMeeting.actionType = passedMeetingModel.actionType
//        }
//
//        let myItems = myDatabaseConnection.loadAgenda(passedMeeting.previousMinutes, teamID: currentUser.currentTeam!.teamID)
//
//        if myItems.count == 0
//        {
//            let alert = UIAlertController(title: "Meeting", message:
//                "Can not retrieve details for previous meeting", preferredStyle: UIAlertControllerStyle.alert)
//
//            self.present(alert, animated: false, completion: nil)
//
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
//        }
//        else
//        {
//            for _ in myItems
//            {
//                let tempMeeting = calendarItem(meetingID: passedMeeting.previousMinutes, teamID: currentUser.currentTeam!.teamID)
//                tempMeeting.loadAgenda()
//                targetPassedMeeting.event = tempMeeting
//            }
//        }
//        targetPassedMeeting.delegate = self
//
//        meetingViewControl.myPassedMeeting = targetPassedMeeting
//
//        self.present(meetingViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnDisplayNextMeeting(_ sender: UIButton)
    {
//        let meetingViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "MeetingsTab") as! meetingTabViewController
print("gaza check this btnDisplayNextMeeting")
//        let targetPassedMeeting = MeetingModel()
//        if passedMeetingModel != nil
//        {
//            targetPassedMeeting.actionType = passedMeetingModel.actionType
//        }
//        let myItems = myDatabaseConnection.loadAgenda(passedMeeting.nextMeeting, teamID: currentUser.currentTeam!.teamID)
//        
//        if myItems.count == 0
//        {
//            let alert = UIAlertController(title: "Meeting", message:
//                "Can not retrieve details for next meeting", preferredStyle: UIAlertControllerStyle.alert)
//            
//            self.present(alert, animated: false, completion: nil)
//            
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
//        }
//        else
//        {
//            for _ in myItems
//            {
//                let tempMeeting = calendarItem(meetingID: passedMeeting.nextMeeting, teamID: currentUser.currentTeam!.teamID)
//                tempMeeting.loadAgenda()
//                targetPassedMeeting.event = tempMeeting
//            }
//        }
//        targetPassedMeeting.delegate = self
//        
//        meetingViewControl.myPassedMeeting = targetPassedMeeting
//        
//        self.present(meetingViewControl, animated: true, completion: nil)
    }
    
    func hideFields()
    {
        lblMeetingHead.isHidden = true
        lblLocationHead.isHidden = true
        lblLocation.isHidden = true
        lblAT.isHidden = true
        lblStartTime.isHidden = true
        lblMeetingName.isHidden = true
        lblChairHead.isHidden = true
        lblMinutesHead.isHidden = true
        lblAttendeesHead.isHidden = true
        colAttendees.isHidden = true
        btnChair.isHidden = true
        btnMinutes.isHidden = true
        txtAttendeeName.isHidden = true
        txtAttendeeEmail.isHidden = true
        btnAddAttendee.isHidden = true
        lblName.isHidden = true
        lblEmail.isHidden = true
        btnPreviousMinutes.isHidden = true
        lblPreviousMeeting.isHidden = true
        lblNextMeeting.isHidden = true
        btnNextMeeting.isHidden = true
        btnDisplayPreviousMeeting.isHidden = true
        btnDisplayNextMeeting.isHidden = true
        if meetingCommunication == nil
        {
            btnAgenda.isHidden = true
        }
        btnCompleted.isHidden = true
    }
    
    func showFields()
    {
        lblMeetingHead.isHidden = false
        lblLocationHead.isHidden = false
        lblLocation.isHidden = false
        lblAT.isHidden = false
        lblStartTime.isHidden = false
        lblMeetingName.isHidden = false
        lblChairHead.isHidden = false
        lblMinutesHead.isHidden = false
        lblAttendeesHead.isHidden = false
        colAttendees.isHidden = false
        btnChair.isHidden = false
        btnMinutes.isHidden = false
        txtAttendeeName.isHidden = false
        txtAttendeeEmail.isHidden = false
        btnAddAttendee.isHidden = false
        lblName.isHidden = false
        lblEmail.isHidden = false
        btnPreviousMinutes.isHidden = false
        lblPreviousMeeting.isHidden = false
        lblNextMeeting.isHidden = false
        btnNextMeeting.isHidden = false
        if passedMeeting.previousMinutes != ""
        {
            btnDisplayPreviousMeeting.isHidden = false
        }
        else
        {
            btnDisplayPreviousMeeting.isHidden = true
        }
        
        if passedMeeting.nextMeeting != ""
        {
            btnDisplayNextMeeting.isHidden = false
        }
        else
        {
            btnDisplayNextMeeting.isHidden = true
        }
        if meetingCommunication == nil
        {
            btnAgenda.isHidden = false
        }
        
print("gaza put an if here once we are storeing and retrieveing this")
        btnCompleted.isHidden = false
    }
    
    func attendeeRemoved(_ notification: Notification)
    {
        let action = notification.userInfo!["Action"] as! String
        let itemToRemove = notification.userInfo!["itemNo"] as! Int
        
        if action == "Remove"
        {
            passedMeeting.removeAttendee(itemToRemove)
            colAttendees.reloadData()
        }
        else
        {
            pickerOptions.removeAll()
            
            for myItem in myAttendenceStatus
            {
                pickerOptions.append(myItem)
            }
            
            hideFields()
            myPicker.isHidden = false
            btnSelect.setTitle("Set Attendence", for: .normal)
            btnSelect.isHidden = false
            myPicker.reloadAllComponents()
            pickerTarget = "attendence"
            rowToAction = itemToRemove
        }
    }

    func getPreviousMeeting()
    {
        // We only list items here that we have Meeting records for, as otherwise there is no previous actions to get and display
        
        // if a recurring meeting invite then display previous occurances at the top of the list
        
        pickerOptions.removeAll(keepingCapacity: false)
        pickerEventArray.removeAll(keepingCapacity: false)
        pickerStartDateArray.removeAll(keepingCapacity: false)
        
        if passedMeeting.event!.recurrenceRules != nil
        {
            // Recurring event, so display rucurrences first
         
            // get the meeting id, and remove the trailing portion in order to use in a search
            
            let myItems = myDatabaseConnection.searchPastAgendaByPartialMeetingIDBeforeStart(passedMeeting.meetingID, meetingStartDate: passedMeeting.startDate as NSDate, teamID: currentUser.currentTeam!.teamID)

            if myItems.count > 0
            { // There is an previous meeting
                for myItem in myItems
                {
                    if myItem.meetingID != passedMeeting.meetingID
                    { // Not this meeting meeting
                        let startDateFormatter = DateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                        pickerOptions.append("\(myItem.name!) - \(myDisplayDate)")
                        pickerEventArray.append(myItem.meetingID!)
                        pickerStartDateArray.append(myItem.startTime! as Date)
                    }
                }
            }
            
            // display remaining items, newest first

            let myNonItems = myDatabaseConnection.searchPastAgendaWithoutPartialMeetingIDBeforeStart(passedMeeting.meetingID, meetingStartDate: passedMeeting.startDate as NSDate, teamID: currentUser.currentTeam!.teamID)
            
            if myNonItems.count > 0
            { // There is an previous meeting
                for myItem in myNonItems
                {
                    if myItem.meetingID != passedMeeting.meetingID
                    { // Not this meeting meeting
                        let startDateFormatter = DateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                        pickerOptions.append("\(myItem.name!) - \(myDisplayDate)")
                        pickerEventArray.append(myItem.meetingID!)
                        pickerStartDateArray.append(myItem.startTime! as Date)
                    }
                }
            }
            
            // Next meeting could also be a non entry so need to show calendar items as well
        }
        else
        {
            //non-recurring event, so display in date order, newest first
            
            // list items prior to meeting date
            
            let myItems = myDatabaseConnection.listAgendaReverseDateAfterStart(passedMeeting.startDate as NSDate, teamID: currentUser.currentTeam!.teamID)
            
            if myItems.count > 0
            { // There is an previous meeting
                for myItem in myItems
                {
                    if myItem.meetingID != passedMeeting.meetingID
                    { // Not this meeting meeting
                        let startDateFormatter = DateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                        pickerOptions.append("\(myItem.name!) - \(myDisplayDate)")
                        pickerEventArray.append(myItem.meetingID!)
                        pickerStartDateArray.append(myItem.startTime! as Date)
                    }
                }
            }
        }
        
        if pickerOptions.count > 0
        {
            hideFields()
            myPicker.isHidden = false
            btnSelect.setTitle("Set previous meeting", for: .normal)
            btnSelect.isHidden = false
            myPicker.reloadAllComponents()
            pickerTarget = "previousMeeting"
        }
    }
    
    func getNextMeeting()
    {
        pickerOptions.removeAll(keepingCapacity: false)
        pickerEventArray.removeAll(keepingCapacity: false)
        pickerStartDateArray.removeAll(keepingCapacity: false)

        var calItems: [EKEvent] = []
        
        let startDate = passedMeeting.startDate
        
        let endDateModifier = readDefaultInt("CalAfter") as Int
        
        let endDate = Date().add(.day, amount: (endDateModifier * 7))
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        let searchPredicate = globalEventStore.predicateForEvents(
            withStart: startDate as Date,
            end: endDate,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if globalEventStore.sources.count > 0
        {
            calItems = globalEventStore.events(matching: searchPredicate)
        }
        
        if calItems.count >  0
        {
            // Go through all the events and print them to the console
            for calItem in calItems
            {
                if passedMeeting.meetingID != "\(calItem.calendarItemExternalIdentifier) Date: \(calItem.startDate)"
                {
                    let startDateFormatter = DateFormatter()
                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                    let myDisplayDate = startDateFormatter.string(from: calItem.startDate)
                
                    pickerOptions.append("\(calItem.title) - \(myDisplayDate)")
                    pickerEventArray.append("\(calItem.calendarItemExternalIdentifier) Date: \(calItem.startDate)")
                    pickerStartDateArray.append(calItem.startDate)
                }
            }
        }
        
        if passedMeeting.event?.recurrenceRules != nil
        {
            // Recurring event, so display rucurrences first
            
            // get the meeting id, and remove the trailing portion in order to use in a search
            
            var myItems: [MeetingAgenda]!
            
            let tempMeetingID = passedMeeting.meetingID
            if tempMeetingID.range(of: "/") != nil
            {
                let myStringArr = tempMeetingID.components(separatedBy: "/")
                myItems = myDatabaseConnection.searchPastAgendaByPartialMeetingIDBeforeStart(myStringArr[0], meetingStartDate: passedMeeting.startDate as NSDate, teamID: currentUser.currentTeam!.teamID)
            }
            else
            {
                myItems = myDatabaseConnection.searchPastAgendaByPartialMeetingIDBeforeStart(passedMeeting.meetingID, meetingStartDate: passedMeeting.startDate as NSDate, teamID: currentUser.currentTeam!.teamID)
            }
            
            if myItems.count > 1
            { // There is an previous meeting
                for myItem in myItems
                {
                    if myItem.meetingID != passedMeeting.meetingID
                    { // Not this meeting meeting
                        let startDateFormatter = DateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                        pickerOptions.append("\(myItem.name!) - \(myDisplayDate)")
                        pickerEventArray.append(myItem.meetingID!)
                        pickerStartDateArray.append(myItem.startTime! as Date)
                    }
                }
            }
        }
            
        if pickerOptions.count > 0
        {
            hideFields()
            myPicker.isHidden = false
            btnSelect.setTitle("Set next meeting", for: .normal)
            btnSelect.isHidden = false
            myPicker.reloadAllComponents()
            pickerTarget = "nextMeeting"
        }
    }

    func createActivityController() -> UIActivityViewController
    {
        // Build up the details we want to share
        let sourceString: String = ""
        let sharingActivityProvider: SharingActivityProvider = SharingActivityProvider(placeholderItem: sourceString)
        
        let myTmp1 = passedMeeting.buildShareHTMLString().replacingOccurrences(of: "\n", with: "<p>")
        sharingActivityProvider.HTMLString = myTmp1
        sharingActivityProvider.plainString = passedMeeting.buildShareString()
        
        if passedMeeting.startDate.compare(Date()) == ComparisonResult.orderedAscending
        {  // Historical so show Minutes
            sharingActivityProvider.messageSubject = "Minutes for meeting: \(passedMeeting.title)"
        }
        else
        {
            sharingActivityProvider.messageSubject = "Agenda for meeting: \(passedMeeting.title)"
        }
        
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

    func share(_ sender: AnyObject)
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            let activityViewController: UIActivityViewController = createActivityController()
            activityViewController.popoverPresentationController!.sourceView = sender.view
            present(activityViewController, animated:true, completion:nil)
        }
        else if UIDevice.current.userInterfaceIdiom == .pad
        {
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
        
        
//        if !self.activityPopover.isViewLoaded()
//            {
//            if sender is UIBarButtonItem
//            {
//                let b = sender as! UIBarButtonItem
        
//                self.activityPopover.modalPresentationStyle = UIModalPresentationStyle.Popover
//                self.activityPopover.popoverPresentationController!.sourceView = b.customView
//                presentViewController(self.activityPopover, animated:true, completion:nil)
    //            self.activityPopover.presentPopoverFromBarButtonItem(sender as! UIBarButtonItem,
    //                permittedArrowDirections:.Any,
    //                animated:true)
//            }
//            else
//            {
//                let b = sender as! UIButton
//                self.activityPopover.modalPresentationStyle = UIModalPresentationStyle.Popover
//                self.activityPopover.popoverPresentationController!.sourceView = b
//                presentViewController(self.activityPopover, animated:true, completion:nil)
         //       self.activityPopover.presentPopoverFromRect(b.frame,
         //           inView: self.view,
         //           permittedArrowDirections:.Any,
         //           animated:true)
//            }
//        }
//        else
//        {
//            self.activityPopover.dismissViewControllerAnimated(true, completion: nil)
//        }
    }
    
    func myMeetingsAgendaDidFinish(_ controller:meetingAgendaViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func myMeetingsDidFinish(_ controller:meetingsViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAgenda(_ sender: UIButton)
    {
        if meetingCommunication != nil
        {
            meetingCommunication.callMeetingAgenda(passedMeeting)
        }
    }
    
    @IBAction func btnCompleted(_ sender: UIButton)
    {
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
//    //func identifierForTextArea(_ uiTextObject: AnyObject) -> String
//    func identifier(forTextArea uiTextObject: Any) -> String
//    {
//        var result: String = ""
//
//        if uiTextObject is UITextField
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "txtAttendeeName"
//            }
//            
//            if (uiTextObject as AnyObject).tag == 2
//            {
//                result = "txtAttendeeEmail"
//            }
//        }
//        
//        if uiTextObject is UITextView
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "unused"
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
//        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.pointee
//        
//        if "txtAttendeeName" == textIdentifier
//        {
//            txtAttendeeName.becomeFirstResponder()
//            let theLoc = txtAttendeeName.position(from: txtAttendeeName.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtAttendeeName.selectedTextRange = txtAttendeeName.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtAttendeeName
//        }
//        else if "txtAttendeeEmail" == textIdentifier
//        {
//            txtAttendeeEmail.becomeFirstResponder()
//            let theLoc = txtAttendeeEmail.position(from: txtAttendeeEmail.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtAttendeeEmail.selectedTextRange = txtAttendeeEmail.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtAttendeeEmail
//        }
//
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
//    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
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

class myAttendeeHeader: UICollectionReusableView
{
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblAction: UILabel!
    
}

let NotificationAttendeeRemoved = Notification.Name("NotificationAttendeeRemoved")

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
    
    @IBAction func btnAction(_ sender: UIButton)
    {
        if btnAction.currentTitle == "Remove"
        {
            notificationCenter.post(name: NotificationAttendeeRemoved, object: nil, userInfo:["Action":"Remove","itemNo":btnAction.tag])
        }
        else
        {
            notificationCenter.post(name: NotificationAttendeeRemoved, object: nil, userInfo:["Action":"Attendence","itemNo":btnAction.tag])
        }
    }
}
