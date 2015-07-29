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
    func myTaskDidFinish(controller:taskViewController, actionType: String)
}

class taskViewController: UIViewController
{
    var delegate: MyTaskDelegate?
    var taskType: String = ""
    
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
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell : myHistory!
        
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(resuseID, forIndexPath: indexPath) as! myHistory
        cell.lblDate.text = "Name"
        cell.txtUpdate.text = "Status"
        cell.lblSource.text = "Owner"

        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = swiftColor
        }
        else
        {
            cell.backgroundColor = UIColor.clearColor()
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
        
        retVal = CGSize(width: colHistory.bounds.size.width, height: 39)
        
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
        delegate?.myTaskDidFinish(self, actionType: "Cancel")
    }
    
    @IBAction func btnSave(sender: UIButton)
    {
        delegate?.myTaskDidFinish(self, actionType: "Changed")
    }
    
    @IBAction func btnAddUpdate(sender: UIButton)
    {

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