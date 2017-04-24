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

class project: NSObject // 10k level
{
    fileprivate var myProjectEndDate: Date!
    fileprivate var myProjectID: Int = 0
    fileprivate var myProjectName: String = "New project"
    fileprivate var myProjectStartDate: Date!
    fileprivate var myProjectStatus: String = ""
    fileprivate var myReviewFrequency: Int = 0
    fileprivate var myLastReviewDate: Date!
    fileprivate var myTeamMembers: [projectTeamMember] = Array()
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
    
    var projectEndDate: Date
    {
        get
        {
            
            return myProjectEndDate
        }
        set
        {
            myProjectEndDate = newValue
            save()
        }
    }
    
    var displayProjectEndDate: String
    {
        get
        {
            if myProjectEndDate == nil
            {
                myProjectEndDate = getDefaultDate() as Date!
                save()
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
            save()
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
            save()
        }
    }
    
    var teamMembers: [projectTeamMember]
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
                save()
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
            
            if newValue == "Archived" || newValue == "Completed"
            {
                checkForRepeat()
            }
            save()
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
            save()
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
            save()
        }
    }
    
    var displayLastReviewDate: String
    {
        get
        {
            if myLastReviewDate == nil
            {
                myLastReviewDate = getDefaultDate() as Date!
                save()
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
        }
    }
    
    init(inTeamID: Int)
    {
        super.init()
        
        myProjectID = myDatabaseConnection.getNextID("Projects")
        
        // Set dates to a really daft value so that it stores into the database
        
        myProjectEndDate = getDefaultDate() as Date!
        myProjectStartDate = getDefaultDate() as Date!
        myLastReviewDate = getDefaultDate() as Date!
        myTeamID = inTeamID
        
        save()
    }
    
    init(inProjectID: Int)
    {
        super.init()
        
        // GRE whatever calls projects should check to make sure it is not marked as "Archived", as we are not deleting Projects, only marking them as archived
        let myProjects = myDatabaseConnection.getProjectDetails(inProjectID)
        
        for myProject in myProjects
        {
            myProjectEndDate = myProject.projectEndDate
            myProjectID = myProject.projectID as! Int
            myProjectName = myProject.projectName
            myProjectStartDate = myProject.projectStartDate
            myProjectStatus = myProject.projectStatus
            myReviewFrequency = myProject.reviewFrequency as! Int
            myLastReviewDate = myProject.lastReviewDate
            myGTDItemID = myProject.areaID as! Int
            myRepeatInterval = myProject.repeatInterval as! Int
            myRepeatType = myProject.repeatType
            myRepeatBase = myProject.repeatBase
            myTeamID = myProject.teamID as! Int
            
            // load team members
            
            loadTeamMembers()
            
            // load tasks
            
            loadTasks()
            
            // Get project Note
            
            let myNotes = myDatabaseConnection.getProjectNote(myProjectID)
            
            if myNotes.count == 0
            {
                myNote = ""
                myReviewPeriod = ""
                myPredecessor = 0
            }
            else
            {
                for myItem in myNotes
                {
                    myNote = myItem.note
                    myReviewPeriod = myItem.reviewPeriod
                    myPredecessor = myItem.predecessor as! Int
                }
            }
        }
    }
    
    func loadTeamMembers()
    {
        myTeamMembers.removeAll()
        
        let myProjectTeamMembers = myDatabaseConnection.getTeamMembers(NSNumber(value: myProjectID))
        
        for myTeamMember in myProjectTeamMembers
        {
            let myMember = projectTeamMember(inProjectID: myTeamMember.projectID as! Int, inTeamMember: myTeamMember.teamMember, inRoleID: myTeamMember.roleID as! Int, inTeamID: myTeamID )
            
            myMember.projectMemberNotes = myTeamMember.projectMemberNotes
            
            // Due to an error I am commenting this out, not using this field at the moment, so hopefully will not be an issue
            //  println("name \(myTeamMember.teamMember)")
            
            //    if myTeamMember.projectMemberNotes == ""
            //  {
            //        println("its nil")
            //    }
            //println("incoming \(myTeamMember.projectMemberNotes)")
            //println("new \(myMember.projectMemberNotes)")
            
            //               myMember.projectMemberNotes = myTeamMember.projectMemberNotes
            
            myTeamMembers.append(myMember)
        }
    }
    
    func addTask(_ inTask: task)
    {
        inTask.projectID = myProjectID
        
        loadTasks()
    }
    
    func removeTask(_ inTask: task)
    {
        inTask.projectID = 0
        loadTasks()
    }
    
    func loadTasks()
    {
        myTasks.removeAll()
        
        let myProjectTasks = myDatabaseConnection.getTasksForProject(myProjectID)
        
        for myProjectTask in myProjectTasks
        {
            let myNewTask = task(taskID: myProjectTask.taskID as! Int)
            myTasks.append(myNewTask)
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveProject(myProjectID, inProjectEndDate: myProjectEndDate, inProjectName: myProjectName, inProjectStartDate: myProjectStartDate, inProjectStatus: myProjectStatus, inReviewFrequency: myReviewFrequency, inLastReviewDate: myLastReviewDate, inGTDItemID: myGTDItemID, inRepeatInterval: myRepeatInterval, inRepeatType: myRepeatType, inRepeatBase: myRepeatBase, inTeamID: myTeamID)
        
        // Save Team Members
        
        for myMember in myTeamMembers
        {
            myMember.save()
        }
        
        // Save Tasks
        
        for myProjectTask in myTasks
        {
            myProjectTask.save()
        }
        
        // save note
        
        myDatabaseConnection.saveProjectNote(myProjectID, inNote: myNote, inReviewPeriod: myReviewPeriod, inPredecessor: myPredecessor)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(workingGTDLevel.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        // Save Project
        
        let myProject = myDatabaseConnection.getProjectDetails(myProjectID)[0]
        
        myCloudDB.saveProjectsRecordToCloudKit(myProject)
        
        let myProjectNote = myDatabaseConnection.getProjectNote(myProjectID)[0]
        
        myCloudDB.saveProjectNoteRecordToCloudKit(myProjectNote)
        
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
                tempStartDate = calculateNewDate(Date(), inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
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
                    tempStartDate = calculateNewDate(Date(), inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
                }
                
                if myProjectEndDate != getDefaultDate() as Date
                {
                    let calendar = Calendar.current
                    
                    let tempDate = calendar.date(
                        byAdding: .day,
                        value: daysToAdd,
                        to: Date())!
                    
                    tempEndDate = calculateNewDate(tempDate, inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
                }
            }
            
            // Create new Project
            
            let newProject = project(inTeamID: myTeamID)
            newProject.projectEndDate = tempEndDate
            newProject.projectName = myProjectName
            newProject.projectStartDate = tempStartDate
            newProject.GTDItemID = myGTDItemID
            newProject.repeatInterval = myRepeatInterval
            newProject.repeatType = myRepeatType
            newProject.repeatBase = myRepeatBase
            newProject.note = myNote
            
            // Populate team Members
            
            let myProjectTeamMembers = myDatabaseConnection.getTeamMembers(NSNumber(value: myProjectID))
            
            for myTeamMember in myProjectTeamMembers
            {
                let myMember = projectTeamMember(inProjectID: newProject.projectID as Int, inTeamMember: myTeamMember.teamMember, inRoleID: myTeamMember.roleID as! Int, inTeamID: myTeamID )
                
                myMember.projectMemberNotes = myTeamMember.projectMemberNotes
            }
            
            // Populate tasks, but have the marked as Open
            
            let myProjectTasks = myDatabaseConnection.getAllTasksForProject(myProjectID, inTeamID: myTeamID)
            
            for myProjectTask in myProjectTasks
            {
                let myNewTask = task(inTeamID: myTeamID)
                
                myNewTask.title = myProjectTask.title
                myNewTask.details = myProjectTask.details
                myNewTask.status = "Open"
                myNewTask.priority = myProjectTask.priority
                myNewTask.energyLevel = myProjectTask.energyLevel
                myNewTask.estimatedTime = myProjectTask.estimatedTime as! Int
                myNewTask.estimatedTimeType = myProjectTask.estimatedTimeType
                myNewTask.projectID = newProject.projectID
                myNewTask.repeatInterval = myProjectTask.repeatInterval as! Int
                myNewTask.repeatType = myProjectTask.repeatType
                myNewTask.repeatBase = myProjectTask.repeatBase
                myNewTask.flagged = myProjectTask.flagged as! Bool
                myNewTask.urgency = myProjectTask.urgency
                
                let myContextList = myDatabaseConnection.getContextsForTask(myProjectTask.taskID as! Int)
                
                for myContextItem in myContextList
                {
                    myNewTask.addContext(myContextItem.contextID as! Int)
                }
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
                let tempSuccessor = project(inProjectID: fromCurrentPredecessor)
                tempSuccessor.predecessor = myPredecessor
            }
            return true
        }
    }
}

extension coreDatabase
{
    func getOpenProjectsForGTDItem(_ inGTDItemID: Int, inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Completed\") && (projectStatus != \"Deleted\") && (areaID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
        
        let fetchRequest = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        
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
            return fetchResults[0].projectID as! Int
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }

    func getAllProjects(_ inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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

    func getProjects(_ inTeamID: Int, inArchiveFlag: Bool = false) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        if !inArchiveFlag
        {
            var predicate: NSPredicate
            
            predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Completed\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
        }
        else
        {
            // Create a new predicate that filters out any object that
            // doesn't have a title of "Best Language" exactly.
            let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
        }
        
        let sortDescriptor = NSSortDescriptor(key: "projectName", ascending: true)
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

    func saveProject(_ inProjectID: Int, inProjectEndDate: Date, inProjectName: String, inProjectStartDate: Date, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: Date, inGTDItemID: Int, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inTeamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID)
        
        if myProjects.count == 0
        { // Add
            myProject = Projects(context: objectContext)
            myProject.projectID = NSNumber(value: inProjectID)
            myProject.projectEndDate = inProjectEndDate
            myProject.projectName = inProjectName
            myProject.projectStartDate = inProjectStartDate
            myProject.projectStatus = inProjectStatus
            myProject.reviewFrequency = NSNumber(value: inReviewFrequency)
            myProject.lastReviewDate = inLastReviewDate
            myProject.areaID = NSNumber(value: inGTDItemID)
            myProject.repeatInterval = NSNumber(value: inRepeatInterval)
            myProject.repeatType = inRepeatType
            myProject.repeatBase = inRepeatBase
            myProject.teamID = NSNumber(value: inTeamID)
            
            if inUpdateType == "CODE"
            {
                myProject.updateTime =  Date()
                myProject.updateType = "Add"
            }
            else
            {
                myProject.updateTime = inUpdateTime
                myProject.updateType = inUpdateType
            }
        }
        else
        { // Update
            myProject = myProjects[0]
            myProject.projectEndDate = inProjectEndDate
            myProject.projectName = inProjectName
            myProject.projectStartDate = inProjectStartDate
            myProject.projectStatus = inProjectStatus
            myProject.reviewFrequency = NSNumber(value: inReviewFrequency)
            myProject.lastReviewDate = inLastReviewDate
            myProject.areaID = NSNumber(value: inGTDItemID)
            myProject.repeatInterval = NSNumber(value: inRepeatInterval)
            myProject.repeatType = inRepeatType
            myProject.repeatBase = inRepeatBase
            myProject.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myProject.updateTime =  Date()
                if myProject.updateType != "Add"
                {
                    myProject.updateType = "Update"
                }
            }
            else
            {
                myProject.updateTime = inUpdateTime
                myProject.updateType = inUpdateType
            }
        }
        
        saveContext()
    }
    
    func replaceProject(_ inProjectID: Int, inProjectEndDate: Date, inProjectName: String, inProjectStartDate: Date, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: Date, inGTDItemID: Int, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inTeamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        
        let myProject = Projects(context: objectContext)
        myProject.projectID = NSNumber(value: inProjectID)
        myProject.projectEndDate = inProjectEndDate
        myProject.projectName = inProjectName
        myProject.projectStartDate = inProjectStartDate
        myProject.projectStatus = inProjectStatus
        myProject.reviewFrequency = NSNumber(value: inReviewFrequency)
        myProject.lastReviewDate = inLastReviewDate
        myProject.areaID = NSNumber(value: inGTDItemID)
        myProject.repeatInterval = NSNumber(value: inRepeatInterval)
        myProject.repeatType = inRepeatType
        myProject.repeatBase = inRepeatBase
        myProject.teamID = NSNumber(value: inTeamID)
        
        if inUpdateType == "CODE"
        {
            myProject.updateTime =  Date()
            myProject.updateType = "Add"
        }
        else
        {
            myProject.updateTime = inUpdateTime
            myProject.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func deleteProject(_ inProjectID: Int, inTeamID: Int)
    {
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID)
        
        if myProjects.count > 0
        { // Update
            myProject = myProjects[0]
            myProject.updateTime =  Date()
            myProject.updateType = "Delete"
        }
        
        saveContext()
        
        var myProjectNote: ProjectNote!
        
        let myTeams = getProjectNote(inProjectID)
        
        if myTeams.count > 0
        { // Update
            myProjectNote = myTeams[0]
            myProjectNote.updateType = "Delete"
            myProjectNote.updateTime =  Date()
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
                myStage.updateTime =  Date()
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
        
        let fetchRequest23 = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        
        // Set the predicate on the fetch request
        fetchRequest23.predicate = predicate
        do
        {
            let fetchResults23 = try objectContext.fetch(fetchRequest23)
            for myItem23 in fetchResults23
            {
                objectContext.delete(myItem23 as NSManagedObject)
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
    
    func saveProjectNote(_ inProjectID: Int, inNote: String, inReviewPeriod: String, inPredecessor: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myProjectNote: ProjectNote!
        
        let myTeams = getProjectNote(inProjectID)
        
        if myTeams.count == 0
        { // Add
            myProjectNote = ProjectNote(context: objectContext)
            myProjectNote.projectID = NSNumber(value: inProjectID)
            myProjectNote.note = inNote
            
            myProjectNote.reviewPeriod = inReviewPeriod
            myProjectNote.predecessor = NSNumber(value: inPredecessor)
            if inUpdateType == "CODE"
            {
                myProjectNote.updateTime =  Date()
                myProjectNote.updateType = "Add"
            }
            else
            {
                myProjectNote.updateTime = inUpdateTime
                myProjectNote.updateType = inUpdateType
            }
        }
        else
        { // Update
            myProjectNote = myTeams[0]
            myProjectNote.note = inNote
            myProjectNote.reviewPeriod = inReviewPeriod
            myProjectNote.predecessor = NSNumber(value: inPredecessor)
            if inUpdateType == "CODE"
            {
                if myProjectNote.updateType != "Add"
                {
                    myProjectNote.updateType = "Update"
                }
                myProjectNote.updateTime =  Date()
            }
            else
            {
                myProjectNote.updateTime = inUpdateTime
                myProjectNote.updateType = inUpdateType
            }
        }
        
        saveContext()
    }
    
    func replaceProjectNote(_ inProjectID: Int, inNote: String, inReviewPeriod: String, inPredecessor: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myProjectNote = ProjectNote(context: objectContext)
        myProjectNote.projectID = NSNumber(value: inProjectID)
        myProjectNote.note = inNote
        
        myProjectNote.reviewPeriod = inReviewPeriod
        myProjectNote.predecessor = NSNumber(value: inPredecessor)
        if inUpdateType == "CODE"
        {
            myProjectNote.updateTime =  Date()
            myProjectNote.updateType = "Add"
        }
        else
        {
            myProjectNote.updateTime = inUpdateTime
            myProjectNote.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func getProjectNote(_ inProjectID: Int)->[ProjectNote]
    {
        let fetchRequest = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (projectID == \(inProjectID))")
        
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

    func initialiseTeamForProject(_ inTeamID: Int)
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
                    myItem.teamID = NSNumber(value: inTeamID)
                    maxID = myItem.projectID as! Int
                }
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Projects", inCodeValue: tempInt, inCodeType: "hidden")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func getProjectsForSync(_ inLastSyncDate: NSDate) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
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
    
    func getProjectNotesForSync(_ inLastSyncDate: NSDate) -> [ProjectNote]
    {
        let fetchRequest = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
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

        let fetchRequest23 = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        
        do
        {
            let fetchResults23 = try objectContext.fetch(fetchRequest23)
            for myItem23 in fetchResults23
            {
                self.objectContext.delete(myItem23 as NSManagedObject)
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
    func saveProjectsToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing Projects")
        for myItem in myDatabaseConnection.getProjectsForSync(inLastSyncDate)
        {
            saveProjectsRecordToCloudKit(myItem)
        }
        
        for myItem in myDatabaseConnection.getProjectNotesForSync(inLastSyncDate)
        {
            saveProjectNoteRecordToCloudKit(myItem)
        }
    }

    func updateProjectsInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateProjectsRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteProjects()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            sem.signal()
        })
        sem.wait()
        
        var myRecordList2: [CKRecordID] = Array()
        let predicate2: NSPredicate = NSPredicate(value: true)
        let query2: CKQuery = CKQuery(recordType: "ProjectNote", predicate: predicate2)
        privateDB.perform(query2, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList2.append(record.recordID)
            }
            self.performDelete(myRecordList2)
            sem.signal()
        })
        sem.wait()
    }

    func replaceProjectsInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let projectID = record.object(forKey: "projectID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
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
                
                myDatabaseConnection.replaceProject(projectID, inProjectEndDate: projectEndDate, inProjectName: projectName, inProjectStartDate: projectStartDate, inProjectStatus: projectStatus, inReviewFrequency: reviewFrequency, inLastReviewDate: lastReviewDate, inGTDItemID: areaID, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
                
                myDatabaseConnection.replaceProjectNote(projectID, inNote: note, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveProjectsRecordToCloudKit(_ sourceRecord: Projects)
    {
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                
                // First need to get additional info from other table
                
                let tempProjectNote = myDatabaseConnection.getProjectNote(sourceRecord.projectID as! Int)
                
                var myNote: String = ""
                var myReviewPeriod: String = ""
                var myPredecessor: Int = 0
                
                if tempProjectNote.count > 0
                {
                    myNote = tempProjectNote[0].note
                    myReviewPeriod = tempProjectNote[0].reviewPeriod
                    myPredecessor = tempProjectNote[0].predecessor as! Int
                }
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
                    record!.setValue(myNote, forKey: "note")
                    record!.setValue(myReviewPeriod, forKey: "reviewPeriod")
                    record!.setValue(myPredecessor, forKey: "predecessor")
                    
                    // Save this record again
                    self.privateDB.save(record!, completionHandler: { (savedRecord, saveError) in
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
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
                    record.setValue(myNote, forKey: "note")
                    record.setValue(myReviewPeriod, forKey: "reviewPeriod")
                    record.setValue(myPredecessor, forKey: "predecessor")
                    
                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
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
        })
    }

    func saveProjectNoteRecordToCloudKit(_ sourceRecord: ProjectNote)
    {
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Projects", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
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
                    record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.note, forKey: "note")
                    record!.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                    record!.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    
                    // Save this record again
                    self.privateDB.save(record!, completionHandler: { (savedRecord, saveError) in
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
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.note, forKey: "note")
                    record.setValue(sourceRecord.reviewPeriod, forKey: "reviewPeriod")
                    record.setValue(sourceRecord.predecessor, forKey: "predecessor")
                    
                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
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
        })
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
        
        myDatabaseConnection.saveProject(projectID, inProjectEndDate: projectEndDate, inProjectName: projectName, inProjectStartDate: projectStartDate, inProjectStatus: projectStatus, inReviewFrequency: reviewFrequency, inLastReviewDate: lastReviewDate, inGTDItemID: areaID, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
        
        myDatabaseConnection.saveProjectNote(projectID, inNote: note, inReviewPeriod: reviewPeriod, inPredecessor: predecessor, inUpdateTime: updateTime, inUpdateType: updateType)
    }

}
