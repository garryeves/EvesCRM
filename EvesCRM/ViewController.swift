//
//  ViewController.swift
//  EvesCRM
//
//  Created by Garry Eves /Users/garryeves/Documents/xcode/EvesCRM/EvesCRM/reminderViewController.swifton 15/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import EventKit
import EventKitUI
import Social
import Accounts
import TextExpander

//import "ENSDK/Headers/ENSDK.h"

protocol internalCommunicationDelegate
{
    func displayResults(sourceService: String, resultsArray: [TableData])
}

// PeoplePicker code
class ViewController: UIViewController, MyReminderDelegate, CNContactPickerDelegate, MyMaintainProjectDelegate, MySettingsDelegate, EKEventViewDelegate, EKEventEditViewDelegate, EKCalendarChooserDelegate, MyMeetingsDelegate, SideBarDelegate, MyMaintainPanesDelegate, UIPopoverPresentationControllerDelegate, MyGTDInboxDelegate, MyMaintainContextsDelegate, internalCommunicationDelegate   //MyDropboxCoreDelegate
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
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var btnSetStartDate: UIButton!
    @IBOutlet weak var btnSendToInbox: UIButton!
    
    
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
    var documentURL: URL?
    var ubiquityURL: URL?
    var metaDataQuery: NSMetadataQuery?
    
    var dropBoxClass: dropboxService!
    
//    var dbRestClient: DBRestClient?
    
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
    var myWorkingTask: task!
    var myWorkingTable: String = ""
    var myWorkingGmailMessage: gmailMessage!
    
    // Peoplepicker settings
    
    var sideBar:SideBar!
    
    // Textexpander
    
    var textExpander: SMTEDelegateController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myID = "dummy" // this is here for when I enable multiuser, to make it easy to implement

        myDBSync.startTimer()
        
        globalEventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
        case .authorized:
            print("Calendar Access granted")
        case .denied:
            print("Calendar Access denied")
        case .notDetermined:
            // 3
            globalEventStore.requestAccess(to: EKEntityType.event, completion:
                {(granted: Bool, error: Error?) -> Void in
                    if granted {
                        print("Calendar Access granted")
                    } else {
                        print("Calendar Access denied")
                    }
                })
        default:
            print("Calendar Case Default")
        }

        // Now we will try and open Evernote
        

        evernoteSession = ENSession.shared()

//        connectToEvernote()
        
       // Initial population of contact list
        self.dataTable1.register(UITableViewCell.self, forCellReuseIdentifier: CONTACT_CELL_IDENTIFER)
        self.dataTable2.register(UITableViewCell.self, forCellReuseIdentifier: CONTACT_CELL_IDENTIFER)
        self.dataTable3.register(UITableViewCell.self, forCellReuseIdentifier: CONTACT_CELL_IDENTIFER)
        self.dataTable4.register(UITableViewCell.self, forCellReuseIdentifier: CONTACT_CELL_IDENTIFER)
        
        hideFields()
        buttonAdd1.isHidden = true
        buttonAdd2.isHidden = true
        buttonAdd3.isHidden = true
        buttonAdd4.isHidden = true
        StartLabel.isHidden = false
        
        dataTable1.tableFooterView = UIView(frame:CGRect.zero)
        dataTable2.tableFooterView = UIView(frame:CGRect.zero)
        dataTable3.tableFooterView = UIView(frame:CGRect.zero)
        dataTable4.tableFooterView = UIView(frame:CGRect.zero)

        populateContactList()
    
   //   code to reset projects if needed for testing
    //    myDatabaseConnection.resetprojects()
        
   //   code to reset meetings if needed for testing        
  //      myDatabaseConnection.resetMeetings()
        
        //   code to reset tasks if needed for testing
  //      myDatabaseConnection.resetTasks()
        
        //   code to reset contexts if needed for testing
    //         myDatabaseConnection.resetContexts()
        
        dataTable1.estimatedRowHeight = 12.0
        dataTable1.rowHeight = UITableViewAutomaticDimension
        dataTable2.estimatedRowHeight = 12.0
        dataTable2.rowHeight = UITableViewAutomaticDimension
        dataTable3.estimatedRowHeight = 12.0
        dataTable3.rowHeight = UITableViewAutomaticDimension
        dataTable4.estimatedRowHeight = 12.0
        dataTable4.rowHeight = UITableViewAutomaticDimension
        
        // Default the buttons
        
        TableTypeButton1.setTitle("Calendar", for: UIControlState())
        itemSelected = "Calendar"
        TableTypeButton2.setTitle("Details", for: UIControlState())
        TableTypeButton3.setTitle("Project Membership", for: UIControlState())
        TableTypeButton4.setTitle("Tasks", for: UIControlState())
       
        TableOptions = Array()

        myEvernote = EvernoteDetails(inSession: self.evernoteSession)
        
        if evernoteSession.isAuthenticated
        {
            getEvernoteUserDetails()
        }

        labelName.text = ""
    
        notificationCenter.addObserver(self, selector: #selector(self.OneNoteNotebookGetSections), name: NotificationOneNoteNotebooksLoaded, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.OneNotePagesReady(_:)), name: NotificationOneNotePagesReady, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.OneNoteNoNotebookFound), name: NotificationOneNoteNoNotebookFound, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.EvernoteComplete), name: NotificationEvernoteComplete, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.myEvernoteUserDidFinish), name: NotificationEvernoteUserDidFinish, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.myGmailDidFinish), name: NotificationGmailDidFinish, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.myHangoutsDidFinish), name: NotificationHangoutsDidFinish, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.gmailSignedIn(_:)), name: NotificationGmailConnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.dropBoxReady), name: NotificationDropBoxReady, object: nil)
        
        myWebView.isHidden = true
        
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
                myCurrentViewController = ViewController()
                myCurrentViewController = self

   //             textExpander.fillDelegate = self
            }
        }
    }

    func timerTest(_ timer:Timer)
    {
        NSLog("trigger")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponentsInPickerView(_ TableTypeSelection1: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ TableTypeSelection1: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TableOptions.count
    }
  
    func pickerView(_ TableTypeSelection1: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return TableOptions[row]
    }

    func pickerView(_ TableTypeSelection1: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        actionSelection()
    }
    
    func actionSelection(){
        itemSelected = TableOptions[TableTypeSelection1.selectedRow(inComponent: 0)]
    }
    
    @IBAction func TableTypeButton1TouchUp(_ sender: UIButton) {
        // Show the Picker and hide the button
   
        let myPanes = displayPanes()
        
        TableOptions.removeAll(keepingCapacity: false)
 
        for myPane in myPanes.listVisiblePanes
        {
            TableOptions.append(myPane.paneName)
        }
        
        TableTypeSelection1.reloadAllComponents()
        
        callingTable = sender.tag
        
        TableTypeSelection1.isHidden = false
        setSelectionButton.isHidden = false

        hideFields()
        
        let myIndex = TableOptions.index(of: getFirstPartofString(sender.currentTitle!))

        TableTypeSelection1.selectRow(myIndex!, inComponent: 0, animated: true)
    }

    @IBAction func setSelectionButtonTouchUp(_ sender: UIButton) {
        
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
                    TableTypeButton1.setTitle(itemSelected, for: UIControlState())
                    TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myFullName), for: UIControlState())
                    setAddButtonState(1)
                    populateArraysForTables("Table1")
            
                case 2:
                    TableTypeButton2.setTitle(itemSelected, for: UIControlState())
                    TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myFullName), for: UIControlState())
                    setAddButtonState(2)
                    populateArraysForTables("Table2")

                case 3:
                    TableTypeButton3.setTitle(itemSelected, for: UIControlState())
                    TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myFullName), for: UIControlState())
                    setAddButtonState(3)
                    populateArraysForTables("Table3")
            
                case 4:
                    TableTypeButton4.setTitle(itemSelected, for: UIControlState())
                    TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myFullName), for: UIControlState())
                    setAddButtonState(4)
                    populateArraysForTables("Table4")
            
                default: break
            
            }
            
            showFields()
            TableTypeSelection1.isHidden = true
            setSelectionButton.isHidden = true
        }
    }
 
    func populateContactList()
    {
        _ = createAddressBook()
        _ = determineAddressBookStatus()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var retVal: Int = 0
        
        if (tableView == dataTable1)
        {
            retVal = self.table1Contents.count 
        }
        else if (tableView == dataTable2)
        {
            retVal = self.table2Contents.count 
        }
        else if (tableView == dataTable3)
        {
            retVal = self.table3Contents.count 
        }
        else if (tableView == dataTable4)
        {
            retVal = self.table4Contents.count 
        }
        return retVal
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        if (tableView == dataTable1)
        {
            let cell = dataTable1.dequeueReusableCell(withIdentifier: CONTACT_CELL_IDENTIFER)! 
            cell.textLabel!.text = table1Contents[indexPath.row].displayText
            return setCellFormatting(cell,inDisplayFormat: table1Contents[indexPath.row].displaySpecialFormat)

        }
        else if (tableView == dataTable2)
        {
            let cell = dataTable2.dequeueReusableCell(withIdentifier: CONTACT_CELL_IDENTIFER)!
            cell.textLabel!.text = table2Contents[indexPath.row].displayText
            return setCellFormatting(cell, inDisplayFormat: table2Contents[indexPath.row].displaySpecialFormat)
        }
        else if (tableView == dataTable3)
        {
            let cell = dataTable3.dequeueReusableCell(withIdentifier: CONTACT_CELL_IDENTIFER)!
            cell.textLabel!.text = table3Contents[indexPath.row].displayText
            return setCellFormatting(cell,inDisplayFormat: table3Contents[indexPath.row].displaySpecialFormat)

        }
        else if (tableView == dataTable4)
        {
            let cell = dataTable4.dequeueReusableCell(withIdentifier: CONTACT_CELL_IDENTIFER)!
            cell.textLabel!.text = table4Contents[indexPath.row].displayText
            return setCellFormatting(cell,inDisplayFormat: table4Contents[indexPath.row].displaySpecialFormat)

        }
        else
        {
            // Dummy statements to allow use of else
            let cell = dataTable3.dequeueReusableCell(withIdentifier: CONTACT_CELL_IDENTIFER)!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {

        if tableView == dataTable1
        {
            dataCellClicked(indexPath.row, table: "Table1", viewClicked: tableView.cellForRow(at: indexPath)!)
        }
        else if tableView == dataTable2
        {
            dataCellClicked(indexPath.row, table: "Table2", viewClicked: tableView.cellForRow(at: indexPath)!)
        }
        else if tableView == dataTable3
        {
            dataCellClicked(indexPath.row, table: "Table3", viewClicked: tableView.cellForRow(at: indexPath)!)
        }
        else if tableView == dataTable4
        {
            dataCellClicked(indexPath.row, table: "Table4", viewClicked: tableView.cellForRow(at: indexPath)!)
        }
        
    }
  
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath)
    {
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = myRowColour
        }
        else
        {
            cell.backgroundColor = UIColor.white
        }
    }
    
    func populateArraysForTables(_ inTable : String)
    {
        
        // work out the table we are populating so we can then use this later
        switch inTable
        {
        case "Table1":
            table1Contents = populateArrayDetails(inTable)
            DispatchQueue.main.async
            {
                self.dataTable1.reloadData()
            }
            
        case "Table2":
            table2Contents = populateArrayDetails(inTable)
            DispatchQueue.main.async
            {
                self.dataTable2.reloadData()
            }
            
        case "Table3":
            table3Contents = populateArrayDetails(inTable)
            DispatchQueue.main.async
            {
                self.dataTable3.reloadData()
            }
            
        case "Table4":
            table4Contents = populateArrayDetails(inTable)
            DispatchQueue.main.async
            {
                self.dataTable4.reloadData()
            }
            
        default:
            print("populateArraysForTables: hit default for some reason")
            
        }
    }
    
    func populateArrayDetails(_ inTable: String) -> [TableData]
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
                print("populateArrayDetails: inTable hit default for some reason")
            
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
                
        let selectedType: String = getFirstPartofString(dataType)
        
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
                    writeRowToArray("Context = \(myContextName)", inTable: &workArray)
                }
                else
                {
                    workArray = personContact.tableData
                }
            case "Calendar":
                eventDetails = iOSCalendar(inEventStore: globalEventStore)

                if myDisplayType == "Project"
                {
                    eventDetails.loadCalendarDetails(mySelectedProject.projectName, teamID: mySelectedProject.teamID)
                }
                else if myDisplayType == "Context"
                {
                    writeRowToArray("No calendar entries found", inTable: &workArray)
                }
                else
                {
                    eventDetails.loadCalendarDetails(personContact.emailAddresses, teamID: myCurrentTeam.teamID)
                }
                workArray = eventDetails.displayEvent()
                
                if workArray.count == 0
                {
                    writeRowToArray("No calendar entries found", inTable: &workArray)
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
                writeRowToArray("Loading Evernote data.  Pane will refresh when finished", inTable: &workArray)
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
                    workArray = displayTeamMembers(mySelectedProject, lookupArray: &projectMemberArray)
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
                    workArray = displayProjectsForPerson(searchString, lookupArray: &projectMemberArray)
                }

            case "Omnifocus":
                writeRowToArray("Loading Omnifocus data.  Pane will refresh when finished", inTable: &workArray)
            
                omniTableToRefresh = inTable
                
                openOmnifocusDropbox()

            case "OneNote":
                writeRowToArray("Loading OneNote data.  Pane will refresh when finished", inTable: &workArray)
            
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
                writeRowToArray("Loading GMail messages.  Pane will refresh when finished", inTable: &workArray)
                
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
            writeRowToArray("Loading Hangout messages.  Pane will refresh when finished", inTable: &workArray)
            
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
            myTaskItems.removeAll(keepingCapacity: false)
            
            var myReturnedData: [Task] = Array()
            if myDisplayType == "Project"
            {
                myReturnedData = myDatabaseConnection.getActiveTasksForProject(mySelectedProject.projectID)
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
                
                let myContext = myDatabaseConnection.getContextByName(searchString)
                
                if myContext.count != 0
                {
                    // Context retrieved
                    
                    // Get the tasks based on the retrieved context ID
                
                    let myTaskContextList = myDatabaseConnection.getTasksForContext(myContext[0].contextID as Int)
                
                    for myTaskContext in myTaskContextList
                    {
                        // Get the context details
                        let myTaskList = myDatabaseConnection.getActiveTask(myTaskContext.taskID as Int)
                    
                        for myTask in myTaskList
                        {  //append project details to work array
                            myReturnedData.append(myTask)
                        }
                    }
                }
            }
            
            // Sort workarray by dueDate, with oldest first
            myReturnedData.sort(by: {$0.dueDate.timeIntervalSinceNow < $1.dueDate.timeIntervalSinceNow})
            
            // Load calendar items array based on return array
            
            for myItem in myReturnedData
            {
                let myTempTask = task(taskID: myItem.taskID as Int)
                
                myTaskItems.append(myTempTask)
            }
            
            workArray = buildTaskDisplay()
            
            if workArray.count == 0
            {
                writeRowToArray("No tasks found", inTable: &workArray)
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
            
            case "DropBox":
                writeRowToArray("Loading DropBox data.  Pane will refresh when finished", inTable: &workArray)
                
                dropBoxClass = dropboxService()
                dropBoxClass.delegate = self
                if myDisplayType == "Context"
                {
                    dropBoxClass.searchString = myContextName
                }
                else
                {
                    dropBoxClass.searchString = personContact.fullName
                }
                dropBoxClass.setup(targetViewController: self)                

            default:
                print("populateArrayDetails: dataType hit default for some reason : \(selectedType)")
        }
        return workArray
    }
    
    func dataCellClicked(_ rowID: Int, table: String, viewClicked: UITableViewCell)
    {
        var dataType: String = ""
        // First we need to work out the type of data in the table, we get this from the button

        // Also depending on which table is clicked, we now need to do a check to make sure the row clicked is a valid task row.  If not then no need to try and edit it

        var myRowContents: String = "'"
        myRowClicked = rowID
        
        switch table
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
                print("dataCellClicked: inTable hit default for some reason")
            
        }
  
        let selectedType: String = getFirstPartofString(dataType)

        switch selectedType
        {
            case "Reminders":
                if myRowContents != "No reminders list found"
                {
                    reBuildTableName = table

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
                    reBuildTableName = table
                    
                    var myEvernoteDataArray = myEvernote.getEvernoteDataArray()
                    
                    let myGuid = myEvernoteDataArray[rowID].identifier
                    let myNoteRef = myEvernoteDataArray[rowID].NoteRef

                    openEvernoteEditView(myGuid, inNoteRef: myNoteRef)
                }

            case "Omnifocus":
                let myOmniUrlPath = omniLinkArray[rowID]
               
                let myOmniUrl: URL = URL(string: myOmniUrlPath)!
                
                if UIApplication.shared.canOpenURL(myOmniUrl) == true
                {
                    UIApplication.shared.open(myOmniUrl, options: [:],
                                              completionHandler: {
                                                (success) in
                                                print("Open myOmniUrl - \(myOmniUrl): \(success)")
                    })
                }
            
            case "Calendar":
                
                let calendarOption: UIAlertController = UIAlertController(title: "Calendar Options", message: "Select action to take", preferredStyle: .actionSheet)

                let edit = UIAlertAction(title: "Edit Meeting", style: .default, handler: { (action: UIAlertAction) -> () in
                    // doing something for "product page
                    let evc = EKEventEditViewController()
                    evc.eventStore = globalEventStore
                    evc.editViewDelegate = self
                    evc.event = self.eventDetails.events[rowID]
                    self.present(evc, animated: true, completion: nil)
                })
                
                let agenda = UIAlertAction(title: "Agenda", style: .default, handler: { (action: UIAlertAction) -> () in
                    // doing something for "product page"
                    self.openMeetings("Agenda", workingTask: self.eventDetails.calendarItems[rowID])
                })
                
                let minutes = UIAlertAction(title: "Minutes", style: .default, handler: { (action: UIAlertAction) -> () in
                    // doing something for "product page"
                    self.openMeetings("Minutes", workingTask: self.eventDetails.calendarItems[rowID])

                })
                
                let personNotes = UIAlertAction(title: "Personal Notes", style: .default, handler: { (action: UIAlertAction) -> () in
                    // doing something for "product page"
                    self.openMeetings("Personal Notes", workingTask: self.eventDetails.calendarItems[rowID])

                })

                var agendaDisplay: Bool = false
                if eventDetails.calendarItems[myRowClicked].startDate.compare(Date()) == ComparisonResult.orderedDescending
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
                    calendarOption.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width / 2.0, y: self.view.bounds.height / 2.0, width: 1.0, height: 1.0)

                    self.present(calendarOption, animated: true, completion: nil)
                }
                calendarTable = table

            case "Project Membership":
                // Project team membership details
                if myDisplayType == "Project"
                {
                    let myPerson = findPersonRecord(projectMemberArray[rowID])
                    loadPerson(myPerson!)
                }
                else
                {
                    loadProject(Int(projectMemberArray[rowID])!, teamID: myCurrentTeam.teamID)
                }
            
        case "OneNote":
            let myOneNoteUrlPath = myOneNoteNotebooks.pages[rowID].urlCallback
  
          //  let myEnUrlPath = stringByChangingChars(myTempPath, " ", "%20")
            let myOneNoteUrl: URL = URL(string: myOneNoteUrlPath)!
            
            if UIApplication.shared.canOpenURL(myOneNoteUrl) == true
            {
                UIApplication.shared.open(myOneNoteUrl, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open myOneNoteUrl - \(myOneNoteUrl): \(success)")})
            }

        case "GMail":
            hideFields()
            
            myWebView.isHidden = false
            btnSendToInbox.isHidden = false
            btnCloseWindow.isHidden = false
            myWorkingGmailMessage = myGmailMessages.messages[rowID]
            myWebView.loadHTMLString(myGmailMessages.messages[rowID].body, baseURL: nil)
  
        case "Hangouts":
            showFields()
            
            myWebView.isHidden = false
            btnSendToInbox.isHidden = false

            btnCloseWindow.isHidden = false
            myWorkingGmailMessage = myHangoutsMessages.messages[rowID]
            myWebView.loadHTMLString(myHangoutsMessages.messages[rowID].body, baseURL: nil)
        
        case "Tasks":
            let myOptions = displayTaskOptions(myTaskItems[rowID], targetTable: table)
            myOptions.popoverPresentationController!.sourceView = viewClicked
            
            self.present(myOptions, animated: true, completion: nil)
            
        default:
            NSLog("Do nothing")
        }
    }
    
    func setButtonTitle(_ inButton: UIButton, inTitle: String) -> String
    {
        var workString: String = ""
        
        let dataType = inButton.currentTitle!
        
        let selectedType: String = getFirstPartofString(dataType)
        
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

    func returnFromSecondaryView(_ inTable: String, inRowID: Int)
    {
        displayScreen()
        populateArraysForTables(inTable)
       // populateArrayDetails(inTable)
    }

    
    func openReminderEditView(_ inReminderID: String, inCalendarName: String)
    {

        let reminderViewControl = self.storyboard!.instantiateViewController(withIdentifier: "Reminders") as! reminderViewController
        
        reminderViewControl.inAction = "Edit"
        reminderViewControl.inReminderID = inReminderID
        reminderViewControl.delegate = self
        reminderViewControl.inCalendarName = inCalendarName
 
        self.present(reminderViewControl, animated: true, completion: nil)
    }
    
    
    func openReminderAddView(_ inCalendarName: String)
    {
        
        let reminderViewControl = self.storyboard!.instantiateViewController(withIdentifier: "Reminders") as! reminderViewController
        
        reminderViewControl.inAction = "Add"
        reminderViewControl.delegate = self
        reminderViewControl.inCalendarName = inCalendarName
        
        self.present(reminderViewControl, animated: true, completion: nil)
    }

    
    func myReminderDidFinish(_ controller:reminderViewController, actionType: String)
    {
        if actionType == "Changed"
        {
            populateArraysForTables(reBuildTableName)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonAddClicked(_ sender: UIButton) {
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
            print("btnAddClicked: tag hit default for some reason")
            
        }
        
        let selectedType: String = getFirstPartofString(dataType)
        
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

                let escapedURL = myOmniUrlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                
                let myOmniUrl: URL = URL(string: escapedURL!)!
                
                if UIApplication.shared.canOpenURL(myOmniUrl) == true
                {
                    UIApplication.shared.open(myOmniUrl, options: [:],
                                              completionHandler: {
                                                (success) in
                                                print("Open myOmniUrl - \(myOmniUrl): \(success)")})
                }
            
            case "Calendar":
                let evc = EKEventEditViewController()
                evc.eventStore = globalEventStore
                evc.editViewDelegate = self
                self.present(evc, animated: true, completion: nil)
          
            case "OneNote":
                var myItemFound: Bool = false
                var myStartPage: String = ""
            
                // First check, if a project does the notebook exist already, or if a person, does the Section in People notebook exist
            
                if myDisplayType == "Project"
                {
                    let alert = UIAlertController(title: "OneNote", message:
                        "Creating OneNote Notebook for this Project.  OneNote will open when complete.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    self.present(alert, animated: false, completion: nil)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                    

                    myItemFound = myOneNoteNotebooks.checkExistenceOfNotebook(mySelectedProject.projectName)
                    if myItemFound
                    {
                        let alert = UIAlertController(title: "OneNote", message:
                            "Notebook already exists for this Project", preferredStyle: UIAlertControllerStyle.alert)
                    
                        self.present(alert, animated: false, completion: nil)
                    
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
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
                        let alert = UIAlertController(title: "OneNote", message:
                            "Creating OneNote Section for this Person.  OneNote will open when complete.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        self.present(alert, animated: false, completion: nil)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                        
                        myItemFound = myOneNoteNotebooks.checkExistenceOfPerson(myFullName)
                        if myItemFound
                        {
                            let alert = UIAlertController(title: "OneNote", message:
                                "Entry already exists for this Person", preferredStyle: UIAlertControllerStyle.alert)
                        
                            self.present(alert, animated: false, completion: nil)
                        
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                        }
                        else
                        {
                            // Create a Section for the Person and add an initial page
                            
                           myStartPage = myOneNoteNotebooks.createNewSectionForPerson(myFullName)
                        }
                    }
                }
            
                let myOneNoteUrlPath = myStartPage
            
                let myOneNoteUrl: URL = URL(string: myOneNoteUrlPath)!
            
                if UIApplication.shared.canOpenURL(myOneNoteUrl) == true
                {
                    UIApplication.shared.open(myOneNoteUrl, options: [:],
                                              completionHandler: {
                                                (success) in
                                                print("Open myOneNoteUrl - \(myOneNoteUrl): \(success)")})
                }
            
            default:
                NSLog("Do nothing")
        }

    }
    
    func myMaintainProjectDidFinish(_ controller:MaintainProjectViewController, actionType: String)
    {
        populateArraysForTables(reBuildTableName)
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func myGTDInboxDidFinish(_ controller:GTDInboxViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func myMaintainContextsDidFinish(_ controller:MaintainContextsViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }

    func setAddButtonState(_ inTable: Int)
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
                
                        buttonAdd1.isHidden = false

                    case "Evernote":
                        buttonAdd1.isHidden = false

                    case "Omnifocus":
                        buttonAdd1.isHidden = false

                    case "Calendar":
                        buttonAdd1.isHidden = false
                    
                    case "OneNote":
                        buttonAdd1.isHidden = false

                    default:
                        buttonAdd1.isHidden = true
                }
            
            case 2:
                selectedType = getFirstPartofString(TableTypeButton2.currentTitle!)

                switch selectedType
                {
                    case "Reminders":
                        buttonAdd2.isHidden = false

                    case "Evernote":
                        buttonAdd2.isHidden = false
                    
                    case "Omnifocus":
                        buttonAdd2.isHidden = false
                    
                    case "Calendar":
                        buttonAdd2.isHidden = false
                    
                    case "OneNote":
                        buttonAdd2.isHidden = false
                    
                    default:
                        buttonAdd2.isHidden = true
                }
            
            case 3:
                selectedType = getFirstPartofString(TableTypeButton3.currentTitle!)

                switch selectedType
                {
                    case "Reminders":
                        buttonAdd3.isHidden = false
                    
                    case "Evernote":
                        buttonAdd3.isHidden = false
                    
                    case "Omnifocus":
                        buttonAdd3.isHidden = false
                    
                    case "Calendar":
                        buttonAdd3.isHidden = false
                    
                    
                    case "OneNote":
                        buttonAdd3.isHidden = false
                    
                    default:
                        buttonAdd3.isHidden = true
                }
            
            case 4:
                selectedType = getFirstPartofString(TableTypeButton4.currentTitle!)

                switch selectedType
                {
                    case "Reminders":
                        buttonAdd4.isHidden = false
                    
                    case "Evernote":
                        buttonAdd4.isHidden = false
                    
                    case "Omnifocus":
                        buttonAdd4.isHidden = false
                    
                    case "Calendar":
                        buttonAdd4.isHidden = false
                
                    
                    case "OneNote":
                        buttonAdd4.isHidden = false
                    
                    default:
                        buttonAdd4.isHidden = true
                }
            
            default: break
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact)
    {
        picker.dismiss(animated: true, completion: nil)
        
        loadPerson(contact)
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController)
    {
        picker.dismiss(animated: true, completion: nil)
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
            print("EvernoteComplete has incorrect table")
        }
    }
    
    func openEvernoteEditView(_ inGUID: String, inNoteRef:ENNoteRef)
    {
        if myEvernoteShard != ""
        {
            let myEnUrlPath = "evernote:///view/\(myEvernoteUserID)/\(myEvernoteShard)/\(inGUID)/\(inGUID)/"

            let myEnUrl: URL = URL(string: myEnUrlPath)!
            
            if UIApplication.shared.canOpenURL(myEnUrl) == true
            {
                UIApplication.shared.open(myEnUrl, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open myEnUrl - \(myEnUrl): \(success)")})
            }
        }
        else
        {
            let alert = UIAlertController(title: "Evernote", message:
                "Unable to load Evernote for this Note", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                handler: nil))
        }
    }

    func openEvernoteAddView(_ inFullName: String)
    {
        // Lets build the date string
        let myDateFormatter = DateFormatter()
        
        let dateFormat = DateFormatter.Style.medium
        let timeFormat = DateFormatter.Style.short
        myDateFormatter.dateStyle = dateFormat
        myDateFormatter.timeStyle = timeFormat
        
        /* Instantiate the event store */
        let myDate = myDateFormatter.string(from: Date())

        
        let myTempPath = "evernote://x-callback-url/new-note?type=text&title=\(inFullName) : \(myDate)"
  
        let myEnUrlPath = stringByChangingChars(myTempPath, inOldChar: " ", inNewChar: "%20")

        let myEnUrl: URL = URL(string: myEnUrlPath)!
        
        if UIApplication.shared.canOpenURL(myEnUrl) == true
        {
            UIApplication.shared.open(myEnUrl, options: [:],
                                      completionHandler: {
                                        (success) in
                                        print("Open myEnUrl - \(myEnUrl): \(success)")})
        }
    }
        
    func myEvernoteUserDidFinish()
    {
        print("Evernote user authenticated")
    }
    
    func openOmnifocusDropbox()
    {
//GRE        dropboxCoreService.delegate = self
        
        let fileName = "OmniOutput.txt"
        
        let dirPaths:[String]? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true) as [String]
        
        let directories:[String] = dirPaths!
        let docsDir = directories[0]
        _ = docsDir + "/" + fileName
        _ = "/EvesCRM/" + fileName
        
     //   dropboxCoreService.listFolders("/")
        
//GRE        dropboxCoreService.loadFile(dropboxPath, targetFile: docsDirDAT)
    }
    
    func myDropboxFileDidLoad(_ fileName: String)
    {
        readOmnifocusFileContents(fileName)
    }
    
    func myDropboxFileLoadFailed(_ error:NSError)
    {
        let alert = UIAlertController(title: "Dropbox", message:
            "Unable to load Dropbox file.  Error = \(error)", preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: false, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
            handler: nil))
    }
    
    func myDropboxFileProgress(_ fileName: String, progress:CGFloat)
    {
print("Dropbox status = \(progress)")
    }
    
//    func myDropboxMetadataLoaded(_ metadata:DBMetadata)
//    {
//        if metadata.contents != nil
//        {
//                for myEntry in metadata.contents
//                {
//        print("Entry = \((myEntry as AnyObject).filename)")
//                }
//        }
//        else
//        {
//print("Nothing found")
//        }
//    }
//    
//    func myDropboxMetadataFailed(_ error:NSError)
//    {
//        let alert = UIAlertController(title: "Dropbox", message:
//            "Unable to load Dropbox directory list.  Error = \(error)", preferredStyle: UIAlertControllerStyle.alert)
//        
//        self.present(alert, animated: false, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
//            handler: nil))
//    }
//    
//    func myDropboxLoadAccountInfo(_ info:DBAccountInfo)
//    {
//        print("Dropbox Account Info = \(info)")
//    }
//
//    func myDropboxLoadAccountInfoFailed(_ error:NSError)
//    {
//        let alert = UIAlertController(title: "Dropbox", message:
//            "Unable to load Dropbox account info.  Error = \(error)", preferredStyle: UIAlertControllerStyle.alert)
//        
//        self.present(alert, animated: false, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
//            handler: nil))
//    }
//
//    func myDropboxFileDidUpload(_ destPath:String, srcPath:String, metadata:DBMetadata)
//    {
//        print("Dropbox Upload = \(destPath), \(srcPath)")
//    }
//
//    func myDropboxFileUploadFailed(_ error:NSError)
//    {
//        let alert = UIAlertController(title: "Dropbox", message:
//            "Unable to upload file to Dropbox.  Error = \(error)", preferredStyle: UIAlertControllerStyle.alert)
//        
//        self.present(alert, animated: false, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
//            handler: nil))
//    }
//
//    func myDropboxUploadProgress(_ progress:CGFloat, destPath:String, srcPath:String)
//    {
//        print("Dropbox upload status = \(progress)")
//    }
//
//    func myDropboxFileLoadRevisions(_ revisions:NSArray, path:String)
//    {
//        print("Dropbox File revision = \(path)")
//    }
//
//    func myDropboxFileLoadRevisionsFailed(_ error:NSError)
//    {
//        let alert = UIAlertController(title: "Dropbox", message:
//            "Unable to load Dropbox file revisions.  Error = \(error)", preferredStyle: UIAlertControllerStyle.alert)
//        
//        self.present(alert, animated: false, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
//            handler: nil))
//    }
//
//    func myDropboxCreateFolder(_ folder:DBMetadata)
//    {
//        print("Dropbox Create folder")
//    }
//
//    func myDropboxCreateFolderFailed(_ error:NSError)
//    {
//        let alert = UIAlertController(title: "Dropbox", message:
//            "Unable to load create Dropbox folder.  Error = \(error)", preferredStyle: UIAlertControllerStyle.alert)
//        
//        self.present(alert, animated: false, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
//            handler: nil))
//    }
//
//    func myDropboxFileDeleted(_ path:String)
//    {
//        print("Dropbox File Deleted = \(path)")
//    }
//
//    func myDropboxFileDeleteFailed(_ error:NSError)
//    {
//        let alert = UIAlertController(title: "Dropbox", message:
//            "Unable to delete Dropbox file.  Error = \(error)", preferredStyle: UIAlertControllerStyle.alert)
//        
//        self.present(alert, animated: false, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
//            handler: nil))
//    }
//
//    func myDropboxFileCopiedLoad(_ fromPath:String, toPath:DBMetadata)
//    {
//        print("Dropbox file copied = \(fromPath)")
//    }
//
//    func myDropboxFileCopyFailed(_ error:NSError)
//    {
//        let alert = UIAlertController(title: "Dropbox", message:
//            "Unable to copy Dropbox file.  Error = \(error)", preferredStyle: UIAlertControllerStyle.alert)
//        
//        self.present(alert, animated: false, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
//            handler: nil))
//    }
//
//    func myDropboxFileMoved(_ fromPath:String, toPath:DBMetadata)
//    {
//        print("Dropbox file moved = \(fromPath)")
//    }
//
//    func myDropboxFileMoveFailed(_ error:NSError)
//    {
//        let alert = UIAlertController(title: "Dropbox", message:
//            "Unable to move Dropbox file.  Error = \(error)", preferredStyle: UIAlertControllerStyle.alert)
//        
//        self.present(alert, animated: false, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
//            handler: nil))
//    }
//
//    func myDropboxFileDidLoadSearch(_ results:NSArray, path:String, keyword:String)
//    {
//        print("Dropbox search = \(path), \(keyword)")
//    }
//
//    func myDropboxFileLoadSearchFailed(_ error:NSError)
//    {
//        let alert = UIAlertController(title: "Dropbox", message:
//            "Unable to search Dropbox.  Error = \(error)", preferredStyle: UIAlertControllerStyle.alert)
//        
//        self.present(alert, animated: false, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
//            handler: nil))
//    }
//    
//    
    func readOmnifocusFileContents(_ inPath: String)
    {
        var myFullName: String = ""
        var workArray: [TableData] = [TableData]()
        var myDisplayString: String = ""
        var myFormatString: String = ""
        let myCalendar = Calendar.current
        var myEndDate: Date
        var myStartDate: Date
        var myModDate: Date
        var myEntryFound: Bool = false
        
        omniLinkArray.removeAll(keepingCapacity: false)
        
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
                if line.lowercased().range(of: myFullName.lowercased()) != nil
                {
                    // need to format the string into the approriate format
                    myEntryFound = true
                    let splitText = line.components(separatedBy: ":::")
                    
                    omniLinkArray.append(splitText[5])

                    myDisplayString = "\(splitText[0])\n"
                    myDisplayString += "Project: \(splitText[1])"
                    myDisplayString += "    Context: \(splitText[2])"
              
                    let myDateFormatter = DateFormatter()
                    
                    if splitText[6] != ""  // Modification date
                    {
                        if splitText[6].lowercased().range(of: " at ") == nil
                        {
                            // Date does not contain at
                            let dateFormat = DateFormatter.Style.full
                            let timeFormat = DateFormatter.Style.medium
                            myDateFormatter.dateStyle = dateFormat
                            myDateFormatter.timeStyle = timeFormat
                            
                            myModDate = myDateFormatter.date(from: splitText[6])!
                        }
                        else
                        {
                            // Date contains at
                            
                            // Only interested in the date part for this piece so lets split the string up and get the date (need to do this as date has word at in it sso not a standard format
                            let splitDate = splitText[6].components(separatedBy: " at ")
                            
                            myDateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                            
                            myModDate = myDateFormatter.date(from: splitDate[0])!
                        }
                        
                        // Work out the comparision date we need to use, so we can flag items not updated in last 2 weeks
                        
                        let myLastUpdateString = myDatabaseConnection.getDecodeValue("Tasks - Days since last update")
                        // This is string value, and is also positive, so need to convert to integer
                        
                        let myLastUpdateValue = 0 - (myLastUpdateString as NSString).integerValue
 
                        let myComparisonDate = myCalendar.date(
                            byAdding: .day,
                            value: myLastUpdateValue,
                            to: Date())!
                        
                        if myModDate.compare(myComparisonDate) == ComparisonResult.orderedAscending
                        {
                            myFormatString = "Purple"
                        }
                    }
                    
                    if splitText[3] != ""  // Start date
                    {
                        myDisplayString += "\nStart: \(splitText[3])"
    
                        if splitText[3].lowercased().range(of: " at ") == nil
                        {
                            // Date does not contain at

                            let dateFormat = DateFormatter.Style.full
                            let timeFormat = DateFormatter.Style.medium
                            myDateFormatter.dateStyle = dateFormat
                            myDateFormatter.timeStyle = timeFormat
                            
                            myStartDate = myDateFormatter.date(from: splitText[3])!
                        }
                        else
                        {
                            // Date contains at

                            // Only interested in the date part for this piece so lets split the string up and get the date (need to do this as date has word at in it sso not a standard format
                            let splitDate = splitText[3].components(separatedBy: " at ")
                        
                            myDateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                        
                            myStartDate = myDateFormatter.date(from: splitDate[0])!
                        }

                        if myStartDate.compare(Date()) == ComparisonResult.orderedDescending
                        {
                            myFormatString = "Gray"
                        }
                    }
                    
                    if splitText[4] != ""  // End date
                    {
                        if splitText[4].lowercased().range(of: " at ") == nil
                        {
                            // Date does not contain at
                            let dateFormat = DateFormatter.Style.full
                            let timeFormat = DateFormatter.Style.medium
                            myDateFormatter.dateStyle = dateFormat
                            myDateFormatter.timeStyle = timeFormat
                            
                            myEndDate = myDateFormatter.date(from: splitText[4])!
                        }
                        else
                        {
                            // Date contains at
                    
                            // Only interested in the date part for this piece so lets split the string up and get the date (need to do this as date has word at in it sso not a standard format
                            let splitDate = splitText[4].components(separatedBy: " at ")
                            
                            myDateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                            
                            myEndDate = myDateFormatter.date(from: splitDate[0])!
                        }
                        
                        myDisplayString += "\nDue: \(splitText[4])"
                        
                        // Work out the comparision dat we need to use, so we can see if the due date is in the next 7 days
                        let myDueDateString = myDatabaseConnection.getDecodeValue("Tasks - Days before due date")
                        // This is string value so need to convert to integer
                        
                        let myDueDateValue = (myDueDateString as NSString).integerValue
                       
                        let myComparisonDate = myCalendar.date(
                            byAdding: .day,
                            value: myDueDateValue,
                            to: Date())!
                        
                        if myEndDate.compare(myComparisonDate) == ComparisonResult.orderedAscending
                        {
                             myFormatString = "Orange"
                        }
                        
                        // Work out the comparision dat we need to use, so we can see if the due date is in the next 7 days
                        let myOverdueDateString = myDatabaseConnection.getDecodeValue("Tasks - Days after due date")
                        // This is string value so need to convert to integer
                        
                        let myOverdueDateValue = (myOverdueDateString as NSString).integerValue
                       
                        let myComparisonDateRed = myCalendar.date(
                            byAdding: .day,
                            value: myOverdueDateValue,
                            to: Date())!
                        
                        if myEndDate.compare(myComparisonDateRed) == ComparisonResult.orderedAscending
                        {
                            myFormatString = "Red"
                        }

                    }
                    
                    if myFormatString == ""
                    {
                        writeRowToArray(myDisplayString, inTable: &workArray)
                    }
                    else
                    {
                        myDisplayString += "\nLast updated: \(splitText[6])"
                        writeRowToArray(myDisplayString, inTable: &workArray, inDisplayFormat: myFormatString)
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
            writeRowToArray("No Omnifocus tasks found", inTable: &workArray)
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
                print("populateArrayDetails: inTable hit default for some reason")
            
        }
    }
    
    func mySettingsDidFinish(_ controller:settingsViewController)
    {
        controller.dismiss(animated: true, completion: nil)
        
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
    
    func openMeetings(_ inType: String, workingTask: myCalendarItem)
    {
        let meetingViewControl = self.storyboard!.instantiateViewController(withIdentifier: "MeetingsTab") as! meetingTabViewController
        
        let myPassedMeeting = MeetingModel()
        myPassedMeeting.actionType = inType
     //   let workingTask = eventDetails.calendarItems[myRowClicked]
        myPassedMeeting.event = workingTask
        myPassedMeeting.delegate = self
        
        meetingViewControl.myPassedMeeting = myPassedMeeting
        
        self.present(meetingViewControl, animated: true, completion: nil)
    }
    
    func myMeetingsAgendaDidFinish(_ controller:meetingAgendaViewController)
    {
        controller.dismiss(animated: true, completion: nil)
        _ = populateArrayDetails(calendarTable)
        
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
            print("myMeetingsDidFinish: myMeetingsDidFinish hit default for some reason")
        }
    }

    func myMeetingsDidFinish(_ controller:meetingsViewController)
    {
        controller.dismiss(animated: true, completion: nil)
        _ = populateArrayDetails(calendarTable)
        
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
            print("myMeetingsDidFinish: myMeetingsDidFinish hit default for some reason")
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
        
        labelName.text = myButtonName
        
        TableOptions.removeAll(keepingCapacity: false)
        
        for myPane in myPanes.listVisiblePanes
        {
            TableOptions.append(myPane.paneName)

            if myPane.paneOrder == 1
            {
                TableTypeButton1.setTitle(myPane.paneName, for: UIControlState())
                TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myButtonName), for: UIControlState())
                itemSelected = myPane.paneName
            }
            
            if myPane.paneOrder == 2
            {
                TableTypeButton2.setTitle(myPane.paneName, for: UIControlState())
                TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myButtonName), for: UIControlState())
            }
            
            if myPane.paneOrder == 3
            {
                TableTypeButton3.setTitle(myPane.paneName, for: UIControlState())
                TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myButtonName), for: UIControlState())
            }
            
            if myPane.paneOrder == 4
            {
                TableTypeButton4.setTitle(myPane.paneName, for: UIControlState())
                TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myButtonName), for: UIControlState())
            }
        }
    }
    
    func getEvernoteUserDetails()
    {
        //Now we are authenticated we can get the used id and shard details
        let myEnUserStore = evernoteSession.userStore
        myEnUserStore?.getUserWithSuccess({
            (findNotesResults) in
            self.myEvernoteShard = (findNotesResults?.shardId)!
            self.myEvernoteUserID = findNotesResults?.id as! Int
            self.EvernoteUserDone = true
            notificationCenter.post(name: NotificationEvernoteUserDidFinish, object: nil)
            }
            , failure: {
                (findNotesError) in
                print("Failure")
                self.EvernoteUserDone = true
                self.myEvernoteShard = ""
                self.myEvernoteUserID = 0
                notificationCenter.post(name: NotificationEvernoteUserDidFinish, object: nil)
        })
    }
    
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction)
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

        controller.dismiss(animated: true, completion: nil)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction)
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

        self.dismiss(animated: true, completion: nil)
    }
    
    func eventEditViewControllerDefaultCalendar(forNewEvents controller: EKEventEditViewController) -> EKCalendar
    {

        return globalEventStore.defaultCalendarForNewEvents
    }

    
    func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser)
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

        self.dismiss(animated: true, completion:nil)
    }

    func OneNoteNotebookGetSections()
    {
        DispatchQueue.global(qos: .userInitiated).async
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
        
        writeRowToArray("No matching OneNote Notebook found", inTable: &myDisplay)
        
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
            print("OneNoteNotebookGetSections: oneNoteTableToRefresh hit default for some reason")
        }
    }
    
    func OneNotePagesReady(_ notification: Notification)
    {
        var myDisplay: [TableData] = Array()

        for myPage in myOneNoteNotebooks.pages
        {
            let dateFormat = DateFormatter.Style.medium
            let timeFormat = DateFormatter.Style.short
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateStyle = dateFormat
            myDateFormatter.timeStyle = timeFormat
            
            let myDate = myDateFormatter.string(from: myPage.lastModifiedTime as Date)

            var myString: String = ""
            
            myString = "\(myPage.title)\n"
            myString += "Last modified : \(myDate)"
            writeRowToArray(myString, inTable: &myDisplay)
        }
        
        if myDisplay.count == 0
        {
            writeRowToArray("No matching OneNote pages found", inTable: &myDisplay)
        }
        
        switch oneNoteTableToRefresh
        {
            case "Table1":
                table1Contents = myDisplay
                DispatchQueue.main.async
                {
                        self.dataTable1.reloadData() // reload table/data or whatever here. However you want.
                }
            
            case "Table2":
                table2Contents = myDisplay
                DispatchQueue.main.async
                {
                        self.dataTable2.reloadData() // reload table/data or whatever here. However you want.
                }
            
            case "Table3":
                table3Contents = myDisplay
                DispatchQueue.main.async
                {
                        self.dataTable3.reloadData() // reload table/data or whatever here. However you want.
                }
            
            case "Table4":
                table4Contents = myDisplay
                
                DispatchQueue.main.async
                {
                    self.dataTable4.reloadData() // reload table/data or whatever here. However you want.
                }
            
            default:
                print("OneNoteNotebookGetSections: oneNoteTableToRefresh hit default for some reason")
        }
    }
    
    func myGmailDidFinish()
    {
        var myDisplay: [TableData] = Array()
        
        if myGmailMessages.messages.count == 0
        {
            writeRowToArray("No matching GMail Messages found", inTable: &myDisplay)
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
            writeRowToArray(myString, inTable: &myDisplay)
        }
        
        if myDisplay.count == 0
        {
            writeRowToArray("No matching Gmail Messages found", inTable: &myDisplay)
        }

        switch gmailTableToRefresh
        {
        case "Table1":
            table1Contents = myDisplay
            DispatchQueue.main.async
                {
                    self.dataTable1.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table2":
            table2Contents = myDisplay
            DispatchQueue.main.async
                {
                    self.dataTable2.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table3":
            table3Contents = myDisplay
            DispatchQueue.main.async
                {
                    self.dataTable3.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table4":
            table4Contents = myDisplay
            
            DispatchQueue.main.async
                {
                    self.dataTable4.reloadData() // reload table/data or whatever here. However you want.
            }
            
        default:
            print("myGmailDidFinish: myGmailDidFinish hit default for some reason")
        }
        
        gmailTableToRefresh = ""
    }
    
    func myHangoutsDidFinish()
    {
        var myDisplay: [TableData] = Array()
        
        if myHangoutsMessages.messages.count == 0
        {
            writeRowToArray("No matching Hangout Messages found", inTable: &myDisplay)
        }
        
        for myMessage in myHangoutsMessages.messages
        {
            var myString: String = ""
            
            myString += "From: \(myMessage.from)\n"
            myString += myMessage.snippet
            writeRowToArray(myString, inTable: &myDisplay)
        }
        
        if myDisplay.count == 0
        {
            writeRowToArray("No matching Hangout Messages found", inTable: &myDisplay)
        }
        
        switch hangoutsTableToRefresh
        {
        case "Table1":
            table1Contents = myDisplay
            DispatchQueue.main.async
            {
                self.dataTable1.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table2":
            table2Contents = myDisplay
            DispatchQueue.main.async
            {
                self.dataTable2.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table3":
            table3Contents = myDisplay
            DispatchQueue.main.async
        {
                    self.dataTable3.reloadData() // reload table/data or whatever here. However you want.
            }
            
        case "Table4":
            table4Contents = myDisplay
            
            DispatchQueue.main.async
            {
                self.dataTable4.reloadData() // reload table/data or whatever here. However you want.
            }
            
        default:
            print("myHangoutsDidFinish: myHangoutsDidFinish hit default for some reason")
        }
        hangoutsTableToRefresh = ""
    }

    
    @IBAction func btnCloseWindowClick(_ sender: UIButton)
    {
        showFields()
        
        myWebView.isHidden = true
        btnSendToInbox.isHidden = true
        btnCloseWindow.isHidden = true
    }
    
    func gmailSignedIn(_ notification: Notification)
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
            DispatchQueue.global(qos: .userInitiated).async
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
            DispatchQueue.global(qos: .userInitiated).async
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
            DispatchQueue.global(qos: .userInitiated).async
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
            DispatchQueue.global(qos: .userInitiated).async
            {
                    self.myHangoutsMessages.getPersonMessages(searchString, emailAddresses: self.personContact.emailAddresses, inMessageType: "Hangouts")
            }
        }
    }
    
    func sideBarDidSelectButtonAtIndex(_ passedItem:menuObject)
    {
        switch passedItem.displayType
        {
            case "Header":
                switch passedItem.displayString
                {
                    case "Planning":
                        let projectViewControl = self.storyboard!.instantiateViewController(withIdentifier: "GTDPlanning") as! MaintainGTDPlanningViewController
                        
                        let myPassedGTD = GTDModel()
                        
                        myPassedGTD.delegate = self
                        myPassedGTD.actionSource = "Project"
                        
                        projectViewControl.passedGTD = myPassedGTD
                        
                        self.present(projectViewControl, animated: true, completion: nil)
 
                    case "Inbox":
                        let GTDInboxViewControl = self.storyboard!.instantiateViewController(withIdentifier: "GTDInbox") as! GTDInboxViewController
                    
                        GTDInboxViewControl.delegate = self
                        
                        self.present(GTDInboxViewControl, animated: true, completion: nil)
                    
                    case "Context":
                        let projectViewControl = self.storyboard!.instantiateViewController(withIdentifier: "GTDPlanning") as! MaintainGTDPlanningViewController
                    
                        let myPassedGTD = GTDModel()
                    
                        myPassedGTD.delegate = self
                        myPassedGTD.actionSource = "Context"
                    
                        projectViewControl.passedGTD = myPassedGTD
                    
                        self.present(projectViewControl, animated: true, completion: nil)
                    
                    default:
                        print("sideBarDidSelectButtonAtIndex Header - Action selector: Hit default")
                }

            
            case "Project" :
                let myProject = passedItem.displayObject as! Projects
                loadProject(myProject.projectID as Int, teamID: myProject.teamID as Int)
            
            case "People":
                if passedItem.displayString == "Address Book"
                {
                    let picker = CNContactPickerViewController()
                
                    picker.delegate = self
                    present(picker, animated: true, completion: nil)
                }
                else
                {
                    let myContext = passedItem.displayObject as! context
                    
                    var myPerson: CNContact!
                    
//                    if myContext.personID > 0
//                    {
//                        myPerson = findPersonRecordByID("\(myContext.personID)")
//                    }
//                    else
//                    {
                        myPerson = findPersonRecord(myContext.name)
 //                   }
                        
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
                        let settingViewControl = self.storyboard!.instantiateViewController(withIdentifier: "Settings") as! settingsViewController
                        settingViewControl.delegate = self
                        settingViewControl.evernoteSession = evernoteSession
 //GRE                       settingViewControl.dropboxCoreService = dropboxCoreService
                        
                        self.present(settingViewControl, animated: true, completion: nil)
                    
                    case "Maintain Display Panes":
                        let maintainPaneViewControl = self.storyboard!.instantiateViewController(withIdentifier: "MaintainPanes") as! MaintainPanesViewController
                        
                        maintainPaneViewControl.delegate = self
                        
                        self.present(maintainPaneViewControl, animated: true, completion: nil)
                    
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
                                myCurrentViewController = ViewController()
                                myCurrentViewController = self

                                //    textExpander.fillDelegate = self
                            }
                            textExpander.getSnippets()
                        }
                    
                    default:
                        print("sideBarDidSelectButtonAtIndex Action - Action selector: Hit default")
                    
                }
            
            case "MaintainContexts":
                let maintainContextViewControl = self.storyboard!.instantiateViewController(withIdentifier: "maintainContexts") as! MaintainContextsViewController
                    
                maintainContextViewControl.delegate = self
                    
                self.present(maintainContextViewControl, animated: true, completion: nil)

            case "Place":
                let myContext = passedItem.displayObject as! context
                loadContext(myContext.name)

            case "Tool":
                let myContext = passedItem.displayObject as! context
                loadContext(myContext.name)

            default:
                print("sideBarDidSelectButtonAtIndex Main: Hit default")
        }
    }
    
    func sideBarWillOpen(_ target: UIView)
    {
        self.view.bringSubview(toFront: target)
    }
    
    func loadProject(_ projectID: Int, teamID: Int)
    {
        TableTypeSelection1.isHidden = true
        setSelectionButton.isHidden = true

        showFields()
        
        myDisplayType = "Project"
        mySelectedProject = project(inProjectID: projectID)
        
        displayScreen()
        
        table1Contents = Array()
        table2Contents = Array()
        table3Contents = Array()
        table4Contents = Array()
        
        DispatchQueue.global(qos: .background).async
        {
            self.populateArraysForTables("Table1")
        }
        
        DispatchQueue.global(qos: .background).async
        {
            self.populateArraysForTables("Table2")
        }
        
        DispatchQueue.global(qos: .background).async
        {
            self.populateArraysForTables("Table3")
        }
        
        DispatchQueue.global(qos: .background).async
        {
            self.populateArraysForTables("Table4")
        }
        
        //populateArraysForTables("Table4")
        
        // Here is where we will set the titles for the buttons
        
        TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: mySelectedProject.projectName), for: UIControlState())
        TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: mySelectedProject.projectName), for: UIControlState())
        TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: mySelectedProject.projectName), for: UIControlState())
        TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: mySelectedProject.projectName), for: UIControlState())
    }
    
    func loadPerson(_ personRecord: CNContact)
    {
        TableTypeSelection1.isHidden = true
        setSelectionButton.isHidden = true
        StartLabel.isHidden = true
        
        showFields()
    
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
    
        TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myFullName), for: UIControlState())
        TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myFullName), for: UIControlState())
        TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myFullName), for: UIControlState())
        TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myFullName), for: UIControlState())
    }
    
    func loadContext(_ inContext: String)
    {
        TableTypeSelection1.isHidden = true
        setSelectionButton.isHidden = true
        
        showFields()
        
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
        
        TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myFullName), for: UIControlState())
        TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myFullName), for: UIControlState())
        TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myFullName), for: UIControlState())
        TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myFullName), for: UIControlState())
    }

    func MaintainPanesDidFinish(_ controller:MaintainPanesViewController)
    {
        controller.dismiss(animated: true, completion: nil)
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
            
            if event.startDate.compare(Date()) == ComparisonResult.orderedAscending
            {
                // Event is in the past
                writeRowToArray(myString, inTable: &tableContents, inDisplayFormat: "Gray")
            }
            else
            {
                writeRowToArray(myString, inTable: &tableContents)
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
            
            let myData = myDatabaseConnection.getProjectDetails(myTask.projectID)
            
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
            writeRowToArray(myString, inTable: &tableContents)
        }
        return tableContents
    }
    
    func myGTDPlanningDidFinish(_ controller:MaintainGTDPlanningViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func displayTaskOptions(_ workingTask: task, targetTable: String) -> UIAlertController
    {
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .actionSheet)
        
        let myOption1 = UIAlertAction(title: "Edit Action", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "tasks") as! taskViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: 0,y: 0,width: 700,height: 700)
            
            popoverContent.passedTask = workingTask
            
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        let myOption2 = UIAlertAction(title: "Action Updates", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "taskUpdate") as! taskUpdatesViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: 0,y: 0,width: 700,height: 700)
            
            popoverContent.passedTask = workingTask
            
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        let myOption3 = UIAlertAction(title: "Defer: 1 Hour", style: .default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = Calendar.current
                
            let newTime = myCalendar.date(
                byAdding: .hour,
                value: 1,
                to: Date())!

            workingTask.startDate = newTime
            
            switch targetTable
            {
                case "Table1":
                    self.table1Contents = Array()
                    self.populateArraysForTables("Table1")
                
                case "Table2":
                    self.table2Contents = Array()
                    self.populateArraysForTables("Table2")
                
                case "Table3":
                    self.table3Contents = Array()
                    self.populateArraysForTables("Table3")
                
                case "Table4":
                    self.table4Contents = Array()
                    self.populateArraysForTables("Table4")
                
                default:
                    print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption4 = UIAlertAction(title: "Defer: 4 Hours", style: .default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = Calendar.current
                
            let newTime = myCalendar.date(
                byAdding: .hour,
                value: 4,
                to: Date())!

            workingTask.startDate = newTime
            
            switch targetTable
            {
                case "Table1":
                    self.table1Contents = Array()
                    self.populateArraysForTables("Table1")
                
                case "Table2":
                    self.table2Contents = Array()
                    self.populateArraysForTables("Table2")
                
                case "Table3":
                    self.table3Contents = Array()
                    self.populateArraysForTables("Table3")
                
                case "Table4":
                    self.table4Contents = Array()
                    self.populateArraysForTables("Table4")
                
                default:print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption5 = UIAlertAction(title: "Defer: 1 Day", style: .default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = Calendar.current
                
            let newTime = myCalendar.date(
                byAdding: .day,
                value: 1,
                to: Date())!

            workingTask.startDate = newTime
            
            switch targetTable
            {
                case "Table1":
                    self.table1Contents = Array()
                    self.populateArraysForTables("Table1")
                
                case "Table2":
                    self.table2Contents = Array()
                    self.populateArraysForTables("Table2")
                
                case "Table3":
                    self.table3Contents = Array()
                    self.populateArraysForTables("Table3")
                
                case "Table4":
                    self.table4Contents = Array()
                    self.populateArraysForTables("Table4")
                
                default:print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption6 = UIAlertAction(title: "Defer: 1 Week", style: .default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = Calendar.current
                
            let newTime = myCalendar.date(
                byAdding: .day,
                value: 7,
                to: Date())!

            workingTask.startDate = newTime
            
            switch targetTable
            {
                case "Table1":
                    self.table1Contents = Array()
                    self.populateArraysForTables("Table1")
                
                case "Table2":
                    self.table2Contents = Array()
                    self.populateArraysForTables("Table2")
                
                case "Table3":
                    self.table3Contents = Array()
                    self.populateArraysForTables("Table3")
                
                case "Table4":
                    self.table4Contents = Array()
                    self.populateArraysForTables("Table4")
                
                default:print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption7 = UIAlertAction(title: "Defer: 1 Month", style: .default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = Calendar.current
                
            let newTime = myCalendar.date(
                byAdding: .month,
                value: 1,
                to: Date())!

            workingTask.startDate = newTime
            
            switch targetTable
            {
                case "Table1":
                    self.table1Contents = Array()
                    self.populateArraysForTables("Table1")
                
                case "Table2":
                    self.table2Contents = Array()
                    self.populateArraysForTables("Table2")
                
                case "Table3":
                    self.table3Contents = Array()
                    self.populateArraysForTables("Table3")
                
                case "Table4":
                    self.table4Contents = Array()
                    self.populateArraysForTables("Table4")
                
                default:print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption8 = UIAlertAction(title: "Defer: 1 Year", style: .default, handler: { (action: UIAlertAction) -> () in
            let myCalendar = Calendar.current
                
            let newTime = myCalendar.date(
                byAdding: .year,
                value: 1,
                to: Date())!

            workingTask.startDate = newTime
            
            switch targetTable
            {
                case "Table1":
                    self.table1Contents = Array()
                    self.populateArraysForTables("Table1")
                
                case "Table2":
                    self.table2Contents = Array()
                    self.populateArraysForTables("Table2")
                
                case "Table3":
                    self.table3Contents = Array()
                    self.populateArraysForTables("Table3")
                
                case "Table4":
                    self.table4Contents = Array()
                    self.populateArraysForTables("Table4")
                
                default:print("displayTaskOptions: inTable hit default for some reason")
            }
        })
        
        let myOption9 = UIAlertAction(title: "Defer: Custom", style: .default, handler: { (action: UIAlertAction) -> () in
            if workingTask.displayStartDate == ""
            {
                self.myDatePicker.date = Date()
            }
            else
            {
                self.myDatePicker.date = workingTask.startDate as Date
            }
            
            self.myDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
            self.hideFields()
            self.myDatePicker.isHidden = false
            self.btnSetStartDate.isHidden = false
            self.myWorkingTask = workingTask
            self.myWorkingTable = targetTable
        })
        
        let myOption10 = UIAlertAction(title: "Delete Action", style: .default, handler: { (action: UIAlertAction) -> () in
            _ = workingTask.delete()
            
            switch targetTable
            {
                case "Table1":
                    self.table1Contents = Array()
                    self.populateArraysForTables("Table1")
                
                case "Table2":
                    self.table2Contents = Array()
                    self.populateArraysForTables("Table2")
                
                case "Table3":
                    self.table3Contents = Array()
                    self.populateArraysForTables("Table3")
                
                case "Table4":
                    self.table4Contents = Array()
                    self.populateArraysForTables("Table4")
                
                default:print("displayTaskOptions - option 10: inTable hit default for some reason")
            }

        })
        
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        myOptions.addAction(myOption3)
        myOptions.addAction(myOption4)
        myOptions.addAction(myOption5)
        myOptions.addAction(myOption6)
        myOptions.addAction(myOption7)
        myOptions.addAction(myOption8)
        myOptions.addAction(myOption9)
        myOptions.addAction(myOption10)
        
        return myOptions
    }
    
    func showFields()
    {
        TableTypeSelection1.isHidden = true
        setSelectionButton.isHidden = true
        TableTypeButton1.isHidden = false
        TableTypeButton2.isHidden = false
        TableTypeButton3.isHidden = false
        TableTypeButton4.isHidden = false
        dataTable1.isHidden = false
        dataTable2.isHidden = false
        dataTable3.isHidden = false
        dataTable4.isHidden = false
    }
    
    func hideFields()
    {
        TableTypeButton1.isHidden = true
        TableTypeButton2.isHidden = true
        TableTypeButton3.isHidden = true
        TableTypeButton4.isHidden = true
        dataTable1.isHidden = true
        dataTable2.isHidden = true
        dataTable3.isHidden = true
        dataTable4.isHidden = true
        StartLabel.isHidden = true
        btnCloseWindow.isHidden = true
        btnSendToInbox.isHidden = true
        myDatePicker.isHidden = true
        btnSetStartDate.isHidden = true
    }
    
    @IBAction func btnSetStartDate(_ sender: UIButton)
    {
        myWorkingTask.startDate = myDatePicker.date
        myDatePicker.isHidden = true
        btnSetStartDate.isHidden = true
        
        switch myWorkingTable
        {
            case "Table1":
                table1Contents = Array()
                populateArraysForTables("Table1")
            
            case "Table2":
                table2Contents = Array()
                populateArraysForTables("Table2")
            
            case "Table3":
                table3Contents = Array()
                populateArraysForTables("Table3")
            
            case "Table4":
                table4Contents = Array()
                populateArraysForTables("Table4")
            
            default:print("displayTaskOptions: inTable hit default for some reason")
        }
        showFields()
    }
    
    @IBAction func btnSendToInbox(_ sender: UIButton)
    {
        let newTask = task(inTeamID: myCurrentTeam.teamID)
        newTask.title = myWorkingGmailMessage.subject

        var myBody: String = "From : \(myWorkingGmailMessage.from)"
        myBody += "\n"
        myBody += "Date received : \(myWorkingGmailMessage.dateReceived)"
        myBody += "\n\n\n"

        let plainBody = myWorkingGmailMessage.body.html2String
        
        myBody += plainBody
        
        newTask.details = myBody
        
        myDatabaseConnection.saveProcessedEmail(myWorkingGmailMessage.id, emailType: "GMail", processedDate: Date())
        NSLog("need something here to do the context")
        

    }
    
    func dropBoxReady()
    {
        dropBoxClass.searchFiles("")
    }
    
    func displayResults(sourceService: String, resultsArray: [TableData])
    {
        // Look through the available pans to fins the one that matches the returned service
        if TableTypeButton1.currentTitle == sourceService
        {
            table1Contents = resultsArray
            dataTable1.reloadData()
        }
        else if TableTypeButton2.currentTitle == sourceService
        {
            table2Contents = resultsArray
            dataTable2.reloadData()
        }
        else if TableTypeButton3.currentTitle == sourceService
        {
            table3Contents = resultsArray
            dataTable3.reloadData()
        }
        else //if TableTypeButton4.currentTitle == sourceService
        {
            table4Contents = resultsArray
            dataTable4.reloadData()
        }
    }
}
