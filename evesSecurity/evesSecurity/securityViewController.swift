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

struct displayStruct
{
    var line1: String
    var line2: String
    var line3: String
    var line4: String
    var line5: String
    var line6: String
    var line7: String
    var sourceObject: Any
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
    @IBOutlet weak var btnMonthlyRoster: UIButton!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var btnYear: UIButton!
    
    fileprivate var contractList: projects!
    fileprivate var alertList: [alertStruct] = Array()
    
    fileprivate var reportList: [reportListStruct] = Array()
    fileprivate var displayList: [String] = Array()
    fileprivate var monthList: [String] = Array()
    
    fileprivate var currentReportID: Int = 0
    fileprivate var displayArray: [displayStruct] = Array()
    fileprivate var reportString: String = ""
    
    fileprivate var paperSize = CGRect(x:0.0, y:0.0, width:595.276, height:841.89)

    
    var communicationDelegate: myCommunicationDelegate?
    
    override func viewDidLoad()
    {
 //       btnSettings.setTitle(NSString(string: "\u{2699}") as String, for: UIControlState())
        
        btnSettings.title = NSString(string: "\u{2699}") as String
        
        btnPeople.setTitle("Maintain People", for: .normal)

        if readDefaultInt("reportID") >= 0
        {
            currentReportID = readDefaultInt("reportID")
        }

        if readDefaultInt("reportMonth") >= 0
        {
            let tempInt = readDefaultInt("reportMonth")
            let tempString = "\(tempInt)"
            btnDropdown.setTitle(tempString, for: .normal)
        }
        else
        {
            btnDropdown.setTitle("Select", for: .normal)
        }
        
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
//                pdfData = NSMutableData()
//                //UIGraphicsBeginPDFContextToData(pdfData, paperSize, nil)
//                UIGraphicsBeginPDFPageWithInfo(paperSize, nil)
                
                
                reportString = ""
                
                switch currentReportID
                {
                    case 0, 1:
                        return displayArray.count
                        
//                    case 1:
//                        return displayArray.count
                
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
                switch currentReportID
                {
                    case 0:
                        let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
                        contractEditViewControl.communicationDelegate = self
                        contractEditViewControl.workingContract = contractList.projects[indexPath.row]
                        self.present(contractEditViewControl, animated: true, completion: nil)
                    
                    default:
                        let rosterViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "monthlyRoster") as! monthlyRosterViewController
                        rosterViewControl.communicationDelegate = self
                        
                        let tempPerson = displayArray[indexPath.row].sourceObject as! person
                        rosterViewControl.selectedPerson = tempPerson
                        
                        rosterViewControl.month = btnDropdown.currentTitle!
                        rosterViewControl.year = btnYear.currentTitle!
                        self.present(rosterViewControl, animated: true, completion: nil)
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
    
    func buildRowForReport(_ tableView: UITableView, indexPath: IndexPath) -> contractsListItem
    {
        switch currentReportID
        {
            case 0, 1:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellData1", for: indexPath) as! contractsListItem
                
                cell.lbl1.text = displayArray[indexPath.row].line1
                cell.lbl2.text = displayArray[indexPath.row].line2
                cell.lbl3.text = displayArray[indexPath.row].line3
                cell.lbl4.text = displayArray[indexPath.row].line4
                cell.lbl5.text = displayArray[indexPath.row].line5
                cell.lbl6.text = displayArray[indexPath.row].line6
                cell.lbl7.text = displayArray[indexPath.row].line7
                
                return cell

            case 2:
                return contractsListItem()
                
            case 3:
                return contractsListItem()
                
            default:
                print("unknow entry buildRowForReport - currentReportID - \(currentReportID)")
                return contractsListItem()
        }
    }
    
    @IBAction func btnSettings(_ sender: UIBarButtonItem)
    {
        let userEditViewControl = self.storyboard?.instantiateViewController(withIdentifier: "settings") as! settingsViewController
        self.present(userEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnShare(_ sender: UIBarButtonItem)
    {
        var leftSide: Int = 0
        var topSide: Int = 0
        let height: Int = 30
        var subject: String = "'"
        
        let pdfData: NSMutableData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        UIGraphicsBeginPDFPageWithInfo(paperSize, nil)
        
        switch currentReportID
        {
            case 0:  // Contract for month
                subject = "Contracts for the month of \(btnDropdown.currentTitle!)"
                
                let column1Width = 100
                let column2Width = 150
                let column3Width = 50
                let column4Width = 50
                let column5Width = 50
                let column6Width = 50
                let column7Width = 50
                
                report0Header(column1Width: column1Width, column2Width: column2Width, column3Width: column3Width, column4Width: column4Width, column5Width: column5Width, column6Width: column6Width, column7Width: column7Width)

                for myItem in displayArray
                {
                    topSide += 5 + height

                    if CGFloat(topSide) >= paperSize.height
                    {
                        UIGraphicsBeginPDFPageWithInfo(paperSize, nil)
                        report0Header(column1Width: column1Width, column2Width: column2Width, column3Width: column3Width, column4Width: column4Width, column5Width: column5Width, column6Width: column6Width, column7Width: column7Width)
                        topSide = 5 + height
                    }
                    
                    leftSide = 0
                    
                    writePDFEntry(title: myItem.line1, x: leftSide, y: topSide, width: column1Width, height: height)
                    leftSide += 5 + column1Width
                    
                    writePDFEntry(title: myItem.line2, x: leftSide, y: topSide, width: column2Width, height: height)
                    leftSide += 5 + column2Width
                    
                    writePDFEntry(title: myItem.line3, x: leftSide, y: topSide, width: column3Width, height: height)
                    leftSide += 5 + column3Width
                    
                    writePDFEntry(title: myItem.line4, x: leftSide, y: topSide, width: column4Width, height: height)
                    leftSide += 5 + column4Width
                    
                    writePDFEntry(title: myItem.line5, x: leftSide, y: topSide, width: column5Width, height: height)
                    leftSide += 5 + column5Width
                    
                    writePDFEntry(title: myItem.line6, x: leftSide, y: topSide, width: column6Width, height: height)
                    leftSide += 5 + column6Width
                    
                    writePDFEntry(title: myItem.line7, x: leftSide, y: topSide, width: column7Width, height: height)
                }
            
            case 1:  // Wage per person for month
                subject = "Wages for the month of \(btnDropdown.currentTitle!)"
                
                let column1Width = 150
                let column2Width = 50
                let column3Width = 50
                
                report1Header(column1Width: column1Width, column2Width: 50, column3Width: 50)
                
                for myItem in displayArray
                {
                    topSide += 5 + height
                    if CGFloat(topSide) >= paperSize.height
                    {
                        UIGraphicsBeginPDFPageWithInfo(paperSize, nil)
                        report1Header(column1Width: column1Width, column2Width: 50, column3Width: 50)
                        topSide = 5 + height
                    }

                    leftSide = 0
                    
                    writePDFEntry(title: myItem.line2, x: leftSide, y: topSide, width: column1Width, height: height)
                    leftSide += 5 + column1Width
                    
                    writePDFEntry(title: myItem.line3, x: leftSide, y: topSide, width: column2Width, height: height)
                    leftSide += 5 + column2Width
                    
                    writePDFEntry(title: myItem.line4, x: leftSide, y: topSide, width: column3Width, height: height)
            }
                
            default:
                print("btnShare hit default - \(currentReportID)")
        }
        
        UIGraphicsEndPDFContext()
        
        let activityViewController: UIActivityViewController = createActivityController(pdfData, subject: subject)
        
        activityViewController.popoverPresentationController!.sourceView = self.view
        
        present(activityViewController, animated:true, completion:nil)
    }
    
    func report0Header(column1Width: Int, column2Width: Int, column3Width: Int, column4Width: Int, column5Width: Int, column6Width: Int, column7Width: Int)
    {
        var leftSide: Int = 0
        let height: Int = 30
        
        writePDFHeaderEntry(title: "Client", x: leftSide, y: 0, width: column1Width, height: height)
        leftSide += 5 + column1Width

        writePDFHeaderEntry(title: "Contract", x: leftSide, y: 0, width: column2Width, height: height)
        leftSide += 5 + column2Width

        writePDFHeaderEntry(title: "Cost", x: leftSide, y: 0, width: column3Width, height: height)
        leftSide += 5 + column3Width

        writePDFHeaderEntry(title: "Hours", x: leftSide, y: 0, width: column4Width, height: height)
        leftSide += 5 + column4Width

        writePDFHeaderEntry(title: "Income", x: leftSide, y: 0, width: column5Width, height: height)
        leftSide += 5 + column5Width

        writePDFHeaderEntry(title: "Profit", x: leftSide, y: 0, width: column6Width, height: height)
        leftSide += 5 + column6Width

        writePDFHeaderEntry(title: "GP%", x: leftSide, y: 0, width: column7Width, height: height)
    }
    
    func report1Header(column1Width: Int, column2Width: Int, column3Width: Int)
    {
        var leftSide: Int = 0
        let height: Int = 30
        
        writePDFHeaderEntry(title: "Name", x: leftSide, y: 0, width: column1Width, height: height)
        leftSide += 5 + column1Width
        
        writePDFHeaderEntry(title: "Hours", x: leftSide, y: 0, width: column2Width, height: height)
        leftSide += 5 + column2Width
        
        writePDFHeaderEntry(title: "Pay", x: leftSide, y: 0, width: column3Width, height: height)
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
                    lblYear.isHidden = false
                    btnYear.isHidden = false
                    
                    populateDropdowns()
                
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
                    lblYear.isHidden = false
                    btnYear.isHidden = false
                    
                    populateDropdowns()
                
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
                    lblYear.isHidden = false
                    btnYear.isHidden = false
                    btnDropdown.setTitle("Select", for: .normal)
                    lblDropdown.text = "Year:"
                
                case 3:
                    tblData1.isHidden = true
                    lblDropdown.isHidden = true
                    btnDropdown.isHidden = true
                    lblYear.isHidden = true
                    btnYear.isHidden = true
                
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
            writeDefaultString("reportYear", value: displayList[workingItem])
        }
        else
        {
            print("unknown entry myPickerDidFinish - source - \(source)")
        }

        lbl1.isHidden = true
        lbl2.isHidden = true
        lbl3.isHidden = true
        lbl4.isHidden = true
        lbl5.isHidden = true
        lbl6.isHidden = true
        lbl7.isHidden = true
        
        // see if we can run the report, and if so do it
        
        switch currentReportID
        {
            case 0:  // Contract for month
                if btnDropdown.currentTitle != "Select"
                {
                    contractList = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true)

                    contractList.loadFinancials(month: btnDropdown.currentTitle!, year: btnYear.currentTitle!)

                    displayArray.removeAll()
                    
                    var lastClientID: Int = 0
                    
                    for myItem in contractList.projects
                    {
                        var clientName: String = ""
                        if myItem.clientID != lastClientID
                        {
                            let tempClient = client(clientID: myItem.clientID)
                            clientName = tempClient.name
                            lastClientID = myItem.clientID
                        }
                        
                        let profit = myItem.financials[0].income - myItem.financials[0].expense
                        
                        let gp = (profit/myItem.financials[0].income)  * 100
                        
                        if myItem.financials[0].income != 0 || myItem.financials[0].expense != 0
                        {
                            let newEentry = displayStruct(
                                                        line1: clientName,
                                                        line2: myItem.projectName,
                                                        line3: formatCurrency(myItem.financials[0].expense),
                                                        line4: formatHours(myItem.financials[0].hours),
                                                        line5: formatCurrency(myItem.financials[0].income),
                                                        line6: formatCurrency(profit),
                                                        line7: formatPercent(gp),
                                                        sourceObject: myItem
                                                            )
                            displayArray.append(newEentry)
                        }
                    }
  
                    lbl1.isHidden = false
                    lbl2.isHidden = false
                    lbl3.isHidden = false
                    lbl4.isHidden = false
                    lbl5.isHidden = false
                    lbl6.isHidden = false
                    lbl7.isHidden = false
                    
                    lbl1.text = "Client"
                    lbl2.text = "Contract"
                    lbl3.text = "Cost"
                    lbl4.text = "Hours"
                    lbl5.text = "Income"
                    lbl6.text = "Profit"
                    lbl7.text = "GP%"
                    
                    tblData1.isHidden = false
                    tblData1.reloadData()
                }
                else
                {
                    tblData1.isHidden = true
                }
            
            case 1:  // Wage per person for month
                if btnDropdown.currentTitle != "Select"
                {
                    displayArray.removeAll()
                    
                    for myItem in people(teamID: currentUser.currentTeam!.teamID).people
                    {
                        let monthReport = myItem.getFinancials(month: btnDropdown.currentTitle!, year: btnYear.currentTitle!)
                        
                        if monthReport.hours != 0
                        {
                            let newEntry = displayStruct(
                                line1: "",
                                line2: myItem.name,
                                line3: formatHours(monthReport.hours),
                                line4: formatCurrency(monthReport.wage),
                                line5: "",
                                line6: "",
                                line7: "",
                                sourceObject: myItem
                            )
                            displayArray.append(newEntry)
                        }
                    }
                    
                    lbl1.isHidden = true
                    lbl2.isHidden = false
                    lbl3.isHidden = false
                    lbl4.isHidden = false
                    lbl5.isHidden = true
                    lbl6.isHidden = true
                    lbl7.isHidden = true
                    
                    lbl1.text = ""
                    lbl2.text = "Name"
                    lbl3.text = "Hours"
                    lbl4.text = "Pay"
                    lbl5.text = ""
                    lbl6.text = ""
                    lbl7.text = ""
                    
                    tblData1.isHidden = false
                    tblData1.reloadData()
                }
                else
                {
                    tblData1.isHidden = true
            }
            
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
                
                if readDefaultString("reportYear") != ""
                {
                    btnYear.setTitle(readDefaultString("reportYear"), for: .normal)
                }
                else
                {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY"
                    btnYear.setTitle(dateFormatter.string(from: Date()), for: .normal)
                }

            default:
                print("populateDropdowns fot default : btnReport.currentTitle!")
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
