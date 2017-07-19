//
//  meetingAgendaViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 31/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
import EventKit

//import TextExpander

let meetingAttendenceAttended = "Attended"
let meetingAttendenceApologised = "Apologised"
let meetingAttendenceNotAttend = "Did not attend"
let meetingAttendenceDelegated = "Delegated"

class meetingAgendaViewController: UIViewController, myCommunicationDelegate, MyTaskListDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate , MyPickerDelegate, UIPopoverPresentationControllerDelegate //,  SMTEFillDelegate
{
    var passedMeeting: calendarItem!
    var communicationDelegate: myCommunicationDelegate?
    
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var tblAgenda: UITableView!
    @IBOutlet weak var lblAgendaItems: UILabel!
    @IBOutlet weak var btnAddAgendaItem: UIButton!
    @IBOutlet weak var lblAddAgendaItem: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTimeAllocation: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtTimeAllocation: UITextField!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var tblAttendees: UITableView!
    @IBOutlet weak var lblChair: UILabel!
    @IBOutlet weak var lblMinutes: UILabel!
    @IBOutlet weak var btnChair: UIButton!
    @IBOutlet weak var btnMinutes: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var lblNextMeeting: UILabel!
    @IBOutlet weak var lblPreviousMeeting: UILabel!
    @IBOutlet weak var btnPreviousMeeting: UIButton!
    @IBOutlet weak var btnNextMeeting: UIButton!
    @IBOutlet weak var btnViewPreviousMeeting: UIButton!
    @IBOutlet weak var btnViewNextMeeting: UIButton!
    @IBOutlet weak var btnFinalise: UIButton!
    @IBOutlet weak var btnRearrange: UIButton!
    
    fileprivate let reuseAgendaTime = "reuseAgendaTime"
    fileprivate let reuseAgendaTitle = "reuseAgendaTitle"
    fileprivate let reuseAgendaOwner = "reuseAgendaOwner"
    fileprivate let reuseAgendaAction = "reuseAgendaAction"
    
    fileprivate var myAgendaList: [meetingAgendaItem] = Array()
    fileprivate var displayList: [String] = Array()
    fileprivate var meetingList: [String] = Array()
    
    fileprivate var myDateFormatter = DateFormatter()
    fileprivate let myCalendar = Calendar.current
    fileprivate var myWorkingTime: Date = Date()
        
//    lazy var activityPopover:UIPopoverController = {
//        return UIPopoverController(contentViewController: self.activityViewController)
//        }()
    
//    lazy var activityViewController:UIActivityViewController = {
//        return self.createActivityController()
//        }()
    
//    // Textexpander
//    
//    fileprivate var snippetExpanded: Bool = false
//    
//    var textExpander: SMTEDelegateController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if passedMeeting.meetingStatus != agendaStatus
        {
            btnAddAgendaItem.isHidden = true
            btnRearrange.isHidden = true
        }

        myDateFormatter.timeStyle = DateFormatter.Style.short
        myWorkingTime = passedMeeting.startDate as Date
        
        refreshScreen()
        
//        // TextExpander
//        textExpander = SMTEDelegateController()
//        txtDescription.delegate = textExpander
//        textExpander.clientAppName = "EvesCRM"
//        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
//        textExpander.fillDelegate = self
//        textExpander.nextDelegate = self
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblAttendees
        {
            return passedMeeting.attendees.count
        }
        else if tableView == tblAgenda
        {
            return myAgendaList.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblAttendees
        {
            let cell = tableView.dequeueReusableCell(withIdentifier:"attendeeItem", for: indexPath) as! meetingAgendaEntry
            
            cell.lblName.text = passedMeeting.attendees[indexPath.row].name
            cell.attendeeEntry = passedMeeting.attendees[indexPath.row]
            
            if passedMeeting.attendees[indexPath.row].status == ""
            {
                cell.btnAction.setTitle("Select", for: .normal)
            }
            else
            {
                cell.btnAction.setTitle(passedMeeting.attendees[indexPath.row].status, for: .normal)
            }

            cell.mainView = self
            cell.sourceView = cell
            
            return cell
        }
        else if tableView == tblAgenda
        {
            let cell = tableView.dequeueReusableCell(withIdentifier:"cellAgenda", for: indexPath) as! myAgendaItem
            
            cell.lblTime.text = "\(myDateFormatter.string(from: myWorkingTime))"
            cell.lblItem.text = myAgendaList[indexPath.row].title
            cell.lblOwner.text = myAgendaList[indexPath.row].owner

            myWorkingTime = myWorkingTime.add(.minute, amount: Int(myAgendaList[indexPath.row].timeAllocation))
            
            return cell
        }
        else
        {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblAgenda
        {
            let itemToUpdate = indexPath.row
            
            if myAgendaList[itemToUpdate].agendaID == 0
            {  // This is a previous meeting tasks row, so call the task list
                print("collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)   to do")
                //            if meetingCommunication != nil
                //            {
                //                meetingCommunication.displayTaskList(passedMeeting)
                //            }
                //            else
                //            {
                //                let taskListViewControl = tasksStoryboard.instantiateViewController(withIdentifier: "taskList") as! taskListViewController
                //                taskListViewControl.delegate = self
                //                taskListViewControl.myTaskListType = "Meeting"
                //                taskListViewControl.passedMeeting = passedMeeting
                //
                //                self.present(taskListViewControl, animated: true, completion: nil)
                //            }
            }
            else
            {  // This is a normal Agenda item so call the Agenda item screen
                let agendaViewControl = meetingStoryboard.instantiateViewController(withIdentifier: "AgendaItem") as! agendaItemViewController
                agendaViewControl.communicationDelegate = self
                agendaViewControl.event = passedMeeting
                agendaViewControl.actionType = passedMeeting.meetingStatus
                
                let agendaItem = myAgendaList[itemToUpdate]
                agendaViewControl.agendaItem = agendaItem
                
                self.present(agendaViewControl, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if tableView == tblAgenda
        {
            if passedMeeting.meetingStatus != agendaStatus
            {
                return false
            }
            
            if myAgendaList[indexPath.item].title == "Close meeting"
            {
                return false
            }
            
            if myAgendaList[indexPath.item].title == "Review of previous meeting actions"
            {
                return false
            }
            
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        if tableView == tblAgenda
        {
            if passedMeeting.meetingStatus != agendaStatus
            {
                return false
            }
            
            if myAgendaList[indexPath.item].title == "Close meeting"
            {
                return false
            }
            
            if myAgendaList[indexPath.item].title == "Review of previous meeting actions"
            {
                return false
            }
            
            return true
        }
        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath)
    {
        if tableView == tblAgenda
        {
            if toIndexPath.row > fromIndexPath.row
            {

                myAgendaList[fromIndexPath.row].meetingOrder = myAgendaList[toIndexPath.row].meetingOrder

                var loopCount: Int = fromIndexPath.row

                while loopCount < toIndexPath.row
                {
                    myAgendaList[loopCount + 1].meetingOrder = loopCount - 1
                    loopCount += 1
                }
            }
            else // toIndexPath.row < fromIndexPath.row
            {
                myAgendaList[fromIndexPath.row].meetingOrder = myAgendaList[toIndexPath.row].meetingOrder

                var loopCount: Int = toIndexPath.row

                while loopCount < fromIndexPath.row - 1
                {
                    myAgendaList[loopCount].meetingOrder = loopCount + 1
                    loopCount += 1
                }
            }
        
            buildAgendaArray()
    
            tblAgenda.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if tableView == tblAgenda
        {
            if editingStyle == .delete
            {
                // Get row details to delete
                var performDelete: Bool = true
                
                if passedMeeting.meetingStatus != agendaStatus
                {
                    performDelete = false
                }
                
                if myAgendaList[indexPath.row].title == "Close meeting"
                {
                    performDelete = false
                }
                
                if myAgendaList[indexPath.row].title == "Review of previous meeting actions"
                {
                    performDelete = false
                }
                
                if performDelete
                {
                    myAgendaList[indexPath.row].delete()
                    
                    buildAgendaArray()
                    
                    tblAgenda.reloadData()
                }
            }
        }
    }
    
    @IBAction func btnRearrange(_ sender: UIButton)
    {
        tblAgenda.isEditing = !tblAgenda.isEditing
        
        if tblAgenda.isEditing
        {
            btnRearrange.setTitle("Stop Rearranging", for: .normal)
        }
        else
        {
            btnRearrange.setTitle("Rearrange Agenda Items", for: .normal)
        }
    }
    
    @IBAction func btnAddAgendaItem(_ sender: UIButton)
    {
        if txtDescription.text == ""
        {
            let alert = UIAlertController(title: "Add Agenda Item", message:
        "You must provide a description for the Agenda Item before you can Add it", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
    
            self.present(alert, animated: false, completion: nil)
        }
        else
        {
            let agendaItem = meetingAgendaItem(meetingID: passedMeeting.meetingID, teamID: currentUser.currentTeam!.teamID)
            agendaItem.status = "Open"
            agendaItem.decisionMade = ""
            agendaItem.discussionNotes = ""
            if txtTimeAllocation.text == ""
            {
                agendaItem.timeAllocation = 10
            }
            else
            {
                agendaItem.timeAllocation = Int(txtTimeAllocation.text!)!
            }
            if btnOwner.currentTitle != "Select Owner"
            {
                agendaItem.owner = btnOwner.currentTitle!
            }
        
            agendaItem.title = txtDescription.text!
        
            agendaItem.save()

            // reload the Agenda Items collection view
            buildAgendaArray()
            
            myWorkingTime = passedMeeting.startDate as Date
            tblAgenda.reloadData()
        
            // set the fields to blank
        
            txtTimeAllocation.text = ""
            txtDescription.text = ""
            btnOwner.setTitle("Select Owner", for: .normal)
        }
    }
    
    @IBAction func btnOwner(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        displayList.append("")
        for attendee in passedMeeting.attendees
        {
            displayList.append(attendee.name)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "owner"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnChair(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        displayList.append("")
        for attendee in passedMeeting.attendees
        {
            displayList.append(attendee.name)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "chair"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnMinutes(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        
        displayList.append("")
        for attendee in passedMeeting.attendees
        {
            displayList.append(attendee.name)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "minutes"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnPreviousMeeting(_ sender: UIButton)
    {
        // We only list items here that we have Meeting records for, as otherwise there is no previous actions to get and display
        
        // if a recurring meeting invite then display previous occurances at the top of the list
        
        displayList.removeAll(keepingCapacity: false)
        meetingList.removeAll(keepingCapacity: false)
        
        displayList.append("")
        meetingList.append("")
        
        if passedMeeting.event!.recurrenceRules != nil
        {
            // Recurring event, so display rucurrences first
            
            // get the meeting id, and remove the trailing portion in order to use in a search
            
            let myItems = myDatabaseConnection.searchPastAgendaByPartialMeetingIDBeforeStart(passedMeeting.meetingID, meetingStartDate: passedMeeting.startDate as NSDate, teamID: currentUser.currentTeam!.teamID)
            
            if myItems.count > 0
            { // There is an previous meeting
                for myItem in myItems
                {
                    if myItem.meetingID != passedMeeting.meetingID
                    { // Not this meeting meeting
                        let startDateFormatter = DateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                        displayList.append("\(myItem.name!) - \(myDisplayDate)")
                        meetingList.append(myItem.meetingID!)
                    }
                }
            }
            
            // display remaining items, newest first
            
            let myNonItems = myDatabaseConnection.searchPastAgendaWithoutPartialMeetingIDBeforeStart(passedMeeting.meetingID, meetingStartDate: passedMeeting.startDate as NSDate, teamID: currentUser.currentTeam!.teamID)
            
            if myNonItems.count > 0
            { // There is an previous meeting
                for myItem in myNonItems
                {
                    if myItem.meetingID != passedMeeting.meetingID
                    { // Not this meeting meeting
                        let startDateFormatter = DateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                        displayList.append("\(myItem.name!) - \(myDisplayDate)")
                        meetingList.append(myItem.meetingID!)
                    }
                }
            }
            
            // Next meeting could also be a non entry so need to show calendar items as well
        }
        else
        {
            //non-recurring event, so display in date order, newest first
            
            // list items prior to meeting date
            
            let myItems = myDatabaseConnection.listAgendaReverseDateAfterStart(passedMeeting.startDate as NSDate, teamID: currentUser.currentTeam!.teamID)
            
            if myItems.count > 0
            { // There is an previous meeting
                for myItem in myItems
                {
                    if myItem.meetingID != passedMeeting.meetingID
                    { // Not this meeting meeting
                        let startDateFormatter = DateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                        displayList.append("\(myItem.name!) - \(myDisplayDate)")
                        meetingList.append(myItem.meetingID!)
                    }
                }
            }
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
            
            pickerView.source = "previousMeeting"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnNextMeeting(_ sender: UIButton)
    {
        displayList.removeAll(keepingCapacity: false)
        meetingList.removeAll(keepingCapacity: false)
        
        displayList.append("")
        meetingList.append("")
        
        var calItems: [EKEvent] = []
        
        let startDate = passedMeeting.startDate
        
        let endDateModifier = readDefaultInt("CalAfter") as Int
        
        let endDate = Date().add(.day, amount: (endDateModifier * 7))
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        let searchPredicate = globalEventStore.predicateForEvents(
            withStart: startDate as Date,
            end: endDate,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if globalEventStore.sources.count > 0
        {
            calItems = globalEventStore.events(matching: searchPredicate)
        }
        
        if calItems.count >  0
        {
            // Go through all the events and print them to the console
            for calItem in calItems
            {
                if passedMeeting.meetingID != "\(calItem.calendarItemExternalIdentifier) Date: \(calItem.startDate)"
                {
                    let startDateFormatter = DateFormatter()
                    startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                    let myDisplayDate = startDateFormatter.string(from: calItem.startDate)
                    
                    displayList.append("\(calItem.title) - \(myDisplayDate)")
                    meetingList.append("\(calItem.calendarItemExternalIdentifier) Date: \(calItem.startDate)")
                }
            }
        }
        
        if passedMeeting.event?.recurrenceRules != nil
        {
            // Recurring event, so display rucurrences first
            
            // get the meeting id, and remove the trailing portion in order to use in a search
            
            var myItems: [MeetingAgenda]!
            
            let tempMeetingID = passedMeeting.meetingID
            if tempMeetingID.range(of: "/") != nil
            {
                let myStringArr = tempMeetingID.components(separatedBy: "/")
                myItems = myDatabaseConnection.searchPastAgendaByPartialMeetingIDBeforeStart(myStringArr[0], meetingStartDate: passedMeeting.startDate as NSDate, teamID: currentUser.currentTeam!.teamID)
            }
            else
            {
                myItems = myDatabaseConnection.searchPastAgendaByPartialMeetingIDBeforeStart(passedMeeting.meetingID, meetingStartDate: passedMeeting.startDate as NSDate, teamID: currentUser.currentTeam!.teamID)
            }
            
            if myItems.count > 1
            { // There is an previous meeting
                for myItem in myItems
                {
                    if myItem.meetingID != passedMeeting.meetingID
                    { // Not this meeting meeting
                        let startDateFormatter = DateFormatter()
                        startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                        let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                        
                        displayList.append("\(myItem.name!) - \(myDisplayDate)")
                        meetingList.append(myItem.meetingID!)
                    }
                }
            }
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
            
            pickerView.source = "nextMeeting"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnViewPreviousMeeting(_ sender: UIButton)
    {
        passedMeeting = calendarItem(meetingID: passedMeeting.previousMinutes, teamID: passedMeeting.teamID)
        refreshScreen()
    }
    
    @IBAction func btnViewNextMeeting(_ sender: UIButton)
    {
        passedMeeting = calendarItem(meetingID: passedMeeting.nextMeeting, teamID: passedMeeting.teamID)
        refreshScreen()
    }

    @IBAction func btnFinalise(_ sender: UIButton)
    {
        if passedMeeting.meetingStatus == agendaStatus
        {
            passedMeeting.meetingStatus = minutesStatus
            
        }
        else
        {
            passedMeeting.meetingStatus = finishedStatus
        }
        
        setStatus()
    }
    
    func buildPeopleList()
    {
        displayList.removeAll()
        
        for attendee in passedMeeting.attendees
        {
            displayList.append(attendee.name)
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        switch source
        {
            case "chair":
                passedMeeting.chair = displayList[selectedItem]
                btnChair.setTitle(displayList[selectedItem], for: .normal)
            
            case "minutes":
                passedMeeting.minutes = displayList[selectedItem]
                btnMinutes.setTitle(displayList[selectedItem], for: .normal)
            
            case "owner":
                btnOwner.setTitle(displayList[selectedItem], for: .normal)
            
            case "previousMeeting":
                let tempMeeting = calendarItem(meetingID: meetingList[selectedItem], teamID: passedMeeting.teamID)
                btnPreviousMeeting.setTitle(tempMeeting.displayStartDate, for: .normal)
                passedMeeting.previousMinutes = meetingList[selectedItem]
                
                btnViewPreviousMeeting.isHidden = false
            
            case "nextMeeting":
                let tempMeeting = calendarItem(meetingID: meetingList[selectedItem], teamID: passedMeeting.teamID)
                tempMeeting.previousMinutes = passedMeeting.meetingID
                btnNextMeeting.setTitle(tempMeeting.displayStartDate, for: .normal)
                
                btnViewNextMeeting.isHidden = false
            
            default:
                print("myPickerDidFinish selectedItem hit default - source = \(source)")
        }
    }
    
    func hideFields()
    {
        lblAgendaItems.isHidden = true
        tblAgenda.isHidden = true
        btnAddAgendaItem.isHidden = true
        lblAddAgendaItem.isHidden = true
        lblDescription.isHidden = true
        lblTimeAllocation.isHidden = true
        txtDescription.isHidden = true
        txtTimeAllocation.isHidden = true
        lblOwner.isHidden = true
        btnOwner.isHidden = true
        lblNextMeeting.isHidden = true
        lblPreviousMeeting.isHidden = true
        btnPreviousMeeting.isHidden = true
        btnNextMeeting.isHidden = true
        btnViewPreviousMeeting.isHidden = true
        btnViewNextMeeting.isHidden = true
    }
    
    func showFields()
    {
        lblAgendaItems.isHidden = false
        tblAgenda.isHidden = false
        btnAddAgendaItem.isHidden = false
        lblAddAgendaItem.isHidden = false
        lblDescription.isHidden = false
        lblTimeAllocation.isHidden = false
        txtDescription.isHidden = false
        txtTimeAllocation.isHidden = false
        lblOwner.isHidden = false
        btnOwner.isHidden = false
        lblNextMeeting.isHidden = false
        lblPreviousMeeting.isHidden = false
        btnPreviousMeeting.isHidden = false
        btnNextMeeting.isHidden = false
        
        if passedMeeting.previousMinutes == ""
        {
            btnPreviousMeeting.setTitle("Select", for: .normal)
            btnViewPreviousMeeting.isHidden = true
        }
        else
        {
            let tempMeeting = calendarItem(meetingID: passedMeeting.previousMinutes, teamID: passedMeeting.teamID)
            if tempMeeting.title == ""
            {
                btnPreviousMeeting.setTitle("Select", for: .normal)
                btnViewPreviousMeeting.isHidden = true
            }
            else
            {
                btnPreviousMeeting.setTitle(tempMeeting.displayStartDate, for: .normal)
                btnViewPreviousMeeting.isHidden = false
            }
        }
      
        // See if there is a meeting with this one as its previous ID
        
        if passedMeeting.nextMeeting == ""
        {
            btnNextMeeting.setTitle("Select", for: .normal)
            btnViewNextMeeting.isHidden = true
        }
        else
        {
            let tempMeeting = calendarItem(meetingID: passedMeeting.nextMeeting, teamID: passedMeeting.teamID)
            if tempMeeting.title == ""
            {
                btnNextMeeting.setTitle("Select", for: .normal)
                btnViewNextMeeting.isHidden = true
            }
            else
            {
                btnNextMeeting.setTitle(tempMeeting.displayStartDate, for: .normal)
                btnViewNextMeeting.isHidden = false
            }
        }
    }

    func buildAgendaArray()
    {
        myWorkingTime = passedMeeting.startDate as Date
        passedMeeting.loadAgendaItems()
        if passedMeeting.previousMinutes == ""
        { // No previous meeting
            myAgendaList = passedMeeting.agendaItems
        }
        else
        { // Previous meeting exists
            let previousMinutes  = meetingAgendaItem(rowType: "PreviousMinutes", teamID: currentUser.currentTeam!.teamID)
            
            myAgendaList.removeAll(keepingCapacity: false)
            myAgendaList.append(previousMinutes)
            for myItem in passedMeeting.agendaItems
            {
                myAgendaList.append(myItem)
            }
        }
        
        let closeMeeting = meetingAgendaItem(rowType: "Close", teamID: currentUser.currentTeam!.teamID)
        myAgendaList.append(closeMeeting)
    }
    
    func refreshScreen()
    {
        buildAgendaArray()
        passedMeeting.loadAttendees()
        
        btnOwner.setTitle("Select Owner", for: .normal)
        
        if passedMeeting.attendees.count == 0
        {
            btnOwner.setTitle(currentUser.name, for: .normal)
            passedMeeting.chair = currentUser.name
            passedMeeting.minutes = currentUser.name
            btnChair.setTitle(passedMeeting.chair, for: .normal)
            btnMinutes.setTitle(passedMeeting.minutes, for: .normal)
            btnOwner.isEnabled = false
            btnChair.isEnabled = false
            btnMinutes.isEnabled = false
        }
        else
        {
            btnOwner.isEnabled = true
            btnChair.isEnabled = true
            btnMinutes.isEnabled = true
            
            if passedMeeting.chair == ""
            {
                btnChair.setTitle("Select Chair", for: .normal)
            }
            else
            {
                btnChair.setTitle(passedMeeting.chair, for: .normal)
            }
            
            if passedMeeting.minutes == ""
            {
                btnMinutes.setTitle("Select Minute taker", for: .normal)
            }
            else
            {
                btnMinutes.setTitle(passedMeeting.minutes, for: .normal)
            }
        }
        navBarTitle.title = passedMeeting.title
        myWorkingTime = passedMeeting.startDate as Date
        
        showFields()
        tblAttendees.reloadData()
        tblAgenda.reloadData()
        
        setStatus()
        
        tblAgenda.isEditing = false
        btnRearrange.setTitle("Rearrange Agenda Items", for: .normal)
    }
    
    func setStatus()
    {
        if passedMeeting.meetingStatus == agendaStatus
        {
            tblAgenda.setEditing(true, animated: true)
            btnFinalise.setTitle("Finalise Agenda", for: .normal)
        }
        else
        {
            tblAgenda.setEditing(false, animated: true)
            
            if passedMeeting.meetingStatus == minutesStatus
            {
                btnFinalise.setTitle("Finalise Minutes", for: .normal)
            }
            else
            {
                btnFinalise.setTitle("Meeting Completed", for: .normal)
                btnFinalise.isEnabled = false
            }
        }
    }
    
    func myTaskListDidFinish(_ controller:taskListViewController)
    {
print("Garry - find where calls this and replace with my call to refreshScreen via commsdeletgate")
        refreshScreen()
        controller.dismiss(animated: true, completion: nil)
    }
    
    func createActivityController() -> UIActivityViewController
    {
        // Build up the details we want to share
        let sourceString: String = ""
        let sharingActivityProvider: SharingActivityProvider = SharingActivityProvider(placeholderItem: sourceString)
        
        let myTmp1 = passedMeeting.buildShareHTMLString().replacingOccurrences(of: "\n", with: "<p>")
        sharingActivityProvider.HTMLString = myTmp1
        sharingActivityProvider.plainString = passedMeeting.buildShareString()

        if passedMeeting.startDate.compare(Date()) == ComparisonResult.orderedAscending
        {  // Historical so show Minutes
            sharingActivityProvider.messageSubject = "Minutes for meeting: \(passedMeeting.title)"
        }
        else
        {
            sharingActivityProvider.messageSubject = "Agenda for meeting: \(passedMeeting.title)"
        }
        
        let activityItems : Array = [sharingActivityProvider];
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // you can specify these if you'd like.
        activityViewController.excludedActivityTypes =  [
            UIActivityType.postToTwitter,
            UIActivityType.postToFacebook,
            UIActivityType.postToWeibo,
            UIActivityType.message,
            //        UIActivityTypeMail,
            //        UIActivityTypePrint,
            //        UIActivityTypeCopyToPasteboard,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        
        return activityViewController
    }

    func doNothing()
    {
        // as it says, do nothing
    }
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
        communicationDelegate?.refreshScreen!()
    }
    
    @IBAction func btnShre(_ sender: UIBarButtonItem)
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            //self.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
            let activityViewController: UIActivityViewController = createActivityController()
            activityViewController.popoverPresentationController!.sourceView = lblChair
            present(activityViewController, animated:true, completion:nil)
        }
        else if UIDevice.current.userInterfaceIdiom == .pad
        {
            // actually, you don't have to do this. But if you do want a popover, this is how to do it.
            iPad(sender)
        }
    }
    
    func iPad(_ sender: AnyObject)
    {
        let activityViewController: UIActivityViewController = createActivityController()
        activityViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        activityViewController.popoverPresentationController!.sourceView = lblChair
        present(activityViewController, animated:true, completion:nil)
        /*
        if !self.activityPopover.popoverVisible {
            if sender is UIBarButtonItem {
                self.activityPopover.presentPopoverFromBarButtonItem(sender as! UIBarButtonItem,
                    permittedArrowDirections:.Any,
                    animated:true)
            } else {
                let b = sender as! UIButton
                self.activityPopover.presentPopoverFromRect(b.frame,
                    inView: self.view,
                    permittedArrowDirections:.Any,
                    animated:true)
            }
        } else {
            self.activityPopover.dismissPopoverAnimated(true)
        }
*/
    }
//    //---------------------------------------------------------------
//    // These three methods implement the SMTEFillDelegate protocol to support fill-ins
//    
//    /* When an abbreviation for a snippet that looks like a fill-in snippet has been
//    * typed, SMTEDelegateController will call your fill delegate's implementation of
//    * this method.
//    * Provide some kind of identifier for the given UITextView/UITextField/UISearchBar/UIWebView
//    * The ID doesn't have to be fancy, "maintext" or "searchbar" will do.
//    * Return nil to avoid the fill-in app-switching process (the snippet will be expanded
//    * with "(field name)" where the fill fields are).
//    *
//    * Note that in the case of a UIWebView, the uiTextObject passed will actually be
//    * an NSDictionary with two of these keys:
//    *     - SMTEkWebView          The UIWebView object (key always present)
//    *     - SMTEkElementID        The HTML element's id attribute (if found, preferred over Name)
//    *     - SMTEkElementName      The HTML element's name attribute (if id not found and name found)
//    * (If no id or name attribute is found, fill-in's cannot be supported, as there is
//    * no way for TE to insert the filled-in text.)
//    * Unless there is only one editable area in your web view, this implies that the returned
//    * identifier string needs to include element id/name information. Eg. "webview-field2".
//    */
//    
//    //func identifierForTextArea(_ uiTextObject: AnyObject) -> String
//    func identifier(forTextArea uiTextObject: Any) -> String
//    {
//        var result: String = ""
//        
//        if uiTextObject is UITextField
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "txtDescription"
//            }
//        }
//        
//        if uiTextObject is UITextView
//        {
//            if (uiTextObject as AnyObject).tag == 1
//            {
//                result = "unused"
//            }
//        }
//        
//        if uiTextObject is UISearchBar
//        {
//            result =  "mySearchBar"
//        }
//        
//        return result
//    }
//    
//    
//    /* Usually called milliseconds after identifierForTextArea:, SMTEDelegateController is
//    * about to call [[UIApplication sharedApplication] openURL: "tetouch-xc: *x-callback-url/fillin?..."]
//    * In other words, the TEtouch is about to be activated. Your app should save state
//    * and make any other preparations.
//    *
//    * Return NO to cancel the process.
//    */
//
//    func prepare(forFillSwitch textIdentifier: String) -> Bool
//    {
//        // At this point the app should save state since TextExpander touch is about
//        // to activate.
//        // It especially needs to save the contents of the textview/textfield!
//        
//        return true
//    }
//    
//    /* Restore active typing location and insertion cursor position to a text item
//    * based on the identifier the fill delegate provided earlier.
//    * (This call is made from handleFillCompletionURL: )
//    *
//    * In the case of a UIWebView, this method should build and return an NSDictionary
//    * like the one sent to the fill delegate in identifierForTextArea: when the snippet
//    * was triggered.
//    * That is, you should make the UIWebView become first responder, then return an
//    * NSDictionary with two of these keys:
//    *     - SMTEkWebView          The UIWebView object (key must be present)
//    *     - SMTEkElementID        The HTML element's id attribute (preferred over Name)
//    *     - SMTEkElementName      The HTML element's name attribute (only if no id)
//    * TE will use the same Javascripts that it uses to expand normal snippets to focus the appropriate
//    * element and insert the filled text.
//    *
//    * Note 1: If your app is still loaded after returning from TEtouch's fill window,
//    * probably no work needs to be done (the text item will still be the first
//    * responder, and the insertion cursor position will still be the same).
//    * Note 2: If the requested insertionPointLocation cannot be honored (ie. text has
//    * been reset because of the app switching), then update it to whatever is reasonable.
//    *
//    * Return nil to cancel insertion of the fill-in text. Users will not expect a cancel
//    * at this point unless userCanceledFill is set. Even in the cancel case, they will likely
//    * expect the identified text object to become the first responder.
//    */
//    
//   // func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
//    public func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String!, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>!) -> Any!
//    {
//        snippetExpanded = true
//
//        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.pointee
//        
//        if "txtDescription" == textIdentifier
//        {
//            txtDescription.becomeFirstResponder()
//            let theLoc = txtDescription.position(from: txtDescription.beginningOfDocument, offset: intIoInsertionPointLocation)
//            if theLoc != nil
//            {
//                txtDescription.selectedTextRange = txtDescription.textRange(from: theLoc!, to: theLoc!)
//            }
//            return txtDescription
//        }
//            //        else if "mySearchBar" == textIdentifier
//            //        {
//            //            searchBar.becomeFirstResponder()
//            // Note: UISearchBar does not support cursor positioning.
//            // Since we don't save search bar text as part of our state, if our app was unloaded while TE was
//            // presenting the fill-in window, the search bar might now be empty to we should return
//            // insertionPointLocation of 0.
//            //            let searchTextLen = searchBar.text.length
//            //            if searchTextLen < ioInsertionPointLocation
//            //            {
//            //                ioInsertionPointLocation = searchTextLen
//            //            }
//            //            return searchBar
//            //        }
//        else
//        {
//            
//            //return nil
//            
//            return "" as AnyObject
//        }
//    }
//    
//    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
//    {
//        if (textExpander.isAttemptingToExpandText)
//        {
//            snippetExpanded = true
//        }
//        return true
//    }
//    
//    // Workaround for what appears to be an iOS 7 bug which affects expansion of snippets
//    // whose content is greater than one line. The UITextView fails to update its display
//    // to show the full content. Try commenting this out and expanding "sig1" to see the issue.
//    //
//    // Given other oddities of UITextView on iOS 7, we had assumed this would be fixed along the way.
//    // Instead, we'll have to work up an isolated case and file a bug. We don't want to bake this kind
//    // of workaround into the SDK, so instead we provide an example here.
//    // If you have a better workaround suggestion, we'd love to hear it.
//    
//    func twiddleText(_ textView: UITextView)
//    {
//        let SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO = UIDevice.current.systemVersion
//        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO >= "7.0"
//        {
//            textView.textStorage.edited(NSTextStorageEditActions.editedCharacters,range:NSMakeRange(0, textView.textStorage.length),changeInLength:0)
//        }
//    }
//    
//    func textViewDidChange(_ textView: UITextView)
//    {
//        if snippetExpanded
//        {
//            usleep(10000)
//            twiddleText(textView)
//            
//            // performSelector(twiddleText:, withObject: textView, afterDelay:0.01)
//            snippetExpanded = false
//        }
//    }
//    
//    
//    /*
//    // The following are the UITextViewDelegate methods; they simply write to the console log for demonstration purposes
//    
//    func textViewDidBeginEditing(textView: UITextView)
//    {
//    println("nextDelegate textViewDidBeginEditing")
//    }
//    func textViewShouldBeginEditing(textView: UITextView) -> Bool
//    {
//    println("nextDelegate textViewShouldBeginEditing")
//    return true
//    }
//    
//    func textViewShouldEndEditing(textView: UITextView) -> Bool
//    {
//    println("nextDelegate textViewShouldEndEditing")
//    return true
//    }
//    
//    func textViewDidEndEditing(textView: UITextView)
//    {
//    println("nextDelegate textViewDidEndEditing")
//    }
//    
//    func textViewDidChangeSelection(textView: UITextView)
//    {
//    println("nextDelegate textViewDidChangeSelection")
//    }
//    
//    // The following are the UITextFieldDelegate methods; they simply write to the console log for demonstration purposes
//    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldBeginEditing")
//    return true
//    }
//    
//    func textFieldDidBeginEditing(textField: UITextField)
//    {
//    println("nextDelegate textFieldDidBeginEditing")
//    }
//    
//    func textFieldShouldEndEditing(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldEndEditing")
//    return true
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField)
//    {
//    println("nextDelegate textFieldDidEndEditing")
//    }
//    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
//    {
//    println("nextDelegate textField:shouldChangeCharactersInRange: \(NSStringFromRange(range)) Original=\(textField.text), replacement = \(string)")
//    return true
//    }
//    
//    func textFieldShouldClear(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldClear")
//    return true
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool
//    {
//    println("nextDelegate textFieldShouldReturn")
//    return true
//    }
//    */
//
    
}

class myAgendaItemHeader: UICollectionReusableView
{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
}

class myAgendaItem: UITableViewCell
{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
}

class meetingAgendaEntry: UITableViewCell, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    
    fileprivate var displayList: [String] = Array()
    
    var sourceView: meetingAgendaEntry!
    var mainView: meetingAgendaViewController!
    
    var attendeeEntry: meetingAttendee!
    
    @IBAction func btnAction(_ sender: UIButton)
    {
        displayList.append(meetingAttendenceAttended)
        displayList.append(meetingAttendenceApologised)
        displayList.append(meetingAttendenceNotAttend)
        displayList.append(meetingAttendenceDelegated)
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "chair"
        pickerView.delegate = sourceView
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        pickerView.currentValue = sender.currentTitle!
        mainView.present(pickerView, animated: true, completion: nil)
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        attendeeEntry.status = displayList[selectedItem]
        btnAction.setTitle(displayList[selectedItem], for: .normal)
    }
}


