//
//  taskListViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 11/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit

let NotificationShowTaskUpdate = Notification.Name("NotificationShowTaskUpdate")

class taskListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var tblTasks: UITableView!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var lblNoActions: UILabel!
    
    var delegate: myCommunicationDelegate?
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
                newTask.meetingID = passedMeeting.meetingID
                
                if newTask.status != taskStatusClosed
                {
                    myTaskList.append(newTask)
                }
            }
        }
        else
        {
            myTaskList = tasks(contextID: currentUser.personTaskLink, contextType: personContextType, teamID: currentUser.currentTeam!.teamID, loadAll: false).tasks
        }
        
        if myTaskList.count == 0
        {
            lblNoActions.isHidden = false
            tblTasks.isHidden = true
        }
        else
        {
            lblNoActions.isHidden = true
            tblTasks.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return myTaskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTask", for: indexPath as IndexPath) as! myTaskListItem
        
        if myTaskList[indexPath.row].displayDueDate == ""
        {
            cell.lblTargetDate.text = "No due date set"
        }
        else
        {
            cell.lblTargetDate.text = myTaskList[indexPath.row].displayDueDate
        }

        if myTaskList[indexPath.row].status != ""
        {
            cell.btnStatus.setTitle(myTaskList[indexPath.row].status, for: .normal)
        }
        else
        {
            cell.btnStatus.setTitle("No Status", for: .normal)
        }
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
            cell.lblContext.text = ""
        }
        else if myTaskList[indexPath.row].contexts.count == 1
        {
            cell.lblContext.text = myTaskList[indexPath.row].contexts[0].name
        }
        else
        {
            var tempStr: String = ""
            
            for myItem in myTaskList[indexPath.row].contexts
            {
                if tempStr != ""
                {
                    tempStr += ", "
                }
                tempStr += "\(myItem.name)"
            }
            cell.lblContext.text = tempStr
        }
        
        cell.passedTask = myTaskList[indexPath.row]
        cell.mainView = self
        cell.sourceView = cell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let myOptions = displayTaskOptions(tableView, workingTask: myTaskList[indexPath.row])
        myOptions.popoverPresentationController!.sourceView = tableView
        
        self.present(myOptions, animated: true, completion: nil)
    }
    
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
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
            
            popoverContent.passedTaskType = "minutes"
            let tempMeeting = calendarItem(meetingID: workingTask.meetingID, teamID: workingTask.teamID)
            popoverContent.passedMeeting = tempMeeting
            popoverContent.passedTask = workingTask
            
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

class myTaskListItem: UITableViewCell, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    @IBOutlet weak var lblTargetDate: UILabel!
    @IBOutlet weak var lblProject: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblContext: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    
    var passedTask: task!
    var sourceView: myTaskListItem!
    var mainView: taskListViewController!
    
    private var displayList: [String] = Array()
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }

    @IBAction func btnStatus(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        displayList.append(taskStatusOpen)
        displayList.append(taskStatusClosed)
        displayList.append(taskStatusOnHold)
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            //      pickerView.isModalInPopover = true
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "TaskStatus"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            mainView.present(pickerView, animated: true, completion: nil)
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        // Write code for select
        if source == "TaskStatus"
        {
            btnStatus.setTitle(displayList[selectedItem], for: .normal)
            passedTask.status = btnStatus.currentTitle!
        }
    }
}
