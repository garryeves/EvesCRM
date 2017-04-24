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
    
    func loadActiveTasksForContext(_ contextID: Int)
    {
        myActiveTasks.removeAll()
        
        let myTaskContextList = myDatabaseConnection.getTasksForContext(contextID)
        
        for myTaskContext in myTaskContextList
        {
            // Get the context details
            let myTaskList = myDatabaseConnection.getActiveTask(myTaskContext.taskID as! Int)
            
            for myTask in myTaskList
            {  //append project details to work array
                // check the project to see if it is on hold
                
                let myProject = project(inProjectID: myTask.projectID as! Int)
                
                if myProject.projectStatus != "On Hold"
                {
                    let tempTask = task(taskID: myTask.taskID as! Int)
                    myActiveTasks.append(tempTask)
                }
            }
        }
        
        myActiveTasks.sort(by: {$0.dueDate.timeIntervalSinceNow < $1.dueDate.timeIntervalSinceNow})
    }
    
    func loadActiveTasksForProject(_ projectID: Int)
    {
        myActiveTasks.removeAll()
        
        var taskList = myDatabaseConnection.getActiveTasksForProject(projectID)
        
        taskList.sort(by: {$0.dueDate.timeIntervalSinceNow < $1.dueDate.timeIntervalSinceNow})
        
        for myItem in taskList
        {
            let tempTask = task(taskID: myItem.taskID as! Int)
            
            myActiveTasks.append(tempTask)
        }
    }
    
    func loadAllTasksForProject(_ projectID: Int)
    {
        myTasks.removeAll()
        
        var taskList = myDatabaseConnection.getTasksForProject(projectID)
        
        taskList.sort(by: {$0.dueDate.timeIntervalSinceNow < $1.dueDate.timeIntervalSinceNow})
        
        for myItem in taskList
        {
            let tempTask = task(taskID: myItem.taskID as! Int)
            
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
                myDueDate = getDefaultDate() as Date!
                save()
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
                myStartDate = getDefaultDate() as Date!
                save()
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
                myTeamID = tempProject[0].teamID as! Int
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
                myCompletionDate = getDefaultDate() as Date!
                save()
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
        
        myDueDate = getDefaultDate() as Date!
        myStartDate = getDefaultDate() as Date!
        myCompletionDate = getDefaultDate() as Date!
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
            myTaskID = myTask.taskID as! Int
            myTitle = myTask.title
            myDetails = myTask.details
            myDueDate = myTask.dueDate
            myStartDate = myTask.startDate
            myStatus = myTask.status
            myPriority = myTask.priority
            myEnergyLevel = myTask.energyLevel
            myEstimatedTime = myTask.estimatedTime as! Int
            myEstimatedTimeType = myTask.estimatedTimeType
            myProjectID = myTask.projectID as! Int
            myCompletionDate = myTask.completionDate
            myRepeatInterval = myTask.repeatInterval as! Int
            myRepeatType = myTask.repeatType
            myRepeatBase = myTask.repeatBase
            myFlagged = myTask.flagged as! Bool
            myUrgency = myTask.urgency
            myTeamID = myTask.teamID as! Int
            
            // get contexts
            
            let myContextList = myDatabaseConnection.getContextsForTask(taskID)
            myContexts.removeAll()
            
            for myContextItem in myContextList
            {
                let myNewContext = context(contextID: myContextItem.contextID as! Int)
                myContexts.append(myNewContext)
            }
            
            let myPredecessorList = myDatabaseConnection.getTaskPredecessors(taskID)
            
            myPredecessors.removeAll()
            
            for myPredecessorItem in myPredecessorList
            {
                let myNewPredecessor = taskPredecessor(inPredecessorID: myPredecessorItem.predecessorID as! Int, inPredecessorType: myPredecessorItem.predecessorType)
                myPredecessors.append(myNewPredecessor)
            }
        }
    }
    
    init(oldTask: task, startDate: Date, dueDate: Date)
    {
        super.init()
        
        myTaskID = myDatabaseConnection.getNextID("Task")
        myTitle = oldTask.title
        myDetails = oldTask.details
        myDueDate = dueDate
        myStartDate = startDate
        myStatus = "Open"
        myPriority = oldTask.priority
        myEnergyLevel = oldTask.energyLevel
        myEstimatedTime = oldTask.estimatedTime as Int
        myEstimatedTimeType = oldTask.estimatedTimeType
        myProjectID = oldTask.projectID as Int
        myCompletionDate = oldTask.completionDate
        myRepeatInterval = oldTask.repeatInterval as Int
        myRepeatType = oldTask.repeatType
        myRepeatBase = oldTask.repeatBase
        myFlagged = oldTask.flagged as Bool
        myUrgency = oldTask.urgency
        myTeamID = oldTask.teamID as Int
        
        save()
        
        // get contexts
        
        myContexts.removeAll()
        
        for myContextItem in oldTask.contexts
        {
            myDatabaseConnection.saveTaskContext(myContextItem.contextID as Int, inTaskID: myTaskID)
        }
        
        myPredecessors.removeAll()
        
        for myPredecessorItem in oldTask.predecessors
        {
            myDatabaseConnection.savePredecessorTask(myTaskID, inPredecessorID: myPredecessorItem.predecessorID, inPredecessorType: myPredecessorItem.predecessorType)
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveTask(myTaskID, inTitle: myTitle, inDetails: myDetails, inDueDate: myDueDate, inStartDate: myStartDate, inStatus: myStatus, inPriority: myPriority, inEnergyLevel: myEnergyLevel, inEstimatedTime: myEstimatedTime, inEstimatedTimeType: myEstimatedTimeType, inProjectID: myProjectID, inCompletionDate: myCompletionDate!, inRepeatInterval: myRepeatInterval, inRepeatType: myRepeatType, inRepeatBase: myRepeatBase, inFlagged: myFlagged, inUrgency: myUrgency, inTeamID: myTeamID)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(workingGTDLevel.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myTask = myDatabaseConnection.getTaskRegardlessOfStatus(myTaskID)[0]
        
        myCloudDB.saveTaskRecordToCloudKit(myTask)
        
        // Save context link
        
        for myContext in myContexts
        {
            myDatabaseConnection.saveTaskContext(myContext.contextID as Int, inTaskID: myTaskID)
        }
        
        saveCalled = false
    }
    
    func addContext(_ contextID: Int)
    {
        var itemFound: Bool = false
        
        // first we need to make sure the context is not already present
        
        // Get the context name
        
        let myContext = context(contextID: contextID)
        
        let myCheck = myDatabaseConnection.getContextsForTask(myTaskID)
        
        for myItem in myCheck
        {
            let myRetrievedContext = context(contextID: myItem.contextID as! Int)
            if myRetrievedContext.name.lowercased() == myContext.name.lowercased()
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
                let myNewContext = context(contextID: myContextItem.contextID as! Int)
                myContexts.append(myNewContext)
            }
        }
    }
    
    func removeContext(_ contextID: Int)
    {
        myDatabaseConnection.deleteTaskContext(contextID, inTaskID: myTaskID)
        
        let myContextList = myDatabaseConnection.getContextsForTask(myTaskID)
        myContexts.removeAll()
        
        for myContextItem in myContextList
        {
            let myNewContext = context(contextID: myContextItem.contextID as! Int)
            myContexts.append(myNewContext)
        }
    }
    
    func delete() -> Bool
    {
        myStatus = "Deleted"
        save()
        return true
    }
    
    
    func addHistoryRecord(_ inHistoryDetails: String, inHistorySource: String)
    {
        let myItem = taskUpdates(inTaskID: myTaskID)
        myItem.details = inHistoryDetails
        myItem.source = inHistorySource
        
        myItem.save()
    }
    
    
    func addPredecessor(_ inPredecessorID: Int, inPredecessorType: String)
    {
        myDatabaseConnection.savePredecessorTask(myTaskID, inPredecessorID: inPredecessorID, inPredecessorType: inPredecessorType)
    }
    
    func removePredecessor(_ inPredecessorID: Int, inPredecessorType: String)
    {
        myDatabaseConnection.deleteTaskPredecessor(myTaskID, inPredecessorID: inPredecessorID)
    }
    
    func changePredecessor(_ inPredecessorID: Int, inPredecessorType: String)
    {
        myDatabaseConnection.updatePredecessorTaskType(myTaskID, inPredecessorID: inPredecessorID, inPredecessorType: inPredecessorType)
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
    
    fileprivate func writeLine(_ inTargetString: String, inLineString: String) -> String
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
    
    fileprivate func writeHTMLLine(_ inTargetString: String, inLineString: String) -> String
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
        var tempStartDate: Date = getDefaultDate() as Date
        var tempDueDate: Date = getDefaultDate() as Date
        
        if myRepeatInterval != 0
        {
            // Calculate new start and end dates, based on the repeat fields
            
            if myStartDate == getDefaultDate() as Date && myDueDate == getDefaultDate() as Date
            {  // No dates have set, so we set the start date
                tempStartDate = calculateNewDate(Date(), inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
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
                        tempStartDate = calculateNewDate(myStartDate, inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
                    }
                    else
                    {
                        tempStartDate = calculateNewDate(todayDate, inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
                    }
                }
                
                if myDueDate != getDefaultDate() as Date
                {
                    let calendar = Calendar.current
                    
                    let tempDate = calendar.date(
                        byAdding: .day,
                        value: daysToAdd,
                        to: todayDate)!
                    
                    tempDueDate = calculateNewDate(tempDate, inDateBase:myRepeatBase, inInterval: myRepeatInterval, inPeriod: myRepeatType)
                }
            }
            
            // Create new task
            let _ = task(oldTask: self, startDate: tempStartDate, dueDate: tempDueDate)
        }
    }
}

extension coreDatabase
{
    func saveTask(_ inTaskID: Int, inTitle: String, inDetails: String, inDueDate: Date, inStartDate: Date, inStatus: String, inPriority: String, inEnergyLevel: String, inEstimatedTime: Int, inEstimatedTimeType: String, inProjectID: Int, inCompletionDate: Date, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inFlagged: Bool, inUrgency: String, inTeamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myTask: Task!
        
        let myTasks = getTask(inTaskID)
        
        if myTasks.count == 0
        { // Add
            myTask = Task(context: objectContext)
            myTask.taskID = NSNumber(value: inTaskID)
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = NSNumber(value: inEstimatedTime)
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = NSNumber(value: inProjectID)
            myTask.completionDate = inCompletionDate
            myTask.repeatInterval = NSNumber(value: inRepeatInterval)
            myTask.repeatType = inRepeatType
            myTask.repeatBase = inRepeatBase
            myTask.flagged = inFlagged as NSNumber
            myTask.urgency = inUrgency
            myTask.teamID = NSNumber(value: inTeamID)
            
            if inUpdateType == "CODE"
            {
                myTask.updateTime =  Date()
                myTask.updateType = "Add"
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }
        }
        else
        { // Update
            myTask = myTasks[0]
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = NSNumber(value: inEstimatedTime)
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = NSNumber(value: inProjectID)
            myTask.completionDate = inCompletionDate
            myTask.repeatInterval = NSNumber(value: inRepeatInterval)
            myTask.repeatType = inRepeatType
            myTask.repeatBase = inRepeatBase
            myTask.flagged = inFlagged as NSNumber
            myTask.urgency = inUrgency
            myTask.teamID = NSNumber(value: inTeamID)
            
            if inUpdateType == "CODE"
            {
                myTask.updateTime =  Date()
                if myTask.updateType != "Add"
                {
                    myTask.updateType = "Update"
                }
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }
            
        }
        
        saveContext()
    }
    
    func replaceTask(_ inTaskID: Int, inTitle: String, inDetails: String, inDueDate: Date, inStartDate: Date, inStatus: String, inPriority: String, inEnergyLevel: String, inEstimatedTime: Int, inEstimatedTimeType: String, inProjectID: Int, inCompletionDate: Date, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inFlagged: Bool, inUrgency: String, inTeamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myTask = Task(context: objectContext)
        myTask.taskID = NSNumber(value: inTaskID)
        myTask.title = inTitle
        myTask.details = inDetails
        myTask.dueDate = inDueDate
        myTask.startDate = inStartDate
        myTask.status = inStatus
        myTask.priority = inPriority
        myTask.energyLevel = inEnergyLevel
        myTask.estimatedTime = NSNumber(value: inEstimatedTime)
        myTask.estimatedTimeType = inEstimatedTimeType
        myTask.projectID = NSNumber(value: inProjectID)
        myTask.completionDate = inCompletionDate
        myTask.repeatInterval = NSNumber(value: inRepeatInterval)
        myTask.repeatType = inRepeatType
        myTask.repeatBase = inRepeatBase
        myTask.flagged = inFlagged as NSNumber
        myTask.urgency = inUrgency
        myTask.teamID = NSNumber(value: inTeamID)
        
        if inUpdateType == "CODE"
        {
            myTask.updateTime =  Date()
            myTask.updateType = "Add"
        }
        else
        {
            myTask.updateTime = inUpdateTime
            myTask.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func deleteTask(_ inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        let predicate = NSPredicate(format: "taskID == \(inTaskID)")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
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
    
    func getTasksNotDeleted(_ inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
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
    
    func getAllTasksForProject(_ inProjectID: Int, inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(inProjectID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
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
    
    func getTasksForProject(_ projectID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(projectID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\")")
        
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
    
    func getActiveTasksForProject(_ projectID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(projectID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\") && (status != \"Pause\") && ((startDate == %@) || (startDate <= %@))", (getDefaultDate() as NSDate) as CVarArg,  NSDate() as CVarArg)
        
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
    
    func getTask(_ taskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (status != \"Deleted\")")
        
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
    
    func getTaskRegardlessOfStatus(_ taskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID))")
        
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
    
    func getActiveTask(_ taskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\") && ((startDate == %@) || (startDate <= %@))", (getDefaultDate() as NSDate) as CVarArg, NSDate() as CVarArg)
        
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
    
    func getTaskCount()->Int
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
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
        resetMeetingTasks()
        
        let fetchRequest2 = NSFetchRequest<Task>(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myMeeting2 in fetchResults2
            {
                myMeeting2.updateTime =  Date()
                myMeeting2.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        resetTaskContextRecords()
        
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
    
    func initialiseTeamForTask(_ inTeamID: Int)
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
                    myItem.teamID = NSNumber(value: inTeamID)
                    maxID = myItem.taskID as! Int
                }
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Task", inCodeValue: tempInt, inCodeType: "hidden")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getTaskForSync(_ inLastSyncDate: NSDate) -> [Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
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

extension CloudKitInteraction
{
    func saveTaskToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing Task")
        for myItem in myDatabaseConnection.getTaskForSync(inLastSyncDate)
        {
            saveTaskRecordToCloudKit(myItem)
        }
    }

    func updateTaskInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateTaskRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteTask()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            sem.signal()
        })
        sem.wait()
    }

    func replaceTaskInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let taskID = record.object(forKey: "taskID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let completionDate = record.object(forKey: "completionDate") as! Date
                let details = record.object(forKey: "details") as! String
                let dueDate = record.object(forKey: "dueDate") as! Date
                let energyLevel = record.object(forKey: "energyLevel") as! String
                let estimatedTime = record.object(forKey: "estimatedTime") as! Int
                let estimatedTimeType = record.object(forKey: "estimatedTimeType") as! String
                let flagged = record.object(forKey: "flagged") as! Bool
                let priority = record.object(forKey: "priority") as! String
                let repeatBase = record.object(forKey: "repeatBase") as! String
                let repeatInterval = record.object(forKey: "repeatInterval") as! Int
                let repeatType = record.object(forKey: "repeatType") as! String
                let startDate = record.object(forKey: "startDate") as! Date
                let status = record.object(forKey: "status") as! String
                let teamID = record.object(forKey: "teamID") as! Int
                let title = record.object(forKey: "title") as! String
                let urgency = record.object(forKey: "urgency") as! String
                let projectID = record.object(forKey: "projectID") as! Int
                
                myDatabaseConnection.replaceTask(taskID, inTitle: title, inDetails: details, inDueDate: dueDate, inStartDate: startDate, inStatus: status, inPriority: priority, inEnergyLevel: energyLevel, inEstimatedTime: estimatedTime, inEstimatedTimeType: estimatedTimeType, inProjectID: projectID, inCompletionDate: completionDate, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inFlagged: flagged, inUrgency: urgency, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveTaskRecordToCloudKit(_ sourceRecord: Task)
    {
        let predicate = NSPredicate(format: "(taskID == \(sourceRecord.taskID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Task", predicate: predicate)
        
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
                    let record = CKRecord(recordType: "Task")
                    record.setValue(sourceRecord.taskID, forKey: "taskID")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
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
        
        myDatabaseConnection.saveTask(taskID, inTitle: title, inDetails: details, inDueDate: dueDate, inStartDate: startDate, inStatus: status, inPriority: priority, inEnergyLevel: energyLevel, inEstimatedTime: estimatedTime, inEstimatedTimeType: estimatedTimeType, inProjectID: projectID, inCompletionDate: completionDate, inRepeatInterval: repeatInterval, inRepeatType: repeatType, inRepeatBase: repeatBase, inFlagged: flagged, inUrgency: urgency, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
}

