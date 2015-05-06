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
import CoreData


let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext


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
    let end = find(inText, ":")
    
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

func getProjects()->[Projects]
{
    
    
  //  let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    
    // Set the list of sort descriptors in the fetch request,
    // so it includes the sort descriptor
  //  fetchRequest.sortDescriptors = [sortDescriptor]
     let fetchRequest = NSFetchRequest(entityName: "Projects")
    
    // Create a new predicate that filters out any object that
    // doesn't have a title of "Best Language" exactly.
    let predicate = NSPredicate(format: "projectStatus != \"Archived\"")
    
    // Set the predicate on the fetch request
    fetchRequest.predicate = predicate
    
    // Create a new fetch request using the entity
    
    // Execute the fetch request, and cast the results to an array of LogItem objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
 
    return fetchResults!
}

func getProjectDetails(myProjectID: NSNumber)->[Projects]
{
    
    let fetchRequest = NSFetchRequest(entityName: "Projects")
    
    // Create a new predicate that filters out any object that
    // doesn't have a title of "Best Language" exactly.
    let predicate = NSPredicate(format: "projectID == \(myProjectID)")
    
    // Set the predicate on the fetch request
    fetchRequest.predicate = predicate
    
    // Create a new fetch request using the entity
    
    // Execute the fetch request, and cast the results to an array of LogItem objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
    
    return fetchResults!
}


func getAllProjects()->[Projects]
{
    
    
    //  let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    
    // Set the list of sort descriptors in the fetch request,
    // so it includes the sort descriptor
    //  fetchRequest.sortDescriptors = [sortDescriptor]
    
    let fetchRequest = NSFetchRequest(entityName: "Projects")
    
    // Execute the fetch request, and cast the results to an array of objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Projects]
    
    return fetchResults!
}

func getRoles()->[Roles]
{
    let fetchRequest = NSFetchRequest(entityName: "Roles")
    
    // Execute the fetch request, and cast the results to an array of  objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
    
    return fetchResults!
}

func populateRoles()
{
    
/*
    let fetchRequest = NSFetchRequest(entityName: "Roles")
    
    // Execute the fetch request, and cast the results to an array of  objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]

    //var bas: NSManagedObject!
    
    for bas  in fetchResults!
    {
        managedObjectContext!.deleteObject(bas as NSManagedObject)
println("delete")
    }
    var error : NSError?
    
    if(managedObjectContext!.save(&error) )
    {
        println(error?.localizedDescription)
    }
*/
    
    var initialRoles = ["Project Manager",
                        "Project Executive",
                        "Project Sponsor",
                        "Technical Stakeholder",
                        "Business Stakeholder",
                        "Developer",
                        "Tester"
                        ]
    
    var rowCount: Int = 1
 
    var mySelectedRole: Roles
    var error : NSError?
    
    for initialRole in initialRoles
    {
           mySelectedRole = NSEntityDescription.insertNewObjectForEntityForName("Roles", inManagedObjectContext: managedObjectContext!) as! Roles
          mySelectedRole.roleID = rowCount
            mySelectedRole.roleDescription = initialRole
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }

        rowCount = rowCount + 1
    }
}

func getTeamMembers(inProjectID: NSNumber)->[ProjectTeamMembers]
{
    let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")

    // Create a new predicate that filters out any object that
    // doesn't have a title of "Best Language" exactly.
    let predicate = NSPredicate(format: "projectID == \(inProjectID)")
    
    // Set the predicate on the fetch request
    fetchRequest.predicate = predicate

    // Execute the fetch request, and cast the results to an array of LogItem objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTeamMembers]
    
    return fetchResults!
}

func getProjectsForPerson(inPersonName: String)->[ProjectTeamMembers]
{
    let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
    
    // Create a new predicate that filters out any object that
    // doesn't have a title of "Best Language" exactly.
    
    var predicate: NSPredicate
    
    predicate = NSPredicate(format: "teamMember == \"\(inPersonName)\"")
    
    // Set the predicate on the fetch request
    fetchRequest.predicate = predicate
    
    // Execute the fetch request, and cast the results to an array of LogItem objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [ProjectTeamMembers]
    
    return fetchResults!
}


func getRoleDescription(inRoleID: NSNumber)->String
{
    let fetchRequest = NSFetchRequest(entityName: "Roles")
    let predicate = NSPredicate(format: "roleID == \(inRoleID)")
    
    // Set the predicate on the fetch request
    fetchRequest.predicate = predicate
    
    // Execute the fetch request, and cast the results to an array of  objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
    
    if fetchResults!.count == 0
    {
        return ""
    }
    else
    {
        return fetchResults![0].roleDescription
    }
}

func parseProjectDetails(myProjectID: NSNumber)->[TableData]
{
    var tableContents:[TableData] = [TableData]()
    var myDateFormatter = NSDateFormatter()
    
    var dateFormat = NSDateFormatterStyle.FullStyle
    myDateFormatter.dateStyle = dateFormat
    
    let myProjects = getProjectDetails(myProjectID)
    
    if myProjects.count == 0
    {
        writeRowToArray("No Project data is available", &tableContents)
    }
    else
    {
        let dateStart = myDateFormatter.stringFromDate(myProjects[0].projectStartDate)
        let dateEnd = myDateFormatter.stringFromDate(myProjects[0].projectEndDate)
        
        writeRowToArray("Start Date = \(dateStart)", &tableContents)
        writeRowToArray("End Date = \(dateEnd)", &tableContents)
        writeRowToArray("Status = \(myProjects[0].projectStatus)", &tableContents)
    }
   
    return tableContents
}

func displayTeamMembers(inProjectID: NSNumber)->[TableData]
{
    var tableContents:[TableData] = [TableData]()
    
    let myTeamMembers = getTeamMembers(inProjectID)
    var titleText: String = ""
    
    for myTeamMember in myTeamMembers
    {
        titleText = myTeamMember.teamMember
        titleText += " : "
        titleText += getRoleDescription(myTeamMember.roleID)
        
        writeRowToArray(titleText, &tableContents)
    }
    
    return tableContents
}

func displayProjectsForPerson(inPerson: String) -> [TableData]
{
    var tableContents:[TableData] = [TableData]()

    let myProjects = getProjectsForPerson(inPerson)
    
    if myProjects.count == 0
    {
        writeRowToArray("Not a member of any Project", &tableContents)
    }
    else
    {
        for myProject in myProjects
        {
            let myDetails = getProjectDetails(myProject.projectID)
        
            if myDetails[0].projectStatus != "Archived"
            {
            writeRowToArray(myDetails[0].projectName, &tableContents)
            }
        }
    }
    return tableContents
}