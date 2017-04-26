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
    func myTaskListDidFinish(_ controller:taskListViewController)
}

class taskListViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate
{
    var delegate: MyTaskListDelegate?
    var myTaskListType: String = ""
    var myMeetingID: String = ""
    
    @IBOutlet weak var colTaskList: UICollectionView!
    
    fileprivate var myTaskList: [task] = Array()
    
    fileprivate let cellTaskName = "taskCell"
    
    fileprivate var myCells: [cellDetails] = Array()
    fileprivate var headerSize: CGFloat = 0.0
    
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
            
            // Parse through All of the previous meetings that led to this meeting looking for tasks that are not yet closed, as need to display them for completeness
            
            let myMeetingRecords = myDatabaseConnection.loadAgenda(myMeetingID, inTeamID: myCurrentTeam.teamID)
            
            if myMeetingRecords.count == 0
            {
                // No meeting found, so no further action
            }
            else
            {
                for myMeetingRecord in myMeetingRecords
                {
                    if myMeetingRecord.previousMeetingID != ""
                    {
                        let myOutstandingTasks = parsePastMeeting(myMeetingRecord.previousMeetingID!)
                    
                        if myOutstandingTasks.count > 0
                        {
                            for myTask in myOutstandingTasks
                            {
                                myTaskList.append(myTask)
                            }
                        }
                    }
                }
            }
            let myData = myDatabaseConnection.getMeetingsTasks(myMeetingID)
            
            for myItem in myData
            {
                let newTask = task(taskID: myItem.taskID)
                myTaskList.append(newTask)
            }
        }
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(taskListViewController.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(taskListViewController.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
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
        myCells.removeAll()
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return myTaskList.count
    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell : myTaskListItem!
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellTaskName, for: indexPath as IndexPath) as! myTaskListItem
        
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
            cell.txtContext.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        }
        
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = myRowColour
            cell.txtContext.backgroundColor = myRowColour
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
        let myOptions = displayTaskOptions(collectionView, workingTask: myTaskList[indexPath.row])
        myOptions.popoverPresentationController!.sourceView = collectionView
        
        self.present(myOptions, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colTaskList.bounds.size.width, height: 78)
        
        return retVal
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
            
            popoverContent.passedTask = workingTask
            
            if self.myTaskListType == "Meeting"
            {
                popoverContent.passedTaskType = "minutes"
                let myWorkingItem = myCalendarItem(inEventStore: globalEventStore, inMeetingID: self.myMeetingID, teamID: myCurrentTeam.teamID)
                
                popoverContent.passedEvent = myWorkingItem
            }
            
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
