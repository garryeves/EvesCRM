//
//  AgendaItemViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 17/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
//import TextExpander

protocol MyAgendaItemDelegate
{
    func myAgendaItemDidFinish(_ controller:agendaItemViewController, actionType: String)
}

class agendaItemViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate //, SMTEFillDelegate
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
    
    fileprivate let cellTaskName = "cellTaskName"
    
    var event: myCalendarItem!
    var agendaItem: meetingAgendaItem!
    var actionType: String = ""
    
    fileprivate var pickerOptions: [String] = Array()
    fileprivate var pickerTarget: String = ""
    fileprivate var myCells: [cellDetails] = Array()
    fileprivate var headerSize: CGFloat = 0.0
    
//    // Textexpander
//    
//    fileprivate var snippetExpanded: Bool = false
//    
//    var textExpander: SMTEDelegateController!
    
    fileprivate var currentEditingField: String = ""

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if actionType == "Agenda"
        {
            txtDiscussionNotes.isEditable = false
            txtDecisionMade.isEditable = false
            btnAddAction.isEnabled = false
        }
        
        if agendaItem.agendaID != 0
        {
            btnStatus.setTitle(agendaItem.status, for: .normal)
            txtDecisionMade.text = agendaItem.decisionMade
            txtDiscussionNotes.text = agendaItem.discussionNotes
            txtTimeAllocation.text = "\(agendaItem.timeAllocation)"
            if agendaItem.owner == ""
            {
                btnOwner.setTitle("Select Item Owner", for: .normal)
            }
            else
            {
                btnOwner.setTitle(agendaItem.owner, for: .normal)
            }
            txtTitle.text = agendaItem.title
        }
        
        myPicker.isHidden = true
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        txtDiscussionNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtDiscussionNotes.layer.borderWidth = 0.5
        txtDiscussionNotes.layer.cornerRadius = 5.0
        txtDiscussionNotes.layer.masksToBounds = true
        txtDiscussionNotes.delegate = self
        
        txtDecisionMade.layer.borderColor = UIColor.lightGray.cgColor
        txtDecisionMade.layer.borderWidth = 0.5
        txtDecisionMade.layer.cornerRadius = 5.0
        txtDecisionMade.layer.masksToBounds = true
        txtDecisionMade.delegate = self
        
//        // TextExpander
//        textExpander = SMTEDelegateController()
//        txtTitle.delegate = textExpander
//        txtDiscussionNotes.delegate = textExpander
//        txtDecisionMade.delegate = textExpander
//        textExpander.clientAppName = "EvesCRM"
//        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
//        textExpander.fillDelegate = self
//        textExpander.nextDelegate = self
        myCurrentViewController = agendaItemViewController()
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
        colActions.collectionViewLayout.invalidateLayout()
        
        colActions.reloadData()
    }

    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
        {
            // Do nothing
        }
        else
        {
            delegate?.myAgendaItemDidFinish(self, actionType: "Cancel")
        }
    }
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        myCells.removeAll()
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return agendaItem.tasks.count
    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell : myTaskItem!
 
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellTaskName, for: indexPath as IndexPath) as! myTaskItem

        if agendaItem.tasks.count == 0
        {
            cell.lblTaskName.text = ""
            cell.lblTaskStatus.text = ""
            cell.lblTaskOwner.text = ""
            cell.lblTaskTargetDate.text = ""
        }
        else
        {
            cell.lblTaskName.text = agendaItem.tasks[indexPath.row].title
            cell.lblTaskStatus.text = agendaItem.tasks[indexPath.row].status
            cell.lblTaskOwner.text = "Owner"
            cell.lblTaskTargetDate.text = agendaItem.tasks[indexPath.row].displayDueDate
        }
        
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

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var headerView:UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader
        {
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "taskItemHeader", for: indexPath as IndexPath) 
        }

        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath)
    {
        let myOptions = displayTaskOptions(collectionView, workingTask: agendaItem.tasks[indexPath.row])
        myOptions.popoverPresentationController!.sourceView = collectionView
        
        self.present(myOptions, animated: true, completion: nil)
    }

    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colActions.bounds.size.width, height: 39)
        
        return retVal
    }

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
        if pickerTarget == "Owner"
        {
            btnOwner.setTitle(pickerOptions[row], for: .normal)
            agendaItem.owner = btnOwner.currentTitle!
        }
        
        if pickerTarget == "Status"
        {
            btnStatus.setTitle(pickerOptions[row], for: .normal)
            agendaItem.status = btnStatus.currentTitle!
        }
        
        myPicker.isHidden = true
        showFields()
    }
    
    @IBAction func btnAddAction(_ sender: UIButton)
    {
        let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "tasks") as! taskViewController
        popoverContent.modalPresentationStyle = .popover
        let popover = popoverContent.popoverPresentationController
        popover!.sourceView = sender
        popover!.sourceRect = CGRect(x: 700,y: 700,width: 0,height: 0)
        
        let newTask = task(inTeamID: myCurrentTeam.teamID)
        popoverContent.passedTask = newTask
        
        popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
        
        present(popoverContent, animated: true, completion: nil)
    }
    
    @IBAction func btnOwner(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)

        pickerOptions.append("")
        for attendee in event.attendees
        {
            pickerOptions.append(attendee.name)
        }
        hideFields()
        myPicker.isHidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Owner"
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        pickerOptions.removeAll(keepingCapacity: false)
        pickerOptions.append("Open")
        pickerOptions.append("Closed")
        hideFields()
        myPicker.isHidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Status"
    }
    
    @IBAction func txtTitle(_ sender: UITextField)
    {
        if txtTitle.text != ""
        {
            agendaItem.title = txtTitle.text!
        }
    }
    
    @IBAction func txtTimeAllocation(_ sender: UITextField)
    {
        agendaItem.timeAllocation = Int16(txtTimeAllocation.text!)!
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
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
        lblDescription.isHidden = true
        txtTitle.isHidden = true
        lblOwner.isHidden = true
        btnOwner.isHidden = true
        lblTimeAllocation.isHidden = true
        txtTimeAllocation.isHidden = true
        lblStatus.isHidden = true
        btnStatus.isHidden = true
        lblNotes.isHidden = true
        txtDiscussionNotes.isHidden = true
        lblDecisionMade.isHidden = true
        txtDecisionMade.isHidden = true
        lblActions.isHidden = true
        btnAddAction.isHidden = true
        colActions.isHidden = true
    }
    
    func showFields()
    {
        lblDescription.isHidden = false
        txtTitle.isHidden = false
        lblOwner.isHidden = false
        btnOwner.isHidden = false
        lblTimeAllocation.isHidden = false
        txtTimeAllocation.isHidden = false
        lblStatus.isHidden = false
        btnStatus.isHidden = false
        lblNotes.isHidden = false
        txtDiscussionNotes.isHidden = false
        lblDecisionMade.isHidden = false
        txtDecisionMade.isHidden = false
        lblActions.isHidden = false
        btnAddAction.isHidden = false
        colActions.isHidden = false
    }
    
    func displayTaskOptions(_ sourceView: UIView, workingTask: task) -> UIAlertController
    {
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .actionSheet)
        
        let myOption1 = UIAlertAction(title: "Edit Action", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "tasks") as! taskViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = sourceView
            popover!.sourceRect = CGRect(x: 700,y: 700,width: 0,height: 0)
            
            popoverContent.passedTaskType = "minutes"
            popoverContent.passedEvent = self.event
            popoverContent.passedTask = workingTask
            
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        let myOption2 = UIAlertAction(title: "Action Updates", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "taskUpdate") as! taskUpdatesViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = sourceView
            popover!.sourceRect = CGRect(x: 700,y: 700,width: 0,height: 0)
            
            popoverContent.passedTask = workingTask
            
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        
        return myOptions
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
//   // func identifierForTextArea(_ uiTextObject: AnyObject) -> String
//    func identifier(forTextArea uiTextObject: Any) -> String
//    {
//        var result: String = ""
//
//        
//        if uiTextObject is UITextField
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "txtTitle"
//            }
//        }
//        
//        if uiTextObject is UITextView
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "txtDiscussionNotes"
//            }
//            
//            if (uiTextObject as AnyObject).tag == 2
//            {
//                result = "txtDecisionMade"
//            }
//
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
//    // At this point the app should save state since TextExpander touch is about
//    // to activate.
//    // It especially needs to save the contents of the textview/textfield!
//        
//        agendaItem.title = txtTitle.text!
//        agendaItem.discussionNotes = txtDiscussionNotes.text
//        agendaItem.decisionMade = txtDecisionMade.text
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
////    func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
//
//    public func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String!, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>!) -> Any!
//    {
//        snippetExpanded = true
//
//        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.pointee
//        
//        if "txtDiscussionNotes" == textIdentifier
//        {
//            txtDiscussionNotes.becomeFirstResponder()
//            let theLoc = txtDiscussionNotes.position(from: txtDiscussionNotes.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtDiscussionNotes.selectedTextRange = txtDiscussionNotes.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtDiscussionNotes
//        }
//        else if "txtDecisionMade" == textIdentifier
//        {
//            txtDecisionMade.becomeFirstResponder()
//            let theLoc = txtDecisionMade.position(from: txtDecisionMade.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtDecisionMade.selectedTextRange = txtDecisionMade.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtDecisionMade
//        }
//        else if "txtTitle" == textIdentifier
//        {
//            txtTitle.becomeFirstResponder()
//            let theLoc = txtTitle.position(from: txtTitle.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtTitle.selectedTextRange = txtTitle.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtTitle
//        }
////        else if "mySearchBar" == textIdentifier
////        {
////            searchBar.becomeFirstResponder()
//    // Note: UISearchBar does not support cursor positioning.
//    // Since we don't save search bar text as part of our state, if our app was unloaded while TE was
//    // presenting the fill-in window, the search bar might now be empty to we should return
//    // insertionPointLocation of 0.
////            let searchTextLen = searchBar.text.length
////            if searchTextLen < ioInsertionPointLocation
////            {
////                ioInsertionPointLocation = searchTextLen
////            }
////            return searchBar
////        }
//        else
//        {
//
//            //return nil
//
//            return "" as AnyObject
//        }
//    }
//    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
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
//        println("nextDelegate textViewShouldBeginEditing")
//        return true
//    }
//
//    func textViewShouldEndEditing(textView: UITextView) -> Bool
//    {
//        println("nextDelegate textViewShouldEndEditing")
//        return true
//    }
//    
//    func textViewDidEndEditing(textView: UITextView)
//    {
//        println("nextDelegate textViewDidEndEditing")
//    }
//    
//    func textViewDidChangeSelection(textView: UITextView)
//    {
//        println("nextDelegate textViewDidChangeSelection")
//    }
//
//    // The following are the UITextFieldDelegate methods; they simply write to the console log for demonstration purposes
//    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
//    {
//        println("nextDelegate textFieldShouldBeginEditing")
//        return true
//    }
//    
//    func textFieldDidBeginEditing(textField: UITextField)
//    {
//        println("nextDelegate textFieldDidBeginEditing")
//    }
//    
//    func textFieldShouldEndEditing(textField: UITextField) -> Bool
//    {
//        println("nextDelegate textFieldShouldEndEditing")
//        return true
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField)
//    {
//        println("nextDelegate textFieldDidEndEditing")
//    }
//    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
//    {
//        println("nextDelegate textField:shouldChangeCharactersInRange: \(NSStringFromRange(range)) Original=\(textField.text), replacement = \(string)")
//        return true
//    }
//    
//    func textFieldShouldClear(textField: UITextField) -> Bool
//    {
//        println("nextDelegate textFieldShouldClear")
//        return true
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool
//    {
//        println("nextDelegate textFieldShouldReturn")
//        return true
//    }
//*/
//    
}

class myTaskItemHeader: UICollectionReusableView
{
    @IBOutlet weak var lblTaskStatus: UILabel!
    @IBOutlet weak var lblTaskTargetDate: UILabel!
    @IBOutlet weak var lblTaskOwner: UILabel!
    @IBOutlet weak var lblTaskName: UILabel!
}

class myTaskItem: UICollectionViewCell
{
    @IBOutlet weak var lblTaskStatus: UILabel!
    @IBOutlet weak var lblTaskTargetDate: UILabel!
    @IBOutlet weak var lblTaskOwner: UILabel!
    @IBOutlet weak var lblTaskName: UILabel!

    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }    
}
