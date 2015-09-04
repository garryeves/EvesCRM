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
var dropboxCoreService: DropboxCoreService = DropboxCoreService()
var myDatabaseConnection: coreDatabase!
var adbk : ABAddressBook!
var eventStore: EKEventStore!
var myTeamID: Int = 1

var myCurrentViewController: AnyObject!

let myRowColour = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)

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
    let end = inText.characters.indexOf(":")
    
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
    let regex = try! NSRegularExpression(pattern:inOldChar, options:.CaseInsensitive)
    let myString = regex.stringByReplacingMatchesInString(inString, options:  NSMatchingOptions(), range: NSMakeRange(0, inString.characters.count), withTemplate:inNewChar)
    
    return myString
}

func populateRoles()
{
    let initialRoles = ["Project Manager",
                        "Project Executive",
                        "Project Sponsor",
                        "Technical Stakeholder",
                        "Business Stakeholder",
                        "Developer",
                        "Tester"
                        ]
    
    for initialRole in initialRoles
    {
        myDatabaseConnection.createRole(initialRole, inTeamID: myTeamID)
    }
}

func parseProjectDetails(myProject: project)->[TableData]
{
    var tableContents:[TableData] = [TableData]()
        
    writeRowToArray("Start Date = \(myProject.displayProjectStartDate)", inTable: &tableContents)
    writeRowToArray("End Date = \(myProject.displayProjectEndDate)", inTable: &tableContents)
    writeRowToArray("Status = \(myProject.projectStatus)", inTable: &tableContents)
    
    return tableContents
}


func displayTeamMembers(inProject: project, inout lookupArray: [String])->[TableData]
{
    var tableContents:[TableData] = [TableData]()
    
    lookupArray.removeAll(keepCapacity: false)
    
    let myTeamMembers = inProject.teamMembers
    var titleText: String = ""
    
    for myTeamMember in myTeamMembers
    {
        titleText = myTeamMember.teamMember
        titleText += " : "
        titleText += myDatabaseConnection.getRoleDescription(myTeamMember.roleID, inTeamID: myTeamID)
        
        lookupArray.append(myTeamMember.teamMember)
        
        writeRowToArray(titleText, inTable: &tableContents)
    }
    
    return tableContents
}

func displayProjectsForPerson(inPerson: String, inout lookupArray: [String]) -> [TableData]
{
    var tableContents:[TableData] = [TableData]()
    var titleText: String = ""
    
    lookupArray.removeAll(keepCapacity: false)
    
    let myProjects = myDatabaseConnection.getProjectsForPerson(inPerson)
    
    if myProjects.count == 0
    {
        writeRowToArray("Not a member of any Project", inTable: &tableContents)
    }
    else
    {
        for myProject in myProjects
        {
            let myDetails = myDatabaseConnection.getProjectDetails(myProject.projectID as Int, inTeamID: myTeamID)
        
            if myDetails[0].projectStatus != "Archived"
            {
                titleText = myDetails[0].projectName
                titleText += " : "
                titleText += myDatabaseConnection.getRoleDescription(myProject.roleID, inTeamID: myTeamID)
                
                lookupArray.append(myProject.projectID.stringValue)
                
                writeRowToArray(titleText, inTable: &tableContents)
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
        var range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
        while range.location == NSNotFound {
            let tmpData = fileHandle.readDataOfLength(chunkSize)
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
            range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
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


func populateStages()
{
    let loadSet = ["Pre-Planning", "Planning", "Planned", "Scheduled", "In-progress", "Delayed", "Completed", "Archived"]
    
    for myItem in loadSet
    {
        if !myDatabaseConnection.stageExists(myItem, inTeamID: myTeamID)
        {
            myDatabaseConnection.createStage(myItem, inTeamID: myTeamID)
        }
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

func fixStringForSearch(inString: String) -> String
{
    let myTextReplacement = ";!@"  // using this as unlikely to occur naturally together
    
    let tempStr1 = inString.stringByReplacingOccurrencesOfString("https:", withString:"https\(myTextReplacement)")
    let tempStr2 = tempStr1.stringByReplacingOccurrencesOfString("http:", withString:"http\(myTextReplacement)")
    let tempStr3 = tempStr2.stringByReplacingOccurrencesOfString("onenote:", withString:"onenote\(myTextReplacement)")
    let tempStr4 = tempStr3.stringByReplacingOccurrencesOfString("0:", withString:"0\(myTextReplacement)")
    let tempStr5 = tempStr4.stringByReplacingOccurrencesOfString("1:", withString:"1\(myTextReplacement)")
    let tempStr6 = tempStr5.stringByReplacingOccurrencesOfString("2:", withString:"2\(myTextReplacement)")
    let tempStr7 = tempStr6.stringByReplacingOccurrencesOfString("3:", withString:"3\(myTextReplacement)")
    let tempStr8 = tempStr7.stringByReplacingOccurrencesOfString("4:", withString:"4\(myTextReplacement)")
    let tempStr9 = tempStr8.stringByReplacingOccurrencesOfString("5:", withString:"5\(myTextReplacement)")
    let tempStr10 = tempStr9.stringByReplacingOccurrencesOfString("6:", withString:"6\(myTextReplacement)")
    let tempStr11 = tempStr10.stringByReplacingOccurrencesOfString("7:", withString:"7\(myTextReplacement)")
    let tempStr12 = tempStr11.stringByReplacingOccurrencesOfString("8:", withString:"8\(myTextReplacement)")
    let tempStr13 = tempStr12.stringByReplacingOccurrencesOfString("9:", withString:"9\(myTextReplacement)")
    let tempStr14 = tempStr13.stringByReplacingOccurrencesOfString("(id,name,self)", withString:"")
    let tempStr15 = tempStr14.stringByReplacingOccurrencesOfString("/$entity,parentNotebook", withString:"")
    let tempStr16 = tempStr15.stringByReplacingOccurrencesOfString("\"", withString:"")
    let tempStr17 = tempStr16.stringByReplacingOccurrencesOfString("{", withString:"")
    let tempStr18 = tempStr17.stringByReplacingOccurrencesOfString("}", withString:"")
    let tempStr19 = tempStr18.stringByReplacingOccurrencesOfString("href:", withString:"")
    let tempStr20 = tempStr19.stringByReplacingOccurrencesOfString("links:", withString:"")
    
    return tempStr20
}

func returnSearchStringToNormal(inString: String) -> String
{
    let myTextReplacement = ";!@"  // using this as unlikely to occur naturally together
    
    let tempStr1 = inString.stringByReplacingOccurrencesOfString("https\(myTextReplacement)", withString:"https:")
    let tempStr2 = tempStr1.stringByReplacingOccurrencesOfString("http\(myTextReplacement)", withString:"http:")
    let tempStr3 = tempStr2.stringByReplacingOccurrencesOfString("onenote\(myTextReplacement)", withString:"onenote:")
    let tempStr4 = tempStr3.stringByReplacingOccurrencesOfString("0\(myTextReplacement)", withString:"0:")
    let tempStr5 = tempStr4.stringByReplacingOccurrencesOfString("1\(myTextReplacement)", withString:"1:")
    let tempStr6 = tempStr5.stringByReplacingOccurrencesOfString("2\(myTextReplacement)", withString:"2:")
    let tempStr7 = tempStr6.stringByReplacingOccurrencesOfString("3\(myTextReplacement)", withString:"3:")
    let tempStr8 = tempStr7.stringByReplacingOccurrencesOfString("4\(myTextReplacement)", withString:"4:")
    let tempStr9 = tempStr8.stringByReplacingOccurrencesOfString("5\(myTextReplacement)", withString:"5:")
    let tempStr10 = tempStr9.stringByReplacingOccurrencesOfString("6\(myTextReplacement)", withString:"6:")
    let tempStr11 = tempStr10.stringByReplacingOccurrencesOfString("7\(myTextReplacement)", withString:"7:")
    let tempStr12 = tempStr11.stringByReplacingOccurrencesOfString("8\(myTextReplacement)", withString:"8:")
    let tempStr13 = tempStr12.stringByReplacingOccurrencesOfString("9\(myTextReplacement)", withString:"9:")
    
    return tempStr13
}

func characterAtIndex(inString: String, index: Int) -> Character {
    var cur = 0
    var retVal: Character!
    for char in inString.characters {
        if cur == index {
            retVal = char
        }
        cur++
    }
    return retVal
}

class MyDisplayCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var Label: UILabel! = UILabel()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        Label.text = ""
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Label.text = ""
    }
}

class menuObject: NSObject
{
    private var myDisplayString: String = ""
    private var myDisplayType: String = ""
    private var myDisplayObject: NSObject!
    
    var displayString: String
    {
        get
        {
            return myDisplayString
        }
        set
        {
            myDisplayString = newValue
        }
    }

    var displayType: String
    {
        get
        {
            return myDisplayType
        }
        set
        {
            myDisplayType = newValue
        }
    }

    var displayObject: NSObject
    {
        get
        {
            return myDisplayObject
        }
        set
        {
            myDisplayObject = newValue
        }
    }
}

//class SharingActivityProvider: UIActivityItemProvider, UIActivityItemSource
class SharingActivityProvider: UIActivityItemProvider
{
    var HTMLString : String!
    var plainString : String!
    var messageSubject: String!
    
    override func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject?
    {
        switch activityType
        {
        case UIActivityTypeMail:
            return HTMLString
            
        case UIActivityTypePrint:
            return HTMLString
            
        case UIActivityTypeCopyToPasteboard:
            return HTMLString
            
        default:
            return plainString
        }
    }
    
    override func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject
    {
        return "";
    }
    
    override func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String
    {
        return messageSubject
    }
}

class textViewTapGestureRecognizer:UITapGestureRecognizer
{
    private var myTag: Int = 0
    private var myTargetObject: AnyObject!
    private var myView: UIView!
    private var myHeadBody: String = ""
    private var myType: String = ""
    
    var tag: Int
    {
        get
        {
            return myTag
        }
        set
        {
            myTag = newValue
        }
    }

    var targetObject: AnyObject
    {
        get
        {
            return myTargetObject
        }
        set
        {
            myTargetObject = newValue
            
            if newValue.isKindOfClass(team)
            {
                myType = "team"
            }
            else if newValue.isKindOfClass(purposeAndCoreValue)
            {
                myType = "purposeAndCoreValue"
            }
            else if newValue.isKindOfClass(gvision)
            {
                myType = "gvision"
            }
            else if newValue.isKindOfClass(goalAndObjective)
            {
                myType = "goalAndObjective"
            }
            else if newValue.isKindOfClass(areaOfResponsibility)
            {
                myType = "areaOfResponsibility"
            }
            else if newValue.isKindOfClass(project)
            {
                myType = "project"
            }
            else if newValue.isKindOfClass(task)
            {
                myType = "task"
            }
            else if newValue.isKindOfClass(context)
            {
                myType = "context"
            }
        }
    }

    var displayView: UIView
    {
        get
        {
            return myView
        }
        set
        {
            myView = newValue
        }
    }
    
    var headBody: String
    {
        get
        {
            return myHeadBody
        }
        set
        {
            myHeadBody = newValue
        }
    }

    var type: String
        {
        get
        {
            return myType
        }
    }
}

class textLongPressGestureRecognizer:UILongPressGestureRecognizer
{
    private var myTag: Int = 0
    private var myTargetObject: AnyObject!
    private var myView: UIView!
    private var myHeadBody: String = ""
    private var myType: String = ""
    
    var tag: Int
        {
        get
        {
            return myTag
        }
        set
        {
            myTag = newValue
        }
    }
    
    var targetObject: AnyObject
        {
        get
        {
            return myTargetObject
        }
        set
        {
            myTargetObject = newValue
            
            if newValue.isKindOfClass(team)
            {
                myType = "team"
            }
            else if newValue.isKindOfClass(purposeAndCoreValue)
            {
                myType = "purposeAndCoreValue"
            }
            else if newValue.isKindOfClass(gvision)
            {
                myType = "gvision"
            }
            else if newValue.isKindOfClass(goalAndObjective)
            {
                myType = "goalAndObjective"
            }
            else if newValue.isKindOfClass(areaOfResponsibility)
            {
                myType = "areaOfResponsibility"
            }
            else if newValue.isKindOfClass(project)
            {
                myType = "project"
            }
            else if newValue.isKindOfClass(task)
            {
                myType = "task"
            }
            else if newValue.isKindOfClass(context)
            {
                myType = "context"
            }
        }
    }
    
    var displayView: UIView
        {
        get
        {
            return myView
        }
        set
        {
            myView = newValue
        }
    }
    
    var headBody: String
        {
        get
        {
            return myHeadBody
        }
        set
        {
            myHeadBody = newValue
        }
    }
    
    var type: String
        {
        get
        {
            return myType
        }
    }
}

func getDefaultDate() -> NSDate
{
    let dateStringFormatter = NSDateFormatter()
    dateStringFormatter.dateFormat = "yyyy-MM-dd"
    return dateStringFormatter.dateFromString("9999-12-31")!
}

