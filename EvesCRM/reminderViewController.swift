//
//  reminderViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 26/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import EventKit
import TextExpander

protocol MyReminderDelegate{
    func myReminderDidFinish(_ controller:reminderViewController, actionType: String)
}


class reminderViewController: UIViewController, UITextViewDelegate, SMTEFillDelegate
{
    fileprivate var reminderStore = EKEventStore()
    fileprivate var targetReminderCal: EKCalendar!
    fileprivate var myReminder: EKReminder!
    fileprivate var iniitialSwitchState: String = "Off"

    var delegate: MyReminderDelegate?
    var inAction: String!
    var inReminderID: String!
    var inCalendarName: String!
    var myDisplayType: String!
    var myProjectName: String!

    fileprivate var itemSelected: String = ""

    fileprivate var priorityOptions = ["High", "Medium", "Low", "None"]

    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var showDueDateSwitch: UISwitch!
    @IBOutlet weak var priorityPicker: UIPickerView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var notesText: UITextView!
   
    // Textexpander
    
    fileprivate var snippetExpanded: Bool = false
    
    var textExpander: SMTEDelegateController!

    private var isChanged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup the calendar store to give access to Reminders
        
        reminderStore.requestAccess(to: EKEntityType.reminder,
            completion: {(granted: Bool, error: Error?) -> Void in
                if !granted
                {
                    print("Access to store not granted")
                }
        })
        
        if inAction == "Edit"
        {

            myReminder = reminderStore.calendarItem(withIdentifier: inReminderID) as! EKReminder
            
            if myReminder != nil
            {
                descriptionText.text = myReminder.title
                
                if myReminder.hasNotes
                {
                    notesText.text = myReminder.notes
                }
              
                // Get Due Date
                if myReminder.hasAlarms
                {
                    showDueDateSwitch.setOn(true, animated: false)
                    for tempAlarm in myReminder.alarms!
                    {
                        dueDatePicker.date = tempAlarm.absoluteDate!
                        break
                    }
                    
                    iniitialSwitchState = "On"
                    dueDatePicker.isHidden = false
                }
                else
                {
                    showDueDateSwitch.setOn(false, animated: false)
                    dueDatePicker.isHidden = true
                }
                
                // display priority
                switch myReminder.priority
                {
                case 1: priorityPicker.selectRow(0, inComponent: 0, animated: true) // High priority
                    
                case 5: priorityPicker.selectRow(1, inComponent: 0, animated: true) // Medium priority
                    
                case 9: priorityPicker.selectRow(2, inComponent: 0, animated: true) // Low priority

                default: priorityPicker.selectRow(3, inComponent: 0, animated: true) // No priority
                }
            }
            else
            {
                descriptionText.isHidden = true
                notesText.isHidden = true
                dueDatePicker.isHidden = true
                showDueDateSwitch.isHidden = true
                priorityPicker.isHidden = true
                descriptionLabel.isHidden = true
                notesLabel.isHidden = true
                priorityLabel.isHidden = true
                dueDateLabel.isHidden = true
                errorLabel.isHidden = false
                completeButton.isHidden = true
                
                errorLabel.text = "Could not find requested Reminder.  Please press 'Cancel' to return to main screen"
            }
        }
        else
        {
            
            completeButton.isHidden = true
            
            // Default to no priority
            priorityPicker.selectRow(3, inComponent: 0, animated: true)
            
            dueDatePicker.isHidden = true
        }
        
        // Set the earliest date for a Due date to be "tomorrow", ie no due dates can be set for today or the past
        let earliestDate = Calendar.current.date(
                            byAdding: .day,
                            value: 1,
                            to: Date())
        
        dueDatePicker.minimumDate = earliestDate
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        notesText.layer.borderWidth = 0.5
        notesText.layer.borderColor = borderColor.cgColor
        notesText.layer.cornerRadius = 5.0
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(reminderViewController.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(reminderViewController.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        notesText.layer.borderColor = UIColor.lightGray.cgColor
        notesText.layer.borderWidth = 0.5
        notesText.layer.cornerRadius = 5.0
        notesText.layer.masksToBounds = true
        notesText.delegate = self

        // TextExpander
        textExpander = SMTEDelegateController()
        descriptionText.delegate = textExpander
        notesText.delegate = textExpander
        textExpander.clientAppName = "EvesCRM"
        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
        textExpander.fillDelegate = self
        textExpander.nextDelegate = self
        myCurrentViewController = reminderViewController()
        myCurrentViewController = self
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        descriptionText.endEditing(true)
        notesText.endEditing(true)
    }
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
        {
            // Do nothing
        }
        else
        {
            if isChanged
            {
                delegate?.myReminderDidFinish(self, actionType: "Changed")
            }
            else
            {
                delegate?.myReminderDidFinish(self, actionType: "Cancel")
            }
        }
    }

    func numberOfComponentsInPickerView(_ priorityPicker: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ inPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return priorityOptions.count
    }
    
    func pickerView(_ inPicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return priorityOptions[row]
    }
    
    func pickerView(_ inPicker: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       // actionSelection()
        itemSelected = priorityOptions[row]
        save()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton)
    {
        
        myReminder.isCompleted = true
        
        var myError : NSError? = nil
        
        do {
            try reminderStore.save(myReminder, commit: true)
        } catch let error as NSError {
            myError = error
        }
        
        if myError != nil
        {
            print("Saving event to Calendar failed with error: \(myError!)")
        }
        delegate?.myReminderDidFinish(self, actionType: "Changed")
    }
    
    @IBAction func showDueDateChanged(_ sender: UISwitch)
    {
        if showDueDateSwitch.isOn
        {
            dueDatePicker.isHidden = false
        }
        else
        {
            dueDatePicker.isHidden = true
        }
        save()
    }
    
    @IBAction func txtDescription(_ sender: UITextField)
    {
        if descriptionText.text == ""
        {
            let alert = UIAlertController(title: "Reminders", message:
                "You have not entered any text for the Reminder", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                handler: nil))
            
            
            descriptionText.becomeFirstResponder()
        }
        else
        {
            save()
        }
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker)
    {
        save()
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    { //Handle the text changes here
        
        if textView == notesText
        {
            save()
        }
    }
    
    func save()
    {
        var myError : NSError? = nil
        var myCalendar: EKCalendar!
        
        if inAction == "Add"
        {
            // First need to check to see if the Reminder list exists.  if it does not then we need to create it
            
            let myCalendars = reminderStore.calendars(for: EKEntityType.reminder) 
            var calExists = false
            for calendar in myCalendars
            {
                if calendar.title == inCalendarName
                {
                    calExists = true
                    myCalendar = calendar
                }
            }
            
            myError = nil
            if !calExists
            {
                myCalendar = EKCalendar(for:EKEntityType.reminder, eventStore:reminderStore)
                myCalendar.title=inCalendarName
                
                
                // What are the source options
                
                for cal in reminderStore.sources
                {
                    if cal.title == "iCloud"
                    {
                        myCalendar.source = cal
                        break
                    }
                }
                
                do
                {
                    try reminderStore.saveCalendar(myCalendar, commit:true)
                }
                catch let error as NSError
                {
                    myError = error
                }
                
                if myError != nil
                {
                    print("Saving Calendar failed with error: \(myError!)")
                }
            }
            
            // Now set the calendar for the Reminder
            
            myReminder = EKReminder(eventStore: reminderStore)
            myReminder.calendar = myCalendar
            
            inAction = "Edit"
        }
        
        myReminder.title = descriptionText.text!
        
        myReminder.notes = notesText.text
        
        // need to check if we need to set a due date
        if showDueDateSwitch.isOn
        {
            // Due date set
            if myReminder.hasAlarms
            {
                for tempAlarm in myReminder.alarms!
                {
                    myReminder.removeAlarm(tempAlarm)
                    break
                }
            }
            let myAlarm = EKAlarm(absoluteDate: dueDatePicker.date)
            
            myReminder.addAlarm(myAlarm)
        }
        else
        {
            // Due date not set
            // if due date was set when we went into edit mode the need to "unset" it
            if iniitialSwitchState == "On"
            {
                // We had a due date at the start so need to "unset" the date
                if myReminder.hasAlarms
                {
                    for tempAlarm in myReminder.alarms!
                    {
                        myReminder.removeAlarm(tempAlarm)
                        break
                    }
                }
            }
        }
        
        switch priorityOptions[priorityPicker.selectedRow(inComponent: 0)]
        {
        case "High":  myReminder.priority = 1 // High priority
            
        case "Medium": myReminder.priority = 5 // Medium priority
            
        case "Low": myReminder.priority = 9 // Low priority
            
        default: myReminder.priority = 0 // No priority
        }
        
        myError = nil
        
        do {
            try reminderStore.save(myReminder, commit: true)
        } catch let error as NSError {
            myError = error
        }
        
        if myError != nil
        {
            print("Saving event to Calendar failed with error: \(myError!)")
        }
        
        isChanged = true
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
    
    //func identifierForTextArea(_ uiTextObject: AnyObject) -> String
    func identifier(forTextArea uiTextObject: Any) -> String
    {
        var result: String = ""

        if uiTextObject is UITextField
        {
            if (uiTextObject as AnyObject).tag == 1
            {
                result = "descriptionText"
            }
        }
        
        if uiTextObject is UITextView
        {
            if (uiTextObject as AnyObject).tag == 1
            {
                result = "notesText"
            }
        }
        
        if uiTextObject is UISearchBar
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

    func prepare(forFillSwitch textIdentifier: String) -> Bool
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
    
    // func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
    public func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String!, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>!) -> Any!
    {
        snippetExpanded = true
        
        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.pointee
        
        if "descriptionText" == textIdentifier
        {
            descriptionText.becomeFirstResponder()
            let theLoc = descriptionText.position(from: descriptionText.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                descriptionText.selectedTextRange = descriptionText.textRange(from: theLoc!, to: theLoc!)
            }
            return descriptionText
        }
        else if "notesText" == textIdentifier
        {
            notesText.becomeFirstResponder()
            let theLoc = notesText.position(from: notesText.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                notesText.selectedTextRange = notesText.textRange(from: theLoc!, to: theLoc!)
            }
            return notesText
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
            
            return "" as AnyObject
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
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
    
    func twiddleText(_ textView: UITextView)
    {
        let SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO = UIDevice.current.systemVersion
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO >= "7.0"
        {
            textView.textStorage.edited(NSTextStorageEditActions.editedCharacters,range:NSMakeRange(0, textView.textStorage.length),changeInLength:0)
        }
    }
    
    func textViewDidChange(_ textView: UITextView)
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
