//
//  mainViewController.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 22/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class mainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, meetingCommunicationDelegate
{
    @IBOutlet weak var lblMeetings: UILabel!
    @IBOutlet weak var tblMeetings: UITableView!
    @IBOutlet weak var tblCalendar: UITableView!
    @IBOutlet weak var displayView: UIView!
    
    private var meetingDisplay: [TableData] = Array()
    private var eventDisplayList: [TableData] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        connectEventStore()
        
        checkCalendarConnected(globalEventStore)
        
        myTeams = teams()
        
        meetingUpdated()        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblMeetings:
                return meetingDisplay.count
                
            case tblCalendar:
                return eventDisplayList.count
                
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblMeetings:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellMeeting", for: indexPath) as! meetingItemHeader

                if meetingDisplay[indexPath.row].calendarItem == nil
                {
                    cell.lblTime.text = meetingDisplay[indexPath.row].displayText
                    cell.lblTitle.text = ""
                    cell.lblTime.font = UIFont.boldSystemFont(ofSize: lblMeetings.font.pointSize)
                    cell.accessoryType = .disclosureIndicator
                }
                else
                {
                    cell.lblTime.text = meetingDisplay[indexPath.row].calendarItem?.displayStartDate
                    cell.lblTitle.text = meetingDisplay[indexPath.row].displayText
                    cell.lblTime.font = UIFont.systemFont(ofSize: cell.lblTitle.font.pointSize)
                    cell.accessoryType = .none
                }
                
                return cell
                
            case tblCalendar:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellCalendar", for: indexPath) as! meetingItemHeader
                
                cell.lblTime.text = eventDisplayList[indexPath.row].notes
                cell.lblTitle.text = eventDisplayList[indexPath.row].displayText
                
                return cell
            
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblMeetings:
                if meetingDisplay[indexPath.row].calendarItem != nil
                {
                    callMeeting(meetingDisplay[indexPath.row].calendarItem!)
                }
            
            case tblCalendar:
                let _ = 1
                
            default:
                let _ = 1
        }
    }

    func loadMeetingDisplayArray()
    {
        meetingDisplay.removeAll()
        
        for myItem in myTeams.teams
        {
            myItem.loadMeetings()
            
            if myItem.meetings.count > 0
            {
                let tempHead = TableData(displayText: myItem.name)
                
                meetingDisplay.append(tempHead)
                
                for myMeeting in myItem.meetings
                {
                    var tempEntry = TableData(displayText: myMeeting.title)
                    tempEntry.calendarItem = myMeeting
                    
                    meetingDisplay.append(tempEntry)
                }
            }
        }
    }
    
    func loadCalendarDisplayArray()
    {
        let tempCal = iOSCalendar()
        
        eventDisplayList = tempCal.getCalendarRecords()
    }
    
    func meetingUpdated()
    {
        loadMeetingDisplayArray()
        
        loadCalendarDisplayArray()
    }
    
    func callMeeting( _ meetingRecord: calendarItem)
    {
        let meetingViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "Meetings") as! meetingsViewController
        meetingViewControl.passedMeeting = meetingRecord
        meetingViewControl.meetingCommunication = self
        
        removeExistingViews(displayView)
        
        addChildViewController(meetingViewControl)
        meetingViewControl.view.frame = CGRect(x: 0, y: 0, width: displayView.frame.size.width, height: displayView.frame.size.height)
        displayView.addSubview(meetingViewControl.view)
        meetingViewControl.didMove(toParentViewController: self)
    }
    
    func callMeetingAgenda(_ meetingRecord: calendarItem)
    {
        let agendaViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "MeetingAgenda") as! meetingAgendaViewController
        agendaViewControl.passedMeeting = meetingRecord
        agendaViewControl.meetingCommunication = self

        removeExistingViews(displayView)
        
        addChildViewController(agendaViewControl)
        agendaViewControl.view.frame = CGRect(x: 0, y: 0, width: displayView.frame.size.width, height: displayView.frame.size.height)
        displayView.addSubview(agendaViewControl.view)
        agendaViewControl.didMove(toParentViewController: self)
    }
    
    func displayTaskList(_ meetingRecord: calendarItem)
    {
        let taskListViewControl = tasksStoryboard.instantiateViewController(withIdentifier: "taskList") as! taskListViewController
     //   taskListViewControl.delegate = self
        taskListViewControl.myTaskListType = "Meeting"
        taskListViewControl.passedMeeting = meetingRecord
        
        self.present(taskListViewControl, animated: true, completion: nil)
    }
}

class meetingItemHeader: UITableViewCell
{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
}
