//
//  securityViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 15/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//
import UIKit

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
    @IBOutlet weak var alertTableHeight: NSLayoutConstraint!
    @IBOutlet weak var lblAlerts: UILabel!
    @IBOutlet weak var btnReportType: UIButton!
    @IBOutlet weak var lblReportType: UILabel!
    @IBOutlet weak var lblReport: UILabel!
    
    fileprivate var contractList: projects!
    fileprivate var alertList: alerts!
    
    fileprivate var reportList: reports!
    fileprivate var displayList: [String] = Array()
    fileprivate var monthList: [String] = Array()
    
    fileprivate var currentReport: report!
    fileprivate var reportString: String = ""
    fileprivate var reportDate1: Date = Date()
    fileprivate var reportDate2: Date = Date()
    
    fileprivate var firstRun: Bool = true
    
    var communicationDelegate: myCommunicationDelegate?
    
    override func viewDidLoad()
    {
        if currentUser.currentTeam == nil
        {
            currentUser.loadTeams()
        }
        
        if readDefaultInt("teamID") >= 0
        {
            currentUser.currentTeam = team(teamID: readDefaultInt("teamID"))
        }
        
        btnSettings.title = NSString(string: "\u{2699}") as String
        
        btnSelect1.setTitle("Select", for: .normal)
        btnSelect2.setTitle("Select", for: .normal)
        btnReportType.setTitle("Select", for: .normal)
        btnReport.setTitle("Select", for: .normal)
        
        btnPeople.setTitle("Maintain People", for: .normal)

//        if readDefaultInt("reportID") >= 0
//        {
//            currentReportID = readDefaultInt("reportID")
//        }

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
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.buildReportList), userInfo: nil, repeats: false)
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
            case tblData1:
                if currentReport != nil
                {
                    return currentReport.lines.count
                }
                else
                {
                    return 0
                
            }
            case tblAlerts:
                 return alertList.alertList.count
            
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
                
                if currentReport != nil
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
                    
                    buildReportCell(label: cell.lbl1, text: currentReport.lines[indexPath.row].column1, width: currentReport.columnWidth1, constraint: cell.constraintWidth1, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl2, text: currentReport.lines[indexPath.row].column2, width: currentReport.columnWidth2, constraint: cell.constraintWidth2, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl3, text: currentReport.lines[indexPath.row].column3, width: currentReport.columnWidth3, constraint: cell.constraintWidth3, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl4, text: currentReport.lines[indexPath.row].column4, width: currentReport.columnWidth4, constraint: cell.constraintWidth4, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl5, text: currentReport.lines[indexPath.row].column5, width: currentReport.columnWidth5, constraint: cell.constraintWidth5, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl6, text: currentReport.lines[indexPath.row].column6, width: currentReport.columnWidth6, constraint: cell.constraintWidth6, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl7, text: currentReport.lines[indexPath.row].column7, width: currentReport.columnWidth7, constraint: cell.constraintWidth7, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl8, text: currentReport.lines[indexPath.row].column8, width: currentReport.columnWidth8, constraint: cell.constraintWidth8, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl9, text: currentReport.lines[indexPath.row].column9, width: currentReport.columnWidth9, constraint: cell.constraintWidth9, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl10, text: currentReport.lines[indexPath.row].column10, width: currentReport.columnWidth10, constraint: cell.constraintWidth10, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl11, text: currentReport.lines[indexPath.row].column11, width: currentReport.columnWidth11, constraint: cell.constraintWidth11, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl12, text: currentReport.lines[indexPath.row].column12, width: currentReport.columnWidth12, constraint: cell.constraintWidth12, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl13, text: currentReport.lines[indexPath.row].column13, width: currentReport.columnWidth13, constraint: cell.constraintWidth13, drawLine: currentReport.lines[indexPath.row].drawLine)
                    buildReportCell(label: cell.lbl14, text: currentReport.lines[indexPath.row].column14, width: currentReport.columnWidth14, constraint: cell.constraintWidth14, drawLine: currentReport.lines[indexPath.row].drawLine)
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
                    
                    case "Shift":
                        let workingShift = alertList.alertList[indexPath.row].object as! shift
                        
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
        userEditViewControl.communicationDelegate = self
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
        if btnReportType.currentTitle! != "Select"
        {
            reportList = reports(reportType: btnReportType.currentTitle!)
            
            if reportList.reports.count > 0
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
                pickerView.currentValue = btnReport.currentTitle!
                pickerView.preferredContentSize = CGSize(width: 400,height: 400)
                
                self.present(pickerView, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnReportType(_ sender: UIButton)
    {
        displayList = getReportTypes()
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "Reports"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.currentValue = btnReportType.currentTitle!
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnMaintainReports(_ sender: UIButton)
    {
        let reportsViewControl = reportsStoryboard.instantiateViewController(withIdentifier: "reportMaintenance") as! reportMaintenanceViewController
        reportsViewControl.communicationDelegate = self
        self.present(reportsViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnDropdown(_ sender: UIButton)
    {
        switch currentReport.reportName
        {
            case reportContractForMonth:
                displayList.removeAll()
                
                for myItem in monthList
                {
                    displayList.append(myItem)
                }
            
            case reportWagesForMonth:
                    displayList.removeAll()
                    
                    for myItem in monthList
                    {
                        displayList.append(myItem)
                    }
            
            case reportContractForYear:
                displayList.removeAll()
                
                displayList.append("2017")
            
            case reportContractDates:
               // Do nothing
                break
                
            default:
                print("unknown entry btnDropdown - currentReportID - \(currentReport.reportName)")
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
            
            pickerView.source = "dropdown"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 400,height: 400)
            pickerView.currentValue = btnDropdown.currentTitle!
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnYear(_ sender: UIButton)
    {
        displayList.removeAll()
        
        if displayList.count > 0
        {
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
            pickerView.currentValue = btnYear.currentTitle!
            
            self.present(pickerView, animated: true, completion: nil)
        }
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
        
        displayReportFields()
        
        if currentUser != nil
        {
            runReport()
        }
        
        var showRoster: Bool = false
        var showEvents: Bool = false
        var showMonthlyRoster: Bool = false
        var showShare: Bool = false
        var showPeople: Bool = false
        var showClients: Bool = false
        
        if currentUser.checkPermission(rosteringRoleType) != noPermission
        {
            showRoster = true
            showEvents = true
            showMonthlyRoster = true
        }
        
        if currentUser.checkPermission(pmRoleType) != noPermission
        {
            showClients = true
            showPeople = true
            showEvents = true
            showMonthlyRoster = true
            showRoster = true
        }
        
        
        if currentUser.checkPermission(financialsRoleType) != noPermission
        {
            showShare = true
        }
        
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
        
        btnRoster.isEnabled = false
        btnEvents.isEnabled = false
        btnMonthlyRoster.isEnabled = false
        btnShare.isEnabled = false
        btnPeople.isEnabled = false
        btnClients.isEnabled = false
        
        if showRoster
        {
            btnRoster.isEnabled = true
        }
        
        if showEvents
        {
            btnEvents.isEnabled = true
        }
        
        if showMonthlyRoster
        {
            btnMonthlyRoster.isEnabled = true
        }
        
        if showShare
        {
            btnShare.isEnabled = true
        }
        
        if showPeople
        {
            btnPeople.isEnabled = true
        }
        
        if showClients
        {
            btnClients.isEnabled = true
        }
    }
    
    func getReportTypes() -> [String]
    {
        var teamArray: [String] = Array()
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: "Reports"))!
        {
            switch myItem
            {
                case "People":
                    if currentUser.checkPermission(hrRoleType) != noPermission
                    {
                        teamArray.append(myItem)
                    }
                
                case "Financial":
                    if currentUser.checkPermission(financialsRoleType) != noPermission
                    {
                        teamArray.append(myItem)
                    }
                
                default:
                    teamArray.append(myItem)
            }
        }
        
        return teamArray
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
        
        if alertList.alertList.count == 0
        {
            alertTableHeight.constant = 0
            lblAlerts.text = "No Alerts"
        }
        else
        {
            alertTableHeight.constant = 200
            lblAlerts.text = "Alerts"
        }
        updateViewConstraints()
    }
    
    func buildReportList()
    {
        if btnReportType.currentTitle! != "Select"
        {
            reportList = reports(reportType: btnReportType.currentTitle!)
        }
    }
        
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if selectedItem >= 0
        {
            switch source
            {
                case "report":
                    btnReport.setTitle(reportList.reports[selectedItem].reportName, for: .normal)
                    
                    currentReport = reportList.reports[selectedItem]
                    
                    displayReportFields()
                        //           writeDefaultInt("reportID", value: currentReportID)

                case "dropdown":
                    btnDropdown.setTitle(displayList[selectedItem], for: .normal)
                    
                    writeDefaultString("reportMonth", value: displayList[selectedItem])
                
                case "year":
                    btnYear.setTitle(displayList[selectedItem], for: .normal)
                    writeDefaultInt("reportYear", value: Int(displayList[selectedItem])!)

                case "Reports":
                    btnReportType.setTitle(displayList[selectedItem], for: .normal)
                    currentReport = nil
                    btnReport.setTitle("Select", for: .normal)
                
                default:
                    print("unknown entry myPickerDidFinish - source - \(source)")
            }
            runReport()
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
    
    func displayReportFields()
    {
        if getReportTypes().count == 0
        {
            lblDropdown.isHidden = true
            lblYear.isHidden = true
            tblData1.isHidden = true
            btnDropdown.isHidden = true
            btnYear.isHidden = true
            btnSelect1.isHidden = true
            btnSelect2.isHidden = true
            btnMaintainReports.isHidden = true
            btnReport.isHidden = true
            btnReportType.isHidden = true
            lblReportType.isHidden = true
            lblReport.isHidden = true
        }
        else
        {
            btnMaintainReports.isHidden = false
            btnReport.isHidden = false
            btnReportType.isHidden = false
            lblReportType.isHidden = false
            lblReport.isHidden = false
            
            if currentReport != nil
            {
                if currentReport.systemReport
                {
                    switch currentReport.reportName
                    {
                        case reportContractForMonth:
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
                        
                        case reportWagesForMonth:
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
                        
                        case reportContractForYear:
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
                        
                        case reportContractDates:
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
                        print("unknown entry displayReportFields - \(currentReport.reportName)")
                    }
                }
                else
                {
                    lblDropdown.isHidden = true
                    lblYear.isHidden = true
                    tblData1.isHidden = true
                    btnDropdown.isHidden = true
                    btnYear.isHidden = true
                    btnSelect1.isHidden = true
                    btnSelect2.isHidden = true
                    
                    if currentReport.columnWidth1 > 0.0
                    {
                        lbl1.isHidden = false
                        lbl1.text = currentReport.columnTitle1
                    }
                    else
                    {
                        lbl1.isHidden = true
                    }
                    
                    if currentReport.columnWidth2 > 0.0
                    {
                        lbl2.isHidden = false
                        lbl2.text = currentReport.columnTitle2
                    }
                    else
                    {
                        lbl2.isHidden = true
                    }
                    
                    if currentReport.columnWidth3 > 0.0
                    {
                        lbl3.isHidden = false
                        lbl3.text = currentReport.columnTitle3
                    }
                    else
                    {
                        lbl13.isHidden = true
                    }
                    
                    if currentReport.columnWidth4 > 0.0
                    {
                        lbl4.isHidden = false
                        lbl4.text = currentReport.columnTitle4
                    }
                    else
                    {
                        lbl4.isHidden = true
                    }
                    
                    if currentReport.columnWidth5 > 0.0
                    {
                        lbl5.isHidden = false
                        lbl5.text = currentReport.columnTitle5
                    }
                    else
                    {
                        lbl5.isHidden = true
                    }
                    
                    if currentReport.columnWidth6 > 0.0
                    {
                        lbl6.isHidden = false
                        lbl6.text = currentReport.columnTitle6
                    }
                    else
                    {
                        lbl6.isHidden = true
                    }
                    
                    if currentReport.columnWidth7 > 0.0
                    {
                        lbl7.isHidden = false
                        lbl7.text = currentReport.columnTitle7
                    }
                    else
                    {
                        lbl7.isHidden = true
                    }
                    
                    if currentReport.columnWidth8 > 0.0
                    {
                        lbl8.isHidden = false
                        lbl8.text = currentReport.columnTitle8
                    }
                    else
                    {
                        lbl8.isHidden = true
                    }
                    
                    if currentReport.columnWidth9 > 0.0
                    {
                        lbl9.isHidden = false
                        lbl9.text = currentReport.columnTitle9
                    }
                    else
                    {
                        lbl9.isHidden = true
                    }
                    
                    if currentReport.columnWidth10 > 0.0
                    {
                        lbl10.isHidden = false
                        lbl10.text = currentReport.columnTitle10
                    }
                    else
                    {
                        lbl10.isHidden = true
                    }
                    
                    if currentReport.columnWidth11 > 0.0
                    {
                        lbl11.isHidden = false
                        lbl11.text = currentReport.columnTitle11
                    }
                    else
                    {
                        lbl11.isHidden = true
                    }
                    
                    if currentReport.columnWidth12 > 0.0
                    {
                        lbl12.isHidden = false
                        lbl12.text = currentReport.columnTitle12
                    }
                    else
                    {
                        lbl12.isHidden = true
                    }
                    
                    if currentReport.columnWidth13 > 0.0
                    {
                        lbl13.isHidden = false
                        lbl13.text = currentReport.columnTitle13
                    }
                    else
                    {
                        lbl3.isHidden = true
                    }
                    
                    if currentReport.columnWidth14 > 0.0
                    {
                        lbl14.isHidden = false
                        lbl14.text = currentReport.columnTitle4
                    }
                    else
                    {
                        lbl14.isHidden = true
                    }
                    
                }
            }
            else
            {
                lblDropdown.isHidden = true
                lblDropdown.text = "Select"
                lblYear.isHidden = true
                lblYear.text = "End Date"
                tblData1.isHidden = true
                btnDropdown.isHidden = true
                btnYear.isHidden = true
                btnSelect1.isHidden = true
                btnSelect2.isHidden = true
                lbl1.isHidden = true
                lbl2.isHidden = true
                lbl3.isHidden = true
                lbl4.isHidden = true
                lbl5.isHidden = true
                lbl6.isHidden = true
                lbl7.isHidden = true
                lbl8.isHidden = true
                lbl9.isHidden = true
                lbl10.isHidden = true
                lbl11.isHidden = true
                lbl12.isHidden = true
                lbl13.isHidden = true
                lbl14.isHidden = true
            }
        }
    }
    
    func resetWidth(constraint: NSLayoutConstraint)
    {
        constraint.constant = 0.0
    }
    
    func runReport()
    {
        var showReport: Bool = false
        
        if currentReport != nil
        {
            currentReport.removeAll()
            // Lets process through the report
            
            currentReport.displayWidth = tblData1.bounds.width
            
            if currentReport.systemReport
            {
                switch currentReport.reportName
                {
                    case reportContractForMonth:  // Contract for month
                        if btnDropdown.currentTitle! != "Select"
                        {
                            contractList = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true)
                            
                            contractList.loadFinancials(month: btnDropdown.currentTitle!, year: btnYear.currentTitle!)
                            
                            currentReport.reportContractForMonth(contractList)
                            showReport = true
                        }
                    
                    case reportWagesForMonth:  // Wage per person for month
                        if btnDropdown.currentTitle! != "Select"
                        {
                            currentReport.reportWagesForMonth(month: btnDropdown.currentTitle!, year: btnYear.currentTitle!)
                            showReport = true
                        }
                    
                    case reportContractForYear:
                        currentReport.reportContractForYear(year: btnYear.currentTitle!)
                    showReport = true
                    
                    case reportContractDates:
                        if btnSelect1.currentTitle! != "Select" && btnSelect2.currentTitle! != "Select"
                        {
                            currentReport.subject = "Contracts between \(btnSelect1.currentTitle!) - \(btnSelect2.currentTitle!)"
                            contractList = projects(teamID: currentUser.currentTeam!.teamID, includeEvents: true)
                            
                            contractList.loadFinancials(startDate: reportDate1, endDate: reportDate2)
                            
                            currentReport.reportContractDates(contractList)
                            showReport = true
                        }

                    default:
                        print("unknown entry runReport - selectedItem - \(currentReport.reportName)")
                }
            }
            else
            {
                currentReport.run()
                showReport = true
            }
        }
        
        if showReport
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
            
            buildReportCell(label: lbl1, text: currentReport.header.column1, width: CGFloat(currentReport.columnWidth1), constraint: constraintWidth1, drawLine: false)
            buildReportCell(label: lbl2, text: currentReport.header.column2, width: CGFloat(currentReport.columnWidth2), constraint: constraintWidth2, drawLine: false)
            buildReportCell(label: lbl3, text: currentReport.header.column3, width: CGFloat(currentReport.columnWidth3), constraint: constraintWidth3, drawLine: false)
            buildReportCell(label: lbl4, text: currentReport.header.column4, width: CGFloat(currentReport.columnWidth4), constraint: constraintWidth4, drawLine: false)
            buildReportCell(label: lbl5, text: currentReport.header.column5, width: CGFloat(currentReport.columnWidth5), constraint: constraintWidth5, drawLine: false)
            buildReportCell(label: lbl6, text: currentReport.header.column6, width: CGFloat(currentReport.columnWidth6), constraint: constraintWidth6, drawLine: false)
            buildReportCell(label: lbl7, text: currentReport.header.column7, width: CGFloat(currentReport.columnWidth7), constraint: constraintWidth7, drawLine: false)
            buildReportCell(label: lbl8, text: currentReport.header.column8, width: CGFloat(currentReport.columnWidth8), constraint: constraintWidth8, drawLine: false)
            buildReportCell(label: lbl9, text: currentReport.header.column9, width: CGFloat(currentReport.columnWidth9), constraint: constraintWidth9, drawLine: false)
            buildReportCell(label: lbl10, text: currentReport.header.column10, width: CGFloat(currentReport.columnWidth10), constraint: constraintWidth10, drawLine: false)
            buildReportCell(label: lbl11, text: currentReport.header.column11, width: CGFloat(currentReport.columnWidth11), constraint: constraintWidth11, drawLine: false)
            buildReportCell(label: lbl12, text: currentReport.header.column12, width: CGFloat(currentReport.columnWidth12), constraint: constraintWidth12, drawLine: false)
            buildReportCell(label: lbl13, text: currentReport.header.column13, width: CGFloat(currentReport.columnWidth13), constraint: constraintWidth13, drawLine: false)
            buildReportCell(label: lbl14, text: currentReport.header.column14, width: CGFloat(currentReport.columnWidth14), constraint: constraintWidth14, drawLine: false)
        
            updateViewConstraints()
           
            tblData1.isHidden = false
            tblData1.reloadData()
        }
    }
    
    func populateDropdowns()
    {
        switch currentReport.reportName
        {
            case reportContractForMonth, reportWagesForMonth:
                lblDropdown.text = "Month:"
 //               if readDefaultInt("reportID") >= 0
//                {
//                    currentReportID = readDefaultInt("reportID")
//                }
//                
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
            
            case reportContractForYear:
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
                print("populateDropdowns got default : \(currentReport.reportName)")
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
