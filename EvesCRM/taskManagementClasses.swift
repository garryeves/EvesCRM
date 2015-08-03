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
    private var myPurposeID: Int = 0
    private var myTitle: String = ""
    private var myStatus: String = ""
    private var myVision: [gvision] = Array()
   
    var purposeID: Int
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

    func load(inPurposeID: Int)
    {
        // Load the details
        
        let myVisions = myDatabaseConnection.getVisions(inPurposeID)
        
        for myPurpose in myVisions
        {
            myPurposeID = myPurpose.purposeID as Int
            myTitle = myPurpose.title
            myStatus = myPurpose.status
        }
        
        // Load the Members
        let myVisionList = myDatabaseConnection.getOpenVisionsForPurpose(myPurposeID)
        myVision.removeAll()
        
        for myVis in myVisionList
        {
            let myNewVision = gvision()
            myNewVision.load(myVis.visionID as Int)
            myVision.append(myNewVision)
        }
    }
    
    func save()
    {
        myDatabaseConnection.savePurpose(myPurposeID, inTitle: myTitle, inStatus: myStatus)
    }
    
    func addVision(inVisionID: Int)
    {
        myDatabaseConnection.savePurposeVision(myPurposeID, inVisionID: inVisionID)
        
        let myVisionList = myDatabaseConnection.getOpenVisionsForPurpose(myPurposeID)
        myVision.removeAll()
        
        for myVis in myVisionList
        {
            let myNewVision = gvision()
            myNewVision.load(myVis.visionID as Int)
            myVision.append(myNewVision)
        }
    }
    
    func removeVision(inVisionID: Int)
    {
        myDatabaseConnection.deletePurposeVision(inVisionID)
        
        let myVisionList = myDatabaseConnection.getOpenVisionsForPurpose(myPurposeID)
        myVision.removeAll()
        
        for myVis in myVisionList
        {
            let myNewVision = gvision()
            myNewVision.load(myVis.visionID as Int)
            myVision.append(myNewVision)
        }
    }
}

class gvision: NSObject // (3-5 year goals) 40k Level
{
    private var myVisionID: Int = 0
    private var myPurposeID: Int = 0
    private var myTitle: String = ""
    private var myStatus: String = ""
    private var myGoals: [goalAndObjective] = Array()
    
    var visionID: Int
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
    
    func load(inVisionID: Int)
    {
        // Load the details
        
        let myVisions = myDatabaseConnection.getVisions(inVisionID)
        
        for myVision in myVisions
        {
            myPurposeID = myVision.purposeID as Int
            myVisionID = myVision.visionID as Int
            myTitle = myVision.title
            myStatus = myVision.status
        }
        
        // Load the Members
        let myGoalList = myDatabaseConnection.getOpenGoalsForVision(myVisionID)
        myGoals.removeAll()
        
        for myGoal in myGoalList
        {
            let myNewGoal = goalAndObjective()
            myNewGoal.load(myGoal.goalID as Int)
            myGoals.append(myNewGoal)
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveVision(myVisionID, inPurposeID: myPurposeID, inTitle: myTitle, inStatus: myStatus)
    }
    
    func addGoal(inGoalID: Int)
    {
        myDatabaseConnection.saveVisionGoal(myVisionID, inGoalID: inGoalID)
        
        let myGoalList = myDatabaseConnection.getOpenGoalsForVision(myVisionID)
        myGoals.removeAll()
        
        for myGoal in myGoalList
        {
            let myNewGoal = goalAndObjective()
            myNewGoal.load(myGoal.goalID as Int)
            myGoals.append(myNewGoal)
        }
    }
    
    func removeGoal(inGoalID: Int)
    {
        myDatabaseConnection.deleteVisionGoal(inGoalID)
        
        let myGoalList = myDatabaseConnection.getOpenGoalsForVision(myVisionID)
        myGoals.removeAll()
        
        for myGoal in myGoalList
        {
            let myNewGoal = goalAndObjective()
            myNewGoal.load(myGoal.goalID as Int)
            myGoals.append(myNewGoal)
        }
    }
}

class goalAndObjective: NSObject  // (1-2 year goals) 30k Level
{
    private var myGoalID: Int = 0
    private var myVisionID: Int = 0
    private var myTitle: String = ""
    private var myStatus: String = ""
    private var myAreas: [areaOfResponsibility] = Array()
    
    var goalID: Int
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
    
    func load(inGoalID: Int)
    {
        // Load the details
        
        let myGoals = myDatabaseConnection.getGoals(inGoalID)
        
        for myGoal in myGoals
        {
            myGoalID = myGoal.goalID as Int
            myVisionID = myGoal.visionID as Int
            myTitle = myGoal.title
            myStatus = myGoal.status
        }
        
        // Load the Members
        let myAreaList = myDatabaseConnection.getOpenAreasForGoal(myGoalID)
        myAreas.removeAll()
        
        for myArea in myAreaList
        {
            let myNewArea = areaOfResponsibility()
            myNewArea.load(myArea.areaID as Int)
            myAreas.append(myNewArea)
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveGoal(myGoalID, inVisionID: myVisionID, inTitle: myTitle, inStatus: myStatus)
    }
    
    func addArea(inAreaID: Int)
    {
        myDatabaseConnection.saveGoalArea(myGoalID, inAreaID: inAreaID)
        
        let myAreaList = myDatabaseConnection.getOpenAreasForGoal(myGoalID)
        myAreas.removeAll()
        
        for myArea in myAreaList
        {
            let myNewArea = areaOfResponsibility()
            myNewArea.load(myArea.areaID as Int)
            myAreas.append(myNewArea)
        }
    }

    func removeArea(inAreaID: Int)
    {
        myDatabaseConnection.deleteGoalArea(inAreaID)
        
        let myAreaList = myDatabaseConnection.getOpenAreasForGoal(myGoalID)
        myAreas.removeAll()
        
        for myArea in myAreaList
        {
            let myNewArea = areaOfResponsibility()
            myNewArea.load(myArea.areaID as Int)
            myAreas.append(myNewArea)
        }
    }
}

class areaOfResponsibility // 20k Level
{
    private var myAreaID: Int = 0
    private var myGoalID: Int = 0
    private var myTitle: String = ""
    private var myStatus: String = ""
    private var myProjects: [project] = Array()
    
    var areaID: Int
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
    
    func load(inAreaID: Int)
    {
        // Load the details
        
        let myAreas = myDatabaseConnection.getAreaOfResponsibility(inAreaID)
        
        for myArea in myAreas
        {
            myAreaID = myArea.areaID as Int
            myGoalID = myArea.goalID as Int
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
    private var myAreaID: Int = 0

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
            if myProjectEndDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                var myDateFormatter = NSDateFormatter()
                myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                return myDateFormatter.stringFromDate(myProjectEndDate)
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
            if myProjectStartDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                var myDateFormatter = NSDateFormatter()
                myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                return myDateFormatter.stringFromDate(myProjectStartDate)
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
            if myProjectStartDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                var myDateFormatter = NSDateFormatter()
                myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                return myDateFormatter.stringFromDate(myLastReviewDate)
            }
        }
    }
    
    var areaID: Int
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
        super.init()
        
        let currentNumberofEntries = myDatabaseConnection.getAllProjects().count
        let nextProjectID = currentNumberofEntries + 1
        
        myProjectID = nextProjectID
        
        // Set dates to a really daft value so that it stores into the database
        
        myProjectEndDate = getDefaultDate()
        myProjectStartDate = getDefaultDate()
        myLastReviewDate = getDefaultDate()
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
            myAreaID = myProject.areaID as Int
                
            // load team members
        
            myTeamMembers.removeAll()
            
            let myProjectTeamMembers = myDatabaseConnection.getTeamMembers(inProjectID)
            
            for myTeamMember in myProjectTeamMembers
            {
                let myMember = projectTeamMember()
                myMember.projectID = myTeamMember.projectID as Int
                myMember.roleID = myTeamMember.roleID as Int
                myMember.teamMember = myTeamMember.teamMember

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
            
            // load tasks
            
            myTasks.removeAll()
            
            let myProjectTasks = myDatabaseConnection.getTasks(myProjectID, inParentType: "Project")
            
            for myProjectTask in myProjectTasks
            {
                let myNewTask = task(inTaskID: myProjectTask.taskID as Int)
                myTasks.append(myNewTask)
            }
        }
        
        func addTaskToProject(inTaskID: Int)
        {
            let nextOrder = myDatabaseConnection.getMaxProjectTaskOrder(myProjectID) + 1
            
            let myTempTask = task(inTaskID: inTaskID)
            myTempTask.parentID = myProjectID
            myTempTask.parentType = "Project"
            myTempTask.setTaskOrder(nextOrder)
            myTempTask.save()
            
            myTasks.removeAll()
            
            let myProjectTasks = myDatabaseConnection.getTasks(myProjectID, inParentType: "Project")
            
            for myProjectTask in myProjectTasks
            {
                let myNewTask = task(inTaskID: myProjectTask.taskID as Int)
                myTasks.append(myNewTask)
            }

        }
        
        func removeTaskFromProject(inTaskID: Int)
        {
            let myTempTask = task(inTaskID: inTaskID)
            myTempTask.parentID = 0
            myTempTask.parentType = ""
            myTempTask.setTaskOrder(0)
            myTempTask.save()
            
            myTasks.removeAll()
            
            let myProjectTasks = myDatabaseConnection.getTasks(myProjectID, inParentType: "Project")
            
            for myProjectTask in myProjectTasks
            {
                let myNewTask = task(inTaskID: myProjectTask.taskID as Int)
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
        }
    }
    
    func getDefaultDate() -> NSDate
    {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        return dateStringFormatter.dateFromString("9999-12-31")!
    }

   //  There is no delete in this class, as I do not want to delete projects, instead they will be marked as archived and not displayed
}

class task: NSObject
{
    private var myTaskID: Int = 0
    private var myTitle: String = ""
    private var myDetails: String = ""
    private var myDueDate: NSDate!
    private var myStartDate: NSDate!
    private var myStatus: String = ""
    private var myContexts: [context] = Array()
    private var myTaskOrder: Int = 0
    private var myParentID: Int = 0
    private var myParentType: String = ""
    private var myTaskMode: String = ""
    private var myPriority: String = ""
    private var myEnergyLevel: String = ""
    private var myEstimatedTime: Int = 0
    private var myEstimatedTimeType: String = ""
    private var myProjectID: Int = 0

    var taskID: Int
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
            if myDueDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                var myDateFormatter = NSDateFormatter()
                myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                return myDateFormatter.stringFromDate(myDueDate)
            }
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
            if myStartDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                var myDateFormatter = NSDateFormatter()
                myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                return myDateFormatter.stringFromDate(myStartDate)
            }
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
    }

    var parentID: Int
    {
        get
        {
            return myParentID
        }
        set
        {
            myTaskID = newValue
        }
    }

    var parentType: String
    {
        get
        {
            return myParentType
        }
        set
        {
            myParentType = newValue
        }
    }
    
    var taskMode: String
    {
        get
        {
            return myTaskMode
        }
        set
        {
            myTaskMode = newValue
        }
    }
    
    var priority: String
    {
        get
        {
            return myPriority
        }
        set
        {
            myPriority = newValue
        }
    }
    
    var energyLevel: String
    {
        get
        {
            return myEnergyLevel
        }
        set
        {
            myEnergyLevel = newValue
        }
    }
    
    var estimatedTime: Int
    {
        get
        {
            return myEstimatedTime
        }
        set
        {
            myEstimatedTime = newValue
        }
    }
    
    var estimatedTimeType: String
    {
        get
        {
            return myEstimatedTimeType
        }
        set
        {
            myEstimatedTimeType = newValue
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
        }
    }
    
    var history: [taskUpdates]
    {
        var myHistory: [taskUpdates] = Array()
        
        let myHistoryRows = myDatabaseConnection.getTaskUpdates(myTaskID)
        
        for myHistoryRow in myHistoryRows
        {
            let myItem = taskUpdates(inUpdate: myHistoryRow)
            myHistory.append(myItem)
        }
        
        return myHistory
    }
    
    override init()
    {
        super.init()
        let currentNumberofEntries = myDatabaseConnection.getTaskCount()
        myTaskID = currentNumberofEntries + 1
        
        myTaskOrder = 1
        
        myDueDate = getDefaultDate()
        myStartDate = getDefaultDate()
    
        save()
    }
    
    init(inTaskID: Int)
    {
        let myTaskData = myDatabaseConnection.getTask(inTaskID)
        
        for myTask in myTaskData
        {
            myTaskID = myTask.taskID as Int
            myTitle = myTask.title
            myDetails = myTask.details
            myDueDate = myTask.dueDate
            myStartDate = myTask.startDate
            myStatus = myTask.status
            myParentID = myTask.parentID as Int
            myParentType = myTask.parentType
            myTaskMode = myTask.taskMode
            myPriority = myTask.priority
            myEnergyLevel = myTask.energyLevel
            myEstimatedTime = myTask.estimatedTime as Int
            myEstimatedTimeType = myTask.estimatedTimeType
            myTaskOrder = myTask.taskOrder as Int
            myProjectID = myTask.projectID as Int
            
            // get contexts
            
            let myContextList = myDatabaseConnection.getContextsForTask(inTaskID)
            myContexts.removeAll()
            
            for myContextItem in myContextList
            {
                let myNewContext = context(inContextID: myContextItem.contextID as Int)
                myContexts.append(myNewContext)
            }
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveTask(myTaskID, inTitle: myTitle, inDetails: myDetails, inDueDate: myDueDate, inStartDate: myStartDate, inStatus: myStatus, inParentID: myParentID, inParentType: myParentType, inTaskMode: myTaskMode, inTaskOrder: myTaskOrder, inPriority: myPriority, inEnergyLevel: myEnergyLevel, inEstimatedTime: myEstimatedTime, inEstimatedTimeType: myEstimatedTimeType, inProjectID: myProjectID)
        
        // Save context link
        
        for myContext in myContexts
        {
            myDatabaseConnection.saveTaskContext(myContext.contextID as Int, inTaskID: myTaskID)
        }
    }
    
    func addContextToTask(inContextID: Int)
    {
        myDatabaseConnection.saveTaskContext(inContextID, inTaskID: myTaskID)
        
        let myContextList = myDatabaseConnection.getContextsForTask(myTaskID)
        myContexts.removeAll()
        
        for myContextItem in myContextList
        {
            let myNewContext = context(inContextID: myContextItem.contextID as Int)
            myContexts.append(myNewContext)
        }
    }
    
    func removeContextFromTask(inContextID: Int)
    {
        myDatabaseConnection.deleteTaskContext(inContextID, inTaskID: myTaskID)
        
        let myContextList = myDatabaseConnection.getContextsForTask(myTaskID)
        myContexts.removeAll()
        
        for myContextItem in myContextList
        {
            let myNewContext = context(inContextID: myContextItem.contextID as Int)
            myContexts.append(myNewContext)
        }
    }
    
    func delete()
    {
        myDatabaseConnection.deleteTask(myTaskID)
    }
    
    func addHistoryRecord(inHistoryDetails: String, inHistorySource: String)
    {
        let myItem = taskUpdates(inTaskID: myTaskID)
        myItem.details = inHistoryDetails
        myItem.source = inHistorySource
        
        myItem.save()
    }
    
    func setTaskOrder(inNewOrderValue: Int)
    {
        let myOtherTasks = myDatabaseConnection.getTasks(myParentID, inParentType: myParentType)
                
        if inNewOrderValue == 0
        {
            // This means we are removing the current value, so subsequent tasks should be decremented by 1
            for myOtherTask in myOtherTasks
            {
                if myOtherTask.taskOrder as Int > myTaskOrder
                {
                    let myNewTask = task(inTaskID: myOtherTask.taskID as Int)
                    myNewTask.storeTaskOrder(myNewTask.taskOrder - 1)
                    myNewTask.save()
                }
            }
        }
        else
        {
            // This means we are moving existing tasks around
            
            if inNewOrderValue < myTaskOrder
            {  //new position is less than current position
                
                for myOtherTask in myOtherTasks
                {
                    let currentValue = myOtherTask.taskOrder as Int
                    if currentValue >= inNewOrderValue && currentValue < myTaskOrder
                    {
                        let myNewTask = task(inTaskID: myOtherTask.taskID as Int)
                        myNewTask.storeTaskOrder(myNewTask.taskOrder + 1)
                        myNewTask.save()
                    }
                }
            }
            else
            {  // new position is higher than current position
                for myOtherTask in myOtherTasks
                {
                    let currentValue = myOtherTask.taskOrder as Int
                    if currentValue > myTaskOrder && currentValue <= inNewOrderValue
                    {
                        let myNewTask = task(inTaskID: myOtherTask.taskID as Int)
                        myNewTask.storeTaskOrder(myNewTask.taskOrder - 1)
                        myNewTask.save()
                    }
                }
            }
        }
                
        myTaskOrder = inNewOrderValue
    }

    func storeTaskOrder(inNewOrderValue: Int)
    {  // This is used by the "setTaskOrder in order to not trigger a cascade update of taskOrder
        myTaskOrder = inNewOrderValue
    }
    
    func getDefaultDate() -> NSDate
    {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        return dateStringFormatter.dateFromString("9999-12-31")!
    }
}

class contexts: NSObject
{
    private var myContexts:[context] = Array()
    
    override init()
    {
        let myData = myDatabaseConnection.getContexts()
        
        for myItem in myData
        {
            let myContext = context(inContext: myItem)
            myContexts.append(myContext)
        }
    }
    
    var contexts: [context]
    {
        get
        {
            return myContexts
        }
    }

    var contextsByHierarchy: [context]
    {
        get
        {
            var workingArray: [context] = Array()
            
            workingArray = myContexts
            
            
            workingArray.sorted { $0.contextHierarchy < $1.contextHierarchy }
            
            
            return workingArray
        }
    }
}

class context: NSObject
{
    private var myContextID: Int = 0
    private var myName: String = ""
    private var myEmail: String = ""
    private var myAutoEmail: String = ""
    private var myParentContext: Int = 0
    private var myStatus: String = ""
    
    var contextID: Int
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
    
    var parentContext: Int
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
    
    var contextHierarchy: String
    {
        get
        {
            var retString: String = ""
        
            if myParentContext == 0
            {
                retString = myName
            }
            else
            { // Navigate to parent
                let theParent = context(inContextID: myParentContext)
                retString = "\(theParent.contextHierarchy) - \(myName)"
            }
        
            return retString
        }
    }
    
    override init()
    {
        super.init()
        let myContexts = myDatabaseConnection.getAllContexts()
        
        let currentNumberofEntries = myContexts.count
        myContextID = currentNumberofEntries + 1
    }
    
    init(inContextID: Int)
    {
        let myContexts = myDatabaseConnection.getContextDetails(inContextID)
        
        for myContext in myContexts
        {
            myContextID = myContext.contextID as Int
            myName = myContext.name
            myEmail = myContext.email
            myAutoEmail = myContext.autoEmail
            myParentContext = myContext.parentContext as Int
            myStatus = myContext.status
        }
    }
    
    init(inContext: Context)
    {
        myContextID = inContext.contextID as Int
        myName = inContext.name
        myEmail = inContext.email
        myAutoEmail = inContext.autoEmail
        myParentContext = inContext.parentContext as Int
        myStatus = inContext.status
    }
    
    func save()
    {
        myDatabaseConnection.saveContext(myContextID, inName: myName, inEmail: myEmail, inAutoEmail: myAutoEmail, inParentContext: myParentContext, inStatus: myStatus)
    }
}

class taskUpdates: NSObject
{
    private var myTaskID: Int = 0
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
            myDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
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
    
    init(inTaskID: Int)
    {
        myTaskID = inTaskID
        
    }
    
    init(inUpdate: TaskUpdates)
    {
        myTaskID = inUpdate.taskID as Int
        myUpdateDate = inUpdate.updateDate
        myDetails = inUpdate.details
        mySource = inUpdate.source
    }
    
    func save()
    {
        myDatabaseConnection.saveTaskUpdate(myTaskID, inDetails: myDetails, inSource: mySource)
    }
}

class TaskModel: NSObject
{
    private var myTaskType: String = ""
    private var myTask: task!
    private var myDelegate: MyTaskDelegate!
 
    var delegate: MyTaskDelegate
        {
        get
        {
            return myDelegate
        }
        set
        {
            myDelegate = newValue
        }
    }
    
    var taskType: String
    {
        get
        {
            return myTaskType
        }
        set
        {
            myTaskType = newValue
        }
    }
    
    var currentTask: task
    {
        get
        {
            return myTask
        }
        set
        {
            myTask = newValue
        }
    }
}