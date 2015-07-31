//
//  meetingTaskViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 22/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MyTaskDelegate
{
    func myTaskDidFinish(controller:taskViewController, actionType: String, currentTask: task)
    func myTaskUpdateDidFinish(controller:taskUpdatesViewController, actionType: String, currentTask: task)
}

class taskViewController: UIViewController
{
    private var passedTask: TaskModel!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblTaskTitle: UILabel!
    @IBOutlet weak var lblTaskDescription: UILabel!
    @IBOutlet weak var lblTargetDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var txtTaskTitle: UITextField!
    @IBOutlet weak var txtTaskDescription: UITextView!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var btnTargetDate: UIButton!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var btnSetTargetDate: UIButton!
    
    private var pickerOptions: [String] = Array()
    private var pickerTarget: String = ""
    private var myStartDate: NSDate!
    private var myDueDate: NSDate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        myDatePicker.hidden = true
        myPicker.hidden = true
        btnSetTargetDate.hidden = true
        
        txtTaskDescription.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtTaskDescription.layer.borderWidth = 0.5
        txtTaskDescription.layer.cornerRadius = 5.0
        txtTaskDescription.layer.masksToBounds = true
        
        passedTask = (tabBarController as! tasksTabViewController).myPassedTask
        
        if passedTask.currentTask.taskID != 0
        {
            // Lets load up the fields
            txtTaskTitle.text = passedTask.currentTask.title
            txtTaskDescription.text = passedTask.currentTask.details
            if passedTask.currentTask.displayDueDate == ""
            {
                btnTargetDate.setTitle("None", forState: .Normal)
            }
            else
            {
                btnTargetDate.setTitle(passedTask.currentTask.displayDueDate, forState: .Normal)
            }
        //    btnOwner.setTitle(passedTask.currentTask., forState: .Normal)
            if passedTask.currentTask.status == ""
            {
                btnStatus.setTitle("Open", forState: .Normal)
            }
            else
            {
                btnStatus.setTitle(passedTask.currentTask.status, forState: .Normal)
            }
            
            myStartDate = passedTask.currentTask.startDate
            myDueDate = passedTask.currentTask.dueDate
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if pickerTarget == "Owner"
        {
            btnOwner.setTitle(pickerOptions[row], forState: .Normal)
        }
        
        if pickerTarget == "Status"
        {
            btnStatus.setTitle(pickerOptions[row], forState: .Normal)
        }
        
        myPicker.hidden = true
        showFields()
    }
    
    @IBAction func btnCancel(sender: UIButton)
    {
        passedTask.delegate.myTaskDidFinish(self, actionType: "Cancel", currentTask: passedTask.currentTask)
    }
    
    @IBAction func btnSave(sender: UIButton)
    {
        passedTask.currentTask.title = txtTaskTitle.text
        passedTask.currentTask.details = txtTaskDescription.text
        passedTask.currentTask.dueDate = myDueDate
        passedTask.currentTask.startDate = myStartDate
        passedTask.currentTask.status = btnStatus.currentTitle!
        //    btnOwner.setTitle(passedTask.currentTask., forState: .Normal)
        
        passedTask.currentTask.save()
        passedTask.delegate.myTaskDidFinish(self, actionType: "Changed", currentTask: passedTask.currentTask)
    }
    
    @IBAction func btnTargetDate(sender: UIButton)
    {
        myDatePicker.datePickerMode = UIDatePickerMode.Date
        hideFields()
        myDatePicker.hidden = false
        btnSetTargetDate.hidden = false
    }
    
    @IBAction func btnOwner(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("Open")
        pickerOptions.append("Closed")
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Owner"
    }
    
    @IBAction func btnStatus(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("Open")
        pickerOptions.append("Closed")
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Status"
    }
    
    @IBAction func btnSetTargetDate(sender: UIButton)
    {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        btnTargetDate.setTitle(dateFormatter.stringFromDate(myDatePicker.date), forState: .Normal)
        myDueDate = myDatePicker.date
        
        myDatePicker.hidden = true
        btnSetTargetDate.hidden = true
        showFields()
    }
    
    func showFields()
    {
        btnCancel.hidden = false
        btnSave.hidden = false
        lblTaskTitle.hidden = false
        lblTaskDescription.hidden = false
        lblTargetDate.hidden = false
        lblStatus.hidden = false
        lblOwner.hidden = false
        txtTaskTitle.hidden = false
        txtTaskDescription.hidden = false
        btnTargetDate.hidden = false
        btnOwner.hidden = false
        btnStatus.hidden = false
    }
    
    func hideFields()
    {
        btnCancel.hidden = true
        btnSave.hidden = true
        lblTaskTitle.hidden = true
        lblTaskDescription.hidden = true
        lblTargetDate.hidden = true
        lblStatus.hidden = true
        lblOwner.hidden = true
        txtTaskTitle.hidden = true
        txtTaskDescription.hidden = true
        btnTargetDate.hidden = true
        btnOwner.hidden = true
        btnStatus.hidden = true
    }
}