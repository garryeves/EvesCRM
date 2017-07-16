//
//  teamClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 27/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import UIKit

let NotificationTeamCreated = Notification.Name("NotificationTeamCreated")
let NotificationTeamSaved = Notification.Name("NotificationTeamSaved")
let NotificationTeamCountQueryDone = Notification.Name("NotificationTeamCountQueryDone")

let shiftShiftType = "Shift"
let eventShiftType = "Event"
let calloutShiftType = "On Call"
let overtimeShiftType = "Overtime"
let regularShiftType = "Regular"

let openTeamState = "Open"
let holdTeamState = "On Hold"
let closedTeamState = "Closed"

let organisationTeamType = "Organisation"

class teams: NSObject
{
    private var myTeams: [team] = Array()
    
    var teams: [team]
    {
        get
        {
            return myTeams
        }
    }
    
    override init()
    {
        for myItem in myDatabaseConnection.getAllTeams()
        {
            let tempTeam = team(teamID: Int(myItem.teamID))
            myTeams.append(tempTeam)
        }
    }
}

class team: NSObject
{
    fileprivate var myTeamID: Int = 0
    fileprivate var myName: String = "New"
    fileprivate var myNote: String = ""
    fileprivate var myStatus: String = ""
    fileprivate var myType: String = ""
    fileprivate var myPredecessor: Int = 0
    fileprivate var myExternalID: String = ""
    fileprivate var myRoles: [Int] = Array()
    fileprivate var myStages:[Int] = Array()
    fileprivate var myGTD: [Int] = Array()
    fileprivate var myGTDTopLevel: [Int] = Array()
    fileprivate var myContexts: [Int] = Array()
    fileprivate var myTaxNumber: String = ""
    fileprivate var myCompanyRegNumber: String = ""
    fileprivate var myNextInvoiceNumber: Int = 0
    fileprivate var myCompanyLogo: UIImage!
    fileprivate var logoChanged: Bool = false
    fileprivate var saveCalled: Bool = false
    fileprivate var myMeetings: [Int] = Array()
    fileprivate var mySubscriptionDate: Date!
    fileprivate var mySubscriptionLevel: Int = 1
    fileprivate var myTeamOwner: Int = 0
    
    var teamID: Int
    {
        get
        {
            return myTeamID
        }
        set
        {
            myTeamID = newValue
            save()
        }
    }
    
    var nextInvoiceNumber: Int
    {
        get
        {
            return myNextInvoiceNumber
        }
        set
        {
            myNextInvoiceNumber = newValue
        }
    }
    
    var logo: UIImage?
    {
        get
        {
            return myCompanyLogo
        }
        set
        {
            myCompanyLogo = newValue
            logoChanged = true
        }
    }
    
    var name: String
    {
        get
        {
            return myName
        }
        set
        {
            myName = newValue
        }
    }
    
    var taxNumber: String
    {
        get
        {
            return myTaxNumber
        }
        set
        {
            myTaxNumber = newValue
        }
    }
    
    var companyRegNumber: String
    {
        get
        {
            return myCompanyRegNumber
        }
        set
        {
            myCompanyRegNumber = newValue
        }
    }
    var status: String
    {
        get
        {
            return myStatus
        }
        set
        {
            myStatus = newValue
        }
    }
    
    var note: String
    {
        get
        {
            return myNote
        }
        set
        {
            myNote = newValue
        }
    }
    
    var predecessor: Int
    {
        get
        {
            return myPredecessor
        }
        set
        {
            myPredecessor = newValue
        }
    }
    
    var externalID: String
    {
        get
        {
            return myExternalID
        }
        set
        {
            myExternalID = newValue
        }
    }
    
    var type: String
    { // Type should be either "private" or "shared"
        get
        {
            return myType
        }
        set
        {
            myType = newValue
        }
    }

    var roles: [Int]
    {
        get
        {
            return myRoles
        }
    }
    
    var stages: [Int]
    {
        get
        {
            return myStages
        }
    }
    
    var meetings: [Int]
    {
        get
        {
            return myMeetings
        }
    }

    var GTDLevels: [Int]
    {
        get
        {
            return myGTD
        }
    }

    var GTDTopLevel: [Int]
    {
        get
        {
            return myGTDTopLevel
        }
    }

    var contexts: [Int]
    {
        get
        {
            return myContexts
        }
    }
    
    var subscriptionDate: Date
    {
        get
        {
            return mySubscriptionDate
        }
        set
        {
            mySubscriptionDate = newValue
        }
    }
    
    var subscriptionDateString: String
    {
        get
        {
            if mySubscriptionDate == nil
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = DateFormatter.Style.medium
                return myDateFormatter.string(from: Date())
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = DateFormatter.Style.medium
                return myDateFormatter.string(from: mySubscriptionDate)
            }
        }
    }
    
    var subscriptionLevel: Int
    {
        get
        {
            return mySubscriptionLevel
        }
        set
        {
            mySubscriptionLevel = newValue
        }
    }
    
    var teamOwner: Int
    {
        get
        {
            return myTeamOwner
        }
        set
        {
            myTeamOwner = newValue
        }
    }
    
    init(teamID: Int)
    {
        super.init()
        // Load the details
        
        let myTeam = myDatabaseConnection.getTeam(teamID)
        
        for myItem in myTeam
        {
            myTeamID = Int(myItem.teamID)
            myName = myItem.name!
            myStatus = myItem.status!
            myType = myItem.type!
            myNote = myItem.note!
            myPredecessor = Int(myItem.predecessor)
            myExternalID = myItem.externalID!
            myTaxNumber = myItem.taxNumber!
            myCompanyRegNumber = myItem.companyRegNumber!
            myNextInvoiceNumber = Int(myItem.nextInvoiceNumber)
            mySubscriptionDate = myItem.subscriptionDate! as Date
            mySubscriptionLevel = Int(myItem.subscriptionLevel)
            myTeamOwner = Int(myItem.teamOwner)
            
            if myItem.logo != nil
            {
                myCompanyLogo = UIImage(data: myItem.logo! as Data)
            }
        }
    }

    override init()
    {
        // Create a new team
        super.init()
        
        notificationCenter.addObserver(self, selector: #selector(self.queryFinished), name: NotificationTeamCountQueryDone, object: nil)
                
        myCloudDB.getTeamCount()
    }
    
    func queryFinished()
    {
        notificationCenter.removeObserver(NotificationTeamCountQueryDone)
        
        myTeamID = myCloudDB.teamCount() + 1
        myStatus = openTeamState
        myType = organisationTeamType
        
        // Now lets call to create the team in cloudkit

        notificationCenter.addObserver(self, selector: #selector(self.teamCreated), name: NotificationTeamSaved, object: nil)

        var tempLogo: NSData?
        
        if myCompanyLogo != nil
        {
            tempLogo = UIImagePNGRepresentation(myCompanyLogo) as NSData?
        }
        
        if mySubscriptionDate == nil
        {
            let myCal = Calendar.current
            
            mySubscriptionDate = myCal.date(byAdding: .month, value: 1, to: Date())!
        }
        
        myCloudDB.createNewTeam(teamID: myTeamID, type: myType, status: myStatus, taxNumber: myTaxNumber, companyRegNumber: myCompanyRegNumber, nextInvoiceNumber: myNextInvoiceNumber, logo: tempLogo, subscriptionDate: mySubscriptionDate, subscriptionLevel: 1)
    }
    
    func teamCreated()
    {
        // Create an entry in the device coredata 
        
        save(false)
        
        populateRolesDropDown()
        sleep(1)
        populateProjectStageDropDown()
        sleep(1)
        populatePublicDecodes()
        sleep(1)
        populatePrivacyDropDown()
        sleep(1)
        populateAddressDropDown()
        sleep(1)
        populateContactsDropDown()
        sleep(1)
        populateShowRoles()
        sleep(1)
        populateReports()
        sleep(1)

        notificationCenter.post(name: NotificationTeamCreated, object: nil)
    }
    
    private func populateRolesDropDown()
    {
        myDatabaseConnection.saveDropdowns("Project Roles", dropdownValue: "Project Manager", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Project Roles", dropdownValue: "Project Executive", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Project Roles", dropdownValue: "Project Sponsor", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Project Roles", dropdownValue: "Technical Stakeholder", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Project Roles", dropdownValue: "Business Stakeholder", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Project Roles", dropdownValue: "Developer", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Project Roles", dropdownValue: "Tester", teamID: myTeamID)
        usleep(500)
    }

    private func populateProjectStageDropDown()
    {
        myDatabaseConnection.saveDropdowns("Event Project", dropdownValue: "Initiation", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Project", dropdownValue: "Planning", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Project", dropdownValue: "Execution", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Project", dropdownValue: "Closure", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Project", dropdownValue: "Completed", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Project", dropdownValue: archivedProjectStatus, teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Project", dropdownValue: "On Hold", teamID: myTeamID)
        usleep(500)
        
        myDatabaseConnection.saveDropdowns("Regular Project", dropdownValue: "Definition", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Regular Project", dropdownValue: "Initiation", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Regular Project", dropdownValue: "Planning", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Regular Project", dropdownValue: "Execution", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Regular Project", dropdownValue: "Monitoring & Control", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Regular Project", dropdownValue: "Closure", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Regular Project", dropdownValue: "Completed", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Regular Project", dropdownValue: archivedProjectStatus, teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Regular Project", dropdownValue: "On Hold", teamID: myTeamID)
        usleep(500)
        
        myDatabaseConnection.saveDropdowns("Sales Project", dropdownValue: "Requirement Gathering", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Sales Project", dropdownValue: "Darft Contract", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Sales Project", dropdownValue: "Review Contract", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Sales Project", dropdownValue: "Contract Submitted", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Sales Project", dropdownValue: "Response Received", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Sales Project", dropdownValue: "Awaiting Client", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Sales Project", dropdownValue: "Contract Won", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Sales Project", dropdownValue: "Contract Not Won", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Sales Project", dropdownValue: archivedProjectStatus, teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Sales Project", dropdownValue: "On Hold", teamID: myTeamID)
        usleep(500)
    }
    
    private func populatePrivacyDropDown()
    {
        myDatabaseConnection.saveDropdowns("Privacy", dropdownValue: "Private", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Privacy", dropdownValue: "Public", teamID: myTeamID)
        usleep(500)
    }
    
    private func populateAddressDropDown()
    {
        myDatabaseConnection.saveDropdowns("Address", dropdownValue: "Home", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Address", dropdownValue: "Postal", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Address", dropdownValue: "Office", teamID: myTeamID)
        usleep(500)
    }
    
    private func populateContactsDropDown()
    {
        myDatabaseConnection.saveDropdowns("Contacts", dropdownValue: "Home Phone", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Contacts", dropdownValue: "Mobile Phone", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Contacts", dropdownValue: "Office Phone", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Contacts", dropdownValue: "Home Email", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Contacts", dropdownValue: "Office Email", teamID: myTeamID)
        usleep(500)
    }
    
    private func populateShowRoles()
    {
        myDatabaseConnection.saveDropdowns("Event Roles", dropdownValue: "1st Aid", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Roles", dropdownValue: "Chauffeur", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Roles", dropdownValue: "Manager", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Roles", dropdownValue: "Security", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Roles", dropdownValue: "Site Crew", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Roles", dropdownValue: "Steward", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Event Roles", dropdownValue: "Team Lead", teamID: myTeamID)
        usleep(500)
    }
    
    func populateReports()
    {
        let tempReport = report(teamID: myTeamID)
        tempReport.reportName = reportContractForMonth
        tempReport.subject = reportContractForMonth
        tempReport.reportType = "Financial"
        tempReport.systemReport = true
        tempReport.columnTitle1 = "Client"
        tempReport.columnTitle2 = "Contract"
        tempReport.columnTitle3 = "Hours"
        tempReport.columnTitle4 = "Cost"
        tempReport.columnTitle5 = "Income"
        tempReport.columnTitle6 = "Profit"
        tempReport.columnTitle7 = "GP%"
        tempReport.columnWidth1 = 26.9
        tempReport.columnWidth2 = 24.7
        tempReport.columnWidth3 = 8.9
        tempReport.columnWidth4 = 11.2
        tempReport.columnWidth5 = 11.2
        tempReport.columnWidth6 = 11.2
        tempReport.columnWidth7 = 5.6
        tempReport.save()
        
        let tempReport2 = report(teamID: myTeamID)
        tempReport2.reportName = reportWagesForMonth
        tempReport2.subject = reportWagesForMonth
        tempReport.reportType = "Financial"
        tempReport.systemReport = true
        tempReport2.columnTitle1 = "Name"
        tempReport2.columnTitle2 = "Hours"
        tempReport2.columnTitle3 = "Pay"
        tempReport2.columnWidth1 = 26.9
        tempReport2.columnWidth2 = 11.2
        tempReport2.columnWidth3 = 13.4
        tempReport2.save()
        
        let tempReport3 = report(teamID: myTeamID)
        tempReport3.reportName = reportContractForYear
        tempReport3.subject = reportContractForYear
        tempReport.reportType = "Financial"
        tempReport.systemReport = true
        tempReport3.columnTitle1 = ""
        tempReport3.columnTitle2 = "Jan"
        tempReport3.columnTitle3 = "Feb"
        tempReport3.columnTitle4 = "Mar"
        tempReport3.columnTitle5 = "Apr"
        tempReport3.columnTitle6 = "May"
        tempReport3.columnTitle7 = "Jun"
        tempReport3.columnTitle8 = "Jul"
        tempReport3.columnTitle9 = "Aug"
        tempReport3.columnTitle10 = "Sep"
        tempReport3.columnTitle11 = "Oct"
        tempReport3.columnTitle12 = "Nov"
        tempReport3.columnTitle13 = "Dec"
        tempReport3.columnTitle14 = "Total"
        tempReport3.columnWidth1 = 18.0
        tempReport3.columnWidth2 = 6.0
        tempReport3.columnWidth3 = 6.0
        tempReport3.columnWidth4 = 6.0
        tempReport3.columnWidth5 = 6.0
        tempReport3.columnWidth6 = 6.0
        tempReport3.columnWidth7 = 6.0
        tempReport3.columnWidth8 = 6.0
        tempReport3.columnWidth9 = 6.0
        tempReport3.columnWidth10 = 6.0
        tempReport3.columnWidth11 = 6.0
        tempReport3.columnWidth12 = 6.0
        tempReport3.columnWidth13 = 6.0
        tempReport3.columnWidth14 = 6.0
        tempReport3.landscape()
        tempReport3.save()
        
        let tempReport4 = report(teamID: myTeamID)
        tempReport4.reportName = reportContractDates
        tempReport4.subject = reportContractDates
        tempReport.reportType = "Financial"
        tempReport.systemReport = true
        tempReport4.columnTitle1 = "Client"
        tempReport4.columnTitle2 = "Contract"
        tempReport4.columnTitle3 = "Hours"
        tempReport4.columnTitle4 = "Cost"
        tempReport4.columnTitle5 = "Income"
        tempReport4.columnTitle6 = "Profit"
        tempReport4.columnTitle7 = "GP%"
        tempReport4.columnWidth1 = 26.9
        tempReport4.columnWidth2 = 24.7
        tempReport4.columnWidth3 = 8.9
        tempReport4.columnWidth4 = 11.2
        tempReport4.columnWidth5 = 11.2
        tempReport4.columnWidth6 = 11.2
        tempReport4.columnWidth7 = 5.6
        tempReport4.save()
    }
    
    private func populatePublicDecodes()
    {
        // none at the moment but here for when it is needed
    }
    
    func getDropDown(dropDownType: String)->[String]
    {
        var retArray: [String] = Array()
        
        for myItem in myDatabaseConnection.getDropdowns(dropdownType: dropDownType, teamID: currentUser.currentTeam!.teamID)
        {
            retArray.append(myItem.dropDownValue!)
        }
        
        return retArray
    }
    
    fileprivate func createGTDLevels()
    {
        // Create Initial GTD Levels
        
//        myDatabaseConnection.saveGTDLevel(1, levelName: "Purpose and Core Values", teamID: myTeamID)
//        myDatabaseConnection.saveGTDLevel(2, levelName: "Vision", teamID: myTeamID)
//        myDatabaseConnection.saveGTDLevel(3, levelName: "Goals and Objectives", teamID: myTeamID)
//        myDatabaseConnection.saveGTDLevel(4, levelName: "Areas of Responsibility", teamID: myTeamID)
    }
    
    func getRoleTypes() -> [String]
    {
        var retArray: [String] = Array()
        
        retArray.append(adminRoleType)
        retArray.append(financialsRoleType)
        retArray.append(hrRoleType)
        retArray.append(invoicingRoleType)
        retArray.append(pmRoleType)
        retArray.append(rosteringRoleType)
        retArray.append(salesRoleType)
        
        return retArray
    }
    
//    func loadGTDLevels()
//    {
//        myGTD.removeAll()
//        for myItem in myDatabaseConnection.getGTDLevels(myTeamID)
//        {
//            let myWorkingLevel = workingGTDLevel(sourceGTDLevel: Int(myItem.gTDLevel), teamID: myTeamID)
//            myGTD.append(myWorkingLevel)
//        }
//
//        loadGTDTopLevel()
//    }
    
//    func loadGTDTopLevel()
//    {
//        myGTDTopLevel.removeAll()
//        for myItem in myDatabaseConnection.getGTDItemsForLevel(1, teamID: myTeamID)
//        {
//            let myWorkingLevel = workingGTDItem(GTDItemID: Int(myItem.gTDItemID), teamID: myTeamID)
//            myGTDTopLevel.append(myWorkingLevel)
//        }
//    }
//    
//    func loadContexts()
//    {
//        myContexts.removeAll()
//        for myItem in myDatabaseConnection.getContexts(myTeamID)
//        {
//            let myWorkingContext = context(sourceContext: myItem)
//            myContexts.append(myWorkingContext)
//        }
//    }
//    
    func save(_ saveToCloud: Bool = true)
    {
        myDatabaseConnection.saveTeam(myTeamID, name: myName, status: myStatus, note: myNote, type: myType, predecessor: myPredecessor, externalID: myExternalID, taxNumber: myTaxNumber, companyRegNumber: myCompanyRegNumber, nextInvoiceNumber: myNextInvoiceNumber, subscriptionDate: mySubscriptionDate, subscriptionLevel: mySubscriptionLevel, teamOwner: myTeamOwner)
        
        if logoChanged
        {
            var tempLogo: NSData?
            
            if myCompanyLogo != nil
            {
                tempLogo = UIImagePNGRepresentation(myCompanyLogo) as NSData?
            }
            
            myDatabaseConnection.saveTeamLogo(teamID: myTeamID, logo: tempLogo!)
            logoChanged = false
        }
        
        if !saveCalled && saveToCloud
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myTeam = myDatabaseConnection.getTeam(myTeamID)[0]
    
        myCloudDB.saveTeamRecordToCloudKit(myTeam)
        
        saveCalled = false
    }
    
//    func loadMeetings()
//    {
//        myMeetings.removeAll()
//        
//        for meetingItem in myDatabaseConnection.getAgendaForTeam(myTeamID)
//        {
//            let tempItem = calendarItem(meetingAgenda: meetingItem)
//            myMeetings.append(tempItem)
//        }
//    }
}

extension coreDatabase
{
    func clearDeletedTeam(predicate: NSPredicate)
    {
        let fetchRequest22 = NSFetchRequest<Team>(entityName: "Team")
        
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        do
        {
            let fetchResults22 = try objectContext.fetch(fetchRequest22)
            for myItem22 in fetchResults22
            {
                objectContext.delete(myItem22 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedTeam(predicate: NSPredicate)
    {
        let fetchRequest22 = NSFetchRequest<Team>(entityName: "Team")
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults22 = try objectContext.fetch(fetchRequest22)
            for myItem22 in fetchResults22
            {
                myItem22.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func saveTeam(_ teamID: Int, name: String, status: String, note: String, type: String, predecessor: Int, externalID: String, taxNumber: String, companyRegNumber: String, nextInvoiceNumber: Int, subscriptionDate: Date, subscriptionLevel: Int, teamOwner: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myTeam: Team!
        
        let myTeams = getTeam(teamID)
        
        if myTeams.count == 0
        { // Add
            myTeam = Team(context: objectContext)
            myTeam.teamID = Int64(teamID)
            myTeam.name = name
            myTeam.status = status
            myTeam.note = note
            myTeam.type = type
            myTeam.predecessor = Int64(predecessor)
            myTeam.externalID = externalID
            myTeam.taxNumber = taxNumber
            myTeam.companyRegNumber = companyRegNumber
            myTeam.nextInvoiceNumber = Int64(nextInvoiceNumber)
            myTeam.subscriptionDate = subscriptionDate as NSDate
            myTeam.subscriptionLevel = Int64(subscriptionLevel)
            myTeam.teamOwner = Int64(teamOwner)
            
            if updateType == "CODE"
            {
                myTeam.updateTime =  NSDate()
                myTeam.updateType = "Add"
            }
            else
            {
                myTeam.updateTime = updateTime as NSDate
                myTeam.updateType = updateType
            }
        }
        else
        { // Update
            myTeam = myTeams[0]
            myTeam.name = name
            myTeam.status = status
            myTeam.note = note
            myTeam.type = type
            myTeam.predecessor = Int64(predecessor)
            myTeam.externalID = externalID
            myTeam.taxNumber = taxNumber
            myTeam.companyRegNumber = companyRegNumber
            myTeam.nextInvoiceNumber = Int64(nextInvoiceNumber)
            myTeam.subscriptionDate = subscriptionDate as NSDate
            myTeam.subscriptionLevel = Int64(subscriptionLevel)
            myTeam.teamOwner = Int64(teamOwner)
            
            if updateType == "CODE"
            {
                if myTeam.updateType != "Add"
                {
                    myTeam.updateType = "Update"
                }
                myTeam.updateTime =  NSDate()
            }
            else
            {
                myTeam.updateTime = updateTime as NSDate
                myTeam.updateType = updateType
            }
        }
        
        saveContext()
    }
    
    func saveTeamLogo(teamID: Int, logo: NSData)
    {
        var myTeam: Team!
    
        let myTeams = getTeam(teamID)
    
        myTeam = myTeams[0]
        myTeam.logo = logo
    
        if myTeam.updateType != "Add"
        {
            myTeam.updateType = "Update"
        }
        myTeam.updateTime =  NSDate()

        saveContext()
    }

    func getTeam(_ teamID: Int)->[Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func getTeamsIOwn(_ userID: Int)->[Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamOwner == \(userID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func getAllTeams()->[Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func getTeamsCount() -> Int
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        fetchRequest.shouldRefreshRefetchedObjects = true
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults.count
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
    
    func deleteAllTeams()
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                objectContext.delete(myItem as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
 //       deleteAllGTDLevelRecords()
    }
    
    func getTeamsForSync(_ syncDate: Date) -> [Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", syncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }

    func deleteAllTeamRecords()
    {
        let fetchRequest22 = NSFetchRequest<Team>(entityName: "Team")
        
        do
        {
            let fetchResults22 = try objectContext.fetch(fetchRequest22)
            for myItem22 in fetchResults22
            {
                self.objectContext.delete(myItem22 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func quickFixTeams()
    {
        let fetchRequest22 = NSFetchRequest<Team>(entityName: "Team")
        
        do
        {
            let fetchResults22 = try objectContext.fetch(fetchRequest22)
            for myItem22 in fetchResults22
            {
                myItem22.subscriptionLevel = 10000
                myItem22.updateTime =  NSDate()
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
}

extension CloudKitInteraction
{    
    func getTeamCount()
    {
        recordsInTable = 0
        
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        operation.desiredKeys = ["teamID"]

        operation.recordFetchedBlock = { (record) in
            self.recordsInTable += 1
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Team", queryOperation: operation, onOperationQueue: operationQueue, notification: NotificationTeamCountQueryDone)
    }
    
    func teamCount() -> Int
    {
        return recordsInTable
    }
    
    func createNewTeam(teamID: Int, type: String, status:String, taxNumber: String, companyRegNumber: String, nextInvoiceNumber: Int, logo: NSData?, subscriptionDate: Date, subscriptionLevel: Int)
    {
        let record = CKRecord(recordType: "Team")
        record.setValue(teamID, forKey: "teamID")
        record.setValue(status, forKey: "status")
        record.setValue(type, forKey: "type")
        record.setValue(taxNumber, forKey: "taxNumber")
        record.setValue(companyRegNumber, forKey: "companyRegNumber")
        record.setValue(nextInvoiceNumber, forKey: "nextInvoiceNumber")
        record.setValue(subscriptionDate, forKey: "subscriptionDate")
        record.setValue(subscriptionLevel, forKey: "subscriptionLevel")
        
        do
        {
            if logo != nil
            {
                var tempURL: URL!
                try logo?.write(to: tempURL, options: NSData.WritingOptions.atomicWrite)
                let asset = CKAsset(fileURL: tempURL)
                record.setValue(asset, forKey: "logo")
                tempURL = URL(fileURLWithPath: "dummy")
            }
        }
        catch
        {
            print("Error writing data", error)
        }
        
        self.publicDB.save(record, completionHandler:
        { (savedRecord, saveError) in
            if saveError != nil
            {
                NSLog("Error saving record: \(saveError!.localizedDescription)")
                self.saveOK = false
            }
            else
            {
                if debugMessages
                {
                    NSLog("Successfully saved record!")
                }
                NotificationCenter.default.post(name: NotificationTeamSaved, object: nil)
            }
        })
    }
    
    func saveTeamToCloudKit()
    {
        for myItem in myDatabaseConnection.getTeamsForSync(getSyncDateForTable(tableName: "Team"))
        {
            saveTeamRecordToCloudKit(myItem)
        }
    }
    
    func updateTeamInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", getSyncDateForTable(tableName: "Team") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateTeamRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Team", queryOperation: operation, onOperationQueue: operationQueue)
    }
    
    func deleteTeam()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performPublicDelete(myRecordList)
            sem.signal()
        })
        sem.wait()
    }

    func replaceTeamInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(\(buildTeamList(currentUser.userID)))")
        
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let teamID = record.object(forKey: "teamID") as! Int
            var updateTime = Date()
            if record.object(forKey: "updateTime") != nil
            {
                updateTime = record.object(forKey: "updateTime") as! Date
            }
            var updateType: String = ""
            if record.object(forKey: "updateType") != nil
            {
                updateType = record.object(forKey: "updateType") as! String
            }
            
            let name =  record.object(forKey: "name") as! String
            let note = record.object(forKey: "note") as! String
            let status = record.object(forKey: "status") as! String
            let type = record.object(forKey: "type") as! String
            let predecessor = record.object(forKey: "predecessor") as! Int
            let externalID = record.object(forKey: "externalIDString") as! String
            let taxNumber = record.object(forKey: "taxNumber") as! String
            let companyRegNumber = record.object(forKey: "companyRegNumber") as! String
            let nextInvoiceNumber = record.object(forKey: "nextInvoiceNumber") as! Int
            let subscriptionLevel = record.object(forKey: "subscriptionLevel") as! Int
            let teamOwner = record.object(forKey: "teamOwner") as! Int
            
            var subscriptionDate = Date()
            if record.object(forKey: "subscriptionDate") != nil
            {
                subscriptionDate = record.object(forKey: "subscriptionDate") as! Date
            }
            
            var logo: NSData!
            
            if let asset = record["logo"] as? CKAsset
            {
                logo = NSData(contentsOf: asset.fileURL)
            }
            
            myDatabaseConnection.saveTeam(teamID, name: name, status: status, note: note, type: type, predecessor: predecessor, externalID: externalID, taxNumber: taxNumber, companyRegNumber: companyRegNumber, nextInvoiceNumber: nextInvoiceNumber, subscriptionDate: subscriptionDate, subscriptionLevel: subscriptionLevel, teamOwner: teamOwner, updateTime: updateTime, updateType: updateType)
            
            if logo != nil
            {
                myDatabaseConnection.saveTeamLogo(teamID: teamID, logo: logo)
            }
            
            usleep(self.sleepTime)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Team", queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
        
        replaceTeamForOwnerInCoreData()
    }
    
    func replaceTeamForOwnerInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamOwner == \(currentUser.userID))")
        
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let teamID = record.object(forKey: "teamID") as! Int
            var updateTime = Date()
            if record.object(forKey: "updateTime") != nil
            {
                updateTime = record.object(forKey: "updateTime") as! Date
            }
            var updateType: String = ""
            if record.object(forKey: "updateType") != nil
            {
                updateType = record.object(forKey: "updateType") as! String
            }
            
            
            var name: String = ""
            
            if record.object(forKey: "name") != nil
            {
                name =  record.object(forKey: "name") as! String
            }

            var note: String = ""
            
            if record.object(forKey: "note") != nil
            {
                note = record.object(forKey: "note") as! String
            }

            var status: String = ""
            
            if record.object(forKey: "status") != nil
            {
                status = record.object(forKey: "status") as! String
            }

            var type: String = ""
            
            if record.object(forKey: "type") != nil
            {
                type = record.object(forKey: "type") as! String
            }

            var externalID: String = ""
            
            if record.object(forKey: "externalID") != nil
            {
                externalID = record.object(forKey: "externalIDString") as! String
            }

            var taxNumber: String = ""
            
            if record.object(forKey: "taxNumber") != nil
            {
                taxNumber = record.object(forKey: "taxNumber") as! String
            }

            var companyRegNumber: String = ""
            
            if record.object(forKey: "companyRegNumber") != nil
            {
                companyRegNumber = record.object(forKey: "companyRegNumber") as! String
            }

            var predecessor: Int = 0
            
            if record.object(forKey: "predecessor") != nil
            {
                predecessor = record.object(forKey: "predecessor") as! Int
            }

            var nextInvoiceNumber: Int = 0
            
            if record.object(forKey: "nextInvoiceNumber") != nil
            {
                nextInvoiceNumber = record.object(forKey: "nextInvoiceNumber") as! Int
            }

            var subscriptionLevel: Int = 0
            
            if record.object(forKey: "subscriptionLevel") != nil
            {
                subscriptionLevel = record.object(forKey: "subscriptionLevel") as! Int
            }

            var teamOwner: Int = 0
            
            if record.object(forKey: "teamOwner") != nil
            {
                teamOwner = record.object(forKey: "teamOwner") as! Int
            }
            
            var subscriptionDate = Date()
            if record.object(forKey: "subscriptionDate") != nil
            {
                subscriptionDate = record.object(forKey: "subscriptionDate") as! Date
            }
            
            var logo: NSData!
            
            if let asset = record["logo"] as? CKAsset
            {
                logo = NSData(contentsOf: asset.fileURL)
            }
            
            myDatabaseConnection.saveTeam(teamID, name: name, status: status, note: note, type: type, predecessor: predecessor, externalID: externalID, taxNumber: taxNumber, companyRegNumber: companyRegNumber, nextInvoiceNumber: nextInvoiceNumber, subscriptionDate: subscriptionDate, subscriptionLevel: subscriptionLevel, teamOwner: teamOwner, updateTime: updateTime, updateType: updateType)
            
            if logo != nil
            {
                myDatabaseConnection.saveTeamLogo(teamID: teamID, logo: logo)
            }
            
            usleep(self.sleepTime)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Team", queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }
    
    func saveTeamRecordToCloudKit(_ sourceRecord: Team)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Team", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.note, forKey: "note")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    record!.setValue(sourceRecord.type, forKey: "type")
                    record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record!.setValue(sourceRecord.externalID, forKey: "externalIDString")
                    record!.setValue(sourceRecord.taxNumber, forKey: "taxNumber")
                    record!.setValue(sourceRecord.companyRegNumber, forKey: "companyRegNumber")
                    record!.setValue(sourceRecord.nextInvoiceNumber, forKey: "nextInvoiceNumber")
                    record!.setValue(sourceRecord.subscriptionDate, forKey: "subscriptionDate")
                    record!.setValue(sourceRecord.subscriptionLevel, forKey: "subscriptionLevel")
                    record!.setValue(sourceRecord.teamOwner, forKey: "teamOwner")
 
                    do
                    {
                        if sourceRecord.logo != nil
                        {
                            var tempURL: URL!
                            try sourceRecord.logo?.write(to: tempURL, options: NSData.WritingOptions.atomicWrite)
                            let asset = CKAsset(fileURL: tempURL)
                            record!.setValue(asset, forKey: "logo")
                            tempURL = URL(fileURLWithPath: "dummy")
                        }
                    }
                    catch
                    {
                        print("Error writing data", error)
                    }

                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully updated record!")
                            }
                        }
                    })
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "Team")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.note, forKey: "note")
                    record.setValue(sourceRecord.status, forKey: "status")
                    record.setValue(sourceRecord.type, forKey: "type")
                    record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record.setValue(sourceRecord.externalID, forKey: "externalIDString")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.taxNumber, forKey: "taxNumber")
                    record.setValue(sourceRecord.companyRegNumber, forKey: "companyRegNumber")
                    record.setValue(sourceRecord.nextInvoiceNumber, forKey: "nextInvoiceNumber")
                    record.setValue(sourceRecord.subscriptionDate, forKey: "subscriptionDate")
                    record.setValue(sourceRecord.subscriptionLevel, forKey: "subscriptionLevel")
                    record.setValue(sourceRecord.teamOwner, forKey: "teamOwner")
                    
                    do
                    {
                        if sourceRecord.logo != nil
                        {
                            var tempURL: URL!
                            try sourceRecord.logo?.write(to: tempURL, options: NSData.WritingOptions.atomicWrite)
                            let asset = CKAsset(fileURL: tempURL)
                            record.setValue(asset, forKey: "logo")
                            tempURL = URL(fileURLWithPath: "dummy")
                        }
                    }
                    catch
                    {
                        print("Error writing data", error)
                    }

                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully saved record!")
                            }
                        }
                    })
                }
            }
            sem.signal()
        })
        sem.wait()
    }
    
    func updateTeamRecord(_ sourceRecord: CKRecord)
    {
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        var updateTime = Date()
        if sourceRecord.object(forKey: "updateTime") != nil
        {
            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
        }
        
        var updateType = ""
        
        if sourceRecord.object(forKey: "updateType") != nil
        {
            updateType = sourceRecord.object(forKey: "updateType") as! String
        }
        let name =  sourceRecord.object(forKey: "name") as! String
        let note = sourceRecord.object(forKey: "note") as! String
        let status = sourceRecord.object(forKey: "status") as! String
        let type = sourceRecord.object(forKey: "type") as! String
        let predecessor = sourceRecord.object(forKey: "predecessor") as! Int
        let externalID = sourceRecord.object(forKey: "externalIDString") as! String
        let taxNumber = sourceRecord.object(forKey: "taxNumber") as! String
        let companyRegNumber = sourceRecord.object(forKey: "companyRegNumber") as! String
        let nextInvoiceNumber = sourceRecord.object(forKey: "nextInvoiceNumber") as! Int
        let subscriptionLevel = sourceRecord.object(forKey: "subscriptionLevel") as! Int
        let teamOwner = sourceRecord.object(forKey: "teamOwner") as! Int
        
        var subscriptionDate = Date()
        if sourceRecord.object(forKey: "subscriptionDate") != nil
        {
            subscriptionDate = sourceRecord.object(forKey: "subscriptionDate") as! Date
        }

        var logo: NSData!
        
        if let asset = sourceRecord["logo"] as? CKAsset
        {
            logo = NSData(contentsOf: asset.fileURL)
        }
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
        
        self.recordCount += 1
        
        myDatabaseConnection.saveTeam(teamID, name: name, status: status, note: note, type: type, predecessor: predecessor, externalID: externalID, taxNumber: taxNumber, companyRegNumber: companyRegNumber, nextInvoiceNumber: nextInvoiceNumber, subscriptionDate: subscriptionDate, subscriptionLevel: subscriptionLevel, teamOwner: teamOwner, updateTime: updateTime, updateType: updateType)
        
        if logo != nil
        {
            myDatabaseConnection.saveTeamLogo(teamID: teamID, logo: logo)
        }
        self.recordCount -= 1
    }
}
