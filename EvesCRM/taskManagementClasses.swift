//
//  taskManagementClasses.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import AddressBook

class workingGTDLevel: NSObject
{
    private var myTitle: String = "New"
    private var myTeamID: Int = 0
    private var myGTDLevel: Int = 0
    
    var GTDLevel: Int
    {
        get
        {
            return myGTDLevel
        }
        set
        {
            myGTDLevel = newValue
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
    
    var teamID: Int
    {
        get
        {
            return myTeamID
        }
    }
    
    init(inGTDLevel: Int, inTeamID: Int)
    {
        super.init()
        
        // Load the details
        
        let myGTDDetail = myDatabaseConnection.getGTDLevel(inGTDLevel, inTeamID: inTeamID)
        
        for myItem in myGTDDetail
        {
            myTitle = myItem.levelName!
            myTeamID = myItem.teamID as! Int
            myGTDLevel = inGTDLevel
        }
    }
    
    init(inGTDLevel: Int, inLevelName: String, inTeamID: Int)
    {
        super.init()
        
        myGTDLevel = inGTDLevel
        myTitle = inLevelName
        myTeamID = inTeamID
        
        save()
    }
    
    init(inLevelName: String, inTeamID: Int)
    {
        super.init()
        
        let myGTDDetail = myDatabaseConnection.getGTDLevels(inTeamID)
        
        myGTDLevel = myGTDDetail.count + 1
        myTeamID = inTeamID
        myTitle = inLevelName
        
        save()
    }
    
    func save()
    {
        myDatabaseConnection.saveGTDLevel(myGTDLevel, inLevelName: myTitle, inTeamID: myTeamID)
    }
    
    func delete()
    { // Delete the current GTD Level and move the remaining ones up a level
        myDatabaseConnection.deleteGTDLevel(myGTDLevel, inTeamID: myTeamID)
        
        var currentLevel = myGTDLevel
        var boolLoop: Bool = true
        
        while boolLoop
        {
            let tempLevel = myDatabaseConnection.getGTDLevel(currentLevel + 1, inTeamID: myTeamID)
            
            if tempLevel.count == 0
            {  // reached the end, so do nothing
                boolLoop = false
            }
            else
            {  // There is another level so need to decrement the level count
                myDatabaseConnection.changeGTDLevel(currentLevel + 1, newGTDLevel: currentLevel, inTeamID: myTeamID)
                
                currentLevel++
            }
        }
    }
    
    func moveLevel(newLevel: Int)
    {
        if myGTDLevel > newLevel
        {
            // Move the existing entries first
            var levelCount: Int = myGTDLevel - 1
            // Dirty workaround.  Set the level for the one we are moving to a so weirdwe can reset it at the end
            
            myDatabaseConnection.changeGTDLevel(myGTDLevel, newGTDLevel: -99, inTeamID: myTeamID)
            
            while levelCount >= newLevel
            {
                NSLog("Move level \(levelCount)")
                let nextLevel = levelCount + 1
                myDatabaseConnection.changeGTDLevel(levelCount, newGTDLevel: nextLevel, inTeamID: myTeamID)
                levelCount--
            }
            myDatabaseConnection.changeGTDLevel(-99, newGTDLevel: newLevel, inTeamID: myTeamID)
        }
        else
        {
            NSLog("Moving down from location = \(myGTDLevel) name \(myTitle) new location = \(newLevel)")
            
            // Move the existing entries first
            var levelCount: Int = myGTDLevel + 1
            // Dirty workaround.  Set the level for the one we are moving to a so weirdwe can reset it at the end
            
            myDatabaseConnection.changeGTDLevel(myGTDLevel, newGTDLevel: -99, inTeamID: myTeamID)
            
            while levelCount <= newLevel
            {
                NSLog("Move level \(levelCount)")
                let nextLevel = levelCount - 1
                myDatabaseConnection.changeGTDLevel(levelCount, newGTDLevel: nextLevel, inTeamID: myTeamID)
                levelCount++
            }
            myDatabaseConnection.changeGTDLevel(-99, newGTDLevel: newLevel, inTeamID: myTeamID)

        }
    }
}

class workingGTDItem: NSObject
{
    private var myGTDItemID: Int = 0
    private var myGTDParentID: Int = 0
    private var myTitle: String = "New"
    private var myStatus: String = ""
    private var myChildren: [AnyObject] = Array()
    private var myTeamID: Int = 0
    private var myNote: String = ""
    private var myLastReviewDate: NSDate!
    private var myReviewFrequency: Int = 0
    private var myReviewPeriod: String = ""
    private var myPredecessor: Int = 0
    private var myGTDID: Int = 0
    private var myGTDLevel: Int = 0
    private var myStoreGTDLevel: Int = 0
    
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
 
    var GTDLevelID: Int
    {
        get
        {
            return myGTDID
        }
        set
        {
            myGTDID = newValue
            save()
        }
    }
    
    var GTDParentID: Int
    {
        get
        {
            return myGTDParentID
        }
        set
        {
            myGTDParentID = newValue
            save()
        }
    }
    
    var GTDLevel: Int
    {
        get
        {
            return myGTDLevel
        }
        set
        {
            myGTDLevel = newValue
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
    
    var children: [AnyObject]
    {
        get
        {
            return myChildren
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
            if myLastReviewDate == nil
            {
                myLastReviewDate = getDefaultDate()
                save()
                return ""
            }
            else if myLastReviewDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                let myDateFormatter = NSDateFormatter()
                myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                return myDateFormatter.stringFromDate(myLastReviewDate)
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
            save()
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
    
    init(inGTDItemID: Int, inTeamID: Int)
    {
        super.init()
        
        // Load the details
        
        if inGTDItemID == 0
        {
            // this is top level so have no details
            myTeamID = inTeamID
            myGTDLevel = 1
        }
        else
        {
            let myGTDDetail = myDatabaseConnection.getGTDItem(inGTDItemID, inTeamID: inTeamID)
        
            for myItem in myGTDDetail
            {
                myGTDItemID = myItem.gTDItemID as! Int
                myTitle = myItem.title!
                myStatus = myItem.status!
                myTeamID = myItem.teamID as! Int
                myNote = myItem.note!
                myLastReviewDate = myItem.lastReviewDate
                myReviewFrequency = myItem.reviewFrequency as! Int
                myReviewPeriod = myItem.reviewPeriod!
                myPredecessor = myItem.predecessor as! Int
                myGTDLevel = myItem.gTDLevel as! Int
                myGTDParentID = myItem.gTDParentID as! Int
            }
        }
        
        if myStoreGTDLevel == 0
        { // We only wantto do this once per instantiation of the object
            let tempTeam = myDatabaseConnection.getGTDLevels(myTeamID)
            
            myStoreGTDLevel = tempTeam.count
        }
        
        // Load the Members
        loadChildren()
    }
    
    init(inTeamID: Int, inParentID: Int)
    {
        super.init()
        
        myGTDItemID = myDatabaseConnection.getNextID("GTDItem")
        myGTDParentID = inParentID
        myLastReviewDate = getDefaultDate()
        myTeamID = inTeamID
        
        if myStoreGTDLevel == 0
        { // We only wantto do this once per instantiation of the object
            let tempTeam = myDatabaseConnection.getGTDLevels(myTeamID)
            
            myStoreGTDLevel = tempTeam.count
        }
        
        save()
    }
    
    func save()
    {
        myDatabaseConnection.saveGTDItem(myGTDItemID, inParentID: myGTDParentID, inTitle: myTitle, inStatus: myStatus, inTeamID: myTeamID, inNote: myNote, inLastReviewDate: myLastReviewDate, inReviewFrequency: myReviewFrequency, inReviewPeriod: myReviewPeriod, inPredecessor: myPredecessor, inGTDLevel: myGTDLevel)
    }
    
    func addChild(inChild: workingGTDItem)
    {
        inChild.GTDParentID = myGTDItemID
        loadChildren()
    }
    
    func removeChild(inChild: workingGTDItem)
    {
        inChild.GTDParentID = 0
        loadChildren()
    }
    
    func loadChildren()
    {
        // check to see if this is the bottom of the GTD hierarchy

        if myGTDLevel != myStoreGTDLevel
        { // Not bottom of hierarchy so get GTDITem as children
            let myChildrenList = myDatabaseConnection.getOpenGTDChildItems(myGTDItemID, inTeamID: myTeamID)
            myChildren.removeAll()
        
            for myItem in myChildrenList
            {
                let myNewChild = workingGTDItem(inGTDItemID: myItem.gTDItemID as! Int, inTeamID: myTeamID)
                myChildren.append(myNewChild)
            }
        }
        else
        {  // Bottom of GTD Hierarchy, so children are projects
            
            myChildren.removeAll()
            
            let myChildrenList = myDatabaseConnection.getOpenProjectsForGTDItem(myGTDItemID, inTeamID: myTeamID)
            
            for myItem in myChildrenList
            {
                // Check to see if the start date is in the future
                var boolAddProject: Bool = true
                
                if myItem.projectStartDate != getDefaultDate()
                {
                    if myItem.projectStartDate.compare(NSDate()) == NSComparisonResult.OrderedDescending
                    {  // Start date is in future
                        boolAddProject = false
                    }
                }
                
                if boolAddProject
                {
                    let myNewChild = project(inProjectID: myItem.projectID as Int)
                    myChildren.append(myNewChild)
                }
            }
        }
    }
    
    func delete() -> Bool
    {
        if myChildren.count > 0
        {
            return false
        }
        else
        {
            myStatus = "Deleted"
            save()
            
            // Need to see if this is in a predessor tree, if it is then we need to update so that this is skipped
            
            // Go and see if another item has set as its predecessor
            
            let fromCurrentPredecessor = myDatabaseConnection.getGTDItemSuccessor(myGTDItemID)
            
            if fromCurrentPredecessor > 0
            {  // This item is a predecessor
                let tempSuccessor = workingGTDItem(inGTDItemID: fromCurrentPredecessor, inTeamID: myTeamID)
                tempSuccessor.predecessor = myPredecessor
            }
            
            return true
        }
    }
}

class projectTeamMember: NSObject
{
    private var myProjectID: Int = 0
    private var myProjectMemberNotes: String = ""
    private var myRoleID: Int = 0
    private var myTeamMember: String = ""
    private var myTeamID: Int = 0

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

    var roleName: String
    {
        get
        {
            return myDatabaseConnection.getRoleDescription(myRoleID as Int, inTeamID: myTeamID)
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
    
    init(inProjectID: Int, inTeamMember: String, inRoleID: Int, inTeamID: Int)
    {
        super.init()
        myProjectID = inProjectID
        myTeamMember = inTeamMember
        myRoleID = inRoleID
        myTeamID = inTeamID
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
    private var myProjectName: String = "New project"
    private var myProjectStartDate: NSDate!
    private var myProjectStatus: String = ""
    private var myReviewFrequency: Int = 0
    private var myLastReviewDate: NSDate!
    private var myTeamMembers: [projectTeamMember] = Array()
    private var myTasks: [task] = Array()
    private var myGTDItemID: Int = 0
    private var myRepeatInterval: Int = 0
    private var myRepeatType: String = ""
    private var myRepeatBase: String = ""
    private var myTeamID: Int = 0
    private var myNote: String = ""
    private var myReviewPeriod: String = ""
    private var myPredecessor: Int = 0

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
            if myProjectEndDate == nil
            {
                myProjectEndDate = getDefaultDate()
                save()
                return ""
            }
            else if myProjectEndDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                let myDateFormatter = NSDateFormatter()
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
            if myProjectStartDate == nil
            {
                myProjectStartDate = getDefaultDate()
                save()
                return ""
            }
            else if myProjectStartDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                let myDateFormatter = NSDateFormatter()
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
            if myLastReviewDate == nil
            {
                myLastReviewDate = getDefaultDate()
                save()
                return ""
            }
            else if myLastReviewDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                let myDateFormatter = NSDateFormatter()
                myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                return myDateFormatter.stringFromDate(myLastReviewDate)
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
        
        myProjectEndDate = getDefaultDate()
        myProjectStartDate = getDefaultDate()
        myLastReviewDate = getDefaultDate()
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
            myProjectID = myProject.projectID as Int
            myProjectName = myProject.projectName
            myProjectStartDate = myProject.projectStartDate
            myProjectStatus = myProject.projectStatus
            myReviewFrequency = myProject.reviewFrequency as Int
            myLastReviewDate = myProject.lastReviewDate
            myGTDItemID = myProject.areaID as Int
            myRepeatInterval = myProject.repeatInterval as Int
            myRepeatType = myProject.repeatType
            myRepeatBase = myProject.repeatBase
            myTeamID = myProject.teamID as Int
                
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
                    myPredecessor = myItem.predecessor as Int
                }
            }
        }
    }
        
    func loadTeamMembers()
    {
        myTeamMembers.removeAll()
            
        let myProjectTeamMembers = myDatabaseConnection.getTeamMembers(myProjectID)
            
        for myTeamMember in myProjectTeamMembers
        {
            let myMember = projectTeamMember(inProjectID: myTeamMember.projectID as Int, inTeamMember: myTeamMember.teamMember, inRoleID: myTeamMember.roleID as Int, inTeamID: myTeamID )
            
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
        
    func addTask(inTask: task)
    {
        inTask.projectID = myProjectID
            
        loadTasks()
    }
        
    func removeTask(inTask: task)
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
            let myNewTask = task(taskID: myProjectTask.taskID as Int)
            myTasks.append(myNewTask)
        }
    }
    
    func save()
    {
        // Save Project
        
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
    }
    
    func checkForRepeat()
    {
        // Check to see if there is a repeat pattern
        var tempStartDate: NSDate = getDefaultDate()
        var tempEndDate: NSDate = getDefaultDate()
        
        if myRepeatInterval != 0
        {
            // Calculate new start and end dates, based on the repeat fields
            
            if myProjectStartDate == getDefaultDate() && myProjectEndDate == getDefaultDate()
            {  // No dates have set, so we set the start date
                tempStartDate = calculateNewDate(NSDate(), inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
            }
            else
            { // A date has been set in at least one of the fields, so we use that as the date to set
                
                // If both start and end dates are set then we want to make sure we keep interval between them the same, so we need to work out the time to add
                
                var daysToAdd: Int = 0
                
                if myProjectStartDate != getDefaultDate() && myProjectEndDate != getDefaultDate()
                {
                    let calendar = NSCalendar.currentCalendar()
                
                    let components = calendar.components([.Day], fromDate: myProjectStartDate, toDate: myProjectEndDate, options: [])
                
                    daysToAdd = components.day
                }
                
                if myProjectStartDate != getDefaultDate()
                {
                    tempStartDate = calculateNewDate(NSDate(), inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
                }
            
                if myProjectEndDate != getDefaultDate()
                {
                    let calendar = NSCalendar.currentCalendar()
                    
                    let tempDate = calendar.dateByAddingUnit(
                            [.Day],
                            value: daysToAdd,
                            toDate: NSDate(),
                            options: [])!
                    
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
           
            let myProjectTeamMembers = myDatabaseConnection.getTeamMembers(myProjectID)
            
            for myTeamMember in myProjectTeamMembers
            {
                let myMember = projectTeamMember(inProjectID: newProject.projectID as Int, inTeamMember: myTeamMember.teamMember, inRoleID: myTeamMember.roleID as Int, inTeamID: myTeamID )
                
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
                myNewTask.estimatedTime = myProjectTask.estimatedTime as Int
                myNewTask.estimatedTimeType = myProjectTask.estimatedTimeType
                myNewTask.projectID = newProject.projectID
                myNewTask.repeatInterval = myProjectTask.repeatInterval as Int
                myNewTask.repeatType = myProjectTask.repeatType
                myNewTask.repeatBase = myProjectTask.repeatBase
                myNewTask.flagged = myProjectTask.flagged as Bool
                myNewTask.urgency = myProjectTask.urgency
     
                let myContextList = myDatabaseConnection.getContextsForTask(myProjectTask.taskID as Int)
                
                for myContextItem in myContextList
                {
                    myNewTask.addContext(myContextItem.contextID as Int)
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
    private var myTitle: String = "New task"
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
            if myDueDate == nil
            {
                myDueDate = getDefaultDate()
                save()
                return ""
            }
            else if myDueDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                let myDateFormatter = NSDateFormatter()
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
            if myStartDate == nil
            {
                myStartDate = getDefaultDate()
                save()
                return ""
            }
            else if myStartDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                let myDateFormatter = NSDateFormatter()
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
            if newValue == "Complete"
            {
                checkForRepeat()
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
            
            // Check the team ID for the new project.  If it is different than the current teamID then change the tasks teamID
            
            let tempProject = myDatabaseConnection.getProjectDetails(projectID)
            
            if tempProject.count > 0
            {
                myTeamID = tempProject[0].teamID as Int
            }
            
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
            if myCompletionDate == nil
            {
                myCompletionDate = getDefaultDate()
                save()
                return ""
            }
            else if myCompletionDate == getDefaultDate()
            {
                return ""
            }
            else
            {
                let myDateFormatter = NSDateFormatter()
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
    
    init(inTeamID: Int)
    {
        super.init()
        
        myTaskID = myDatabaseConnection.getNextID("Task")
        
        myDueDate = getDefaultDate()
        myStartDate = getDefaultDate()
        myCompletionDate = getDefaultDate()
        myStatus = "Open"
        
        myTitle = "New Task"
        myTeamID = inTeamID
    
        save()
    }
    
    init(taskID: Int)
    {
        let myTaskData = myDatabaseConnection.getTask(taskID)
        
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
            
            let myContextList = myDatabaseConnection.getContextsForTask(taskID)
            myContexts.removeAll()
            
            for myContextItem in myContextList
            {
                let myNewContext = context(contextID: myContextItem.contextID as Int)
                myContexts.append(myNewContext)
            }
            
            let myPredecessorList = myDatabaseConnection.getTaskPredecessors(taskID)
            
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
    
    func addContext(contextID: Int)
    {
        var itemFound: Bool = false
        
        // first we need to make sure the context is not already present
        
        // Get the context name
        
        let myContext = context(contextID: contextID)
        
        let myCheck = myDatabaseConnection.getContextsForTask(myTaskID)
        
        for myItem in myCheck
        {
            let myRetrievedContext = context(contextID: myItem.contextID as Int)
            if myRetrievedContext.name.lowercaseString == myContext.name.lowercaseString
            {
                itemFound = true
                break
            }
        }
        
        if !itemFound
        { // Not match found
            myDatabaseConnection.saveTaskContext(contextID, inTaskID: myTaskID)
        
            let myContextList = myDatabaseConnection.getContextsForTask(myTaskID)
            myContexts.removeAll()
        
            for myContextItem in myContextList
            {
                let myNewContext = context(contextID: myContextItem.contextID as Int)
                myContexts.append(myNewContext)
            }
        }
    }
    
    func removeContext(contextID: Int)
    {
        myDatabaseConnection.deleteTaskContext(contextID, inTaskID: myTaskID)
        
        let myContextList = myDatabaseConnection.getContextsForTask(myTaskID)
        myContexts.removeAll()
        
        for myContextItem in myContextList
        {
            let myNewContext = context(contextID: myContextItem.contextID as Int)
            myContexts.append(myNewContext)
        }
    }
    
    func delete() -> Bool
    {
        myStatus = "Deleted"
        save()
        return true
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
    
    func markComplete()
    {
        checkForRepeat()
        myCompletionDate = NSDate()
        myStatus = "Complete"
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
        
        if inTargetString.characters.count > 0
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
        
        myLine = "                \(myTitle)"
        myExportString = writeLine(myExportString, inLineString: myLine)
        
        myExportString = writeLine(myExportString, inLineString: "")
        
        myLine = "\(myDetails)"
        myExportString = writeLine(myExportString, inLineString: myLine)
        
        myExportString = writeLine(myExportString, inLineString: "")
        
        if myProjectID > 0
        {
            let myData3 = myDatabaseConnection.getProjectDetails(myProjectID)
            
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
        
        if inTargetString.characters.count > 0
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
            let myData3 = myDatabaseConnection.getProjectDetails(myProjectID)
            
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
    
    func checkForRepeat()
    {
        // Check to see if there is a repeat pattern
        var tempStartDate: NSDate = getDefaultDate()
        var tempEndDate: NSDate = getDefaultDate()
        
        if myRepeatInterval != 0
        {
            // Calculate new start and end dates, based on the repeat fields
            
            if myStartDate == getDefaultDate() && myDueDate == getDefaultDate()
            {  // No dates have set, so we set the start date
                tempStartDate = calculateNewDate(NSDate(), inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
            }
            else
            { // A date has been set in at least one of the fields, so we use that as the date to set
                
                // If both start and end dates are set then we want to make sure we keep interval between them the same, so we need to work out the time to add
                
                var daysToAdd: Int = 0
                
                if myStartDate != getDefaultDate() && myDueDate != getDefaultDate()
                {
                    let calendar = NSCalendar.currentCalendar()
                    
                    let components = calendar.components([.Day], fromDate: myStartDate, toDate: myDueDate, options: [])
                    
                    daysToAdd = components.day
                }
                
                let now: NSDate = NSDate()
                let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let dateComponents: NSDateComponents = gregorian.components([.Year, .Month, .Day], fromDate: now)
                let todayDate: NSDate = gregorian.dateFromComponents(dateComponents)!

                if myStartDate != getDefaultDate()
                {
                    if myRepeatBase == "Start Date"
                    {
                        tempStartDate = calculateNewDate(myStartDate, inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
                    }
                    else
                    {
                        tempStartDate = calculateNewDate(todayDate, inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
                    }
                }
                
                if myDueDate != getDefaultDate()
                {
                    let calendar = NSCalendar.currentCalendar()
                    
                    let tempDate = calendar.dateByAddingUnit(
                        [.Day],
                        value: daysToAdd,
                        toDate: todayDate,
                        options: [])!
                    
                    tempEndDate = calculateNewDate(tempDate, inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
                }
            }
            
            // Create new task
            
            let newTask = task(inTeamID: myTeamID)
            newTask.title = myTitle
            newTask.details = myDetails
            newTask.dueDate = tempEndDate
            newTask.startDate = tempStartDate
            newTask.status = "Open"
            newTask.priority = myPriority
            newTask.energyLevel = myEnergyLevel
            newTask.estimatedTime = myEstimatedTime
            newTask.estimatedTimeType = myEstimatedTimeType
            newTask.projectID = myProjectID
            newTask.repeatInterval = myRepeatInterval
            newTask.repeatType = myRepeatType
            newTask.repeatBase = myRepeatBase
            newTask.flagged = myFlagged
            newTask.urgency = myUrgency
            
            // Populate Contexts
            
            for myContext in myContexts
            {
                newTask.addContext(myContext.contextID)
            }
            
            // populate Predecessors

            for myPredecessor in myPredecessors
            {
                newTask.addPredecessor(myPredecessor.predecessorID, inPredecessorType: myPredecessor.predecessorType)
            }
        }
    }
}

class contexts: NSObject
{
    private var myContexts:[context] = Array()
    private var myPeopleContexts:[context] = Array()
    private var myPlaceContexts:[context] = Array()
    private var myToolContexts:[context] = Array()
    
    override init()
    {
        for myItem in myDatabaseConnection.getContextsForType("Person")
        {
            let myItemDetails = myDatabaseConnection.getContextDetails(myItem.contextID as! Int)
  
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: myItem.contextID as! Int)
                myPeopleContexts.append(myContext)
                myContexts.append(myContext)
            }
        }
        
        myPeopleContexts.sortInPlace { $0.name < $1.name }
        
        for myItem in myDatabaseConnection.getContextsForType("Place")
        {
            let myItemDetails = myDatabaseConnection.getContextDetails(myItem.contextID as! Int)
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: myItem.contextID as! Int)
                myPlaceContexts.append(myContext)
                myContexts.append(myContext)
            }
        }
        
        myPlaceContexts.sortInPlace { $0.name < $1.name }
        
        for myItem in myDatabaseConnection.getContextsForType("Tool")
        {
            let myItemDetails = myDatabaseConnection.getContextDetails(myItem.contextID as! Int)
            
            if myItemDetails.count > 0
            {
                let myContext = context(contextID: myItem.contextID as! Int)
                myToolContexts.append(myContext)
                myContexts.append(myContext)
            }
        }
        
        myToolContexts.sortInPlace { $0.name < $1.name }
        
        myContexts.sortInPlace { $0.name < $1.name }
    }
    

    var allContexts: [context]
    {
        get
        {
            return myContexts
        }
    }

    var people: [context]
    {
        get
        {
            return myPeopleContexts
        }
    }

    
    var places: [context]
    {
        get
        {
            return myPlaceContexts
        }
    }

    
    var tools: [context]
    {
        get
        {
            return myToolContexts
        }
    }

    
    /*
   var contextsByHierarchy: [context]
    {
        get
        {
            var workingArray: [context] = Array()
            
            workingArray = myContexts
            
            workingArray.sortInPlace { $0.contextHierarchy < $1.contextHierarchy }
            
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
            
            workingArray.sortInPlace { $0.contextHierarchy < $1.contextHierarchy }
            
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
            
            workingArray.sortInPlace { $0.contextHierarchy < $1.contextHierarchy }
            
            return workingArray
        }
    }
   */
}

class context: NSObject
{
    private var myContextID: Int = 0
    private var myName: String = "New context"
    private var myEmail: String = ""
    private var myAutoEmail: String = ""
    private var myParentContext: Int = 0
    private var myStatus: String = ""
    private var myPersonID: Int = 0
    private var myTeamID: Int = 0
    private var myPredecessor: Int = 0
    private var myContextType: String = ""
    
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
    
    var contextType: String
    {
        get
        {
            return myContextType
        }
        set
        {
            myContextType = newValue
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
                let theParent = context(contextID: myParentContext)
                retString = "\(theParent.contextHierarchy) - \(myName)"
            }
        
            return retString
        }
    }
    
    var personID: Int
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
    
    func removeWhitespace(string: String) -> String {
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!$0.characters.isEmpty})
        return components.joinWithSeparator(" ")
    }
    
    
    init(inTeamID: Int)
    {
        super.init()
        
        myContextID = myDatabaseConnection.getNextID("Context")
        myTeamID = inTeamID
        
        save()
    }
    
    init(inContextName: String)
    {
        super.init()
 //       var matchFound: Bool = false
        
        let myContextList = contexts()
        
        // String of any unneeded whilespace
        
        let strippedContext = removeWhitespace(inContextName)
        
        for myContext in myContextList.allContexts
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
                myContextType = myContext.contextType

 //               matchFound = true
                
                getContext1_1()
                
                break
            }
        }
        
/*
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
                    myPersonID = Int(ABRecordGetRecordID(myPersonEmail))
                }
                else
                {  // No match so use text passed in
                    myName = strippedContext
                }
            }
            else
            {
                myName = ABRecordCopyCompositeName(myPerson).takeRetainedValue() as String
                myPersonID = Int(ABRecordGetRecordID(myPerson))
            }
            save()
        }
*/
    }
    
    init(contextID: Int)
    {
        super.init()
        let myContexts = myDatabaseConnection.getContextDetails(contextID)
        
        for myContext in myContexts
        {
            myContextID = myContext.contextID as Int
            myName = myContext.name
            myEmail = myContext.email
            myAutoEmail = myContext.autoEmail
            myParentContext = myContext.parentContext as Int
            myStatus = myContext.status
            myPersonID = myContext.personID as Int
            myTeamID = myContext.teamID as Int
            
            getContext1_1()
        }
    }
    
    init(inContext: Context)
    {
        super.init()
        myContextID = inContext.contextID as Int
        myName = inContext.name
        myEmail = inContext.email
        myAutoEmail = inContext.autoEmail
        myParentContext = inContext.parentContext as Int
        myStatus = inContext.status
        myPersonID = inContext.personID as Int
        myTeamID = inContext.teamID as Int
        
        getContext1_1()
    }
    
    
    private func getContext1_1()
    {
        // Get context1_1
        
        let myNotes = myDatabaseConnection.getContext1_1(myContextID)
        
        if myNotes.count == 0
        {
            myPredecessor = 0
            myContextType = ""
        }
        else
        {
            for myItem in myNotes
            {
                myPredecessor = myItem.predecessor as! Int
                myContextType = myItem.contextType!
            }
        }

    }
    
    func save()
    {
        myDatabaseConnection.saveContext(myContextID, inName: myName, inEmail: myEmail, inAutoEmail: myAutoEmail, inParentContext: myParentContext, inStatus: myStatus, inPersonID: myPersonID, inTeamID: myTeamID)
        
        myDatabaseConnection.saveContext1_1(myContextID, predecessor: myPredecessor, contextType: myContextType)
    }
    
    func delete() -> Bool
    {
        if allTasks.count > 0
        {
            return false
        }
        else
        {
            //myDatabaseConnection.deleteContext(myContextID, inTeamID: myTeamID)
            myStatus = "Deleted"
            save()
            return true
        }
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
            let myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            myDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            return myDateFormatter.stringFromDate(myUpdateDate)
        }
    }
    
    var displayShortUpdateDate: String
    {
        get
        {
            let myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myUpdateDate)
        }
    }
    
    var displayShortUpdateTime: String
    {
        get
        {
            let myDateFormatter = NSDateFormatter()
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

class tasks: NSObject
{
    var myActiveTasks: [task] = Array()
    var myTasks: [task] = Array()
    
    var activeTasks: [task]
    {
        get
        {
            return myActiveTasks
        }
    }
    
    var allTasks: [task]
    {
        get
        {
            return myTasks
        }
    }

    init(projectID: Int)
    {
        super.init()
        
        // check to see if the project is on hold
        
        let myProject = project(inProjectID: projectID)
     
        if myProject.projectStatus != "On Hold"
        {
            loadActiveTasksForProject(projectID)
        }
    }
    
    init(contextID: Int)
    {
        super.init()
        
        loadActiveTasksForContext(contextID)
    }
    
    func loadActiveTasksForContext(contextID: Int)
    {
        myActiveTasks.removeAll()
        
        let myTaskContextList = myDatabaseConnection.getTasksForContext(contextID)
        
        for myTaskContext in myTaskContextList
        {
            // Get the context details
            let myTaskList = myDatabaseConnection.getActiveTask(myTaskContext.taskID as Int)
            
            for myTask in myTaskList
            {  //append project details to work array
                // check the project to see if it is on hold
                
                let myProject = project(inProjectID: myTask.projectID as Int)
                
                if myProject.projectStatus != "On Hold"
                {
                    let tempTask = task(taskID: myTask.taskID as Int)
                    myActiveTasks.append(tempTask)
                }
            }
        }
        
        myActiveTasks.sortInPlace({$0.dueDate.timeIntervalSinceNow < $1.dueDate.timeIntervalSinceNow})
    }
    
    func loadActiveTasksForProject(projectID: Int)
    {
        myActiveTasks.removeAll()
        
        var taskList = myDatabaseConnection.getActiveTasksForProject(projectID)
        
        taskList.sortInPlace({$0.dueDate.timeIntervalSinceNow < $1.dueDate.timeIntervalSinceNow})
        
        for myItem in taskList
        {
            let tempTask = task(taskID: myItem.taskID as Int)
            
            myActiveTasks.append(tempTask)
        }
    }
    
    func loadAllTasksForProject(projectID: Int)
    {
        myTasks.removeAll()
        
        var taskList = myDatabaseConnection.getTasksForProject(projectID)
        
        taskList.sortInPlace({$0.dueDate.timeIntervalSinceNow < $1.dueDate.timeIntervalSinceNow})
        
        for myItem in taskList
        {
            let tempTask = task(taskID: myItem.taskID as Int)
            
            myTasks.append(tempTask)
        }
    }
}

#if os(iOS)
    class GTDModel: NSObject
    {
        private var myDelegate: MyMaintainProjectDelegate!
        private var myActionSource: String = ""
        
        var delegate: MyMaintainProjectDelegate
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
        
        var actionSource: String
            {
            get
            {
                return myActionSource
            }
            set
            {
                myActionSource = newValue
            }
        }
    }
#endif

