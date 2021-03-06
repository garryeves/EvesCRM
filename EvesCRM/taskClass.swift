//
//  taskClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

let taskStatusOpen = "Open"
let taskStatusClosed = "Closed"
let taskStatusOnHold = "On Hold"

class tasks: NSObject
{
    var myActiveTasks: [task] = Array()
    var myTasks: [task] = Array()
    var myTeamID: Int = 0
    
    var tasks: [task]
    {
        get
        {
            return myActiveTasks
        }
    }
    
//    var allTasks: [task]
//    {
//        get
//        {
//            return myTasks
//        }
//    }
    
    init(projectID: Int, teamID: Int)
    {
        super.init()
        
        // check to see if the project is on hold
        
        let myProject = project(projectID: projectID, teamID: teamID)
        myTeamID = teamID
        if myProject.projectStatus != "On Hold"
        {
            loadActiveTasksForProject(projectID)
        }
    }
    
    init(contextID: Int, contextType: String, teamID: Int, loadAll: Bool)
    {
        super.init()
        myTeamID = teamID
        loadTasksForContext(contextID, contextType: contextType, loadAll: loadAll)
    }
    
    func loadTasksForContext(_ contextID: Int, contextType: String, loadAll: Bool)
    {
        myActiveTasks.removeAll()
        
        let myTaskContextList = myDatabaseConnection.getTasksForContext(contextID, teamID: myTeamID, contextType: contextType)
        
        for myTaskContext in myTaskContextList
        {
            // Get the context details
            let myTaskList = myDatabaseConnection.getActiveTask(Int(myTaskContext.taskID), teamID: myTeamID)
            
            for myTask in myTaskList
            {  //append project details to work array
                // check the project to see if it is on hold
                if loadAll || myTask.status == taskStatusOpen
                {
                    let myProject = project(projectID: Int(myTask.projectID), teamID: myTeamID)
                    
                    if myProject.projectStatus != "On Hold"
                    {
                        let tempTask = task(taskID: Int(myTask.taskID), teamID: myTeamID)
                        myActiveTasks.append(tempTask)
                    }
                }
            }
        }
        
        myActiveTasks.sort(by: {$0.dueDate.timeIntervalSinceNow < $1.dueDate.timeIntervalSinceNow})
    }
    
    func loadActiveTasksForProject(_ projectID: Int)
    {
        myActiveTasks.removeAll()
        
        var taskList = myDatabaseConnection.getActiveTasksForProject(projectID, teamID: myTeamID)
        
        taskList.sort(by: {$0.dueDate!.timeIntervalSinceNow < $1.dueDate!.timeIntervalSinceNow})
        
        for myItem in taskList
        {
            let tempTask = task(taskID: Int(myItem.taskID), teamID: myTeamID)
            
            myActiveTasks.append(tempTask)
        }
    }
    
    func loadAllTasksForProject(_ projectID: Int)
    {
        myTasks.removeAll()
        
        var taskList = myDatabaseConnection.getTasksForProject(projectID, teamID: myTeamID)
        
        taskList.sort(by: {$0.dueDate!.timeIntervalSinceNow < $1.dueDate!.timeIntervalSinceNow})
        
        for myItem in taskList
        {
            let tempTask = task(taskID: Int(myItem.taskID), teamID: myTeamID)
            
            myTasks.append(tempTask)
        }
    }
}

class task: NSObject
{
    fileprivate var myTaskID: Int = 0
    fileprivate var myTitle: String = "New task"
    fileprivate var myDetails: String = ""
    fileprivate var myDueDate: Date!
    fileprivate var myStartDate: Date!
    fileprivate var myStatus: String = ""
    fileprivate var myContexts: [context] = Array()
    fileprivate var myPriority: String = ""
    fileprivate var myEnergyLevel: String = ""
    fileprivate var myEstimatedTime: Int = 0
    fileprivate var myEstimatedTimeType: String = ""
    fileprivate var myProjectID: Int = 0
    fileprivate var myCompletionDate: Date!
    fileprivate var myRepeatInterval: Int = 0
    fileprivate var myRepeatType: String = ""
    fileprivate var myRepeatBase: String = ""
    fileprivate var myFlagged: Bool = false
    fileprivate var myUrgency: String = ""
    fileprivate var myTeamID: Int = 0
    fileprivate var myPredecessors: [taskPredecessor] = Array()
    fileprivate var saveCalled: Bool = false
    fileprivate var myMeetingID:String = ""
    
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
    
    var dueDate: Date
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
                return ""
            }
            else if myDueDate == getDefaultDate() as Date
            {
                return ""
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = DateFormatter.Style.medium
                return myDateFormatter.string(from: myDueDate)
            }
        }
    }
    
    var startDate: Date
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
                return ""
            }
            else if myStartDate == getDefaultDate() as Date
            {
                return ""
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = DateFormatter.Style.medium
                return myDateFormatter.string(from: myStartDate)
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
                myCompletionDate = Date()
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
//        set
//        {
//            myContexts = newValue
//            save()
//        }
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
            
            let tempProject = myDatabaseConnection.getProjectDetails(projectID, teamID: myTeamID)
            
            if tempProject.count > 0
            {
                myTeamID = Int(tempProject[0].teamID)
            }
            save()
        }
    }
    
    var history: [taskUpdates]
    {
        var myHistory: [taskUpdates] = Array()
        
        let myHistoryRows = myDatabaseConnection.getTaskUpdates(myTaskID, teamID: myTeamID)
        
        for myHistoryRow in myHistoryRows
        {
            let myItem = taskUpdates(updateObject: myHistoryRow)
            myHistory.append(myItem)
        }
        
        return myHistory
    }
    
    var completionDate: Date
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
                return ""
            }
            else if myCompletionDate == getDefaultDate() as Date
            {
                return ""
            }
            else
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = DateFormatter.Style.medium
                return myDateFormatter.string(from: myCompletionDate)
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
    
    var meetingID: String
    {
        get
        {
            return myMeetingID
        }
        set
        {
            myMeetingID = newValue
        }
    }
    
    
    
    var teamID: Int
    {
        get
        {
            return myTeamID
        }
    }
    
    var predecessors: [taskPredecessor]
    {
        get
        {
            return myPredecessors
        }
    }
    
    init(teamID: Int)
    {
        super.init()
        
        myTaskID = myDatabaseConnection.getNextID("Task", teamID: teamID)
        
        myDueDate = getDefaultDate() as Date!
        myStartDate = getDefaultDate() as Date!
        myCompletionDate = getDefaultDate() as Date!
        myStatus = taskStatusOpen
        
        myTitle = "New Task"
        myTeamID = teamID
        
        save()
    }
    
    init(taskID: Int, teamID: Int)
    {
        super.init()
        let myTaskData = myDatabaseConnection.getTask(taskID, teamID: teamID)
        
        for myTask in myTaskData
        {
            myTaskID = Int(myTask.taskID)
            myTitle = myTask.title!
            myDetails = myTask.details!
            myDueDate = myTask.dueDate! as Date
            myStartDate = myTask.startDate! as Date
            myStatus = myTask.status!
            myPriority = myTask.priority!
            myEnergyLevel = myTask.energyLevel!
            myEstimatedTime = Int(myTask.estimatedTime)
            myEstimatedTimeType = myTask.estimatedTimeType!
            myProjectID = Int(myTask.projectID)
            myCompletionDate = myTask.completionDate! as Date
            myRepeatInterval = Int(myTask.repeatInterval)
            myRepeatType = myTask.repeatType!
            myRepeatBase = myTask.repeatBase!
            myFlagged = myTask.flagged as! Bool
            myUrgency = myTask.urgency!
            myTeamID = Int(myTask.teamID)
            
            // get contexts
            
            loadContexts()
            
            let myPredecessorList = myDatabaseConnection.getTaskPredecessors(taskID, teamID: teamID)
            
            myPredecessors.removeAll()
            
            for myPredecessorItem in myPredecessorList
            {
                let myNewPredecessor = taskPredecessor(predecessorID: Int(myPredecessorItem.predecessorID), predecessorType: myPredecessorItem.predecessorType!, teamID: teamID)
                myPredecessors.append(myNewPredecessor)
            }
        }
    }
    
    init(oldTask: task, startDate: Date, dueDate: Date)
    {
        super.init()
        
        myTaskID = myDatabaseConnection.getNextID("Task", teamID: oldTask.teamID)
        myTitle = oldTask.title
        myDetails = oldTask.details
        myDueDate = dueDate
        myStartDate = startDate
        myStatus = "Open"
        myPriority = oldTask.priority
        myEnergyLevel = oldTask.energyLevel
        myEstimatedTime = oldTask.estimatedTime
        myEstimatedTimeType = oldTask.estimatedTimeType
        myProjectID = oldTask.projectID
        myCompletionDate = oldTask.completionDate
        myRepeatInterval = oldTask.repeatInterval
        myRepeatType = oldTask.repeatType
        myRepeatBase = oldTask.repeatBase
        myFlagged = oldTask.flagged as Bool
        myUrgency = oldTask.urgency
        myTeamID = oldTask.teamID
        
        save()
        
        // get contexts
        
        myContexts.removeAll()
        
        for myContextItem in oldTask.contexts
        {
            myDatabaseConnection.saveTaskContext(myContextItem.contextID, taskID: myTaskID, teamID: teamID, contextType: myContextItem.contextType)
        }
        
        myPredecessors.removeAll()
        
        for myPredecessorItem in oldTask.predecessors
        {
            myDatabaseConnection.savePredecessorTask(myTaskID, predecessorID: myPredecessorItem.predecessorID, predecessorType: myPredecessorItem.predecessorType, teamID: teamID)
        }
    }
    
    func loadContexts()
    {
        let myContextList = myDatabaseConnection.getContextsForTask(taskID, teamID: teamID)
        myContexts.removeAll()
        
        for myContextItem in myContextList
        {
            let myNewContext = context(contextID: Int(myContextItem.contextID), teamID: teamID, contextType: myContextItem.contextType!)
            myContexts.append(myNewContext)
        }
    }
    
    func save()
    {
        if myDueDate == nil
        {
            myDueDate = getDefaultDate() as Date!
        }
        
        if myStartDate == nil
        {
            myStartDate = getDefaultDate() as Date!
        }
        
        if myCompletionDate == nil
        {
            myCompletionDate = getDefaultDate() as Date!
        }
        
        myDatabaseConnection.saveTask(myTaskID, title: myTitle, details: myDetails, dueDate: myDueDate, startDate: myStartDate, status: myStatus, priority: myPriority, energyLevel: myEnergyLevel, estimatedTime: myEstimatedTime, estimatedTimeType: myEstimatedTimeType, projectID: myProjectID, completionDate: myCompletionDate!, repeatInterval: myRepeatInterval, repeatType: myRepeatType, repeatBase: myRepeatBase, flagged: myFlagged, urgency: myUrgency, teamID: myTeamID)
        
//        if !saveCalled
//        {
//            saveCalled = true
//            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
//        }
    }
    
//    func performSave()
//    {
//        let myTask = myDatabaseConnection.getTaskRegardlessOfStatus(myTaskID, teamID: teamID)[0]
//
//        myCloudDB.saveTaskRecordToCloudKit(myTask)
//
//        // Save context link
//
//        for myContext in myContexts
//        {
//            myDatabaseConnection.saveTaskContext(myContext.contextID, taskID: myTaskID, teamID: teamID, contextType: myContext.contextType)
//        }
//
//        saveCalled = false
//    }
    
    func addContext(_ contextID: Int, contextType: String)
    {
        var itemFound: Bool = false
        
        // first we need to make sure the context is not already present
        
        let myCheck = myDatabaseConnection.getContextsForTask(myTaskID, teamID: teamID)

        for myItem in myCheck
        {
            if myItem.contextType == contextType && myItem.contextID == contextID
            {
                itemFound = true
                break
            }
        }
        
        // Get the context name
        
        if !itemFound
        { // Not match found
            myDatabaseConnection.saveTaskContext(contextID, taskID: myTaskID, teamID: teamID, contextType: contextType)
            
            loadContexts()
        }
    }
    
    func removeContext(_ contextID: Int)
    {
        myDatabaseConnection.deleteTaskContext(contextID, taskID: myTaskID, teamID: teamID)
        
        loadContexts()
    }
    
    func delete() -> Bool
    {
        myStatus = "Deleted"
        save()
        return true
    }
    
    func addHistoryRecord(_ historyDetails: String, historySource: String)
    {
        let myItem = taskUpdates(taskID: myTaskID, teamID: teamID)
        myItem.details = historyDetails
        myItem.source = historySource
        
        myItem.save()
    }
    
    func addPredecessor(_ predecessorID: Int, predecessorType: String)
    {
        myDatabaseConnection.savePredecessorTask(myTaskID, predecessorID: predecessorID, predecessorType: predecessorType, teamID: teamID)
    }
    
    func removePredecessor(_ predecessorID: Int, predecessorType: String)
    {
        myDatabaseConnection.deleteTaskPredecessor(myTaskID, predecessorID: predecessorID, teamID: teamID)
    }
    
    func changePredecessor(_ predecessorID: Int, predecessorType: String)
    {
        myDatabaseConnection.updatePredecessorTaskType(myTaskID, predecessorID: predecessorID, predecessorType: predecessorType, teamID: teamID)
    }
    
    func markComplete()
    {
        checkForRepeat()
        myCompletionDate = Date()
        myStatus = "Complete"
        save()
    }
    
    func reopen()
    {
        myStatus = "Open"
        save()
    }
    
    fileprivate func writeLine(_ targetString: String, lineString: String) -> String
    {
        var myString = targetString
        
        if targetString.characters.count > 0
        {
            myString += "\n"
        }
        
        myString += lineString
        
        return myString
    }
    
    func buildShareString() -> String
    {
        var myExportString: String = ""
        var myLine: String = ""
        
        myLine = "                \(myTitle)"
        myExportString = writeLine(myExportString, lineString: myLine)
        
        myExportString = writeLine(myExportString, lineString: "")
        
        myLine = "\(myDetails)"
        myExportString = writeLine(myExportString, lineString: myLine)
        
        myExportString = writeLine(myExportString, lineString: "")
        
        if myProjectID > 0
        {
            let myData3 = myDatabaseConnection.getProjectDetails(myProjectID, teamID: teamID)
            
            if myData3.count != 0
            {
                myLine = "Project: \(myData3[0].projectName!)"
                myExportString = writeLine(myExportString, lineString: myLine)
                myExportString = writeLine(myExportString, lineString: "")
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
        
        myExportString = writeLine(myExportString, lineString: myLine)
        
        myExportString = writeLine(myExportString, lineString: "")
        
        if myContexts.count > 0
        {
            myLine = "Contexts"
            myExportString = writeLine(myExportString, lineString: myLine)
            
            for myContext in myContexts
            {
                myLine = "\(myContext.name)"
                myExportString = writeLine(myExportString, lineString: myLine)
            }
            
            myExportString = writeLine(myExportString, lineString: "")
            myExportString = writeLine(myExportString, lineString: "")
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
        
        myExportString = writeLine(myExportString, lineString: myLine)
        
        if history.count > 0
        { //  task updates displayed here
            myExportString = writeLine(myExportString, lineString: "")
            myExportString = writeLine(myExportString, lineString: "")
            myLine = "Update history"
            myExportString = writeLine(myExportString, lineString: myLine)
            
            for myItem in history
            {
                myLine = "||\(myItem.displayUpdateDate)"
                myLine += "||\(myItem.source)"
                myLine += "||\(myItem.details)||"
                myExportString = writeLine(myExportString, lineString: myLine)
            }
        }
        
        return myExportString
    }
    
    fileprivate func writeHTMLLine(_ targetString: String, lineString: String) -> String
    {
        var myString = targetString
        
        if targetString.characters.count > 0
        {
            myString += "<p>"
        }
        
        myString += lineString
        
        return myString
    }
    
    func buildShareHTMLString() -> String
    {
        var myExportString: String = ""
        var myLine: String = ""
        var myContextTable: String = ""
        
        myLine = "<html><body><h3><center>\(myTitle)</center></h3>"
        myExportString = writeHTMLLine(myExportString, lineString: myLine)
        
        myExportString = writeHTMLLine(myExportString, lineString: "")
        
        myLine = "\(myDetails)"
        myExportString = writeHTMLLine(myExportString, lineString: myLine)
        
        myExportString = writeHTMLLine(myExportString, lineString: "")
        
        if myProjectID > 0
        {
            let myData3 = myDatabaseConnection.getProjectDetails(myProjectID, teamID: myTeamID)
            
            if myData3.count != 0
            {
                myLine = "Project: \(myData3[0].projectName!)"
                myExportString = writeHTMLLine(myExportString, lineString: myLine)
                myExportString = writeHTMLLine(myExportString, lineString: "")
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
        
        myExportString = writeHTMLLine(myExportString, lineString: myLine)
        
        myExportString = writeHTMLLine(myExportString, lineString: "")
        
        if myContexts.count > 0
        {
            myLine = "<h4>Contexts</h4>"
            myExportString = writeHTMLLine(myExportString, lineString: myLine)
            
            myContextTable = "<table>"
            
            for myContext in myContexts
            {
                myContextTable += "<tr><td>\(myContext.name)</td></tr>"
            }
            
            myContextTable += "</table>"
            myExportString = writeHTMLLine(myExportString, lineString: myContextTable)
            myExportString = writeHTMLLine(myExportString, lineString: "")
            myExportString = writeHTMLLine(myExportString, lineString: "")
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
        
        myExportString = writeHTMLLine(myExportString, lineString: myLine)
        
        if history.count > 0
        { //  task updates displayed here
            myExportString = writeHTMLLine(myExportString, lineString: "")
            myExportString = writeHTMLLine(myExportString, lineString: "")
            myLine = "<h4>Update history</h4>"
            myExportString = writeHTMLLine(myExportString, lineString: myLine)
            
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
            myExportString = writeHTMLLine(myExportString, lineString: myContextTable)
        }
        
        myExportString = writeHTMLLine(myExportString, lineString: "</body></html>")
        
        return myExportString
    }
    
    func checkForRepeat()
    {
        // Check to see if there is a repeat pattern
        var tempStartDate: Date = getDefaultDate() as Date
        var tempDueDate: Date = getDefaultDate() as Date
        
        if myRepeatInterval != 0
        {
            // Calculate new start and end dates, based on the repeat fields
            
            if myStartDate == getDefaultDate() as Date && myDueDate == getDefaultDate() as Date
            {  // No dates have set, so we set the start date
                tempStartDate = Date().calculateNewDate(dateBase:myRepeatBase, interval: Int16(myRepeatInterval), period: myRepeatType)
            }
            else
            { // A date has been set in at least one of the fields, so we use that as the date to set
                
                // If both start and end dates are set then we want to make sure we keep interval between them the same, so we need to work out the time to add
                
                var daysToAdd: Int = 0
                
                if myStartDate != getDefaultDate() as Date && myDueDate != getDefaultDate() as Date
                {
                    let calendar = Calendar.current
                    
                    let components = calendar.dateComponents([.day], from: myStartDate, to: myDueDate)
                    
                    daysToAdd = components.day!
                }
                
                let now: Date = Date()
                let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let dateComponents: DateComponents = (gregorian as Calendar).dateComponents([.year, .month, .day], from: now)
                let todayDate: Date = gregorian.date(from: dateComponents)!
                
                if myStartDate != getDefaultDate() as Date
                {
                    if myRepeatBase == "Start Date"
                    {
                        tempStartDate = myStartDate.calculateNewDate(dateBase:myRepeatBase, interval: Int16(myRepeatInterval), period: myRepeatType)
                    }
                    else
                    {
                        tempStartDate = todayDate.calculateNewDate(dateBase:myRepeatBase, interval: Int16(myRepeatInterval), period: myRepeatType)
                    }
                }
                
                if myDueDate != getDefaultDate() as Date
                {
                    let calendar = Calendar.current
                    
                    let tempDate = calendar.date(
                        byAdding: .day,
                        value: daysToAdd,
                        to: todayDate)!
                    
                    tempDueDate = tempDate.calculateNewDate(dateBase:myRepeatBase, interval: Int16(myRepeatInterval), period: myRepeatType)
                }
            }
            
            // Create new task
            let _ = task(oldTask: self, startDate: tempStartDate, dueDate: tempDueDate)
        }
    }
}

extension coreDatabase
{
    func saveTask(_ taskID: Int, title: String, details: String, dueDate: Date, startDate: Date, status: String, priority: String, energyLevel: String, estimatedTime: Int, estimatedTimeType: String, projectID: Int, completionDate: Date, repeatInterval: Int, repeatType: String, repeatBase: String, flagged: Bool, urgency: String, teamID: Int, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myTask: Task!
        
        let myTasks = getTask(taskID, teamID: teamID)
        
        if myTasks.count == 0
        { // Add
            myTask = Task(context: objectContext)
            myTask.taskID = Int64(taskID)
            myTask.title = title
            myTask.details = details
            myTask.dueDate = dueDate as NSDate
            myTask.startDate = startDate as NSDate
            myTask.status = status
            myTask.priority = priority
            myTask.energyLevel = energyLevel
            myTask.estimatedTime = Int64(estimatedTime)
            myTask.estimatedTimeType = estimatedTimeType
            myTask.projectID = Int64(projectID)
            myTask.completionDate = completionDate as NSDate
            myTask.repeatInterval = Int64(repeatInterval)
            myTask.repeatType = repeatType
            myTask.repeatBase = repeatBase
            myTask.flagged = flagged as NSNumber
            myTask.urgency = urgency
            myTask.teamID = Int64(teamID)
            
            if updateType == "CODE"
            {
                myTask.updateTime =  NSDate()
                myTask.updateType = "Add"
            }
            else
            {
                myTask.updateTime = updateTime as NSDate
                myTask.updateType = updateType
            }
        }
        else
        { // Update
            myTask = myTasks[0]
            myTask.title = title
            myTask.details = details
            myTask.dueDate = dueDate as NSDate
            myTask.startDate = startDate as NSDate
            myTask.status = status
            myTask.priority = priority
            myTask.energyLevel = energyLevel
            myTask.estimatedTime = Int64(estimatedTime)
            myTask.estimatedTimeType = estimatedTimeType
            myTask.projectID = Int64(projectID)
            myTask.completionDate = completionDate as NSDate
            myTask.repeatInterval = Int64(repeatInterval)
            myTask.repeatType = repeatType
            myTask.repeatBase = repeatBase
            myTask.flagged = flagged as NSNumber
            myTask.urgency = urgency
            myTask.teamID = Int64(teamID)
            
            if updateType == "CODE"
            {
                myTask.updateTime =  NSDate()
                if myTask.updateType != "Add"
                {
                    myTask.updateType = "Update"
                }
            }
            else
            {
                myTask.updateTime = updateTime as NSDate
                myTask.updateType = updateType
            }
            
        }
        
        saveContext()

        self.recordsProcessed += 1
    }
    
    func deleteTask(_ taskID: Int, teamID: Int)
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        let predicate = NSPredicate(format: "taskID == \(taskID) AND (teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
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
    
    func getTasksNotDeleted(_ teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "taskID", ascending: true)
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
    
    func getAllTasksForProject(_ projectID: Int, teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(projectID)) && (updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\")")
        
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
    
    func getAllTasks(_ teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        let predicate = NSPredicate(format: "(teamID == \(teamID))")
        
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
    
    func getTasksForProject(_ projectID: Int, teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(projectID)) && (updateType != \"Delete\") AND (teamID == \(teamID)) AND (status != \"Deleted\") && (status != \"Complete\")")
        
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
    
    func getActiveTasksForProject(_ projectID: Int, teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(projectID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\") && (status != \"Pause\") && ((startDate == %@) || (startDate <= %@))", (getDefaultDate()) as CVarArg,  NSDate() as CVarArg)
        
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
    
    func getTasksWithoutProject(_ teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == 0) && (updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\") && (status != \"Complete\")")
        
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
    
    func getTask(_ taskID: Int, teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.

        let predicate = NSPredicate(format: "(taskID == \(taskID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\") && (status != \"Deleted\")")
        
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
    
    func getTaskRegardlessOfStatus(_ taskID: Int, teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) AND (teamID == \(teamID))")
        
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
    
    func getActiveTask(_ taskID: Int, teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) AND (teamID == \(teamID)) AND (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\") && ((startDate == %@) || (startDate <= %@))", (getDefaultDate()) as CVarArg, NSDate() as CVarArg)
        
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
    
    func getTaskCount(_ teamID: Int)->Int
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        let predicate = NSPredicate(format: "(teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
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

    func resetTasks()
    {
//        resetMeetingTasks()
        
        let fetchRequest2 = NSFetchRequest<Task>(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myMeeting2 in fetchResults2
            {
                myMeeting2.updateTime =  NSDate()
                myMeeting2.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
 //       resetTaskContextRecords()
        
        resetTaskUpdateRecords()
    }

    func clearDeletedTasks(predicate: NSPredicate)
    {
        let fetchRequest16 = NSFetchRequest<Task>(entityName: "Task")
        
        // Set the predicate on the fetch request
        fetchRequest16.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults16 = try objectContext.fetch(fetchRequest16)
            for myItem16 in fetchResults16
            {
                objectContext.delete(myItem16 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedTasks(predicate: NSPredicate)
    {
        let fetchRequest16 = NSFetchRequest<Task>(entityName: "Task")
        
        // Set the predicate on the fetch request
        fetchRequest16.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults16 = try objectContext.fetch(fetchRequest16)
            for myItem16 in fetchResults16
            {
                myItem16.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func initialiseTeamForTask(_ teamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        let sortDescriptor = NSSortDescriptor(key: "taskID", ascending: true)
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
                    maxID = Int(myItem.taskID)
                }
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Task", codeValue: tempInt, codeType: "hidden", decode_privacy: "Public", teamID: teamID)
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getTaskForSync(_ syncDate: Date) -> [Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
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

    func deleteAllTaskRecords()
    {
        let fetchRequest16 = NSFetchRequest<Task>(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults16 = try objectContext.fetch(fetchRequest16)
            for myItem16 in fetchResults16
            {
                self.objectContext.delete(myItem16 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
}

extension alerts
{
    func taskAlerts(_ teamID: Int)
    {
        // check for assigned tasks that are still open

        for myItem in myDatabaseConnection.getTasksForContext(currentUser.personTaskLink, teamID: teamID, contextType: personContextType)
        {
            let taskEntry = task(taskID: Int(myItem.taskID), teamID: currentUser.currentTeam!.teamID)
            
            if taskEntry.status != taskStatusClosed && taskEntry.status != taskStatusOnHold
            {
                let alertEntry = alertItem()
                
                var projectName: String = ""
                if taskEntry.projectID > 0
                {
                    projectName = project(projectID: taskEntry.projectID, teamID: currentUser.currentTeam!.teamID).projectName
                }
                
                alertEntry.displayText = taskEntry.title
                alertEntry.name = projectName
                alertEntry.source = "Task"
                alertEntry.object = taskEntry
                
                alertList.append(alertEntry)
            }
        }
    }
}

extension CloudKitInteraction
{
    func saveTaskToCloudKit()
    {     
        for myItem in myDatabaseConnection.getTaskForSync(getSyncDateForTable(tableName: "Task"))
        {
            saveTaskRecordToCloudKit(myItem)
        }
    }

    func updateTaskInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "Task") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateTaskRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Task", queryOperation: operation, onOperationQueue: operationQueue)
    }

//    func deleteTask(teamID: Int)
//    {
//        let sem = DispatchSemaphore(value: 0);
//        
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
//        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
//        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
//            for record in results!
//            {
//                myRecordList.append(record.recordID)
//            }
//            self.performPublicDelete(myRecordList)
//            sem.signal()
//        })
//        sem.wait()
//    }

    func saveTaskRecordToCloudKit(_ sourceRecord: Task)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Task", predicate: predicate)
        
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
                    record!.setValue(sourceRecord.completionDate, forKey: "completionDate")
                    record!.setValue(sourceRecord.details, forKey: "details")
                    record!.setValue(sourceRecord.dueDate, forKey: "dueDate")
                    record!.setValue(sourceRecord.energyLevel, forKey: "energyLevel")
                    record!.setValue(sourceRecord.estimatedTime, forKey: "estimatedTime")
                    record!.setValue(sourceRecord.estimatedTimeType, forKey: "estimatedTimeType")
                    record!.setValue(sourceRecord.flagged, forKey: "flagged")
                    record!.setValue(sourceRecord.priority, forKey: "priority")
                    record!.setValue(sourceRecord.repeatBase, forKey: "repeatBase")
                    record!.setValue(sourceRecord.repeatInterval, forKey: "repeatInterval")
                    record!.setValue(sourceRecord.repeatType, forKey: "repeatType")
                    record!.setValue(sourceRecord.startDate, forKey: "startDate")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    record!.setValue(sourceRecord.title, forKey: "title")
                    record!.setValue(sourceRecord.urgency, forKey: "urgency")
                    record!.setValue(sourceRecord.projectID, forKey: "projectID")
                    record!.setValue(sourceRecord.teamID, forKey: "teamID")
                    
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
                    let record = CKRecord(recordType: "Task")
                    record.setValue(sourceRecord.taskID, forKey: "taskID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.completionDate, forKey: "completionDate")
                    record.setValue(sourceRecord.details, forKey: "details")
                    record.setValue(sourceRecord.dueDate, forKey: "dueDate")
                    record.setValue(sourceRecord.energyLevel, forKey: "energyLevel")
                    record.setValue(sourceRecord.estimatedTime, forKey: "estimatedTime")
                    record.setValue(sourceRecord.estimatedTimeType, forKey: "estimatedTimeType")
                    record.setValue(sourceRecord.flagged, forKey: "flagged")
                    record.setValue(sourceRecord.priority, forKey: "priority")
                    record.setValue(sourceRecord.repeatBase, forKey: "repeatBase")
                    record.setValue(sourceRecord.repeatInterval, forKey: "repeatInterval")
                    record.setValue(sourceRecord.repeatType, forKey: "repeatType")
                    record.setValue(sourceRecord.startDate, forKey: "startDate")
                    record.setValue(sourceRecord.status, forKey: "status")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.title, forKey: "title")
                    record.setValue(sourceRecord.urgency, forKey: "urgency")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
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

    func updateTaskRecord(_ sourceRecord: CKRecord)
    {
        let taskID = sourceRecord.object(forKey: "taskID") as! Int
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
        let completionDate = sourceRecord.object(forKey: "completionDate") as! Date
        let details = sourceRecord.object(forKey: "details") as! String
        let dueDate = sourceRecord.object(forKey: "dueDate") as! Date
        let energyLevel = sourceRecord.object(forKey: "energyLevel") as! String
        let estimatedTime = sourceRecord.object(forKey: "estimatedTime") as! Int
        let estimatedTimeType = sourceRecord.object(forKey: "estimatedTimeType") as! String
        let flagged = sourceRecord.object(forKey: "flagged") as! Bool
        let priority = sourceRecord.object(forKey: "priority") as! String
        let repeatBase = sourceRecord.object(forKey: "repeatBase") as! String
        let repeatInterval = sourceRecord.object(forKey: "repeatInterval") as! Int
        let repeatType = sourceRecord.object(forKey: "repeatType") as! String
        let startDate = sourceRecord.object(forKey: "startDate") as! Date
        let status = sourceRecord.object(forKey: "status") as! String
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        let title = sourceRecord.object(forKey: "title") as! String
        let urgency = sourceRecord.object(forKey: "urgency") as! String
        let projectID = sourceRecord.object(forKey: "projectID") as! Int
        
        myDatabaseConnection.recordsToChange += 1
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
        
        self.recordCount += 1
        
        myDatabaseConnection.saveTask(taskID, title: title, details: details, dueDate: dueDate, startDate: startDate, status: status, priority: priority, energyLevel: energyLevel, estimatedTime: estimatedTime, estimatedTimeType: estimatedTimeType, projectID: projectID, completionDate: completionDate, repeatInterval: repeatInterval, repeatType: repeatType, repeatBase: repeatBase, flagged: flagged, urgency: urgency, teamID: teamID, updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
}

