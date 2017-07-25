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
    var event: mergedCalendarItem!
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
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var btnType: UIButton!
    @IBOutlet weak var btnAddAppt: UIBarButtonItem!
    @IBOutlet weak var btnResetFilter: UIButton!
    
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
    fileprivate var selectedEvent: mergedCalendarItem!
    fileprivate var workingMeeting: calendarItem!
    fileprivate var displayList: [String] = Array()
    fileprivate var clientSource: [client] = Array()
    fileprivate var projectSource: [project] = Array()
    fileprivate var dayList: [dayViewList] = Array()
    fileprivate var startDate: Date!
    fileprivate var endDate: Date!
    fileprivate var filterClient: Int = 0
    fileprivate var filterProject: Int = 0
    
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
                    cell.lblName.text = appointmentList.events[indexPath.row].iCalItem!.title
                    
                    if appointmentList.events[indexPath.row].iCalItem!.isAllDay
                    {
                        cell.lblDate.text = appointmentList.events[indexPath.row].startDate.formatDateToString
                    }
                    else
                    {
                        cell.lblDate.text = "\(appointmentList.events[indexPath.row].iCalItem!.startDate.formatDateAndTimeString) - \(appointmentList.events[indexPath.row].iCalItem!.endDate.formatTimeString)"
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
                switch alertList.alertList[indexPath.row].source
                {
                    case "Project":
                        let workingProject = alertList.alertList[indexPath.row].object as! project
                        let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
                        contractEditViewControl.communicationDelegate = self
                        contractEditViewControl.workingContract = workingProject
                        self.present(contractEditViewControl, animated: true, completion: nil)
        
                    case "Client":
                        let clientMaintenanceViewControl = clientsStoryboard.instantiateViewController(withIdentifier: "clientMaintenance") as! clientMaintenanceViewController
                        clientMaintenanceViewControl.communicationDelegate = self
                        clientMaintenanceViewControl.selectedClient = alertList.alertList[indexPath.row].object as! client
                        self.present(clientMaintenanceViewControl, animated: true, completion: nil)
        
                    default:
                        let _ = 1
                }
            
            default:
                let _ = 1
            }
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction)
    {
        controller.dismiss(animated: true)
        refreshScreen()
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
        controller.event = selectedEvent.iCalItem
        controller.eventStore = globalEventStore
        controller.editViewDelegate = self
        present(controller, animated: true)
    }
    
    @IBAction func btnAgenda(_ sender: UIButton)
    {
        createMeetingAgenda()
        
        selectedEvent.databaseItem!.populateAttendeesFromInvite(selectedEvent.iCalItem)
        
        let agendaViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "MeetingAgenda") as! meetingAgendaViewController
        agendaViewControl.communicationDelegate = self
        agendaViewControl.passedMeeting = selectedEvent.databaseItem
        self.present(agendaViewControl, animated: true, completion: nil)
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
        
        projectSource = projects(clientID: workingMeeting.clientID, teamID: workingMeeting.teamID).projects
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
            
            pickerView.source = "filterClients"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnClient.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnFilterProject(_ sender: UIButton)
    {
        displayList.removeAll()
        
        if filterClient == 0
        {
            projectSource = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true).projects
        }
        else
        {
            projectSource = projects(clientID: filterClient, teamID: currentUser.currentTeam!.teamID).projects
        }
        
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
            
            pickerView.source = "filterProjects"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnProject.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnStartDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "startDate"
        pickerView.delegate = self
        if startDate == nil
        {
            pickerView.currentDate = Date()
        }
        else
        {
            pickerView.currentDate = startDate
        }
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnEndDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "endDate"
        pickerView.delegate = self
        if endDate == nil
        {
            pickerView.currentDate = Date()
        }
        else
        {
            pickerView.currentDate = endDate
        }
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnType(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append(meetingMeetingType)
        displayList.append(oneOnOneMeetingType)
        displayList.append(quoteMeetingType)
        displayList.append(performMeetingType)
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "type"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnProject.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAddAppt(_ sender: UIBarButtonItem)
    {
        let controller = EKEventEditViewController()
        controller.eventStore = globalEventStore
        controller.editViewDelegate = self
        present(controller, animated: true)
    }
    
    @IBAction func btnResetFilter(_ sender: UIButton)
    {
        filterClient = 0
        filterProject = 0
        btnFilterClient.setTitle("Filter by Client", for: .normal)
        btnFilterProject.setTitle("Filter by Project", for: .normal)
        
        let startAdjust = readDefaultInt("CalBefore") as Int
        let endAdjust = readDefaultInt("CalAfter") as Int
        startDate = Date().add(.day, amount: -(7 * startAdjust))
        endDate = Date().add(.day, amount: (7 * endAdjust))
        btnStartDate.setTitle(startDate.formatDateToString, for: .normal)
        btnEndDate.setTitle(endDate.formatDateToString, for: .normal)
        
        selectedEvent = nil
        refreshScreen()
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        switch source
        {
            case "clients":
                createMeetingAgenda()
                
                workingMeeting.clientID = clientSource[selectedItem].clientID
                displayClientAndProjectFields()
            
            case "projects":
                workingMeeting.projectID = projectSource[selectedItem].projectID
                displayClientAndProjectFields()
            
            case "type":
                createMeetingAgenda()
                
                workingMeeting.minutesType = displayList[selectedItem]
                displayClientAndProjectFields()
            
            case "filterClients":
                filterClient = clientSource[selectedItem].clientID
                btnFilterClient.setTitle(clientSource[selectedItem].name, for: .normal)
                selectedEvent = nil
                refreshScreen()
            
            case "filterProjects":
                filterProject = projectSource[selectedItem].projectID
                btnFilterProject.setTitle(projectSource[selectedItem].projectName, for: .normal)
                selectedEvent = nil
                refreshScreen()
            
            default:
                print("myPickerDidFinish selectedItem hit default - source = \(source)")
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
                startDate = selectedDate
                btnStartDate.setTitle("\(startDate.formatDateToString)", for: .normal)
                selectedEvent = nil
                refreshScreen()
            
            case "endDate":
                endDate = selectedDate
                btnEndDate.setTitle("\(endDate.formatDateToString)", for: .normal)
                selectedEvent = nil
                refreshScreen()
            
            default:
                print("myPickerDidFinish Date got unknown source - \(source)")
        }
    }
    
    func createMeetingAgenda()
    {
        if workingMeeting == nil
        {
            workingMeeting = calendarItem(event: selectedEvent.iCalItem!, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func buildArrayForDay()
    {
        // Break day into half hour slots and then use this to show whether to display appointment details or not
        
        var currentColour: UIColor = greenColour
        var currentTitle: String = ""
        
        if filterClient > 0 || filterProject > 0
        {
            appointmentList = iOSCalendar(clientID: filterClient, projectID: filterProject, teamID: currentUser.currentTeam!.teamID, startDate: startDate, endDate: endDate)
        }
        else
        {
            appointmentList = iOSCalendar(teamID: currentUser.currentTeam!.teamID, workingDate: workingDate)
        }
        
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
                    if eventEntry.iCalItem!.isAllDay
                    {
                        if myTime == "00:00"
                        {
                            let newMerged = mergedCalendarItem(startDate: eventEntry.iCalItem!.startDate, databaseItem: nil, iCalItem: eventEntry.iCalItem!)
                            newEntry = dayViewList(timeSlice: "All Day", title: eventEntry.iCalItem!.title, dateString: eventEntry.iCalItem!.startDate.formatDateToString, colour: currentColour, event: newMerged)
                            currentColour = switchColour(currentColour)
                        }
                        break
                    }
                    
                    if eventEntry.iCalItem!.startDate >= tempStartDate && eventEntry.iCalItem!.endDate <= tempEndDate
                    {
                        // Entire meeting fits into this slot
                        let newMerged = mergedCalendarItem(startDate: eventEntry.iCalItem!.startDate, databaseItem: nil, iCalItem: eventEntry.iCalItem!)
                        newEntry = dayViewList(timeSlice: myTime, title: eventEntry.iCalItem!.title, dateString: "\(eventEntry.iCalItem!.startDate.formatTimeString) - \(eventEntry.iCalItem!.endDate.formatTimeString)", colour: currentColour, event: newMerged)
                        
                        currentColour = switchColour(currentColour)
                        currentTitle = ""
                    }
                    else if eventEntry.iCalItem!.startDate < tempStartDate && eventEntry.iCalItem!.endDate >= tempEndDate
                    {
                        // Meeting already in progress and runs over entire slot
                        let newMerged = mergedCalendarItem(startDate: eventEntry.iCalItem!.startDate, databaseItem: nil, iCalItem: eventEntry.iCalItem!)
                        newEntry = dayViewList(timeSlice: myTime, title: myTime, dateString: "", colour: currentColour, event: newMerged)
                    }
                    else if eventEntry.iCalItem!.startDate >= tempEndDate
                    {
                        // Do nothing
                    }
                    else if eventEntry.iCalItem!.startDate >= tempStartDate && eventEntry.iCalItem!.endDate > tempEndDate
                    {
                        // Meeting straddles slots
                        let newMerged = mergedCalendarItem(startDate: eventEntry.iCalItem!.startDate, databaseItem: nil, iCalItem: eventEntry.iCalItem!)
                        newEntry = dayViewList(timeSlice: myTime, title: eventEntry.iCalItem!.title, dateString: "\(eventEntry.iCalItem!.startDate.formatTimeString) - \(eventEntry.iCalItem!.endDate.formatTimeString)", colour: currentColour, event: newMerged)
                        currentTitle = eventEntry.iCalItem!.title
                    }
                    else if eventEntry.iCalItem!.endDate < tempEndDate && currentTitle != ""
                    {
                        currentColour = switchColour(currentColour)
                        currentTitle = ""
                    }
                    
                    if eventEntry.iCalItem!.endDate > tempEndDate
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
        
        lblTitle.text = selectedEvent.iCalItem!.title
        
        if selectedEvent.iCalItem!.isAllDay
        {
            lblDate.text = selectedEvent.startDate.formatDateToString
        }
        else
        {
            lblDate.text = "\(selectedEvent.iCalItem!.startDate.formatDateAndTimeString) - \(selectedEvent.iCalItem!.endDate.formatTimeString)"
        }
        
        lblLocation.text = selectedEvent.iCalItem!.structuredLocation?.title
        
        // Is there a meeting entry for this
        
        workingMeeting = calendarItem(meetingID: generateMeetingID(selectedEvent.iCalItem!), teamID: currentUser.currentTeam!.teamID)
        
        if workingMeeting.meetingID == ""
        {
            // No meeting was found
            btnClient.setTitle("Select", for: .normal)
            btnProject.setTitle("Select", for: .normal)
            btnType.setTitle(meetingMeetingType, for: .normal)
            btnClient.isEnabled = true
            btnProject.isEnabled = false
            btnAgenda.setTitle("Create Agenda", for: .normal)
            workingMeeting = nil
        }
        else
        {
            // Meeting was found
            
            displayClientAndProjectFields()
            btnAgenda.setTitle("Edit Agenda", for: .normal)
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
            let tempClient = client(clientID: workingMeeting.clientID, teamID: currentUser.currentTeam!.teamID)
            btnClient.setTitle(tempClient.name, for: .normal)
            btnClient.isEnabled = true
            btnProject.isEnabled = true
            
            if workingMeeting.projectID == 0
            {
                btnProject.setTitle("Select", for: .normal)
            }
            else
            {
                let tempProject = project(projectID: workingMeeting.projectID, teamID: currentUser.currentTeam!.teamID)
                btnProject.setTitle(tempProject.projectName, for: .normal)
            }
        }
        
        switch workingMeeting.minutesType
        {
            case meetingMeetingType:
                btnType.setTitle(workingMeeting.minutesType, for: .normal)
                btnAgenda.isEnabled = true
            
            case quoteMeetingType:
                btnType.setTitle(workingMeeting.minutesType, for: .normal)
                btnAgenda.isEnabled = false
            
            case performMeetingType:
                btnType.setTitle(workingMeeting.minutesType, for: .normal)
                btnAgenda.isEnabled = false
            
            case oneOnOneMeetingType:
                btnType.setTitle(workingMeeting.minutesType, for: .normal)
                btnAgenda.isEnabled = true
            
            case "":
                workingMeeting.minutesType = meetingMeetingType
                btnType.setTitle(meetingMeetingType, for: .normal)
            
            default:
                print("displayClientAndProjectFields hot default - \(workingMeeting.minutesType)")
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
        lblType.isHidden = true
        btnType.isHidden = true
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
        lblType.isHidden = false
        btnType.isHidden = false
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
            
            if selectedEvent != nil
            {
                displayEvent()
            }
        }
        
        btnStartDate.setTitle(startDate.formatDateToString, for: .normal)
        btnEndDate.setTitle(endDate.formatDateToString, for: .normal)
        
        if btnCalendarView.currentTitle == listView
        {
            // Load calendar items
            
            appointmentList = iOSCalendar(clientID: filterClient, projectID: filterProject, teamID: currentUser.currentTeam!.teamID, startDate: startDate, endDate: endDate)
//            if filterClient > 0 || filterProject > 0
//            {
//                appointmentList = iOSCalendar(clientID: filterClient, projectID: filterProject, teamID: currentUser.currentTeam!.teamID, startDate: startDate, endDate: endDate)
//            }
//            else
//            {
//                appointmentList = iOSCalendar(teamID: currentUser.currentTeam!.teamID, startDate: startDate, endDate: endDate)
//            }
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
        
        alertList.taskAlerts(currentUser.currentTeam!.teamID)
        alertList.shiftAlerts(currentUser.currentTeam!.teamID)
        alertList.clientAlerts(currentUser.currentTeam!.teamID)
        alertList.projectAlerts(currentUser.currentTeam!.teamID)
    }
}

class calendarTableItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
}
