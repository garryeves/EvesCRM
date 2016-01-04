//
//  teamClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 27/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

class team: NSObject
{
    private var myTeamID: Int = 0
    private var myName: String = "New"
    private var myNote: String = ""
    private var myStatus: String = ""
    private var myType: String = ""
    private var myPredecessor: Int = 0
    private var myExternalID: Int = 0
    private var myRoles: [Roles]!
    private var myStages:[Stages]!
    private var myGTD: [workingGTDLevel] = Array()
    private var myGTDTopLevel: [workingGTDItem] = Array()
    private var myContexts: [context] = Array()
    private var saveCalled: Bool = false
    
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
    
    var externalID: Int
    {
        get
        {
            return myExternalID
        }
        set
        {
            myExternalID = newValue
            save()
        }
    }
    
    var type: String
    { // Type should be either "private" or "shared"
        get
        {
            return myType
        }
        set
        {
            myType = newValue
            save()
        }
    }

    var roles: [Roles]
    {
        get
        {
            return myRoles
        }
    }
    
    var stages: [Stages]
    {
        get
        {
            return myStages
        }
    }

    var GTDLevels: [workingGTDLevel]
    {
        get
        {
            return myGTD
        }
    }

    var GTDTopLevel: [workingGTDItem]
    {
        get
        {
            return myGTDTopLevel
        }
    }

    var contexts: [context]
    {
        get
        {
            return myContexts
        }
    }

    init(inTeamID: Int)
    {
        super.init()
        
        // Load the details
        
        let myTeam = myDatabaseConnection.getTeam(inTeamID)
        
        for myItem in myTeam
        {
            myTeamID = myItem.teamID as Int
            myName = myItem.name
            myStatus = myItem.status
            myType = myItem.type
            myNote = myItem.note
            myPredecessor = myItem.predecessor as Int
            myExternalID = myItem.externalID as Int
        }
 
        loadRoles()
        
        loadStages()
        
        loadGTDLevels()
        
        loadContexts()
    }

    override init()
    {
        super.init()
        
        let currentNumberofEntries = myDatabaseConnection.getTeamsCount()
        
        myTeamID = myDatabaseConnection.getNextID("Team")
        
        save()
        
        if currentNumberofEntries == 0
        {
            // Initial load.  As belt and braces, in case updating from previous version of the database, Initialise any existing tables with this team ID
            
            myDatabaseConnection.initialiseTeamForContext(myTeamID)
            myDatabaseConnection.initialiseTeamForMeetingAgenda(myTeamID)
            myDatabaseConnection.initialiseTeamForProject(myTeamID)
            myDatabaseConnection.initialiseTeamForRoles(myTeamID)
            myDatabaseConnection.initialiseTeamForStages(myTeamID)
            myDatabaseConnection.initialiseTeamForTask(myTeamID)
        }
        
        createGTDLevels()
        
        createRoles()
        
        createStages()

        loadRoles()
        
        loadStages()
        
        loadGTDLevels()
    }
    
    private func createGTDLevels()
    {
        // Create Initial GTD Levels
        
        myDatabaseConnection.saveGTDLevel(1, inLevelName: "Purpose and Core Values", inTeamID: myTeamID)
        myDatabaseConnection.saveGTDLevel(2, inLevelName: "Vision", inTeamID: myTeamID)
        myDatabaseConnection.saveGTDLevel(3, inLevelName: "Goals and Objectives", inTeamID: myTeamID)
        myDatabaseConnection.saveGTDLevel(4, inLevelName: "Areas of Responsibility", inTeamID: myTeamID)
    }
    
    private func createRoles()
    {
        if myDatabaseConnection.getRoles(myTeamID).count == 0
        {
            // There are no roles defined so we need to go in and create them
            
            populateRoles(myTeamID)
        }
    }
    
    private func createStages()
    {
        if myDatabaseConnection.getStages(myTeamID).count == 0
        {
            // There are no roles defined so we need to go in and create them
            
            populateStages(myTeamID)
        }
    }
    
    func loadRoles()
    {
        myRoles = myDatabaseConnection.getRoles(myTeamID)
    }
    
    func loadStages()
    {
        myStages = myDatabaseConnection.getVisibleStages(myTeamID)
    }
    
    func loadGTDLevels()
    {
        myGTD.removeAll()
        for myItem in myDatabaseConnection.getGTDLevels(myTeamID)
        {
            let myWorkingLevel = workingGTDLevel(inGTDLevel: myItem.gTDLevel as! Int, inTeamID: myTeamID)
            myGTD.append(myWorkingLevel)
        }

        loadGTDTopLevel()
    }
    
    func loadGTDTopLevel()
    {
        myGTDTopLevel.removeAll()
        for myItem in myDatabaseConnection.getGTDItemsForLevel(1, inTeamID: myTeamID)
        {
            let myWorkingLevel = workingGTDItem(inGTDItemID: myItem.gTDItemID as! Int, inTeamID: myTeamID)
            myGTDTopLevel.append(myWorkingLevel)
        }
    }
    
    func loadContexts()
    {
        myContexts.removeAll()
        for myItem in myDatabaseConnection.getContexts(myTeamID)
        {
            let myWorkingContext = context(inContext: myItem)
            myContexts.append(myWorkingContext)
        }
    }
    
    func save()
    {
        myDatabaseConnection.saveTeam(myTeamID, inName: myName, inStatus: myStatus, inNote: myNote, inType: myType, inPredecessor: myPredecessor, inExternalID: myExternalID)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "performSave", userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myTeam = myDatabaseConnection.getTeam(myTeamID)[0]
    
        myCloudDB.saveTeamRecordToCloudKit(myTeam)
        
        saveCalled = false
    }
}
