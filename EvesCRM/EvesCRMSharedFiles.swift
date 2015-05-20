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
    var initialRoles = ["Project Manager",
                        "Project Executive",
                        "Project Sponsor",
                        "Technical Stakeholder",
                        "Business Stakeholder",
                        "Developer",
                        "Tester"
                        ]
    
    for initialRole in initialRoles
    {
        createRole(initialRole)
    }
}

func getMaxRoleID()-> Int
{
    var retVal: Int = 0

    let fetchRequest = NSFetchRequest(entityName: "Roles")

    fetchRequest.propertiesToFetch = ["roleID"]

    let sortDescriptor = NSSortDescriptor(key: "roleID", ascending: true)
    let sortDescriptors = [sortDescriptor]
    fetchRequest.sortDescriptors = sortDescriptors
    
    // Execute the fetch request, and cast the results to an array of LogItem objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
    
    for myItem in fetchResults!
    {
        retVal = myItem.roleID as Int
    }
    
    return retVal + 1
}

func createRole(inRoleName: String)
{
    var mySelectedRole: Roles
    var error : NSError?
    
    mySelectedRole = NSEntityDescription.insertNewObjectForEntityForName("Roles", inManagedObjectContext: managedObjectContext!) as! Roles
    mySelectedRole.roleID = getMaxRoleID()
    mySelectedRole.roleDescription = inRoleName
    
    if(managedObjectContext!.save(&error) )
    {
        println(error?.localizedDescription)
    }
}

func deleteRoleEntry(inRoleName: String)
{
    var error : NSError?
    
    let fetchRequest = NSFetchRequest(entityName: "Roles")
    
    let predicate = NSPredicate(format: "roleDescription == \"\(inRoleName)\"")
    
    // Set the predicate on the fetch request
    fetchRequest.predicate = predicate
    
    // Execute the fetch request, and cast the results to an array of  objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Roles]
    for myStage in fetchResults!
    {
        managedObjectContext!.deleteObject(myStage as NSManagedObject)
    }
    
    if(managedObjectContext!.save(&error) )
    {
        println(error?.localizedDescription)
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

func displayTeamMembers(inProjectID: NSNumber, inout lookupArray: [String])->[TableData]
{
    var tableContents:[TableData] = [TableData]()
    
    lookupArray.removeAll(keepCapacity: false)
    
    let myTeamMembers = getTeamMembers(inProjectID)
    var titleText: String = ""
    
    for myTeamMember in myTeamMembers
    {
        titleText = myTeamMember.teamMember
        titleText += " : "
        titleText += getRoleDescription(myTeamMember.roleID)
        
        lookupArray.append(myTeamMember.teamMember)
        
        writeRowToArray(titleText, &tableContents)
    }
    
    return tableContents
}

func displayProjectsForPerson(inPerson: String, inout lookupArray: [String]) -> [TableData]
{
    var tableContents:[TableData] = [TableData]()
    var titleText: String = ""
    
    lookupArray.removeAll(keepCapacity: false)
    
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
                titleText = myDetails[0].projectName
                titleText += " : "
                titleText += getRoleDescription(myProject.roleID)
                
                lookupArray.append(myProject.projectID.stringValue)
                
                writeRowToArray(titleText, &tableContents)
                //writeRowToArray(myDetails[0].projectName, &tableContents)
            }
        }
    }
    return tableContents
}

class MyDocument: UIDocument
{
    var userText: String? = "Some Sample Text"
}

/*
 from http://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift

*/
class StreamReader  {
    
    let encoding : UInt
    let chunkSize : Int
    
    var fileHandle : NSFileHandle!
    let buffer : NSMutableData!
    let delimData : NSData!
    var atEof : Bool = false
    
    init?(path: String, delimiter: String = "\r", encoding : UInt = NSUTF8StringEncoding, chunkSize : Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding
        
        if let fileHandle = NSFileHandle(forReadingAtPath: path),
            delimData = delimiter.dataUsingEncoding(encoding),
            buffer = NSMutableData(capacity: chunkSize)
        {
            self.fileHandle = fileHandle
            self.delimData = delimData
            self.buffer = buffer
        } else {
            self.fileHandle = nil
            self.delimData = nil
            self.buffer = nil
            return nil
        }
    }
    
    deinit {
        self.close()
    }
    
    /// Return next line, or nil on EOF.
    func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")
        
        if atEof {
            return nil
        }
        
        // Read data chunks from file until a line delimiter is found:
        var range = buffer.rangeOfData(delimData, options: nil, range: NSMakeRange(0, buffer.length))
        while range.location == NSNotFound {
            var tmpData = fileHandle.readDataOfLength(chunkSize)
            if tmpData.length == 0 {
                // EOF or read error.
                atEof = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer, encoding: encoding)
                    
                    buffer.length = 0
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer.appendData(tmpData)
            range = buffer.rangeOfData(delimData, options: nil, range: NSMakeRange(0, buffer.length))
        }
        
        // Convert complete line (excluding the delimiter) to a string:
        let line = NSString(data: buffer.subdataWithRange(NSMakeRange(0, range.location)),
            encoding: encoding)
        // Remove line (and the delimiter) from the buffer:
        buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        
        return line as String?
    }
    
    /// Start reading from the beginning of file.
    func rewind() -> Void {
        fileHandle.seekToFileOffset(0)
        buffer.length = 0
        atEof = false
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}

func getDecodeValue(inCodeType: String) -> String
{
    let fetchRequest = NSFetchRequest(entityName: "Decodes")
    let predicate = NSPredicate(format: "decode_name == \"\(inCodeType)\"")
    
    // Set the predicate on the fetch request
    fetchRequest.predicate = predicate
    
    // Execute the fetch request, and cast the results to an array of  objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Decodes]
    
    if fetchResults!.count == 0
    {
        return ""
    }
    else
    {
        return fetchResults![0].decode_value
    }
}

func updateDecodeValue(inCodeType: String, inCodeValue: String)
{
    // first check to see if decode exists, if not we create
    
    var error: NSError?
    var myDecode: Decodes!

    if getDecodeValue(inCodeType) == ""
    { // Add
        myDecode = NSEntityDescription.insertNewObjectForEntityForName("Decodes", inManagedObjectContext: managedObjectContext!) as! Decodes
        
        myDecode.decode_name = inCodeType
        myDecode.decode_value = inCodeValue
    }
    else
    { // Update
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
        let predicate = NSPredicate(format: "decode_name == \"\(inCodeType)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let myDecodes = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Decodes]
        myDecode = myDecodes![0]
        myDecode.decode_value = inCodeValue
    }
    
    if(managedObjectContext!.save(&error) )
    {
     //   println(error?.localizedDescription)
    }
}

func getStages()->[Stages]
{
    let fetchRequest = NSFetchRequest(entityName: "Stages")
    
    // Execute the fetch request, and cast the results to an array of  objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
    
    return fetchResults!
}

func populateStages()
{
    var loadSet = ["Pre-Planning", "Planning", "Planned", "Scheduled", "In-progress", "Delayed", "Completed", "Archived"]
    
    for myItem in loadSet
    {
        if !stageExists(myItem)
        {
            createStage(myItem)
        }
    }
}

func stageExists(inStageDesc:String)-> Bool
{
    let fetchRequest = NSFetchRequest(entityName: "Stages")
    
    // Create a new predicate that filters out any object that
    // doesn't have a title of "Best Language" exactly.
    let predicate = NSPredicate(format: "stageDescription == \"\(inStageDesc)\"")
    
    // Set the predicate on the fetch request
    fetchRequest.predicate = predicate
    
    // Create a new fetch request using the entity
    
    // Execute the fetch request, and cast the results to an array of LogItem objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
    
    if fetchResults!.count > 0
    {
        return true
    }
    else
    {
        return false
    }
}

func createStage(inStageDesc: String)
{
    // Save the details of this pane to the database
    var error: NSError?
    let myStage = NSEntityDescription.insertNewObjectForEntityForName("Stages", inManagedObjectContext: managedObjectContext!) as! Stages
    
    myStage.stageDescription = inStageDesc

    if(managedObjectContext!.save(&error) )
    {
        println(error?.localizedDescription)
    }
}

func deleteStageEntry(inStageDesc: String)
{
    var error : NSError?

    let fetchRequest = NSFetchRequest(entityName: "Stages")
    
    let predicate = NSPredicate(format: "stageDescription == \"\(inStageDesc)\"")
    
    // Set the predicate on the fetch request
    fetchRequest.predicate = predicate

    // Execute the fetch request, and cast the results to an array of  objects
    let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Stages]
    for myStage in fetchResults!
    {
        managedObjectContext!.deleteObject(myStage as NSManagedObject)
    }
    
    if(managedObjectContext!.save(&error) )
    {
    println(error?.localizedDescription)
    }
}

func setCellFormatting (inCell: UITableViewCell, inDisplayFormat: String) -> UITableViewCell
{
    inCell.textLabel!.numberOfLines = 0;
    inCell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
    
    if inDisplayFormat != ""
    {
        switch inDisplayFormat
        {
        case "Gray" :
            inCell.textLabel!.textColor = UIColor.grayColor()
            
        case "Red" :
            inCell.textLabel!.textColor = UIColor.redColor()
            
        case "Yellow" :
            inCell.textLabel!.textColor = UIColor.yellowColor()
            
        case "Orange" :
            inCell.textLabel!.textColor = UIColor.orangeColor()
            
        case "Purple" :
            inCell.textLabel!.textColor = UIColor.purpleColor()
            
        case "Header":
            inCell.textLabel!.font = UIFont.boldSystemFontOfSize(24.0)
            inCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
        default:
            inCell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            inCell.textLabel!.textColor = UIColor.blackColor()
        }
    }
    else
    {
        inCell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        inCell.textLabel!.textColor = UIColor.blackColor()
    }
    
    return inCell
    
}
