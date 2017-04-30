//
//  mainViewController.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 22/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class mainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
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
        
        loadMeetingDisplayArray()
        
        loadCalendarDisplayArray()
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
                    cell.lblTime.font = UIFont.systemFont(ofSize: cell.lblTime.font.pointSize)
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
                    let meetingViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "Meetings") as! meetingsViewController
                    meetingViewControl.passedMeeting = meetingDisplay[indexPath.row].calendarItem
                    
//                    displayView.autoresizesSubviews = true
//                    displayView.clipsToBounds = true
//                    
                    meetingViewControl.view.frame = CGRect(x: 0, y: 0, width: displayView.frame.size.width, height: displayView.frame.size.height)
                    displayView.addSubview(meetingViewControl.view)
//                    
//                    meetingViewControl.didMove(toParentViewController: self)
                    
                    
                    
               //     self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
//                    self.addChildViewController(meetingViewControl)
//                    meetingViewControl.view.frame = displayView.frame
//                    displayView.addSubview(meetingViewControl.view)
//                    
                    //self.present(meetingViewControl, animated: true, completion: nil)
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
}

class meetingItemHeader: UITableViewCell
{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
}
