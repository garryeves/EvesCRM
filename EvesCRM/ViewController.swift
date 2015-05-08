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
import CoreData


//import "ENSDK/Headers/ENSDK.h"

// PeoplePicker code

private let CONTACT_CELL_IDENTIFER = "contactNameCell"
private let dataTable1_CELL_IDENTIFER = "dataTable1Cell"

var dropboxCoreService: DropboxCoreService = DropboxCoreService()

class ViewController: UIViewController, MyReminderDelegate, ABPeoplePickerNavigationControllerDelegate, MyMaintainProjectDelegate, MyDropboxCoreDelegate {
    
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
    
    @IBOutlet weak var peoplePickerButton: UIButton!
    var TableOptions = ["Calendar", "Details", "Evernote", "Omnifocus", "Project Membership", "Reminders"]
    
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
    var EvernoteTimer = NSTimer()
    var EvernoteTargetTable: String = "'"
    var EvernoteTimerCount: Int = 0
    var myEvernoteShard: String = ""
    var myEvernoteUserID: Int = 0
    var myEvernoteUserTimer = NSTimer()
    var EvernoteUserDone: Bool = false
    var EvernoteAuthenticationDone: Bool = false
    var EvernoteUserTimerCount: Int = 0
    var myEvernoteGUID: String = ""
    var myDisplayType: String = ""
    var myProjectID: NSNumber!
    var myProjectName: String = ""
    var omniTableToRefresh: String = ""
    var omniLinkArray: [String] = Array()
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var document: MyDocument?
    var documentURL: NSURL?
    var ubiquityURL: NSURL?
    var metaDataQuery: NSMetadataQuery?
    
    var dropboxConnected: Bool = false
    
    var dbRestClient: DBRestClient?
    
    // Peoplepicker settings
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        connectToEvernote()
        
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
                    dataTable1.reloadData()
            
                case 2:
                    TableTypeButton2.setTitle(itemSelected, forState: .Normal)
                    TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myFullName), forState: .Normal)
                    setAddButtonState(2)
                    populateArraysForTables("Table2")
                    dataTable2.reloadData()

                case 3:
                    TableTypeButton3.setTitle(itemSelected, forState: .Normal)
                    TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myFullName), forState: .Normal)
                    setAddButtonState(3)
                    populateArraysForTables("Table3")
                    dataTable3.reloadData()
            
                case 4:
                    TableTypeButton4.setTitle(itemSelected, forState: .Normal)
                    TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myFullName), forState: .Normal)
                    
                    setAddButtonState(4)
                    populateArraysForTables("Table4")
                    dataTable4.reloadData()

            
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
    
    
    func connectToEvernote()
    {
        // Authenticate to Evernote if needed
    
        if !evernotePass1
        {
            evernoteSession.authenticateWithViewController (self, preferRegistration:false, completion: {
                (error: NSError?) in
                if error != nil
                {
                    // authentication failed
                    // show an alert, etc
                    // ...
                }
                else
                {
                    // authentication succeeded
                    // do something now that we're authenticated
                    // ...
                    self.myEvernote = EvernoteDetails(inSession: self.evernoteSession)
                }
                self.EvernoteAuthenticationDone = true
            })
        }
        
        myEvernoteUserTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("myEvernoteAuthenticationDidFinish"), userInfo: nil, repeats: false)

        evernotePass1 = true  // This is to allow only one attempt to launch Evernote
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

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {

        var retVal: CGFloat = 0.0
    
        if (tableView == dataTable1)
        {
            let cell = dataTable1.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            let titleText = table1Contents[indexPath.row].displayText
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        if (tableView == dataTable2)
        {
            let cell = dataTable2.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            let titleText = table2Contents[indexPath.row].displayText
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        if (tableView == dataTable3)
        {
            let cell = dataTable3.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            let titleText = table3Contents[indexPath.row].displayText
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        if (tableView == dataTable4)
        {
            let cell = dataTable4.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            let titleText = table4Contents[indexPath.row].displayText
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        
        return retVal + 36.0
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
            return setCellFormatting(cell,inDisplayFormat: table1Contents[indexPath.row].displaySpecialFormat)

        }
        else if (tableView == dataTable2)
        {
            let cell = dataTable2.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table2Contents[indexPath.row].displayText
            
            return setCellFormatting(cell,inDisplayFormat: table2Contents[indexPath.row].displaySpecialFormat)
        }
        else if (tableView == dataTable3)
        {
            let cell = dataTable3.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table3Contents[indexPath.row].displayText
            return setCellFormatting(cell,inDisplayFormat: table3Contents[indexPath.row].displaySpecialFormat)

        }
        else if (tableView == dataTable4)
        {
            let cell = dataTable4.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table4Contents[indexPath.row].displayText
            return setCellFormatting(cell,inDisplayFormat: table4Contents[indexPath.row].displaySpecialFormat)

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
  
    func populateArraysForTables(inTable : String)
    {
        
        // work out the table we are populating so we can then use this later
        switch inTable
        {
        case "Table1":
            table1Contents = populateArrayDetails(inTable)
            
        case "Table2":
            table2Contents = populateArrayDetails(inTable)
            
        case "Table3":
            table3Contents = populateArrayDetails(inTable)
            
        case "Table4":
            table4Contents = populateArrayDetails(inTable)
            
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
        
        var selectedType: String = getFirstPartofString(dataType)
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
                   workArray = parseCalendarDetails("Calendar", myProjectName, eventStore)                   }
                else
                {
                    workArray = parseCalendarDetails("Calendar",personSelected, eventStore)
                }
            case "Reminders":
                if myDisplayType == "Project"
                {
                    workArray = parseCalendarDetails("Reminders", myProjectName, eventStore)
                }
                else
                {
                    workArray = parseCalendarDetails("Reminders", personSelected, eventStore)
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
                EvernoteTimerCount = 0
                EvernoteTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("EvernoteComplete"), userInfo: nil, repeats: false)
            
            case "Project Membership":
                // Project team membership details
                if myDisplayType == "Project"
                {
                    workArray = displayTeamMembers(myProjectID)
                }
                else
                {
                    let searchString = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                    workArray = displayProjectsForPerson(searchString)
                }

            case "Omnifocus":
                writeRowToArray("Loading Omnifocus data.  Pane will refresh when finished", &workArray)
            
                omniTableToRefresh = inTable
                
                openOmnifocusDropbox()
            
            case "Mail":
                let a = 1
            
            default:
                println("populateArrayDetails: dataType hit default for some reason : \(selectedType)")
        }
        return workArray
    }
    
    func reloadDataTables()
    {
        dataTable1.reloadData()
        dataTable2.reloadData()
        dataTable3.reloadData()
        dataTable4.reloadData()
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
            
            default:
                workString = inButton.currentTitle!
        }
        
        setAddButtonState(inButton.tag)
        
        return workString
    }

    func returnFromSecondaryView(inTable: String, inRowID: Int)
    {
        populateArrayDetails(inTable)
        reloadDataTables()
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
            reloadDataTables()
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
            reloadDataTables()
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func myMaintainProjectSelect(controller:MaintainProjectViewController, projectID: NSNumber, projectName: String){
    
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
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        table1Contents = Array()
        table2Contents = Array()
        table3Contents = Array()
        table4Contents = Array()
        
        populateArraysForTables("Table1")
        populateArraysForTables("Table2")
        populateArraysForTables("Table3")
        populateArraysForTables("Table4")
        
        reloadDataTables()
        
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
        
        personSelected = person as ABRecord
        
        table1Contents = Array()
        table2Contents = Array()
        table3Contents = Array()
        table4Contents = Array()
        
        populateArraysForTables("Table1")
        populateArraysForTables("Table2")
        populateArraysForTables("Table3")
        populateArraysForTables("Table4")
        
        reloadDataTables()
        
        // Here is where we will set the titles for the buttons
        
        let myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
        
        TableTypeButton1.setTitle(setButtonTitle(TableTypeButton1, inTitle: myFullName), forState: .Normal)
        TableTypeButton2.setTitle(setButtonTitle(TableTypeButton2, inTitle: myFullName), forState: .Normal)
        TableTypeButton3.setTitle(setButtonTitle(TableTypeButton3, inTitle: myFullName), forState: .Normal)
        TableTypeButton4.setTitle(setButtonTitle(TableTypeButton4, inTitle: myFullName), forState: .Normal)
    }

/*
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, shouldContinueAfterSelectingPerson person: ABRecordRef!) -> Bool {
    
    //peoplePickerNavigationController(peoplePicker, didSelectPerson: person)
    println("George")
        
    peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    
    return false;
    }

*/

    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!)
    {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    }

    func EvernoteComplete()
    {
        var myTable: [TableData] = Array()

        if !myEvernote.isAsyncDone()
        {  // Async not yet complete
            if EvernoteTimerCount > 5
            {
                    writeRowToArray("Unable to retrieve Evernote data in timely manner", &myTable)
            }
            else
            {
                EvernoteTimerCount = EvernoteTimerCount + 1
                EvernoteTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("EvernoteComplete"), userInfo: nil, repeats: false)
            }
        }
        else
        {
            myTable = myEvernote.getWriteString()
        }
        
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
        
    func myEvernoteAuthenticationDidFinish()
    {
        if !EvernoteAuthenticationDone
        {  // Async not yet complete
            if EvernoteUserTimerCount > 5
            {
                var alert = UIAlertController(title: "Evernote", message:
                    "Unable to load Evernote in a timely manner", preferredStyle: UIAlertControllerStyle.Alert)
                
                self.presentViewController(alert, animated: false, completion: nil)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                    handler: nil))
            }
            else
            {
                EvernoteUserTimerCount = EvernoteUserTimerCount + 1
                myEvernoteUserTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("myEvernoteAuthenticationDidFinish"), userInfo: nil, repeats: false)
            }
        }
        else
        {
            //Now we are authenticated we can get the used id and shard details
            let myEnUserStore = evernoteSession.userStore
            myEnUserStore.getUserWithSuccess({
            (findNotesResults) in
            self.myEvernoteShard = findNotesResults.shardId
            self.myEvernoteUserID = findNotesResults.id as Int
            self.EvernoteUserDone = true
            }
            , failure: {
            (findNotesError) in
            println("Failure")
            self.EvernoteUserDone = true
            self.myEvernoteShard = ""
            self.myEvernoteUserID = 0
            })
            
            EvernoteUserTimerCount = 0
            
            myEvernoteUserTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("myEvernoteUserDidFinish"), userInfo: nil, repeats: false)
        }
    }
    
    func myEvernoteUserDidFinish()
    {
        if !EvernoteUserDone
        {  // Async not yet complete
            if EvernoteUserTimerCount > 5
            {
                var alert = UIAlertController(title: "Evernote", message:
                    "Unable to load Evernote in a timely manner", preferredStyle: UIAlertControllerStyle.Alert)
                
                self.presentViewController(alert, animated: false, completion: nil)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                    handler: nil))
            }
            else
            {
                EvernoteUserTimerCount = EvernoteUserTimerCount + 1
                myEvernoteUserTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("myEvernoteUserDidFinish"), userInfo: nil, repeats: false)
            }
        }
    }

    func connectToDropbox()
    {   
        if !dropboxCoreService.isAlreadyInitialised()
        {
            dropboxCoreService.initiateAuthentication(self)
            dropboxConnected = true
        }
    }
    
    func openOmnifocusDropbox()
    {
        dropboxCoreService.delegate = self
        connectToDropbox()  // GRE move to button once we have one
        
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
                    
                    let splitText = line.componentsSeparatedByString(":::")
                    
                    omniLinkArray.append(splitText[5])
                    
                    myDisplayString = "\(splitText[0])\n"
                    myDisplayString += "Project: \(splitText[1])"
                    myDisplayString += "    Context: \(splitText[2])\n"
              
                    if splitText[3] != " "
                    {
                        myDisplayString += "Start: \(splitText[3])    "
                    }
                    if splitText[4] != " "
                    {
                        myDisplayString += "Due: \(splitText[4])"
                    }
                    
                    writeRowToArray(myDisplayString, &workArray)
                }
            }
            // You can close the underlying file explicitly. Otherwise it will be
            // closed when the reader is deallocated.
            aStreamReader.close()
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
}