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
    private var myName: String = ""
    private var myNote: String = ""
    private var myStatus: String = ""
    private var myType: String = ""
    private var myPredecessor: Int = 0
    private var myExternalID: Int = 0
    
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
    }

    override init()
    {
        super.init()
        
        let currentNumberofEntries = myDatabaseConnection.getTeamsCount()
        
        let nextID = currentNumberofEntries + 1
        
        myTeamID = nextID
        
        save()
    }
    
    func save()
    {
        myDatabaseConnection.saveTeam(myTeamID, inName: myName, inStatus: myStatus, inNote: myNote, inType: myType, inPredecessor: myPredecessor, inExternalID: myExternalID)
    }
}
