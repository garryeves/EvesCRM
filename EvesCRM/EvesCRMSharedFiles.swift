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

// Here I am definging my own struct to use in the Display array.  This is to allow passing of multiple different types of information

struct TableData
{
    var displayText: String
    
    private var myDisplayFormat: String
    private var myObjectType: String
    private var myReminderPriority: Int
    private var myNotes: String
    private var mycalendarItemIdentifier: String
    
    var displaySpecialFormat: String
        {
        get {
            return myDisplayFormat
        }
        set {
            myDisplayFormat = newValue
        }
    }
    
    var objectType: String
        {
        get {
            return myObjectType
        }
        set {
            myObjectType = newValue
        }
    }
    
    var reminderPriority: Int
        {
        get {
            return myReminderPriority
        }
        set {
            myReminderPriority = newValue
        }
    }
    
    var calendarItemIdentifier: String
        {
        get {
            return mycalendarItemIdentifier
        }
        set {
            mycalendarItemIdentifier = newValue
        }
    }
    
    var notes: String
        {
        get {
            return myNotes
        }
        set {
            myNotes = newValue
        }
    }
    
    init(displayText: String)
    {
        self.displayText = displayText
        self.myDisplayFormat = ""
        self.myObjectType = ""
        self.myReminderPriority = 0
        self.mycalendarItemIdentifier = ""
        self.myNotes = ""
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
    private var mycalendarItemIdentifier: String!
    
    var reminderCalendar: EKCalendar?
    
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
    
    var calendarItemIdentifier: String!
        {
        get {
            return mycalendarItemIdentifier
        }
        set {
            mycalendarItemIdentifier = newValue
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
        self.mycalendarItemIdentifier = ""
    }
    
    init()
    {
        self.reminderText = ""
        self.myDisplayFormat = ""
        self.myPriority = 0
        self.myNotes = ""
        self.reminderCalendar = nil
        self.mycalendarItemIdentifier = ""
    }

}

struct EvernoteData
{
    private var myTitle: String
    private var myUpdateDate: NSDate!
    private var myCreateDate: NSDate!
    private var myIdentifier: String
    private var myNoteRef: ENNoteRef!

    var title: String
        {
        get {
            return myTitle
        }
        set {
            myTitle = newValue
        }
    }
    
    var updateDate: NSDate
        {
        get {
            return myUpdateDate
        }
        set {
            myUpdateDate = newValue
        }
    }
    
    var createDate: NSDate
        {
        get {
            return myCreateDate
        }
        set {
            myCreateDate = newValue
        }
    }
    
    var identifier: String
        {
        get {
            return myIdentifier
        }
        set {
            myIdentifier = newValue
        }
    }

    var NoteRef: ENNoteRef
        {
        get {
            return myNoteRef
        }
        set {
            myNoteRef = newValue
        }
    }

    
    init()
    {
        self.myTitle = ""
        self.myIdentifier = ""
    }
    
}

// Overloading writeRowToArray a number of times to allow for collection of structs where I am going to allow user to interact and change data inside the app,rather than them having to go to source app.  The number of these will be kept to a minimum.


func writeRowToArray(inDisplayFormat: String, inReminder: ReminderData, inout inTable: [TableData])
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: inReminder.reminderText)
    
    if inDisplayFormat != ""
    {
        myDisplay.displaySpecialFormat = inDisplayFormat
    }
    
    myDisplay.calendarItemIdentifier = inReminder.calendarItemIdentifier
    myDisplay.reminderPriority = inReminder.priority
    myDisplay.notes = inReminder.notes
    
    myDisplay.objectType = "Reminders"
  
    inTable.append(myDisplay)
}

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

func getFirstPartofString(inText: String) -> String
{
    let start = inText.startIndex
    let end = find(inText, " ")
    
    var selectedType: String = ""
    
    if end != nil
    {
        let myEnd = end?.predecessor()
        selectedType = inText[start...myEnd!]
    }
    else
    { // no space found
        selectedType = inText
    }
    return selectedType
}

func stringByChangingChars(inString: String, inOldChar: String, inNewChar: String) -> String
{
    var error:NSError?
    
    let regex = NSRegularExpression(pattern:inOldChar, options:.CaseInsensitive, error:&error)!
    let myString = regex.stringByReplacingMatchesInString(inString, options:  NSMatchingOptions.allZeros, range: NSMakeRange(0, count(inString)), withTemplate:inNewChar)
    
    return myString
}

