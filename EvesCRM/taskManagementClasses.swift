//
//  taskManagementClasses.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import AddressBook

class purposeAndCoreValue: NSObject // 50k Level
{
    private var myPurposeID: Int = 0
    private var myTitle: String = ""
    private var myStatus: String = ""
    private var myVision: [gvision] = Array()
    private var myTeamID: Int = 0
   
    var purposeID: Int
    {
        get
        {
            return myPurposeID
        }
        set
        {
            myPurposeID = newValue
            save()
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
            save()
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
            save()
        }
    }
    
    var vision: [gvision]
    {
        get
        {
            return myVision
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
    
    func load(inPurposeID: Int)
    {
        // Load the details
        
        let myVisions = myDatabaseConnection.getVisions(inPurposeID, inTeamID: myTeamID)
        
        for myPurpose in myVisions
        {
            myPurposeID = myPurpose.purposeID as Int
            myTitle = myPurpose.title
            myStatus = myPurpose.status
            myTeamID = myPurpose.teamID as Int
        }
        
        // Load the Members
        let myVisionList = myDatabaseConnection.getOpenVisionsForPurpose(myPurposeID, inTeamID: myTeamID)
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
        myDatabaseConnection.savePurpose(myPurposeID, inTitle: myTitle, inStatus: myStatus, inTeamID: myTeamID)
    }
    
    func addVision(inVisionID: Int)
    {
        myDatabaseConnection.savePurposeVision(myPurposeID, inVisionID: inVisionID, inTeamID: myTeamID)
        
        let myVisionList = myDatabaseConnection.getOpenVisionsForPurpose(myPurposeID, inTeamID: myTeamID)
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
        myDatabaseConnection.deletePurposeVision(inVisionID, inTeamID: myTeamID)
        
        let myVisionList = myDatabaseConnection.getOpenVisionsForPurpose(myPurposeID, inTeamID: myTeamID)
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
    private var myTeamID: Int = 0
    
    var visionID: Int
    {
        get
        {
            return myVisionID
        }
        set
        {
            myVisionID = newValue
            save()
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
            save()
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
            save()
        }
    }
    
    var goals: [goalAndObjective]
    {
        get
        {
            return myGoals
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
    
    func load(inVisionID: Int)
    {
        // Load the details
        
        let myVisions = myDatabaseConnection.getVisions(inVisionID, inTeamID: myTeamID)
        
        for myVision in myVisions
        {
            myPurposeID = myVision.purposeID as Int
            myVisionID = myVision.visionID as Int
            myTitle = myVision.title
            myStatus = myVision.status
            myTeamID = myVision.teamID as Int
        }
        
        // Load the Members
        let myGoalList = myDatabaseConnection.getOpenGoalsForVision(myVisionID, inTeamID: myTeamID)
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
        myDatabaseConnection.saveVision(myVisionID, inPurposeID: myPurposeID, inTitle: myTitle, inStatus: myStatus, inTeamID: myTeamID)
    }
    
    func addGoal(inGoalID: Int)
    {
        myDatabaseConnection.saveVisionGoal(myVisionID, inGoalID: inGoalID, inTeamID: myTeamID)
        
        let myGoalList = myDatabaseConnection.getOpenGoalsForVision(myVisionID, inTeamID: myTeamID)
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
        myDatabaseConnection.deleteVisionGoal(inGoalID, inTeamID: myTeamID)
        
        let myGoalList = myDatabaseConnection.getOpenGoalsForVision(myVisionID, inTeamID: myTeamID)
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
    private var myTeamID: Int = 0
    
    var goalID: Int
    {
        get
        {
            return myGoalID
        }
        set
        {
            myGoalID = newValue
            save()
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
            save()
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
            save()
        }
    }
    
    var areas: [areaOfResponsibility]
    {
        get
        {
            return myAreas
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
    
    func load(inGoalID: Int)
    {
        // Load the details
        
        let myGoals = myDatabaseConnection.getGoals(inGoalID, inTeamID: myTeamID)
        
        for myGoal in myGoals
        {
            myGoalID = myGoal.goalID as Int
            myVisionID = myGoal.visionID as Int
            myTitle = myGoal.title
            myStatus = myGoal.status
            myTeamID = myGoal.teamID as Int
        }
        
        // Load the Members
        let myAreaList = myDatabaseConnection.getOpenAreasForGoal(myGoalID, inTeamID: myTeamID)
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
        myDatabaseConnection.saveGoal(myGoalID, inVisionID: myVisionID, inTitle: myTitle, inStatus: myStatus, inTeamID: myTeamID)
    }
    
    func addArea(inAreaID: Int)
    {
        myDatabaseConnection.saveGoalArea(myGoalID, inAreaID: inAreaID, inTeamID: myTeamID)
        
        let myAreaList = myDatabaseConnection.getOpenAreasForGoal(myGoalID, inTeamID: myTeamID)
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
        myDatabaseConnection.deleteGoalArea(inAreaID, inTeamID: myTeamID)
        
        let myAreaList = myDatabaseConnection.getOpenAreasForGoal(myGoalID, inTeamID: myTeamID)
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
    private var myTeamID: Int = 0
    
    var areaID: Int
    {
        get
        {
            return myAreaID
        }
        set
        {
            myAreaID = newValue
            save()
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
            save()
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
            save()
        }
    }
    
    var projects: [project]
    {
        get
        {
            return myProjects
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
    
    func load(inAreaID: Int)
    {
        // Load the details
        
        let myAreas = myDatabaseConnection.getAreaOfResponsibility(inAreaID, inTeamID: myTeamID)
        
        for myArea in myAreas
        {
            myAreaID = myArea.areaID as Int
            myGoalID = myArea.goalID as Int
            myTitle = myArea.title
            myStatus = myArea.status
            myTeamID = myArea.teamID as Int
        }
        
        // Load the Members
        let myProjectList = myDatabaseConnection.getOpenProjectsForArea(inAreaID, inTeamID: myTeamID)
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
        myDatabaseConnection.saveAreaOfResponsibility(myAreaID, inGoalID: myGoalID, inTitle: myTitle, inStatus: myStatus, inTeamID: myTeamID)
    }
    
    func addProject(inProjectID: Int)
    {
        myDatabaseConnection.saveAreaProject(inProjectID, inAreaID: myAreaID, inTeamID: myTeamID)
        
        let myProjectList = myDatabaseConnection.getOpenProjectsForArea(myAreaID, inTeamID: myTeamID)
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
        myDatabaseConnection.deleteAreaProject(inProjectID, inTeamID: myTeamID)
        
        let myProjectList = myDatabaseConnection.getOpenProjectsForArea(myAreaID, inTeamID: myTeamID)
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
            save()
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
            save()
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
            save()
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
            save()
        }
    }
    
    init(inProjectID: Int, inTeamMember: String, inRoleID: Int)
    {
        super.init()
        myProjectID = inProjectID
        myTeamMember = inTeamMember
        myRoleID = inRoleID
        save()
    }
    
    override init()
    {
        // Do nothing
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
    private var myRepeatInterval: Int = 0
    private var myRepeatType: String = ""
    private var myRepeatBase: String = ""
    private var myTeamID: Int = 0

    var projectEndDate: NSDate
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
            save()
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
    
    var lastReviewDate: NSDate
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
    
    override init()
    {
        super.init()
 
        let currentNumberofEntries = myDatabaseConnection.getProjectCount()
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
        let myProjects = myDatabaseConnection.getProjectDetails(inProjectID, inTeamID: myTeamID)
        
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
            myRepeatInterval = myProject.repeatInterval as Int
            myRepeatType = myProject.repeatType
            myRepeatBase = myProject.repeatBase
            myTeamID = myProject.teamID as Int
                
            // load team members
        
            loadTeamMembers()
            
            // load tasks
            
            myTasks.removeAll()
            
            let myProjectTasks = myDatabaseConnection.getTasksForProject(myProjectID, inTeamID: myTeamID)
            
            for myProjectTask in myProjectTasks
            {
                let myNewTask = task(inTaskID: myProjectTask.taskID as Int)
                myTasks.append(myNewTask)
            }
        }
    }
        
    func loadTeamMembers()
    {
        myTeamMembers.removeAll()
            
        let myProjectTeamMembers = myDatabaseConnection.getTeamMembers(myProjectID)
            
        for myTeamMember in myProjectTeamMembers
        {
            let myMember = projectTeamMember(inProjectID: myTeamMember.projectID as Int, inTeamMember: myTeamMember.teamMember, inRoleID: myTeamMember.roleID as Int )
            
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
        
    func addTaskToProject(inTaskID: Int)
    {            
        let myTempTask = task(inTaskID: inTaskID)
        myTempTask.projectID = myProjectID
        myTempTask.save()
            
        myTasks.removeAll()
            
        let myProjectTasks = myDatabaseConnection.getTasksForProject(myProjectID, inTeamID: myTeamID)
            
        for myProjectTask in myProjectTasks
        {
            let myNewTask = task(inTaskID: myProjectTask.taskID as Int)
            myTasks.append(myNewTask)
        }
    }
        
    func removeTaskFromProject(inTaskID: Int)
    {
        let myTempTask = task(inTaskID: inTaskID)
        myTempTask.projectID = 0
        myTempTask.save()
            
        myTasks.removeAll()
            
        let myProjectTasks = myDatabaseConnection.getTasksForProject(myProjectID, inTeamID: myTeamID)
            
        for myProjectTask in myProjectTasks
        {
            let myNewTask = task(inTaskID: myProjectTask.taskID as Int)
            myTasks.append(myNewTask)
        }
    }
    
    func save()
    {
        // Save Project
        
        myDatabaseConnection.saveProject(myProjectID, inProjectEndDate: myProjectEndDate, inProjectName: myProjectName, inProjectStartDate: myProjectStartDate, inProjectStatus: myProjectStatus, inReviewFrequency: myReviewFrequency, inLastReviewDate: myLastReviewDate, inAreaID: myAreaID, inRepeatInterval: myRepeatInterval, inRepeatType: myRepeatType, inRepeatBase: myRepeatBase, inTeamID: myTeamID)
        
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

class taskPredecessor: NSObject
{
    private var myPredecessorID: Int = 0
    private var myPredecessorType: String = ""
    
    var predecessorID: Int
    {
        get
        {
            return myPredecessorID
        }
        set
        {
            myPredecessorID = newValue
        }
    }
    
    var predecessorType: String
    {
        get
        {
            return myPredecessorType
        }
        set
        {
            myPredecessorType = newValue
        }
    }
    
    init(inPredecessorID: Int, inPredecessorType: String)
    {
        myPredecessorID = inPredecessorID
        myPredecessorType = inPredecessorType
    }
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
    private var myPriority: String = ""
    private var myEnergyLevel: String = ""
    private var myEstimatedTime: Int = 0
    private var myEstimatedTimeType: String = ""
    private var myProjectID: Int = 0
    private var myCompletionDate: NSDate!
    private var myRepeatInterval: Int = 0
    private var myRepeatType: String = ""
    private var myRepeatBase: String = ""
    private var myFlagged: Bool = false
    private var myUrgency: String = ""
    private var myTeamID: Int = 0
    private var myPredecessors: [taskPredecessor] = Array()
 
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
            save()
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
            save()
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
            save()
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
            save()
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
            if newValue == "Completed"
            {
                myCompletionDate = NSDate()
            }
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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

    var completionDate: NSDate
    {
        get
        {
            return myCompletionDate
        }
    }

    var displayCompletionDate: String
    {
        get
        {
            if myCompletionDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                var myDateFormatter = NSDateFormatter()
                myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                return myDateFormatter.stringFromDate(myCompletionDate)
            }
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

    var flagged: Bool
    {
        get
        {
            return myFlagged
        }
        set
        {
            myFlagged = newValue
            save()
        }
    }

    var urgency: String
    {
        get
        {
            return myUrgency
        }
        set
        {
            myUrgency = newValue
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
    
    var predecessors: [taskPredecessor]
    {
        get
        {
            return myPredecessors
        }
    }
    
    override init()
    {
        super.init()
        let currentNumberofEntries = myDatabaseConnection.getTaskCount()
        myTaskID = currentNumberofEntries + 1
        
        myDueDate = getDefaultDate()
        myStartDate = getDefaultDate()
        myCompletionDate = getDefaultDate()
        myStatus = "Open"
        
        myTitle = "New Task"
    
        save()
    }
    
    init(inTaskID: Int)
    {
        let myTaskData = myDatabaseConnection.getTask(inTaskID, inTeamID: myTeamID)
        
        for myTask in myTaskData
        {
            myTaskID = myTask.taskID as Int
            myTitle = myTask.title
            myDetails = myTask.details
            myDueDate = myTask.dueDate
            myStartDate = myTask.startDate
            myStatus = myTask.status
            myPriority = myTask.priority
            myEnergyLevel = myTask.energyLevel
            myEstimatedTime = myTask.estimatedTime as Int
            myEstimatedTimeType = myTask.estimatedTimeType
            myProjectID = myTask.projectID as Int
            myCompletionDate = myTask.completionDate
            myRepeatInterval = myTask.repeatInterval as Int
            myRepeatType = myTask.repeatType
            myRepeatBase = myTask.repeatBase
            myFlagged = myTask.flagged as Bool
            myUrgency = myTask.urgency
            myTeamID = myTask.teamID as Int
            
            // get contexts
            
            let myContextList = myDatabaseConnection.getContextsForTask(inTaskID)
            myContexts.removeAll()
            
            for myContextItem in myContextList
            {
                let myNewContext = context(inContextID: myContextItem.contextID as Int)
                myContexts.append(myNewContext)
            }
            
            let myPredecessorList = myDatabaseConnection.getTaskPredecessors(inTaskID)
            
            myPredecessors.removeAll()
            
            for myPredecessorItem in myPredecessorList
            {
                let myNewPredecessor = taskPredecessor(inPredecessorID: myPredecessorItem.predecessorID as Int, inPredecessorType: myPredecessorItem.predecessorType)
                myPredecessors.append(myNewPredecessor)
            }
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveTask(myTaskID, inTitle: myTitle, inDetails: myDetails, inDueDate: myDueDate, inStartDate: myStartDate, inStatus: myStatus, inPriority: myPriority, inEnergyLevel: myEnergyLevel, inEstimatedTime: myEstimatedTime, inEstimatedTimeType: myEstimatedTimeType, inProjectID: myProjectID, inCompletionDate: myCompletionDate!, inRepeatInterval: myRepeatInterval, inRepeatType: myRepeatType, inRepeatBase: myRepeatBase, inFlagged: myFlagged, inUrgency: myUrgency, inTeamID: myTeamID)
        
        // Save context link
        
        for myContext in myContexts
        {
            myDatabaseConnection.saveTaskContext(myContext.contextID as Int, inTaskID: myTaskID)
        }
    }
    
    func addContextToTask(inContextID: Int)
    {
        var itemFound: Bool = false
        
        // first we need to make sure the context is not already present
        
        // Get the context name
        
        let myContext = context(inContextID: inContextID)
        
        let myCheck = myDatabaseConnection.getContextsForTask(myTaskID)
        
        for myItem in myCheck
        {
            let myRetrievedContext = context(inContextID: myItem.contextID as Int)
            if myRetrievedContext.name.lowercaseString == myContext.name.lowercaseString
            {
                itemFound = true
                break
            }
        }
        
        if !itemFound
        { // Not match found
            myDatabaseConnection.saveTaskContext(inContextID, inTaskID: myTaskID)
        
            let myContextList = myDatabaseConnection.getContextsForTask(myTaskID)
            myContexts.removeAll()
        
            for myContextItem in myContextList
            {
                let myNewContext = context(inContextID: myContextItem.contextID as Int)
                myContexts.append(myNewContext)
            }
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
    
    
    func addPredecessor(inPredecessorID: Int, inPredecessorType: String)
    {
        myDatabaseConnection.savePredecessorTask(myTaskID, inPredecessorID: inPredecessorID, inPredecessorType: inPredecessorType)
    }

    func removePredecessor(inPredecessorID: Int, inPredecessorType: String)
    {
        myDatabaseConnection.deleteTaskPredecessor(myTaskID, inPredecessorID: inPredecessorID)
    }

    func changePredecessor(inPredecessorID: Int, inPredecessorType: String)
    {
        myDatabaseConnection.updatePredecessorTaskType(myTaskID, inPredecessorID: inPredecessorID, inPredecessorType: inPredecessorType)
    }

    func getDefaultDate() -> NSDate
    {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        return dateStringFormatter.dateFromString("9999-12-31")!
    }
    
    func markComplete()
    {
        myCompletionDate = NSDate()
        myStatus = "Completed"
        save()
    }
    
    func reopen()
    {
        myStatus = "Open"
        save()
    }
    
    private func writeLine(inTargetString: String, inLineString: String) -> String
    {
        var myString = inTargetString
        
        if count(inTargetString) > 0
        {
            myString += "\n"
        }
        
        myString += inLineString
        
        return myString
    }

    func buildShareString() -> String
    {
        var myExportString: String = ""
        var myLine: String = ""
        var myContextTable: String = ""
        
        myLine = "                \(myTitle)"
        myExportString = writeLine(myExportString, inLineString: myLine)
        
        myExportString = writeLine(myExportString, inLineString: "")
        
        myLine = "\(myDetails)"
        myExportString = writeLine(myExportString, inLineString: myLine)
        
        myExportString = writeLine(myExportString, inLineString: "")
        
        if myProjectID > 0
        {
            let myData3 = myDatabaseConnection.getProjectDetails(myProjectID, inTeamID: myTeamID)
            
            if myData3.count != 0
            {
                myLine = "Project: \(myData3[0].projectName)"
                myExportString = writeLine(myExportString, inLineString: myLine)
                myExportString = writeLine(myExportString, inLineString: "")
            }
        }
        
        myLine = ""
        
        if displayStartDate != ""
        {
            myLine += "Start: \(displayStartDate)      "
        }
        
        if displayDueDate != ""
        {
            myLine += "Due: \(displayDueDate)      "
        }
        
        if myEstimatedTime > 0
        {
            myLine += "Estimated Time \(myEstimatedTime) \(myEstimatedTimeType)"
        }
        
        myExportString = writeLine(myExportString, inLineString: myLine)
        
        myExportString = writeLine(myExportString, inLineString: "")
        
        if myContexts.count > 0
        {
            myLine = "Contexts"
            myExportString = writeLine(myExportString, inLineString: myLine)
            
            myContextTable = ""
            
            for myContext in myContexts
            {
                myLine = "\(myContext.name)"
                myExportString = writeLine(myExportString, inLineString: myLine)
            }
            
            myExportString = writeLine(myExportString, inLineString: "")
            myExportString = writeLine(myExportString, inLineString: "")
        }
        
        myLine = ""
        
        if myPriority != ""
        {
            myLine += "Priority: \(myPriority)      "
        }
        
        if myUrgency != ""
        {
            myLine += "Urgency: \(myUrgency)      "
        }
        
        if myEnergyLevel != ""
        {
            myLine += "Energy: \(myEnergyLevel)"
        }
        
        myExportString = writeLine(myExportString, inLineString: myLine)
        
        if history.count > 0
        { //  task updates displayed here
            myExportString = writeLine(myExportString, inLineString: "")
            myExportString = writeLine(myExportString, inLineString: "")
            myLine = "Update history"
            myExportString = writeLine(myExportString, inLineString: myLine)
            
            for myItem in history
            {
                myLine = "||\(myItem.displayUpdateDate)"
                myLine += "||\(myItem.source)"
                myLine += "||\(myItem.details)||"
                myExportString = writeLine(myExportString, inLineString: myLine)
            }
        }
        
        return myExportString
    }
    
    private func writeHTMLLine(inTargetString: String, inLineString: String) -> String
    {
        var myString = inTargetString
        
        if count(inTargetString) > 0
        {
            myString += "<p>"
        }
        
        myString += inLineString
        
        return myString
    }
    
    func buildShareHTMLString() -> String
    {
        var myExportString: String = ""
        var myLine: String = ""
        var myContextTable: String = ""
        
        myLine = "<html><body><h3><center>\(myTitle)</center></h3>"
        myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        
        myExportString = writeHTMLLine(myExportString, inLineString: "")
        
        myLine = "\(myDetails)"
        myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        
        myExportString = writeHTMLLine(myExportString, inLineString: "")
        
        if myProjectID > 0
        {
            let myData3 = myDatabaseConnection.getProjectDetails(myProjectID, inTeamID: myTeamID)
            
            if myData3.count != 0
            {
                myLine = "Project: \(myData3[0].projectName)"
                myExportString = writeHTMLLine(myExportString, inLineString: myLine)
                myExportString = writeHTMLLine(myExportString, inLineString: "")
            }
        }
        
        myLine = ""
        
        if displayStartDate != ""
        {
            myLine += "Start: \(displayStartDate)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        }

        if displayDueDate != ""
        {
            myLine += "Due: \(displayDueDate)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        }
        
        if myEstimatedTime > 0
        {
            myLine += "Estimated Time \(myEstimatedTime) \(myEstimatedTimeType)"
        }
        
        myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        
        myExportString = writeHTMLLine(myExportString, inLineString: "")
        
        if myContexts.count > 0
        {
            myLine = "<h4>Contexts</h4>"
            myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        
            myContextTable = "<table>"
        
            for myContext in myContexts
            {
                myContextTable += "<tr><td>\(myContext.name)</td></tr>"
            }
     
            myContextTable += "</table>"
            myExportString = writeHTMLLine(myExportString, inLineString: myContextTable)
            myExportString = writeHTMLLine(myExportString, inLineString: "")
            myExportString = writeHTMLLine(myExportString, inLineString: "")
        }
        
        myLine = ""
        
        if myPriority != ""
        {
            myLine += "Priority: \(myPriority)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        }

        if myUrgency != ""
        {
            myLine += "Urgency: \(myUrgency)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        }
        
        if myEnergyLevel != ""
        {
            myLine += "Energy: \(myEnergyLevel)"
        }

        myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        
        if history.count > 0
        { //  task updates displayed here
            myExportString = writeHTMLLine(myExportString, inLineString: "")
            myExportString = writeHTMLLine(myExportString, inLineString: "")
            myLine = "<h4>Update history</h4>"
            myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        
            myContextTable = "<table border=\"1\">"

            for myItem in history
            {
                myContextTable += "<tr>"
                myContextTable += "<td>\(myItem.displayUpdateDate)</td>"
                myContextTable += "<td>\(myItem.source)</td>"
                myContextTable += "<td>\(myItem.details)</td>"
                myContextTable += "</tr>"
            }
            
            myContextTable += "</table>"
            myExportString = writeHTMLLine(myExportString, inLineString: myContextTable)
        }
        
        myExportString = writeHTMLLine(myExportString, inLineString: "</body></html>")
        
        return myExportString
    }
}

class contexts: NSObject
{
    private var myContexts:[context] = Array()
    
    override init()
    {
        let myData = myDatabaseConnection.getContexts(myTeamID)
        
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
    
    var peopleContextsByHierarchy: [context]
    {
        get
        {
            var workingArray: [context] = Array()
            
            for myContext in myContexts
            {
                if myContext.personID != 0
                {
                    workingArray.append(myContext)
                }
            }
            
            workingArray.sorted { $0.contextHierarchy < $1.contextHierarchy }
            
            return workingArray
        }
    }

    var nonPeopleContextsByHierarchy: [context]
        {
        get
        {
            var workingArray: [context] = Array()
            
            for myContext in myContexts
            {
                if myContext.personID == 0
                {
                    workingArray.append(myContext)
                }
            }
            
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
    private var myPersonID: Int32 = 0
    private var myTeamID: Int = 0
    
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
            save()
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
            save()
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
            save()
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
            save()
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
            save()
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
    
    var personID: Int32
    {
        get
        {
            return myPersonID
        }
        set
        {
            myPersonID = newValue
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
    
    func removeWhitespace(string: String) -> String {
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!isEmpty($0)})
        return join(" ", components)
    }
    
    init(inContextName: String)
    {
        super.init()
        var matchFound: Bool = false
        
        let myContextList = contexts()
        
        // String of any unneeded whilespace
        
        let strippedContext = removeWhitespace(inContextName)
        
        for myContext in myContextList.contexts
        {
            if myContext.name.lowercaseString == strippedContext.lowercaseString
            {
                // Existing context found, so use this record
                
                myContextID = myContext.contextID as Int
                myName = myContext.name
                myEmail = myContext.email
                myAutoEmail = myContext.autoEmail
                myParentContext = myContext.parentContext as Int
                myStatus = myContext.status
                myPersonID = myContext.personID
                myTeamID = myContext.teamID

                matchFound = true
                break
            }
        }
        
        // if no match then create context
        
        if !matchFound
        {
            let currentNumberofEntries = myDatabaseConnection.getContextCount()
            myContextID = currentNumberofEntries + 1
        
            save()
            
            // Now we need to check the Addressbook to see if there is a match for the person, so we can store the personID
        
            let myPerson: ABRecord! = findPersonRecord(inContextName) as ABRecord!
        
            if myPerson == nil
            { // No match on Name so check on Email Addresses
                let myPersonEmail:ABRecord! = findPersonbyEmail(inContextName)
            
                if myPersonEmail != nil
                {
                    myName = ABRecordCopyCompositeName(myPersonEmail).takeRetainedValue() as String
                    myEmail = inContextName
                    myPersonID = ABRecordGetRecordID(myPersonEmail)
                }
                else
                {  // No match so use text passed in
                    myName = strippedContext
                }
            }
            else
            {
                myName = ABRecordCopyCompositeName(myPerson).takeRetainedValue() as String
                myPersonID = ABRecordGetRecordID(myPerson)
            }
            save()
        }
    }
    
    init(inContextID: Int)
    {
        let myContexts = myDatabaseConnection.getContextDetails(inContextID, inTeamID: myTeamID)
        
        for myContext in myContexts
        {
            myContextID = myContext.contextID as Int
            myName = myContext.name
            myEmail = myContext.email
            myAutoEmail = myContext.autoEmail
            myParentContext = myContext.parentContext as Int
            myStatus = myContext.status
            myPersonID = myContext.personID.intValue
            myTeamID = myContext.teamID as Int
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
        myPersonID = inContext.personID.intValue
        myTeamID = inContext.teamID as Int
    }
    
    func save()
    {
        myDatabaseConnection.saveContext(myContextID, inName: myName, inEmail: myEmail, inAutoEmail: myAutoEmail, inParentContext: myParentContext, inStatus: myStatus, inPersonID: myPersonID, inTeamID: myTeamID)
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
    private var myEvent: myCalendarItem!
 
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
    
    var event: myCalendarItem
    {
        get
        {
            return myEvent
        }
        set
        {
            myEvent = newValue
        }
    }
}