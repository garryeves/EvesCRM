//
//  projectClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

let eventProjectType = "Event"
let regularProjectType = "Regular"
let projectProjectType = "Project"

class projects: NSObject
{
    fileprivate var myProjects:[project] = Array()
    
    init(clientID: Int, type: String = "")
    {
        super.init()
        
        for myItem in myDatabaseConnection.getProjects(clientID: clientID, type: type)
        {
            let myObject = project(projectID: Int(myItem.projectID),
                                    projectEndDate: myItem.projectEndDate! as Date,
                                    projectName: myItem.projectName!,
                                    projectStartDate: myItem.projectStartDate! as Date,
                                    projectStatus: myItem.projectStatus!,
                                    reviewFrequency: Int(myItem.reviewFrequency),
                                    lastReviewDate: myItem.lastReviewDate! as Date,
                                    GTDItemID: Int(myItem.areaID),
                                    repeatInterval: Int(myItem.repeatInterval),
                                    repeatType: myItem.repeatType!,
                                    repeatBase: myItem.repeatBase!,
                                    teamID: Int(myItem.teamID),
                                    clientID: Int(myItem.clientID),
                                    note: myItem.note!,
                                    reviewPeriod: myItem.reviewPeriod!,
                                    predecessor: Int(myItem.predecessor),
                                    clientDept: myItem.clientDept!,
                                    invoicingFrequency: myItem.invoicingFrequency!,
                                    invoicingDay: Int(myItem.invoicingDay),
                                    daysToPay: Int(myItem.daysToPay),
                                    type: myItem.type!)
                
            myProjects.append(myObject)
        }
        
        sortArrayByClient()
    }
    
    init(teamID: Int, includeEvents: Bool, type: String = "")
    {
        super.init()
        
        var returnArray: [Projects]!
        
        if includeEvents
        {
            returnArray = myDatabaseConnection.getProjects(teamID: teamID, type: type)
        }
        else
        {
            returnArray = myDatabaseConnection.getProjectsNotEvent(teamID: teamID)
        }
        
        for myItem in returnArray
        {
            let myObject = project(projectID: Int(myItem.projectID),
                                   projectEndDate: myItem.projectEndDate! as Date,
                                   projectName: myItem.projectName!,
                                   projectStartDate: myItem.projectStartDate! as Date,
                                   projectStatus: myItem.projectStatus!,
                                   reviewFrequency: Int(myItem.reviewFrequency),
                                   lastReviewDate: myItem.lastReviewDate! as Date,
                                   GTDItemID: Int(myItem.areaID),
                                   repeatInterval: Int(myItem.repeatInterval),
                                   repeatType: myItem.repeatType!,
                                   repeatBase: myItem.repeatBase!,
                                   teamID: Int(myItem.teamID),
                                   clientID: Int(myItem.clientID),
                                   note: myItem.note!,
                                   reviewPeriod: myItem.reviewPeriod!,
                                   predecessor: Int(myItem.predecessor),
                                   clientDept: myItem.clientDept!,
                                   invoicingFrequency: myItem.invoicingFrequency!,
                                   invoicingDay: Int(myItem.invoicingDay),
                                   daysToPay: Int(myItem.daysToPay),
                                   type: myItem.type!)

            
            myProjects.append(myObject)
        }
        
        if type != eventProjectType
        {
            sortArrayByClient()
        }
    }
    
    init(query: String, teamID: Int)
    {
        super.init()
        
        var returnArray: [Projects]!
        
        myProjects.removeAll()

        switch query
        {
            case "project type":
                returnArray = myDatabaseConnection.getProjectsWithNoType(teamID: teamID)
        
            case "project no start or end":
                returnArray = myDatabaseConnection.getProjectsWithNoStartOrEndDate(teamID: teamID)
                
            case "project no start":
                returnArray = myDatabaseConnection.getProjectsWithNoStartDate(teamID: teamID)
                
            case "project no end":
                returnArray = myDatabaseConnection.getProjectsWithNoEndDate(teamID: teamID)
            
            default:
                let _ = 1
        }
        
        if returnArray != nil
        {
            for myItem in returnArray
            {
                let myObject = project(projectID: Int(myItem.projectID),
                                       projectEndDate: myItem.projectEndDate! as Date,
                                       projectName: myItem.projectName!,
                                       projectStartDate: myItem.projectStartDate! as Date,
                                       projectStatus: myItem.projectStatus!,
                                       reviewFrequency: Int(myItem.reviewFrequency),
                                       lastReviewDate: myItem.lastReviewDate! as Date,
                                       GTDItemID: Int(myItem.areaID),
                                       repeatInterval: Int(myItem.repeatInterval),
                                       repeatType: myItem.repeatType!,
                                       repeatBase: myItem.repeatBase!,
                                       teamID: Int(myItem.teamID),
                                       clientID: Int(myItem.clientID),
                                       note: myItem.note!,
                                       reviewPeriod: myItem.reviewPeriod!,
                                       predecessor: Int(myItem.predecessor),
                                       clientDept: myItem.clientDept!,
                                       invoicingFrequency: myItem.invoicingFrequency!,
                                       invoicingDay: Int(myItem.invoicingDay),
                                       daysToPay: Int(myItem.daysToPay),
                                       type: myItem.type!)
                
                
                myProjects.append(myObject)
            }
            
            sortArrayByClient()
        }
    }

    private func sortArrayByName()
    {
        if myProjects.count > 0
        {
            myProjects.sort
            {
                if $0.projectName == $1.projectName
                {
                    return $0.clientID < $1.clientID
                }
                else
                {
                    return $0.projectName < $1.projectName
                }
            }
        }
    }

    private func sortArrayByClient()
    {
        if myProjects.count > 0
        {
            myProjects.sort
                {
                    if $0.clientID == $1.clientID
                    {
                        return $0.projectName < $1.projectName
                    }
                    else
                    {
                        return $0.clientID < $1.clientID
                    }
            }
        }
    }
    
    func sortOrder(by: String)
    {
        if by == "Name"
        {
            sortArrayByName()
        }
        else
        {
            sortArrayByClient()
        }
    }
    
    var projects: [project]
    {
        get
        {
            return myProjects
        }
    }
}

class project: NSObject // 10k level
{
    fileprivate var myProjectEndDate: Date!
    fileprivate var myProjectID: Int = 0
    fileprivate var myProjectName: String = ""
    fileprivate var myProjectStartDate: Date!
    fileprivate var myProjectStatus: String = ""
    fileprivate var myReviewFrequency: Int = 0
    fileprivate var myLastReviewDate: Date!
    fileprivate var myTeamMembers: [Int] = Array()
    fileprivate var myTasks: [task] = Array()
    fileprivate var myGTDItemID: Int = 0
    fileprivate var myRepeatInterval: Int = 0
    fileprivate var myRepeatType: String = ""
    fileprivate var myRepeatBase: String = ""
    fileprivate var myTeamID: Int = 0
    fileprivate var myNote: String = ""
    fileprivate var myReviewPeriod: String = ""
    fileprivate var myPredecessor: Int = 0
    fileprivate var saveCalled: Bool = false
    fileprivate var myClientID: Int = 0
    fileprivate var myClientDept: String = ""
    fileprivate var myInvoicingFrequency: String = ""
    fileprivate var myInvoicingDay: Int = 0
    fileprivate var myDaysToPay: Int = 0
    fileprivate var myType: String = ""
    
    var projectEndDate: Date
    {
        get
        {
            
            return myProjectEndDate
        }
        set
        {
            myProjectEndDate = newValue
        }
    }
    
    var type: String
    {
        get
        {
            
            return myType
        }
        set
        {
            myType = newValue
        }
    }
    
    var displayProjectEndDate: String
    {
        get
        {
            if myProjectEndDate == nil
            {
                myProjectEndDate = getDefaultDate() as Date!
                return ""
            }
            else if myProjectEndDate == getDefaultDate() as Date
            {
                return ""
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = DateFormatter.Style.medium
                return myDateFormatter.string(from: myProjectEndDate)
            }
        }
    }
    
    var projectID: Int
    {
        get
        {
            return myProjectID
        }
    }
    
    var projectName: String
    {
        get
        {
            return myProjectName
        }
        set
        {
            myProjectName = newValue
        }
    }
    
    var projectStartDate: Date
    {
        get
        {
            return myProjectStartDate
        }
        set
        {
            myProjectStartDate = newValue
        }
    }
    
    var teamMembers: [Int]
    {
        get
        {
            return myTeamMembers
        }
    }
    
    var tasks: [task]
    {
        get
        {
            return myTasks
        }
    }
    
    var displayProjectStartDate: String
    {
        get
        {
            if myProjectStartDate == nil
            {
                myProjectStartDate = getDefaultDate() as Date!
                return ""
            }
            else if myProjectStartDate == getDefaultDate() as Date
            {
                return ""
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = DateFormatter.Style.medium
                return myDateFormatter.string(from: myProjectStartDate)
            }
        }
    }
    
    var projectStatus: String
    {
        get
        {
            return myProjectStatus
        }
        set
        {
            myProjectStatus = newValue
            
            if newValue == "Archived"
            {
                checkForRepeat()
            }
        }
    }
    
    var reviewFrequency: Int
    {
        get
        {
            return myReviewFrequency
        }
        set
        {
            myReviewFrequency = newValue
        }
    }
    
    var lastReviewDate: Date
    {
        get
        {
            return myLastReviewDate
        }
        set
        {
            myLastReviewDate = newValue
        }
    }
    
    var displayLastReviewDate: String
    {
        get
        {
            if myLastReviewDate == nil
            {
                myLastReviewDate = getDefaultDate() as Date!
                return ""
            }
            else if myLastReviewDate == getDefaultDate() as Date
            {
                return ""
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = DateFormatter.Style.medium
                return myDateFormatter.string(from: myLastReviewDate)
            }
        }
    }
    
    var reviewPeriod: String
    {
        get
        {
            return myReviewPeriod
        }
        set
        {
            myReviewPeriod = newValue
        }
    }
    
    var GTDItemID: Int
    {
        get
        {
            return myGTDItemID
        }
        set
        {
            myGTDItemID = newValue
        }
    }
    
    var repeatInterval: Int
    {
        get
        {
            return myRepeatInterval
        }
        set
        {
            myRepeatInterval = newValue
        }
    }
    
    var repeatType: String
    {
        get
        {
            return myRepeatType
        }
        set
        {
            myRepeatType = newValue
        }
    }
    
    var repeatBase: String
    {
        get
        {
            return myRepeatBase
        }
        set
        {
            myRepeatBase = newValue
        }
    }
    
    var teamID: Int
    {
        get
        {
            return myTeamID
        }
        set
        {
            myTeamID = newValue
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
    
    var clientID: Int
    {
        get
        {
            return myClientID
        }
        set
        {
            myClientID = newValue
        }
    }
    
    var clientDept: String
    {
        get
        {
            return myClientDept
        }
        set
        {
            myClientDept = newValue
        }
    }
    
    var invoicingFrequency: String
    {
        get
        {
            return myInvoicingFrequency
        }
        set
        {
            myInvoicingFrequency = newValue
        }
    }
    
    var invoicingDay: Int
    {
        get
        {
            return myInvoicingDay
        }
        set
        {
            myInvoicingDay = newValue
        }
    }
    
    var daysToPay: Int
    {
        get
        {
            return myDaysToPay
        }
        set
        {
            myDaysToPay = newValue
        }
    }
    
    var staff: shifts?
    {
        get
        {
            return shifts(projectID: myProjectID)
        }
    }
    
    init(teamID: Int)
    {
        super.init()
        
        myProjectID = myDatabaseConnection.getNextID("Projects")
        
        // Set dates to a really daft value so that it stores into the database
        
        myProjectEndDate = getDefaultDate() as Date!
        myProjectStartDate = getDefaultDate() as Date!
        myLastReviewDate = getDefaultDate() as Date!
        myTeamID = teamID
        myType = type
        
        save()
    }
    
    init(projectID: Int)
    {
        super.init()
        
        // GRE whatever calls projects should check to make sure it is not marked as "Archived", as we are not deleting Projects, only marking them as archived
        let myProjects = myDatabaseConnection.getProjectDetails(projectID)
        
        for myProject in myProjects
        {
            myProjectEndDate = myProject.projectEndDate! as Date
            myProjectID = Int(myProject.projectID)
            myProjectName = myProject.projectName!
            myProjectStartDate = myProject.projectStartDate! as Date
            myProjectStatus = myProject.projectStatus!
            myReviewFrequency = Int(myProject.reviewFrequency)
            myLastReviewDate = myProject.lastReviewDate! as Date
            myGTDItemID = Int(myProject.areaID)
            myRepeatInterval = Int(myProject.repeatInterval)
            myRepeatType = myProject.repeatType!
            myRepeatBase = myProject.repeatBase!
            myTeamID = Int(myProject.teamID)
            myClientID = Int(myProject.clientID)
            myNote = myProject.note!
            myReviewPeriod = myProject.reviewPeriod!
            myPredecessor = Int(myProject.predecessor)
            myClientDept = myProject.clientDept!
            myInvoicingFrequency = myProject.invoicingFrequency!
            myInvoicingDay = Int(myProject.invoicingDay)
            myDaysToPay = Int(myProject.daysToPay)
            myType = myProject.type!
            
            // load team members
            
  //          loadTeamMembers()
            
            // load tasks
            
            loadTasks()
        }
    }

    init(projectID: Int, projectEndDate: Date, projectName: String, projectStartDate: Date, projectStatus: String, reviewFrequency: Int, lastReviewDate: Date, GTDItemID: Int, repeatInterval: Int, repeatType: String, repeatBase: String, teamID: Int, clientID: Int, note: String, reviewPeriod: String, predecessor: Int, clientDept: String, invoicingFrequency: String, invoicingDay: Int, daysToPay: Int, type: String)
    {
        super.init()
        myProjectEndDate = projectEndDate
        myProjectID = projectID
        myProjectName = projectName
        myProjectStartDate = projectStartDate
        myProjectStatus = projectStatus
        myReviewFrequency = reviewFrequency
        myLastReviewDate = lastReviewDate
        myGTDItemID = GTDItemID
        myRepeatInterval = repeatInterval
        myRepeatType = repeatType
        myRepeatBase = repeatBase
        myTeamID = teamID
        myClientID = clientID
        myNote = note
        myReviewPeriod = reviewPeriod
        myPredecessor = predecessor
        myClientDept = clientDept
        myInvoicingFrequency = invoicingFrequency
        myInvoicingDay = invoicingDay
        myDaysToPay = daysToPay
        myType = type
        
        // load team members
        
//        loadTeamMembers()
        
        // load tasks
        
        loadTasks()
    }

//    func loadTeamMembers()
//    {
//        myTeamMembers.removeAll()
//        
//        let myProjectTeamMembers = myDatabaseConnection.getTeamMembers(myProjectID)
//        
//        for myTeamMember in myProjectTeamMembers
//        {
//            let myMember = projectTeamMember(projectID: Int(myTeamMember.projectID), teamMember: myTeamMember.teamMember!, roleID: Int(myTeamMember.roleID), teamID: myTeamID)
//            
//            myMember.projectMemberNotes = myTeamMember.projectMemberNotes!
//            
//            myTeamMembers.append(myMember)
//        }
//    }
    
    func addTask(_ taskItem: task)
    {
        taskItem.projectID = myProjectID
        
        loadTasks()
    }
    
    func removeTask(_ taskItem: task)
    {
        taskItem.projectID = 0
        loadTasks()
    }
    
    func loadTasks()
    {
        myTasks.removeAll()
        
        let myProjectTasks = myDatabaseConnection.getTasksForProject(myProjectID)
        
        for myProjectTask in myProjectTasks
        {
            let myNewTask = task(taskID: Int(myProjectTask.taskID))
            myTasks.append(myNewTask)
        }
    }
 
    func save()
    {
        myDatabaseConnection.saveProject(myProjectID,
                                         projectEndDate: myProjectEndDate,
                                         projectName: myProjectName,
                                         projectStartDate: myProjectStartDate,
                                         projectStatus: myProjectStatus,
                                         reviewFrequency: myReviewFrequency,
                                         lastReviewDate: myLastReviewDate,
                                         GTDItemID: myGTDItemID,
                                         repeatInterval: myRepeatInterval,
                                         repeatType: myRepeatType,
                                         repeatBase: myRepeatBase,
                                         teamID: myTeamID,
                                         clientID: myClientID,
                                         note: myNote,
                                         reviewPeriod: myReviewPeriod,
                                         predecessor: myPredecessor,
                                         clientDept: myClientDept,
                                         invoicingFrequency: myInvoicingFrequency,
                                         invoicingDay: myInvoicingDay,
                                         daysToPay: myDaysToPay,
                                         type: myType)
        
        // Save Team Members
        
//        for myMember in myTeamMembers
//        {
//            myMember.save()
//        }
//        
        // Save Tasks
        
        for myProjectTask in myTasks
        {
            myProjectTask.save()
        }
    }
    
    func performSave()
    {
        // Save Project
        
        let myProject = myDatabaseConnection.getProjectDetails(myProjectID)[0]
        
        myCloudDB.saveProjectsRecordToCloudKit(myProject, teamID: currentUser.currentTeam!.teamID)
        
        saveCalled = false
    }
    
    func checkForRepeat()
    {
        // Check to see if there is a repeat pattern
        var tempStartDate: Date = getDefaultDate() as Date
        var tempEndDate: Date = getDefaultDate() as Date
        
        if myRepeatInterval != 0
        {
            // Calculate new start and end dates, based on the repeat fields
            
            if myProjectStartDate == getDefaultDate() as Date && myProjectEndDate == getDefaultDate() as Date
            {  // No dates have set, so we set the start date
                tempStartDate = calculateNewDate(Date(), dateBase:myRepeatBase, interval: Int16(myRepeatInterval), period: myRepeatType)
            }
            else
            { // A date has been set in at least one of the fields, so we use that as the date to set
                
                // If both start and end dates are set then we want to make sure we keep interval between them the same, so we need to work out the time to add
                
                var daysToAdd: Int = 0
                
                if myProjectStartDate != getDefaultDate() as Date && myProjectEndDate != getDefaultDate() as Date
                {
                    let calendar = Calendar.current
                    
                    let components = calendar.dateComponents([.day], from: myProjectStartDate, to: myProjectEndDate)
                    
                    daysToAdd = components.day!
                }
                
                if myProjectStartDate != getDefaultDate() as Date
                {
                    tempStartDate = calculateNewDate(Date(), dateBase:myRepeatBase, interval: Int16(myRepeatInterval), period: myRepeatType)
                }
                
                if myProjectEndDate != getDefaultDate() as Date
                {
                    let calendar = Calendar.current
                    
                    let tempDate = calendar.date(
                        byAdding: .day,
                        value: daysToAdd,
                        to: Date())!
                    
                    tempEndDate = calculateNewDate(tempDate, dateBase:myRepeatBase, interval: Int16(myRepeatInterval), period: myRepeatType)
                }
            }
            
            // Create new Project
            
            let newProject = project(teamID: myTeamID)
            newProject.type = myType
            newProject.projectEndDate = tempEndDate
            newProject.projectName = myProjectName
            newProject.projectStartDate = tempStartDate
            newProject.GTDItemID = myGTDItemID
            newProject.repeatInterval = myRepeatInterval
            newProject.repeatType = myRepeatType
            newProject.repeatBase = myRepeatBase
            newProject.note = myNote
            newProject.clientID = myClientID
            newProject.clientDept = myClientDept
            newProject.invoicingFrequency = myInvoicingFrequency
            newProject.invoicingDay = myInvoicingDay
            newProject.daysToPay = myDaysToPay
            
            // Populate team Members
            
//            let myProjectTeamMembers = myDatabaseConnection.getTeamMembers(myProjectID)
            
//            for myTeamMember in myProjectTeamMembers
//            {
//                let myMember = projectTeamMember(projectID: newProject.projectID, teamMember: myTeamMember.teamMember!, roleID: Int(myTeamMember.roleID), teamID: myTeamID)
//                
//                myMember.projectMemberNotes = myTeamMember.projectMemberNotes!
//            }
            
            // Populate tasks, but have the marked as Open
            
            let myProjectTasks = myDatabaseConnection.getAllTasksForProject(myProjectID, teamID: myTeamID)
            
            for myProjectTask in myProjectTasks
            {
                let myNewTask = task(teamID: myTeamID)
                
                myNewTask.title = myProjectTask.title!
                myNewTask.details = myProjectTask.details!
                myNewTask.status = "Open"
                myNewTask.priority = myProjectTask.priority!
                myNewTask.energyLevel = myProjectTask.energyLevel!
                myNewTask.estimatedTime = Int(myProjectTask.estimatedTime)
                myNewTask.estimatedTimeType = myProjectTask.estimatedTimeType!
                myNewTask.projectID = newProject.projectID
                myNewTask.repeatInterval = Int(myProjectTask.repeatInterval)
                myNewTask.repeatType = myProjectTask.repeatType!
                myNewTask.repeatBase = myProjectTask.repeatBase!
                myNewTask.flagged = myProjectTask.flagged as! Bool
                myNewTask.urgency = myProjectTask.urgency!

//                let myContextList = myDatabaseConnection.getContextsForTask(Int(myProjectTask.taskID))
//                
//                for myContextItem in myContextList
//                {
//                    myNewTask.addContext(Int(myContextItem.contextID))
//                }
            }
        }
    }
    
    func delete() -> Bool
    {
        if myTasks.count > 0
        {
            return false
        }
        else
        {
            myProjectStatus = "Deleted"
            save()
            
            // Need to see if this is in a predessor tree, if it is then we need to update so that this is skipped
            
            // Go and see if another item has set as its predecessor
            
            let fromCurrentPredecessor = myDatabaseConnection.getProjectSuccessor(myProjectID)
            
            if fromCurrentPredecessor > 0
            {  // This item is a predecessor
                let tempSuccessor = project(projectID: fromCurrentPredecessor)
                tempSuccessor.predecessor = myPredecessor
            }
            return true
        }
    }
}

extension coreDatabase
{
    func getOpenProjectsForGTDItem(_ GTDItemID: Int, teamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (areaID == \(GTDItemID)) && (updateType != \"Delete\") && (teamID == \(teamID))")
        
        let sortDescriptor = NSSortDescriptor(key: "projectID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
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
            print("Error ocurred during execution: \(error)")
            return []
        }
    }
    
    func getProjectDetails(_ projectID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
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
    
    func getProjectSuccessor(_ projectID: Int)->Int
    {
        
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(predecessor == \(projectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return Int(fetchResults[0].projectID)
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }

    func getAllProjects(_ teamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of objects
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
    
    func getProjectCount()->Int
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
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

    func getProjects(teamID: Int, type: String, archiveFlag: Bool = false) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.

        var predicate: NSPredicate

        if !archiveFlag
        {
            if type == ""
            {
                predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (teamID == \(teamID))")
            }
            else
            {
                predicate = NSPredicate(format: "(type == \"\(type)\") AND (projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (teamID == \(teamID))")
            }
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
        }
        else
        {
            // Create a new predicate that filters out any object that
            // doesn't have a title of "Best Language" exactly.
            if type == ""
            {
                predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID))")
            }
            else
            {
                predicate = NSPredicate(format: "(type == \"\(type)\") AND (updateType != \"Delete\") && (teamID == \(teamID))")
            }
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
        }
        
        let sortDescriptor = NSSortDescriptor(key: "projectStartDate", ascending: true)
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
    
    func getInDateProjectsForTeam(_ teamID: Int, archiveFlag: Bool = false) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        if !archiveFlag
        {
            var predicate: NSPredicate

            predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (teamID == \(teamID)) AND ((projectStartDate == nil) OR (projectStartDate <= %@) OR (projectStartDate == %@)) AND ((projectEndDate == nil) OR (projectEndDate >= %@) OR (projectEndDate == %@))", Date() as CVarArg, getDefaultDate() as CVarArg, Date() as CVarArg, getDefaultDate() as CVarArg)
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
        }
        else
        {
            // Create a new predicate that filters out any object that
            // doesn't have a title of "Best Language" exactly.
            let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID))")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
        }
        
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

    
    func getProjects(clientID: Int, type: String) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        if type == ""
        {
            predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (clientID == \(clientID))")
        }
        else
        {
            predicate = NSPredicate(format: "(type == \"\(type)\") AND (projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (clientID == \(clientID))")
        }
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

    func getProjectsWithNoType(teamID: Int) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (teamID == \(teamID)) AND (type = \"\")")
        
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

    func getProjectsWithNoStartOrEndDate(teamID: Int) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (teamID == \(teamID)) AND (projectStartDate == %@) AND (projectEndDate == %@)", getDefaultDate() as CVarArg, getDefaultDate() as CVarArg)
        
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

    func getProjectsWithNoStartDate(teamID: Int) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (teamID == \(teamID)) AND (projectStartDate == %@) AND (projectEndDate != %@)", getDefaultDate() as CVarArg, getDefaultDate() as CVarArg)
        
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
    
    func getProjectsWithNoEndDate(teamID: Int) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (teamID == \(teamID)) AND (projectStartDate != %@) AND (projectEndDate == %@)", getDefaultDate() as CVarArg, getDefaultDate() as CVarArg)
        
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
    
    func getProjectsNotEvent(teamID: Int) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (teamID == \(teamID)) AND (type != \"\(eventProjectType)\")")
        
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
    
    func saveProject(_ projectID: Int, projectEndDate: Date, projectName: String, projectStartDate: Date, projectStatus: String, reviewFrequency: Int, lastReviewDate: Date, GTDItemID: Int, repeatInterval: Int, repeatType: String, repeatBase: String, teamID: Int, clientID: Int, note: String, reviewPeriod: String, predecessor: Int, clientDept: String, invoicingFrequency: String, invoicingDay: Int, daysToPay: Int, type: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myProject: Projects!
        
        let myProjects = getProjectDetails(projectID)
        
        if myProjects.count == 0
        { // Add
            myProject = Projects(context: objectContext)
            myProject.projectID = Int64(projectID)
            myProject.projectEndDate = projectEndDate as NSDate
            myProject.projectName = projectName
            myProject.projectStartDate = projectStartDate as NSDate
            myProject.projectStatus = projectStatus
            myProject.reviewFrequency = Int64(reviewFrequency)
            myProject.lastReviewDate = lastReviewDate as NSDate
            myProject.areaID = Int64(GTDItemID)
            myProject.repeatInterval = Int64(repeatInterval)
            myProject.repeatType = repeatType
            myProject.repeatBase = repeatBase
            myProject.teamID = Int64(teamID)
            myProject.clientID = Int64(clientID)
            myProject.note = note
            myProject.reviewPeriod = reviewPeriod
            myProject.predecessor = Int64(predecessor)
            myProject.clientDept = clientDept
            myProject.invoicingFrequency = invoicingFrequency
            myProject.invoicingDay = Int64(invoicingDay)
            myProject.daysToPay = Int64(daysToPay)
            myProject.type = type
            
            if updateType == "CODE"
            {
                myProject.updateTime =  NSDate()
                myProject.updateType = "Add"
            }
            else
            {
                myProject.updateTime = updateTime as NSDate
                myProject.updateType = updateType
            }
        }
        else
        { // Update
            myProject = myProjects[0]
            myProject.projectEndDate = projectEndDate as NSDate
            myProject.projectName = projectName
            myProject.projectStartDate = projectStartDate as NSDate
            myProject.projectStatus = projectStatus
            myProject.reviewFrequency = Int64(reviewFrequency)
            myProject.lastReviewDate = lastReviewDate as NSDate
            myProject.areaID = Int64(GTDItemID)
            myProject.repeatInterval = Int64(repeatInterval)
            myProject.repeatType = repeatType
            myProject.repeatBase = repeatBase
            myProject.teamID = Int64(teamID)
            myProject.clientID = Int64(clientID)
            myProject.note = note
            myProject.reviewPeriod = reviewPeriod
            myProject.predecessor = Int64(predecessor)
            myProject.clientDept = clientDept
            myProject.invoicingFrequency = invoicingFrequency
            myProject.invoicingDay = Int64(invoicingDay)
            myProject.daysToPay = Int64(daysToPay)
            myProject.type = type
            
            if updateType == "CODE"
            {
                myProject.updateTime =  NSDate()
                if myProject.updateType != "Add"
                {
                    myProject.updateType = "Update"
                }
            }
            else
            {
                myProject.updateTime = updateTime as NSDate
                myProject.updateType = updateType
            }
        }
        
        saveContext()
    }
    
    func replaceProject(_ projectID: Int, projectEndDate: Date, projectName: String, projectStartDate: Date, projectStatus: String, reviewFrequency: Int, lastReviewDate: Date, GTDItemID: Int, repeatInterval: Int, repeatType: String, repeatBase: String, teamID: Int, clientID: Int, note: String, reviewPeriod: String, predecessor: Int, clientDept: String, invoicingFrequency: String, invoicingDay: Int, daysToPay: Int, type: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        
        let myProject = Projects(context: objectContext)
        myProject.projectID = Int64(projectID)
        myProject.projectEndDate = projectEndDate as NSDate
        myProject.projectName = projectName
        myProject.projectStartDate = projectStartDate as NSDate
        myProject.projectStatus = projectStatus
        myProject.reviewFrequency = Int64(reviewFrequency)
        myProject.lastReviewDate = lastReviewDate as NSDate
        myProject.areaID = Int64(GTDItemID)
        myProject.repeatInterval = Int64(repeatInterval)
        myProject.repeatType = repeatType
        myProject.repeatBase = repeatBase
        myProject.teamID = Int64(teamID)
        myProject.clientID = Int64(clientID)
        myProject.note = note
        myProject.reviewPeriod = reviewPeriod
        myProject.predecessor = Int64(predecessor)
        myProject.clientDept = clientDept
        myProject.invoicingFrequency = invoicingFrequency
        myProject.invoicingDay = Int64(invoicingDay)
        myProject.daysToPay = Int64(daysToPay)
        myProject.type = type
        
        if updateType == "CODE"
        {
            myProject.updateTime =  NSDate()
            myProject.updateType = "Add"
        }
        else
        {
            myProject.updateTime = updateTime as NSDate
            myProject.updateType = updateType
        }
        
        saveContext()
    }
    
    func deleteProject(_ projectID: Int, teamID: Int)
    {
        var myProject: Projects!
        
        let myProjects = getProjectDetails(projectID)
        
        if myProjects.count > 0
        { // Update
            myProject = myProjects[0]
            myProject.updateTime =  NSDate()
            myProject.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func resetProjectRecords()
    {
        let fetchRequest2 = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Execute the fetch request, and cast the results to an array of objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myStage in fetchResults2
            {
                myStage.updateTime =  NSDate()
                myStage.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func clearDeletedProjects(predicate: NSPredicate)
    {
        let fetchRequest11 = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Set the predicate on the fetch request
        fetchRequest11.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults11 = try objectContext.fetch(fetchRequest11)
            for myItem11 in fetchResults11
            {
                objectContext.delete(myItem11 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedProjects(predicate: NSPredicate)
    {
        let fetchRequest11 = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Set the predicate on the fetch request
        fetchRequest11.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults11 = try objectContext.fetch(fetchRequest11)
            for myItem11 in fetchResults11
            {
                myItem11.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func initialiseTeamForProject(_ teamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        let sortDescriptor = NSSortDescriptor(key: "projectID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            {
                for myItem in fetchResults
                {
                    myItem.teamID = Int64(teamID)
                    maxID = Int(myItem.projectID)
                }
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Projects", codeValue: tempInt, codeType: "hidden", decode_privacy: "Public")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func getProjectsForSync(_ syncDate: Date) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
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

    func deleteAllProjectRecords()
    {
        let fetchRequest11 = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults11 = try objectContext.fetch(fetchRequest11)
            for myItem11 in fetchResults11
            {
                self.objectContext.delete(myItem11 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func quickFixProjects()
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")

        let predicate = NSPredicate(format: "(type = \"Regular\")")
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myProject in fetchResults
            {
                myProject.type = "Regular"
                myProject.updateTime = NSDate()
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
    func saveProjectsToCloudKit()
    {
        for myItem in myDatabaseConnection.getProjectsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Projects"))
        {
            saveProjectsRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }

    func updateProjectsInCoreData(teamID: Int)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "Projects") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        while waitFlag
        {
            usleep(self.sleepTime)
        }
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            while self.recordCount > 0
            {
                usleep(self.sleepTime)
            }
            
            self.recordCount += 1

            self.updateProjectsRecord(record)
            self.recordCount -= 1

//            usleep(self.sleepTime)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Projects", queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func deleteProjects(teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
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

    func replaceProjectsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let projectID = record.object(forKey: "projectID") as! Int
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
            let areaID = record.object(forKey: "areaID") as! Int
            let lastReviewDate = record.object(forKey: "lastReviewDate") as! Date
            let projectEndDate = record.object(forKey: "projectEndDate") as! Date
            let projectName = record.object(forKey: "projectName") as! String
            let projectStartDate = record.object(forKey: "projectStartDate") as! Date
            let projectStatus = record.object(forKey: "projectStatus") as! String
            let repeatBase = record.object(forKey: "repeatBase") as! String
            let repeatInterval = record.object(forKey: "repeatInterval") as! Int
            let repeatType = record.object(forKey: "repeatType") as! String
            let reviewFrequency = record.object(forKey: "reviewFrequency") as! Int
            let teamID = record.object(forKey: "teamID") as! Int
            let note = record.object(forKey: "note") as! String
            let reviewPeriod = record.object(forKey: "reviewPeriod") as! String
            let predecessor = record.object(forKey: "predecessor") as! Int
            let type = record.object(forKey: "type") as! String
            
            var clientID: Int = 0
            
            if record.object(forKey: "clientID") != nil
            {
                clientID = record.object(forKey: "clientID") as! Int
            }
            
            let clientDept = record.object(forKey: "clientDept") as! String
            let invoicingFrequency = record.object(forKey: "invoicingFrequency") as! String
            
            var invoicingDay: Int = 0
            if record.object(forKey: "invoicingDay") != nil
            {
                invoicingDay = record.object(forKey: "invoicingDay") as! Int
            }
            var daysToPay: Int = 0
            if record.object(forKey: "daysToPay") != nil
            {
                daysToPay = record.object(forKey: "daysToPay") as! Int
            }

            myDatabaseConnection.replaceProject(projectID, projectEndDate: projectEndDate, projectName: projectName, projectStartDate: projectStartDate, projectStatus: projectStatus, reviewFrequency: reviewFrequency, lastReviewDate: lastReviewDate, GTDItemID: areaID, repeatInterval: repeatInterval, repeatType: repeatType, repeatBase: repeatBase, teamID: teamID, clientID: clientID, note: note, reviewPeriod: reviewPeriod, predecessor: predecessor, clientDept: clientDept, invoicingFrequency: invoicingFrequency, invoicingDay: invoicingDay, daysToPay:daysToPay, type: type, updateTime: updateTime, updateType: updateType)

            usleep(self.sleepTime)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Projects", queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveProjectsRecordToCloudKit(_ sourceRecord: Projects, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID)) AND \(buildTeamList(currentUser.userID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Projects", predicate: predicate)
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
                    record!.setValue(sourceRecord.areaID, forKey: "areaID")
                    record!.setValue(sourceRecord.lastReviewDate, forKey: "lastReviewDate")
                    record!.setValue(sourceRecord.projectEndDate, forKey: "projectEndDate")
                    record!.setValue(sourceRecord.projectName, forKey: "projectName")
                    record!.setValue(sourceRecord.projectStartDate, forKey: "projectStartDate")
                    record!.setValue(sourceRecord.projectStatus, forKey: "projectStatus")
                    record!.setValue(sourceRecord.repeatBase, forKey: "repeatBase")
                    record!.setValue(sourceRecord.repeatInterval, forKey: "repeatInterval")
                    record!.setValue(sourceRecord.repeatType, forKey: "repeatType")
                    record!.setValue(sourceRecord.reviewFrequency, forKey: "reviewFrequency")
                    record!.setValue(sourceRecord.teamID, forKey: "teamID")
                    record!.setValue(sourceRecord.note, forKey: "note")
                    record!.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                    record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record!.setValue(sourceRecord.clientID, forKey: "clientID")
                    record!.setValue(sourceRecord.clientDept, forKey: "clientDept")
                    record!.setValue(sourceRecord.invoicingFrequency, forKey: "invoicingFrequency")
                    record!.setValue(sourceRecord.invoicingDay, forKey: "invoicingDay")
                    record!.setValue(sourceRecord.daysToPay, forKey: "daysToPay")
                    record!.setValue(sourceRecord.type, forKey: "type")

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
                    let record = CKRecord(recordType: "Projects")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.areaID, forKey: "areaID")
                    record.setValue(sourceRecord.lastReviewDate, forKey: "lastReviewDate")
                    record.setValue(sourceRecord.projectEndDate, forKey: "projectEndDate")
                    record.setValue(sourceRecord.projectName, forKey: "projectName")
                    record.setValue(sourceRecord.projectStartDate, forKey: "projectStartDate")
                    record.setValue(sourceRecord.projectStatus, forKey: "projectStatus")
                    record.setValue(sourceRecord.repeatBase, forKey: "repeatBase")
                    record.setValue(sourceRecord.repeatInterval, forKey: "repeatInterval")
                    record.setValue(sourceRecord.repeatType, forKey: "repeatType")
                    record.setValue(sourceRecord.reviewFrequency, forKey: "reviewFrequency")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.note, forKey: "note")
                    record.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                    record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    record.setValue(sourceRecord.clientID, forKey: "clientID")
                    record.setValue(sourceRecord.clientDept, forKey: "clientDept")
                    record.setValue(sourceRecord.invoicingFrequency, forKey: "invoicingFrequency")
                    record.setValue(sourceRecord.invoicingDay, forKey: "invoicingDay")
                    record.setValue(sourceRecord.daysToPay, forKey: "daysToPay")
                    record.setValue(sourceRecord.type, forKey: "type")
                    
                    record.setValue(teamID, forKey: "teamID")
                    
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

    func updateProjectsRecord(_ sourceRecord: CKRecord)
    {
        let projectID = sourceRecord.object(forKey: "projectID") as! Int
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
        let areaID = sourceRecord.object(forKey: "areaID") as! Int
        let lastReviewDate = sourceRecord.object(forKey: "lastReviewDate") as! Date
        let projectEndDate = sourceRecord.object(forKey: "projectEndDate") as! Date
        let projectName = sourceRecord.object(forKey: "projectName") as! String
        let projectStartDate = sourceRecord.object(forKey: "projectStartDate") as! Date
        let projectStatus = sourceRecord.object(forKey: "projectStatus") as! String
        let repeatBase = sourceRecord.object(forKey: "repeatBase") as! String
        let repeatInterval = sourceRecord.object(forKey: "repeatInterval") as! Int
        let repeatType = sourceRecord.object(forKey: "repeatType") as! String
        let reviewFrequency = sourceRecord.object(forKey: "reviewFrequency") as! Int
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        let note = sourceRecord.object(forKey: "note") as! String
        let reviewPeriod = sourceRecord.object(forKey: "reviewPeriod") as! String
        let predecessor = sourceRecord.object(forKey: "predecessor") as! Int
        let type = sourceRecord.object(forKey: "type") as! String

        var clientID: Int = 0
        
        if sourceRecord.object(forKey: "clientID") != nil
        {
            clientID = sourceRecord.object(forKey: "clientID") as! Int
        }
        
        let clientDept = sourceRecord.object(forKey: "clientDept") as! String
        let invoicingFrequency = sourceRecord.object(forKey: "invoicingFrequency") as! String
        
        var invoicingDay: Int = 0
        if sourceRecord.object(forKey: "invoicingDay") != nil
        {
            invoicingDay = sourceRecord.object(forKey: "invoicingDay") as! Int
        }
        var daysToPay: Int = 0
        if sourceRecord.object(forKey: "daysToPay") != nil
        {
            daysToPay = sourceRecord.object(forKey: "daysToPay") as! Int
        }
        
        myDatabaseConnection.saveProject(projectID, projectEndDate: projectEndDate, projectName: projectName, projectStartDate: projectStartDate, projectStatus: projectStatus, reviewFrequency: reviewFrequency, lastReviewDate: lastReviewDate, GTDItemID: areaID, repeatInterval: repeatInterval, repeatType: repeatType, repeatBase: repeatBase, teamID: teamID, clientID: clientID, note: note, reviewPeriod: reviewPeriod, predecessor: predecessor, clientDept: clientDept, invoicingFrequency: invoicingFrequency, invoicingDay: invoicingDay, daysToPay:daysToPay, type: type, updateTime: updateTime, updateType: updateType)
    }
}
