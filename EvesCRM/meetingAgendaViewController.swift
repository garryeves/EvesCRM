//
//  meetingAgendaViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 31/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
//import TextExpander

class meetingAgendaViewController: UIViewController, MyAgendaItemDelegate, MyTaskListDelegate, KDRearrangeableCollectionViewDelegate, UIGestureRecognizerDelegate //,  SMTEFillDelegate
{
    fileprivate var passedMeetingModel: MeetingModel!
    var passedMeeting: calendarItem!
    var meetingCommunication: meetingCommunicationDelegate!
    
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
    
    fileprivate let reuseAgendaTime = "reuseAgendaTime"
    fileprivate let reuseAgendaTitle = "reuseAgendaTitle"
    fileprivate let reuseAgendaOwner = "reuseAgendaOwner"
    fileprivate let reuseAgendaAction = "reuseAgendaAction"
    
    fileprivate var pickerOptions: [String] = Array()
    fileprivate var myAgendaList: [meetingAgendaItem] = Array()
    
    fileprivate var myDateFormatter = DateFormatter()
    fileprivate let myCalendar = Calendar.current
    fileprivate var myWorkingTime: Date = Date()
        
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
        
        if passedMeeting == nil
        {
            passedMeetingModel = (tabBarController as! meetingTabViewController).myPassedMeeting
            passedMeeting = (tabBarController as! meetingTabViewController).myPassedMeeting.event
        }
        
        toolbar.isTranslucent = false
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
            target: self, action: nil)
        
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share(_:)))
        
        if passedMeetingModel != nil
        {
            let pageHead = UIBarButtonItem(title: passedMeetingModel.actionType, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doNothing))
            pageHead.tintColor = UIColor.black
        
            let spacer2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            self.toolbar.items=[spacer,pageHead, spacer2, share]
        }
        else
        {
            let spacer2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            self.toolbar.items=[spacer, spacer2, share]
        }
        
        if passedMeetingModel != nil
        {
            if passedMeetingModel.actionType != "Agenda"
            {
                btnAddAgendaItem.isHidden = true
            }
        }
        
        buildAgendaArray()
        
        myPicker.isHidden = true
        
        btnOwner.setTitle("Select Owner", for: .normal)
        
        myDateFormatter.timeStyle = DateFormatter.Style.short
        myWorkingTime = passedMeeting.startDate as Date
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
//        // TextExpander
//        textExpander = SMTEDelegateController()
//        txtDescription.delegate = textExpander
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
        colAgenda.collectionViewLayout.invalidateLayout()
        myWorkingTime = passedMeeting.startDate as Date
        colAgenda.reloadData()
    }
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
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
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return myAgendaList.count
    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell: myMovableAgendaItem!
     
        if indexPath.row == 0
        {
            myWorkingTime = passedMeeting.startDate as Date
        }
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseAgendaTime, for: indexPath as IndexPath) as! myMovableAgendaItem
        cell.lblTime.text = "\(myDateFormatter.string(from: myWorkingTime))"
        cell.lblItem.text = myAgendaList[indexPath.row].title
        cell.lblOwner.text = myAgendaList[indexPath.row].owner

        myWorkingTime = myCalendar.date(
            byAdding: .minute,
            value: Int(myAgendaList[indexPath.row].timeAllocation),
            to: myWorkingTime)!
        
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = myRowColour
        }
        else
        {
            cell.backgroundColor = UIColor.clear
        }
        
        cell.layoutSubviews()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let itemToUpdate = indexPath.row
  
        if myAgendaList[itemToUpdate].agendaID == 0
        {  // This is a previous meeting tasks row, so call the task list
            
            if meetingCommunication != nil
            {
                meetingCommunication.displayTaskList(passedMeeting)
            }
            else
            {
                let taskListViewControl = tasksStoryboard.instantiateViewController(withIdentifier: "taskList") as! taskListViewController
                taskListViewControl.delegate = self
                taskListViewControl.myTaskListType = "Meeting"
                taskListViewControl.passedMeeting = passedMeeting
                
                self.present(taskListViewControl, animated: true, completion: nil)
            }
        }
        else
        {  // This is a normal Agenda item so call the Agenda item screen
            let agendaViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "AgendaItems") as! agendaItemViewController
            agendaViewControl.delegate = self
            agendaViewControl.event = passedMeeting
            agendaViewControl.actionType = passedMeetingModel.actionType
            
            let agendaItem = myAgendaList[itemToUpdate]
            agendaViewControl.agendaItem = agendaItem
            
            self.present(agendaViewControl, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var headerView:UICollectionReusableView!

        if kind == UICollectionElementKindSectionHeader
        {
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "agendaItemHeader", for: indexPath as IndexPath) 
        }
        return headerView
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSize(width: colAgenda.bounds.size.width, height: 39)
    }
    
    // Start move
    
    func moveDataItem(_ toIndexPath : IndexPath, fromIndexPath: IndexPath) -> Void
    {
        if passedMeetingModel.actionType != "Agenda"
        {
            let alert = UIAlertController(title: "Move item", message:
                "You can only move Agenda items when building the Agenda.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alert, animated: false, completion: nil)
        }
        else if myAgendaList[toIndexPath.item].title == "Close meeting" ||
           myAgendaList[fromIndexPath.item].title == "Close meeting"
        {
            let alert = UIAlertController(title: "Move item", message:
                "Unable to move \"Close meeting\" item", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alert, animated: false, completion: nil)
        }
        else if myAgendaList[toIndexPath.item].title == "Review of previous meeting actions" ||
            myAgendaList[fromIndexPath.item].title == "Review of previous meeting actions"
        {
            let alert = UIAlertController(title: "Move item", message:
                "Unable to move \"Review of previous meeting actions\" item", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alert, animated: false, completion: nil)
        }
        else
        {
            if toIndexPath.item > fromIndexPath.item
            {
                myAgendaList[toIndexPath.item].meetingOrder = myAgendaList[fromIndexPath.item].meetingOrder
                
                var loopCount: Int = fromIndexPath.item
                
                while loopCount < toIndexPath.item
                {
                    myAgendaList[loopCount].meetingOrder = Int32(loopCount + 2)
                    loopCount += 1
                }
            }
            else // toIndexPath.item < fromIndexPath.item
            {
                let tempToIndex = toIndexPath.item

                myAgendaList[toIndexPath.item].meetingOrder = myAgendaList[fromIndexPath.item].meetingOrder

                var loopCount: Int = tempToIndex + 1
                
                while loopCount <= fromIndexPath.item
                {
                    myAgendaList[loopCount].meetingOrder = Int32(loopCount)
                    loopCount += 1
                }
            }
        }

        buildAgendaArray()
        
        colAgenda.reloadData()
    }
    
    // End move
    
    func numberOfComponentsInPickerView(_ TableTypeSelection1: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ TableTypeSelection1: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(_ TableTypeSelection1: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerOptions[row]
    }
    
    func pickerView(_ TableTypeSelection1: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Write code for select
        btnOwner.setTitle(pickerOptions[row], for: .normal)
        
        myPicker.isHidden = true
        showFields()
    }
    
    @IBAction func btnAddAgendaItem(_ sender: UIButton)
    {
        if txtDescription.text == ""
        {
            let alert = UIAlertController(title: "Add Agenda Item", message:
        "You must provide a description for the Agenda Item before you can Add it", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
    
            self.present(alert, animated: false, completion: nil)
        }
        else
        {
            let agendaItem = meetingAgendaItem(meetingID: passedMeeting.meetingID)
            agendaItem.status = "Open"
            agendaItem.decisionMade = ""
            agendaItem.discussionNotes = ""
            if txtTimeAllocation.text == ""
            {
                agendaItem.timeAllocation = 10
            }
            else
            {
                agendaItem.timeAllocation = Int16(txtTimeAllocation.text!)!
            }
            if btnOwner.currentTitle != "Select Owner"
            {
                agendaItem.owner = btnOwner.currentTitle!
            }
        
            agendaItem.title = txtDescription.text!
        
            agendaItem.save()

            // reload the Agenda Items collection view
            buildAgendaArray()
            
            myWorkingTime = passedMeeting.startDate as Date
            colAgenda.reloadData()
        
            // set the fields to blank
        
            txtTimeAllocation.text = ""
            txtDescription.text = ""
            btnOwner.setTitle("Select Owner", for: .normal)
        }
    }
    
    @IBAction func btnOwner(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        
        pickerOptions.append("")
        for attendee in passedMeeting.attendees
        {
            pickerOptions.append(attendee.name)
        }
        hideFields()
        myPicker.isHidden = false
        myPicker.reloadAllComponents()
    }
    
    func hideFields()
    {
        lblAgendaItems.isHidden = true
        colAgenda.isHidden = true
        btnAddAgendaItem.isHidden = true
        lblAddAgendaItem.isHidden = true
        lblDescription.isHidden = true
        lblTimeAllocation.isHidden = true
        txtDescription.isHidden = true
        txtTimeAllocation.isHidden = true
        lblOwner.isHidden = true
        btnOwner.isHidden = true
    }
    
    func showFields()
    {
        lblAgendaItems.isHidden = false
        colAgenda.isHidden = false
        btnAddAgendaItem.isHidden = false
        lblAddAgendaItem.isHidden = false
        lblDescription.isHidden = false
        lblTimeAllocation.isHidden = false
        txtDescription.isHidden = false
        txtTimeAllocation.isHidden = false
        lblOwner.isHidden = false
        btnOwner.isHidden = false
    }

    func buildAgendaArray()
    {
        passedMeeting.loadAgendaItems()
        if passedMeeting.previousMinutes == ""
        { // No previous meeting
            myAgendaList = passedMeeting.agendaItems
        }
        else
        { // Previous meeting exists
            let previousMinutes  = meetingAgendaItem(rowType: "PreviousMinutes")
            
            myAgendaList.removeAll(keepingCapacity: false)
            myAgendaList.append(previousMinutes)
            for myItem in passedMeeting.agendaItems
            {
                myAgendaList.append(myItem)
            }
        }
        
        let closeMeeting = meetingAgendaItem(rowType: "Close")
        myAgendaList.append(closeMeeting)
    }
    
    func myAgendaItemDidFinish(_ controller:agendaItemViewController, actionType: String)
    {
        buildAgendaArray()
        myWorkingTime = passedMeeting.startDate as Date
        colAgenda.reloadData()
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func myTaskListDidFinish(_ controller:taskListViewController)
    {
        buildAgendaArray()
        myWorkingTime = passedMeeting.startDate as Date
        colAgenda.reloadData()
        
        controller.dismiss(animated: true, completion: nil)
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
        if UIDevice.current.userInterfaceIdiom == .phone {
            //self.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
            let activityViewController: UIActivityViewController = createActivityController()
            activityViewController.popoverPresentationController!.sourceView = sender.view
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
        /*
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
*/
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
//                result = "txtDescription"
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
//   // func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
//    public func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String!, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>!) -> Any!
//    {
//        snippetExpanded = true
//
//        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.pointee
//        
//        if "txtDescription" == textIdentifier
//        {
//            txtDescription.becomeFirstResponder()
//            let theLoc = txtDescription.position(from: txtDescription.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtDescription.selectedTextRange = txtDescription.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtDescription
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
//
    
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
  
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    var dragging : Bool = false
    {
        didSet
        {
            
        }
        
    }

    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class myMovableAgendaItem: myAgendaItem
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //  self.layer.cornerRadius = self.frame.size.width * 0.5
        self.clipsToBounds = true
    }
}


