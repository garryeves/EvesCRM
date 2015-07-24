//
//  taskManagementClasses.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

class purposeAndCoreValue: NSObject // 50k Level
{
    func delete()
    {
        
    }
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class vision: NSObject // (3-5 year goals) 40k Level
{
    func delete()
    {
        
    }
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class goalAndObjective: NSObject  // (1-2 year goals) 30k Level
{
    func delete()
    {
        
    }
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class areaOfResponsibility // 20k Level
{
    func delete()
    {
    
    }
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class projectTeamMember: NSObject
{
    private var myProjectID: Int = 0
    private var myProjectMemberNotes: String = ""
    private var myRoleID: Int = 0
    private var myTeamMember: String = ""

    var projectID: Int
    {
        get
        {
            return myProjectID as Int
        }
        set
        {
            myProjectID = newValue
        }
    }

    var projectMemberNotes: String
    {
        get
        {
            return myProjectMemberNotes
        }
        set
        {
            myProjectMemberNotes = newValue
        }
    }

    var roleID: Int
    {
        get
        {
            return myRoleID as Int
        }
        set
        {
            myRoleID = newValue
        }
    }

    var teamMember: String
    {
        get
        {
            return myTeamMember
        }
        set
        {
            myTeamMember = newValue
        }
    }

    func save()
    {
        myDatabaseConnection.saveTeamMember(myProjectID, inRoleID: myRoleID, inPersonName: myTeamMember, inNotes: myProjectMemberNotes)
    }
    
    func delete()
    {
        myDatabaseConnection.deleteTeamMember(myProjectID, inPersonName: myTeamMember)
    }
}

class project: NSObject // 10k level
{
    private var myProjectEndDate: NSDate!
    private var myProjectID: Int = 0
    private var myProjectName: String = ""
    private var myProjectStartDate: NSDate!
    private var myProjectStatus: String = ""
    private var myReviewFrequency: Int = 0
    private var myLastReviewDate: NSDate!
    private var myTeamMembers: [projectTeamMember] = Array()
    private var myTasks: [task] = Array()
    
    var projectEndDate: NSDate
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
    
    var displayProjectEndDate: String
    {
        get
        {
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myProjectEndDate)
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

    var projectStartDate: NSDate
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
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myProjectStartDate)
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
    
    var lastReviewDate: NSDate
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
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myLastReviewDate)
        }
    }
    
    override init()
    {
        let currentNumberofEntries = myDatabaseConnection.getAllProjects().count
        let nextProjectID = currentNumberofEntries + 1
        
        myProjectID = nextProjectID
    }
    
    init(inProjectID: Int)
    {
 // GRE whatever calls projects should check to make sure it is not marked as "Archived", as we are not deleting Projects, only marking them as archived
        let myProjects = myDatabaseConnection.getProjectDetails(inProjectID)
        
        for myProject in myProjects
        {
            myProjectEndDate = myProject.projectEndDate
            myProjectID = myProject.projectID as Int
            myProjectName = myProject.projectName
            myProjectStartDate = myProject.projectStartDate
            myProjectStatus = myProject.projectStatus
            myReviewFrequency = myProject.reviewFrequency as Int
            myLastReviewDate = myProject.lastReviewDate
                
            // load team members
        
            myTeamMembers.removeAll()
            
            let myProjectTeamMembers = myDatabaseConnection.getTeamMembers(inProjectID)
            
            for myTeamMember in myProjectTeamMembers
            {
                let myMember = projectTeamMember()
                myMember.projectID = myTeamMember.projectID as Int
                myMember.roleID = myTeamMember.roleID as Int
                myMember.teamMember = myTeamMember.teamMember
                myMember.projectMemberNotes = myTeamMember.projectMemberNotes
                myTeamMembers.append(myMember)
            }
            
            // load tasks
            
            myTasks.removeAll()
            
            let myProjectTasks = myDatabaseConnection.getProjectTasks(myProjectID)
            
            for myProjectTask in myProjectTasks
            {
                let myNewTask = task(inTaskID: myProjectTask.taskID)
                myNewTask.projectID = myProjectID
                myTasks.append(myNewTask)
            }
        }
        
        func addTaskToProject(inTaskID: String)
        {
            myDatabaseConnection.saveProjectTask(myProjectID, inTaskID: inTaskID)
            
            myTasks.removeAll()
            
            let myProjectTasks = myDatabaseConnection.getProjectTasks(myProjectID)
            
            for myProjectTask in myProjectTasks
            {
                let myNewTask = task(inTaskID: myProjectTask.taskID)
                myNewTask.projectID = myProjectID
                myTasks.append(myNewTask)
            }

        }
        
        func removeTaskFromProject(inTaskID: String)
        {
            myDatabaseConnection.deleteProjectTask(myProjectID, inTaskID: inTaskID)
            
            myTasks.removeAll()
            
            let myProjectTasks = myDatabaseConnection.getProjectTasks(myProjectID)
            
            for myProjectTask in myProjectTasks
            {
                let myNewTask = task(inTaskID: myProjectTask.taskID)
                myNewTask.projectID = myProjectID
                myTasks.append(myNewTask)
            }
        }
    }
    
    func save()
    {
        // Save Project
        
        myDatabaseConnection.saveProject(myProjectID, inProjectEndDate: myProjectEndDate, inProjectName: myProjectName, inProjectStartDate: myProjectStartDate, inProjectStatus: myProjectStatus, inReviewFrequency: myReviewFrequency, inLastReviewDate: myLastReviewDate)
        
        // Save Team Members
        
        for myMember in myTeamMembers
        {
            myMember.save()
        }
        
        // Save Tasks
        
        for myProjectTask in myTasks
        {
            myProjectTask.save()
            
            // Also need to save a project/task record
            
            myDatabaseConnection.saveProjectTask(myProjectID, inTaskID: myProjectTask.taskID)
        }
    }
    
   //  There is no delete in this class, as I do not want to delete projects, instead they will be marked as archived and not displayed
}

class task: NSObject
{
    private var myTaskID: String = ""
    private var myTitle: String = ""
    private var myDetails: String = ""
    private var myDueDate: NSDate!
    private var myStartDate: NSDate!
    private var myStatus: String = ""
    private var myProjectID: Int
    private var myContexts: [context] = Array()

    var taskID: String
    {
        get
        {
            return myTaskID
        }
    }
    
    var title: String
    {
        get
        {
            return myTitle
        }
        set
        {
            myTitle = newValue
        }
    }
    
    var details: String
    {
        get
        {
            return myDetails
        }
        set
        {
            myDetails = newValue
        }
    }
    
    var dueDate: NSDate
    {
        get
        {
            return myDueDate
        }
        set
        {
            myDueDate = newValue
        }
    }
    
    var displayDueDate: String
    {
        get
        {
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myDueDate)
        }
    }
    
    var startDate: NSDate
    {
        get
        {
            return myStartDate
        }
        set
        {
            myStartDate = newValue
        }
    }
 
    var displayStartDate: String
    {
        get
        {
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myStartDate)
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
    
    var projectID: Int
    {
        get
        {
            return myProjectID
        }
        set
        {
            myProjectID = newValue
            myDatabaseConnection.saveProjectTask(myProjectID, inTaskID: myTaskID)
        }
    }
    
    var contexts: [context]
        {
        get
        {
            return myContexts
        }
        set
        {
            myContexts = newValue
        }
    }
    
    override init()
    {
        let currentNumberofEntries = myDatabaseConnection.getTaskCount()
        let nextTaskID = currentNumberofEntries + 1
        
        myTaskID = String(nextTaskID)
    }
    
    init(inTaskID: String)
    {
        let myTaskData = myDatabaseConnection.getTask(inTaskID)
        
        for myTask in myTaskData
        {
            myTaskID = myTask.taskID
            myTitle = myTask.title
            myDetails = myTask.details
            myDueDate = myTask.dueDate
            myStartDate = myTask.startDate
            myStatus = myTask.status
            
            // get contexts
            
            let myContextList = myDatabaseConnection.getContextsForTask(inTaskID)
            myContexts.removeAll()
            
            for myContextItem in myContextList
            {
                let myNewContext = context(inContextID: myContextItem.contextID)
                myContexts.append(myNewContext)
            }
            
            // get Project ID link
            
            let myProjectList = myDatabaseConnection.getProjectForTask(inTaskID)
            
            if myProjectList.count == 0
            {
                myProjectID = 0
            }
            else
            {
                myProjectID = myProjectList[0].projectID as Int
            }
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveTask(myTaskID, inTitle: myTitle, inDetails: myDetails, inDueDate: myDueDate, inStartDate: myStartDate, inStatus: myStatus)
        
        // Save project link
        
        myDatabaseConnection.saveProjectTask(myProjectID, inTaskID: myTaskID)
        
        // Save context link
        
        for myContext in myContexts
        {
            myDatabaseConnection.saveTaskContext(myContext.contextID, inTaskID: myTaskID)
        }
    }
    
    func addContextToTask(inContextID: String)
    {
        myDatabaseConnection.saveTaskContext(inContextID, inTaskID: myTaskID)
        
        let myContextList = myDatabaseConnection.getContextsForTask(myTaskID)
        myContexts.removeAll()
        
        for myContextItem in myContextList
        {
            let myNewContext = context(inContextID: myContextItem.contextID)
            myContexts.append(myNewContext)
        }
    }
    
    func removeContextFromTask(inContextID: String)
    {
        myDatabaseConnection.deleteTaskContext(inContextID, inTaskID: myTaskID)
        
        let myContextList = myDatabaseConnection.getContextsForTask(myTaskID)
        myContexts.removeAll()
        
        for myContextItem in myContextList
        {
            let myNewContext = context(inContextID: myContextItem.contextID)
            myContexts.append(myNewContext)
        }
    }
    
    func delete()
    {
        myDatabaseConnection.deleteTask(myTaskID)
    }
    
    func history() -> [taskUpdates]
    {
        var myHistory: [taskUpdates] = Array()
        
        let myHistoryRows = myDatabaseConnection.getTaskUpdates(myTaskID)
        
        for myHistoryRow in myHistoryRows
        {
            let myItem = taskUpdates(inUpdate: myHistoryRow)
            myHistory.append(myItem)
        }
    }
    
    func addHistoryRecord(inHistoryDetails: String, inHistorySource: String)
    {
        let myItem = taskUpdates(inTaskID: myTaskID)
        myItem.details = inHistoryDetails
        myItem.source = inHistorySource
        
        myItem.save()
    }
}

class context: NSObject
{
    private var myContextID: String = ""
    private var myName: String = ""
    private var myEmail: String = ""
    private var myAutoEmail: String = ""
    private var myParentContext: String = ""
    private var myStatus: String = ""
    
    var contextID: String
    {
        get
        {
            return myContextID
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
    
    var email: String
    {
        get
        {
            return myEmail
        }
        set
        {
            myEmail = newValue
        }
    }
    
    var autoEmail: String
    {
        get
        {
            return myAutoEmail
        }
        set
        {
            myAutoEmail = newValue
        }
    }
    
    var parentContext: String
    {
        get
        {
            return myParentContext
        }
        set
        {
            myParentContext = newValue
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
    
    var allTasks: [TaskContext]
    {
        get
        {
            return myDatabaseConnection.getTasksForContext(myContextID)
        }
    }
    
    override init()
    {
        let myContexts = myDatabaseConnection.getAllContexts()
        
        let currentNumberofEntries = myContexts.count
        let nextContextID = currentNumberofEntries + 1
        
        myContextID = String(nextContextID)
    }
    
    init(inContextID: String)
    {
        let myContexts = myDatabaseConnection.getContextDetails(inContextID)
        
        for myContext in myContexts
        {
            myContextID = myContext.contextID
            myName = myContext.name
            myEmail = myContext.email
            myAutoEmail = myContext.autoEmail
            myParentContext = myContext.parentContext
            myStatus = myContext.status
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveContext(myContextID, inName: myName, inEmail: myEmail, inAutoEmail: myAutoEmail, inParentContext: myParentContext, inStatus: myStatus)
    }
}

class taskUpdates: NSObject
{
    private var myTaskID: String = ""
    private var myUpdateDate: NSDate!
    private var myDetails: String = ""
    private var mySource: String = ""

    var updateDate: NSDate
    {
        get
        {
            return myUpdateDate
        }
    }
    
    var displayUpdateDate: String
    {
        get
        {
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myUpdateDate)
        }
    }
    
    var details: String
        {
        get
        {
            return myDetails
        }
        set
        {
            myDetails = newValue
        }
    }
    
    var source: String
        {
        get
        {
            return mySource
        }
        set
        {
            mySource = newValue
        }
    }
    
    init(inTaskID: String)
    {
        myTaskID = inTaskID
        
    }
    
    init(inUpdate: TaskUpdates)
    {
        myTaskID = inUpdate.taskID
        myUpdateDate = inUpdate.updateDate
        myDetails = inUpdate.details
        mySource = inUpdate.source
    }
    
    func save()
    {
        myDatabaseConnection.saveTaskUpdate(myTaskID, inDetails: myDetails, inSource: mySource)
    }
}