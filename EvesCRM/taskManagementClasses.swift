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
    
    func save()
    {
        myDatabaseConnection.saveGTDLevel(myGTDLevel, inLevelName: myTitle, inTeamID: myTeamID)
    }
}


class workingGTDItem: NSObject
{
    private var myGTDItemID: Int = 0
    private var myGTDParentID: Int = 0
    private var myTitle: String = "New"
    private var myStatus: String = ""
    private var myChildren: [workingGTDItem] = Array()
    private var myTeamID: Int = 0
    private var myNote: String = ""
    private var myLastReviewDate: NSDate!
    private var myReviewFrequency: Int = 0
    private var myReviewPeriod: String = ""
    private var myPredecessor: Int = 0
    private var myGTDID: Int = 0
    private var myGTDLevel: Int = 0
    
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
    
    var children: [workingGTDItem]
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
        let myChildrenList = myDatabaseConnection.getOpenGTDChildItems(myGTDItemID, inTeamID: myTeamID)
        myChildren.removeAll()
        
        for myItem in myChildrenList
        {
            let myNewChild = workingGTDItem(inGTDItemID: myItem.gTDItemID as! Int, inTeamID: myTeamID)
            myChildren.append(myNewChild)
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
            myDatabaseConnection.deleteGTDItem(myGTDItemID, inTeamID: myTeamID)
            return true
        }
    }
}




class purposeAndCoreValue: NSObject // 50k Level
{
    private var myPurposeID: Int = 0
    private var myTitle: String = "New purpose"
    private var myStatus: String = ""
    private var myVision: [gvision] = Array()
    private var myTeamID: Int = 0
    private var myNote: String = ""
    private var myLastReviewDate: NSDate!
    private var myReviewFrequency: Int = 0
    private var myReviewPeriod: String = ""
    private var myPredecessor: Int = 0
   
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
    
    init(inPurposeID: Int, inTeamID: Int)
    {
        super.init()
        
        // Load the details
        
        let myPurposeDetail = myDatabaseConnection.getPurpose(inPurposeID, inTeamID: inTeamID)
        
        for myPurpose in myPurposeDetail
        {
            myPurposeID = myPurpose.purposeID as Int
            myTitle = myPurpose.title
            myStatus = myPurpose.status
            myTeamID = myPurpose.teamID as Int
            myNote = myPurpose.note
            myLastReviewDate = myPurpose.lastReviewDate
            myReviewFrequency = myPurpose.reviewFrequency as Int
            myReviewPeriod = myPurpose.reviewPeriod
            myPredecessor = myPurpose.predecessor as Int
        }
        
        // Load the Members
        loadVision()
    }
    
    init(inTeamID: Int)
    {
        super.init()
        
        myPurposeID = myDatabaseConnection.getNextID("PurposeAndCoreValue")
        myLastReviewDate = getDefaultDate()
        myTeamID = inTeamID
        
        save()
    }
    
    func save()
    {
        myDatabaseConnection.savePurpose(myPurposeID, inTitle: myTitle, inStatus: myStatus, inTeamID: myTeamID, inNote: myNote, inLastReviewDate: myLastReviewDate, inReviewFrequency: myReviewFrequency, inReviewPeriod: myReviewPeriod, inPredecessor: myPredecessor)
    }
    
    func addVision(inVision: gvision)
    {
        inVision.purposeID = myPurposeID
        loadVision()
    }
    
    func removeVision(inVision: gvision)
    {
        inVision.purposeID = 0
        loadVision()
    }
    
    func loadVision()
    {
        let myVisionList = myDatabaseConnection.getOpenVisionsForPurpose(myPurposeID, inTeamID: myTeamID)
        myVision.removeAll()
        
        for myVis in myVisionList
        {
            let myNewVision = gvision(inVisionID: myVis.visionID as Int, inTeamID: myTeamID)
            myVision.append(myNewVision)
        }
    }
    
    func delete() -> Bool
    {
        if myVision.count > 0
        {
            return false
        }
        else
        {
            myDatabaseConnection.deletePurpose(myPurposeID, inTeamID: myTeamID)
            return true
        }
    }
}

class gvision: NSObject // (3-5 year goals) 40k Level
{
    private var myVisionID: Int = 0
    private var myPurposeID: Int = 0
    private var myTitle: String = "New vision"
    private var myStatus: String = ""
    private var myGoals: [goalAndObjective] = Array()
    private var myTeamID: Int = 0
    private var myNote: String = ""
    private var myLastReviewDate: NSDate!
    private var myReviewFrequency: Int = 0
    private var myReviewPeriod: String = ""
    private var myPredecessor: Int = 0
    
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
    
    init(inVisionID: Int, inTeamID: Int)
    {
        super.init()
        
        // Load the details
        
        let myVisions = myDatabaseConnection.getVisions(inVisionID, inTeamID: inTeamID)
        
        for myVision in myVisions
        {
            myPurposeID = myVision.purposeID as Int
            myVisionID = myVision.visionID as Int
            myTitle = myVision.title
            myStatus = myVision.status
            myTeamID = myVision.teamID as Int
            myNote = myVision.note
            myLastReviewDate = myVision.lastReviewDate
            myReviewFrequency = myVision.reviewFrequency as Int
            myReviewPeriod = myVision.reviewPeriod
            myPredecessor = myVision.predecessor as Int
        }
        
        // Load the Members
        loadGoals()
    }
    
    init(inTeamID: Int)
    {
        super.init()
        
        myVisionID = myDatabaseConnection.getNextID("Vision")
        myLastReviewDate = getDefaultDate()
        myTeamID = inTeamID
        
        save()
    }
    
    func save()
    {
        myDatabaseConnection.saveVision(myVisionID, inPurposeID: myPurposeID, inTitle: myTitle, inStatus: myStatus, inTeamID: myTeamID, inNote: myNote, inLastReviewDate: myLastReviewDate, inReviewFrequency: myReviewFrequency, inReviewPeriod: myReviewPeriod, inPredecessor: myPredecessor)
    }
    
    func addGoal(inGoal: goalAndObjective)
    {
        inGoal.visionID = myVisionID
        
        loadGoals()
    }
    
    func removeGoal(inGoal: goalAndObjective)
    {
        inGoal.visionID = 0
        loadGoals()
    }
    
    func loadGoals()
    {
        let myGoalList = myDatabaseConnection.getOpenGoalsForVision(myVisionID, inTeamID: myTeamID)
        myGoals.removeAll()
        
        for myGoal in myGoalList
        {
            let myNewGoal = goalAndObjective(inGoalID: myGoal.goalID as Int, inTeamID: myTeamID)
            myGoals.append(myNewGoal)
        }
    }

    func delete() -> Bool
    {
        if myGoals.count > 0
        {
            return false
        }
        else
        {
            myDatabaseConnection.deleteVision(myPurposeID, inTeamID: myTeamID)
            return true
        }
    }
}

class goalAndObjective: NSObject  // (1-2 year goals) 30k Level
{
    private var myGoalID: Int = 0
    private var myVisionID: Int = 0
    private var myTitle: String = "New goals"
    private var myStatus: String = ""
    private var myAreas: [areaOfResponsibility] = Array()
    private var myTeamID: Int = 0
    private var myNote: String = ""
    private var myLastReviewDate: NSDate!
    private var myReviewFrequency: Int = 0
    private var myReviewPeriod: String = ""
    private var myPredecessor: Int = 0
    
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
    
    init(inGoalID: Int, inTeamID: Int)
    {
        super.init()
        
        // Load the details
        
        let myGoals = myDatabaseConnection.getGoals(inGoalID, inTeamID: inTeamID)
        
        for myGoal in myGoals
        {
            myGoalID = myGoal.goalID as Int
            myVisionID = myGoal.visionID as Int
            myTitle = myGoal.title
            myStatus = myGoal.status
            myTeamID = myGoal.teamID as Int
            myNote = myGoal.note
            myLastReviewDate = myGoal.lastReviewDate
            myReviewFrequency = myGoal.reviewFrequency as Int
            myReviewPeriod = myGoal.reviewPeriod
            myPredecessor = myGoal.predecessor as Int
        }
        
        // Load the Members
        loadAreas()
    }
    
    init(inTeamID: Int)
    {
        super.init()
        
        myGoalID = myDatabaseConnection.getNextID("GoalAndObjective")
        myLastReviewDate = getDefaultDate()
        myTeamID = inTeamID
        
        save()
    }
    
    func save()
    {
        myDatabaseConnection.saveGoal(myGoalID, inVisionID: myVisionID, inTitle: myTitle, inStatus: myStatus, inTeamID: myTeamID, inNote: myNote, inLastReviewDate: myLastReviewDate, inReviewFrequency: myReviewFrequency, inReviewPeriod: myReviewPeriod, inPredecessor: myPredecessor)
    }
    
    func addArea(inArea: areaOfResponsibility)
    {
        inArea.goalID = myGoalID
        loadAreas()
    }

    func removeArea(inArea: areaOfResponsibility)
    {
        inArea.goalID = 0
        loadAreas()
    }
    
    func loadAreas()
    {
        let myAreaList = myDatabaseConnection.getOpenAreasForGoal(myGoalID, inTeamID: myTeamID)
        myAreas.removeAll()
        
        for myArea in myAreaList
        {
            let myNewArea = areaOfResponsibility(inAreaID: myArea.areaID as Int, inTeamID: myTeamID)
            myAreas.append(myNewArea)
        }
    }
    
    func delete() -> Bool
    {
        if myAreas.count > 0
        {
            return false
        }
        else
        {
            myDatabaseConnection.deleteGoal(myGoalID, inTeamID: myTeamID)
            return true
        }
    }
}

class areaOfResponsibility: NSObject // 20k Level
{
    private var myAreaID: Int = 0
    private var myGoalID: Int = 0
    private var myTitle: String = "New area"
    private var myStatus: String = ""
    private var myProjects: [project] = Array()
    private var myTeamID: Int = 0
    private var myNote: String = ""
    private var myLastReviewDate: NSDate!
    private var myReviewFrequency: Int = 0
    private var myReviewPeriod: String = ""
    private var myPredecessor: Int = 0
    
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

    init(inAreaID: Int, inTeamID: Int)
    {
        super.init()
        
        // Load the details
        
        let myAreas = myDatabaseConnection.getAreaOfResponsibility(inAreaID, inTeamID: inTeamID)
        
        for myArea in myAreas
        {
            myAreaID = myArea.areaID as Int
            myGoalID = myArea.goalID as Int
            myTitle = myArea.title
            myStatus = myArea.status
            myTeamID = myArea.teamID as Int
            myNote = myArea.note
            myLastReviewDate = myArea.lastReviewDate
            myReviewFrequency = myArea.reviewFrequency as Int
            myReviewPeriod = myArea.reviewPeriod
            myPredecessor = myArea.predecessor as Int
        }
        
        // Load the Members
        loadProjects()
    }
    
    init(inTeamID: Int)
    {
        super.init()
        
        myAreaID = myDatabaseConnection.getNextID("AreaOfResponsibility")
        myLastReviewDate = getDefaultDate()
        myTeamID = inTeamID
        
        save()
    }

    func save()
    {
        myDatabaseConnection.saveAreaOfResponsibility(myAreaID, inGoalID: myGoalID, inTitle: myTitle, inStatus: myStatus, inTeamID: myTeamID, inNote: myNote, inLastReviewDate: myLastReviewDate, inReviewFrequency: myReviewFrequency, inReviewPeriod: myReviewPeriod, inPredecessor: myPredecessor)
    }
    
    func addProject(inProject: project)
    {
        inProject.areaID = myAreaID
        loadProjects()
    }
    
    func removeProject(inProject: project)
    {
        inProject.areaID = 0
        loadProjects()
    }
    
    func loadProjects()
    {
        let myProjectList = myDatabaseConnection.getOpenProjectsForArea(myAreaID, inTeamID: myTeamID)
        myProjects.removeAll()
        
        for myProject in myProjectList
        {
            let myNewProject = project(inProjectID: myProject.projectID as Int, inTeamID: myTeamID)
            myProjects.append(myNewProject)
        }
    }
    
    func delete() -> Bool
    {
        if myProjects.count > 0
        {
            return false
        }
        else
        {
            myDatabaseConnection.deleteAreaOfResponsibility(myAreaID, inTeamID: myTeamID)
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
    private var myAreaID: Int = 0
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
    }
    
    init(inProjectID: Int, inTeamID: Int)
    {
        super.init()
        
 // GRE whatever calls projects should check to make sure it is not marked as "Archived", as we are not deleting Projects, only marking them as archived
        let myProjects = myDatabaseConnection.getProjectDetails(inProjectID, inTeamID: inTeamID)
        
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
        
        let myProjectTasks = myDatabaseConnection.getTasksForProject(myProjectID, inTeamID: myTeamID)
        
        for myProjectTask in myProjectTasks
        {
            let myNewTask = task(inTaskID: myProjectTask.taskID as Int, inTeamID: myTeamID)
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
        
        // save note
        
        myDatabaseConnection.saveProjectNote(myProjectID, inNote: myNote, inReviewPeriod: myReviewPeriod, inPredecessor: myPredecessor)
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
    
    init(inTaskID: Int, inTeamID: Int)
    {
        let myTaskData = myDatabaseConnection.getTask(inTaskID, inTeamID: inTeamID)
        
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
                let myNewContext = context(inContextID: myContextItem.contextID as Int, inTeamID: myTeamID)
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
    
    func addContext(inContextID: Int)
    {
        var itemFound: Bool = false
        
        // first we need to make sure the context is not already present
        
        // Get the context name
        
        let myContext = context(inContextID: inContextID, inTeamID: myTeamID)
        
        let myCheck = myDatabaseConnection.getContextsForTask(myTaskID)
        
        for myItem in myCheck
        {
            let myRetrievedContext = context(inContextID: myItem.contextID as Int, inTeamID: myTeamID)
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
                let myNewContext = context(inContextID: myContextItem.contextID as Int, inTeamID: myTeamID)
                myContexts.append(myNewContext)
            }
        }
    }
    
    func removeContext(inContextID: Int)
    {
        myDatabaseConnection.deleteTaskContext(inContextID, inTaskID: myTaskID)
        
        let myContextList = myDatabaseConnection.getContextsForTask(myTaskID)
        myContexts.removeAll()
        
        for myContextItem in myContextList
        {
            let myNewContext = context(inContextID: myContextItem.contextID as Int, inTeamID: myTeamID)
            myContexts.append(myNewContext)
        }
    }
    
    func delete() -> Bool
    {
        myDatabaseConnection.deleteTask(myTaskID)
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
        let myData = myDatabaseConnection.getContexts(myCurrentTeam.teamID)
        
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
}

class context: NSObject
{
    private var myContextID: Int = 0
    private var myName: String = "New context"
    private var myEmail: String = ""
    private var myAutoEmail: String = ""
    private var myParentContext: Int = 0
    private var myStatus: String = ""
    private var myPersonID: Int32 = 0
    private var myTeamID: Int = 0
    private var myPredecessor: Int = 0
    
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
                let theParent = context(inContextID: myParentContext, inTeamID: myTeamID)
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
                
                getContext1_1()
                
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
    
    init(inContextID: Int, inTeamID: Int)
    {
        super.init()
        let myContexts = myDatabaseConnection.getContextDetails(inContextID, inTeamID: inTeamID)
        
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
        myPersonID = inContext.personID.intValue
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
        }
        else
        {
            for myItem in myNotes
            {
                myPredecessor = myItem.predecessor as Int
            }
        }

    }
    
    func save()
    {
        myDatabaseConnection.saveContext(myContextID, inName: myName, inEmail: myEmail, inAutoEmail: myAutoEmail, inParentContext: myParentContext, inStatus: myStatus, inPersonID: myPersonID, inTeamID: myTeamID)
    }
    
    func delete() -> Bool
    {
        if allTasks.count > 0
        {
            return false
        }
        else
        {
            myDatabaseConnection.deleteContext(myContextID, inTeamID: myTeamID)
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