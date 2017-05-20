//
//  EvesCRMSharedFiles.swift
//  EvesCRM
//
//  Created by Garry Eves on 19/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import EventKit
import UIKit

@objc protocol myCommunicationDelegate
{
    @objc optional func orgEdit(_ organisation: team?)
    @objc optional func userCreated(_ userRecord: userItem?)
    @objc optional func loadMainScreen()
    @objc optional func passwordCorrect()
    @objc optional func refreshScreen()
    @objc optional func callLoadMainScreen()
}

var currentAddressBook: addressBookClass!

let defaultsName = "group.com.garryeves.EvesCRM"
let userDefaultName = "userID"
let userDefaultPassword = "password"
let userDefaultPasswordHint = "passwordHint"

let loginStoryboard = UIStoryboard(name: "LoginRoles", bundle: nil)
let pickerStoryboard = UIStoryboard(name: "dropDownMenus", bundle: nil)
let personStoryboard = UIStoryboard(name: "person", bundle: nil)
let clientsStoryboard = UIStoryboard(name: "Clients", bundle: nil)
let projectsStoryboard = UIStoryboard(name: "Projects", bundle: nil)

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

var currentUser: userItem!

var myCurrentViewController: AnyObject!

#if os(iOS)
    let myRowColour = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
#elseif os(OSX)
//    let myRowColour = NSColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25) as! CGColor
    let myRowColour = CGColorCreateGenericRGB(0.75, 1.0, 0.92, 0.25)
#endif

func getDeviceType() -> UIUserInterfaceIdiom
{
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    return deviceIdiom
}

func writeDefaultString(_ keyName: String, value: String)
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    defaults.set(value, forKey: keyName)
    
    defaults.synchronize()
}

func writeDefaultInt(_ keyName: String, value: Int)
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    defaults.set(value, forKey: keyName)
    
    defaults.synchronize()
}

func readDefaultString(_ keyName: String) -> String
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    if defaults.string(forKey: keyName) != nil
    {
        return (defaults.string(forKey: keyName))!
    }
    else
    {
        return ""
    }
}

func readDefaultInt(_ keyName: String) -> Int
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    if defaults.string(forKey: keyName) != nil
    {
        return defaults.integer(forKey: keyName)
    }
    else
    {
        return -1
    }
}

func removeDefaultString(_ keyName: String)
{
    let defaults = UserDefaults(suiteName: defaultsName)!
    
    defaults.removeObject(forKey: keyName)
    
    defaults.synchronize()
}

struct TableData
{
    var displayText: String
    
    fileprivate var myDisplayFormat: String
    fileprivate var myObjectType: String
    fileprivate var myReminderPriority: Int
    fileprivate var myNotes: String
    fileprivate var myCalendarItemIdentifier: String
    fileprivate var myTask: task?
    fileprivate var myEvent: calendarItem?
    fileprivate var myObject: AnyObject?
    fileprivate var myCalendarEvent: EKEvent?
    
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
            return myCalendarItemIdentifier
        }
        set {
            myCalendarItemIdentifier = newValue
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
    
    var task: task?
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
    
    var calendarItem: calendarItem?
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
    
    var event: EKEvent?
    {
        get
        {
            return myCalendarEvent
        }
        set
        {
            myCalendarEvent = newValue
        }
    }
    
    var object: AnyObject?
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
        self.myCalendarItemIdentifier = ""
        self.myNotes = ""
    }
}

// Here I am definging my own struct to use in the Display array.  This is to allow passing of multiple different types of information

// Overloading writeRowToArray a number of times to allow for collection of structs where I am going to allow user to interact and change data inside the app,rather than them having to go to source app.  The number of these will be kept to a minimum.

func writeRowToArray(_ displayText: String, table: inout [TableData], displayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: displayText)

    if displayFormat != ""
    {
        myDisplay.displaySpecialFormat = displayFormat
    }
        
    table.append(myDisplay)
}

func writeRowToArray(_ displayText: String, table: inout [TableData], targetTask: task, displayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: displayText)
    
    if displayFormat != ""
    {
        myDisplay.displaySpecialFormat = displayFormat
    }
    
    myDisplay.task = targetTask
    
    table.append(myDisplay)
}

func writeRowToArray(_ displayText: String, table: inout [TableData], targetEvent: calendarItem, displayFormat: String="")
{
    // Create the struct for this record
    
    var myDisplay: TableData = TableData(displayText: displayText)
    
    if displayFormat != ""
    {
        myDisplay.displaySpecialFormat = displayFormat
    }
    
    myDisplay.calendarItem = targetEvent
    
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
    
    myDisplay.object = targetObject
    
    table.append(myDisplay)
}

func getFirstPartofString(_ original: String) -> String
{
    let start = original.startIndex
    let end = original.characters.index(of: ":")
    
    var selectedType: String = ""
    
    if end != nil
    {
        let myEnd = original.index(before: (end)!)
        selectedType = original[start...myEnd]
    }
    else
    { // no space found
        selectedType = original
    }
    return selectedType
}

func stringByChangingChars(_ string: String, oldChar: String, newChar: String) -> String
{
    let regex = try! NSRegularExpression(pattern:oldChar, options:.caseInsensitive)
    let myString = regex.stringByReplacingMatches(in: string, options:  NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, string.characters.count), withTemplate:newChar)
    
    return myString
}

//func displayTeamMembers(_ sourceProject: project, lookupArray: inout [String])->[TableData]
//{
//    var tableContents:[TableData] = [TableData]()
//    
//    lookupArray.removeAll(keepingCapacity: false)
//    
//    let myTeamMembers = sourceProject.teamMembers
//    var titleText: String = ""
//    
//    for myTeamMember in myTeamMembers
//    {
//        titleText = myTeamMember.teamMember
//        titleText += " : "
//        titleText += myDatabaseConnection.getRoleDescription(myTeamMember.roleID, teamID: sourceProject.teamID)
//        
//        lookupArray.append(myTeamMember.teamMember)
//        
//        let personObject = findPersonRecord(myTeamMember.teamMember)
//        
//        writeRowToArray(titleText, table: &tableContents, targetObject: personObject!)
//    }
//    
//    return tableContents
//}
//
//func displayProjectsForPerson(_ person: String, lookupArray: inout [String]) -> [TableData]
//{
//    var tableContents:[TableData] = [TableData]()
//    var titleText: String = ""
//    
//    lookupArray.removeAll(keepingCapacity: false)
//    
//    let myProjects = myDatabaseConnection.getProjectsForPerson(person)
//    
//    if myProjects.count == 0
//    {
//        writeRowToArray("Not a member of any Project", table: &tableContents)
//    }
//    else
//    {
//        for myProject in myProjects
//        {
//            let myDetails = myDatabaseConnection.getProjectDetails(Int(myProject.projectID))
//        
//            if myDetails[0].projectStatus != "Archived"
//            {
//                titleText = myDetails[0].projectName!
//                titleText += " : "
//                titleText += myDatabaseConnection.getRoleDescription(Int(myProject.roleID), teamID: Int(myDetails[0].teamID))
//                
//                lookupArray.append("\(myProject.projectID)")
//                
//                let projectObject = project(projectID: Int(myDetails[0].projectID))
//
//                writeRowToArray(titleText, table: &tableContents, targetObject: projectObject)
//            }
//        }
//    }
//    return tableContents
//}

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

#if os(iOS)
    func setCellFormatting (_ cell: UITableViewCell, displayFormat: String) -> UITableViewCell
    {
        cell.textLabel!.numberOfLines = 0;
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        
        if displayFormat != ""
        {
            switch displayFormat
            {
            case "Gray" :
                cell.textLabel!.textColor = .gray
                
            case "Red" :
                cell.textLabel!.textColor = .red
                
            case "Yellow" :
                cell.textLabel!.textColor = .yellow
                
            case "Orange" :
                cell.textLabel!.textColor = .orange
                
            case "Purple" :
                cell.textLabel!.textColor = .purple
                
            case "Header":
                cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 24.0)
                cell.accessoryType = .disclosureIndicator
                
            default:
                cell.textLabel!.font = UIFont.preferredFont(forTextStyle: .body)
                cell.textLabel!.textColor = .black
            }
        }
        else
        {
            cell.textLabel!.font = UIFont.preferredFont(forTextStyle: .body)
            cell.textLabel!.textColor = .black
        }
        
        return cell
    }

#elseif os(OSX)
    func setCellFormatting (cell: NSTableCellView, displayFormat: String) -> NSTableCellView
    {
 //       inCell.textField!.numberOfLines = 0;
        cell.textField!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        
        if displayFormat != ""
        {
            switch displayFormat
            {
            case "Gray" :
                cell.textField!.textColor = NSColor.grayColor()
                
            case "Red" :
                cell.textField!.textColor = NSColor.redColor()
                
            case "Yellow" :
                cell.textField!.textColor = NSColor.yellowColor()
                
            case "Orange" :
                cell.textField!.textColor = NSColor.orangeColor()
                
            case "Purple" :
                cell.textField!.textColor = NSColor.purpleColor()
                
            case "Header":
                cell.textField!.font = NSFont.boldSystemFontOfSize(24.0)
  //              cell.accessoryType = setIndicatorImage(NSDisclosureImage)
                
            default:
//                cell.textField!.font = NSFont.preferredFontForTextStyle(NSFontTextStyleBody)
                cell.textField!.textColor = NSColor.blackColor()
            }
        }
        else
        {
//            cell.textField!.font = NSFont.preferredFontForTextStyle(NSFontTextStyleBody)
            cell.textField!.textColor = NSColor.blackColor()
        }
        
        return cell
    }
    
#else
//NSLog("Unexpected OS")
#endif

func fixStringForSearch(_ original: String) -> String
{
    let myTextReplacement = ";!@"  // using this as unlikely to occur naturally together
    
    let tempStr1 = original.replacingOccurrences(of: "https:", with:"https\(myTextReplacement)")
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

func returnSearchStringToNormal(_ original: String) -> String
{
    let myTextReplacement = ";!@"  // using this as unlikely to occur naturally together
    
    let tempStr1 = original.replacingOccurrences(of: "https\(myTextReplacement)", with:"https:")
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

func characterAtIndex(_ original: String, index: Int) -> Character {
    var cur = 0
    var retVal: Character!
    for char in original.characters {
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

func calculateNewDate(_ originalDate: Date, dateBase: String, interval: Int16, period: String) -> Date
{
    var addCalendarUnit: Calendar.Component!
    var tempInterval = interval
    var returnDate = Date()
    
    var calendar = Calendar.current
    
    switch period
    {
        case "Day":
            addCalendarUnit = .day
        
        case "Week":
            addCalendarUnit = .day
            tempInterval = interval * 7   // fudge a there is no easy week setting
        
        case "Month":
            addCalendarUnit = .month
        
        case "Quarter":
            addCalendarUnit = .month
            tempInterval = interval * 3   // fudge a there is no easy quarter setting
        
        case "Year":
            addCalendarUnit = .year
        
    default:
        NSLog("calculateNewDate inPeriod hit default")
        addCalendarUnit = .day
    }
    
    calendar.timeZone = TimeZone.current
    
    switch dateBase
    {
        case "Completion Date":
            returnDate = calendar.date(
                byAdding: addCalendarUnit,
                value: Int(tempInterval),
                to: originalDate)!
        
        case "Start Date":
            returnDate = calendar.date(
                byAdding: addCalendarUnit,
                value: Int(tempInterval),
                to: originalDate)!

        case "1st of month":
            // date math to get appropriate month
            
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: Int(tempInterval),
                to: originalDate)!
            
            var currentDateComponents = calendar.dateComponents([.year, .month], from: tempDate)
            currentDateComponents.day = 1

            currentDateComponents.timeZone = TimeZone(identifier: "UTC")

            returnDate = calendar.date(from: currentDateComponents)!
        
        case "Monday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: Int(tempInterval),
                to: originalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 2)
        
        case "Tuesday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: Int(tempInterval),
                to: originalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 3)
        
        case "Wednesday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: Int(tempInterval),
                to: originalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 4)
        
        case "Thursday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: Int(tempInterval),
                to: originalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 5)
        
        case "Friday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: Int(tempInterval),
                to: originalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 6)
        
        case "Saturday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: Int(tempInterval),
                to: originalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 7)

        case "Sunday":
            let tempDate = calendar.date(
                byAdding: addCalendarUnit,
                value: Int(tempInterval),
                to: originalDate)!
            
            returnDate = calculateDateForWeekDay(tempDate, dayToFind: 1)

        default:
            NSLog("calculateNewDate Bases hit default")
    }
    
    return returnDate
}

func calculateDateForWeekDay(_ startDate: Date, dayToFind: Int) -> Date
{
    var returnDate: Date!
    var daysToAdd: Int = 0
    
    let calendar = Calendar.current
    
    var currentDateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: startDate)
    currentDateComponents.timeZone = TimeZone(identifier: "UTC")
    
    // Need to work out the days to add
    
    if dayToFind == currentDateComponents.weekday
    {  // The date has hit the correct day of the week
        returnDate = startDate
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
            to: startDate)!
        
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

func connectEventStore()
{    
    globalEventStore = EKEventStore()
    
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
}

func checkRemindersConnected(_ myEventStore: EKEventStore)
{
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

func removeExistingViews(_ sourceView: UIView)
{
    for view in sourceView.subviews
    {
        view.removeFromSuperview()
    }
}

extension String  {
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
}

func formatCurrency(value: Double) -> String
{
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2;
    formatter.locale = Locale(identifier: Locale.current.identifier)
    let result = formatter.string(from: value as NSNumber);
    return result!;
}
