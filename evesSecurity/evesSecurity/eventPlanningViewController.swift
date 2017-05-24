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
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblEvents: UITableView!
    @IBOutlet weak var tblRoles: UITableView!
    @IBOutlet weak var lblAddToRole: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnAddRole: UIButton!
    @IBOutlet weak var lblEventTemplate: UILabel!
    @IBOutlet weak var lblContractName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnDate: UIButton!
    
    var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var eventList: projects!
    fileprivate var currentEvent: project!
    fileprivate var displayList: [String] = Array()
    fileprivate var currentTemplate: eventTemplateHead!
    fileprivate var templateList: eventTemplateHeads!
    fileprivate var eventDays: [Date] = Array()
    fileprivate var newRoleDate: Date!
    fileprivate var peopleList: people!
    fileprivate var rateList: rates!
    
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
                if currentEvent == nil
                {
                    return 0
                }
                else
                {
                    if currentEvent.staff == nil
                    {
                        return 0
                    }
                    else
                    {
                        return (currentEvent.staff?.shifts.count)!
                    }
                }
                
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
                
                cell.lblRole.text = currentEvent.staff?.shifts[indexPath.row].shiftDescription
                cell.lblDate.text = currentEvent.staff?.shifts[indexPath.row].workDateString
                cell.btnRate.setTitle(currentEvent.staff?.shifts[indexPath.row].rateDescription, for: .normal)
                cell.btnPerson.setTitle(currentEvent.staff?.shifts[indexPath.row].personName, for: .normal)
                cell.btnStart.setTitle(currentEvent.staff?.shifts[indexPath.row].startTimeString, for: .normal)
                cell.btnEnd.setTitle(currentEvent.staff?.shifts[indexPath.row].endTimeString, for: .normal)
                
                cell.mainView = self
                cell.sourceView = cell
                cell.shiftRecord = currentEvent.staff?.shifts[indexPath.row]
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
                rateList = rates(clientID: currentEvent.clientID)

                refreshScreen()
                if currentEvent.staff?.shifts.count == 0
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
                eventDays.append(addDays(to: currentEvent.projectStartDate, days: -2))
                eventDays.append(addDays(to: currentEvent.projectStartDate, days: -1))
                eventDays.append(currentEvent.projectStartDate)
                eventDays.append(addDays(to: currentEvent.projectStartDate, days: 1))
                eventDays.append(addDays(to: currentEvent.projectStartDate, days: 2))
                btnDate.setTitle(formatDateToString(currentEvent.projectStartDate), for: .normal)
            
            case tblRoles:
                let _ = 1
                
                
            default:
                let _ = 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        switch tableView
        {
            case tblEvents:
                return nil
                
            case tblRoles:
                let headerView = tableView.dequeueReusableCell(withIdentifier: "cellEventHeader") as! eventRoleHeaderItem
                return headerView
            
            default:
                return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        switch tableView
        {
            case tblEvents:
                return 0
                
            case tblRoles:
                return 30
                
            default:
                return 0
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton)
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
                workDay = addDays(to: currentEvent.projectStartDate, days: myItem.dateModifier)
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
        
        refreshScreen()
        
        showFields()
    }

    @IBAction func btnDate(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in eventDays
        {
            displayList.append(formatDateToString(myItem))
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
        
        
        print("Role Date = \(newRoleDate)")
        
        createShiftEntry(teamID: currentUser.currentTeam!.teamID, projectID: currentEvent.projectID, shiftDescription: btnSelect.currentTitle!, workDay: newRoleDate, startTime: getDefaultDate(), endTime: getDefaultDate())
        
        refreshScreen()
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
        let WEDate = getWeekEndingDate(workDay)
        
        let shiftLineID = myDatabaseConnection.getNextID("shiftLineID", saveToCloud: saveToCloud)
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
    }
    
    func refreshScreen()
    {
        eventList = projects(teamID: currentUser.currentTeam!.teamID, type: eventShiftType)
        tblEvents.reloadData()
        
        if currentEvent != nil
        {
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

class eventRoleHeaderItem: UITableViewCell
{
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var lblPerson: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblEnd: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}
