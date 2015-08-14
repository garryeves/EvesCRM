//
//  meetingAgendaViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 31/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

class meetingAgendaViewController: UIViewController, MyAgendaItemDelegate, MyTaskListDelegate
{
    
    private var passedMeeting: MeetingModel!
    
    @IBOutlet weak var lblAgendaItems: UILabel!
    @IBOutlet weak var colAgenda: UICollectionView!
    @IBOutlet weak var btnAddAgendaItem: UIButton!
    @IBOutlet weak var lblAddAgendaItem: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTimeAllocation: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtTimeAllocation: UITextField!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    private let reuseAgendaTime = "reuseAgendaTime"
    private let reuseAgendaTitle = "reuseAgendaTitle"
    private let reuseAgendaOwner = "reuseAgendaOwner"
    private let reuseAgendaAction = "reuseAgendaAction"
    
    private var pickerOptions: [String] = Array()
    private var myAgendaList: [meetingAgendaItem] = Array()
    
    private var myDateFormatter = NSDateFormatter()
    private let myCalendar = NSCalendar.currentCalendar()
    private var myWorkingTime: NSDate = NSDate()
    
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
        
        toolbar.translucent = false
        
        var spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: self, action: nil)
        
        var share = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share:")
        
        var pageHead = UIBarButtonItem(title: passedMeeting.actionType, style: UIBarButtonItemStyle.Plain, target: self, action: "doNothing")
        pageHead.tintColor = UIColor.blackColor()
        
        var spacer2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: self, action: nil)
        self.toolbar.items=[spacer,pageHead, spacer2, share]
        
        if passedMeeting.actionType != "Agenda"
        {
            btnAddAgendaItem.hidden = true
        }
        
        buildAgendaArray()
        
        myPicker.hidden = true
        
        btnOwner.setTitle("Select Owner", forState: .Normal)
        
        myDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        myWorkingTime = passedMeeting.event.startDate
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        colAgenda.collectionViewLayout.invalidateLayout()
        myWorkingTime = passedMeeting.event.startDate
        colAgenda.reloadData()
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            // Move to previous item in tab hierarchy
            
            let myCurrentTab = self.tabBarController
            
            myCurrentTab!.selectedIndex = myCurrentTab!.selectedIndex - 1
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return myAgendaList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell: myAgendaItem!
            
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAgendaTime, forIndexPath: indexPath) as! myAgendaItem
        cell.lblTime.text = "\(myDateFormatter.stringFromDate(myWorkingTime))"
        cell.lblItem.text = myAgendaList[indexPath.row].title
        cell.lblOwner.text = myAgendaList[indexPath.row].owner

        myWorkingTime = myCalendar.dateByAddingUnit(
            .CalendarUnitMinute,
            value: myAgendaList[indexPath.row].timeAllocation,
            toDate: myWorkingTime,
            options: nil)!
        
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
    {
        let itemToUpdate = indexPath.row
        
        if myAgendaList[itemToUpdate].agendaID == 0
        {  // This is a previous meeting tasks row, so call the task list
            let taskListViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("taskList") as! taskListViewController
            taskListViewControl.delegate = self
            taskListViewControl.myTaskListType = "Meeting"
            taskListViewControl.myMeetingID = passedMeeting.event.previousMinutes
            
            self.presentViewController(taskListViewControl, animated: true, completion: nil)
        }
        else
        {  // This is a normal Agenda item so call the Agenda item screen
            let agendaViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("AgendaItems") as! agendaItemViewController
            agendaViewControl.delegate = self
            agendaViewControl.event = passedMeeting.event
            agendaViewControl.actionType = passedMeeting.actionType
        
            let agendaItem = myAgendaList[itemToUpdate]
            agendaViewControl.agendaItem = agendaItem
        
            self.presentViewController(agendaViewControl, animated: true, completion: nil)
        }
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
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSize(width: colAgenda.bounds.size.width, height: 39)
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
        btnOwner.setTitle(pickerOptions[row], forState: .Normal)
        
        myPicker.hidden = true
        showFields()
    }
    
    @IBAction func btnAddAgendaItem(sender: UIButton)
    {
        if txtDescription.text == ""
        {
            var alert = UIAlertController(title: "Add Agenda Item", message:
        "You must provide a description for the Agenda Item before you can Add it", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
    
            self.presentViewController(alert, animated: false, completion: nil)
        }
        else
        {
            let agendaItem = meetingAgendaItem(inMeetingID: passedMeeting.event.eventID)
            agendaItem.status = "Open"
            agendaItem.decisionMade = ""
            agendaItem.discussionNotes = ""
            if txtTimeAllocation.text == ""
            {
                agendaItem.timeAllocation = 10
            }
            else
            {
                agendaItem.timeAllocation = txtTimeAllocation.text.toInt()!
            }
            if btnOwner.currentTitle != "Select Owner"
            {
                agendaItem.owner = btnOwner.currentTitle!
            }
        
            agendaItem.title = txtDescription.text
        
            agendaItem.save()

            // reload the Agenda Items collection view
            passedMeeting.event.loadAgendaItems()
            buildAgendaArray()
            
            myWorkingTime = passedMeeting.event.startDate
            colAgenda.reloadData()
        
            // set the fields to blank
        
            txtTimeAllocation.text = ""
            txtDescription.text = ""
            btnOwner.setTitle("Select Owner", forState: .Normal)
        }
    }
    
    @IBAction func btnOwner(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        
        pickerOptions.append("")
        for attendee in passedMeeting.event.attendees
        {
            pickerOptions.append(attendee.name)
        }
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
    }
    
    func hideFields()
    {
        lblAgendaItems.hidden = true
        colAgenda.hidden = true
        btnAddAgendaItem.hidden = true
        lblAddAgendaItem.hidden = true
        lblDescription.hidden = true
        lblTimeAllocation.hidden = true
        txtDescription.hidden = true
        txtTimeAllocation.hidden = true
        lblOwner.hidden = true
        btnOwner.hidden = true
    }
    
    func showFields()
    {
        lblAgendaItems.hidden = false
        colAgenda.hidden = false
        btnAddAgendaItem.hidden = false
        lblAddAgendaItem.hidden = false
        lblDescription.hidden = false
        lblTimeAllocation.hidden = false
        txtDescription.hidden = false
        txtTimeAllocation.hidden = false
        lblOwner.hidden = false
        btnOwner.hidden = false
    }

    func buildAgendaArray()
    {
        if passedMeeting.event.previousMinutes == ""
        { // No previous meeting
            myAgendaList = passedMeeting.event.agendaItems
        }
        else
        { // Previous meeting exists
            // Does the previous meeting have any tasks
            let myData = myDatabaseConnection.getMeetingsTasks(passedMeeting.event.previousMinutes)
        
            if myData.count > 0
            {  // There are tasks for the previous meeting
                let previousMinutes  = meetingAgendaItem()
            
                previousMinutes.createPreviousMeetingRow()
                myAgendaList.removeAll(keepCapacity: false)
                myAgendaList.append(previousMinutes)
                for myItem in passedMeeting.event.agendaItems
                {
                    myAgendaList.append(myItem)
                }
            }
            else
            { // Not tasks for the previous meeting
                myAgendaList = passedMeeting.event.agendaItems
            }
        }
        let closeMeeting = meetingAgendaItem()
        closeMeeting.createCloseMeetingRow()
        myAgendaList.append(closeMeeting)
    }
    
    func myAgendaItemDidFinish(controller:agendaItemViewController, actionType: String)
    {
        passedMeeting.event.loadAgendaItems()
        buildAgendaArray()
        myWorkingTime = passedMeeting.event.startDate
        colAgenda.reloadData()
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func myTaskListDidFinish(controller:taskListViewController)
    {
        passedMeeting.event.loadAgendaItems()
        buildAgendaArray()
        myWorkingTime = passedMeeting.event.startDate
        colAgenda.reloadData()
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createActivityController() -> UIActivityViewController
    {
        // Build up the details we want to share
        
        var sharingActivityProvider: SharingActivityProvider = SharingActivityProvider()
        
        let myTmp1 = passedMeeting.event.buildShareHTMLString().stringByReplacingOccurrencesOfString("\n", withString: "<p>")
        sharingActivityProvider.HTMLString = myTmp1
        sharingActivityProvider.plainString = passedMeeting.event.buildShareString()

        if passedMeeting.event.startDate.compare(NSDate()) == NSComparisonResult.OrderedAscending
        {  // Historical so show Minutes
            sharingActivityProvider.messageSubject = "Minutes for meeting: \(passedMeeting.event.title)"
        }
        else
        {
            sharingActivityProvider.messageSubject = "Agenda for meeting: \(passedMeeting.event.title)"
        }
        
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

class myAgendaItemHeader: UICollectionReusableView
{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
}

class myAgendaItem: UICollectionViewCell
{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
  
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

