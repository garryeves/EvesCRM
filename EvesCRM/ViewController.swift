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
import Social
import Accounts

//import "ENSDK/Headers/ENSDK.h"

// PeoplePicker code
class ViewController: UIViewController, MyReminderDelegate, ABPeoplePickerNavigationControllerDelegate, MyMaintainProjectDelegate, MyDropboxCoreDelegate, MySettingsDelegate, EKEventViewDelegate, EKEventEditViewDelegate, EKCalendarChooserDelegate, MyMeetingsDelegate, SideBarDelegate, MyMaintainPanesDelegate, MyTaskDelegate
{
    
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
    @IBOutlet weak var StartLabel: UILabel!
    @IBOutlet weak var setSelectionButton: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var btnCloseWindow: UIButton!

    let CONTACT_CELL_IDENTIFER = "contactNameCell"
    let dataTable1_CELL_IDENTIFER = "dataTable1Cell"
    
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
    
    // store the details of the person selected in the People table
    var personContact: iOSContact!
    
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
    var omniTableToRefresh: String = ""
    var oneNoteTableToRefresh: String = ""
    var gmailTableToRefresh: String = ""
    var hangoutsTableToRefresh: String = ""
    var facebookTableToRefresh: String = ""

    var oneNoteLinkArray: [String] = Array()
    var omniLinkArray: [String] = Array()
    
    var document: MyDocument?
    var documentURL: NSURL?
    var ubiquityURL: NSURL?
    var metaDataQuery: NSMetadataQuery?
    
    var dropboxConnected: Bool = false
    
    var dbRestClient: DBRestClient?
    
  //  var eventDetails: [EKEvent] = Array()
    var eventDetails: iOSCalendar!

//    var reminderDetails: [EKReminder] = Array()
    var reminderDetails: iOSReminder!

    var projectMemberArray: [String] = Array()
    var mySelectedProject: project!
    var myContextName: String = ""
    
    // OneNote
    var myOneNoteNotebooks: oneNoteNotebooks!

    // Gmail
    var myGmailMessages: gmailMessages!
    var myHangoutsMessages: gmailMessages!
    var myGmailData: gmailData!

    var myRowClicked: Int = 0
    var calendarTable: String = ""
    var myCalendarItems: [myCalendarItem] = Array()
    
    var myTaskItems: [task] = Array()
    
    // Peoplepicker settings
    
    var sideBar:SideBar!
    
    // Textexpander
    
    var textExpander: SMTEDelegateController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myDatabaseConnection = coreDatabase()
        
        // sync with the master database
        
        let myDBSync = DBSync()
        
        myDBSync.sync()
 
        //   code to reset decodes if needed for testing
 //       myDatabaseConnection.deleteDecodeValue()
        
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
        
        myWebView.hidden = true
        btnCloseWindow.hidden = true
        
        dataTable1.tableFooterView = UIView(frame:CGRectZero)
        dataTable2.tableFooterView = UIView(frame:CGRectZero)
        dataTable3.tableFooterView = UIView(frame:CGRectZero)
        dataTable4.tableFooterView = UIView(frame:CGRectZero)

        populateContactList()
    
   //   code to reset projects if needed for testing
    //    myDatabaseConnection.resetprojects()
        
   //   code to reset meetings if needed for testing        
  //      myDatabaseConnection.resetMeetings()
        
        //   code to reset tasks if needed for testing
  //      myDatabaseConnection.resetTasks()
        
        //   code to reset contexts if needed for testing
    //         myDatabaseConnection.resetContexts()
        
        // Work out if a project has been added to the data store, so we can then select it
        let myProjects = myDatabaseConnection.getProjects(myTeamID)
                
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
        TableTypeButton4.setTitle("Tasks", forState: .Normal)
       
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
        
        sideBar = SideBar()
        
        sideBar = SideBar(sourceView: self.view)
        sideBar.delegate = self

        // Textexpander
        
        if SMTEDelegateController.isTextExpanderTouchInstalled() == true
        {
            if textExpander == nil
            {
                // Lazy load of TextExpander
                textExpander = SMTEDelegateController()
                textExpander.clientAppName = "EvesCRM"
                textExpander.getSnippetsScheme = "EvesCRM-get-snippets-xc"
                textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
                textExpander.fillDelegate = self
            }
        }
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
   
        let myPanes = displayPanes()
        
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
                myFullName = mySelectedProject.projectName
            }
            else if myDisplayType == "Context"
            {
                myFullName = myContextName
            }
            else
            {
                myFullName = personContact.fullName
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
        }
    }

    func createAddressBook() -> Bool {
        if adbk != nil {
            return true
        }
        var err : Unmanaged<CFError>? = nil
        let myAdbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if myAdbk == nil
        {
            println(err)
            adbk = nil
            return false
        }
        adbk = myAdbk
        
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
            adbk = nil
            return false
        case .Restricted:
            adbk = nil
            return false
        case .Denied:
            adbk = nil
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
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = myRowColour
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
            labelName.text = mySelectedProject.projectName
        }
        else if myDisplayType == "Context"
        {
            labelName.text = myContextName
        }
        else
        {
            labelName.text = personContact.fullName
        }
                
        var selectedType: String = getFirstPartofString(dataType)
        
        // This is where we have the logic to work out which type of data we are goign to populate with
        switch selectedType
        {
            case "Details":
                if myDisplayType == "Project"
                {
                    workArray = parseProjectDetails(mySelectedProject)
                }
                else if myDisplayType == "Context"
                {
                    writeRowToArray("Context = \(myContextName)", &workArray)
                }
                else
                {
                    workArray = personContact.tableData
                }
            case "Calendar":
                eventDetails = iOSCalendar(inEventStore: eventStore)

                if myDisplayType == "Project"
                {
                    eventDetails.loadCalendarDetails(mySelectedProject.projectName)
                }
                else if myDisplayType == "Context"
                {
                    writeRowToArray("No calendar entries found", &workArray)
                }
                else
                {
                    eventDetails.loadCalendarDetails(personContact.emailAddresses)
                }
                workArray = eventDetails.displayEvent()
                
                if workArray.count == 0
                {
                    writeRowToArray("No calendar entries found", &workArray)
                }
            case "Reminders":
                reminderDetails = iOSReminder()
                var workingName: String = ""
                if myDisplayType == "Project"
                {
                    reminderDetails.parseReminderDetails(mySelectedProject.projectName)
                }
                else
                {
                    if myDisplayType == "Context"
                    {
                        workingName = myContextName
                    }
                    else
                    {
                        workingName = personContact.fullName
                    }
                    reminderDetails.parseReminderDetails(workingName)
                }
                workArray = reminderDetails.displayReminder()
            
            case "Evernote":
                writeRowToArray("Loading Evernote data.  Pane will refresh when finished", &workArray)
                if myDisplayType == "Project"
                {
                    myEvernote.findEvernoteNotes(mySelectedProject.projectName)
                }
                else
                {
                    var searchString: String = ""
                    if myDisplayType == "Context"
                    {
                        searchString = myContextName
                    }
                    else
                    {
                        searchString = personContact.fullName
                    }
                    myEvernote.findEvernoteNotes(searchString)
                }
                EvernoteTargetTable = inTable

            case "Project Membership":
                // Project team membership details
                if myDisplayType == "Project"
                {
                    workArray = displayTeamMembers(mySelectedProject, &projectMemberArray)
                }
                else
                {
                    var searchString: String = ""
                    if myDisplayType == "Context"
                    {
                        searchString = myContextName
                    }
                    else
                    {
                        searchString = personContact.fullName
                    }
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

        case "Tasks":
            myTaskItems.removeAll(keepCapacity: false)
            
            var myReturnedData: [Task] = Array()
            if myDisplayType == "Project"
            {
                myReturnedData = myDatabaseConnection.getTasksForProject(mySelectedProject.projectID, inTeamID: myTeamID)
            }
            else
            {
                // Get the context name
                var searchString: String = ""
                if myDisplayType == "Context"
                {
                    searchString = myContextName
                }
                else
                {
                    searchString = personContact.fullName
                }
                
                let myContext = myDatabaseConnection.getContextByName(searchString, inTeamID: myTeamID)
                
                if myContext.count != 0
                {
                    // Context retrieved
                    
                    // Get the tasks based on the retrieved context ID
                
                    let myTaskContextList = myDatabaseConnection.getTasksForContext(myContext[0].contextID as Int)
                
                    for myTaskContext in myTaskContextList
                    {
                        // Get the context details
                        let myTaskList = myDatabaseConnection.getActiveTask(myTaskContext.taskID as Int, inTeamID: myTeamID)
                    
                        for myTask in myTaskList
                        {  //append project details to work array
                            myReturnedData.append(myTask)
                        }
                    }
                }
            }
            
            // Sort workarray by dueDate, with oldest first
            myReturnedData.sort({$0.dueDate.timeIntervalSinceNow < $1.dueDate.timeIntervalSinceNow})
            
            // Load calendar items array based on return array
            
            for myItem in myReturnedData
            {
                let myTempTask = task(inTaskID: myItem.taskID as Int)
                
                myTaskItems.append(myTempTask)
            }
            
            workArray = buildTaskDisplay()
            
            if workArray.count == 0
            {
                writeRowToArray("No tasks found", &workArray)
            }
            
            
            /*case "Facebook":
                if myDisplayType == "Project"
                {
                    writeRowToArray("Projects do not have Facebook accounts", &workArray)
                }
                else
                {
                    if myFacebookID == ""
                    {
                        writeRowToArray("No Facebook account for this person", &workArray)
                    }
                    else
                    {
                        writeRowToArray("Loading Facebook posts.  Pane will refresh when finished", &workArray)
                        
                        facebookTableToRefresh = inTable
println("facebook ID = \(myFacebookID)")
                        
                        var accountStore = ACAccountStore()
                        var accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
                        
                        var postingOptions = [ACFacebookAppIdKey: "456682554489016",
                                              ACFacebookPermissionsKey: ["email"],
                                              ACFacebookAudienceKey: ACFacebookAudienceEveryone]
                        
                        accountStore.requestAccessToAccountsWithType(accountType, options: postingOptions as [NSObject : AnyObject])
                            {
                                success, error in
                                if success
                                {
                println("Facebook success")
                                    var options = [ACFacebookAppIdKey: "456682554489016",
                                                   ACFacebookPermissionsKey: ["publish_actions"],
                                                   ACFacebookAudienceKey: ACFacebookAudienceEveryone]
                                   
                                    
                                    NSString *acessToken = [NSString stringWithFormat:@"%@",facebookAccount.credential.oauthToken];
                                    NSDictionary *parameters = @{@"access_token": acessToken};
                                    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];
                                    
                                    SLRequest *feedRequest = [SLRequest
                                    requestForServiceType:SLServiceTypeFacebook
                                    requestMethod:SLRequestMethodGET
                                    URL:feedURL
                                    parameters:parameters];
                                    feedRequest.account = facebookAccount;
                                    [feedRequest performRequestWithHandler:^(NSData *responseData,
                                    NSHTTPURLResponse *urlResponse, NSError *error)
                                    {
                                    NSLog(@"%@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                                    }];
                                }
                                else
                                {
                                    // Handle Failure
                                }
                                    
                                    
                                    
                                  //  var options = [ACFacebookAppIdKey: "456682554489016",
                                  //      ACFacebookPermissionsKey: ["publish_actions"],
                                  //      ACFacebookAudienceKey: ACFacebookAudienceFriends]
                                    
                                  //  accountStore.requestAccessToAccountsWithType(accountType,
                                  //      options: options) {
                                  //          success, error in
                                  //          if success {
                                  //              var accountsArray =
                                  //              accountStore.accountsWithAccountType(accountType)
                                                
                                   //             if accountsArray.count > 0 {
                                   //                 var facebookAccount = accountsArray[0] as! ACAccount
                                                    
                                   //                 var parameters = Dictionary<String, AnyObject>()
                                   //                 parameters["access_token"] =
                                   //                     facebookAccount.credential.oauthToken
                                   //                 parameters["message"] = "My first Facebook post from iOS 8"
                                                    
                                   //                 var feedURL = NSURL(string:
                                   //                     "https://graph.facebook.com/me/feed")
                                                    
                                   //                 let postRequest = SLRequest(forServiceType:
                                   //                     SLServiceTypeFacebook,
                                   //                     requestMethod: SLRequestMethod.POST,
                                   //                     URL: feedURL,
                                   //                     parameters: parameters)
                                   //                 postRequest.performRequestWithHandler(
                                   //                     {(responseData: NSData!,
                                   //                         urlResponse: NSHTTPURLResponse!,
                                  //                          error: NSError!) -> Void in
                                  //                          println("Twitter HTTP response \(urlResponse.statusCode)")
                                    //                })
                                     //           }
                                    //        } else {
                                    //            println("Access denied")
                                    //            println(error.localizedDescription)
                                    //        }
                                   // }
                                }
                                else
                                {
                                    println("Facebook Access denied")
                                    println(error.localizedDescription)
                                }
                        }
                        
                        
                    }
                }

*/
            
            
            
            
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
        myRowClicked = rowID
        
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
                        myFullName = mySelectedProject.projectName
                    }
                    else if myDisplayType == "Context"
                    {
                        myFullName = myContextName
                    }
                    else
                    {
                        myFullName = personContact.fullName
                    }
                    openReminderEditView(reminderDetails.reminders[rowID].calendarItemIdentifier, inCalendarName: myFullName)
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
                
                let calendarOption: UIAlertController = UIAlertController(title: "Calendar Options", message: "Select action to take", preferredStyle: .ActionSheet)

                let edit = UIAlertAction(title: "Edit Meeting", style: .Default, handler: { (action: UIAlertAction!) -> () in
                    // doing something for "product page
                    let evc = EKEventEditViewController()
                    evc.eventStore = eventStore
                    evc.editViewDelegate = self
                    evc.event = self.eventDetails.events[rowID]
                    self.presentViewController(evc, animated: true, completion: nil)
                })
                
                let agenda = UIAlertAction(title: "Agenda", style: .Default, handler: { (action: UIAlertAction!) -> () in
                    // doing something for "product page"
                    self.openMeetings("Agenda", workingTask: self.eventDetails.calendarItems[rowID])
                })
                
                let minutes = UIAlertAction(title: "Minutes", style: .Default, handler: { (action: UIAlertAction!) -> () in
                    // doing something for "product page"
                    self.openMeetings("Minutes", workingTask: self.eventDetails.calendarItems[rowID])

                })
                
                let personNotes = UIAlertAction(title: "Personal Notes", style: .Default, handler: { (action: UIAlertAction!) -> () in
                    // doing something for "product page"
                    self.openMeetings("Personal Notes", workingTask: self.eventDetails.calendarItems[rowID])

                })

                var agendaDisplay: Bool = false
                if eventDetails.calendarItems[myRowClicked].startDate.compare(NSDate()) == NSComparisonResult.OrderedDescending
                { // Start date is in the future
                    calendarOption.addAction(edit)
                    calendarOption.addAction(agenda)
                    agendaDisplay = true
                }
                
                // Is there an Agenda created for the meeting, if not then do not display Minutes or Notes options
                
                var minutesDisplay: Bool = false
                eventDetails.calendarItems[myRowClicked].loadAgenda()
                if eventDetails.calendarItems[myRowClicked].agendaItems.count > 0
                { // Start date is in the future
                    calendarOption.addAction(minutes)
                    calendarOption.addAction(personNotes)
                    minutesDisplay = true
                }
            
                if agendaDisplay || minutesDisplay
                {
                    calendarOption.popoverPresentationController?.sourceView = self.view
                    calendarOption.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.width / 2.0, self.view.bounds.height / 2.0, 1.0, 1.0)

                    self.presentViewController(calendarOption, animated: true, completion: nil)
                }
                calendarTable = inTable

            case "Project Membership":
                // Project team membership details
                if myDisplayType == "Project"
                {
                    let myPerson: ABRecord = findPersonRecord(projectMemberArray[rowID]) as ABRecord
                    loadPerson(myPerson)
                }
                else
                {
                    loadProject(projectMemberArray[rowID].toInt()!)
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
            
            myWebView.hidden = false
            btnCloseWindow.hidden = false
            myWebView.loadHTMLString(myHangoutsMessages.messages[rowID].body, baseURL: nil)
        
        case "Tasks":
            
            let taskViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("taskTab") as! tasksTabViewController
            
            var myPassedTask = TaskModel()
            myPassedTask.taskType = ""
            myPassedTask.currentTask = myTaskItems[rowID]
            myPassedTask.delegate = self
            taskViewControl.myPassedTask = myPassedTask
            
            self.presentViewController(taskViewControl, animated: true, completion: nil)

            
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
                    myFullName = mySelectedProject.projectName
                }
                else if myDisplayType == "Context"
                {
                    myFullName = myContextName
                }
                else
                {
                    myFullName = personContact.fullName
                }

                openReminderAddView(myFullName)

            case "Evernote":
                var myFullName: String
                if myDisplayType == "Project"
                {
                    myFullName = mySelectedProject.projectName
                }
                else if myDisplayType == "Context"
                {
                    myFullName = myContextName
                }
                else
                {
                    myFullName = personContact.fullName
                }

                openEvernoteAddView(myFullName)
            
            case "Omnifocus":
                var myOmniUrlPath: String
                
                if myDisplayType == "Project"
                {
                    myOmniUrlPath = "omnifocus:///add?name=Set Project to '\(mySelectedProject.projectName)'"
                }
                else
                {
                    var myFullName: String = ""
                    if myDisplayType == "Context"
                    {
                        myFullName = myContextName
                    }
                    else
                    {
                        myFullName = personContact.fullName
                    }
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
                evc.eventStore = eventStore
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
                    

                    myItemFound = myOneNoteNotebooks.checkExistenceOfNotebook(mySelectedProject.projectName)
                    if myItemFound
                    {
                        var alert = UIAlertController(title: "OneNote", message:
                            "Notebook already exists for this Project", preferredStyle: UIAlertControllerStyle.Alert)
                    
                        self.presentViewController(alert, animated: false, completion: nil)
                    
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    }
                    else
                    {
                        myStartPage = self.myOneNoteNotebooks.createNewNotebookForProject(self.mySelectedProject.projectName)
                    }
                }
                else
                {
                    var myFullName: String = ""
                    if myDisplayType == "Context"
                    {
                        myFullName = myContextName
                    }
                    else
                    {
                        myFullName = personContact.fullName
                    }
                    
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
    
    func myMaintainProjectDidFinish(controller:MaintainProjectViewController, actionType: String)
    {
        populateArraysForTables(reBuildTableName)
        
        controller.dismissViewControllerAnimated(true, completion: nil)
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
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!)
    {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
        
        loadPerson(person)
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
                    myFullName = mySelectedProject.projectName
                }
                else if myDisplayType == "Context"
                {
                    myFullName = myContextName
                }
                else
                {
                    myFullName = personContact.fullName
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
                        
                        let myLastUpdateString = myDatabaseConnection.getDecodeValue("Tasks - Days since last update")
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
                        let myDueDateString = myDatabaseConnection.getDecodeValue("Tasks - Days before due date")
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
                        let myOverdueDateString = myDatabaseConnection.getDecodeValue("Tasks - Days after due date")
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
    
    func openMeetings(inType: String, workingTask: myCalendarItem)
    {
        let meetingViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("MeetingsTab") as! meetingTabViewController
        
        var myPassedMeeting = MeetingModel()
        myPassedMeeting.actionType = inType
     //   let workingTask = eventDetails.calendarItems[myRowClicked]
        myPassedMeeting.event = workingTask
        myPassedMeeting.delegate = self
        
        meetingViewControl.myPassedMeeting = myPassedMeeting
        
        self.presentViewController(meetingViewControl, animated: true, completion: nil)
    }
    
    func myMeetingsAgendaDidFinish(controller:meetingAgendaViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
        populateArrayDetails(calendarTable)
        
        switch calendarTable
        {
        case "Table1":
            dataTable1.reloadData()
            
        case "Table2":
            dataTable2.reloadData()
            
        case "Table3":
            dataTable3.reloadData()
            
        case "Table4":
            dataTable4.reloadData()
            
        default:
            println("myMeetingsDidFinish: myMeetingsDidFinish hit default for some reason")
        }
    }

    func myMeetingsDidFinish(controller:meetingsViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
        populateArrayDetails(calendarTable)
        
        switch calendarTable
        {
        case "Table1":
            dataTable1.reloadData()
            
        case "Table2":
            dataTable2.reloadData()
            
        case "Table3":
            dataTable3.reloadData()
            
        case "Table4":
            dataTable4.reloadData()
            
        default:
            println("myMeetingsDidFinish: myMeetingsDidFinish hit default for some reason")
        }
    }

    func initialPopulationOfTables()
    {
        var decodeString: String = ""
        
        if myDatabaseConnection.getTeamsCount() == 0
        {
            let myTeam = team()
            myTeam.name = "My Life"
            myTeam.type = "private"
            myTeam.status = "Open"
            
            // Need to update existing tables to use the newly created team
            
            myDatabaseConnection.initialiseTeamForContext(myTeam.teamID)
            myDatabaseConnection.initialiseTeamForMeetingAgenda(myTeam.teamID)
            myDatabaseConnection.initialiseTeamForProject(myTeam.teamID)
            myDatabaseConnection.initialiseTeamForRoles(myTeam.teamID)
            myDatabaseConnection.initialiseTeamForStages(myTeam.teamID)
            myDatabaseConnection.initialiseTeamForTask(myTeam.teamID)
        }

        decodeString = myDatabaseConnection.getDecodeValue("Calendar - Weeks before current date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Calendar - Weeks before current date", inCodeValue: "1", inCodeType: "stepper")
        }

        decodeString = myDatabaseConnection.getDecodeValue("Calendar - Weeks after current date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Calendar - Weeks after current date", inCodeValue: "4", inCodeType: "stepper")
        }
        
        decodeString = myDatabaseConnection.getDecodeValue("Tasks - Days after due date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Tasks - Days after due date", inCodeValue: "0", inCodeType: "stepper")
        }
        
        decodeString = myDatabaseConnection.getDecodeValue("Tasks - Days before due date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Tasks - Days before due date", inCodeValue: "7", inCodeType: "stepper")
        }
        
        decodeString = myDatabaseConnection.getDecodeValue("Tasks - Days since last update")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Tasks - Days since last update", inCodeValue: "14", inCodeType: "stepper")
        }
        
        if myDatabaseConnection.getRoles(myTeamID).count == 0
        {
            // There are no roles defined so we need to go in and create them
            
            populateRoles()
        }
        
        if myDatabaseConnection.getStages(myTeamID).count == 0
        {
            // There are no roles defined so we need to go in and create them
            
            populateStages()
        }
    }
    
    func displayScreen()
    {
        // Go and get the list of available panes
        
        let myPanes = displayPanes()
        
        var myButtonName: String = ""
        
        if myDisplayType == "Person"
        {
            myButtonName = personContact.fullName
        }
        else if myDisplayType == "Context"
        {
            myButtonName = myContextName
        }
        else
        {
            myButtonName = mySelectedProject.projectName
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
                self.myGmailMessages.getProjectMessages(self.mySelectedProject.projectName, inMessageType: "Mail")
            }
        }
        else
        {
            var searchString: String = ""
            if myDisplayType == "Context"
            {
                searchString = myContextName
            }
            else
            {
                searchString = personContact.fullName
            }
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
            {
                self.myGmailMessages.getPersonMessages(searchString, emailAddresses: self.personContact.emailAddresses, inMessageType: "Mail")
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
                    self.myHangoutsMessages.getProjectMessages(self.mySelectedProject.projectName, inMessageType: "Hangouts")
            }
        }
        else
        {
            var searchString: String = ""
            if myDisplayType == "Context"
            {
                searchString = myContextName
            }
            else
            {
                searchString = personContact.fullName
            }
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
            {
                    self.myHangoutsMessages.getPersonMessages(searchString, emailAddresses: self.personContact.emailAddresses, inMessageType: "Hangouts")
            }
        }
    }
    
    func sideBarDidSelectButtonAtIndex(passedItem:menuObject)
    {
        switch passedItem.displayType
        {
            case "Header":
                switch passedItem.displayString
                {
                    case "Projects":
                     //   let MaintainProjectViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("MaintainProject") as! MaintainProjectViewController
                    
                     //   MaintainProjectViewControl.delegate = self
                     //   MaintainProjectViewControl.myActionType = "Add"
                    
                     //   self.presentViewController(MaintainProjectViewControl, animated: true, completion: nil)
                    
                    
                        let projectViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("planningTab") as! GTDPlanningTabViewController
                        
                        var myPassedGTD = GTDModel()
                        
                        myPassedGTD.delegate = self
                        myPassedGTD.actionSource = "Project"
                        
                        projectViewControl.myPassedGTD = myPassedGTD
                        
                        self.presentViewController(projectViewControl, animated: true, completion: nil)
                    
                case "Context":
                    let projectViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("planningTab") as! GTDPlanningTabViewController
                    
                    var myPassedGTD = GTDModel()
                    
                    myPassedGTD.delegate = self
                    myPassedGTD.actionSource = "Context"
                    
                    projectViewControl.myPassedGTD = myPassedGTD
                    
                    self.presentViewController(projectViewControl, animated: true, completion: nil)
                    
                    default: println("sideBarDidSelectButtonAtIndex - Action selector: Hit default")
                }

            
            case "Project" :
                let myProject = passedItem.displayObject as! Projects
                loadProject(myProject.projectID as Int)
            
        case "People":
            if passedItem.displayString == "Address Book"
            {
                let picker = ABPeoplePickerNavigationController()
                
                picker.peoplePickerDelegate = self
                presentViewController(picker, animated: true, completion: nil)
            }
            else
            {
                let myPerson: ABRecord! = findPersonRecord(passedItem.displayString) as ABRecord!
            
                if myPerson == nil
                {
                    loadContext(passedItem.displayString)
                }
                else
                {
                    loadPerson(myPerson)
                }
            }

            case "Context":
                loadContext(passedItem.displayString)
            
            case "Action":
                switch passedItem.displayString
                {
                    case "Settings":
                        let settingViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("Settings") as! settingsViewController
                        settingViewControl.delegate = self
                        settingViewControl.evernoteSession = evernoteSession
                        settingViewControl.dropboxCoreService = dropboxCoreService
                        
                        self.presentViewController(settingViewControl, animated: true, completion: nil)
                    
                    case "Maintain Display Panes":
                        let maintainPaneViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("MaintainPanes") as! MaintainPanesViewController
                        
                        maintainPaneViewControl.delegate = self
                        
                        self.presentViewController(maintainPaneViewControl, animated: true, completion: nil)
                    
                    case "Load TextExpander Snippets" :
                        // Textexpander
                    
                        if SMTEDelegateController.isTextExpanderTouchInstalled() == true
                        {
                            if textExpander == nil
                            {
                                // Lazy load of TextExpander
                                textExpander = SMTEDelegateController()
                                textExpander.clientAppName = "EvesCRM"
                                textExpander.getSnippetsScheme = "EvesCRM-get-snippets-xc"
                                textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
                                textExpander.fillDelegate = self
                            }
                            textExpander.getSnippets()
                        }
                    
                    default: println("sideBarDidSelectButtonAtIndex - Action selector: Hit default")
                    
                }
            
            default:
                println("sideBarDidSelectButtonAtIndex: Hit default")
        }
    }
    
    func sideBarWillOpen(target: UIView)
    {
        self.view.bringSubviewToFront(target)
    }
    
    func loadProject(inProjectID: Int)
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
        mySelectedProject = project(inProjectID: inProjectID)
        
        displayScreen()
        
        table1Contents = Array()
        table2Contents = Array()
        table3Contents = Array()
        table4Contents = Array()
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
        {
            self.populateArraysForTables("Table1")
        }
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
        {
            self.populateArraysForTables("Table2")
        }
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
        {
            self.populateArraysForTables("Table3")
        }
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0))
        {
            self.populateArraysForTables("Table4")
        }
        
        //populateArraysForTables("Table4")
        
        // Here is where we will set the titles for the buttons
        
        TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: mySelectedProject.projectName), forState: .Normal)
        TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: mySelectedProject.projectName), forState: .Normal)
        TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: mySelectedProject.projectName), forState: .Normal)
        TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: mySelectedProject.projectName), forState: .Normal)
    }
    
    func loadPerson(personRecord: ABRecord)
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
    
        personContact = iOSContact(contactRecord: personRecord)
        displayScreen()
        
        table1Contents = Array()
        table2Contents = Array()
        table3Contents = Array()
        table4Contents = Array()
    
        populateArraysForTables("Table1")
        populateArraysForTables("Table2")
        populateArraysForTables("Table3")
        populateArraysForTables("Table4")
    
        // Here is where we will set the titles for the buttons
    
        let myFullName = personContact.fullName
    
        TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myFullName), forState: .Normal)
        TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myFullName), forState: .Normal)
        TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myFullName), forState: .Normal)
        TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myFullName), forState: .Normal)
    }
    
    func loadContext(inContext: String)
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
        
        myDisplayType = "Context"
        myContextName = inContext
        
        // we need to go and find the record for the person we have selected

        displayScreen()
        
        table1Contents = Array()
        table2Contents = Array()
        table3Contents = Array()
        table4Contents = Array()
        
        populateArraysForTables("Table1")
        populateArraysForTables("Table2")
        populateArraysForTables("Table3")
        populateArraysForTables("Table4")
        
        // Here is where we will set the titles for the buttons
        
        let myFullName = inContext
        
        TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myFullName), forState: .Normal)
        TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myFullName), forState: .Normal)
        TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myFullName), forState: .Normal)
        TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myFullName), forState: .Normal)
    }

    func MaintainPanesDidFinish(controller:MaintainPanesViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func buildMeetingDisplay() -> [TableData]
    {
        var tableContents: [TableData] = [TableData]()
        
        // Build up the details we want to show ing the calendar
        
        for event in myCalendarItems
        {
            var myString = "\(event.title)\n"
            myString += "\(event.displayScheduledDate)\n"
            
            if event.location != ""
            {
                myString += "At \(event.location)\n"
            }
            
            if event.startDate.compare(NSDate()) == NSComparisonResult.OrderedAscending
            {
                // Event is in the past
                writeRowToArray(myString, &tableContents, inDisplayFormat: "Gray")
            }
            else
            {
                writeRowToArray(myString, &tableContents)
            }
        }
        return tableContents
    }
    
    func buildTaskDisplay() -> [TableData]
    {
        var tableContents: [TableData] = [TableData]()
        
        // Build up the details we want to show ing the calendar
        
        for myTask in myTaskItems
        {
            var myString = "\(myTask.title)\n"
            
            myString += "Project: "
            
            let myData = myDatabaseConnection.getProjectDetails(myTask.projectID, inTeamID: myTeamID)
            
            if myData.count == 0
            {
                myString += "No project set"
            }
            else
            {
                myString += myData[0].projectName
            }

            myString += "   Due: "
            if myTask.displayDueDate == ""
            {
                myString += "No due date set"
            }
            else
            {
                myString += myTask.displayDueDate
            }
            writeRowToArray(myString, &tableContents)
        }
        return tableContents
    }

    func myTaskDidFinish(controller:taskViewController, actionType: String, currentTask: task)
    {
        // reload the task Items collection view
        
        // Associate the task with the meeting
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func myTaskUpdateDidFinish(controller:taskUpdatesViewController, actionType: String, currentTask: task)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func myGTDPlanningDidFinish(controller:MaintainGTDPlanningViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}