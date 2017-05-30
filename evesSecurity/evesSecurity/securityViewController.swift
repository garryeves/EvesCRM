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

struct reportListStruct
{
    var reportName: String
    var reportID: Int
}

class securityViewController: UIViewController, myCommunicationDelegate, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var btnPeople: UIButton!
    @IBOutlet weak var btnClients: UIButton!
    @IBOutlet weak var tblData1: UITableView!
    @IBOutlet weak var btnRoster: UIButton!
    @IBOutlet weak var btnEvents: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var tblAlerts: UITableView!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var btnMaintainReports: UIButton!
    @IBOutlet weak var lblDropdown: UILabel!
    @IBOutlet weak var btnDropdown: UIButton!
    
    fileprivate var contractList: projects!
    fileprivate var alertList: [alertStruct] = Array()
    
    fileprivate var reportList: [reportListStruct] = Array()
    fileprivate var displayList: [String] = Array()
    fileprivate var monthList: [String] = Array()
    
    fileprivate var lastClientID: Int = 0
    fileprivate var currentReportID: Int = 0
    fileprivate var workingYear: String = ""
    
    var communicationDelegate: myCommunicationDelegate?
    
    override func viewDidLoad()
    {
        btnSettings.setTitle(NSString(string: "\u{2699}") as String, for: UIControlState())
        
        btnPeople.setTitle("Maintain People", for: .normal)

        if readDefaultInt("reportID") >= 0
        {
            currentReportID = readDefaultInt("reportID")
        }

        lblDropdown.isHidden = true
        btnDropdown.isHidden = true
        tblData1.isHidden = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        workingYear = dateFormatter.string(from: Date())
        
        refreshScreen()
        
        DispatchQueue.global().async
        {
            self.populateMonthList()
        }
        
        btnMaintainReports.isHidden = true
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
                switch currentReportID
                {
                    case 0:
                        if contractList == nil
                        {
                            return 0
                        }
                        else
                        {
                            lastClientID = 0
                            return contractList.projects.count
                        }
                    case 1:
                        return 0
                
                    case 2:
                        return 0
                    
                    case 3:
                        return 0
                    
                    default:
                        print("unknow entry numberOfRowsInSection - currentReportID - \(currentReportID)")
                        return 0
                }
            
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
                let cell = buildRowForReport(tableView, indexPath: indexPath)
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
                let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
                contractEditViewControl.communicationDelegate = self
                contractEditViewControl.workingContract = contractList.projects[indexPath.row]
                self.present(contractEditViewControl, animated: true, completion: nil)
            
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
    func buildRowForReport(_ tableView: UITableView, indexPath: IndexPath) -> contractsListItem
    {
        switch currentReportID
        {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellData1", for: indexPath) as! contractsListItem
                
                if contractList.projects[indexPath.row].clientID != lastClientID
                {
                    let tempClient = client(clientID: contractList.projects[indexPath.row].clientID)
                    cell.lbl1.text = tempClient.name
                    lastClientID = contractList.projects[indexPath.row].clientID
                }
                else
                {
                    cell.lbl1.text = ""
                }
                
                cell.lbl2.text = contractList.projects[indexPath.row].projectName
                cell.lbl3.text = "\(contractList.projects[indexPath.row].financials[0].expense)"
                cell.lbl4.text = "\(contractList.projects[indexPath.row].financials[0].hours)"
                cell.lbl5.text = "\(contractList.projects[indexPath.row].financials[0].income)"
                
                let profit = contractList.projects[indexPath.row].financials[0].income - contractList.projects[indexPath.row].financials[0].expense
                
                let gp = (profit/contractList.projects[indexPath.row].financials[0].income)  * 100
                
                cell.lbl6.text = "\(profit)"
                cell.lbl7.text = "\(gp)"
                
                
                
                return cell
            
            case 1:
                return contractsListItem()
                
            case 2:
                return contractsListItem()
                
            case 3:
                return contractsListItem()
                
            default:
                print("unknow entry buildRowForReport - currentReportID - \(currentReportID)")
                return contractsListItem()
        }
    }
    
    @IBAction func btnSettings(_ sender: UIButton)
    {
        let userEditViewControl = self.storyboard?.instantiateViewController(withIdentifier: "settings") as! settingsViewController
        self.present(userEditViewControl, animated: true, completion: nil)
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
    
    @IBAction func btnReport(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in reportList
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
    
    func refreshScreen()
    {
        lblHeader.text = currentUser.currentTeam!.name
        
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
        
        buildReportList()
        
        myPickerDidFinish("report", selectedItem: currentReportID)
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
        
        let report1 = reportListStruct(reportName: "Contract for Month", reportID: 0)
        reportList.append(report1)
        let report2 = reportListStruct(reportName: "Wages for Month", reportID: 0)
        reportList.append(report2)
        let report3 = reportListStruct(reportName: "Contract for Year", reportID: 0)
        reportList.append(report3)
        let report4 = reportListStruct(reportName: "Annual Report", reportID: 0)
        reportList.append(report4)
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
            btnReport.setTitle(reportList[workingItem].reportName, for: .normal)
            
            switch workingItem
            {
                case 0:
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
                    btnDropdown.setTitle("Select", for: .normal)
                    lblDropdown.text = "Month:"
                
                case 1:
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
                    btnDropdown.setTitle("Select", for: .normal)
                    lblDropdown.text = "Month:"
                
                case 2:
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
                    btnDropdown.setTitle("Select", for: .normal)
                    lblDropdown.text = "Year:"
                
                case 3:
                    tblData1.isHidden = true
                    lblDropdown.isHidden = true
                    btnDropdown.isHidden = true
                
                default:
                    print("unknow entry myPickerDidFinish - selectedItem - \(selectedItem)")
            }
            
            currentReportID = workingItem
            
            writeDefaultInt("reportID", value: currentReportID)

        }
        else if source == "dropdown"
        {
            btnDropdown.setTitle(displayList[workingItem], for: .normal)
        }
        else
        {
            print("unknown entry myPickerDidFinish - source - \(source)")
        }

        // see if we can run the report, and if so do it
        
        switch currentReportID
        {
            case 0:
                if btnDropdown.currentTitle != "Select"
                {
                    contractList = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true)

                    contractList.loadFinancials(month: btnDropdown.currentTitle!, year: workingYear)

                    tblData1.isHidden = false
                    tblData1.reloadData()
                }
                else
                {
                    tblData1.isHidden = true
                }
            
            case 1:
                tblData1.isHidden = false
                tblData1.reloadData()
            
            case 2:
            
                tblData1.isHidden = false
                tblData1.reloadData()
            
            case 3:
                
                tblData1.isHidden = false
                tblData1.reloadData()
                
            default:
                print("unknow entry myPickerDidFinish - selectedItem - \(selectedItem)")
        }
    }
    
    func populateMonthList()
    {
        monthList.removeAll()
        
        for myItem in currentUser.currentTeam!.reportingMonths
        {
            monthList.append(myItem)
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
