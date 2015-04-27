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

    
    var reminderStore = EKEventStore()
    var targetReminderCal: EKCalendar!
    var myReminder: EKReminder!

    var delegate: MyReminderDelegate?
    var inAction: String!
    var inReminderID: String!
    
    var itemSelected: String = ""

    var priorityOptions = ["High", "Medium", "Low", "None"]

    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var notesText: UITextField!
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
//GRE TODO
        // if type is edit
        // default earlier date picker date to be tomorrow (no due dates in past)
        // save the changes back
        // set to be complete
        // remove a due date
        // do stuff for add
        
        
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
                
                errorLabel.text = "Could not find request Reminder.  Please press 'Cancel' to return to main screen"
            }

        }
        else
        { // Means we are adding a new one
     println("add")
        }
        
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
    
    @IBAction func completeButtonPressed(sender: UIButton) {
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
    }
    
    @IBAction func showDueDateChanged(sender: UISwitch) {
    }
 }
