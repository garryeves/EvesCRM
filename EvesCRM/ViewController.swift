//
//  ViewController.swift
//  EvesCRM
//
//  Created by Garry Eves /Users/garryeves/Documents/xcode/EvesCRM/EvesCRM/reminderViewController.swifton 15/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import EventKit
import EventKitUI
import CoreData


//import "ENSDK/Headers/ENSDK.h"

// PeoplePicker code

private let CONTACT_CELL_IDENTIFER = "contactNameCell"
private let dataTable1_CELL_IDENTIFER = "dataTable1Cell"

var dropboxCoreService: DropboxCoreService = DropboxCoreService()

class ViewController: UIViewController, MyReminderDelegate, ABPeoplePickerNavigationControllerDelegate, MyMaintainProjectDelegate, MyDropboxCoreDelegate, MySettingsDelegate, EKEventViewDelegate, EKEventEditViewDelegate, EKCalendarChooserDelegate {
    
    @IBOutlet weak var TableTypeSelection1: UIPickerView!
    
    // setup grid header buttons
    @IBOutlet weak var TableTypeButton1: UIButton!
    @IBOutlet weak var TableTypeButton2: UIButton!
    @IBOutlet weak var TableTypeButton3: UIButton!
    @IBOutlet weak var TableTypeButton4: UIButton!
    

    @IBOutlet weak var buttonAdd3: UIButton!
    
    @IBOutlet weak var buttonAdd4: UIButton!
    @IBOutlet weak var buttonAdd2: UIButton!
    @IBOutlet weak var buttonAdd1: UIButton!
    // Setup data tables for initial values
    @IBOutlet weak var dataTable1: UITableView!
    @IBOutlet weak var dataTable2: UITableView!
    @IBOutlet weak var dataTable3: UITableView!
    @IBOutlet weak var dataTable4: UITableView!
    @IBOutlet weak var buttonMaintainProjects: UIButton!
    
    @IBOutlet weak var buttonSelectProject: UIButton!
    @IBOutlet weak var StartLabel: UILabel!
    
    @IBOutlet weak var setSelectionButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var peoplePickerButton: UIButton!
    
    @IBOutlet weak var myWebView: UIWebView!
    
    @IBOutlet weak var btnCloseWindow: UIButton!
    var TableOptions: [String]!
    
    
    // Store the tag number of the button pressed so that we can make sure we update the correct button text and table
    var callingTable = 0
    
    // Default for the table type selected
    var itemSelected = "Details"
    
    // define arrasy to store the table displays
    
    var table1Contents:[TableData] = [TableData]()
    var table2Contents:[TableData] = [TableData]()
    var table3Contents:[TableData] = [TableData]()
    var table4Contents:[TableData] = [TableData]()
    
    // store the name of the person selected in the People table
    var personSelected: ABRecord!
    
    var adbk : ABAddressBook!
    
    var eventStore: EKEventStore!
    
    // Do not like this workaround, but is best way I can find to store for rebuilding tables
    
    var reBuildTableName: String = ""
    
    var evernoteSession: ENSession!
    var myEvernote: EvernoteDetails!
    var evernotePass1: Bool = false
    var EvernoteTargetTable: String = "'"
    var myEvernoteShard: String = ""
    var myEvernoteUserID: Int = 0
    var EvernoteUserDone: Bool = false
    var EvernoteAuthenticationDone: Bool = false
    var myEvernoteGUID: String = ""
    var myDisplayType: String = ""
    var myProjectID: NSNumber!
    var myProjectName: String = ""
    var omniTableToRefresh: String = ""
    var oneNoteTableToRefresh: String = ""
    var gmailTableToRefresh: String = ""
    var hangoutsTableToRefresh: String = ""

    var oneNoteLinkArray: [String] = Array()
    var omniLinkArray: [String] = Array()
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var document: MyDocument?
    var documentURL: NSURL?
    var ubiquityURL: NSURL?
    var metaDataQuery: NSMetadataQuery?
    
    var dropboxConnected: Bool = false
    
    var dbRestClient: DBRestClient?
    
    var eventDetails: [EKEvent] = Array()
    var reminderDetails: [EKReminder] = Array()
    var projectMemberArray: [String] = Array()
    
    
    // OneNote
    var myOneNoteNotebooks: oneNoteNotebooks!

    // Gmail
    var myGmailMessages: gmailMessages!
    var myHangoutsMessages: gmailMessages!
    var myGmailData: gmailData!
    
    // Peoplepicker settings
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialPopulationOfTables()
        
        eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
        case .Authorized:
            println("Calendar Access granted")
        case .Denied:
            println("Calendar Access denied")
        case .NotDetermined:
            // 3
            eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
                {[weak self] (granted: Bool, error: NSError!) -> Void in
                    if granted {
                        println("Calendar Access granted")
                    } else {
                        println("Calendar Access denied")
                    }
                })
        default:
            println("Calendar Case Default")
        }

        // Now we will try and open Evernote
        
        
        evernoteSession = ENSession.sharedSession()
//        connectToEvernote()
        
       // Initial population of contact list
        self.dataTable1.registerClass(UITableViewCell.self, forCellReuseIdentifier: CONTACT_CELL_IDENTIFER)
        self.dataTable2.registerClass(UITableViewCell.self, forCellReuseIdentifier: CONTACT_CELL_IDENTIFER)
        self.dataTable3.registerClass(UITableViewCell.self, forCellReuseIdentifier: CONTACT_CELL_IDENTIFER)
        self.dataTable4.registerClass(UITableViewCell.self, forCellReuseIdentifier: CONTACT_CELL_IDENTIFER)
        
        TableTypeSelection1.hidden = true
        setSelectionButton.hidden = true
        TableTypeButton1.hidden = true
        TableTypeButton2.hidden = true
        TableTypeButton3.hidden = true
        TableTypeButton4.hidden = true
        dataTable1.hidden = true
        dataTable2.hidden = true
        dataTable3.hidden = true
        dataTable4.hidden = true
        StartLabel.hidden = false
        
        buttonAdd1.hidden = true
        buttonAdd2.hidden = true
        buttonAdd3.hidden = true
        buttonAdd4.hidden = true
        peoplePickerButton.hidden = false
        
        myWebView.hidden = true
        btnCloseWindow.hidden = true
        
        dataTable1.tableFooterView = UIView(frame:CGRectZero)
        dataTable2.tableFooterView = UIView(frame:CGRectZero)
        dataTable3.tableFooterView = UIView(frame:CGRectZero)
        dataTable4.tableFooterView = UIView(frame:CGRectZero)

        populateContactList()
        
        // Work out if a project has been added to the data store, so we can then select it
        let myProjects = getProjects()
        
        if myProjects.count > 0
        {
            buttonSelectProject.hidden = false
        }
        else
        {
            buttonSelectProject.hidden = true
        }
        
        dataTable1.estimatedRowHeight = 12.0
        dataTable1.rowHeight = UITableViewAutomaticDimension
        dataTable2.estimatedRowHeight = 12.0
        dataTable2.rowHeight = UITableViewAutomaticDimension
        dataTable3.estimatedRowHeight = 12.0
        dataTable3.rowHeight = UITableViewAutomaticDimension
        dataTable4.estimatedRowHeight = 12.0
        dataTable4.rowHeight = UITableViewAutomaticDimension
        
        // Default the buttons
        
        TableTypeButton1.setTitle("Calendar", forState: .Normal)
        itemSelected = "Calendar"
        TableTypeButton2.setTitle("Details", forState: .Normal)
        TableTypeButton3.setTitle("Project Membership", forState: .Normal)
        TableTypeButton4.setTitle("Reminders", forState: .Normal)
        
        TableOptions = Array()
        
        myEvernote = EvernoteDetails(inSession: self.evernoteSession)
        
        if evernoteSession.isAuthenticated
        {
            getEvernoteUserDetails()
        }
        
        labelName.text = ""
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "OneNoteNotebookGetSections", name:"NotificationOneNoteNotebooksLoaded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "OneNotePagesReady:", name:"NotificationOneNotePagesReady", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "OneNoteNoNotebookFound", name:"NotificationOneNoteNoNotebookFound", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "EvernoteComplete", name:"NotificationEvernoteComplete", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "myEvernoteUserDidFinish", name:"NotificationEvernoteUserDidFinish", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "myGmailDidFinish", name:"NotificationGmailDidFinish", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "myHangoutsDidFinish", name:"NotificationHangoutsDidFinish", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gmailSignedIn:", name:"NotificationGmailConnected", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponentsInPickerView(TableTypeSelection1: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TableOptions.count
    }
  
    func pickerView(TableTypeSelection1: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return TableOptions[row]
    }

    func pickerView(TableTypeSelection1: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        actionSelection()
    }
    
    func actionSelection(){
        itemSelected = TableOptions[TableTypeSelection1.selectedRowInComponent(0)]
    }
    
    @IBAction func TableTypeButton1TouchUp(sender: UIButton) {
        // Show the Picker and hide the button
   
        let myPanes = displayPanes(inManagedContext: managedObjectContext!)
        
        TableOptions.removeAll(keepCapacity: false)
 
        for myPane in myPanes.listVisiblePanes
        {
            TableOptions.append(myPane.paneName)
        }
        
        TableTypeSelection1.reloadAllComponents()
        
        callingTable = sender.tag
        
        TableTypeSelection1.hidden = false
        setSelectionButton.hidden = false
        TableTypeButton1.hidden = true
        TableTypeButton2.hidden = true
        TableTypeButton3.hidden = true
        TableTypeButton4.hidden = true
        dataTable1.hidden = true
        dataTable2.hidden = true
        dataTable3.hidden = true
        dataTable4.hidden = true
        StartLabel.hidden = true
        peoplePickerButton.hidden = true
        buttonAdd1.hidden = true
        buttonAdd2.hidden = true
        buttonAdd3.hidden = true
        buttonAdd4.hidden = true
        
        let startString = getFirstPartofString(sender.currentTitle!)

        let myIndex = find(TableOptions, getFirstPartofString(sender.currentTitle!))

        TableTypeSelection1.selectRow(myIndex!, inComponent: 0, animated: true)
    }

    @IBAction func setSelectionButtonTouchUp(sender: UIButton) {
        
        if itemSelected == ""
        {
            // do nothing
        }
        else
        {
            var myFullName: String
            if myDisplayType == "Project"
            {
                myFullName = myProjectName
            }
            else
            {
                myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
            }

            switch callingTable
            {
                case 1:
                    TableTypeButton1.setTitle(itemSelected, forState: .Normal)
                    TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myFullName), forState: .Normal)
                    setAddButtonState(1)
                    populateArraysForTables("Table1")
            
                case 2:
                    TableTypeButton2.setTitle(itemSelected, forState: .Normal)
                    TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myFullName), forState: .Normal)
                    setAddButtonState(2)
                    populateArraysForTables("Table2")

                case 3:
                    TableTypeButton3.setTitle(itemSelected, forState: .Normal)
                    TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myFullName), forState: .Normal)
                    setAddButtonState(3)
                    populateArraysForTables("Table3")
            
                case 4:
                    TableTypeButton4.setTitle(itemSelected, forState: .Normal)
                    TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myFullName), forState: .Normal)
                    setAddButtonState(4)
                    populateArraysForTables("Table4")
            
                default: break
            
            }
            
            TableTypeSelection1.hidden = true
            setSelectionButton.hidden = true
            TableTypeButton1.hidden = false
            TableTypeButton2.hidden = false
            TableTypeButton3.hidden = false
            TableTypeButton4.hidden = false
            dataTable1.hidden = false
            dataTable2.hidden = false
            dataTable3.hidden = false
            dataTable4.hidden = false
            StartLabel.hidden = true
            peoplePickerButton.hidden = false
        }
    }

    func createAddressBook() -> Bool {
        if self.adbk != nil {
            return true
        }
        var err : Unmanaged<CFError>? = nil
        let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if adbk == nil {
            println(err)
            self.adbk = nil
            return false
        }
        self.adbk = adbk
        
        return true
    }
    
    func determineStatus() -> Bool {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .Authorized:
            return self.createAddressBook()
        case .NotDetermined:
            var ok = false
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        ok = self.createAddressBook()
                    }
                }
            }
            if ok == true {
                return true
            }
            self.adbk = nil
            return false
        case .Restricted:
            self.adbk = nil
            return false
        case .Denied:
            self.adbk = nil
            return false
        }
    }
    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
 
    func populateContactList()
    {
        createAddressBook()
        determineStatus()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        var retVal: Int = 0
        
        if (tableView == dataTable1)
        {
            retVal = self.table1Contents.count ?? 0
        }
        else if (tableView == dataTable2)
        {
            retVal = self.table2Contents.count ?? 0
        }
        else if (tableView == dataTable3)
        {
            retVal = self.table3Contents.count ?? 0
        }
        else if (tableView == dataTable4)
        {
            retVal = self.table4Contents.count ?? 0
        }
        return retVal
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (tableView == dataTable1)
        {
            let cell = dataTable1.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table1Contents[indexPath.row].displayText
            return setCellFormatting(cell,table1Contents[indexPath.row].displaySpecialFormat)

        }
        else if (tableView == dataTable2)
        {
            let cell = dataTable2.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table2Contents[indexPath.row].displayText
            return setCellFormatting(cell, table2Contents[indexPath.row].displaySpecialFormat)
        }
        else if (tableView == dataTable3)
        {
            let cell = dataTable3.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table3Contents[indexPath.row].displayText
            return setCellFormatting(cell,table3Contents[indexPath.row].displaySpecialFormat)

        }
        else if (tableView == dataTable4)
        {
            let cell = dataTable4.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table4Contents[indexPath.row].displayText
            return setCellFormatting(cell,table4Contents[indexPath.row].displaySpecialFormat)

        }
        else
        {
            // Dummy statements to allow use of else
            let cell = dataTable3.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if tableView == dataTable1
        {
            dataCellClicked(indexPath.row, inTable: "Table1", inRecord: table1Contents[indexPath.row])
        }
        else if tableView == dataTable2
        {
            dataCellClicked(indexPath.row, inTable: "Table2", inRecord: table2Contents[indexPath.row])
        }
        else if tableView == dataTable3
        {
            dataCellClicked(indexPath.row, inTable: "Table3", inRecord: table3Contents[indexPath.row])
        }
        else if tableView == dataTable4
        {
            dataCellClicked(indexPath.row, inTable: "Table4", inRecord: table4Contents[indexPath.row])
        }
        
    }
  
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = swiftColor
        }
        else
        {
            cell.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func populateArraysForTables(inTable : String)
    {
        
        // work out the table we are populating so we can then use this later
        switch inTable
        {
        case "Table1":
            table1Contents = populateArrayDetails(inTable)
            dispatch_async(dispatch_get_main_queue())
            {
                self.dataTable1.reloadData()
            }
            
        case "Table2":
            table2Contents = populateArrayDetails(inTable)
            dispatch_async(dispatch_get_main_queue())
            {
                self.dataTable2.reloadData()
            }
            
        case "Table3":
            table3Contents = populateArrayDetails(inTable)
            dispatch_async(dispatch_get_main_queue())
            {
                self.dataTable3.reloadData()
            }
            
        case "Table4":
            table4Contents = populateArrayDetails(inTable)
            dispatch_async(dispatch_get_main_queue())
            {
                self.dataTable4.reloadData()
            }
            
        default:
            println("populateArraysForTables: hit default for some reason")
            
        }
    }
    
    func populateArrayDetails(inTable: String) -> [TableData]
    {
        var workArray: [TableData] = [TableData]()
        var dataType: String = ""
        
        // First we need to work out the type of data in the table, we get this from the button
        
        switch inTable
        {
            case "Table1":
                dataType = TableTypeButton1.currentTitle!
            
            case "Table2":
                dataType = TableTypeButton2.currentTitle!
            
            case "Table3":
                dataType = TableTypeButton3.currentTitle!
            
            case "Table4":
                dataType = TableTypeButton4.currentTitle!

            default:
                println("populateArrayDetails: inTable hit default for some reason")
            
        }
        
        if myDisplayType == "Project"
        {
            labelName.text = myProjectName
        }
        else
        {
            labelName.text = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
        }
                
        var selectedType: String = getFirstPartofString(dataType)
        
        hangoutsTableToRefresh = ""
        gmailTableToRefresh = ""
        
        // This is where we have the logic to work out which type of data we are goign to populate with
        switch selectedType
        {
            case "Details":
                if myDisplayType == "Project"
                {
                    workArray = parseProjectDetails(myProjectID)
                }
                else
                {
                    workArray = parseContactDetails(personSelected)
                }
            case "Calendar":
                if myDisplayType == "Project"
                {
                   workArray = parseCalendarDetails(myProjectName, eventStore, &eventDetails)
                }
                else
                {
                    workArray = parseCalendarDetails(personSelected, eventStore, &eventDetails)
                }
            case "Reminders":
                if myDisplayType == "Project"
                {
                    workArray = parseReminderDetails(myProjectName, eventStore, &reminderDetails)
                }
                else
                {
                    workArray = parseReminderDetails(personSelected, eventStore, &reminderDetails)
                }
            case "Evernote":
                writeRowToArray("Loading Evernote data.  Pane will refresh when finished", &workArray)
                if myDisplayType == "Project"
                {
                    myEvernote.findEvernoteNotes(myProjectName)
                }
                else
                {
                    let searchString = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                    myEvernote.findEvernoteNotes(searchString)
                }
                EvernoteTargetTable = inTable

            case "Project Membership":
                // Project team membership details
                if myDisplayType == "Project"
                {
                    workArray = displayTeamMembers(myProjectID, &projectMemberArray)
                }
                else
                {
                    let searchString = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                    workArray = displayProjectsForPerson(searchString, &projectMemberArray)
                }

            case "Omnifocus":
                writeRowToArray("Loading Omnifocus data.  Pane will refresh when finished", &workArray)
            
                omniTableToRefresh = inTable
                
                openOmnifocusDropbox()

            case "OneNote":
                writeRowToArray("Loading OneNote data.  Pane will refresh when finished", &workArray)
            
                oneNoteTableToRefresh = inTable
            
                if myOneNoteNotebooks == nil
                {
                    myOneNoteNotebooks = oneNoteNotebooks(inViewController: self)
                }
                else
                {
                    OneNoteNotebookGetSections()
                }
            
            case "GMail":
                writeRowToArray("Loading GMail messages.  Pane will refresh when finished", &workArray)
                
                gmailTableToRefresh = inTable
                
                // Does connection to GmailData exist
                
                if myGmailData == nil
                {
                    myGmailData = gmailData()
                    myGmailData.sourceViewController = self
                    myGmailData.connectToGmail()
                }
                else
                {
                    loadGmail()
                }
            
        case "Hangouts":
            writeRowToArray("Loading Hangout messages.  Pane will refresh when finished", &workArray)
            
            hangoutsTableToRefresh = inTable
            
            if myGmailData == nil
            {
                myGmailData = gmailData()
                myGmailData.sourceViewController = self
                myGmailData.connectToGmail()
            }
            else
            {
                loadHangouts()
            }
        
            case "Mail":
                let a = 1
            
            default:
                println("populateArrayDetails: dataType hit default for some reason : \(selectedType)")
        }
        return workArray
    }
    
    func dataCellClicked(rowID: Int, inTable: String, inRecord: TableData)
    {
        var dataType: String = ""
        // First we need to work out the type of data in the table, we get this from the button

        // Also depending on which table is clicked, we now need to do a check to make sure the row clicked is a valid task row.  If not then no need to try and edit it

        var myRowContents: String = "'"
        
        switch inTable
        {
            case "Table1":
                dataType = TableTypeButton1.currentTitle!
                myRowContents = table1Contents[rowID].displayText

            case "Table2":
                dataType = TableTypeButton2.currentTitle!
                myRowContents = table2Contents[rowID].displayText
            
            case "Table3":
                dataType = TableTypeButton3.currentTitle!
                myRowContents = table3Contents[rowID].displayText
            
            case "Table4":
                dataType = TableTypeButton4.currentTitle!
                myRowContents = table4Contents[rowID].displayText

            default:
                println("dataCellClicked: inTable hit default for some reason")
            
        }
  
        var selectedType: String = getFirstPartofString(dataType)

        switch selectedType
        {
            case "Reminders":
                if myRowContents != "No reminders list found"
                {
                    reBuildTableName = inTable

                    var myFullName: String
                    if myDisplayType == "Project"
                    {
                        myFullName = myProjectName
                    }
                    else
                    {
                        myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                    }
                    openReminderEditView(inRecord.calendarItemIdentifier, inCalendarName: myFullName)
                }
            case "Evernote":
                if myRowContents != "No Notes found"
                {
                    reBuildTableName = inTable
                    
                    var myEvernoteDataArray = myEvernote.getEvernoteDataArray()
                    
                    var myGuid = myEvernoteDataArray[rowID].identifier
                    var myNoteRef = myEvernoteDataArray[rowID].NoteRef

                    openEvernoteEditView(myGuid, inNoteRef: myNoteRef)
                }

            case "Omnifocus":
                let myOmniUrlPath = omniLinkArray[rowID]
               
                var myOmniUrl: NSURL = NSURL(string: myOmniUrlPath)!
                
                if UIApplication.sharedApplication().canOpenURL(myOmniUrl) == true
                {
                    UIApplication.sharedApplication().openURL(myOmniUrl)
                }
            
            case "Calendar":
                let evc = EKEventEditViewController()
                evc.eventStore = self.eventStore
                evc.editViewDelegate = self
                evc.event = eventDetails[rowID]
                self.presentViewController(evc, animated: true, completion: nil)

            case "Project Membership":
                // Project team membership details
                if myDisplayType == "Project"
                {
                    TableTypeSelection1.hidden = true
                    setSelectionButton.hidden = true
                    TableTypeButton1.hidden = false
                    TableTypeButton2.hidden = false
                    TableTypeButton3.hidden = false
                    TableTypeButton4.hidden = false
                    dataTable1.hidden = false
                    dataTable2.hidden = false
                    dataTable3.hidden = false
                    dataTable4.hidden = false
                    StartLabel.hidden = true
                    
                    myDisplayType = "Person"
                    
                    // we need to go and find the record for the person we have selected
                    
                    personSelected = findPersonRecord(projectMemberArray[rowID], adbk)
                    
                    table1Contents = Array()
                    table2Contents = Array()
                    table3Contents = Array()
                    table4Contents = Array()
                    
                    populateArraysForTables("Table1")
                    populateArraysForTables("Table2")
                    populateArraysForTables("Table3")
                    populateArraysForTables("Table4")
                    
                    // Here is where we will set the titles for the buttons
                    
                    let myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                    
                    TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myFullName), forState: .Normal)
                    TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myFullName), forState: .Normal)
                    TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myFullName), forState: .Normal)
                    TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myFullName), forState: .Normal)
                }
                else
                {
                    TableTypeSelection1.hidden = true
                    setSelectionButton.hidden = true
                    TableTypeButton1.hidden = false
                    TableTypeButton2.hidden = false
                    TableTypeButton3.hidden = false
                    TableTypeButton4.hidden = false
                    dataTable1.hidden = false
                    dataTable2.hidden = false
                    dataTable3.hidden = false
                    dataTable4.hidden = false
                    StartLabel.hidden = true
                    
                    myDisplayType = "Project"
                    myProjectID = projectMemberArray[rowID].toInt()
                    
                    let mySelectProjects = getProjectDetails(myProjectID)
                    
                    myProjectName = mySelectProjects[0].projectName
                    
                    table1Contents = Array()
                    table2Contents = Array()
                    table3Contents = Array()
                    table4Contents = Array()
                    
                    populateArraysForTables("Table1")
                    populateArraysForTables("Table2")
                    populateArraysForTables("Table3")
                    populateArraysForTables("Table4")
                    
                    // Here is where we will set the titles for the buttons
                    
                    TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myProjectName), forState: .Normal)
                    TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myProjectName), forState: .Normal)
                    TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myProjectName), forState: .Normal)
                    TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myProjectName), forState: .Normal)
                }
            
        case "OneNote":
            let myOneNoteUrlPath = myOneNoteNotebooks.pages[rowID].urlCallback
  
          //  let myEnUrlPath = stringByChangingChars(myTempPath, " ", "%20")
            var myOneNoteUrl: NSURL = NSURL(string: myOneNoteUrlPath)!
            
            if UIApplication.sharedApplication().canOpenURL(myOneNoteUrl) == true
            {
                UIApplication.sharedApplication().openURL(myOneNoteUrl)
            }

        case "GMail":
            TableTypeButton1.hidden = true
            TableTypeButton2.hidden = true
            TableTypeButton3.hidden = true
            TableTypeButton4.hidden = true
            dataTable1.hidden = true
            dataTable2.hidden = true
            dataTable3.hidden = true
            dataTable4.hidden = true
            peoplePickerButton.hidden = true
            
            myWebView.hidden = false
            btnCloseWindow.hidden = false
            myWebView.loadHTMLString(myGmailMessages.messages[rowID].body, baseURL: nil)
  
        case "Hangouts":
            TableTypeButton1.hidden = true
            TableTypeButton2.hidden = true
            TableTypeButton3.hidden = true
            TableTypeButton4.hidden = true
            dataTable1.hidden = true
            dataTable2.hidden = true
            dataTable3.hidden = true
            dataTable4.hidden = true
            peoplePickerButton.hidden = true
            
            myWebView.hidden = false
            btnCloseWindow.hidden = false
            myWebView.loadHTMLString(myHangoutsMessages.messages[rowID].body, baseURL: nil)
            
            default:
                let a = 1
        }
    }
    
    func setButtonTitle(inButton: UIButton, inTitle: String) -> String
    {
        var workString: String = ""
        
        let dataType = inButton.currentTitle!
        
        var selectedType: String = getFirstPartofString(dataType)
        
        // This is where we have the logic to work out which type of data we are goign to populate with
        switch selectedType
        {
            case "Reminders":
                workString = "Reminders: use List '\(inTitle)'"

            case "Evernote":
                workString = "Evernote: use Tag '\(inTitle)'"

            case "Omnifocus":
                if myDisplayType == "Project"
                {
                    workString = "Omnifocus: use Project '\(inTitle)'"
                }
                else
                {
                    workString = "Omnifocus: use Context '\(inTitle)'"
                }
            
        case "OneNote":
            
            if myDisplayType == "Project"
            {
                workString = "OneNote: use Notebook '\(inTitle)'"
            }
            else
            {
                workString = "OneNote: use Notebook 'People' and Section '\(inTitle)'"
            }
            
            default:
                workString = inButton.currentTitle!
        }
        
        if myDisplayType != ""
        {
            setAddButtonState(inButton.tag)
        }
        
        return workString
    }

    func returnFromSecondaryView(inTable: String, inRowID: Int)
    {
        displayScreen()
        populateArraysForTables(inTable)
       // populateArrayDetails(inTable)
    }

    
    func openReminderEditView(inReminderID: String, inCalendarName: String)
    {

        let reminderViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("Reminders") as! reminderViewController
        
        reminderViewControl.inAction = "Edit"
        reminderViewControl.inReminderID = inReminderID
        reminderViewControl.delegate = self
        reminderViewControl.inCalendarName = inCalendarName
 
        self.presentViewController(reminderViewControl, animated: true, completion: nil)
    }
    
    
    func openReminderAddView(inCalendarName: String)
    {
        
        let reminderViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("Reminders") as! reminderViewController
        
        reminderViewControl.inAction = "Add"
        reminderViewControl.delegate = self
        reminderViewControl.inCalendarName = inCalendarName
        
        self.presentViewController(reminderViewControl, animated: true, completion: nil)
    }

    
    func myReminderDidFinish(controller:reminderViewController, actionType: String)
    {
        if actionType == "Changed"
        {
            populateArraysForTables(reBuildTableName)
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func buttonAddClicked(sender: UIButton) {
        var dataType: String = ""
        
        // First we need to work out the type of data in the table, we get this from the button
        
        // Also depending on which table is clicked, we now need to do a check to make sure the row clicked is a valid task row.  If not then no need to try and edit it
        
        switch sender.tag
        {
        case 1:
            dataType = TableTypeButton1.currentTitle!
            reBuildTableName = "Table1"
            
        case 2:
            dataType = TableTypeButton2.currentTitle!
            reBuildTableName = "Table2"
            
        case 3:
            dataType = TableTypeButton3.currentTitle!
            reBuildTableName = "Table3"
            
        case 4:
            dataType = TableTypeButton4.currentTitle!
            reBuildTableName = "Table4"
            
        default:
            println("btnAddClicked: tag hit default for some reason")
            
        }
        
        var selectedType: String = getFirstPartofString(dataType)
        
        switch selectedType
        {
            case "Reminders":
                var myFullName: String
                if myDisplayType == "Project"
                {
                    myFullName = myProjectName
                }
                else
                {
                    myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                }

                openReminderAddView(myFullName)

            case "Evernote":
                var myFullName: String
                if myDisplayType == "Project"
                {
                    myFullName = myProjectName
                }
                else
                {
                    myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                }

                openEvernoteAddView(myFullName)
            
            case "Omnifocus":
                var myOmniUrlPath: String
                
                if myDisplayType == "Project"
                {
                    myOmniUrlPath = "omnifocus:///add?name=Set Project to '\(myProjectName)'"
                }
                else
                {
                    let myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                    myOmniUrlPath = "omnifocus:///add?name=Set Context to '\(myFullName)'"
                }

                var escapedURL = myOmniUrlPath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                
                var myOmniUrl: NSURL = NSURL(string: escapedURL!)!
                
                if UIApplication.sharedApplication().canOpenURL(myOmniUrl) == true
                {
                    UIApplication.sharedApplication().openURL(myOmniUrl)
                }
            
            case "Calendar":
                let evc = EKEventEditViewController()
                evc.eventStore = self.eventStore
                evc.editViewDelegate = self
                self.presentViewController(evc, animated: true, completion: nil)
          
            case "OneNote":
                var myItemFound: Bool = false
                var myStartPage: String = ""
            
                // First check, if a project does the notebook exist already, or if a person, does the Section in People notebook exist
            
                if myDisplayType == "Project"
                {
                    var alert = UIAlertController(title: "OneNote", message:
                        "Creating OneNote Notebook for this Project.  OneNote will open when complete.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    self.presentViewController(alert, animated: false, completion: nil)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    

                    myItemFound = myOneNoteNotebooks.checkExistenceOfNotebook(myProjectName)
                    if myItemFound
                    {
                        var alert = UIAlertController(title: "OneNote", message:
                            "Notebook already exists for this Project", preferredStyle: UIAlertControllerStyle.Alert)
                    
                        self.presentViewController(alert, animated: false, completion: nil)
                    
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    }
                    else
                    {
                        myStartPage = self.myOneNoteNotebooks.createNewNotebookForProject(self.myProjectName)
                    }
                }
                else
                {
                    let myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                    
                    if myFullName != ""
                    {
                        var alert = UIAlertController(title: "OneNote", message:
                            "Creating OneNote Section for this Person.  OneNote will open when complete.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        self.presentViewController(alert, animated: false, completion: nil)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        
                        myItemFound = myOneNoteNotebooks.checkExistenceOfPerson(myFullName)
                        if myItemFound
                        {
                            var alert = UIAlertController(title: "OneNote", message:
                                "Entry already exists for this Person", preferredStyle: UIAlertControllerStyle.Alert)
                        
                            self.presentViewController(alert, animated: false, completion: nil)
                        
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        }
                        else
                        {
                            // Create a Section for the Person and add an initial page
                            
                           myStartPage = myOneNoteNotebooks.createNewSectionForPerson(myFullName)
                        }
                    }
                }
            
                let myOneNoteUrlPath = myStartPage
            
                var myOneNoteUrl: NSURL = NSURL(string: myOneNoteUrlPath)!
            
                if UIApplication.sharedApplication().canOpenURL(myOneNoteUrl) == true
                {
                    UIApplication.sharedApplication().openURL(myOneNoteUrl)
                }
            
            default:
                let a = 1
        }

    }
    
    @IBAction func buttonMaintainProjects(sender: UIButton) {
        let MaintainProjectViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("MaintainProject") as! MaintainProjectViewController
        
        MaintainProjectViewControl.delegate = self
        MaintainProjectViewControl.myActionType = "Add"

        self.presentViewController(MaintainProjectViewControl, animated: true, completion: nil)
    }
    
    @IBAction func buttonSelectProject(sender: UIButton)
    {
        let MaintainProjectViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("MaintainProject") as! MaintainProjectViewController
        
        MaintainProjectViewControl.delegate = self
        MaintainProjectViewControl.myActionType = "Select"
        
        self.presentViewController(MaintainProjectViewControl, animated: true, completion: nil)

    }
    
    func myMaintainProjectDidFinish(controller:MaintainProjectViewController, actionType: String)
    {
        if actionType == "Changed"
        {
            populateArraysForTables(reBuildTableName)
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func myMaintainProjectSelect(controller:MaintainProjectViewController, projectID: NSNumber, projectName: String)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
        TableTypeSelection1.hidden = true
        setSelectionButton.hidden = true
        TableTypeButton1.hidden = false
        TableTypeButton2.hidden = false
        TableTypeButton3.hidden = false
        TableTypeButton4.hidden = false
        dataTable1.hidden = false
        dataTable2.hidden = false
        dataTable3.hidden = false
        dataTable4.hidden = false
        StartLabel.hidden = true
        
        myDisplayType = "Project"
        myProjectID = projectID
        myProjectName = projectName
        displayScreen()
        
        table1Contents = Array()
        table2Contents = Array()
        table3Contents = Array()
        table4Contents = Array()
        
        populateArraysForTables("Table1")
        populateArraysForTables("Table2")
        populateArraysForTables("Table3")
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
        {
            self.populateArraysForTables("Table4")
        }
    
        //populateArraysForTables("Table4")
    
        // Here is where we will set the titles for the buttons
        
        TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: projectName), forState: .Normal)
        TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: projectName), forState: .Normal)
        TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: projectName), forState: .Normal)
        TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: projectName), forState: .Normal)
    }
    
    func setAddButtonState(inTable: Int)
    {
        // Hide all of the buttons
        // Decide which buttons to show
        
        var selectedType: String = ""
        
        switch inTable
        {
            case 1:
                selectedType = getFirstPartofString(TableTypeButton1.currentTitle!)

                switch selectedType
                {
                    case "Reminders":
                
                        buttonAdd1.hidden = false

                    case "Evernote":
                        buttonAdd1.hidden = false

                    case "Omnifocus":
                        buttonAdd1.hidden = false

                    case "Calendar":
                        buttonAdd1.hidden = false
                    
                    case "OneNote":
                        buttonAdd1.hidden = false

                    default:
                        buttonAdd1.hidden = true
                }
            
            case 2:
                selectedType = getFirstPartofString(TableTypeButton2.currentTitle!)

                switch selectedType
                {
                    case "Reminders":
                        buttonAdd2.hidden = false

                    case "Evernote":
                        buttonAdd2.hidden = false
                    
                    case "Omnifocus":
                        buttonAdd2.hidden = false
                    
                    case "Calendar":
                        buttonAdd2.hidden = false
                    
                    case "OneNote":
                        buttonAdd2.hidden = false
                    
                    default:
                        buttonAdd2.hidden = true
                }
            
            case 3:
                selectedType = getFirstPartofString(TableTypeButton3.currentTitle!)

                switch selectedType
                {
                    case "Reminders":
                        buttonAdd3.hidden = false
                    
                    case "Evernote":
                        buttonAdd3.hidden = false
                    
                    case "Omnifocus":
                        buttonAdd3.hidden = false
                    
                    case "Calendar":
                        buttonAdd3.hidden = false
                    
                    
                    case "OneNote":
                        buttonAdd3.hidden = false
                    
                    default:
                        buttonAdd3.hidden = true
                }
            
            case 4:
                selectedType = getFirstPartofString(TableTypeButton4.currentTitle!)

                switch selectedType
                {
                    case "Reminders":
                        buttonAdd4.hidden = false
                    
                    case "Evernote":
                        buttonAdd4.hidden = false
                    
                    case "Omnifocus":
                        buttonAdd4.hidden = false
                    
                    case "Calendar":
                        buttonAdd4.hidden = false
                
                    
                    case "OneNote":
                        buttonAdd4.hidden = false
                    
                    default:
                        buttonAdd4.hidden = true
                }
            
            default: break
        }
    }
    
// Peoplepicker code

    @IBAction func peoplePickerButtonClick(sender: UIButton)
    {
        let picker = ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!)
    {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
        myDisplayType = "Person"
        personSelected = person

        // Dirty fix as have an issue with populating contact details if called later
        
        let dummyArray = parseContactDetails(personSelected)
        
        displayScreen()
        TableTypeSelection1.hidden = true
        setSelectionButton.hidden = true
        TableTypeButton1.hidden = false
        TableTypeButton2.hidden = false
        TableTypeButton3.hidden = false
        TableTypeButton4.hidden = false
        dataTable1.hidden = false
        dataTable2.hidden = false
        dataTable3.hidden = false
        dataTable4.hidden = false
        StartLabel.hidden = true
        
        table1Contents = Array()
        table2Contents = Array()
        table3Contents = Array()
        table4Contents = Array()
        
        populateArraysForTables("Table1")
        populateArraysForTables("Table2")
        populateArraysForTables("Table3")
        populateArraysForTables("Table4")
        
        // Here is where we will set the titles for the buttons
        
        let myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
        
        TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myFullName), forState: .Normal)
        TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myFullName), forState: .Normal)
        TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myFullName), forState: .Normal)
        TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myFullName), forState: .Normal)
    }

    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!)
    {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    }

    func EvernoteComplete()
    {
        var myTable: [TableData] = Array()

        myTable = myEvernote.getWriteString()
        
        switch EvernoteTargetTable
        {
        case "Table1":
            table1Contents = myTable
            dataTable1.reloadData()
            
        case "Table2":
            table2Contents = myTable
            dataTable2.reloadData()
            
        case "Table3":
            table3Contents = myTable
            dataTable3.reloadData()
            
        case "Table4":
            table4Contents = myTable
            dataTable4.reloadData()
            
        default:
            println("EvernoteComplete has incorrect table")
        }
    }
    
    func openEvernoteEditView(inGUID: String, inNoteRef:ENNoteRef)
    {
        if myEvernoteShard != ""
        {
            let myEnUrlPath = "evernote:///view/\(myEvernoteUserID)/\(myEvernoteShard)/\(inGUID)/\(inGUID)/"

            var myEnUrl: NSURL = NSURL(string: myEnUrlPath)!
            
            if UIApplication.sharedApplication().canOpenURL(myEnUrl) == true
            {
                UIApplication.sharedApplication().openURL(myEnUrl)
            }
        }
        else
        {
            var alert = UIAlertController(title: "Evernote", message:
                "Unable to load Evernote for this Note", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
        }
    }

    func openEvernoteAddView(inFullName: String)
    {
        // Lets build the date string
        var myDateFormatter = NSDateFormatter()
        
        var dateFormat = NSDateFormatterStyle.MediumStyle
        var timeFormat = NSDateFormatterStyle.ShortStyle
        myDateFormatter.dateStyle = dateFormat
        myDateFormatter.timeStyle = timeFormat
        
        /* Instantiate the event store */
        let myDate = myDateFormatter.stringFromDate(NSDate())

        
        let myTempPath = "evernote://x-callback-url/new-note?type=text&title=\(inFullName) : \(myDate)"
  
        let myEnUrlPath = stringByChangingChars(myTempPath, " ", "%20")

        var myEnUrl: NSURL = NSURL(string: myEnUrlPath)!
        
        if UIApplication.sharedApplication().canOpenURL(myEnUrl) == true
        {
            UIApplication.sharedApplication().openURL(myEnUrl)
        }
    }
        
    func myEvernoteUserDidFinish()
    {
        println("Evernote user authenticated")
    }
    
    func openOmnifocusDropbox()
    {
        dropboxCoreService.delegate = self
        
        let fileName = "OmniOutput.txt"
        
        let dirPaths:[String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        
        let directories:[String] = dirPaths!
        let docsDir = directories[0]
        let docsDirDAT = docsDir + "/" + fileName
        let dropboxPath = "/EvesCRM/" + fileName
        
     //   dropboxCoreService.listFolders("/")
        
        dropboxCoreService.loadFile(dropboxPath, targetFile: docsDirDAT)
    }
    
    func myDropboxFileDidLoad(fileName: String)
    {
        readOmnifocusFileContents(fileName)
    }
    
    func myDropboxFileLoadFailed(error:NSError)
    {
        var alert = UIAlertController(title: "Dropbox", message:
            "Unable to load Dropbox file.  Error = \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
    }
    
    func myDropboxFileProgress(fileName: String, progress:CGFloat)
    {
println("Dropbox status = \(progress)")
    }
    
    func myDropboxMetadataLoaded(metadata:DBMetadata)
    {
        if metadata.contents != nil
        {
                for myEntry in metadata.contents
                {
        println("Entry = \(myEntry.filename)")
                }
        }
        else
        {
println("Nothing found")
        }
    }
    
    func myDropboxMetadataFailed(error:NSError)
    {
        var alert = UIAlertController(title: "Dropbox", message:
            "Unable to load Dropbox directory list.  Error = \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
    }
    
    func myDropboxLoadAccountInfo(info:DBAccountInfo)
    {
        println("Dropbox Account Info = \(info)")
    }

    func myDropboxLoadAccountInfoFailed(error:NSError)
    {
        var alert = UIAlertController(title: "Dropbox", message:
            "Unable to load Dropbox account info.  Error = \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
    }

    func myDropboxFileDidUpload(destPath:String, srcPath:String, metadata:DBMetadata)
    {
        println("Dropbox Upload = \(destPath), \(srcPath)")
    }

    func myDropboxFileUploadFailed(error:NSError)
    {
        var alert = UIAlertController(title: "Dropbox", message:
            "Unable to upload file to Dropbox.  Error = \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
    }

    func myDropboxUploadProgress(progress:CGFloat, destPath:String, srcPath:String)
    {
        println("Dropbox upload status = \(progress)")
    }

    func myDropboxFileLoadRevisions(revisions:NSArray, path:String)
    {
        println("Dropbox File revision = \(path)")
    }

    func myDropboxFileLoadRevisionsFailed(error:NSError)
    {
        var alert = UIAlertController(title: "Dropbox", message:
            "Unable to load Dropbox file revisions.  Error = \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
    }

    func myDropboxCreateFolder(folder:DBMetadata)
    {
        println("Dropbox Create folder")
    }

    func myDropboxCreateFolderFailed(error:NSError)
    {
        var alert = UIAlertController(title: "Dropbox", message:
            "Unable to load create Dropbox folder.  Error = \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
    }

    func myDropboxFileDeleted(path:String)
    {
        println("Dropbox File Deleted = \(path)")
    }

    func myDropboxFileDeleteFailed(error:NSError)
    {
        var alert = UIAlertController(title: "Dropbox", message:
            "Unable to delete Dropbox file.  Error = \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
    }

    func myDropboxFileCopiedLoad(fromPath:String, toPath:DBMetadata)
    {
        println("Dropbox file copied = \(fromPath)")
    }

    func myDropboxFileCopyFailed(error:NSError)
    {
        var alert = UIAlertController(title: "Dropbox", message:
            "Unable to copy Dropbox file.  Error = \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
    }

    func myDropboxFileMoved(fromPath:String, toPath:DBMetadata)
    {
        println("Dropbox file moved = \(fromPath)")
    }

    func myDropboxFileMoveFailed(error:NSError)
    {
        var alert = UIAlertController(title: "Dropbox", message:
            "Unable to move Dropbox file.  Error = \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
    }

    func myDropboxFileDidLoadSearch(results:NSArray, path:String, keyword:String)
    {
        println("Dropbox search = \(path), \(keyword)")
    }

    func myDropboxFileLoadSearchFailed(error:NSError)
    {
        var alert = UIAlertController(title: "Dropbox", message:
            "Unable to search Dropbox.  Error = \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
            handler: nil))
    }
    
    
    func readOmnifocusFileContents(inPath: String)
    {
        var myFullName: String = ""
        var workArray: [TableData] = [TableData]()
        var myDisplayString: String = ""
        var myFormatString: String = ""
        let myCalendar = NSCalendar.currentCalendar()
        var myEndDate: NSDate
        var myStartDate: NSDate
        var myModDate: NSDate
        var myEntryFound: Bool = false
        
        omniLinkArray.removeAll(keepCapacity: false)
        
        if let aStreamReader = StreamReader(path: inPath)
        {
            while let line = aStreamReader.nextLine()
            {
                if myDisplayType == "Project"
                {
                    myFullName = myProjectName
                }
                else
                {
                    myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                }
                if line.lowercaseString.rangeOfString(myFullName.lowercaseString) != nil
                {
                    // need to format the string into the approriate format
                    myEntryFound = true
                    let splitText = line.componentsSeparatedByString(":::")
                    
                    omniLinkArray.append(splitText[5])

                    myDisplayString = "\(splitText[0])\n"
                    myDisplayString += "Project: \(splitText[1])"
                    myDisplayString += "    Context: \(splitText[2])"
              
                    var myDateFormatter = NSDateFormatter()
                    
                    if splitText[6] != ""  // Modification date
                    {
                        if splitText[6].lowercaseString.rangeOfString(" at ") == nil
                        {
                            // Date does not contain at
                            var dateFormat = NSDateFormatterStyle.FullStyle
                            var timeFormat = NSDateFormatterStyle.MediumStyle
                            myDateFormatter.dateStyle = dateFormat
                            myDateFormatter.timeStyle = timeFormat
                            
                            myModDate = myDateFormatter.dateFromString(splitText[6])!
                        }
                        else
                        {
                            // Date contains at
                            
                            // Only interested in the date part for this piece so lets split the string up and get the date (need to do this as date has word at in it sso not a standard format
                            let splitDate = splitText[6].componentsSeparatedByString(" at ")
                            
                            myDateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                            
                            myModDate = myDateFormatter.dateFromString(splitDate[0])!
                        }
                        
                        // Work out the comparision date we need to use, so we can flag items not updated in last 2 weeks
                        
                        let myLastUpdateString = getDecodeValue("OmniPurple")
                        // This is string value, and is also positive, so need to convert to integer
                        
                        let myLastUpdateValue = 0 - (myLastUpdateString as NSString).integerValue
 
                        let myComparisonDate = myCalendar.dateByAddingUnit(
                            .CalendarUnitDay,
                            value: myLastUpdateValue,
                            toDate: NSDate(),
                            options: nil)!
                        
                        if myModDate.compare(myComparisonDate) == NSComparisonResult.OrderedAscending
                        {
                            myFormatString = "Purple"
                        }
                    }
                    
                    if splitText[3] != ""  // Start date
                    {
                        myDisplayString += "\nStart: \(splitText[3])"
    
                        if splitText[3].lowercaseString.rangeOfString(" at ") == nil
                        {
                            // Date does not contain at

                            var dateFormat = NSDateFormatterStyle.FullStyle
                            var timeFormat = NSDateFormatterStyle.MediumStyle
                            myDateFormatter.dateStyle = dateFormat
                            myDateFormatter.timeStyle = timeFormat
                            
                            myStartDate = myDateFormatter.dateFromString(splitText[3])!
                        }
                        else
                        {
                            // Date contains at

                            // Only interested in the date part for this piece so lets split the string up and get the date (need to do this as date has word at in it sso not a standard format
                            let splitDate = splitText[3].componentsSeparatedByString(" at ")
                        
                            myDateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                        
                            myStartDate = myDateFormatter.dateFromString(splitDate[0])!
                        }

                        if myStartDate.compare(NSDate()) == NSComparisonResult.OrderedDescending
                        {
                            myFormatString = "Gray"
                        }
                    }
                    
                    if splitText[4] != ""  // End date
                    {
                        if splitText[4].lowercaseString.rangeOfString(" at ") == nil
                        {
                            // Date does not contain at
                            var dateFormat = NSDateFormatterStyle.FullStyle
                            var timeFormat = NSDateFormatterStyle.MediumStyle
                            myDateFormatter.dateStyle = dateFormat
                            myDateFormatter.timeStyle = timeFormat
                            
                            myEndDate = myDateFormatter.dateFromString(splitText[4])!
                        }
                        else
                        {
                            // Date contains at
                    
                            // Only interested in the date part for this piece so lets split the string up and get the date (need to do this as date has word at in it sso not a standard format
                            let splitDate = splitText[4].componentsSeparatedByString(" at ")
                            
                            myDateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                            
                            myEndDate = myDateFormatter.dateFromString(splitDate[0])!
                        }
                        
                        myDisplayString += "\nDue: \(splitText[4])"
                        
                        // Work out the comparision dat we need to use, so we can see if the due date is in the next 7 days
                        let myDueDateString = getDecodeValue("OmniOrange")
                        // This is string value so need to convert to integer
                        
                        let myDueDateValue = (myDueDateString as NSString).integerValue
                       
                        let myComparisonDate = myCalendar.dateByAddingUnit(
                            .CalendarUnitDay,
                            value: myDueDateValue,
                            toDate: NSDate(),
                            options: nil)!
                        
                        if myEndDate.compare(myComparisonDate) == NSComparisonResult.OrderedAscending
                        {
                             myFormatString = "Orange"
                        }
                        
                        // Work out the comparision dat we need to use, so we can see if the due date is in the next 7 days
                        let myOverdueDateString = getDecodeValue("OmniRed")
                        // This is string value so need to convert to integer
                        
                        let myOverdueDateValue = (myOverdueDateString as NSString).integerValue
                       
                        let myComparisonDateRed = myCalendar.dateByAddingUnit(
                            .CalendarUnitDay,
                            value: myOverdueDateValue,
                            toDate: NSDate(),
                            options: nil)!
                        
                        if myEndDate.compare(myComparisonDateRed) == NSComparisonResult.OrderedAscending
                        {
                            myFormatString = "Red"
                        }

                    }
                    
                    if myFormatString == ""
                    {
                        writeRowToArray(myDisplayString, &workArray)
                    }
                    else
                    {
                        myDisplayString += "\nLast updated: \(splitText[6])"
                        writeRowToArray(myDisplayString, &workArray, inDisplayFormat: myFormatString)
                        myFormatString = ""
                    }
                }
            }
            // You can close the underlying file explicitly. Otherwise it will be
            // closed when the reader is deallocated.
            aStreamReader.close()
        }
        
        if !myEntryFound
        {
            writeRowToArray("No Omnifocus tasks found", &workArray)
        }
        
        switch omniTableToRefresh
        {
            case "Table1":
                table1Contents = workArray
                dataTable1.reloadData()
            
            case "Table2":
                table2Contents = workArray
                dataTable2.reloadData()
            
            case "Table3":
                table3Contents = workArray
                dataTable3.reloadData()
            
            case "Table4":
                table4Contents = workArray
                dataTable4.reloadData()
            
            default:
                println("populateArrayDetails: inTable hit default for some reason")
            
        }
    }
    
    @IBAction func settingsButton(sender: UIButton)
    {
        let settingViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("Settings") as! settingsViewController
        settingViewControl.delegate = self
        settingViewControl.evernoteSession = evernoteSession
        settingViewControl.dropboxCoreService = dropboxCoreService
        settingViewControl.myManagedContext = managedObjectContext!

        self.presentViewController(settingViewControl, animated: true, completion: nil)
    }
    
    func mySettingsDidFinish(controller:settingsViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        if myDisplayType != ""
        { // only reload if a selection has been made
            
            displayScreen()
            table1Contents = Array()
            table2Contents = Array()
            table3Contents = Array()
            table4Contents = Array()
        
            populateArraysForTables("Table1")
            populateArraysForTables("Table2")
            populateArraysForTables("Table3")
            populateArraysForTables("Table4")
        }
    }
    
    func initialPopulationOfTables()
    {
        var decodeString: String = ""

        decodeString = getDecodeValue("CalBeforeWeeks")
        
        if decodeString == ""
        {  // Nothing found so go and create
            updateDecodeValue("CalBeforeWeeks", "1")
        }

        decodeString = getDecodeValue("CalAfterWeeks")
        
        if decodeString == ""
        {  // Nothing found so go and create
            updateDecodeValue("CalAfterWeeks", "4")
        }
        
        decodeString = getDecodeValue("OmniRed")
        
        if decodeString == ""
        {  // Nothing found so go and create
            updateDecodeValue("OmniRed", "0")
        }
        
        decodeString = getDecodeValue("OmniOrange")
        
        if decodeString == ""
        {  // Nothing found so go and create
            updateDecodeValue("OmniOrange", "7")
        }
        
        decodeString = getDecodeValue("OmniPurple")
        
        if decodeString == ""
        {  // Nothing found so go and create
            updateDecodeValue("OmniPurple", "14")
        }
        
        if getRoles().count == 0
        {
            // There are no roles defined so we need to go in and create them
            
            populateRoles()
        }
        
        if getStages().count == 0
        {
            // There are no roles defined so we need to go in and create them
            
            populateStages()
        }
    }
    
    func displayScreen()
    {
        // Go and get the list of available panes
        
        let myPanes = displayPanes(inManagedContext: managedObjectContext!)
        
        var myButtonName: String = ""
        
        if myDisplayType == "Person"
        {
            myButtonName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
        }
        else
        {
            myButtonName = myProjectName
        }
        
        TableOptions.removeAll(keepCapacity: false)
        
        for myPane in myPanes.listVisiblePanes
        {
            TableOptions.append(myPane.paneName)

            if myPane.paneOrder == 1
            {
                TableTypeButton1.setTitle(myPane.paneName, forState: .Normal)
                TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myButtonName), forState: .Normal)
                itemSelected = myPane.paneName
            }
            
            if myPane.paneOrder == 2
            {
                TableTypeButton2.setTitle(myPane.paneName, forState: .Normal)
                TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myButtonName), forState: .Normal)
            }
            
            if myPane.paneOrder == 3
            {
                TableTypeButton3.setTitle(myPane.paneName, forState: .Normal)
                TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myButtonName), forState: .Normal)
            }
            
            if myPane.paneOrder == 4
            {
                TableTypeButton4.setTitle(myPane.paneName, forState: .Normal)
                TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myButtonName), forState: .Normal)
            }
        }
    }
    
    func getEvernoteUserDetails()
    {
        //Now we are authenticated we can get the used id and shard details
        let myEnUserStore = evernoteSession.userStore
        myEnUserStore.getUserWithSuccess({
            (findNotesResults) in
            self.myEvernoteShard = findNotesResults.shardId
            self.myEvernoteUserID = findNotesResults.id as Int
            self.EvernoteUserDone = true
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationEvernoteUserDidFinish", object: nil)
            }
            , failure: {
                (findNotesError) in
                println("Failure")
                self.EvernoteUserDone = true
                self.myEvernoteShard = ""
                self.myEvernoteUserID = 0
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationEvernoteUserDidFinish", object: nil)
        })
    }
    
    func eventViewController(controller: EKEventViewController, didCompleteWithAction action: EKEventViewAction)
    {
        if myDisplayType != ""
        { // only reload if a selection has been made
            
            displayScreen()
            table1Contents = Array()
            table2Contents = Array()
            table3Contents = Array()
            table4Contents = Array()
            
            populateArraysForTables("Table1")
            populateArraysForTables("Table2")
            populateArraysForTables("Table3")
            populateArraysForTables("Table4")
        }

        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction)
    {
        if myDisplayType != ""
        { // only reload if a selection has been made
            
            displayScreen()
            table1Contents = Array()
            table2Contents = Array()
            table3Contents = Array()
            table4Contents = Array()
            
            populateArraysForTables("Table1")
            populateArraysForTables("Table2")
            populateArraysForTables("Table3")
            populateArraysForTables("Table4")
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func eventEditViewControllerDefaultCalendarForNewEvents(controller: EKEventEditViewController) -> EKCalendar!
    {

        return eventStore.defaultCalendarForNewEvents
    }

    
    func calendarChooserDidCancel(calendarChooser: EKCalendarChooser)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func calendarChooserDidFinish(calendarChooser: EKCalendarChooser)
    {
        if myDisplayType != ""
        { // only reload if a selection has been made
            
            displayScreen()
            table1Contents = Array()
            table2Contents = Array()
            table3Contents = Array()
            table4Contents = Array()
            
            populateArraysForTables("Table1")
            populateArraysForTables("Table2")
            populateArraysForTables("Table3")
            populateArraysForTables("Table4")
        }

        self.dismissViewControllerAnimated(true, completion:nil)
    }

    func OneNoteNotebookGetSections()
    {
        var myDisplay: [TableData] = Array()
        var myString: String = ""
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
            { // 1
               /* Disabling this code in order to use the OneNote search API instead
                if self.myDisplayType == "Project"
                {
                    self.myOneNoteNotebooks.getNotesForProject(self.labelName.text!)
                }
                else
                {
                    self.myOneNoteNotebooks.getNotesForPerson(self.labelName.text!)
                }
                */
                self.myOneNoteNotebooks.searchOneNote(self.labelName.text!)
            }
    }

    func OneNoteNoNotebookFound()
    {
        var myDisplay: [TableData] = Array()
        
        writeRowToArray("No matching OneNote Notebook found", &myDisplay)
        
        switch oneNoteTableToRefresh
        {
        case "Table1":
            table1Contents = myDisplay
            dataTable1.reloadData()
            
        case "Table2":
            table2Contents = myDisplay
            dataTable2.reloadData()
            
        case "Table3":
            table3Contents = myDisplay
            dataTable3.reloadData()
            
        case "Table4":
            table4Contents = myDisplay
            dataTable4.reloadData()
            
        default:
            println("OneNoteNotebookGetSections: oneNoteTableToRefresh hit default for some reason")
        }
    }
    
    func OneNotePagesReady(notification: NSNotification)
    {
        var myDisplay: [TableData] = Array()

        for myPage in myOneNoteNotebooks.pages
        {
            var dateFormat = NSDateFormatterStyle.MediumStyle
            var timeFormat = NSDateFormatterStyle.ShortStyle
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = dateFormat
            myDateFormatter.timeStyle = timeFormat
            
            let myDate = myDateFormatter.stringFromDate(myPage.lastModifiedTime)

            var myString: String = ""
            
            myString = "\(myPage.title)\n"
            myString += "Last modified : \(myDate)"
            writeRowToArray(myString, &myDisplay)
        }
        
        if myDisplay.count == 0
        {
            writeRowToArray("No matching OneNote pages found", &myDisplay)
        }
        
        switch oneNoteTableToRefresh
        {
            case "Table1":
                table1Contents = myDisplay
                dispatch_async(dispatch_get_main_queue())
                {
                        self.dataTable1.reloadData() // reload table/data or whatever here. However you want.
                }
            
            case "Table2":
                table2Contents = myDisplay
                dispatch_async(dispatch_get_main_queue())
                {
                        self.dataTable2.reloadData() // reload table/data or whatever here. However you want.
                }
            
            case "Table3":
                table3Contents = myDisplay
                dispatch_async(dispatch_get_main_queue())
                {
                        self.dataTable3.reloadData() // reload table/data or whatever here. However you want.
                }
            
            case "Table4":
                table4Contents = myDisplay
                
                dispatch_async(dispatch_get_main_queue())
                {
                    self.dataTable4.reloadData() // reload table/data or whatever here. However you want.
                }
            
            default:
                println("OneNoteNotebookGetSections: oneNoteTableToRefresh hit default for some reason")
        }
    }
    
    func myGmailDidFinish()
    {
        var myDisplay: [TableData] = Array()
        
        if myGmailMessages.messages.count == 0
        {
            writeRowToArray("No matching GMail Messages found", &myDisplay)
        }
        
        for myMessage in myGmailMessages.messages
        {
            var myString: String = ""
            
            myString = "\(myMessage.subject)\n"
            myString += "From: \(myMessage.from) to: \(myMessage.to)\n"
            myString += "Sent : \(myMessage.dateReceived)\n"
            myString += myMessage.snippet
//println("ID = \(myMessage.id)")
//println(myString)
            writeRowToArray(myString, &myDisplay)
        }
        
        if myDisplay.count == 0
        {
            writeRowToArray("No matching Gmail Messages found", &myDisplay)
        }

        switch gmailTableToRefresh
        {
        case "Table1":
            table1Contents = myDisplay
            dispatch_async(dispatch_get_main_queue())
                {
                    self.dataTable1.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table2":
            table2Contents = myDisplay
            dispatch_async(dispatch_get_main_queue())
                {
                    self.dataTable2.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table3":
            table3Contents = myDisplay
            dispatch_async(dispatch_get_main_queue())
                {
                    self.dataTable3.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table4":
            table4Contents = myDisplay
            
            dispatch_async(dispatch_get_main_queue())
                {
                    self.dataTable4.reloadData() // reload table/data or whatever here. However you want.
            }
            
        default:
            println("myGmailDidFinish: myGmailDidFinish hit default for some reason")
        }
        
        gmailTableToRefresh = ""
    }
    
    func myHangoutsDidFinish()
    {
        var myDisplay: [TableData] = Array()
        
        if myHangoutsMessages.messages.count == 0
        {
            writeRowToArray("No matching Hangout Messages found", &myDisplay)
        }
        
        for myMessage in myHangoutsMessages.messages
        {
            var myString: String = ""
            
            myString += "From: \(myMessage.from)\n"
            myString += myMessage.snippet
            writeRowToArray(myString, &myDisplay)
        }
        
        if myDisplay.count == 0
        {
            writeRowToArray("No matching Hangout Messages found", &myDisplay)
        }
        
        switch hangoutsTableToRefresh
        {
        case "Table1":
            table1Contents = myDisplay
            dispatch_async(dispatch_get_main_queue())
            {
                self.dataTable1.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table2":
            table2Contents = myDisplay
            dispatch_async(dispatch_get_main_queue())
            {
                self.dataTable2.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table3":
            table3Contents = myDisplay
            dispatch_async(dispatch_get_main_queue())
        {
                    self.dataTable3.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table4":
            table4Contents = myDisplay
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.dataTable4.reloadData() // reload table/data or whatever here. However you want.
            }
            
        default:
            println("myHangoutsDidFinish: myHangoutsDidFinish hit default for some reason")
        }
        hangoutsTableToRefresh = ""
    }

    
    @IBAction func btnCloseWindowClick(sender: UIButton)
    {
        TableTypeButton1.hidden = false
        TableTypeButton2.hidden = false
        TableTypeButton3.hidden = false
        TableTypeButton4.hidden = false
        dataTable1.hidden = false
        dataTable2.hidden = false
        dataTable3.hidden = false
        dataTable4.hidden = false
        peoplePickerButton.hidden = false
        
        myWebView.hidden = true
        btnCloseWindow.hidden = true
    }
    
    func gmailSignedIn(notification: NSNotification)
    {
        if hangoutsTableToRefresh != ""
        {
            loadHangouts()
        }
        
        if gmailTableToRefresh != ""
        {
            loadGmail()
        }
        
    }
    
    func loadGmail()
    {
        if myGmailMessages == nil
        {
            myGmailMessages = gmailMessages(inGmailData: myGmailData)
        }
        
        if myDisplayType == "Project"
        {
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
            {
                self.myGmailMessages.getMessages(self.myProjectName, inType: self.myDisplayType, inPerson: self.personSelected, inMessageType: "Mail")
            }
        }
        else
        {
            let searchString = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
            {
                self.myGmailMessages.getMessages(searchString, inType: self.myDisplayType, inPerson: self.personSelected, inMessageType: "Mail")
            }
        }
     }
    
    func loadHangouts()
    {
        if myHangoutsMessages == nil
        {
            myHangoutsMessages = gmailMessages(inGmailData: myGmailData)
        }
        
        if myDisplayType == "Project"
        {
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
            {
                    self.myHangoutsMessages.getMessages(self.myProjectName, inType: self.myDisplayType, inPerson: self.personSelected, inMessageType: "Hangouts")
            }
        }
        else
        {
            let searchString = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
            {
                    self.myHangoutsMessages.getMessages(searchString, inType: self.myDisplayType, inPerson: self.personSelected, inMessageType: "Hangouts")
            }
        }
    }
}