//
//  toolBoxViewController.swift
//  toolbox
//
//  Created by Garry Eves on 3/7/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

struct dayViewList
{
    var timeSlice: String
    var title: String = ""
    var dateString: String = ""
    var colour: UIColor
    var event: EKEvent!
}

class toolboxViewController: UIViewController, myCommunicationDelegate, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate, UIPopoverPresentationControllerDelegate, EKEventEditViewDelegate
{
    @IBOutlet weak var tblCalendar: UITableView!
    @IBOutlet weak var tblAlerts: UITableView!
    @IBOutlet weak var btnPeople: UIButton!
    @IBOutlet weak var btnClients: UIButton!
    @IBOutlet weak var btnSettings: UIBarButtonItem!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var btnCalendarView: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var btnEvent: UIButton!
    @IBOutlet weak var btnAgenda: UIButton!
    @IBOutlet weak var lblClient: UILabel!
    @IBOutlet weak var lblProject: UILabel!
    @IBOutlet weak var btnClient: UIButton!
    @IBOutlet weak var btnProject: UIButton!
    @IBOutlet weak var btnFilterClient: UIButton!
    @IBOutlet weak var btnFilterProject: UIButton!
    @IBOutlet weak var btnStartDate: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var lblFilyerDate: UILabel!
    @IBOutlet weak var lblFilterDash: UILabel!
    
    fileprivate let listView = "List View"
    fileprivate let dayView = "Day View"
    fileprivate let timeSplit = ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30",
                                 "03:00", "03:30", "04:00", "04:30", "05:00", "05:30",
                                 "06:00", "06:30", "07:00", "07:30", "08:00", "08:30",
                                 "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
                                 "12:00", "12:30", "13:00", "13:30", "14:00", "14:30",
                                 "15:00", "15:30", "16:00", "16:30", "17:00", "17:30",
                                 "18:00", "18:30", "19:00", "19:30", "20:00", "20:30",
                                 "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"
                                 ]
    
    fileprivate var firstRun = true
    fileprivate var alertList: alerts!
    fileprivate var appointmentList: iOSCalendar!
    fileprivate var workingDate: Date!
    fileprivate var selectedEvent: EKEvent!
    fileprivate var workingMeeting: calendarItem!
    fileprivate var displayList: [String] = Array()
    fileprivate var clientSource: [client] = Array()
    fileprivate var projectSource: [project] = Array()
    fileprivate var dayList: [dayViewList] = Array()
    fileprivate var startDate: Date!
    fileprivate var endDate: Date!
    
    var communicationDelegate: myCommunicationDelegate?

    override func viewDidLoad()
    {
        if readDefaultInt("CalBefore") as Int == -1
        {
            writeDefaultInt("CalBefore", value: 2)
        }
        
        if readDefaultInt("CalAfter") as Int == -1
        {
            writeDefaultInt("CalAfter", value: 4)
        }
        
        let startAdjust = readDefaultInt("CalBefore") as Int
        let endAdjust = readDefaultInt("CalAfter") as Int
        startDate = Date().add(.day, amount: -(7 * startAdjust))
        endDate = Date().add(.day, amount: (7 * endAdjust))
        
        connectEventStore()
        
        checkCalendarConnected(globalEventStore)
        
        if currentUser.currentTeam == nil
        {
            currentUser.loadTeams()
        }
        
        if readDefaultInt("teamID") >= 0
        {
            currentUser.currentTeam = team(teamID: readDefaultInt("teamID"))
        }
        
        btnSettings.title = NSString(string: "\u{2699}") as String
        
        btnCalendarView.setTitle(listView, for: .normal)
        workingDate = Date()
        
        btnDate.isHidden = true
        hideFields()
        
        refreshScreen()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        if !firstRun
        {
            DispatchQueue.global().async
            {
                myDBSync.sync()
            }
        }
        firstRun = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblCalendar:
                if btnCalendarView.currentTitle == listView
                {
                    if appointmentList != nil
                    {
                        return appointmentList.events.count
                    }
                    else
                    {
                        return 0
                    }
                }
                else
                {
                    return dayList.count
                }
            
            case tblAlerts:
                if alertList != nil
                {
                    return alertList.alertList.count
                }
                else
                {
                    return 0
                }
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblCalendar:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellCalendar", for: indexPath) as! calendarTableItem
                
                if btnCalendarView.currentTitle == listView
                {
                    cell.lblName.text = appointmentList.events[indexPath.row].title
                    
                    if appointmentList.events[indexPath.row].isAllDay
                    {
                        cell.lblDate.text = appointmentList.events[indexPath.row].startDate.formatDateToString
                    }
                    else
                    {
                        cell.lblDate.text = "\(appointmentList.events[indexPath.row].startDate.formatDateAndTimeString) - \(appointmentList.events[indexPath.row].endDate.formatTimeString)"
                    }
                }
                else
                {
                    cell.lblName.text = dayList[indexPath.row].title
                    cell.lblDate.text = dayList[indexPath.row].dateString
                    
                    cell.backgroundColor = dayList[indexPath.row].colour
                }
                
                return cell
            
            case tblAlerts:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellAlert", for: indexPath) as! alertListItem
                
                cell.lblAlert.text = alertList.alertList[indexPath.row].displayText
                cell.lblName.text = alertList.alertList[indexPath.row].name
                
                return cell
            
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblCalendar:
                if btnCalendarView.currentTitle == listView
                {
                    selectedEvent = appointmentList.events[indexPath.row]
                }
                else
                {
                     selectedEvent = dayList[indexPath.row].event
                }
                if selectedEvent == nil
                {
                    hideFields()
                }
                else
                {
                    workingMeeting = nil
                    displayEvent()
                }
            
            case tblAlerts:
                let _ = 1
    //            switch alertList.alertList[indexPath.row].source
    //            {
    //            case "Project":
    //                let workingProject = alertList.alertList[indexPath.row].object as! project
    //                let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
    //                contractEditViewControl.communicationDelegate = self
    //                contractEditViewControl.workingContract = workingProject
    //                self.present(contractEditViewControl, animated: true, completion: nil)
    //
    //            case "Client":
    //                let clientMaintenanceViewControl = clientsStoryboard.instantiateViewController(withIdentifier: "clientMaintenance") as! clientMaintenanceViewController
    //                clientMaintenanceViewControl.communicationDelegate = self
    //                clientMaintenanceViewControl.selectedClient = alertList.alertList[indexPath.row].object as! client
    //                self.present(clientMaintenanceViewControl, animated: true, completion: nil)
    //
    //            case "Shift":
    //                let workingShift = alertList.alertList[indexPath.row].object as! shift
    //
    //                if workingShift.type == eventShiftType
    //                {
    //                    let workingProject = project(projectID: workingShift.projectID)
    //                    let eventsViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventPlanningForm") as! eventPlanningViewController
    //                    eventsViewControl.communicationDelegate = self
    //                    eventsViewControl.currentEvent = workingProject
    //                    self.present(eventsViewControl, animated: true, completion: nil)
    //
    //                }
    //                else
    //                {
    //                    let rosterMaintenanceViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "rosterForm") as! shiftMaintenanceViewController
    //                    rosterMaintenanceViewControl.communicationDelegate = self
    //                    rosterMaintenanceViewControl.currentWeekEndingDate = workingShift.weekEndDate
    //                    self.present(rosterMaintenanceViewControl, animated: true, completion: nil)
    //                }
    //
    //            default:
    //                let _ = 1
    //            }
            
            default:
                let _ = 1
            }
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction)
    {
        controller.dismiss(animated: true)
    }
    
    @IBAction func btnPeople(_ sender: UIButton)
    {
        let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
        self.present(peopleEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnClients(_ sender: UIButton)
    {
        let clientMaintenanceViewControl = clientsStoryboard.instantiateViewController(withIdentifier: "clientMaintenance") as! clientMaintenanceViewController
        clientMaintenanceViewControl.communicationDelegate = self
        self.present(clientMaintenanceViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnSettings(_ sender: UIBarButtonItem)
    {
        let userEditViewControl = settingsStoryboard.instantiateViewController(withIdentifier: "settings") as! settingsViewController
        userEditViewControl.communicationDelegate = self
        self.present(userEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnCalendarView(_ sender: UIButton)
    {
        if sender.currentTitle == listView
        {
            btnCalendarView.setTitle(dayView, for: .normal)
            btnDate.isHidden = false
            lblFilyerDate.isHidden = true
            lblFilterDash.isHidden = true
            btnStartDate.isHidden = true
            btnEndDate.isHidden = true
        }
        else
        {
            btnCalendarView.setTitle(listView, for: .normal)
            btnDate.isHidden = true
            lblFilyerDate.isHidden = false
            lblFilterDash.isHidden = false
            btnStartDate.isHidden = false
            btnEndDate.isHidden = false
        }
        
        refreshScreen()
    }
    
    @IBAction func btnEvent(_ sender: UIButton)
    {
        let controller = EKEventEditViewController()
        controller.event = selectedEvent
        controller.eventStore = globalEventStore
        controller.editViewDelegate = self
        present(controller, animated: true)
    }
    
    @IBAction func btnAgenda(_ sender: UIButton)
    {
        createMeetingAgenda()
    }
    
    @IBAction func btnClient(_ sender: UIButton)
    {
        displayList.removeAll()
        
        clientSource = clients(teamID: currentUser.currentTeam!.teamID).clients
        for myItem in clientSource
        {
            displayList.append(myItem.name)
        }
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "clients"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnClient.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnProject(_ sender: UIButton)
    {
        displayList.removeAll()
        
        projectSource = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true).projects
        for myItem in projectSource
        {
            displayList.append(myItem.projectName)
        }
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "projects"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnProject.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "calendarDate"
        pickerView.delegate = self
        pickerView.currentDate = workingDate
        
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnFilterClient(_ sender: UIButton)
    {
    }
    
    @IBAction func btnFilterProject(_ sender: UIButton)
    {
    }
    
    @IBAction func btnStartDate(_ sender: UIButton)
    {
    }
    
    @IBAction func btnEndDate(_ sender: UIButton)
    {
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "clients"
        {
            createMeetingAgenda()
            
            workingMeeting.clientID = clientSource[selectedItem].clientID
            displayClientAndProjectFields()
        }
        else if source == "projects"
        {
            workingMeeting.projectID = projectSource[selectedItem].projectID
            displayClientAndProjectFields()
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        switch source
        {
            case "calendarDate":
                workingDate = selectedDate
                btnDate.setTitle("\(workingDate.formatDateToString)", for: .normal)
                
                buildArrayForDay()
            
            case "startDate":
                let _ = 1
            
            case "endDate":
                let _ = 1
            
            default:
                print("myPickerDidFinish Date got unknown source - \(source)")
        }
    }
    
    func createMeetingAgenda()
    {
        if workingMeeting == nil
        {
            workingMeeting = calendarItem(event: selectedEvent, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func buildArrayForDay()
    {
        // Break day into half hour slots and then use this to show whether to display appointment details or not
        
        var currentColour: UIColor = greenColour
        var currentTitle: String = ""
        
        appointmentList = iOSCalendar(teamID: currentUser.currentTeam!.teamID, workingDate: workingDate)
        
        dayList.removeAll()
        if appointmentList.events.count == 0
        {
            // No appointments for day
        }
        else
        {
            for myTime in timeSplit
            {
                var newEntry: dayViewList!
                
                let dateString = "\(workingDate.formatDateToString) \(myTime)"
                
                let tempStartDate = dateString.formatStringToDateTime
                let tempEndDate = tempStartDate.add(.minute, amount: 30)
                
                for eventEntry in appointmentList.events
                {
                    if eventEntry.isAllDay
                    {
                        if myTime == "00:00"
                        {
                            newEntry = dayViewList(timeSlice: "All Day", title: eventEntry.title, dateString: eventEntry.startDate.formatDateToString, colour: currentColour, event: eventEntry)
                            currentColour = switchColour(currentColour)
                        }
                        break
                    }
                    
                    if eventEntry.startDate >= tempStartDate && eventEntry.endDate <= tempEndDate
                    {
                        // Entire meeting fits into this slot
                        newEntry = dayViewList(timeSlice: myTime, title: eventEntry.title, dateString: "\(eventEntry.startDate.formatTimeString) - \(eventEntry.endDate.formatTimeString)", colour: currentColour, event: eventEntry)
                        
                        currentColour = switchColour(currentColour)
                        currentTitle = ""
                    }
                    else if eventEntry.startDate < tempStartDate && eventEntry.endDate >= tempEndDate
                    {
                        // Meeting already in progress and runs over entire slot
                        newEntry = dayViewList(timeSlice: myTime, title: myTime, dateString: "", colour: currentColour, event: eventEntry)
                    }
                    else if eventEntry.startDate >= tempEndDate
                    {
                        // Do nothing
                    }
                    else if eventEntry.startDate >= tempStartDate && eventEntry.endDate > tempEndDate
                    {
                        // Meeting straddles slots
                        newEntry = dayViewList(timeSlice: myTime, title: eventEntry.title, dateString: "\(eventEntry.startDate.formatTimeString) - \(eventEntry.endDate.formatTimeString)", colour: currentColour, event: eventEntry)
                        currentTitle = eventEntry.title
                    }
                    else if eventEntry.endDate < tempEndDate && currentTitle != ""
                    {
                        currentColour = switchColour(currentColour)
                        currentTitle = ""
                    }
                    
                    if eventEntry.endDate > tempEndDate
                    {
                        break
                    }
                }
                
                if newEntry == nil
                {
                    newEntry = dayViewList(timeSlice: myTime, title: myTime, dateString: "", colour: UIColor.white, event: nil)
                }
                dayList.append(newEntry)
            }
        }
        tblCalendar.reloadData()
    }
    
    func switchColour(_ source: UIColor) -> UIColor
    {
        switch source
        {
            case greenColour:
                return cyanColour
            
            case cyanColour:
                return redColour
            
            case redColour:
                return greyColour
            
            case greyColour:
                return yellowColour
            
            case yellowColour:
                return brownColour
            
            default:
                return greenColour
        }
    }
    
    func displayEvent()
    {
        showFields()
        
        lblTitle.text = selectedEvent.title
        
        if selectedEvent.isAllDay
        {
            lblDate.text = selectedEvent.startDate.formatDateToString
        }
        else
        {
            lblDate.text = "\(selectedEvent.startDate.formatDateAndTimeString) - \(selectedEvent.endDate.formatTimeString)"
        }
        
        lblLocation.text = selectedEvent.structuredLocation?.title
        
        // Is there a meeting entry for this
        
        workingMeeting = calendarItem(meetingID: generateMeetingID(selectedEvent), teamID: currentUser.currentTeam!.teamID)
        
        if workingMeeting.meetingID == ""
        {
            // No meeting was found
            btnClient.setTitle("Select", for: .normal)
            btnProject.setTitle("Select", for: .normal)
            btnClient.isEnabled = true
            btnProject.isEnabled = false
        }
        else
        {
            // Meeting was found
            
            displayClientAndProjectFields()
        }
    }
    
    func displayClientAndProjectFields()
    {
        if workingMeeting.clientID == 0
        {
            btnClient.setTitle("Select", for: .normal)
            btnProject.setTitle("Select", for: .normal)
            btnClient.isEnabled = true
            btnProject.isEnabled = false
        }
        else
        {
            let tempClient = client(clientID: workingMeeting.clientID)
            btnClient.setTitle(tempClient.name, for: .normal)
            btnClient.isEnabled = true
            btnProject.isEnabled = true
            
            if workingMeeting.projectID == 0
            {
                btnProject.setTitle("Select", for: .normal)
            }
            else
            {
                let tempProject = project(projectID: workingMeeting.projectID)
                btnProject.setTitle(tempProject.projectName, for: .normal)
            }
        }
    }
    
    func hideFields()
    {
        lblTitle.isHidden = true
        lblDate.isHidden = true
        lblLocation.isHidden = true
        btnEvent.isHidden = true
        btnAgenda.isHidden = true
        lblClient.isHidden = true
        lblProject.isHidden = true
        btnClient.isHidden = true
        btnProject.isHidden = true
    }
    
    func showFields()
    {
        lblTitle.isHidden = false
        lblDate.isHidden = false
        lblLocation.isHidden = false
        btnEvent.isHidden = false
        btnAgenda.isHidden = false
        lblClient.isHidden = false
        lblProject.isHidden = false
        btnClient.isHidden = false
        btnProject.isHidden = false
    }
    
    func refreshScreen()
    {
        navBarTitle.title = currentUser.currentTeam!.name
        
        btnDate.setTitle("\(workingDate.formatDateToString)", for: .normal)
        
        buildAlerts()
        
        if currentUser.currentTeam!.subscriptionDate < Date().startOfDay
        {
            btnSettings.isEnabled = true
            btnPeople.isHidden = true
            btnClients.isHidden = true
            tblCalendar.isHidden = true
            tblAlerts.isHidden = true
            
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.notSubscribedMessage), userInfo: nil, repeats: false)
        }
        else
        {
            tblAlerts.reloadData()
            
//            var showRoster: Bool = false
//            var showEvents: Bool = false
//            var showMonthlyRoster: Bool = false
//            var showShare: Bool = false
            var showPeople: Bool = false
            var showClients: Bool = false
            
//            if currentUser.checkPermission(rosteringRoleType) != noPermission
//            {
//                showRoster = true
//                showEvents = true
//                showMonthlyRoster = true
//            }
            
            if currentUser.checkPermission(pmRoleType) != noPermission
            {
                showClients = true
                showPeople = true
//                showEvents = true
//                showMonthlyRoster = true
//                showRoster = true
            }
            
//            if currentUser.checkPermission(financialsRoleType) != noPermission
//            {
//                showShare = true
//            }
            
            if currentUser.checkPermission(hrRoleType) != noPermission
            {
                showPeople = true
            }
            
            if currentUser.checkPermission(salesRoleType) != noPermission
            {
                showClients = true
            }
            
            if currentUser.checkPermission(invoicingRoleType) != noPermission
            {
                showClients = true
            }
            
            btnPeople.isEnabled = false
            btnClients.isEnabled = false
            
            if showPeople
            {
                btnPeople.isEnabled = true
            }
            
            if showClients
            {
                btnClients.isEnabled = true
            }
        }
        
        btnStartDate.setTitle(startDate.formatDateToString, for: .normal)
        btnEndDate.setTitle(endDate.formatDateToString, for: .normal)
        
        if btnCalendarView.currentTitle == listView
        {
            // Load calendar items
            
            appointmentList = iOSCalendar(teamID: currentUser.currentTeam!.teamID, startDate: startDate, endDate: endDate)
            tblCalendar.reloadData()
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.scrollCalendar), userInfo: nil, repeats: false)
        }
        else
        {
            // Just want appointments for the day
            buildArrayForDay()
        }
    }
    
    func scrollCalendar()
    {
        var recordCount: Int = 0
        
        for myItem in appointmentList.events
        {
            if myItem.startDate > Date()
            {
                break
            }
            recordCount += 1
        }
        
        if recordCount > 0
        {
            let startPosition = IndexPath(row: recordCount, section: 0)
            tblCalendar.scrollToRow(at: startPosition, at: .top, animated: true)
        }
    }
    
    func notSubscribedMessage()
    {
        let alert = UIAlertController(title: "Subscription Expired", message:
            "Your teams subscription has expired.  Please contact your Administrator in order to have the Subscription renewed.", preferredStyle: UIAlertControllerStyle.alert)
        
        let yesOption = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(yesOption)
        self.present(alert, animated: false, completion: nil)
    }
    
    func buildAlerts()
    {
        if alertList == nil
        {
            alertList = alerts()
            
        }
        else
        {
            alertList.clearAlerts()
        }
        
        alertList.shiftAlerts()
        alertList.clientAlerts()
        alertList.projectAlerts()
    }
}

class calendarTableItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
}
