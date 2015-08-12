//
//  meetingsViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 7/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import EventKit

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
    @IBOutlet weak var btnNextMeeting: UIButton!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var btnSelect: UIButton!
    
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var btnHead: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    private let reuseAttendeeIdentifier = "AttendeeCell"
    private let reuseAttendeeStatusIdentifier = "AttendeeStatusCell"
    private let reuseAttendeeAction = "AttendeeActionCell"
    
    private var pickerOptions: [String] = Array()
    private var pickerEventArray: [String] = Array()
    private var pickerTarget: String = ""
    private var mySelectedRow: Int = 0
    
    lazy var activityPopover:UIPopoverController = {
        return UIPopoverController(contentViewController: self.activityViewController)
        }()
    
    lazy var activityViewController:UIActivityViewController = {
        return self.createActivityController()
         }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        passedMeeting = (tabBarController as! meetingTabViewController).myPassedMeeting
        
        lblMeetingHead.text = passedMeeting.actionType
        
        toolbar.translucent = false
        
        var spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: self, action: nil)
        
        var share = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share:")
        
        var pageHead = UIBarButtonItem(title: passedMeeting.actionType, style: UIBarButtonItemStyle.Plain, target: self, action: "doNothing")
        pageHead.tintColor = UIColor.blackColor()
        
        var spacer2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: self, action: nil)
        self.toolbar.items=[spacer,pageHead, spacer2, share]
        
        lblLocation.text = passedMeeting.event.location
        lblStartTime.text = passedMeeting.event.displayScheduledDate
        lblMeetingName.text = passedMeeting.event.title
        myPicker.hidden = true
        btnSelect.hidden = true
        
        passedMeeting.event.loadAgenda()
        
        if passedMeeting.event.chair != ""
        {
            btnChair.setTitle(passedMeeting.event.chair, forState: .Normal)
        }
        
        if passedMeeting.event.minutes != ""
        {
            btnMinutes.setTitle(passedMeeting.event.minutes, forState: .Normal)
        }
        
        if passedMeeting.event.previousMinutes != ""
        {
            // Get the previous meetings details

            let myItems = myDatabaseConnection.loadAgenda(passedMeeting.event.previousMinutes)
           
            for myItem in myItems
            {
                var startDateFormatter = NSDateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
            
                let myDisplayString = "\(myItem.name) - \(myDisplayDate)"
            
                btnPreviousMinutes.setTitle(myDisplayString, forState: .Normal)
            }
        }

        if passedMeeting.event.nextMeeting != ""
        {
            // Get the previous meetings details
            
            let myItems = myDatabaseConnection.loadAgenda(passedMeeting.event.nextMeeting)
            
            for myItem in myItems
            {
                var startDateFormatter = NSDateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                
                let myDisplayString = "\(myItem.name) - \(myDisplayDate)"
                
                btnNextMeeting.setTitle(myDisplayString, forState: .Normal)
            }
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

        mySelectedRow = row
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
        btnSelect.hidden = false
        btnSelect.setTitle("Set Chairperson", forState: .Normal)
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
        btnSelect.setTitle("Set Minutes taker", forState: .Normal)
        btnSelect.hidden = false
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
        
            txtAttendeeName.text = ""
            txtAttendeeEmail.text = ""
        }
    }
    
    @IBAction func btnPreviousMinutes(sender: UIButton)
    {
        getPreviousMeeting()
    }
    
    @IBAction func btnNextMeeting(sender: UIButton)
    {
        getNextMeeting()
    }
    
    @IBAction func btnSelect(sender: UIButton)
    {
        if pickerOptions.count > 0
        {
            if pickerTarget == "chair"
            {
                btnChair.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedMeeting.event.chair = pickerOptions[mySelectedRow]
            }
        
            if pickerTarget == "minutes"
            {
                btnMinutes.setTitle(pickerOptions[mySelectedRow], forState: .Normal)
                passedMeeting.event.minutes = pickerOptions[mySelectedRow]
            }
        
            if pickerTarget == "previousMeeting"
            {
                // Check to see if an existing meeting already has this previos ID
            
                let myItems = myDatabaseConnection.loadPreviousAgenda(pickerEventArray[mySelectedRow])
            
                if myItems.count > 0
                { // Existing meeting found
                    for myItem in myItems
                    {
                        var startDateFormatter = NSDateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                    
                        let calendarOption: UIAlertController = UIAlertController(title: "Existing meeting found", message: "A meeting \(myItem.name) - \(myDisplayDate) has this set as previous meeting.  Do you want to continue, which will clear the previous meeting from the original meeting?  ", preferredStyle: .ActionSheet)
                    
                        let myYes = UIAlertAction(title: "Yes, update the details", style: .Default, handler: { (action: UIAlertAction!) -> () in
                            // go and update the previous meeting
                        
                            myDatabaseConnection.updatePreviousAgendaID("", inMeetingID: myItem.meetingID)
                        
                            self.passedMeeting.event.previousMinutes = self.pickerEventArray[self.mySelectedRow]
                        
                            if self.passedMeeting.event.previousMinutes != ""
                            {
                                // Get the previous meetings details
                            
                                let myDisplayItems = myDatabaseConnection.loadAgenda(self.passedMeeting.event.previousMinutes)
                            
                                for myDisplayItem in myDisplayItems
                                {
                                    var startDateFormatter = NSDateFormatter()
                                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                    let myDisplayDate = startDateFormatter.stringFromDate(myDisplayItem.startTime)
                                
                                    let myDisplayString = "\(myDisplayItem.name) - \(myDisplayDate)"
                                
                                    self.btnPreviousMinutes.setTitle(myDisplayString, forState: .Normal)
                                }
                            }
                        })
                    
                        let myNo = UIAlertAction(title: "No, leave the existing details", style: .Default, handler: { (action: UIAlertAction!) -> () in
                            // do nothing
                        })
                    
                        calendarOption.addAction(myYes)
                        calendarOption.addAction(myNo)
                    
                        calendarOption.popoverPresentationController?.sourceView = self.view
                        calendarOption.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.width / 2.0, self.view.bounds.height / 2.0, 1.0, 1.0)
                    
                        self.presentViewController(calendarOption, animated: true, completion: nil)
                    }
                }
                else
                {
                    passedMeeting.event.previousMinutes = pickerEventArray[mySelectedRow]
                
                    if passedMeeting.event.previousMinutes != ""
                    {
                        // Get the previous meetings details
                    
                        let myDisplayItems = myDatabaseConnection.loadAgenda(passedMeeting.event.previousMinutes)
                    
                        for myDisplayItem in myDisplayItems
                        {
                            var startDateFormatter = NSDateFormatter()
                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                            let myDisplayDate = startDateFormatter.stringFromDate(myDisplayItem.startTime)
                        
                            let myDisplayString = "\(myDisplayItem.name) - \(myDisplayDate)"
                        
                            btnPreviousMinutes.setTitle(myDisplayString, forState: .Normal)
                        }
                    }
                }
            }
        
            if pickerTarget == "nextMeeting"
            {
                // Check to see if an existing meeting already has this previos ID
            
                let myItems = myDatabaseConnection.loadAgenda(pickerEventArray[mySelectedRow])
            
                if myItems.count > 0
                {
                    for myItem in myItems
                    {
                        if myItem.previousMeetingID != ""
                        {
                            var startDateFormatter = NSDateFormatter()
                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                            let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                        
                            let calendarOption: UIAlertController = UIAlertController(title: "Existing meeting found", message: "A meeting \(myItem.name) - \(myDisplayDate) has this set as next meeting.  Do you want to continue, which will clear the next meeting from the original meeting?  ", preferredStyle: .ActionSheet)
                        
                            let myYes = UIAlertAction(title: "Yes, update the details", style: .Default, handler: { (action: UIAlertAction!) -> () in
                            // go and update the previous meeting
                            
                                let myOriginalNextMeeting = self.passedMeeting.event.nextMeeting
                            
                                myDatabaseConnection.updatePreviousAgendaID("", inMeetingID: myOriginalNextMeeting)
                            
                                self.passedMeeting.event.nextMeeting = self.pickerEventArray[self.mySelectedRow]
                            
                                if self.passedMeeting.event.nextMeeting != ""
                                {
                                    // Get the previous meetings details
                                
                                    let myItems = myDatabaseConnection.loadAgenda(self.passedMeeting.event.nextMeeting)
                                    
                                    for myItem in myItems
                                    {
                                        var startDateFormatter = NSDateFormatter()
                                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                        let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                                    
                                        let myDisplayString = "\(myItem.name) - \(myDisplayDate)"
                                    
                                        self.btnNextMeeting.setTitle(myDisplayString, forState: .Normal)
                                    }
                                }
                            })
                        
                            let myNo = UIAlertAction(title: "No, leave the existing details", style: .Default, handler: { (action: UIAlertAction!) -> () in
                                // do nothing
                            })
                        
                            calendarOption.addAction(myYes)
                            calendarOption.addAction(myNo)
                        
                            calendarOption.popoverPresentationController?.sourceView = self.view
                            calendarOption.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.width / 2.0, self.view.bounds.height / 2.0, 1.0, 1.0)
                        
                            self.presentViewController(calendarOption, animated: true, completion: nil)
                        }
                        else
                        {
                            let myOriginalNextMeeting = self.passedMeeting.event.nextMeeting
                        
                            myDatabaseConnection.updatePreviousAgendaID("", inMeetingID: myOriginalNextMeeting)

                            passedMeeting.event.nextMeeting = pickerEventArray[mySelectedRow]
                            if passedMeeting.event.nextMeeting != ""
                            {
                                // Get the previous meetings details
                            
                                let myItems = myDatabaseConnection.loadAgenda(passedMeeting.event.nextMeeting)
                            
                                for myItem in myItems
                                {
                                    var startDateFormatter = NSDateFormatter()
                                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                                    let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                                
                                    let myDisplayString = "\(myItem.name) - \(myDisplayDate)"
                                
                                    btnNextMeeting.setTitle(myDisplayString, forState: .Normal)
                                }
                            }
                        }
                    }
                }
                else
                {
                    let myOriginalNextMeeting = self.passedMeeting.event.nextMeeting
                
                    myDatabaseConnection.updatePreviousAgendaID("", inMeetingID: myOriginalNextMeeting)

                    passedMeeting.event.nextMeeting = pickerEventArray[mySelectedRow]
                    if passedMeeting.event.nextMeeting != ""
                    {
                        // Get the previous meetings details
                    
                        let myItems = myDatabaseConnection.loadAgenda(passedMeeting.event.nextMeeting)
                    
                        for myItem in myItems
                        {
                            var startDateFormatter = NSDateFormatter()
                            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                            let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                        
                            let myDisplayString = "\(myItem.name) - \(myDisplayDate)"
                        
                            btnNextMeeting.setTitle(myDisplayString, forState: .Normal)
                        }
                    }
                }
            }
        }
        
        myPicker.hidden = true
        btnSelect.hidden = true
        showFields()
    }
    
    @IBAction func btnShare(sender: UIBarButtonItem)
    {
        let textToShare = "Swift is awesome!  Check out this website about it!"
        
        if let myWebsite = NSURL(string: "http://www.codingexplorer.com/")
        {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
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
        btnNextMeeting.hidden = true
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
        btnNextMeeting.hidden = false
    }
    
    func attendeeRemoved(notification: NSNotification)
    {
        let itemToRemove = notification.userInfo!["itemNo"] as! Int
        
        passedMeeting.event.removeAttendee(itemToRemove)
        colAttendees.reloadData()
    }
    
    func getPreviousMeeting()
    {
        // We only list items here that we have Meeting records for, as otherwise there is no previous actions to get and display
        
        // if a recurring meeting invite then display previous occurances at the top of the list
        
        pickerOptions.removeAll(keepCapacity: false)
        pickerEventArray.removeAll(keepCapacity: false)
        
        if passedMeeting.event.event!.recurrenceRules != nil
        {
            // Recurring event, so display rucurrences first
         
            // get the meeting id, and remove the trailing portion in order to use in a search
            
            let myStringArr = passedMeeting.event.event!.eventIdentifier.componentsSeparatedByString("/")

            
            let myItems = myDatabaseConnection.searchPastAgendaByPartialMeetingIDAfterStart(myStringArr[0], inMeetingStartDate: passedMeeting.event.startDate)
            
            if myItems.count > 1
            { // There is an previous meeting
                for myItem in myItems
                {
                    if myItem.meetingID != passedMeeting.event.event!.eventIdentifier
                    { // Not this meeting meeting
                        var startDateFormatter = NSDateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                        
                        pickerOptions.append("\(myItem.name) - \(myDisplayDate)")
                        pickerEventArray.append(myItem.meetingID)
                    }
                }
            }
            
            // display remaining items, newest first

            let myNonItems = myDatabaseConnection.searchPastAgendaWithoutPartialMeetingIDAfterStart(myStringArr[0], inMeetingStartDate: passedMeeting.event.startDate)
            
            if myNonItems.count > 0
            { // There is an previous meeting
                for myItem in myNonItems
                {
                    var startDateFormatter = NSDateFormatter()
                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                    let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                        
                    pickerOptions.append("\(myItem.name) - \(myDisplayDate)")
                    pickerEventArray.append(myItem.meetingID)
                }
            }
            
            // Next meeting could also be a non entry so need to show calendar items as well
        }
        else
        {
            //non-recurring event, so display in date order, newest first
            
            // list items prior to meeting date
            
            let myItems = myDatabaseConnection.listAgendaReverseDateAfterStart(passedMeeting.event.startDate)
            
            if myItems.count > 0
            { // There is an previous meeting
                for myItem in myItems
                {
                    if myItem.meetingID != passedMeeting.event.event!.eventIdentifier
                    { // Not this meeting meeting
                        var startDateFormatter = NSDateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                        
                        pickerOptions.append("\(myItem.name) - \(myDisplayDate)")
                        pickerEventArray.append(myItem.meetingID)
                    }
                }
            }
        }
        
        if pickerOptions.count > 0
        {
            hideFields()
            myPicker.hidden = false
            btnSelect.setTitle("Set previous meeting", forState: .Normal)
            btnSelect.hidden = false
            myPicker.reloadAllComponents()
            pickerTarget = "previousMeeting"
        }
    }
    
    func getNextMeeting()
    {
        // We only list items here that we have Meeting records for, as otherwise there is no previous actions to get and display
        
        // if a recurring meeting invite then display previous occurances at the top of the list
        
        pickerOptions.removeAll(keepCapacity: false)
        pickerEventArray.removeAll(keepCapacity: false)

        var events: [EKEvent] = []
        
        let baseDate = NSDate()
        
        let myEndDateString = myDatabaseConnection.getDecodeValue("CalAfterWeeks")
        // This is string value so need to convert to integer
        
        let myEndDateValue:NSTimeInterval = (myEndDateString as NSString).doubleValue * 7 * 24 * 60 * 60
        
        let endDate = baseDate.dateByAddingTimeInterval(myEndDateValue)
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        let searchPredicate = eventStore.predicateForEventsWithStartDate(
            NSDate(),
            endDate: endDate,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if eventStore.sources().count > 0
        {
            if eventStore.eventsMatchingPredicate(searchPredicate) != nil
            {
                events = eventStore.eventsMatchingPredicate(searchPredicate) as! [EKEvent]
            }
        }
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                var myDisplayString = event.title
                
                var startDateFormatter = NSDateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.stringFromDate(event.startDate)
                
                pickerOptions.append("\(event.title) - \(myDisplayDate)")
                pickerEventArray.append(event.eventIdentifier)
            }
        }
        
        if passedMeeting.event.event!.recurrenceRules != nil
        {
            // Recurring event, so display rucurrences first
            
            // get the meeting id, and remove the trailing portion in order to use in a search
            
            let myStringArr = passedMeeting.event.event!.eventIdentifier.componentsSeparatedByString("/")
            
            let myItems = myDatabaseConnection.searchPastAgendaByPartialMeetingIDBeforeStart(myStringArr[0], inMeetingStartDate: passedMeeting.event.startDate)
            
            if myItems.count > 1
            { // There is an previous meeting
                for myItem in myItems
                {
                    if myItem.meetingID != passedMeeting.event.event!.eventIdentifier
                    { // Not this meeting meeting
                        var startDateFormatter = NSDateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                        
                        pickerOptions.append("\(myItem.name) - \(myDisplayDate)")
                        pickerEventArray.append(myItem.meetingID)
                    }
                }
            }
 /*
            // display remaining items, newest first
            
            let myNonItems = myDatabaseConnection.searchPastAgendaWithoutPartialMeetingIDBeforeStart(myStringArr[0], inMeetingStartDate: passedMeeting.event.startDate)
            
            if myNonItems.count > 0
            { // There is an previous meeting
                for myItem in myNonItems
                {
                    var startDateFormatter = NSDateFormatter()
                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                    let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                    
                    pickerOptions.append("\(myItem.name) - \(myDisplayDate)")
                    pickerEventArray.append(myItem.meetingID)
                }
            }
*/
        }
/*
        else
        {
            //non-recurring event, so display in date order, newest first
            
            // list items prior to meeting date
            
            let myItems = myDatabaseConnection.listAgendaReverseDateBeforeStart(passedMeeting.event.startDate)
            
            if myItems.count > 0
            { // There is an previous meeting
                for myItem in myItems
                {
                    if myItem.meetingID != passedMeeting.event.event.eventIdentifier
                    { // Not this meeting meeting
                        var startDateFormatter = NSDateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                        
                        pickerOptions.append("\(myItem.name) - \(myDisplayDate)")
                        pickerEventArray.append(myItem.meetingID)
                    }
                }
            }
        }
      */
            
        if pickerOptions.count > 0
        {
            hideFields()
            myPicker.hidden = false
            btnSelect.setTitle("Set next meeting", forState: .Normal)
            btnSelect.hidden = false
            myPicker.reloadAllComponents()
            pickerTarget = "nextMeeting"
        }
    }
    
    func createActivityController() -> UIActivityViewController
    {
        // Build up the details we want to share

        var sharingActivityProvider: SharingActivityProvider = SharingActivityProvider();
        sharingActivityProvider.HTMLString = passedMeeting.event.buildShareHTMLString()
        sharingActivityProvider.plainString = passedMeeting.event.buildShareString()
        
        var activityItems : Array = [sharingActivityProvider];
        
        var activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
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
                var b = sender as! UIButton
                self.activityPopover.presentPopoverFromRect(b.frame,
                    inView: self.view,
                    permittedArrowDirections:.Any,
                    animated:true)
            }
        } else {
            self.activityPopover.dismissPopoverAnimated(true)
        }
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