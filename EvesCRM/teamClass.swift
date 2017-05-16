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
let NotificationTeamCountQueryString = "NotificationTeamCountQueryDone"

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
    fileprivate var myRoles: [Roles]!
    fileprivate var myStages:[Stages]!
    fileprivate var myGTD: [workingGTDLevel] = Array()
    fileprivate var myGTDTopLevel: [workingGTDItem] = Array()
    fileprivate var myContexts: [context] = Array()
    fileprivate var myTaxNumber: String = ""
    fileprivate var myCompanyRegNumber: String = ""
    fileprivate var myNextInvoiceNumber: Int = 0
    fileprivate var myCompanyLogo: UIImage!
    fileprivate var logoChanged: Bool = false
    fileprivate var saveCalled: Bool = false
    fileprivate var myMeetings: [calendarItem] = Array()
    
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

    var roles: [Roles]
    {
        get
        {
            return myRoles
        }
    }
    
    var stages: [Stages]
    {
        get
        {
            return myStages
        }
    }
    
    var meetings: [calendarItem]
    {
        get
        {
            return myMeetings
        }
    }

    var GTDLevels: [workingGTDLevel]
    {
        get
        {
            return myGTD
        }
    }

    var GTDTopLevel: [workingGTDItem]
    {
        get
        {
            return myGTDTopLevel
        }
    }

    var contexts: [context]
    {
        get
        {
            return myContexts
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
        myStatus = "Open"
        myType = "Organisation"
        
        // Now lets call to create the team in cloudkit

        notificationCenter.addObserver(self, selector: #selector(self.teamCreated), name: NotificationTeamSaved, object: nil)

        var tempLogo: NSData?
        
        if myCompanyLogo != nil
        {
            tempLogo = UIImagePNGRepresentation(myCompanyLogo) as NSData?
        }
        
        myCloudDB.createNewTeam(teamID: myTeamID, type: myType, status: myStatus, taxNumber: myTaxNumber, companyRegNumber: myCompanyRegNumber, nextInvoiceNumber: myNextInvoiceNumber, logo: tempLogo)
    }
    
    func teamCreated()
    {
        // Create an entry in the device coredata 
        
        save(false)
        
        populateTeamStateDropDown()
        
        populateRolesDropDown()
        
        populateStagesDropDown()
        
        populatePublicDecodes()
        
        populatePrivacyDropDown()
        
        populateRoleTypesDropDown()
        
        populateRoleAccessDropDown()
        
        populateAddressDropDown()
        
        populateContactsDropDown()
        
        notificationCenter.post(name: NotificationTeamCreated, object: nil)
    }
    
    private func populateTeamStateDropDown()
    {
        myDatabaseConnection.saveDropdowns("TeamState", dropdownValue: "Open", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("TeamState", dropdownValue: "OnHold", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("TeamState", dropdownValue: "Closed", teamID: myTeamID)
        usleep(500)
    }
    
    private func populateRolesDropDown()
    {
        myDatabaseConnection.saveDropdowns("Roles", dropdownValue: "Project Manager", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Roles", dropdownValue: "Project Executive", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Roles", dropdownValue: "Project Sponsor", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Roles", dropdownValue: "Technical Stakeholder", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Roles", dropdownValue: "Business Stakeholder", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Roles", dropdownValue: "Developer", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Roles", dropdownValue: "Tester", teamID: myTeamID)
        usleep(500)
    }
    
    private func populateStagesDropDown()
    {
        myDatabaseConnection.saveDropdowns("Stages", dropdownValue: "Definition", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Stages", dropdownValue: "Initiation", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Stages", dropdownValue: "Planning", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Stages", dropdownValue: "Execution", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Stages", dropdownValue: "Monitoring & Control", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Stages", dropdownValue: "Closure", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Stages", dropdownValue: "Completed", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Stages", dropdownValue: "Archived", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Stages", dropdownValue: "On Hold", teamID: myTeamID)
        usleep(500)
    }
    
    private func populatePrivacyDropDown()
    {
        myDatabaseConnection.saveDropdowns("Privacy", dropdownValue: "Private", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("Privacy", dropdownValue: "Public", teamID: myTeamID)
        usleep(500)
    }
    
    private func populateRoleTypesDropDown()
    {
        myDatabaseConnection.saveDropdowns("RoleType", dropdownValue: "Admin", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("RoleType", dropdownValue: "Rostering", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("RoleType", dropdownValue: "Invoicing", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("RoleType", dropdownValue: "Financials", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("RoleType", dropdownValue: "HR", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("RoleType", dropdownValue: "Sales", teamID: myTeamID)
        usleep(500)
    }
    
    private func populateRoleAccessDropDown()
    {
        myDatabaseConnection.saveDropdowns("RoleAccess", dropdownValue: "None", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("RoleAccess", dropdownValue: "Read", teamID: myTeamID)
        usleep(500)
        myDatabaseConnection.saveDropdowns("RoleAccess", dropdownValue: "Write", teamID: myTeamID)
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
    
    private func populatePublicDecodes()
    {
        // none at the moment but here for when it is needed
    }
    
    func getDropDown(dropDownType: String)->[String]
    {
        var retArray: [String] = Array()
        
        for myItem in myDatabaseConnection.getDropdowns(dropdownType: dropDownType)
        {
            retArray.append(myItem.dropDownValue!)
        }
        
        return retArray
    }
    
    fileprivate func createGTDLevels()
    {
        // Create Initial GTD Levels
        
        myDatabaseConnection.saveGTDLevel(1, levelName: "Purpose and Core Values", teamID: myTeamID)
        myDatabaseConnection.saveGTDLevel(2, levelName: "Vision", teamID: myTeamID)
        myDatabaseConnection.saveGTDLevel(3, levelName: "Goals and Objectives", teamID: myTeamID)
        myDatabaseConnection.saveGTDLevel(4, levelName: "Areas of Responsibility", teamID: myTeamID)
    }
    
    func getRoleTypes() -> [String]
    {
        var retArray: [String] = Array()
        
        for myItem in dropdowns(dropdownType: "RoleType").dropdowns
        {
            retArray.append(myItem.dropdownValue)
        }
        return retArray
    }
    
    func loadGTDLevels()
    {
        myGTD.removeAll()
        for myItem in myDatabaseConnection.getGTDLevels(myTeamID)
        {
            let myWorkingLevel = workingGTDLevel(sourceGTDLevel: Int(myItem.gTDLevel), teamID: myTeamID)
            myGTD.append(myWorkingLevel)
        }

        loadGTDTopLevel()
    }
    
    func loadGTDTopLevel()
    {
        myGTDTopLevel.removeAll()
        for myItem in myDatabaseConnection.getGTDItemsForLevel(1, teamID: myTeamID)
        {
            let myWorkingLevel = workingGTDItem(GTDItemID: Int(myItem.gTDItemID), teamID: myTeamID)
            myGTDTopLevel.append(myWorkingLevel)
        }
    }
    
    func loadContexts()
    {
        myContexts.removeAll()
        for myItem in myDatabaseConnection.getContexts(myTeamID)
        {
            let myWorkingContext = context(sourceContext: myItem)
            myContexts.append(myWorkingContext)
        }
    }
    
    func save(_ saveToCloud: Bool = true)
    {
        myDatabaseConnection.saveTeam(myTeamID, name: myName, status: myStatus, note: myNote, type: myType, predecessor: myPredecessor, externalID: myExternalID, taxNumber: myTaxNumber, companyRegNumber: myCompanyRegNumber, nextInvoiceNumber: myNextInvoiceNumber)
        
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
    
    func loadMeetings()
    {
        myMeetings.removeAll()
        
        for meetingItem in myDatabaseConnection.getAgendaForTeam(myTeamID)
        {
            let tempItem = calendarItem(meetingAgenda: meetingItem)
            myMeetings.append(tempItem)
        }
    }
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
    
    func saveTeam(_ teamID: Int, name: String, status: String, note: String, type: String, predecessor: Int, externalID: String, taxNumber: String, companyRegNumber: String, nextInvoiceNumber: Int, updateTime: Date =  Date(), updateType: String = "CODE")
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
    
    func replaceTeam(_ teamID: Int, name: String, status: String, note: String, type: String, predecessor: Int, externalID: String, taxNumber: String, companyRegNumber: String, nextInvoiceNumber: Int, logo: NSData, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myTeam = Team(context: persistentContainer.viewContext)
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
        myTeam.logo = logo

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
        
        saveContext()
        self.refreshObject(myTeam)
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
    
    func getMyTeams(_ myID: String)->[Team]
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
        
        deleteAllGTDLevelRecords()
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
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue, notification: NotificationTeamCountQueryString)
    }
    
    func teamCount() -> Int
    {
        return recordsInTable
    }
    
    func createNewTeam(teamID: Int, type: String, status:String, taxNumber: String, companyRegNumber: String, nextInvoiceNumber: Int, logo: NSData?)
    {
        let record = CKRecord(recordType: "Team")
        record.setValue(teamID, forKey: "teamID")
        record.setValue(status, forKey: "status")
        record.setValue(type, forKey: "type")
        record.setValue(taxNumber, forKey: "taxNumber")
        record.setValue(companyRegNumber, forKey: "companyRegNumber")
        record.setValue(nextInvoiceNumber, forKey: "nextInvoiceNumber")
        
        do
        {
            if logo != nil
            {
                var tempURL: URL!
                try logo?.write(to: tempURL, options: NSData.WritingOptions.atomicWrite)
                let asset = CKAsset(fileURL: tempURL)
                record.setValue(asset, forKey: "logo")
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
        for myItem in myDatabaseConnection.getTeamsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Team"))
        {
            saveTeamRecordToCloudKit(myItem)
        }
    }
    
    func updateTeamInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", myDatabaseConnection.getSyncDateForTable(tableName: "Team") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Team", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1

                self.updateTeamRecord(record)
            self.recordCount -= 1

                usleep(useconds_t(self.sleepTime))
            }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
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
        let predicate: NSPredicate = NSPredicate(value: true)
        
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
            
            var logo: NSData!
            
            if let asset = record["logo"] as? CKAsset
            {
                logo = NSData(contentsOf: asset.fileURL)
            }
            
            myDatabaseConnection.replaceTeam(teamID, name: name, status: status, note: note, type: type, predecessor: predecessor, externalID: externalID, taxNumber: taxNumber, companyRegNumber: companyRegNumber, nextInvoiceNumber: nextInvoiceNumber, logo: logo, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
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
                    
                    do
                    {
                        if sourceRecord.logo != nil
                        {
                            var tempURL: URL!
                            try sourceRecord.logo?.write(to: tempURL, options: NSData.WritingOptions.atomicWrite)
                            let asset = CKAsset(fileURL: tempURL)
                            record!.setValue(asset, forKey: "logo")
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
                    
                    do
                    {
                        if sourceRecord.logo != nil
                        {
                            var tempURL: URL!
                            try sourceRecord.logo?.write(to: tempURL, options: NSData.WritingOptions.atomicWrite)
                            let asset = CKAsset(fileURL: tempURL)
                            record.setValue(asset, forKey: "logo")
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
        
        var logo: NSData!
        
        if let asset = sourceRecord["logo"] as? CKAsset
        {
            logo = NSData(contentsOf: asset.fileURL)
        }
        
        myDatabaseConnection.saveTeam(teamID, name: name, status: status, note: note, type: type, predecessor: predecessor, externalID: externalID, taxNumber: taxNumber, companyRegNumber: companyRegNumber, nextInvoiceNumber: nextInvoiceNumber, updateTime: updateTime, updateType: updateType)
        
        if logo != nil
        {
            myDatabaseConnection.saveTeamLogo(teamID: teamID, logo: logo)
        }
    }
}
