//
//  EvesCRMSharedFiles.swift
//  EvesCRM
//
//  Created by Garry Eves on 19/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import AddressBook
import EventKit

func writeRowToArray(inDisplayText: String, inout inTable: [TableData], inDisplayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: inDisplayText)
    
    if inDisplayFormat != ""
    {
        myDisplay.displaySpecialFormat = inDisplayFormat
    }
    
    inTable.append(myDisplay)
}

// Here I am definging my own struct to use in the Display array.  This is to allow passing of multiple different types of information

struct TableData
{
    var displayText: String
    
    private var myDisplayFormat: String
    
    var displaySpecialFormat: String
    {
        get {
            return myDisplayFormat
        }
        set {
            myDisplayFormat = newValue
        }
    }


    //GRE what shoudl this be   var itemIdentifier: NSIdentifier?
    
    
    init(displayText: String)
    {
        self.displayText = displayText
        self.myDisplayFormat = ""
    }
}

// Here I am definging my own struct to use in the Display array.  This is to allow passing of multiple different types of information

struct PeopleData
{
    var fullName: String
    private var myDisplayFormat: String
    var personRecord: ABRecordRef
    
    var displaySpecialFormat: String
        {
        get {
            return myDisplayFormat
        }
        set {
            myDisplayFormat = newValue
        }
    }
    
    init(fullName: String, inRecord: ABRecordRef)
    {
        self.fullName = fullName
        self.myDisplayFormat = ""
        self.personRecord = inRecord
    }
}

struct ReminderData
{
    var reminderText: String
    private var myDisplayFormat: String
    private var myPriority: Int
    private var myNotes: String!
    var reminderCalendar: EKCalendar
    
    var displaySpecialFormat: String
        {
        get {
            return myDisplayFormat
        }
        set {
            myDisplayFormat = newValue
        }
    }

    var priority: Int
        {
        get {
            return myPriority
        }
        set {
            myPriority = newValue
        }
    }

    var notes: String!
        {
        get {
            return myNotes
        }
        set {
            myNotes = newValue
        }
    }
    
    init(reminderText: String, reminderCalendar: EKCalendar)
    {
        self.reminderText = reminderText
        self.myDisplayFormat = ""
        self.myPriority = 0
        self.myNotes = ""
        self.reminderCalendar = reminderCalendar
    }
}