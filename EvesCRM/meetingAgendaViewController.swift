//
//  meetingAgendaViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 31/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

class meetingAgendaViewController: UIViewController, MyAgendaItemDelegate, MyTaskListDelegate, SMTEFillDelegate
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
    
    // Textexpander
    
    private var snippetExpanded: Bool = false
    
    var textExpander: SMTEDelegateController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        passedMeeting = (tabBarController as! meetingTabViewController).myPassedMeeting
        
        toolbar.translucent = false
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: self, action: nil)
        
        let share = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share:")
        
        let pageHead = UIBarButtonItem(title: passedMeeting.actionType, style: UIBarButtonItemStyle.Plain, target: self, action: "doNothing")
        pageHead.tintColor = UIColor.blackColor()
        
        let spacer2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
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
        
        // TextExpander
        textExpander = SMTEDelegateController()
        txtDescription.delegate = textExpander
        textExpander.clientAppName = "EvesCRM"
        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
        textExpander.fillDelegate = self
        textExpander.nextDelegate = self
        myCurrentViewController = meetingAgendaViewController()
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
            .Minute,
            value: myAgendaList[indexPath.row].timeAllocation,
            toDate: myWorkingTime,
            options: [])!
        
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = myRowColour
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
        headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "agendaItemHeader", forIndexPath: indexPath) 
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
            let alert = UIAlertController(title: "Add Agenda Item", message:
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
                agendaItem.timeAllocation = Int(txtTimeAllocation.text!)!
            }
            if btnOwner.currentTitle != "Select Owner"
            {
                agendaItem.owner = btnOwner.currentTitle!
            }
        
            agendaItem.title = txtDescription.text!
        
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
            let previousMinutes  = meetingAgendaItem()
            
            previousMinutes.createPreviousMeetingRow()
            myAgendaList.removeAll(keepCapacity: false)
            myAgendaList.append(previousMinutes)
            for myItem in passedMeeting.event.agendaItems
            {
                myAgendaList.append(myItem)
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
        let inString: String = ""
        let sharingActivityProvider: SharingActivityProvider = SharingActivityProvider(placeholderItem: inString)
        
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
        
        let activityItems : Array = [sharingActivityProvider];
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
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
                let b = sender as! UIButton
                self.activityPopover.presentPopoverFromRect(b.frame,
                    inView: self.view,
                    permittedArrowDirections:.Any,
                    animated:true)
            }
        } else {
            self.activityPopover.dismissPopoverAnimated(true)
        }
    }
    //---------------------------------------------------------------
    // These three methods implement the SMTEFillDelegate protocol to support fill-ins
    
    /* When an abbreviation for a snippet that looks like a fill-in snippet has been
    * typed, SMTEDelegateController will call your fill delegate's implementation of
    * this method.
    * Provide some kind of identifier for the given UITextView/UITextField/UISearchBar/UIWebView
    * The ID doesn't have to be fancy, "maintext" or "searchbar" will do.
    * Return nil to avoid the fill-in app-switching process (the snippet will be expanded
    * with "(field name)" where the fill fields are).
    *
    * Note that in the case of a UIWebView, the uiTextObject passed will actually be
    * an NSDictionary with two of these keys:
    *     - SMTEkWebView          The UIWebView object (key always present)
    *     - SMTEkElementID        The HTML element's id attribute (if found, preferred over Name)
    *     - SMTEkElementName      The HTML element's name attribute (if id not found and name found)
    * (If no id or name attribute is found, fill-in's cannot be supported, as there is
    * no way for TE to insert the filled-in text.)
    * Unless there is only one editable area in your web view, this implies that the returned
    * identifier string needs to include element id/name information. Eg. "webview-field2".
    */
    
    func identifierForTextArea(uiTextObject: AnyObject) -> String
    {
        var result: String = ""
        
        if uiTextObject.isKindOfClass(UITextField)
        {
            if uiTextObject.tag == 1
            {
                result = "txtDescription"
            }
        }
        
        if uiTextObject.isKindOfClass(UITextView)
        {
            if uiTextObject.tag == 1
            {
                result = "unused"
            }
        }
        
        if uiTextObject.isKindOfClass(UISearchBar)
        {
            result =  "mySearchBar"
        }
        
        return result
    }
    
    
    /* Usually called milliseconds after identifierForTextArea:, SMTEDelegateController is
    * about to call [[UIApplication sharedApplication] openURL: "tetouch-xc: *x-callback-url/fillin?..."]
    * In other words, the TEtouch is about to be activated. Your app should save state
    * and make any other preparations.
    *
    * Return NO to cancel the process.
    */

    func prepareForFillSwitch(textIdentifier: String) -> Bool
    {
        // At this point the app should save state since TextExpander touch is about
        // to activate.
        // It especially needs to save the contents of the textview/textfield!
        
        return true
    }
    
    /* Restore active typing location and insertion cursor position to a text item
    * based on the identifier the fill delegate provided earlier.
    * (This call is made from handleFillCompletionURL: )
    *
    * In the case of a UIWebView, this method should build and return an NSDictionary
    * like the one sent to the fill delegate in identifierForTextArea: when the snippet
    * was triggered.
    * That is, you should make the UIWebView become first responder, then return an
    * NSDictionary with two of these keys:
    *     - SMTEkWebView          The UIWebView object (key must be present)
    *     - SMTEkElementID        The HTML element's id attribute (preferred over Name)
    *     - SMTEkElementName      The HTML element's name attribute (only if no id)
    * TE will use the same Javascripts that it uses to expand normal snippets to focus the appropriate
    * element and insert the filled text.
    *
    * Note 1: If your app is still loaded after returning from TEtouch's fill window,
    * probably no work needs to be done (the text item will still be the first
    * responder, and the insertion cursor position will still be the same).
    * Note 2: If the requested insertionPointLocation cannot be honored (ie. text has
    * been reset because of the app switching), then update it to whatever is reasonable.
    *
    * Return nil to cancel insertion of the fill-in text. Users will not expect a cancel
    * at this point unless userCanceledFill is set. Even in the cancel case, they will likely
    * expect the identified text object to become the first responder.
    */
    
    func makeIdentifiedTextObjectFirstResponder(textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
    {
        snippetExpanded = true

        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.memory
        
        if "txtDescription" == textIdentifier
        {
            txtDescription.becomeFirstResponder()
            let theLoc = txtDescription.positionFromPosition(txtDescription.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtDescription.selectedTextRange = txtDescription.textRangeFromPosition(theLoc!, toPosition: theLoc!)
            }
            return txtDescription
        }
            //        else if "mySearchBar" == textIdentifier
            //        {
            //            searchBar.becomeFirstResponder()
            // Note: UISearchBar does not support cursor positioning.
            // Since we don't save search bar text as part of our state, if our app was unloaded while TE was
            // presenting the fill-in window, the search bar might now be empty to we should return
            // insertionPointLocation of 0.
            //            let searchTextLen = searchBar.text.length
            //            if searchTextLen < ioInsertionPointLocation
            //            {
            //                ioInsertionPointLocation = searchTextLen
            //            }
            //            return searchBar
            //        }
        else
        {
            
            //return nil
            
            return ""
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if (textExpander.isAttemptingToExpandText)
        {
            snippetExpanded = true
        }
        return true
    }
    
    // Workaround for what appears to be an iOS 7 bug which affects expansion of snippets
    // whose content is greater than one line. The UITextView fails to update its display
    // to show the full content. Try commenting this out and expanding "sig1" to see the issue.
    //
    // Given other oddities of UITextView on iOS 7, we had assumed this would be fixed along the way.
    // Instead, we'll have to work up an isolated case and file a bug. We don't want to bake this kind
    // of workaround into the SDK, so instead we provide an example here.
    // If you have a better workaround suggestion, we'd love to hear it.
    
    func twiddleText(textView: UITextView)
    {
        let SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO = UIDevice.currentDevice().systemVersion
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO >= "7.0"
        {
            textView.textStorage.edited(NSTextStorageEditActions.EditedCharacters,range:NSMakeRange(0, textView.textStorage.length),changeInLength:0)
        }
    }
    
    func textViewDidChange(textView: UITextView)
    {
        if snippetExpanded
        {
            usleep(10000)
            twiddleText(textView)
            
            // performSelector(twiddleText:, withObject: textView, afterDelay:0.01)
            snippetExpanded = false
        }
    }
    
    
    /*
    // The following are the UITextViewDelegate methods; they simply write to the console log for demonstration purposes
    
    func textViewDidBeginEditing(textView: UITextView)
    {
    println("nextDelegate textViewDidBeginEditing")
    }
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
    println("nextDelegate textViewShouldBeginEditing")
    return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool
    {
    println("nextDelegate textViewShouldEndEditing")
    return true
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
    println("nextDelegate textViewDidEndEditing")
    }
    
    func textViewDidChangeSelection(textView: UITextView)
    {
    println("nextDelegate textViewDidChangeSelection")
    }
    
    // The following are the UITextFieldDelegate methods; they simply write to the console log for demonstration purposes
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldBeginEditing")
    return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
    println("nextDelegate textFieldDidBeginEditing")
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldEndEditing")
    return true
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
    println("nextDelegate textFieldDidEndEditing")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
    println("nextDelegate textField:shouldChangeCharactersInRange: \(NSStringFromRange(range)) Original=\(textField.text), replacement = \(string)")
    return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldClear")
    return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldReturn")
    return true
    }
    */

    
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

