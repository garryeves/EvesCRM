//
//  securityViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 15/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//
import UIKit

struct alertStruct
{
    var displayText: String
    var name: String
    var source: String
    var sourceObject: AnyObject!
}

class securityViewController: UIViewController, myCommunicationDelegate, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var btnSettings: UIBarButtonItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var btnPeople: UIButton!
    @IBOutlet weak var btnClients: UIButton!
    @IBOutlet weak var tblData1: UITableView!
    @IBOutlet weak var btnRoster: UIButton!
    @IBOutlet weak var btnEvents: UIButton!
    @IBOutlet weak var tblAlerts: UITableView!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var btnMaintainReports: UIButton!
    @IBOutlet weak var lblDropdown: UILabel!
    @IBOutlet weak var btnDropdown: UIButton!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    @IBOutlet weak var lbl6: UILabel!
    @IBOutlet weak var lbl7: UILabel!
    @IBOutlet weak var lbl8: UILabel!
    @IBOutlet weak var lbl9: UILabel!
    @IBOutlet weak var lbl10: UILabel!
    @IBOutlet weak var lbl11: UILabel!
    @IBOutlet weak var lbl13: UILabel!
    @IBOutlet weak var lbl12: UILabel!
    @IBOutlet weak var lbl14: UILabel!
    @IBOutlet weak var constraintWidth1: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth2: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth3: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth4: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth5: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth6: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth7: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth8: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth9: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth10: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth11: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth12: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth13: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth14: NSLayoutConstraint!
    @IBOutlet weak var btnMonthlyRoster: UIButton!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var btnYear: UIButton!
    @IBOutlet weak var btnSelect1: UIButton!
    @IBOutlet weak var btnSelect2: UIButton!
    
    fileprivate var contractList: projects!
    fileprivate var alertList: [alertStruct] = Array()
    
    fileprivate var reportList: reports = reports()
    fileprivate var displayList: [String] = Array()
    fileprivate var monthList: [String] = Array()
    
    fileprivate var currentReportID: Int = 0
    fileprivate var reportString: String = ""
    fileprivate var reportDate1: Date = Date()
    fileprivate var reportDate2: Date = Date()
    
    var communicationDelegate: myCommunicationDelegate?
    
    override func viewDidLoad()
    {
        btnSettings.title = NSString(string: "\u{2699}") as String
        
        btnSelect1.setTitle("Select", for: .normal)
        btnSelect2.setTitle("Select", for: .normal)
        
        btnPeople.setTitle("Maintain People", for: .normal)

        if readDefaultInt("reportID") >= 0
        {
            currentReportID = readDefaultInt("reportID")
        }

        btnDropdown.setTitle("Select", for: .normal)
        
        if readDefaultInt("reportYear") >= 0
        {
            let tempInt = readDefaultInt("reportYear")
            let tempString = "\(tempInt)"
            btnYear.setTitle(tempString, for: .normal)
        }
        else
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY"
            btnYear.setTitle(dateFormatter.string(from: Date()), for: .normal)
        }
        
        lblDropdown.isHidden = true
        btnDropdown.isHidden = true
        lblYear.isHidden = true
        btnYear.isHidden = true
        tblData1.isHidden = true

        refreshScreen()
        
        DispatchQueue.global().async
        {
            self.populateMonthList()
        }
        
        btnMaintainReports.isHidden = true
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.buildReportList), userInfo: nil, repeats: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblData1:
                for myItem in reportList.reports
                {
                    if myItem.reportName == btnReport.currentTitle!
                    {
                        return myItem.count
                    }
                }
            
                return 0
            case tblAlerts:
                 return alertList.count
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblData1:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellData1", for: indexPath) as! contractsListItem
                
                for myItem in reportList.reports
                {
                    if myItem.reportName == btnReport.currentTitle!
                    {
                        resetWidth(constraint: cell.constraintWidth1)
                        resetWidth(constraint: cell.constraintWidth2)
                        resetWidth(constraint: cell.constraintWidth3)
                        resetWidth(constraint: cell.constraintWidth4)
                        resetWidth(constraint: cell.constraintWidth5)
                        resetWidth(constraint: cell.constraintWidth6)
                        resetWidth(constraint: cell.constraintWidth7)
                        resetWidth(constraint: cell.constraintWidth8)
                        resetWidth(constraint: cell.constraintWidth9)
                        resetWidth(constraint: cell.constraintWidth10)
                        resetWidth(constraint: cell.constraintWidth11)
                        resetWidth(constraint: cell.constraintWidth12)
                        resetWidth(constraint: cell.constraintWidth13)
                        resetWidth(constraint: cell.constraintWidth14)
                        
                        let reportEntry = myItem.lines[indexPath.row]
                        buildReportCell(label: cell.lbl1, text: reportEntry.column1, width: myItem.columnWidth1, constraint: cell.constraintWidth1, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl2, text: reportEntry.column2, width: myItem.columnWidth2, constraint: cell.constraintWidth2, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl3, text: reportEntry.column3, width: myItem.columnWidth3, constraint: cell.constraintWidth3, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl4, text: reportEntry.column4, width: myItem.columnWidth4, constraint: cell.constraintWidth4, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl5, text: reportEntry.column5, width: myItem.columnWidth5, constraint: cell.constraintWidth5, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl6, text: reportEntry.column6, width: myItem.columnWidth6, constraint: cell.constraintWidth6, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl7, text: reportEntry.column7, width: myItem.columnWidth7, constraint: cell.constraintWidth7, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl8, text: reportEntry.column8, width: myItem.columnWidth8, constraint: cell.constraintWidth8, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl9, text: reportEntry.column9, width: myItem.columnWidth9, constraint: cell.constraintWidth9, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl10, text: reportEntry.column10, width: myItem.columnWidth10, constraint: cell.constraintWidth10, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl11, text: reportEntry.column11, width: myItem.columnWidth11, constraint: cell.constraintWidth11, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl12, text: reportEntry.column12, width: myItem.columnWidth12, constraint: cell.constraintWidth12, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl13, text: reportEntry.column13, width: myItem.columnWidth13, constraint: cell.constraintWidth13, drawLine: reportEntry.drawLine)
                        buildReportCell(label: cell.lbl14, text: reportEntry.column14, width: myItem.columnWidth14, constraint: cell.constraintWidth14, drawLine: reportEntry.drawLine)
                        
                        break
                    }
                }
                
                return cell
            
            case tblAlerts:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellAlert", for: indexPath) as! alertListItem
                
                cell.lblAlert.text = alertList[indexPath.row].displayText
                cell.lblName.text = alertList[indexPath.row].name
                
                return cell

            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblData1:
                for reportEntry in reportList.reports
                {
                    if reportEntry.reportName == btnReport.currentTitle!
                    {
                        switch reportEntry.reportName
                        {
                            case reportContractForMonth:  // Contract for month
                                let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
                                contractEditViewControl.communicationDelegate = self
                                
                                let tempObject = reportEntry.lines[indexPath.row].sourceObject as! project
                                contractEditViewControl.workingContract = tempObject
                                
                                self.present(contractEditViewControl, animated: true, completion: nil)
                                
                            case reportWagesForMonth:  // Wage per person for month
                                let rosterViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "monthlyRoster") as! monthlyRosterViewController
                                rosterViewControl.communicationDelegate = self
                                
                                let tempObject = reportEntry.lines[indexPath.row].sourceObject as! person
                                rosterViewControl.selectedPerson = tempObject
                                
                                rosterViewControl.month = btnDropdown.currentTitle!
                                rosterViewControl.year = btnYear.currentTitle!
                                self.present(rosterViewControl, animated: true, completion: nil)
                                
                            case reportContractForYear:
                                let _ = 1
                            
                            case reportContractDates:
                                let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
                                contractEditViewControl.communicationDelegate = self
                                
                                let tempObject = reportEntry.lines[indexPath.row].sourceObject as! project
                                contractEditViewControl.workingContract = tempObject
                                
                                self.present(contractEditViewControl, animated: true, completion: nil)
                            
                            default:
                                print("unknow entry myPickerDidFinish - selectedItem - \(reportEntry.reportName)")
                        }

                       
                        break
                    }
                }

            case tblAlerts:
                switch alertList[indexPath.row].source
                {
                    case "Project":
                        let workingProject = alertList[indexPath.row].sourceObject as! project
                        let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
                        contractEditViewControl.communicationDelegate = self
                        contractEditViewControl.workingContract = workingProject
                        self.present(contractEditViewControl, animated: true, completion: nil)
                    
                    case "Client":
                        let clientMaintenanceViewControl = clientsStoryboard.instantiateViewController(withIdentifier: "clientMaintenance") as! clientMaintenanceViewController
                        clientMaintenanceViewControl.communicationDelegate = self
                        clientMaintenanceViewControl.selectedClient = alertList[indexPath.row].sourceObject as! client
                        self.present(clientMaintenanceViewControl, animated: true, completion: nil)
                    
                    case "Shift":
                        let workingShift = alertList[indexPath.row].sourceObject as! shift
                        
                        if workingShift.type == eventShiftType
                        {
                            let workingProject = project(projectID: workingShift.projectID)
                            let eventsViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventPlanningForm") as! eventPlanningViewController
                            eventsViewControl.communicationDelegate = self
                            eventsViewControl.currentEvent = workingProject
                            self.present(eventsViewControl, animated: true, completion: nil)
                            
                        }
                        else
                        {
                            let rosterMaintenanceViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "rosterForm") as! shiftMaintenanceViewController
                            rosterMaintenanceViewControl.communicationDelegate = self
                            rosterMaintenanceViewControl.currentWeekEndingDate = workingShift.weekEndDate
                            self.present(rosterMaintenanceViewControl, animated: true, completion: nil)
                        }
                    
                    default:
                        let _ = 1
                }
            
            default:
                let _ = 1
        }
    }
    
    @IBAction func btnSettings(_ sender: UIBarButtonItem)
    {
        let userEditViewControl = self.storyboard?.instantiateViewController(withIdentifier: "settings") as! settingsViewController
        self.present(userEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnShare(_ sender: UIBarButtonItem)
    {
        for myItem in reportList.reports
        {
            if myItem.reportName == btnReport.currentTitle!
            {
                let activityViewController = myItem.activityController
                
                activityViewController.popoverPresentationController!.sourceView = self.view
                
                present(activityViewController, animated:true, completion:nil)
                break
            }
        }
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
    
    @IBAction func btnRoster(_ sender: UIButton)
    {
        let rosterMaintenanceViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "rosterForm") as! shiftMaintenanceViewController
        rosterMaintenanceViewControl.communicationDelegate = self
        self.present(rosterMaintenanceViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnEvents(_ sender: UIButton)
    {
        let eventsViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventPlanningForm") as! eventPlanningViewController
        eventsViewControl.communicationDelegate = self
        self.present(eventsViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnMonthlyRoster(_ sender: UIButton)
    {
        let rosterViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "monthlyRoster") as! monthlyRosterViewController
        rosterViewControl.communicationDelegate = self
        self.present(rosterViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnReport(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in reportList.reports
        {
            displayList.append(myItem.reportName)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "report"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnMaintainReports(_ sender: UIButton)
    {
    }
    
    @IBAction func btnDropdown(_ sender: UIButton)
    {
        switch currentReportID
        {
            case 0:
                displayList.removeAll()
                
                for myItem in monthList
                {
                    displayList.append(myItem)
                }
            
            case 1:
                displayList.removeAll()
                
                for myItem in monthList
                {
                    displayList.append(myItem)
                }
            
            case 2:
                displayList.removeAll()
                
                displayList.append("2017")
            
            case 3:
               // Do nothing
                break
                
            default:
                print("unknown entry btnDropdown - currentReportID - \(currentReportID)")
        }

        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "dropdown"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
        
    }
    
    @IBAction func btnYear(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("2017")
        displayList.append("2018")
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "year"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnSelect(_ sender: UIButton)
    {
        var source: String = ""
        var tempDate: Date = Date()
        
        if sender == btnSelect1
        {
            source = "btnSelect1"
            tempDate = reportDate1
        }
        else if sender == btnSelect2
        {
            source = "btnSelect2"
            tempDate = reportDate2
        }
        
        if btnReport.currentTitle! == reportContractDates
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
            pickerView.modalPresentationStyle = .popover
            //      pickerView.isModalInPopover = true
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = source
            pickerView.delegate = self
            pickerView.currentDate = tempDate
            
            pickerView.showTimes = false
            
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "dd MMM YY"
        
        switch source
        {
            case "btnSelect1":
                reportDate1 = selectedDate
                btnSelect1.setTitle(dateStringFormatter.string(from: selectedDate), for: .normal)
                runReport()
            
            case "btnSelect2":
                reportDate2 = selectedDate
                btnSelect2.setTitle(dateStringFormatter.string(from: selectedDate), for: .normal)
                runReport()
            
            default:
                print("myPickerDidFinish: selectedDate - got default \(source)")
        }
    }
    
    func refreshScreen()
    {
        navBarTitle.title = currentUser.currentTeam!.name
        
        let tempEvents = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true, type: eventProjectType)
        
        if tempEvents.projects.count == 0
        {
            btnEvents.isEnabled = false
        }
        else
        {
            btnEvents.isEnabled = true
        }
        
        buildAlerts()
        
        tblAlerts.reloadData()
        
        if reportList.reports.count > 0
        {
            myPickerDidFinish("report", selectedItem: currentReportID)
        }
    }
    
    func buildAlerts()
    {
        alertList.removeAll()
        
        // check for shifts with no person or rate
        
        for myItem in shifts(query: "shifts no person or rate", teamID: currentUser.currentTeam!.teamID).shifts
        {
            let contractEntry = project(projectID: myItem.projectID)
            
            let alertEntry = alertStruct(
                displayText: "Shift has no person or rate for \(myItem.workDateString) - \(myItem.startTimeString) - \(myItem.endTimeString)",
                name: contractEntry.projectName,
                source: "Shift",
                sourceObject: myItem
            )
            
            alertList.append(alertEntry)
        }
        
        // check for shifts with no person
        
        for myItem in shifts(query: "shifts no person", teamID: currentUser.currentTeam!.teamID).shifts
        {
            let contractEntry = project(projectID: myItem.projectID)
            
            let alertEntry = alertStruct(
                displayText: "Shift has no person for \(myItem.workDateString) - \(myItem.startTimeString) - \(myItem.endTimeString)",
                name: contractEntry.projectName,
                source: "Shift",
                sourceObject: myItem
            )
            
            alertList.append(alertEntry)
        }
        
        // check for shifts with no rate
        
        for myItem in shifts(query: "shifts no rate", teamID: currentUser.currentTeam!.teamID).shifts
        {
            let contractEntry = project(projectID: myItem.projectID)
            
            let alertEntry = alertStruct(
                displayText: "Shift has no rate for \(myItem.workDateString) - \(myItem.startTimeString) - \(myItem.endTimeString)",
                name: contractEntry.projectName,
                source: "Shift",
                sourceObject: myItem
            )
            
            alertList.append(alertEntry)
        }
        
        // check for clients with no projects
        
        for myItem in clients(query: "client no project", teamID: currentUser.currentTeam!.teamID).clients
        {
            let alertEntry = alertStruct(
                displayText: "Client has no Contracts",
                name: myItem.name,
                source: "Client",
                sourceObject: myItem
            )
            
            alertList.append(alertEntry)
        }

        // check for clients with no projects
        
        for myItem in clients(query: "client no rate", teamID: currentUser.currentTeam!.teamID).clients
        {
            let alertEntry = alertStruct(
                displayText: "Client has no Rates",
                name: myItem.name,
                source: "Client",
                sourceObject: myItem
            )
            
            alertList.append(alertEntry)
        }

        // check for projects with no type defined
        
        for myItem in projects(query: "project type", teamID: currentUser.currentTeam!.teamID).projects
        {
            var projectName: String = "No name supplied"
            
            if myItem.projectName != ""
            {
                projectName = myItem.projectName
            }
            
            let alertEntry = alertStruct(
                displayText: "Contract does not have a Type assigned",
                name: projectName,
                source: "Project",
                sourceObject: myItem
            )
            
            alertList.append(alertEntry)
        }

        // check for projects with no start or end date
        
        for myItem in projects(query: "project no start or end", teamID: currentUser.currentTeam!.teamID).projects
        {
            var projectName: String = "No name supplied"
            
            if myItem.projectName != ""
            {
                projectName = myItem.projectName
            }
            
            let alertEntry = alertStruct(
                displayText: "Contract does not have a start or end date",
                name: projectName,
                source: "Project",
                sourceObject: myItem
            )
            
            alertList.append(alertEntry)
        }

        // check for projects with no start date
        
        for myItem in projects(query: "project no start", teamID: currentUser.currentTeam!.teamID).projects
        {
            var projectName: String = "No name supplied"
            
            if myItem.projectName != ""
            {
                projectName = myItem.projectName
            }
            
            let alertEntry = alertStruct(
                displayText: "Contract does not have a start date",
                name: projectName,
                source: "Project",
                sourceObject: myItem
            )
            
            alertList.append(alertEntry)
        }

        // check for projects with no end date
        
        for myItem in projects(query: "project no end", teamID: currentUser.currentTeam!.teamID).projects
        {
            var projectName: String = "No name supplied"
            
            if myItem.projectName != ""
            {
                projectName = myItem.projectName
            }
            
            let alertEntry = alertStruct(
                displayText: "Contract does not have an end date",
                name: projectName,
                source: "Project",
                sourceObject: myItem
            )
            
            alertList.append(alertEntry)
        }
    }
    
    func buildReportList()
    {
        reportList.removeAll()
    
        buildReportLine(name: reportContractForMonth,
                        subject: reportContractForMonth,
                        text1: "Client", width1: 26.9,
                        text2: "Contract", width2: 24.7,
                        text3: "Hours", width3: 8.9,
                        text4: "Cost", width4: 11.2,
                        text5: "Income", width5: 11.2,
                        text6: "Profit", width6: 11.2,
                        text7: "GP%", width7: 5.6
                        )

        buildReportLine(name: reportWagesForMonth,
                        subject: reportWagesForMonth,
                        text1: "Name", width1: 26.9,
                        text2: "Hours", width2: 11.2,
                        text3: "Pay", width3: 13.4
                        )

        buildReportLine(name: reportContractForYear,
                        subject: reportContractForYear,
                        text1: "", width1: 18.0,
                        text2: "Jan", width2: 6.0,
                        text3: "Feb", width3: 6.0,
                        text4: "Mar", width4: 6.0,
                        text5: "Apr", width5: 6.0,
                        text6: "May", width6: 6.0,
                        text7: "Jun", width7: 6.0,
                        text8: "July", width8: 6.0,
                        text9: "Aug", width9: 6.0,
                        text10: "Sep", width10: 6.0,
                        text11: "Oct", width11: 6.0,
                        text12: "Nov", width12: 6.0,
                        text13: "Dec", width13: 6.0,
                        text14: "Total", width14: 6.0)
            
        buildReportLine(name: reportContractDates,
                        subject: reportContractDates,
                        text1: "Client", width1: 26.9,
                        text2: "Contract", width2: 24.7,
                        text3: "Hours", width3: 8.9,
                        text4: "Cost", width4: 11.2,
                        text5: "Income", width5: 11.2,
                        text6: "Profit", width6: 11.2,
                        text7: "GP%", width7: 8.9)
        
        myPickerDidFinish("report", selectedItem: currentReportID)
    }
    
    func buildReportLine(name: String, subject: String, text1: String = "", width1: CGFloat = 0, text2: String = "", width2: CGFloat = 0, text3: String = "", width3: CGFloat = 0, text4: String = "", width4: CGFloat = 0, text5: String = "", width5: CGFloat = 0, text6: String = "", width6: CGFloat = 0, text7: String = "", width7: CGFloat = 0, text8: String = "", width8: CGFloat = 0, text9: String = "", width9: CGFloat = 0, text10: String = "", width10: CGFloat = 0, text11: String = "", width11: CGFloat = 0, text12: String = "", width12: CGFloat = 0, text13: String = "", width13: CGFloat = 0, text14: String = "", width14: CGFloat = 0)
    {
        let newReport = report(name: name)
        newReport.displayWidth = tblData1.bounds.width
            
        newReport.subject = subject
        newReport.columnWidth1 = width1
        newReport.columnWidth2 = width2
        newReport.columnWidth3 = width3
        newReport.columnWidth4 = width4
        newReport.columnWidth5 = width5
        newReport.columnWidth6 = width6
        newReport.columnWidth7 = width7
        newReport.columnWidth8 = width8
        newReport.columnWidth9 = width9
        newReport.columnWidth10 = width10
        newReport.columnWidth11 = width11
        newReport.columnWidth12 = width12
        newReport.columnWidth13 = width13
        newReport.columnWidth14 = width14
        
        let newReportHeader = reportLine()
        newReportHeader.column1 = text1
        newReportHeader.column2 = text2
        newReportHeader.column3 = text3
        newReportHeader.column4 = text4
        newReportHeader.column5 = text5
        newReportHeader.column6 = text6
        newReportHeader.column7 = text7
        newReportHeader.column8 = text8
        newReportHeader.column9 = text9
        newReportHeader.column10 = text10
        newReportHeader.column11 = text11
        newReportHeader.column12 = text12
        newReportHeader.column13 = text13
        newReportHeader.column14 = text14
        
        newReport.header = newReportHeader
        
        reportList.append(newReport)
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        var workingItem: Int = 0
        if selectedItem < 0
        {
            workingItem = 0
        }
        else
        {
            workingItem = selectedItem
        }
        
        if source == "report"
        {
            btnReport.setTitle(reportList.reports[workingItem].reportName, for: .normal)
            
            switch workingItem
            {
                case 0:
                    lblDropdown.text = "Month"
                    lblYear.text = "Year"
                    if btnDropdown.currentTitle == "Select"
                    {
                        tblData1.isHidden = true
                    }
                    else
                    {
                       tblData1.isHidden = false
                    }
                    
                    lblDropdown.isHidden = false
                    btnDropdown.isHidden = false
                    btnSelect1.isHidden = true
                    btnSelect2.isHidden = true
                    lblYear.isHidden = false
                    btnYear.isHidden = false
                    
                    populateDropdowns()
                
                case 1:
                    lblDropdown.text = "Month"
                    lblYear.text = "Year"
                    if btnDropdown.currentTitle == "Select"
                    {
                        tblData1.isHidden = true
                    }
                    else
                    {
                        tblData1.isHidden = false
                    }
                    
                    lblDropdown.isHidden = false
                    btnDropdown.isHidden = false
                    btnSelect1.isHidden = true
                    btnSelect2.isHidden = true
                    lblYear.isHidden = false
                    btnYear.isHidden = false
                    
                    populateDropdowns()
                
                case 2:
                    lblDropdown.text = "Month"
                    lblYear.text = "Year"
                    if btnDropdown.currentTitle == "Select"
                    {
                        tblData1.isHidden = true
                    }
                    else
                    {
                        tblData1.isHidden = false
                    }
                    
                    lblDropdown.isHidden = true
                    btnDropdown.isHidden = true
                    btnSelect1.isHidden = true
                    btnSelect2.isHidden = true
                    lblYear.isHidden = false
                    btnYear.isHidden = false
                
                case 3:
                    lblDropdown.isHidden = false
                    lblDropdown.text = "Start Date"
                    lblYear.isHidden = false
                    lblYear.text = "End Date"
                    tblData1.isHidden = true
                    btnDropdown.isHidden = true
                    btnYear.isHidden = true
                    btnSelect1.isHidden = false
                    btnSelect2.isHidden = false
                
                default:
                    print("unknow entry myPickerDidFinish - selectedItem - \(selectedItem)")
            }
            
            currentReportID = workingItem
            
            writeDefaultInt("reportID", value: currentReportID)

        }
        else if source == "dropdown"
        {
            btnDropdown.setTitle(displayList[workingItem], for: .normal)
            
            writeDefaultString("reportMonth", value: displayList[workingItem])
        }
        else if source == "year"
        {
            btnYear.setTitle(displayList[workingItem], for: .normal)
            writeDefaultInt("reportYear", value: Int(displayList[workingItem])!)
        }
        else
        {
            print("unknown entry myPickerDidFinish - source - \(source)")
        }
        
        // see if we can run the report, and if so do it
        
        runReport()
    }
    
    func runReport()
    {
        for myItem in reportList.reports
        {
            if myItem.reportName == btnReport.currentTitle!
            {
                buildReport(myItem)
                break
            }
        }
    }
    
    func buildReportCell(label: UILabel, text: String, width: CGFloat, constraint: NSLayoutConstraint, drawLine: Bool)
    {
        if width == 0.0
        {
            label.isHidden = true
        }
        else
        {
            label.isHidden = false
            
            for mySubView in label.subviews
            {
                mySubView.removeFromSuperview()
            }
            
            if drawLine
            {
                label.text = ""
                
                let lineView = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(12), width: width, height: CGFloat(1)))
                lineView.backgroundColor = UIColor.black
                lineView.autoresizingMask = UIViewAutoresizing(rawValue: 0x3f)
                label.addSubview(lineView)
            }
            else
            {
                label.text = text
            }

        }
        constraint.constant = width
    }
    
    func resetWidth(constraint: NSLayoutConstraint)
    {
        constraint.constant = 0.0
    }
    
    func buildReport(_ reportEntry: report)
    {
        resetWidth(constraint: constraintWidth1)
        resetWidth(constraint: constraintWidth2)
        resetWidth(constraint: constraintWidth3)
        resetWidth(constraint: constraintWidth4)
        resetWidth(constraint: constraintWidth5)
        resetWidth(constraint: constraintWidth6)
        resetWidth(constraint: constraintWidth7)
        resetWidth(constraint: constraintWidth8)
        resetWidth(constraint: constraintWidth9)
        resetWidth(constraint: constraintWidth10)
        resetWidth(constraint: constraintWidth11)
        resetWidth(constraint: constraintWidth12)
        resetWidth(constraint: constraintWidth13)
        resetWidth(constraint: constraintWidth14)
        
        buildReportCell(label: lbl1, text: reportEntry.header.column1, width: CGFloat(reportEntry.columnWidth1), constraint: constraintWidth1, drawLine: false)
        buildReportCell(label: lbl2, text: reportEntry.header.column2, width: CGFloat(reportEntry.columnWidth2), constraint: constraintWidth2, drawLine: false)
        buildReportCell(label: lbl3, text: reportEntry.header.column3, width: CGFloat(reportEntry.columnWidth3), constraint: constraintWidth3, drawLine: false)
        buildReportCell(label: lbl4, text: reportEntry.header.column4, width: CGFloat(reportEntry.columnWidth4), constraint: constraintWidth4, drawLine: false)
        buildReportCell(label: lbl5, text: reportEntry.header.column5, width: CGFloat(reportEntry.columnWidth5), constraint: constraintWidth5, drawLine: false)
        buildReportCell(label: lbl6, text: reportEntry.header.column6, width: CGFloat(reportEntry.columnWidth6), constraint: constraintWidth6, drawLine: false)
        buildReportCell(label: lbl7, text: reportEntry.header.column7, width: CGFloat(reportEntry.columnWidth7), constraint: constraintWidth7, drawLine: false)
        buildReportCell(label: lbl8, text: reportEntry.header.column8, width: CGFloat(reportEntry.columnWidth8), constraint: constraintWidth8, drawLine: false)
        buildReportCell(label: lbl9, text: reportEntry.header.column9, width: CGFloat(reportEntry.columnWidth9), constraint: constraintWidth9, drawLine: false)
        buildReportCell(label: lbl10, text: reportEntry.header.column10, width: CGFloat(reportEntry.columnWidth10), constraint: constraintWidth10, drawLine: false)
        buildReportCell(label: lbl11, text: reportEntry.header.column11, width: CGFloat(reportEntry.columnWidth11), constraint: constraintWidth11, drawLine: false)
        buildReportCell(label: lbl12, text: reportEntry.header.column12, width: CGFloat(reportEntry.columnWidth12), constraint: constraintWidth12, drawLine: false)
        buildReportCell(label: lbl13, text: reportEntry.header.column13, width: CGFloat(reportEntry.columnWidth13), constraint: constraintWidth13, drawLine: false)
        buildReportCell(label: lbl14, text: reportEntry.header.column14, width: CGFloat(reportEntry.columnWidth14), constraint: constraintWidth14, drawLine: false)
    
        updateViewConstraints()
       
        reportEntry.removeAll()
        // Lets process through the report
        
        switch reportEntry.reportName
        {
            case reportContractForMonth:  // Contract for month
                if btnDropdown.currentTitle! != "Select"
                {
                    contractList = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true)
                    
                    contractList.loadFinancials(month: btnDropdown.currentTitle!, year: btnYear.currentTitle!)
                    
                    var lastClientID: Int = -1
                    
                    for myItem in contractList.projects
                    {
                        let profit = myItem.financials[0].income - myItem.financials[0].expense
                        
                        let gp = (profit/myItem.financials[0].income)  * 100
                        
                        if myItem.financials[0].income != 0 || myItem.financials[0].expense != 0
                        {
                            let newReportLine = reportLine()
                            
                            var clientName: String = ""
                            if myItem.clientID != lastClientID
                            {
                                let tempClient = client(clientID: myItem.clientID)
                                clientName = tempClient.name
                                lastClientID = myItem.clientID
                            }
                            
                            newReportLine.column1 = clientName
                            newReportLine.column2 = myItem.projectName
                            newReportLine.column3 = myItem.financials[0].hours.formatHours
                            newReportLine.column4 = myItem.financials[0].expense.formatCurrency
                            newReportLine.column5 = myItem.financials[0].income.formatCurrency
                            newReportLine.column6 = profit.formatCurrency
                            newReportLine.column7 = gp.formatPercent
                            newReportLine.sourceObject = myItem
                            
                            reportEntry.append(newReportLine)
                        }
                    }
                }

            case reportWagesForMonth:  // Wage per person for month
                if btnDropdown.currentTitle! != "Select"
                {
                    for myItem in people(teamID: currentUser.currentTeam!.teamID).people
                    {
                        let monthReport = myItem.getFinancials(month: btnDropdown.currentTitle!, year: btnYear.currentTitle!)
                        
                        if monthReport.hours != 0
                        {
                            let newReportLine = reportLine()
                            
                            newReportLine.column1 = myItem.name
                            newReportLine.column2 = monthReport.hours.formatHours
                            newReportLine.column3 = monthReport.wage.formatCurrency

                            newReportLine.sourceObject = myItem
                            
                            reportEntry.append(newReportLine)
                        }
                    }
                }
            
            case reportContractForYear:
                reportEntry.landscape()
                
                var janTotalAmount: Double = 0.0
                var febTotalAmount: Double = 0.0
                var marTotalAmount: Double = 0.0
                var aprTotalAmount: Double = 0.0
                var mayTotalAmount: Double = 0.0
                var junTotalAmount: Double = 0.0
                var julTotalAmount: Double = 0.0
                var augTotalAmount: Double = 0.0
                var sepTotalAmount: Double = 0.0
                var octTotalAmount: Double = 0.0
                var novTotalAmount: Double = 0.0
                var decTotalAmount: Double = 0.0
                
                for myClient in clients(teamID: currentUser.currentTeam!.teamID).clients
                {
                    var janClientAmount: Double = 0.0
                    var febClientAmount: Double = 0.0
                    var marClientAmount: Double = 0.0
                    var aprClientAmount: Double = 0.0
                    var mayClientAmount: Double = 0.0
                    var junClientAmount: Double = 0.0
                    var julClientAmount: Double = 0.0
                    var augClientAmount: Double = 0.0
                    var sepClientAmount: Double = 0.0
                    var octClientAmount: Double = 0.0
                    var novClientAmount: Double = 0.0
                    var decClientAmount: Double = 0.0
                    
                    for myProject in myClient.projectList
                    {
                        myProject.loadFinancials(month: "January", year: btnYear.currentTitle!)
                        let janAmount = myProject.financials[0].income - myProject.financials[0].expense

                        myProject.loadFinancials(month: "February", year: btnYear.currentTitle!)
                        let febAmount = myProject.financials[0].income - myProject.financials[0].expense

                        myProject.loadFinancials(month: "March", year: btnYear.currentTitle!)
                        let marAmount = myProject.financials[0].income - myProject.financials[0].expense

                        myProject.loadFinancials(month: "April", year: btnYear.currentTitle!)
                        let aprAmount = myProject.financials[0].income - myProject.financials[0].expense

                        myProject.loadFinancials(month: "May", year: btnYear.currentTitle!)
                        let mayAmount = myProject.financials[0].income - myProject.financials[0].expense

                        myProject.loadFinancials(month: "June", year: btnYear.currentTitle!)
                        let junAmount = myProject.financials[0].income - myProject.financials[0].expense

                        myProject.loadFinancials(month: "July", year: btnYear.currentTitle!)
                        let julAmount = myProject.financials[0].income - myProject.financials[0].expense

                        myProject.loadFinancials(month: "August", year: btnYear.currentTitle!)
                        let augAmount = myProject.financials[0].income - myProject.financials[0].expense

                        myProject.loadFinancials(month: "September", year: btnYear.currentTitle!)
                        let sepAmount = myProject.financials[0].income - myProject.financials[0].expense

                        myProject.loadFinancials(month: "October", year: btnYear.currentTitle!)
                        let octAmount = myProject.financials[0].income - myProject.financials[0].expense
                        
                        myProject.loadFinancials(month: "November", year: btnYear.currentTitle!)
                        let novAmount = myProject.financials[0].income - myProject.financials[0].expense
                        
                        myProject.loadFinancials(month: "December", year: btnYear.currentTitle!)
                        let decAmount = myProject.financials[0].income - myProject.financials[0].expense
                        
                        let newReportLine = reportLine()
                        
                        let totAmount = janAmount + febAmount + marAmount + aprAmount + mayAmount + junAmount + julAmount + augAmount + sepAmount + octAmount + novAmount + decAmount

                        newReportLine.column1 = myProject.projectName
                        
                        if janAmount != 0.0
                        {
                            newReportLine.column2 = janAmount.formatIntString
                        }
                        
                        if febAmount != 0.0
                        {
                            newReportLine.column3 = febAmount.formatIntString
                        }
                        
                        if marAmount != 0.0
                        {
                            newReportLine.column4 = marAmount.formatIntString
                        }
                        
                        if aprAmount != 0.0
                        {
                            newReportLine.column5 = aprAmount.formatIntString
                        }
                        
                        if mayAmount != 0.0
                        {
                            newReportLine.column6 = mayAmount.formatIntString
                        }
                        
                        if junAmount != 0.0
                        {
                            newReportLine.column7 = junAmount.formatIntString
                        }
                        
                        if julAmount != 0.0
                        {
                            newReportLine.column8 = julAmount.formatIntString
                        }
                        
                        if augAmount != 0.0
                        {
                            newReportLine.column9 = augAmount.formatIntString
                        }
                        
                        if sepAmount != 0.0
                        {
                            newReportLine.column10 = sepAmount.formatIntString
                        }
                        
                        if octAmount != 0.0
                        {
                            newReportLine.column11 = octAmount.formatIntString
                        }
                        
                        if novAmount != 0.0
                        {
                            newReportLine.column12 = novAmount.formatIntString
                        }
                        
                        if decAmount != 0.0
                        {
                            newReportLine.column13 = decAmount.formatIntString
                        }
                        
                        if totAmount != 0.0
                        {
                            newReportLine.column14 = totAmount.formatIntString
                        }
                        
                        newReportLine.sourceObject = myProject

                        reportEntry.append(newReportLine)
                        
                        janClientAmount += janAmount
                        febClientAmount += febAmount
                        marClientAmount += marAmount
                        aprClientAmount += aprAmount
                        mayClientAmount += mayAmount
                        junClientAmount += junAmount
                        julClientAmount += julAmount
                        augClientAmount += augAmount
                        sepClientAmount += sepAmount
                        octClientAmount += octAmount
                        novClientAmount += novAmount
                        decClientAmount += decAmount
                        
                        janTotalAmount += janAmount
                        febTotalAmount += febAmount
                        marTotalAmount += marAmount
                        aprTotalAmount += aprAmount
                        mayTotalAmount += mayAmount
                        junTotalAmount += junAmount
                        julTotalAmount += julAmount
                        augTotalAmount += augAmount
                        sepTotalAmount += sepAmount
                        octTotalAmount += octAmount
                        novTotalAmount += novAmount
                        decTotalAmount += decAmount
                    }
                    
                    let drawLine = reportLine()
                    drawLine.drawLine = true
                    reportEntry.append(drawLine)
                    
                    let newReportLine = reportLine()
                    
                    let totClientAmount = janClientAmount + febClientAmount + marClientAmount + aprClientAmount + mayClientAmount + junClientAmount + julClientAmount + augClientAmount + sepClientAmount + octClientAmount + novClientAmount + decClientAmount
                    
                    newReportLine.column1 = myClient.name
                    
                    if janClientAmount != 0.0
                    {
                        newReportLine.column2 = janClientAmount.formatIntString
                    }
                    
                    if febClientAmount != 0.0
                    {
                        newReportLine.column3 = febClientAmount.formatIntString
                    }
                    
                    if marClientAmount != 0.0
                    {
                        newReportLine.column4 = marClientAmount.formatIntString
                    }
                    
                    if aprClientAmount != 0.0
                    {
                        newReportLine.column5 = aprClientAmount.formatIntString
                    }
                    
                    if mayClientAmount != 0.0
                    {
                        newReportLine.column6 = mayClientAmount.formatIntString
                    }
                    
                    if junClientAmount != 0.0
                    {
                        newReportLine.column7 = junClientAmount.formatIntString
                    }
                    
                    if julClientAmount != 0.0
                    {
                        newReportLine.column8 = julClientAmount.formatIntString
                    }
                    
                    if augClientAmount != 0.0
                    {
                        newReportLine.column9 = augClientAmount.formatIntString
                    }
                    
                    if sepClientAmount != 0.0
                    {
                        newReportLine.column10 = sepClientAmount.formatIntString
                    }
                    
                    if octClientAmount != 0.0
                    {
                        newReportLine.column11 = octClientAmount.formatIntString
                    }
                    
                    if novClientAmount != 0.0
                    {
                        newReportLine.column12 = novClientAmount.formatIntString
                    }
                    
                    if decClientAmount != 0.0
                    {
                        newReportLine.column13 = decClientAmount.formatIntString
                    }
                    
                    if totClientAmount != 0.0
                    {
                        newReportLine.column14 = totClientAmount.formatIntString
                    }
                    
                    newReportLine.sourceObject = myClient
                    
                    reportEntry.append(newReportLine)

                    let drawLine2 = reportLine()
                    drawLine2.drawLine = true
                    reportEntry.append(drawLine2)
                }
                
                let newReportLine = reportLine()
                
                let totTotalAmount = janTotalAmount + febTotalAmount + marTotalAmount + aprTotalAmount + mayTotalAmount + junTotalAmount + julTotalAmount + augTotalAmount + sepTotalAmount + octTotalAmount + novTotalAmount + decTotalAmount
                
                newReportLine.column1 = "Total"
                
                if janTotalAmount != 0.0
                {
                    newReportLine.column2 = janTotalAmount.formatIntString
                }
                
                if febTotalAmount != 0.0
                {
                    newReportLine.column3 = febTotalAmount.formatIntString
                }
                
                if marTotalAmount != 0.0
                {
                    newReportLine.column4 = marTotalAmount.formatIntString
                }
                
                if aprTotalAmount != 0.0
                {
                    newReportLine.column5 = aprTotalAmount.formatIntString
                }
                
                if mayTotalAmount != 0.0
                {
                    newReportLine.column6 = mayTotalAmount.formatIntString
                }
                
                if junTotalAmount != 0.0
                {
                    newReportLine.column7 = junTotalAmount.formatIntString
                }
                
                if julTotalAmount != 0.0
                {
                    newReportLine.column8 = julTotalAmount.formatIntString
                }
                
                if augTotalAmount != 0.0
                {
                    newReportLine.column9 = augTotalAmount.formatIntString
                }
                
                if sepTotalAmount != 0.0
                {
                    newReportLine.column10 = sepTotalAmount.formatIntString
                }
                
                if octTotalAmount != 0.0
                {
                    newReportLine.column11 = octTotalAmount.formatIntString
                }
                
                if novTotalAmount != 0.0
                {
                    newReportLine.column12 = novTotalAmount.formatIntString
                }
                
                if decTotalAmount != 0.0
                {
                    newReportLine.column13 = decTotalAmount.formatIntString
                }
                
                if totTotalAmount != 0.0
                {
                    newReportLine.column14 = totTotalAmount.formatIntString
                }
                
                reportEntry.append(newReportLine)

        case reportContractDates:
            if btnSelect1.currentTitle! != "Select" && btnSelect2.currentTitle! != "Select"
            {
                reportEntry.subject = "Contracts between \(btnSelect1.currentTitle!) - \(btnSelect2.currentTitle!)"
                contractList = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true)
                
                contractList.loadFinancials(startDate: reportDate1, endDate: reportDate2)
                
                var lastClientID: Int = -1
                
                for myItem in contractList.projects
                {
                    let profit = myItem.financials[0].income - myItem.financials[0].expense
                    
                    let gp = (profit/myItem.financials[0].income)  * 100
                    
                    if myItem.financials[0].income != 0 || myItem.financials[0].expense != 0
                    {
                        let newReportLine = reportLine()
                        
                        var clientName: String = ""
                        if myItem.clientID != lastClientID
                        {
                            let tempClient = client(clientID: myItem.clientID)
                            clientName = tempClient.name
                            lastClientID = myItem.clientID
                        }
                        
                        newReportLine.column1 = clientName
                        newReportLine.column2 = myItem.projectName
                        newReportLine.column3 = myItem.financials[0].hours.formatHours
                        newReportLine.column4 = myItem.financials[0].expense.formatCurrency
                        newReportLine.column5 = myItem.financials[0].income.formatCurrency
                        newReportLine.column6 = profit.formatCurrency
                        newReportLine.column7 = gp.formatPercent
                        newReportLine.sourceObject = myItem
                        
                        reportEntry.append(newReportLine)
                    }
                }
            //    tblData1.reloadData()
            }

            default:
                print("unknow entry myPickerDidFinish - selectedItem - \(reportEntry.reportName)")
        }

        tblData1.isHidden = false
        tblData1.reloadData()
    }
    
    func populateDropdowns()
    {
        switch currentReportID
        {
            case 0, 1:
                lblDropdown.text = "Month:"
                if readDefaultInt("reportID") >= 0
                {
                    currentReportID = readDefaultInt("reportID")
                }
                
                if readDefaultString("reportMonth") != ""
                {
                    btnDropdown.setTitle(readDefaultString("reportMonth"), for: .normal)
                }
                else
                {
                    btnDropdown.setTitle("Select", for: .normal)
                }

                if readDefaultInt("reportYear") >= 0
                {
                    let tempInt = readDefaultInt("reportYear")
                    btnYear.setTitle("\(tempInt)", for: .normal)
                }
                else
                {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY"
                    btnYear.setTitle(dateFormatter.string(from: Date()), for: .normal)
                }
            
            case 2:
                if readDefaultInt("reportYear") >= 0
                {
                    let tempInt = readDefaultInt("reportYear")
                    btnYear.setTitle("\(tempInt)", for: .normal)
                }
                else
                {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY"
                    btnYear.setTitle(dateFormatter.string(from: Date()), for: .normal)
                }
            

            default:
                print("populateDropdowns got default : \(currentReportID)")
        }
    }
    
    func populateMonthList()
    {
        monthList.removeAll()
        
        for myItem in currentUser.currentTeam!.reportingMonths
        {
            monthList.append(myItem)
        }
        
        if readDefaultString("reportMonth") != ""
        {
            DispatchQueue.main.async
            {
                self.btnDropdown.setTitle(readDefaultString("reportMonth"), for: .normal)
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                self.btnDropdown.setTitle("Select", for: .normal)
            }
        }
    }
}

class contractsListItem: UITableViewCell
{
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    @IBOutlet weak var lbl6: UILabel!
    @IBOutlet weak var lbl7: UILabel!
    @IBOutlet weak var lbl8: UILabel!
    @IBOutlet weak var lbl9: UILabel!
    @IBOutlet weak var lbl10: UILabel!
    @IBOutlet weak var lbl11: UILabel!
    @IBOutlet weak var lbl12: UILabel!
    @IBOutlet weak var lbl13: UILabel!
    @IBOutlet weak var lbl14: UILabel!
    @IBOutlet weak var constraintWidth1: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth2: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth3: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth4: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth5: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth6: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth7: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth8: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth9: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth10: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth11: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth12: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth13: NSLayoutConstraint!
    @IBOutlet weak var constraintWidth14: NSLayoutConstraint!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class alertListItem: UITableViewCell
{
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}
