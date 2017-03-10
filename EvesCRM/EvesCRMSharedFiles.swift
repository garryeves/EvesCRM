//
//  EvesCRMSharedFiles.swift
//  EvesCRM
//
//  Created by Garry Eves on 19/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import EventKit

import Contacts

var adbk: CNContactStore!

#if os(OSX)
    import AppKit
#endif

// Here I am definging my own struct to use in the Display array.  This is to allow passing of multiple different types of information
#if os(iOS)
//GRE    var dropboxCoreService: DropboxCoreService = DropboxCoreService()
    
#elseif os(OSX)
//
#else
    // NSLog("Unexpected OS")
#endif

var myDatabaseConnection: coreDatabase!
var myCloudDB: CloudKitInteraction!
let myDBSync = DBSync()
var globalEventStore: EKEventStore!
var debugMessages: Bool = false

var myCurrentTeam: team!

var myID: String = ""

var myCurrentViewController: AnyObject!

#if os(iOS)
    let myRowColour = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
#elseif os(OSX)
//    let myRowColour = NSColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25) as! CGColor
    let myRowColour = CGColorCreateGenericRGB(0.75, 1.0, 0.92, 0.25)
#endif


struct TableData
{
    var displayText: String
    
    fileprivate var myDisplayFormat: String
    fileprivate var myObjectType: String
    fileprivate var myReminderPriority: Int
    fileprivate var myNotes: String
    fileprivate var mycalendarItemIdentifier: String
    fileprivate var myTask: task!
    fileprivate var myEvent: myCalendarItem!
    fileprivate var myObject: AnyObject!
    
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
    
    var targetTask: task
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
    
    var targetEvent: myCalendarItem
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
    
    var targetObject: AnyObject
    {
        get
        {
            return myObject
        }
        set
        {
            myObject = newValue
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
    fileprivate var myDisplayFormat: String
    var personRecord: CNContact
    
    var displaySpecialFormat: String
        {
        get {
            return myDisplayFormat
        }
        set {
            myDisplayFormat = newValue
        }
    }
    
    init(fullName: String, inRecord: CNContact)
    {
        self.fullName = fullName
        self.myDisplayFormat = ""
        self.personRecord = inRecord
    }
}

struct EvernoteData
{
    fileprivate var myTitle: String
    fileprivate var myUpdateDate: Date!
    fileprivate var myCreateDate: Date!
    fileprivate var myIdentifier: String
    #if os(iOS)
        fileprivate var myNoteRef: ENNoteRef!
    #elseif os(OSX)
        // NSLog("Evernote to be determined")
    #else
        //NSLog("Unexpected OS")
    #endif


    var title: String
        {
        get {
            return myTitle
        }
        set {
            myTitle = newValue
        }
    }
    
    var updateDate: Date
        {
        get {
            return myUpdateDate
        }
        set {
            myUpdateDate = newValue
        }
    }
    
    var createDate: Date
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

    #if os(iOS)
        var NoteRef: ENNoteRef
        {
            get
            {
                return myNoteRef
            }
            set
            {
                myNoteRef = newValue
            }
        }

    #elseif os(OSX)
        // Evernote to do
    #else
        //    NSLog("Unexpected OS")
    #endif
    
    init()
    {
        self.myTitle = ""
        self.myIdentifier = ""
    }
    
}

// Overloading writeRowToArray a number of times to allow for collection of structs where I am going to allow user to interact and change data inside the app,rather than them having to go to source app.  The number of these will be kept to a minimum.

func writeRowToArray(_ inDisplayText: String, inTable: inout [TableData], inDisplayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: inDisplayText)

    if inDisplayFormat != ""
    {
        myDisplay.displaySpecialFormat = inDisplayFormat
    }
        
    inTable.append(myDisplay)
}

func writeRowToArray(_ displayText: String, table: inout [TableData], targetTask: task, displayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: displayText)
    
    if displayFormat != ""
    {
        myDisplay.displaySpecialFormat = displayFormat
    }
    
    myDisplay.targetTask = targetTask
    
    table.append(myDisplay)
}

func writeRowToArray(_ displayText: String, table: inout [TableData], targetEvent: myCalendarItem, displayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: displayText)
    
    if displayFormat != ""
    {
        myDisplay.displaySpecialFormat = displayFormat
    }
    
    myDisplay.targetEvent = targetEvent
    
    table.append(myDisplay)
}

func writeRowToArray(_ displayText: String, table: inout [TableData], targetObject: AnyObject, displayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: displayText)
    
    if displayFormat != ""
    {
        myDisplay.displaySpecialFormat = displayFormat
    }
    
    myDisplay.targetObject = targetObject
    
    table.append(myDisplay)
}

func getFirstPartofString(_ inText: String) -> String
{
    let start = inText.startIndex
    let end = inText.characters.index(of: ":")
    
    var selectedType: String = ""
    
    if end != nil
    {
        let myEnd = inText.index(before: (end)!)
        selectedType = inText[start...myEnd]
    }
    else
    { // no space found
        selectedType = inText
    }
    return selectedType
}

func stringByChangingChars(_ inString: String, inOldChar: String, inNewChar: String) -> String
{
    let regex = try! NSRegularExpression(pattern:inOldChar, options:.caseInsensitive)
    let myString = regex.stringByReplacingMatches(in: inString, options:  NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, inString.characters.count), withTemplate:inNewChar)
    
    return myString
}

func populateRoles(_ inTeamID: Int)
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
        myDatabaseConnection.saveRole(initialRole, teamID: inTeamID)
    }
}

func displayTeamMembers(_ inProject: project, lookupArray: inout [String])->[TableData]
{
    var tableContents:[TableData] = [TableData]()
    
    lookupArray.removeAll(keepingCapacity: false)
    
    let myTeamMembers = inProject.teamMembers
    var titleText: String = ""
    
    for myTeamMember in myTeamMembers
    {
        titleText = myTeamMember.teamMember
        titleText += " : "
        titleText += myDatabaseConnection.getRoleDescription(NSNumber(value: myTeamMember.roleID), inTeamID: inProject.teamID)
        
        lookupArray.append(myTeamMember.teamMember)
        
        let personObject = findPersonRecord(myTeamMember.teamMember)
        
        writeRowToArray(titleText, table: &tableContents, targetObject: personObject!)
    }
    
    return tableContents
}

func displayProjectsForPerson(_ inPerson: String, lookupArray: inout [String]) -> [TableData]
{
    var tableContents:[TableData] = [TableData]()
    var titleText: String = ""
    
    lookupArray.removeAll(keepingCapacity: false)
    
    let myProjects = myDatabaseConnection.getProjectsForPerson(inPerson)
    
    if myProjects.count == 0
    {
        writeRowToArray("Not a member of any Project", inTable: &tableContents)
    }
    else
    {
        for myProject in myProjects
        {
            let myDetails = myDatabaseConnection.getProjectDetails(myProject.projectID as! Int)
        
            if myDetails[0].projectStatus != "Archived"
            {
                titleText = myDetails[0].projectName
                titleText += " : "
                titleText += myDatabaseConnection.getRoleDescription(myProject.roleID, inTeamID: myDetails[0].teamID as! Int)
                
                lookupArray.append(myProject.projectID.stringValue)
                
                let projectObject = project(inProjectID: myDetails[0].projectID as! Int)

                writeRowToArray(titleText, table: &tableContents, targetObject: projectObject)
            }
        }
    }
    return tableContents
}

#if os(iOS)
    class MyDocument: UIDocument
    {
        var userText: String? = "Some Sample Text"
    }
    
#elseif os(OSX)
    class MyDocument: NSDocument
    {
        var userText: String? = "Some Sample Text"
    }
    
#else
// NSLog("Unexpected OS")
#endif

/*
 from http://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift

*/
class StreamReader  {
    
    let encoding : UInt
    let chunkSize : Int
    
    var fileHandle : FileHandle!
    let buffer : NSMutableData!
    let delimData : Data!
    var atEof : Bool = false
    
//    init?(path: String, delimiter: String = "\r", encoding : UInt = String.Encoding.utf8, chunkSize : Int = 4096) {
    init?(path: String, delimiter: String = "\r", encoding : UInt = String.Encoding.utf8.rawValue, chunkSize : Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding
        
        if let fileHandle = FileHandle(forReadingAtPath: path),
            let delimData = delimiter.data(using: String.Encoding(rawValue: encoding)),
            let buffer = NSMutableData(capacity: chunkSize)
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
        var range = buffer.range(of: delimData, options: [], in: NSMakeRange(0, buffer.length))
        while range.location == NSNotFound {
            let tmpData = fileHandle.readData(ofLength: chunkSize)
            if tmpData.count == 0 {
                // EOF or read error.
                atEof = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer as Data, encoding: encoding)
                    
                    buffer.length = 0
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer.append(tmpData)
            range = buffer.range(of: delimData, options: [], in: NSMakeRange(0, buffer.length))
        }
        
        // Convert complete line (excluding the delimiter) to a string:
        let line = NSString(data: buffer.subdata(with: NSMakeRange(0, range.location)),
            encoding: encoding)
        // Remove line (and the delimiter) from the buffer:
        buffer.replaceBytes(in: NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        
        return line as String?
    }
    
    /// Start reading from the beginning of file.
    func rewind() -> Void {
        fileHandle.seek(toFileOffset: 0)
        buffer.length = 0
        atEof = false
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}


func populateStages(_ inTeamID: Int)
{
    let loadSet = ["Definition", "Initiation", "Planning", "Execution", "Monitoring & Control", "Closure", "Completed", "Archived", "On Hold"]
    
    for myItem in loadSet
    {
        if !myDatabaseConnection.stageExists(myItem, inTeamID: inTeamID)
        {
            myDatabaseConnection.saveStage(myItem, teamID: inTeamID)
        }
    }
}

#if os(iOS)
    func setCellFormatting (_ inCell: UITableViewCell, inDisplayFormat: String) -> UITableViewCell
    {
        inCell.textLabel!.numberOfLines = 0;
        inCell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        
        if inDisplayFormat != ""
        {
            switch inDisplayFormat
            {
            case "Gray" :
                inCell.textLabel!.textColor = UIColor.gray
                
            case "Red" :
                inCell.textLabel!.textColor = UIColor.red
                
            case "Yellow" :
                inCell.textLabel!.textColor = UIColor.yellow
                
            case "Orange" :
                inCell.textLabel!.textColor = UIColor.orange
                
            case "Purple" :
                inCell.textLabel!.textColor = UIColor.purple
                
            case "Header":
                inCell.textLabel!.font = UIFont.boldSystemFont(ofSize: 24.0)
                inCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
            default:
                inCell.textLabel!.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
                inCell.textLabel!.textColor = UIColor.black
            }
        }
        else
        {
            inCell.textLabel!.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            inCell.textLabel!.textColor = UIColor.black
        }
        
        return inCell
    }

#elseif os(OSX)
    func setCellFormatting (inCell: NSTableCellView, inDisplayFormat: String) -> NSTableCellView
    {
 //       inCell.textField!.numberOfLines = 0;
        inCell.textField!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        
        if inDisplayFormat != ""
        {
            switch inDisplayFormat
            {
            case "Gray" :
                inCell.textField!.textColor = NSColor.grayColor()
                
            case "Red" :
                inCell.textField!.textColor = NSColor.redColor()
                
            case "Yellow" :
                inCell.textField!.textColor = NSColor.yellowColor()
                
            case "Orange" :
                inCell.textField!.textColor = NSColor.orangeColor()
                
            case "Purple" :
                inCell.textField!.textColor = NSColor.purpleColor()
                
            case "Header":
                inCell.textField!.font = NSFont.boldSystemFontOfSize(24.0)
  //              inCell.accessoryType = setIndicatorImage(NSDisclosureImage)
                
            default:
//                inCell.textField!.font = NSFont.preferredFontForTextStyle(NSFontTextStyleBody)
                inCell.textField!.textColor = NSColor.blackColor()
            }
        }
        else
        {
//            inCell.textField!.font = NSFont.preferredFontForTextStyle(NSFontTextStyleBody)
            inCell.textField!.textColor = NSColor.blackColor()
        }
        
        return inCell
    }
    
#else
//NSLog("Unexpected OS")
#endif

func fixStringForSearch(_ inString: String) -> String
{
    let myTextReplacement = ";!@"  // using this as unlikely to occur naturally together
    
    let tempStr1 = inString.replacingOccurrences(of: "https:", with:"https\(myTextReplacement)")
    let tempStr2 = tempStr1.replacingOccurrences(of: "http:", with:"http\(myTextReplacement)")
    let tempStr3 = tempStr2.replacingOccurrences(of: "onenote:", with:"onenote\(myTextReplacement)")
    let tempStr4 = tempStr3.replacingOccurrences(of: "0:", with:"0\(myTextReplacement)")
    let tempStr5 = tempStr4.replacingOccurrences(of: "1:", with:"1\(myTextReplacement)")
    let tempStr6 = tempStr5.replacingOccurrences(of: "2:", with:"2\(myTextReplacement)")
    let tempStr7 = tempStr6.replacingOccurrences(of: "3:", with:"3\(myTextReplacement)")
    let tempStr8 = tempStr7.replacingOccurrences(of: "4:", with:"4\(myTextReplacement)")
    let tempStr9 = tempStr8.replacingOccurrences(of: "5:", with:"5\(myTextReplacement)")
    let tempStr10 = tempStr9.replacingOccurrences(of: "6:", with:"6\(myTextReplacement)")
    let tempStr11 = tempStr10.replacingOccurrences(of: "7:", with:"7\(myTextReplacement)")
    let tempStr12 = tempStr11.replacingOccurrences(of: "8:", with:"8\(myTextReplacement)")
    let tempStr13 = tempStr12.replacingOccurrences(of: "9:", with:"9\(myTextReplacement)")
    let tempStr14 = tempStr13.replacingOccurrences(of: "(id,name,self)", with:"")
    let tempStr15 = tempStr14.replacingOccurrences(of: "/$entity,parentNotebook", with:"")
    let tempStr16 = tempStr15.replacingOccurrences(of: "\"", with:"")
    let tempStr17 = tempStr16.replacingOccurrences(of: "{", with:"")
    let tempStr18 = tempStr17.replacingOccurrences(of: "}", with:"")
    let tempStr19 = tempStr18.replacingOccurrences(of: "href:", with:"")
    let tempStr20 = tempStr19.replacingOccurrences(of: "links:", with:"")
    
    return tempStr20
}

func returnSearchStringToNormal(_ inString: String) -> String
{
    let myTextReplacement = ";!@"  // using this as unlikely to occur naturally together
    
    let tempStr1 = inString.replacingOccurrences(of: "https\(myTextReplacement)", with:"https:")
    let tempStr2 = tempStr1.replacingOccurrences(of: "http\(myTextReplacement)", with:"http:")
    let tempStr3 = tempStr2.replacingOccurrences(of: "onenote\(myTextReplacement)", with:"onenote:")
    let tempStr4 = tempStr3.replacingOccurrences(of: "0\(myTextReplacement)", with:"0:")
    let tempStr5 = tempStr4.replacingOccurrences(of: "1\(myTextReplacement)", with:"1:")
    let tempStr6 = tempStr5.replacingOccurrences(of: "2\(myTextReplacement)", with:"2:")
    let tempStr7 = tempStr6.replacingOccurrences(of: "3\(myTextReplacement)", with:"3:")
    let tempStr8 = tempStr7.replacingOccurrences(of: "4\(myTextReplacement)", with:"4:")
    let tempStr9 = tempStr8.replacingOccurrences(of: "5\(myTextReplacement)", with:"5:")
    let tempStr10 = tempStr9.replacingOccurrences(of: "6\(myTextReplacement)", with:"6:")
    let tempStr11 = tempStr10.replacingOccurrences(of: "7\(myTextReplacement)", with:"7:")
    let tempStr12 = tempStr11.replacingOccurrences(of: "8\(myTextReplacement)", with:"8:")
    let tempStr13 = tempStr12.replacingOccurrences(of: "9\(myTextReplacement)", with:"9:")
    
    return tempStr13
}

func characterAtIndex(_ inString: String, index: Int) -> Character {
    var cur = 0
    var retVal: Character!
    for char in inString.characters {
        if cur == index {
            retVal = char
        }
        cur += 1
    }
    return retVal
}

#if os(iOS)
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

#elseif os(OSX)
    class MyDisplayCollectionViewCell: NSCollectionViewItem
    {
        @IBOutlet var Label: NSTextField! = NSTextField()
        
        required init?(coder aDecoder: NSCoder)
        {
            super.init(coder: aDecoder)
            Label.stringValue = ""
        }
        
 //       init(frame: CGRect)
 //       {
            //super.init(frame: frame)
            //super.init()
 //           Label.stringValue = ""
 //       }
    }
    
#else
    //NSLog("Unexpected OS")
#endif

class menuObject: NSObject
{
    fileprivate var myDisplayString: String = ""
    fileprivate var myDisplayType: String = ""
    fileprivate var myDisplayObject: NSObject!
    fileprivate var myDisclosure: Bool = false
    fileprivate var myDisclosureExpanded: Bool = false
    fileprivate var myType: String = "text"
    fileprivate var mySection: String = ""
    fileprivate var myChildSection: String = ""
    
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

    var disclosureExpanded: Bool
    {
        get
        {
            return myDisclosureExpanded
        }
        set
        {
            myDisclosureExpanded = newValue
        }
    }
    
    var type: String
    {
        get
        {
            return myType
        }
        set
        {
            myType = newValue
        }
    }
    
    var section: String
    {
        get
        {
            return mySection
        }
        set
        {
            mySection = newValue
        }
    }
    
    var childSection: String
    {
        get
        {
            return myChildSection
        }
        set
        {
            myChildSection = newValue
        }
    }
}

class menuObjectMac: NSObject
{
    fileprivate var myString: String = ""
    fileprivate var myArray: [NSObject] = Array()
    fileprivate var myObject: NSObject!
    
    var name: String
    {
        get
        {
            return myString
        }
        set
        {
            myString = newValue
        }
    }
    
    var array: [NSObject]
    {
        get
        {
            return myArray
        }
        set
        {
            myArray = newValue
        }
    }

    var object: NSObject
    {
        get
        {
            return myObject
        }
        set
        {
            myObject = newValue
        }
    }
}

struct menuEntry
{
    var menuType: String = ""
    var menuEntries: [menuObject]!
}

#if os(iOS)
    class SharingActivityProvider: UIActivityItemProvider
    {
        var HTMLString : String!
        var plainString : String!
        var messageSubject: String!
    
        override func activityViewController(_ activityViewController: UIActivityViewController,
                                             itemForActivityType activityType: UIActivityType) -> Any?
        {
            switch activityType
            {
            case UIActivityType.mail:
                return HTMLString as AnyObject?
            
            case UIActivityType.print:
                return HTMLString as AnyObject?
            
            case UIActivityType.copyToPasteboard:
                return HTMLString as AnyObject?
            
            default:
                return plainString as AnyObject?
            }
        }
    
//        override func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> AnyObject
//        {
//            return "" as AnyObject;
//        }
//    
        override func activityViewController(_ activityViewController: UIActivityViewController,
                                             subjectForActivityType activityType: UIActivityType?) -> String
        {
            return messageSubject
        }
    }
    #endif
/*
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
*/

#if os(iOS)
    class textLongPressGestureRecognizer:UILongPressGestureRecognizer
    {
        fileprivate var myTag: Int = 0
        fileprivate var myTargetObject: AnyObject!
        fileprivate var myView: UIView!
        fileprivate var myHeadBody: String = ""
        fileprivate var myType: String = ""
        fileprivate var myFrame: CGRect!
    
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
            
                if newValue is team
                {
                    myType = "team"
                }
                else if newValue is workingGTDItem
                {
                    myType = "workingGTDItem"
                }
                else if newValue is project
                {
                    myType = "project"
                }
                else if newValue is task
                {
                    myType = "task"
                }
                else if newValue is context
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
    
        var displayX: CGFloat
        {
            get
            {
                return myFrame.origin.x
            }
        }
    
        var displayY: CGFloat
        {
            get
            {
                return myFrame.origin.y
            }
        }
    
        var frame: CGRect
        {
            get
            {
                return myFrame
            }
            set
            {
                myFrame = newValue
            }
        }
    }
#endif

class cellDetails: NSObject
{
    fileprivate var myTag: Int = 0
    fileprivate var myTargetObject: AnyObject!
    #if os(iOS)
        fileprivate var myView: UIView!
    #elseif os(OSX)
        private var myView: NSView!
    #else
        //NSLog("Unexpected OS")
    #endif

    fileprivate var myHeadBody: String = ""
    fileprivate var myType: String = ""
    fileprivate var myFrame: CGRect!
    
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
            
            if newValue is team
            {
                myType = "team"
            }
            else if newValue is workingGTDItem
            {
                myType = "workingGTDItem"
            }
            else if newValue is project
            {
                myType = "project"
            }
            else if newValue is task
            {
                myType = "task"
            }
            else if newValue is context
            {
                myType = "context"
            }
        }
    }

    #if os(iOS)
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
    
    #elseif os(OSX)
        var displayView: NSView
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
    
    #else
        //NSLog("Unexpected OS")
    #endif

    
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
    
    var displayX: CGFloat
        {
        get
        {
            return myFrame.origin.x
        }
    }
    
    var displayY: CGFloat
        {
        get
        {
            return myFrame.origin.y
        }
    }
    
    var frame: CGRect
        {
        get
        {
            return myFrame
        }
        set
        {
            myFrame = newValue
        }
    }
}

func getDefaultDate() -> Date
{
    let dateStringFormatter = DateFormatter()
    dateStringFormatter.dateFormat = "yyyy-MM-dd"
    return dateStringFormatter.date(from: "9999-12-31")!
}

let myRepeatPeriods = ["",
    "Day",
    "Week",
    "Month",
    "Quarter",
    "Year"]

let myRepeatBases = ["",
    "Completion Date",
    "Start Date",
    "1st of month",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"]

let myTaskStatus = ["", "Open", "Pause", "Complete"]
let myTimeInterval = ["",
    "Minutes",
    "Hours",
    "Days",
    "Weeks",
    "Months",
    "Years"]

let myTaskPriority = ["",
    "High",
    "Medium",
    "Low"]

let myTaskUrgency = ["",
    "High",
    "Medium",
    "Low"]

let myTaskEnergy = ["",
    "High",
    "Medium",
    "Low"]

let myAttendenceStatus = [ "Attended",
                            "Apology",
                            "Delegated"]

func calculateNewDate(_ inOriginalDate: Date, inDateBase: String, inInterval: Int, inPeriod: String) -> Date
{
    var addCalendarUnit: Calendar.Component!
    var tempInterval: Int = inInterval
    var returnDate: Date = Date()
    
    var calendar = Calendar.current
    
    switch inPeriod
    {
        case "Day":
            addCalendarUnit = .day
        
        case "Week":
            addCalendarUnit = .day
            tempInterval = inInterval * 7   // fudge a there is no easy week setting
        
        case "Month":
            addCalendarUnit = .month
        
        case "Quarter":
            addCalendarUnit = .month
            tempInterval = inInterval * 3   // fudge a there is no easy quarter setting
        
        case "Year":
            addCalendarUnit = .year
        
    default:
        NSLog("calculateNewDate inPeriod hit default")
        addCalendarUnit = .day
    }
    
    calendar.timeZone = TimeZone.current
    
    switch inDateBase
    {
        case "Completion Date":
            returnDate = calendar.date(
                byAdding: addCalendarUnit,
                value: tempInterval,
                to: inOriginalDate)!
        
        case "Start Date":
            returnDate = calendar.date(
                byAdding: addCalendarUnit,
                value: tempInterval,
                to: inOriginalDate)!

        case "1st of month":
            // date math to get appropriate month
            
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: tempInterval,
                to: inOriginalDate)!
            
            var currentDateComponents = calendar.dateComponents([.year, .month], from: tempDate)
            currentDateComponents.day = 1

            currentDateComponents.timeZone = TimeZone(identifier: "UTC")

            returnDate = calendar.date(from: currentDateComponents)!
        
        case "Monday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: tempInterval,
                to: inOriginalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 2)
        
        case "Tuesday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: tempInterval,
                to: inOriginalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 3)
        
        case "Wednesday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: tempInterval,
                to: inOriginalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 4)
        
        case "Thursday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: tempInterval,
                to: inOriginalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 5)
        
        case "Friday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: tempInterval,
                to: inOriginalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 6)
        
        case "Saturday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: tempInterval,
                to: inOriginalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 7)

        case "Sunday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: tempInterval,
                to: inOriginalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 1)

        default:
            NSLog("calculateNewDate Bases hit default")
    }
    
    return returnDate
}

func calculateDateForWeekDay(_ inStartDate: Date, dayToFind: Int) -> Date
{
    var returnDate: Date!
    var daysToAdd: Int = 0
    
    let calendar = Calendar.current
    
    var currentDateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: inStartDate)
    currentDateComponents.timeZone = TimeZone(identifier: "UTC")
    
    // Need to work out the days to add
    
    if dayToFind == currentDateComponents.weekday
    {  // The date has hit the correct day of the week
        returnDate = inStartDate
        daysToAdd = 0
    }
    else if dayToFind > currentDateComponents.weekday!
    {
        daysToAdd = dayToFind - currentDateComponents.weekday!
    }
    else
    {
        daysToAdd = 7 - currentDateComponents.weekday! + dayToFind
    }
    
    if daysToAdd > 0
    {
        returnDate = calendar.date(
            byAdding: .day,
            value: daysToAdd,
            to: inStartDate)!
        
  //      returnDate = calendar.dateFromComponents(currentDateComponents)!
    }
    
    return returnDate
}

extension String
{
    var html2String:String
    {
        do
        {
            return try NSAttributedString(data: data(using: String.Encoding.utf8)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:String.Encoding.utf8], documentAttributes: nil).string
        }
        catch let error as NSError
        {
            NSLog("Warning: failed to create plain text \(error)")
            return ""
        }
        catch
        {
            NSLog("html2String unknown error")
            return ""
        }
    }
}

func connectCalendar()
{    
    globalEventStore = EKEventStore()
    checkCalendarConnected(globalEventStore)
}

func checkCalendarConnected(_ myEventStore: EKEventStore)
{
    switch EKEventStore.authorizationStatus(for: EKEntityType.event)
    {
        case .authorized:
            print("Event Access granted")
        
        case .denied:
            print("Event Access denied")
        
        case .notDetermined:
            myEventStore.requestAccess(to: EKEntityType.event, completion:
                {(granted: Bool, error: Error?) -> Void in
                    if granted
                    {
                        print("Event Access granted")
                    }
                    else
                    {
                        print("Event Access denied")
                    }
            })
        
        default:
            print("Event Case Default")
    }
    
    switch EKEventStore.authorizationStatus(for: EKEntityType.reminder)
    {
        case .authorized:
            print("Reminder Access granted")
        
        case .denied:
            print("Reminder Access denied")
        
        case .notDetermined:
            myEventStore.requestAccess(to: EKEntityType.reminder, completion:
                {(granted: Bool, error: Error?) -> Void in
                    if granted
                    {
                        print("Reminder Access granted")
                    }
                    else
                    {
                        print("Reminder Access denied")
                    }
            })
        
        default:
            print("Reminder Case Default")
    }
}
