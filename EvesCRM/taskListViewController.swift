//
//  taskListViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 11/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MyTaskListDelegate
{
    func myTaskListDidFinish(controller:taskListViewController)
}

class taskListViewController: UIViewController, MyTaskDelegate, UITextViewDelegate
{
    var delegate: MyTaskListDelegate?
    var myTaskListType: String = ""
    var myMeetingID: String = ""
    
    @IBOutlet weak var colTaskList: UICollectionView!
    
    private var myTaskList: [task] = Array()
    
    private let cellTaskName = "taskCell"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if myMeetingID == ""
        {
            // Load up full task list
        }
        else
        {
            // Only load Items associated with Meeting
            
            // Get list of tasks for the meeting
            
            let myData = myDatabaseConnection.getMeetingsTasks(myMeetingID)
            
            for myItem in myData
            {
                let newTask = task(inTaskID: myItem.taskID as Int)
                myTaskList.append(newTask)
            }
        }
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        colTaskList.collectionViewLayout.invalidateLayout()
        
        colTaskList.reloadData()
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            delegate?.myTaskListDidFinish(self)
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return myTaskList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell : myTaskListItem!
        
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellTaskName, forIndexPath: indexPath) as! myTaskListItem
        
        if myTaskList.count == 0
        {
            cell.lblTargetDate.text = ""
            cell.lblStatus.text = ""
            cell.lblProject.text = ""
            cell.lblDescription.text = ""
            cell.txtContext.text = ""
        }
        else
        {
            if myTaskList[indexPath.row].displayDueDate == ""
            {
                cell.lblTargetDate.text = "No due date set"
            }
            else
            {
                cell.lblTargetDate.text = myTaskList[indexPath.row].displayDueDate
            }
            
            cell.lblStatus.text = myTaskList[indexPath.row].status
            
            // Get the project name to display
            
            let myData = myDatabaseConnection.getProjectDetails(myTaskList[indexPath.row].projectID)
            
            if myData.count == 0
            {
                cell.lblProject.text = "No project set"
            }
            else
            {
                cell.lblProject.text = myData[0].projectName
            }
            
            cell.lblDescription.text = myTaskList[indexPath.row].title
            if myTaskList[indexPath.row].contexts.count == 0
            {
                cell.txtContext.text = ""
            }
            else if myTaskList[indexPath.row].contexts.count == 1
            {
                cell.txtContext.text = myTaskList[indexPath.row].contexts[0].name
            }
            else
            {
                cell.txtContext.text = ""
                for myItem in myTaskList[indexPath.row].contexts
                {
                    cell.txtContext.text = "\(cell.txtContext.text)\(myItem.name)\n"
                }
            }
            cell.txtContext.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
        
        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = swiftColor
            cell.txtContext.backgroundColor = swiftColor
        }
        else
        {
            cell.backgroundColor = UIColor.clearColor()
            cell.txtContext.backgroundColor = UIColor.clearColor()
        }
        
        cell.layoutSubviews()
        
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let taskViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("taskTab") as! tasksTabViewController
        
        var myPassedTask = TaskModel()
        if myTaskListType == "Meeting"
        {
            myPassedTask.taskType = "minutes"
            let myWorkingItem = myCalendarItem(inEventStore: eventStore, inMeetingID: myMeetingID)
            
            myPassedTask.event = myWorkingItem
        }
        else
        {
            myPassedTask.taskType = ""
        }
        myPassedTask.currentTask = myTaskList[indexPath.row]
        myPassedTask.delegate = self
        taskViewControl.myPassedTask = myPassedTask
        
        self.presentViewController(taskViewControl, animated: true, completion: nil)
    }
    
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colTaskList.bounds.size.width, height: 78)
        
        return retVal
    }
    
    func myTaskDidFinish(controller:taskViewController, actionType: String, currentTask: task)
    {
        // reload the task Items collection view
        
        // Associate the task with the meeting
        
        colTaskList.reloadData()
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func myTaskUpdateDidFinish(controller:taskUpdatesViewController, actionType: String, currentTask: task)
    {
        colTaskList.reloadData()
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

class myTaskListItem: UICollectionViewCell
{

    @IBOutlet weak var lblTargetDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblProject: UILabel!
    @IBOutlet weak var txtContext: UITextView!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}