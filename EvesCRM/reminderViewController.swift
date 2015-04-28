//
//  reminderViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 26/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import EventKit

protocol MyReminderDelegate{
    func myReminderDidFinish(controller:reminderViewController, actionType: String)
}


class reminderViewController: UIViewController {

    
    private var reminderStore = EKEventStore()
    private var targetReminderCal: EKCalendar!
    private var myReminder: EKReminder!
    private var iniitialSwitchState: String = "Off"

    var delegate: MyReminderDelegate?
    var inAction: String!
    var inReminderID: String!
    var inCalendarName: String!
    
    private var itemSelected: String = ""

    private var priorityOptions = ["High", "Medium", "Low", "None"]

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
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var notesText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup the calendar store to give access to Reminders
        
        reminderStore.requestAccessToEntityType(EKEntityTypeReminder,
            completion: {(granted: Bool, error:NSError!) in
                if !granted {
                    println("Access to store not granted")
                }
        })
        
        if inAction == "Edit"
        {

            myReminder = reminderStore.calendarItemWithIdentifier(inReminderID) as! EKReminder
            
            if myReminder != nil
            {
                descriptionText.text = myReminder.title!
                
                if myReminder.hasNotes
                {
                    notesText.text = myReminder.notes
                }
              
                // Get Due Date
                if myReminder.hasAlarms
                {
                    showDueDateSwitch.setOn(true, animated: false)
                    dueDatePicker.date = myReminder.alarms[0].absoluteDate
                    iniitialSwitchState = "On"
                    dueDatePicker.hidden = false
                }
                else
                {
                    showDueDateSwitch.setOn(false, animated: false)
                    dueDatePicker.hidden = true
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
                descriptionText.hidden = true
                notesText.hidden = true
                dueDatePicker.hidden = true
                showDueDateSwitch.hidden = true
                priorityPicker.hidden = true
                descriptionLabel.hidden = true
                notesLabel.hidden = true
                priorityLabel.hidden = true
                dueDateLabel.hidden = true
                errorLabel.hidden = false
                completeButton.hidden = true
                saveButton.hidden = true
                
                errorLabel.text = "Could not find requested Reminder.  Please press 'Cancel' to return to main screen"
            }
        }
        else
        {
            
            completeButton.hidden = true
            
            // Default to no priority
            priorityPicker.selectRow(3, inComponent: 0, animated: true)
            
            dueDatePicker.hidden = true
        }
        
        // Set the earliest date for a Due date to be "tomorrow", ie no due dates can be set for today or the past
        var components = NSDateComponents()
        components.setValue(1, forComponent: NSCalendarUnit.CalendarUnitDay);
        let currDate: NSDate = NSDate()
        var earliestDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: currDate, options: NSCalendarOptions(0))
        dueDatePicker.minimumDate = earliestDate
        
    }
 
    func numberOfComponentsInPickerView(priorityPicker: UIPickerView) -> Int {
        return 1
    }

    func pickerView(inPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return priorityOptions.count
    }
    
    func pickerView(inPicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return priorityOptions[row]
    }
    
    func pickerView(inPicker: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       // actionSelection()
        itemSelected = priorityOptions[row]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     @IBAction func cancelButtonPressed(sender: UIButton) {
        delegate?.myReminderDidFinish(self, actionType: "Cancel")
    }
    
    @IBAction func completeButtonPressed(sender: UIButton)
    {
        
        myReminder.completed = true
        
        var myError : NSError? = nil
        
        reminderStore.saveReminder(myReminder, commit: true, error: &myError)
        
        if myError != nil
        {
            println("Saving event to Calendar failed with error: \(myError!)")
        }
        delegate?.myReminderDidFinish(self, actionType: "Changed")
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {

        // if we are adding a new reminder then need to instantiated it, else it means we are editting so do not need to do anything
        
        var myError : NSError? = nil
        var myCalendar: EKCalendar!
        
        if descriptionText.text == ""
        {
            var alert = UIAlertController(title: "Reminders", message:
                "You have not entered any text for the Reminder", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
        }
        else
        {
            if inAction == "Add"
            {
                // First need to check to see if the Reminder list exists.  if it does not then we need to create it
            
                let myCalendars = reminderStore.calendarsForEntityType(EKEntityTypeReminder) as! [EKCalendar]
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
                    myCalendar = EKCalendar(forEntityType:EKEntityTypeReminder, eventStore:reminderStore)
                    myCalendar.title=inCalendarName
                
                
                    // What are the source options
                
                    for cal in reminderStore.sources()
                    {
                        if cal.title! == "iCloud"
                        {
                            myCalendar.source = cal as! EKSource
                            break
                        }
                    }
    
                    let ok = reminderStore.saveCalendar(myCalendar, commit:true, error:&myError)
                
                    if myError != nil
                    {
                        println("Saving Calendar failed with error: \(myError!)")
                    }
                }
            
                // Now set the calendar for the Reminder
            
                myReminder = EKReminder(eventStore: reminderStore)
                myReminder.calendar = myCalendar
            }

            myReminder.title = descriptionText.text

            myReminder.notes = notesText.text
        
            // need to check if we need to set a due date
            if showDueDateSwitch.on
            {
                // Due date set
                if myReminder.hasAlarms
                {
                    myReminder.removeAlarm(myReminder.alarms[0] as! EKAlarm)
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
                    myReminder.removeAlarm(myReminder.alarms[0] as! EKAlarm)
                }
            }
        
            switch priorityOptions[priorityPicker.selectedRowInComponent(0)]
            {
                case "High":  myReminder.priority = 1 // High priority
                
                case "Medium": myReminder.priority = 5 // Medium priority
                
                case "Low": myReminder.priority = 9 // Low priority
                
                default: myReminder.priority = 0 // No priority
            }
        
            myError = nil
    
            reminderStore.saveReminder(myReminder, commit: true, error: &myError)
        
            if myError != nil
            {
                println("Saving event to Calendar failed with error: \(myError!)")
            }
            delegate?.myReminderDidFinish(self, actionType: "Changed")
        }
    }
    
    @IBAction func showDueDateChanged(sender: UISwitch) {
        if showDueDateSwitch.on
        {
            dueDatePicker.hidden = false
        }
        else
        {
            dueDatePicker.hidden = true
        }
    }
 }
