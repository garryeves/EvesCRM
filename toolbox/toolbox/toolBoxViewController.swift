//
//  toolBoxViewController.swift
//  toolbox
//
//  Created by Garry Eves on 3/7/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class toolboxViewController: UIViewController, myCommunicationDelegate, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var tblCalendar: UITableView!
    @IBOutlet weak var tblAlerts: UITableView!
    @IBOutlet weak var btnPeople: UIButton!
    @IBOutlet weak var btnClients: UIButton!
    @IBOutlet weak var btnSettings: UIBarButtonItem!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    fileprivate var firstRun = true
    fileprivate var alertList: alerts!
    fileprivate var appointmentList: iOSCalendar!
    
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
                if appointmentList != nil
                {
                    return appointmentList.events.count
                }
                else
                {
                    return 0
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
            
            cell.lblName.text = appointmentList.events[indexPath.row].title
            cell.lblDate.text = ""
            cell.lblWhere.text = appointmentList.events[indexPath.row].structuredLocation?.title
            
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
//        switch tableView
//        {
//        case tblData1:
//            for reportEntry in reportList.reports
//            {
//                if reportEntry.reportName == btnReport.currentTitle!
//                {
//                    switch reportEntry.reportName
//                    {
//                    case reportContractForMonth:  // Contract for month
//                        let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
//                        contractEditViewControl.communicationDelegate = self
//
//                        let tempObject = reportEntry.lines[indexPath.row].sourceObject as! project
//                        contractEditViewControl.workingContract = tempObject
//
//                        self.present(contractEditViewControl, animated: true, completion: nil)
//
//                    case reportWagesForMonth:  // Wage per person for month
//                        let rosterViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "monthlyRoster") as! monthlyRosterViewController
//                        rosterViewControl.communicationDelegate = self
//
//                        let tempObject = reportEntry.lines[indexPath.row].sourceObject as! person
//                        rosterViewControl.selectedPerson = tempObject
//
//                        rosterViewControl.month = btnDropdown.currentTitle!
//                        rosterViewControl.year = btnYear.currentTitle!
//                        self.present(rosterViewControl, animated: true, completion: nil)
//
//                    case reportContractForYear:
//                        let _ = 1
//
//                    case reportContractDates:
//                        let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
//                        contractEditViewControl.communicationDelegate = self
//
//                        let tempObject = reportEntry.lines[indexPath.row].sourceObject as! project
//                        contractEditViewControl.workingContract = tempObject
//
//                        self.present(contractEditViewControl, animated: true, completion: nil)
//
//                    default:
//                        print("unknow entry myPickerDidFinish - selectedItem - \(reportEntry.reportName)")
//                    }
//
//
//                    break
//                }
//            }
//
//        case tblAlerts:
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
//
//        default:
//            let _ = 1
//        }
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
//        let userEditViewControl = self.storyboard?.instantiateViewController(withIdentifier: "settings") as! settingsViewController
//        userEditViewControl.communicationDelegate = self
//        self.present(userEditViewControl, animated: true, completion: nil)
    }
    
    func refreshScreen()
    {
        navBarTitle.title = currentUser.currentTeam!.name
        
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
        
        // Load calendar items
        
        appointmentList = iOSCalendar(teamID: currentUser.currentTeam!.teamID)
        
        tblCalendar.reloadData()
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
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var btnClient: UIButton!
    @IBOutlet weak var btnProject: UIButton!
    
    @IBAction func btnClient(_ sender: UIButton)
    {
    }
    
    @IBAction func btnProject(_ sender: UIButton)
    {
    }
}
