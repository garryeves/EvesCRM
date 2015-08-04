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
    @IBOutlet weak var txtTaskTitle: UITextField!
    @IBOutlet weak var txtTaskDescription: UITextView!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var btnTargetDate: UIButton!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var btnSetTargetDate: UIButton!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblContexts: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var colContexts: UICollectionView!
    @IBOutlet weak var lblPriority: UILabel!
    @IBOutlet weak var txtEstTime: UITextField!
    @IBOutlet weak var btnEstTimeInterval: UIButton!
    @IBOutlet weak var lblEstTime: UILabel!
    @IBOutlet weak var btnPriority: UIButton!
    @IBOutlet weak var lblEnergy: UILabel!
    @IBOutlet weak var btnEnergy: UIButton!
    @IBOutlet weak var lblNewContext: UILabel!
    @IBOutlet weak var txtNewContext: UITextField!
    @IBOutlet weak var btnNewContext: UIButton!
    @IBOutlet weak var lblProject: UILabel!
    @IBOutlet weak var btnProject: UIButton!
    
    private var pickerOptions: [String] = Array()
    private var pickerTarget: String = ""
    private var myStartDate: NSDate!
    private var myDueDate: NSDate!
    private var myProjectID: Int = 0
    private var myProjectDetails: [Projects] = Array()
    private var myContexts: [context] = Array()
    
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

            if passedTask.currentTask.displayStartDate == ""
            {
                btnStart.setTitle("None", forState: .Normal)
            }
            else
            {
                btnStart.setTitle(passedTask.currentTask.displayStartDate, forState: .Normal)
            }

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
            
            if passedTask.currentTask.priority == ""
            {
                btnPriority.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnPriority.setTitle(passedTask.currentTask.priority, forState: .Normal)
            }
            
            if passedTask.currentTask.energyLevel == ""
            {
                btnEnergy.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnEnergy.setTitle(passedTask.currentTask.energyLevel, forState: .Normal)
            }
            
            if passedTask.currentTask.estimatedTimeType == ""
            {
                btnEstTimeInterval.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                btnEstTimeInterval.setTitle(passedTask.currentTask.estimatedTimeType, forState: .Normal)
            }
            
            if passedTask.currentTask.projectID == 0
            {
                btnProject.setTitle("Click to set", forState: .Normal)
            }
            else
            {
                // Go an get the project name
                setProjectName(passedTask.currentTask.projectID)
            }

            txtEstTime.text = "\(passedTask.currentTask.estimatedTime)"
            
            lblNewContext.hidden = true
            txtNewContext.hidden = true
            btnNewContext.hidden = true
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeTaskContext:", name:"NotificationRemoveTaskContext", object: nil)

        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        colContexts.collectionViewLayout.invalidateLayout()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return passedTask.currentTask.contexts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell: myContextItem!

        cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseContext", forIndexPath: indexPath) as! myContextItem
        cell.lblContext.text = passedTask.currentTask.contexts[indexPath.row].name
        cell.btnRemove.setTitle("Remove", forState: .Normal)
        cell.btnRemove.tag = passedTask.currentTask.contexts[indexPath.row].contextID
        
  //      var frmPlay : CGRect = cell.lblContext.frame
        
   //     let originXbutton = frmPlay.origin.x
   //     let originYbutton = frmPlay.origin.y
        
   //     let originWidthbutton = frmPlay.size.width
   //     let originHeightbutton = frmPlay.size.height
        
   //     cell.lblContext.frame = frmPlay
        
   //     cell.lblContext.frame = CGRectMake(
   //         originXbutton,
   //         originYbutton,
   //         colContexts.bounds.size.width-100,
   //         originHeightbutton)
    
        cell.lblContext.sizeThatFits(CGSizeMake(colContexts.bounds.size.width - 110, 35))
        cell.btnRemove.sizeThatFits(CGSizeMake(100, 35))
        
    //    cell.lblContext.frame = CGSizeMake(colContexts.bounds.size.width - 110, 35)
    //    cell.btnRemove.frame = CGSizeMake(100, 35)
        
  //      CGSize retval =  CGSizeMake(100, 100)
    //    retval.height += 35; retval.width += 35
        
        
    //    cell.btnRemove.frame.width = myWidth
        
   //     if indexPath.section == 2
   //     {
   //         cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseAction", forIndexPath: indexPath) as! myContextItem
   //         cell.btnRemove.setTitle("Remove", forState: .Normal)
   //         cell.btnRemove.tag = passedTask.currentTask.contexts[indexPath.row].contextID
   //     }
        
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
/*
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {  // Leaving stub in here for use in other collections
        
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
*/
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSize(width: colContexts.bounds.size.width, height: 39)
    }

    func numberOfComponentsInPickerView(TableTypeSelection1: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerOptions.count
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return pickerOptions[row]
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // Write code for select
        if pickerTarget == "Context"
        {
          //  btnOwner.setTitle(pickerOptions[row], forState: .Normal)
            lblNewContext.hidden = true
            txtNewContext.hidden = true
            btnNewContext.hidden = true
        }
        
        if pickerTarget == "Status"
        {
            btnStatus.setTitle(pickerOptions[row], forState: .Normal)
        }
        
        if pickerTarget == "TimeInterval"
        {
            btnEstTimeInterval.setTitle(pickerOptions[row], forState: .Normal)
        }

        if pickerTarget == "Priority"
        {
            btnPriority.setTitle(pickerOptions[row], forState: .Normal)
        }

        if pickerTarget == "Energy"
        {
            btnEnergy.setTitle(pickerOptions[row], forState: .Normal)
        }

        if pickerTarget == "Project"
        {
            setProjectName(myProjectDetails[row].projectID as Int)
        }
        
        if pickerTarget == "Context"
        {
            setContext(myContexts[row].contextID)
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
        if txtTaskTitle.text == ""
        {
            var alert = UIAlertController(title: "Add Task", message:
                "You must provide a description for the Task before you can Save it", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alert, animated: false, completion: nil)
        }
        else
        {
            saveTask()
            passedTask.delegate.myTaskDidFinish(self, actionType: "Changed", currentTask: passedTask.currentTask)
        }
    }
    
    @IBAction func btnTargetDate(sender: UIButton)
    {
        btnSetTargetDate.setTitle("Set Target Date", forState: .Normal)
        pickerTarget = "TargetDate"
        myDatePicker.datePickerMode = UIDatePickerMode.Date
        hideFields()
        myDatePicker.hidden = false
        btnSetTargetDate.hidden = false
    }
    
    @IBAction func btnOwner(sender: UIButton)
    {
        if txtTaskTitle.text == ""
        {
            var alert = UIAlertController(title: "Add Task", message:
                "You must provide a description for the Task before you can add a Context to it", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alert, animated: false, completion: nil)
        }
        else
        {
            saveTask()
    
            lblNewContext.hidden = false
            txtNewContext.hidden = false
            btnNewContext.hidden = false
            txtNewContext.text = ""
        
            let myContextList = contexts()
            
            pickerOptions.removeAll(keepCapacity: false)
            myContexts.removeAll(keepCapacity: false)
            
            for myContext in myContextList.contextsByHierarchy
            {
                pickerOptions.append(myContext.contextHierarchy)
                myContexts.append(myContext)
            }
            
            hideFields()
            
            if pickerOptions.count > 0
            {
                myPicker.hidden = false
                myPicker.reloadAllComponents()
            }
            
            pickerTarget = "Context"
        }
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
        
        if pickerTarget == "TargetDate"
        {
            btnTargetDate.setTitle(dateFormatter.stringFromDate(myDatePicker.date), forState: .Normal)
            myDueDate = myDatePicker.date
            btnSetTargetDate.hidden = true
        }
        else
        {
            btnStart.setTitle(dateFormatter.stringFromDate(myDatePicker.date), forState: .Normal)
            myStartDate = myDatePicker.date
            btnSetTargetDate.hidden = true
        }
        
        myDatePicker.hidden = true
        
        showFields()
    }
    
    @IBAction func btnStart(sender: UIButton)
    {
        btnSetTargetDate.setTitle("Set Start Date", forState: .Normal)
        pickerTarget = "StartDate"
        myDatePicker.datePickerMode = UIDatePickerMode.Date
        hideFields()
        myDatePicker.hidden = false
        btnSetTargetDate.hidden = false
    }
    
    @IBAction func btnEstTimeInterval(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("Minutes")
        pickerOptions.append("Hours")
        pickerOptions.append("Days")
        pickerOptions.append("Weeks")
        pickerOptions.append("Months")
        pickerOptions.append("Years")
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "TimeInterval"
    }
    
    @IBAction func btnPriority(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("High")
        pickerOptions.append("Medium")
        pickerOptions.append("Low")
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Priority"
    }
    
    @IBAction func btnEnergy(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("High")
        pickerOptions.append("Medium")
        pickerOptions.append("Low")
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Energy"
    }
    
    @IBAction func btnNewContext(sender: UIButton)
    {
        var matchFound: Bool = false
        
        if txtNewContext.text == ""
        {
            var alert = UIAlertController(title: "Add Context", message:
                "You must provide a description for the Context before you can Add it", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alert, animated: false, completion: nil)
        }
        else
        {
            // first lets see if there is already a context with this name
            let myContextList = contexts()
        
            for myContext in myContextList.contexts
            {
                if myContext.name.lowercaseString == txtNewContext.text.lowercaseString
                {
                    // Exisiting context found, so use this record
              
                    setContext(myContext.contextID)
                    matchFound = true
                    break
                }
            }
        
            // if no match then create context

            if !matchFound
            {
                let myNewContext = context()
                myNewContext.name = txtNewContext.text
                myNewContext.save()
            
                setContext(myNewContext.contextID)
            }
        }
        lblNewContext.hidden = true
        txtNewContext.hidden = true
        btnNewContext.hidden = true
        myPicker.hidden = true
        showFields()
    }
    
    @IBAction func btnProject(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        myProjectDetails.removeAll(keepCapacity: false)
        
        let myProjects = myDatabaseConnection.getAllOpenProjects()
        
        for myProject in myProjects
        {
            pickerOptions.append(myProject.projectName)
            myProjectDetails.append(myProject)
        }
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Project"
    }
    
    func showFields()
    {
        btnCancel.hidden = false
        btnSave.hidden = false
        lblTaskTitle.hidden = false
        lblTaskDescription.hidden = false
        lblTargetDate.hidden = false
        lblStatus.hidden = false
        txtTaskTitle.hidden = false
        txtTaskDescription.hidden = false
        btnTargetDate.hidden = false
        btnOwner.hidden = false
        btnStatus.hidden = false
        lblStart.hidden = false
        lblContexts.hidden = false
        btnStart.hidden = false
        colContexts.hidden = false
        lblPriority.hidden = false
        txtEstTime.hidden = false
        btnEstTimeInterval.hidden = false
        lblEstTime.hidden = false
        btnPriority.hidden = false
        lblEnergy.hidden = false
        btnEnergy.hidden = false
        lblProject.hidden = false
        btnProject.hidden = false
    }
    
    func hideFields()
    {
        btnCancel.hidden = true
        btnSave.hidden = true
        lblTaskTitle.hidden = true
        lblTaskDescription.hidden = true
        lblTargetDate.hidden = true
        lblStatus.hidden = true
        txtTaskTitle.hidden = true
        txtTaskDescription.hidden = true
        btnTargetDate.hidden = true
        btnOwner.hidden = true
        btnStatus.hidden = true
        lblStart.hidden = true
        lblContexts.hidden = true
        btnStart.hidden = true
        colContexts.hidden = true
        lblPriority.hidden = true
        txtEstTime.hidden = true
        btnEstTimeInterval.hidden = true
        lblEstTime.hidden = true
        btnPriority.hidden = true
        lblEnergy.hidden = true
        btnEnergy.hidden = true
        lblProject.hidden = true
        btnProject.hidden = true
    }
    
    func saveTask()
    {
        passedTask.currentTask.title = txtTaskTitle.text
        passedTask.currentTask.details = txtTaskDescription.text
        passedTask.currentTask.dueDate = myDueDate
        passedTask.currentTask.startDate = myStartDate
        passedTask.currentTask.status = btnStatus.currentTitle!
        passedTask.currentTask.priority = btnPriority.currentTitle!
        passedTask.currentTask.energyLevel = btnEnergy.currentTitle!
        passedTask.currentTask.estimatedTime = txtEstTime.text.toInt()!
        passedTask.currentTask.estimatedTimeType = btnEstTimeInterval.currentTitle!
        passedTask.currentTask.projectID = myProjectID
            
        passedTask.currentTask.save()
    }
    
    func setProjectName(inProjectID: Int)
    {
        let myProjects = myDatabaseConnection.getProjectDetails(inProjectID)
        
        if myProjects.count == 0
        {
            btnProject.setTitle("Click to set", forState: .Normal)
            myProjectID = 0
        }
        else
        {
            btnProject.setTitle(myProjects[0].projectName, forState: .Normal)
            myProjectID = myProjects[0].projectID as Int
        }
    }
    
    func setContext(inContextID: Int)
    {
        passedTask.currentTask.addContextToTask(inContextID)
        
        // Reload the collection data
        
        colContexts.reloadData()
    }
    
    func removeTaskContext(notification: NSNotification)
    {
        let contextToRemove = notification.userInfo!["itemNo"] as! Int
        
        passedTask.currentTask.removeContextFromTask(contextToRemove)
        
        // Reload the collection data
        
        colContexts.reloadData()
    }
}

class myContextItem: UICollectionViewCell
{
    @IBOutlet weak var lblContext: UILabel!
    @IBOutlet weak var btnRemove: UIButton!

    @IBAction func btnRemove(sender: UIButton)
    {
        if btnRemove.currentTitle == "Remove"
        {
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationRemoveTaskContext", object: nil, userInfo:["itemNo":btnRemove.tag])
        }
    }
}