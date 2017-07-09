//
//  taskListViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 11/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit

protocol MyTaskListDelegate
{
    func myTaskListDidFinish(_ controller:taskListViewController)
}

let NotificationShowTaskUpdate = Notification.Name("NotificationShowTaskUpdate")

class taskListViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var colTaskList: UICollectionView!
    @IBOutlet weak var displayViewHeight: NSLayoutConstraint!

    var delegate: MyTaskListDelegate?
    var myTaskListType: String = ""
    var passedMeeting: calendarItem!
    
    fileprivate var myTaskList: [task] = Array()
    
    fileprivate var headerSize: CGFloat = 0.0
    fileprivate var kbHeight: CGFloat = 0.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
 
        if passedMeeting != nil
        {
            // Only load Items associated with Meeting
            
            // Get list of tasks for the meeting
            
            // Parse through All of the previous meetings that led to this meeting looking for tasks that are not yet closed, as need to display them for completeness
            
            if passedMeeting.previousMinutes != ""
            {
                let myOutstandingTasks = parsePastMeeting(passedMeeting.previousMinutes, teamID: currentUser.currentTeam!.teamID)
            
                if myOutstandingTasks.count > 0
                {
                    for myTask in myOutstandingTasks
                    {
                        myTaskList.append(myTask)
                    }
                }
            }
            
            let myData = myDatabaseConnection.getMeetingsTasks(passedMeeting.meetingID, teamID: currentUser.currentTeam!.teamID)
                
            for myItem in myData
            {
                let newTask = task(taskID: Int(myItem.taskID), teamID: currentUser.currentTeam!.teamID)
                myTaskList.append(newTask)
            }
        }
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.showUpdates(_:)), name: NotificationShowTaskUpdate, object: nil)
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
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
        {
            // Do nothing
        }
        else
        {
            delegate?.myTaskListDidFinish(self)
        }
    }

    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return myTaskList.count
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell : myTaskListItem!

        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taskCell", for: indexPath as IndexPath) as! myTaskListItem
        
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
            
            let myData = myDatabaseConnection.getProjectDetails(myTaskList[indexPath.row].projectID, teamID: currentUser.currentTeam!.teamID)
            
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
                cell.txtContext.text = ""
             //   cell.txtContext.text = myTaskList[indexPath.row].contexts[0].name
            }
            else
            {
                cell.txtContext.text = ""
//                for myItem in myTaskList[indexPath.row].contexts
//                {
//                    cell.txtContext.text = "\(cell.txtContext.text)\(myItem.name)\n"
//                }
            }
            cell.txtContext.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            
            cell.passedTask = myTaskList[indexPath.row]
        }
        
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = greenColour
            cell.txtContext.backgroundColor = greenColour
        }
        else
        {
            cell.backgroundColor = UIColor.clear
            cell.txtContext.backgroundColor = UIColor.clear
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
        let taskViewControl = tasksStoryboard.instantiateViewController(withIdentifier: "tasks") as! taskViewController
        taskViewControl.passedTask = myTaskList[indexPath.row]
        if self.myTaskListType == "Meeting"
        {
            taskViewControl.passedMeeting = passedMeeting
            taskViewControl.passedTaskType = "minutes"
        }
        
        removeExistingViews(displayView)
        
        taskViewControl.view.frame = CGRect(x: 0, y: 0, width: displayView.frame.size.width, height: displayView.frame.size.height)
        addChildViewController(taskViewControl)
        displayView.addSubview(taskViewControl.view)
        taskViewControl.didMove(toParentViewController: self)
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colTaskList.bounds.size.width, height: 78)
        
        return retVal
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showUpdates(_ notification: Notification)
    {
        let passedTask = notification.userInfo!["Task"] as! task
    
        let taskUpdateControl = tasksStoryboard.instantiateViewController(withIdentifier: "taskUpdate") as! taskUpdatesViewController
        taskUpdateControl.passedTask = passedTask
        
        removeExistingViews(displayView)
        
        taskUpdateControl.view.frame = CGRect(x: 0, y: 0, width: displayView.frame.size.width, height: displayView.frame.size.height)
        addChildViewController(taskUpdateControl)
        displayView.addSubview(taskUpdateControl.view)
        taskUpdateControl.didMove(toParentViewController: self)
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        if let userInfo = notification.userInfo
        {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            {
                if kbHeight != keyboardSize.height
                {
                    let currentKBSize = kbHeight
                    kbHeight = keyboardSize.height
                
                    let newHeight = colTaskList.frame.size.height + currentKBSize - kbHeight
                    
                    let tempSize = CGRect(x: colTaskList.frame.origin.x, y: colTaskList.frame.origin.y, width: colTaskList.frame.size.width, height: newHeight)
                
                    colTaskList.frame = tempSize

                    displayViewHeight.constant = 500 + kbHeight
   //                 updateViewConstraints()
                }
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        if kbHeight > 0.0
        {
            let tempSize = CGRect(x: colTaskList.frame.origin.x, y: colTaskList.frame.origin.y, width: colTaskList.frame.size.width, height: colTaskList.frame.size.height + kbHeight)
            
            colTaskList.frame = tempSize

            displayViewHeight.constant = 500
            
            kbHeight = 0.0
            
            updateViewConstraints()
        }
    }
}

class myTaskListItem: UICollectionViewCell
{
    @IBOutlet weak var lblTargetDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblProject: UILabel!
    @IBOutlet weak var txtContext: UITextView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnTaskUpdates: UIButton!
    
    var passedTask: task!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    @IBAction func btnTaskUpdates(_ sender: UIButton)
    {
        notificationCenter.post(name: NotificationShowTaskUpdate, object: nil, userInfo:["Task":passedTask])
    }
}
