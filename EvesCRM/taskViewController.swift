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
}

class taskViewController: UIViewController
{
    var delegate: MyTaskDelegate?
    var taskType: String = ""
    var myTask: task!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblTaskTitle: UILabel!
    @IBOutlet weak var lblTaskDescription: UILabel!
    @IBOutlet weak var lblTargetDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblUpdateHistory: UILabel!
    @IBOutlet weak var lblAddUpdate: UILabel!
    @IBOutlet weak var lblUpdateSource: UILabel!
    @IBOutlet weak var lblUpdateDetails: UILabel!
    @IBOutlet weak var btnAddUpdate: UIButton!
    @IBOutlet weak var txtTaskTitle: UITextField!
    @IBOutlet weak var txtTaskDescription: UITextView!
    @IBOutlet weak var txtUpdateSource: UITextField!
    @IBOutlet weak var txtUpdateDetails: UITextView!
    @IBOutlet weak var colHistory: UICollectionView!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var btnTargetDate: UIButton!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var btnSetTargetDate: UIButton!
    
    private let resuseID = "historyCell"
    
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
        
        txtUpdateDetails.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtUpdateDetails.layer.borderWidth = 0.5
        txtUpdateDetails.layer.cornerRadius = 5.0
        txtUpdateDetails.layer.masksToBounds = true
        
        if myTask.taskID != 0
        {
            // Lets load up the fields
            txtTaskTitle.text = myTask.title
            txtTaskDescription.text = myTask.details
            if myTask.displayDueDate == ""
            {
                btnTargetDate.setTitle("None", forState: .Normal)
            }
            else
            {
                btnTargetDate.setTitle(myTask.displayDueDate, forState: .Normal)
            }
        //    btnOwner.setTitle(myTask., forState: .Normal)
            if myTask.status == ""
            {
                btnStatus.setTitle("Open", forState: .Normal)
            }
            else
            {
                btnStatus.setTitle(myTask.status, forState: .Normal)
            }
            
            myStartDate = myTask.startDate
            myDueDate = myTask.dueDate
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        colHistory.collectionViewLayout.invalidateLayout()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return myTask.history.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell : myHistory!
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(resuseID, forIndexPath: indexPath) as! myHistory
 
        if myTask.history.count > 0
        {
            cell.lblDate.text = myTask.history[indexPath.row].displayUpdateDate
            cell.lblSource.text = myTask.history[indexPath.row].source
            cell.txtUpdate.text = myTask.history[indexPath.row].details
            
            let fixedWidth = cell.txtUpdate.frame.size.width
            cell.txtUpdate.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            let newSize = cell.txtUpdate.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            var newFrame = cell.txtUpdate.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            cell.txtUpdate.frame = newFrame;
        }
        else
        {
            cell.lblDate.text = ""
            cell.txtUpdate.text = ""
            cell.lblSource.text = ""
        }
        
        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = swiftColor
            cell.txtUpdate.backgroundColor = swiftColor
        }
        else
        {
            cell.backgroundColor = UIColor.clearColor()
            cell.txtUpdate.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var headerView:UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader
        {
            headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "taskItemHeader", forIndexPath: indexPath) as! UICollectionReusableView
        }
        
        return headerView
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colHistory.bounds.size.width, height: 80)
        
        //retVal = CGSize(width: colHistory.bounds.size.width, height: 39)
        
        return retVal
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
        delegate?.myTaskDidFinish(self, actionType: "Cancel", currentTask: myTask)
    }
    
    @IBAction func btnSave(sender: UIButton)
    {
        myTask.title = txtTaskTitle.text
        myTask.details = txtTaskDescription.text
        myTask.dueDate = myDueDate
        myTask.startDate = myStartDate
        myTask.status = btnStatus.currentTitle!
        //    btnOwner.setTitle(myTask., forState: .Normal)
        
        myTask.save()
        delegate?.myTaskDidFinish(self, actionType: "Changed", currentTask: myTask)
    }
    
    @IBAction func btnAddUpdate(sender: UIButton)
    {
        if count(txtUpdateDetails.text) > 0 && count(txtUpdateSource.text) > 0
        {
            myTask.addHistoryRecord(txtUpdateDetails.text, inHistorySource: txtUpdateSource.text)
            txtUpdateDetails.text = ""
            txtUpdateSource.text = ""
            colHistory.reloadData()
        }
        else
        {
            var alert = UIAlertController(title: "Add Task Update", message:
                "You need to enter update details and source", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
        }
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
        lblUpdateHistory.hidden = false
        lblAddUpdate.hidden = false
        lblUpdateSource.hidden = false
        lblUpdateDetails.hidden = false
        btnAddUpdate.hidden = false
        txtTaskTitle.hidden = false
        txtTaskDescription.hidden = false
        txtUpdateSource.hidden = false
        txtUpdateDetails.hidden = false
        colHistory.hidden = false
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
        lblUpdateHistory.hidden = true
        lblAddUpdate.hidden = true
        lblUpdateSource.hidden = true
        lblUpdateDetails.hidden = true
        btnAddUpdate.hidden = true
        txtTaskTitle.hidden = true
        txtTaskDescription.hidden = true
        txtUpdateSource.hidden = true
        txtUpdateDetails.hidden = true
        colHistory.hidden = true
        btnTargetDate.hidden = true
        btnOwner.hidden = true
        btnStatus.hidden = true
    }

}

class myHistory: UICollectionViewCell
{
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var txtUpdate: UITextView!
    @IBOutlet weak var lblSource: UILabel!
}