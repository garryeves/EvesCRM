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
                    cell.lblTime.font = UIFont.systemFont(ofSize: lblMeetings.font.pointSize)
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
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        switch myContentsArray[indexPath.section].items[indexPath.row].type
//        {
//        case "header":
//            return 32.0
//            
//        case "class":
//            return 64.0
//            
//        case "mix":
//            return 64.0
//            
//        default:
//            return 32.0
//        }
//    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        switch tableView
//        {
//            case tblMeetings:
//                let _ = 1
//                
//            case tblCalendar:
//                let _ = 1
//                
//            default:
//                let _ = 1
//        }

//        if myContentsArray[indexPath.section].items[indexPath.row].type == "class"
//        {
//            // Process for a class
//            
//            let myValues: segueParameters = segueParameters()
//            
//            myValues.parentObject = tableView
//            myValues.parameterValue = myContentsArray[indexPath.section].items[indexPath.row].displayClass
//            
//            performSegue(withIdentifier: "classSegue", sender: myValues)
//        }
//        else if myContentsArray[indexPath.section].items[indexPath.row].type == "mix"
//        {
//            let myValues: segueParameters = segueParameters()
//            
//            myValues.parentObject = tableView
//            myValues.parameterValue = myContentsArray[indexPath.section].items[indexPath.row].displayMix
//            
//            performSegue(withIdentifier: "mixSegue", sender: myValues)
//        }
//    }

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
