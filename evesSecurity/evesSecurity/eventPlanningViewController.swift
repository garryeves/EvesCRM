//
//  eventPlanningViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 23/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class eventPlanningViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var btnTemplate: UIButton!
    @IBOutlet weak var btnCreatePlan: UIButton!
    @IBOutlet weak var btnMaintainTemplates: UIButton!
    @IBOutlet weak var tblEvents: UITableView!
    @IBOutlet weak var tblRoles: UITableView!
    @IBOutlet weak var lblAddToRole: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnAddRole: UIButton!
    @IBOutlet weak var lblEventTemplate: UILabel!
    @IBOutlet weak var lblContractName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblRoleHead: UILabel!
    @IBOutlet weak var lblPersonHead: UILabel!
    @IBOutlet weak var lblRateHead: UILabel!
    @IBOutlet weak var lblDateHead: UILabel!
    @IBOutlet weak var lblStarHead: UILabel!
    @IBOutlet weak var lblEndHead: UILabel!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    
    var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var eventList: projects!
    var currentEvent: project!
    fileprivate var displayList: [String] = Array()
    fileprivate var currentTemplate: eventTemplateHead!
    fileprivate var templateList: eventTemplateHeads!
    fileprivate var eventDays: [Date] = Array()
    fileprivate var newRoleDate: Date!
    fileprivate var peopleList: people!
    fileprivate var rateList: rates!
    fileprivate var shiftList: [shift] = Array()
    
    override func viewDidLoad()
    {
        peopleList = people(teamID: currentUser.currentTeam!.teamID)
        hideAllFields()
        refreshScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblEvents:
                if eventList == nil
                {
                    return 0
                }
                else
                {
                    return eventList.projects.count
                }
                
            case tblRoles:
                return shiftList.count
                
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblEvents:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellEventName", for: indexPath) as! eventSummaryItem
                
                cell.lblName.text = eventList.projects[indexPath.row].projectName
                cell.lblDate.text = eventList.projects[indexPath.row].displayProjectStartDate
                
                return cell
                
            case tblRoles:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellEvent", for: indexPath) as! eventRoleItem
                
                cell.lblRole.text = shiftList[indexPath.row].shiftDescription
                cell.lblDate.text = shiftList[indexPath.row].workDateShortString
                cell.btnRate.setTitle(shiftList[indexPath.row].rateDescription, for: .normal)
                cell.btnPerson.setTitle(shiftList[indexPath.row].personName, for: .normal)
                cell.btnStart.setTitle(shiftList[indexPath.row].startTimeString, for: .normal)
                cell.btnEnd.setTitle(shiftList[indexPath.row].endTimeString, for: .normal)
                
                cell.mainView = self
                cell.sourceView = cell
                cell.shiftRecord = shiftList[indexPath.row]
                cell.peopleList = peopleList
                cell.rateList = rateList
                
                return cell
                
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblEvents:
                currentEvent = eventList.projects[indexPath.row]
                refreshScreen()
            
            case tblRoles:
                let _ = 1
                
                
            default:
                let _ = 1
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if tableView == tblRoles
        {
            if editingStyle == .delete
            {
                shiftList[indexPath.row].delete()
         
                tblRoles.reloadData()
            }
        }
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnMaintainTemplates(_ sender: UIButton)
    {
        let templatesViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventTemplateForm") as! eventTemplateVoewController
        templatesViewControl.communicationDelegate = self
        self.present(templatesViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnCreatePlan(_ sender: UIButton)
    {
        currentTemplate.loadRoles()
        let roles = currentTemplate.roles!.roles!
        
        var recordCount: Int = 0
        
        for myItem in roles
        {
            let workDay: Date!
            if myItem.dateModifier == 0
            {
                workDay = currentEvent.projectStartDate
            }
            else
            {
                workDay = currentEvent.projectStartDate.add(.day, amount: myItem.dateModifier)
            }
            
            if recordCount == roles.count - 1
            {
                // Save the decode on the last run
                createShiftEntry(teamID: currentUser.currentTeam!.teamID, projectID: currentEvent.projectID, shiftDescription: myItem.role, workDay: workDay, startTime: myItem.startTime, endTime: myItem.endTime)
            }
            else
            {
                createShiftEntry(teamID: currentUser.currentTeam!.teamID, projectID: currentEvent.projectID, shiftDescription: myItem.role, workDay: workDay, startTime: myItem.startTime, endTime: myItem.endTime, saveToCloud: false)
            }
            
            recordCount += 1
        }
        
        sleep(2)
        refreshScreen()
        
        showFields()
    }

    @IBAction func btnDate(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in eventDays
        {
            displayList.append(myItem.formatDateToString)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "workday"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 300,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnTemplate(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        templateList = eventTemplateHeads(teamID: currentUser.currentTeam!.teamID)
        for myItem in templateList.templates
        {
            displayList.append(myItem.templateName)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "template"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnSelect(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: "ShowRole"))!
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "role"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnAddRole(_ sender: UIButton)
    {
        createShiftEntry(teamID: currentUser.currentTeam!.teamID, projectID: currentEvent.projectID, shiftDescription: btnSelect.currentTitle!, workDay: newRoleDate, startTime: getDefaultDate(), endTime: getDefaultDate())
        
        sleep(2)
        refreshScreen()
    }
    
    @IBAction func btnShare(_ sender: UIBarButtonItem)
    {
        let titleString = "\(currentUser.currentTeam!.name) Event Plan for \(currentEvent.projectName)"
        
        let tempReport = report(name: reportEventPlan)
        
        tempReport.subject = titleString
        
        let headerLine = reportLine()
        headerLine.column1 = "Name"
        tempReport.columnWidth1 = 240
        headerLine.column2 = "Date"
        tempReport.columnWidth2 = 120
        headerLine.column3 = "Start"
        tempReport.columnWidth3 = 70
        headerLine.column4 = "End"
        tempReport.columnWidth4 = 70
        headerLine.column5 = "Role"
        tempReport.columnWidth5 = 200
        
        tempReport.header = headerLine
        
        var currentDate: String = ""
        var firstTime: Bool = true
        var currentShiftDescription: String = ""
        var currentStartTime: String = ""
        
        for myShift in shiftList
        {
            if myShift.workDateString != currentDate
            {
                if !firstTime
                {
                    let drawLine = reportLine()
                    drawLine.drawLine = true
                    tempReport.append(drawLine)
                }
        
                currentDate = myShift.workDateString
                currentShiftDescription = myShift.shiftDescription
                currentStartTime = myShift.startTimeString
            }
            
            if myShift.shiftDescription != currentShiftDescription
            {
                if !firstTime
                {
                    let drawLine = reportLine()
                    drawLine.drawLine = true
                    tempReport.append(drawLine)
                }
                currentShiftDescription = myShift.shiftDescription
                currentStartTime = myShift.startTimeString
            }
            else
            {
                if myShift.startTimeString != currentStartTime
                {
                    if !firstTime
                    {
                        let drawLine = reportLine()
                        drawLine.drawLine = true
                        tempReport.append(drawLine)
                    }
                    currentStartTime = myShift.startTimeString
                }
            }
            
            firstTime = false
            let newTimeLine = reportLine()
            
            newTimeLine.column1 = myShift.personName
            newTimeLine.column2 = myShift.workDateString
            newTimeLine.column3 = myShift.startTimeString
            newTimeLine.column4 = myShift.endTimeString
            newTimeLine.column5 = myShift.shiftDescription

            tempReport.append(newTimeLine)
        }
    
        let activityViewController = tempReport.activityController
        
        activityViewController.popoverPresentationController!.sourceView = btnAddRole
        
        present(activityViewController, animated:true, completion:nil)
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "template"
        {
            if selectedItem > 0
            {
                if displayList[selectedItem] == ""
                {
                    btnTemplate.setTitle("Select Template", for: .normal)
                    currentTemplate = nil
                    btnCreatePlan.isHidden = true
                }
                else
                {
                    btnTemplate.setTitle(displayList[selectedItem], for: .normal)
                }
                currentTemplate = templateList.templates[selectedItem - 1]
                btnCreatePlan.isHidden = false
            }
            else
            {
                btnTemplate.setTitle("Select Template", for: .normal)
                currentTemplate = nil
                if source == "template"
                {
                    if selectedItem > 1
                    {
                        if displayList[selectedItem] == ""
                        {
                            btnTemplate.setTitle("Select Template", for: .normal)
                            currentTemplate = nil
                            btnCreatePlan.isHidden = true
                        }
                        else
                        {
                            btnTemplate.setTitle(displayList[selectedItem], for: .normal)
                        }
                        currentTemplate = templateList.templates[selectedItem - 1]
                        btnCreatePlan.isHidden = false
                    }
                    else
                    {
                        btnTemplate.setTitle("Select Template", for: .normal)
                        currentTemplate = nil
                        btnCreatePlan.isHidden = true
                    }
                }

            }
        }
        
        if source == "role"
        {
            if selectedItem > 0
            {
                if displayList[selectedItem] == ""
                {
                    btnSelect.setTitle("Select Role", for: .normal)
                    btnAddRole.isHidden = true
                }
                else
                {
                    btnSelect.setTitle(displayList[selectedItem], for: .normal)
                }
                btnAddRole.isHidden = false
            }
            else
            {
                btnSelect.setTitle("Select Role", for: .normal)
                btnAddRole.isHidden = true
            }
        }
        
        if source == "workday"
        {
            var workingItem: Int = 0
            if selectedItem > 0
            {
                workingItem = selectedItem
            }
            
            btnDate.setTitle(displayList[workingItem], for: .normal)
            newRoleDate = eventDays[workingItem]
        }
    }
    
    func createShiftEntry(teamID: Int, projectID: Int, shiftDescription: String, workDay: Date, startTime: Date, endTime: Date, saveToCloud: Bool = true)
    {
        let WEDate = workDay.getWeekEndingDate
        
        let shiftLineID = myDatabaseConnection.getNextID("shiftLineID", saveToCloud: false)
        let newShift = shift(projectID: projectID, workDate: workDay, weekEndDate: WEDate, teamID: teamID, shiftLineID: shiftLineID, type: eventShiftType, saveToCloud: saveToCloud)
        newShift.shiftDescription = shiftDescription
        newShift.startTime = startTime
        newShift.endTime = endTime
        newShift.save()
    }
    
    func hideFields()
    {
        btnTemplate.isHidden = false
        btnTemplate.setTitle("Select Template", for: .normal)
        lblContractName.isHidden = false
        btnCreatePlan.isHidden = true
        lblEventTemplate.isHidden = false
        tblRoles.isHidden = true
        lblAddToRole.isHidden = true
        btnSelect.isHidden = true
        btnAddRole.isHidden = true
        lblDate.isHidden = true
        btnDate.isHidden = true
        lblRoleHead.isHidden = true
        lblPersonHead.isHidden = true
        lblRateHead.isHidden = true
        lblDateHead.isHidden = true
        lblStarHead.isHidden = true
        lblEndHead.isHidden = true
    }
    
    func showFields()
    {
        btnTemplate.isHidden = true
        btnCreatePlan.isHidden = true
        lblEventTemplate.isHidden = true
        tblRoles.isHidden = false
        lblAddToRole.isHidden = false
        btnSelect.isHidden = false
        btnAddRole.isHidden = false
        lblDate.isHidden = false
        btnDate.isHidden = false
        lblContractName.isHidden = false
        lblRoleHead.isHidden = false
        lblPersonHead.isHidden = false
        lblRateHead.isHidden = false
        lblDateHead.isHidden = false
        lblStarHead.isHidden = false
        lblEndHead.isHidden = false
    }
    
    func hideAllFields()
    {
        btnTemplate.isHidden = true
        btnCreatePlan.isHidden = true
        lblEventTemplate.isHidden = true
        tblRoles.isHidden = true
        lblAddToRole.isHidden = true
        btnSelect.isHidden = true
        btnAddRole.isHidden = true
        lblDate.isHidden = true
        btnDate.isHidden = true
        lblContractName.isHidden = true
        lblRoleHead.isHidden = true
        lblPersonHead.isHidden = true
        lblRateHead.isHidden = true
        lblDateHead.isHidden = true
        lblStarHead.isHidden = true
        lblEndHead.isHidden = true
    }
    
    func refreshScreen()
    {
        eventList = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true, type: eventShiftType)
        tblEvents.reloadData()
        
        if currentEvent != nil
        {
            rateList = rates(clientID: currentEvent.clientID)
            shiftList = currentEvent.staff!.shifts
            
            if shiftList.count == 0
            {
                hideFields()
            }
            else
            {
                showFields()
            }
            
            lblContractName.text = currentEvent.projectName
            newRoleDate = currentEvent.projectStartDate
            
            eventDays.removeAll()
            eventDays.append(currentEvent.projectStartDate.add(.day, amount: -2))
            eventDays.append(currentEvent.projectStartDate.add(.day, amount: -1))
            eventDays.append(currentEvent.projectStartDate)
            eventDays.append(currentEvent.projectStartDate.add(.day, amount: 1))
            eventDays.append(currentEvent.projectStartDate.add(.day, amount: 2))
            btnDate.setTitle(currentEvent.projectStartDate.formatDateToString, for: .normal)

            tblRoles.reloadData()
        }
    }
}

class eventSummaryItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class eventRoleItem: UITableViewCell, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var btnPerson: UIButton!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnEnd: UIButton!
    @IBOutlet weak var btnRate: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    
    var shiftRecord: shift!
    var peopleList: people!
    var rateList: rates!
    var sourceView: eventRoleItem!
    var mainView: eventPlanningViewController!
    
    fileprivate var displayList: [String] = Array()
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnPerson(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in peopleList.people
        {
            displayList.append(myItem.name)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "person"
        pickerView.delegate = sourceView
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 300,height: 500)
        
        mainView.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnStart(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        pickerView.source = "startTime"
        
        pickerView.currentDate = shiftRecord.startTime
        pickerView.delegate = sourceView
        pickerView.showTimes = true
        pickerView.showDates = false
        pickerView.minutesInterval = 5
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        mainView.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnEnd(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        pickerView.source = "endTime"
        
        pickerView.currentDate = shiftRecord.endTime
        pickerView.delegate = sourceView
        pickerView.showTimes = true
        pickerView.showDates = false
        pickerView.minutesInterval = 5
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        mainView.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnRate(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in rateList.rates
        {
            displayList.append(myItem.rateName)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        pickerView.source = "rate"

        pickerView.delegate = sourceView
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 300,height: 500)
        
        mainView.present(pickerView, animated: true, completion: nil)

    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if selectedItem > 0
        {
            // We have a new object, with a selected item, so we can go ahead and create a new summary row
            switch source
            {
            case "person":
                btnPerson.setTitle(peopleList.people[selectedItem - 1].name, for: .normal)
                
                shiftRecord.personID = peopleList.people[selectedItem - 1].personID
                shiftRecord.save()
                
            case "rate":
                btnRate.setTitle(rateList.rates[selectedItem - 1].rateName, for: .normal)
                shiftRecord.rateID = rateList.rates[selectedItem - 1].rateID
                shiftRecord.save()
                
             default:
                print("eventRoleItem myPickerDidFinish-Int got unexpected entry \(source)")
            }
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        switch source
        {
        case "startTime":
            btnStart.setTitle(dateFormatter.string(from: selectedDate), for: .normal)

            shiftRecord.startTime = selectedDate
            shiftRecord.save()
            
        case "endTime":
            btnEnd.setTitle(dateFormatter.string(from: selectedDate), for: .normal)
            
            shiftRecord.endTime = selectedDate
            shiftRecord.save()
            
        default:
            print("eventRoleItem myPickerDidFinish-Date got unexpected entry \(source)")
        }
    }
}

