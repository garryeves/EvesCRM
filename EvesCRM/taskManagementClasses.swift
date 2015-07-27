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
    private var myPurposeID: String = ""
    private var myTitle: String = ""
    private var myStatus: String = ""
    private var myVision: [gvision] = Array()
   
    var purposeID: String
    {
        get
        {
            return myPurposeID
        }
        set
        {
            myPurposeID = newValue
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
    
    var vision: [gvision]
    {
        get
        {
            return myVision
        }
    }

    func load(inPurposeID: String)
    {
        // Load the details
        
        let myVisions = myDatabaseConnection.getVisions(inPurposeID)
        
        for myPurpose in myVisions
        {
            myPurposeID = myPurpose.purposeID
            myTitle = myPurpose.title
            myStatus = myPurpose.status
        }
        
        // Load the Members
        let myVisionList = myDatabaseConnection.getOpenVisionsForPurpose(myPurposeID)
        myVision.removeAll()
        
        for myVis in myVisionList
        {
            let myNewVision = gvision()
            myNewVision.load(myVis.visionID)
            myVision.append(myNewVision)
        }
    }
    
    func save()
    {
        myDatabaseConnection.savePurpose(myPurposeID, inTitle: myTitle, inStatus: myStatus)
    }
    
    func addVision(inVisionID: String)
    {
        myDatabaseConnection.savePurposeVision(myPurposeID, inVisionID: inVisionID)
        
        let myVisionList = myDatabaseConnection.getOpenVisionsForPurpose(myPurposeID)
        myVision.removeAll()
        
        for myVis in myVisionList
        {
            let myNewVision = gvision()
            myNewVision.load(myVis.visionID)
            myVision.append(myNewVision)
        }
    }
    
    func removeVision(inVisionID: String)
    {
        myDatabaseConnection.deletePurposeVision(inVisionID)
        
        let myVisionList = myDatabaseConnection.getOpenVisionsForPurpose(myPurposeID)
        myVision.removeAll()
        
        for myVis in myVisionList
        {
            let myNewVision = gvision()
            myNewVision.load(myVis.visionID)
            myVision.append(myNewVision)
        }
    }
}

class gvision: NSObject // (3-5 year goals) 40k Level
{
    private var myVisionID: String = ""
    private var myPurposeID: String = ""
    private var myTitle: String = ""
    private var myStatus: String = ""
    private var myGoals: [goalAndObjective] = Array()
    
    var visionID: String
    {
        get
        {
            return myVisionID
        }
        set
        {
            myVisionID = newValue
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
    
    var goals: [goalAndObjective]
    {
        get
        {
            return myGoals
        }
    }
    
    func load(inVisionID: String)
    {
        // Load the details
        
        let myVisions = myDatabaseConnection.getVisions(inVisionID)
        
        for myVision in myVisions
        {
            myPurposeID = myVision.purposeID
            myVisionID = myVision.visionID
            myTitle = myVision.title
            myStatus = myVision.status
        }
        
        // Load the Members
        let myGoalList = myDatabaseConnection.getOpenGoalsForVision(myVisionID)
        myGoals.removeAll()
        
        for myGoal in myGoalList
        {
            let myNewGoal = goalAndObjective()
            myNewGoal.load(myGoal.goalID)
            myGoals.append(myNewGoal)
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveVision(myVisionID, inPurposeID: myPurposeID, inTitle: myTitle, inStatus: myStatus)
    }
    
    func addGoal(inGoalID: String)
    {
        myDatabaseConnection.saveVisionGoal(myVisionID, inGoalID: inGoalID)
        
        let myGoalList = myDatabaseConnection.getOpenGoalsForVision(myVisionID)
        myGoals.removeAll()
        
        for myGoal in myGoalList
        {
            let myNewGoal = goalAndObjective()
            myNewGoal.load(myGoal.goalID)
            myGoals.append(myNewGoal)
        }
    }
    
    func removeGoal(inGoalID: String)
    {
        myDatabaseConnection.deleteVisionGoal(inGoalID)
        
        let myGoalList = myDatabaseConnection.getOpenGoalsForVision(myVisionID)
        myGoals.removeAll()
        
        for myGoal in myGoalList
        {
            let myNewGoal = goalAndObjective()
            myNewGoal.load(myGoal.goalID)
            myGoals.append(myNewGoal)
        }
    }
}

class goalAndObjective: NSObject  // (1-2 year goals) 30k Level
{
    private var myGoalID: String = ""
    private var myVisionID: String = ""
    private var myTitle: String = ""
    private var myStatus: String = ""
    private var myAreas: [areaOfResponsibility] = Array()
    
    var goalID: String
    {
        get
        {
            return myGoalID
        }
        set
        {
            myGoalID = newValue
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
    
    var areas: [areaOfResponsibility]
    {
        get
        {
            return myAreas
        }
    }
    
    func load(inGoalID: String)
    {
        // Load the details
        
        let myGoals = myDatabaseConnection.getGoals(inGoalID)
        
        for myGoal in myGoals
        {
            myGoalID = myGoal.goalID
            myVisionID = myGoal.visionID
            myTitle = myGoal.title
            myStatus = myGoal.status
        }
        
        // Load the Members
        let myAreaList = myDatabaseConnection.getOpenAreasForGoal(myGoalID)
        myAreas.removeAll()
        
        for myArea in myAreaList
        {
            let myNewArea = areaOfResponsibility()
            myNewArea.load(myArea.areaID)
            myAreas.append(myNewArea)
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveGoal(myGoalID, inVisionID: myVisionID, inTitle: myTitle, inStatus: myStatus)
    }
    
    func addArea(inAreaID: String)
    {
        myDatabaseConnection.saveGoalArea(myGoalID, inAreaID: inAreaID)
        
        let myAreaList = myDatabaseConnection.getOpenAreasForGoal(myGoalID)
        myAreas.removeAll()
        
        for myArea in myAreaList
        {
            let myNewArea = areaOfResponsibility()
            myNewArea.load(myArea.areaID)
            myAreas.append(myNewArea)
        }
    }

    func removeArea(inAreaID: String)
    {
        myDatabaseConnection.deleteGoalArea(inAreaID)
        
        let myAreaList = myDatabaseConnection.getOpenAreasForGoal(myGoalID)
        myAreas.removeAll()
        
        for myArea in myAreaList
        {
            let myNewArea = areaOfResponsibility()
            myNewArea.load(myArea.areaID)
            myAreas.append(myNewArea)
        }
    }
}

class areaOfResponsibility // 20k Level
{
    private var myAreaID: String = ""
    private var myGoalID: String = ""
    private var myTitle: String = ""
    private var myStatus: String = ""
    private var myProjects: [project] = Array()
    
    var areaID: String
    {
        get
        {
            return myAreaID
        }
        set
        {
            myAreaID = newValue
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
    
    var projects: [project]
    {
        get
        {
            return myProjects
        }
    }
    
    func load(inAreaID: String)
    {
        // Load the details
        
        let myAreas = myDatabaseConnection.getAreaOfResponsibility(inAreaID)
        
        for myArea in myAreas
        {
            myAreaID = myArea.areaID
            myGoalID = myArea.goalID
            myTitle = myArea.title
            myStatus = myArea.status
        }
        
        // Load the Members
        let myProjectList = myDatabaseConnection.getOpenProjectsForArea(inAreaID)
        myProjects.removeAll()
        
        for myProject in myProjectList
        {
            let myNewProject = project()
            myNewProject.load(myProject.projectID as Int)
            myProjects.append(myNewProject)
        }
    }

    func save()
    {
        myDatabaseConnection.saveAreaOfResponsibility(myAreaID, inGoalID: myGoalID, inTitle: myTitle, inStatus: myStatus)
    }
    
    func addProject(inProjectID: Int)
    {
        myDatabaseConnection.saveAreaProject(inProjectID, inAreaID: myAreaID)
        
        let myProjectList = myDatabaseConnection.getOpenProjectsForArea(myAreaID)
        myProjects.removeAll()
        
        for myProject in myProjectList
        {
            let myNewProject = project()
            myNewProject.load(myProject.projectID as Int)
            myProjects.append(myNewProject)
        }
    }
    
    func removeProject(inProjectID: Int)
    {
        myDatabaseConnection.deleteAreaProject(inProjectID)
        
        let myProjectList = myDatabaseConnection.getOpenProjectsForArea(myAreaID)
        myProjects.removeAll()
        
        for myProject in myProjectList
        {
            let myNewProject = project()
            myNewProject.load(myProject.projectID as Int)
            myProjects.append(myNewProject)
        }
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
    private var myAreaID: String
    
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
    
    var areaID: String
    {
        get
        {
            return myAreaID
        }
        set
        {
            myAreaID = newValue
        }
    }
    
    override init()
    {
        let currentNumberofEntries = myDatabaseConnection.getAllProjects().count
        let nextProjectID = currentNumberofEntries + 1
        
        myProjectID = nextProjectID
    }
    
    func load(inProjectID: Int)
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
            myAreaID = myProject.areaID
                
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
                myNewTask.taskOrder = myProjectTask.taskOrder as Int
                myTasks.append(myNewTask)
            }
        }
        
        func addTaskToProject(inTaskID: String)
        {
            let nextOrder = myDatabaseConnection.getMaxProjectTaskOrder(myProjectID) + 1
            myDatabaseConnection.saveProjectTask(myProjectID, inTaskID: inTaskID, inTaskOrder: nextOrder)
            
            myTasks.removeAll()
            
            let myProjectTasks = myDatabaseConnection.getProjectTasks(myProjectID)
            
            for myProjectTask in myProjectTasks
            {
                let myNewTask = task(inTaskID: myProjectTask.taskID)
                myNewTask.projectID = myProjectID
                myNewTask.taskOrder = myProjectTask.taskOrder as Int
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
                myNewTask.taskOrder = myProjectTask.taskOrder as Int
                myTasks.append(myNewTask)
            }
        }
    }
    
    func save()
    {
        // Save Project
        
        myDatabaseConnection.saveProject(myProjectID, inProjectEndDate: myProjectEndDate, inProjectName: myProjectName, inProjectStartDate: myProjectStartDate, inProjectStatus: myProjectStatus, inReviewFrequency: myReviewFrequency, inLastReviewDate: myLastReviewDate, inAreaID: myAreaID)
        
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
            
            myDatabaseConnection.saveProjectTask(myProjectID, inTaskID: myProjectTask.taskID, inTaskOrder: myProjectTask.myTaskOrder)
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
    private var myTaskOrder: Int = 0
    private var myParentTaskID: String = ""

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
            myDatabaseConnection.saveProjectTask(myProjectID, inTaskID: myTaskID, inTaskOrder: myTaskOrder)
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
    
    var taskOrder: Int
    {
        get
        {
            return myTaskOrder
        }
        set
        {
            myTaskOrder = newValue
        }
    }

    var parentTaskID: String
    {
        get
        {
            return myParentTaskID
        }
        set
        {
            myParentTaskID = newValue
        }
    }
    
    override init()
    {
        let currentNumberofEntries = myDatabaseConnection.getTaskCount()
        let nextTaskID = currentNumberofEntries + 1
        
        myTaskOrder = 1
        
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
            myParentTaskID = myTask.parentTaskID
            
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
                myTaskOrder = 1
            }
            else
            {
                myProjectID = myProjectList[0].projectID as Int
                myTaskOrder = myProjectList[0].taskOrder as Int
            }
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveTask(myTaskID, inTitle: myTitle, inDetails: myDetails, inDueDate: myDueDate, inStartDate: myStartDate, inStatus: myStatus, inParentTask: myParentTaskID)
        
        // Save project link
        
        myDatabaseConnection.saveProjectTask(myProjectID, inTaskID: myTaskID, inTaskOrder: myTaskOrder)
        
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