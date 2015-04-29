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

// PeoplePicker code

private let CONTACT_CELL_IDENTIFER = "contactNameCell"
private let dataTable1_CELL_IDENTIFER = "dataTable1Cell"

class ViewController: UIViewController, MyReminderDelegate, ABPeoplePickerNavigationControllerDelegate {
    
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
    
    @IBOutlet weak var peoplePickerButton: UIButton!
    var TableOptions = ["Details", "Calendar", "Omnifocus", "Evernote", "Mail", "Twitter", "Facebook", "LinkedIn", "Reminders"]
    
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
        
        dataTable1.tableFooterView = UIView(frame:CGRectZero)
        dataTable2.tableFooterView = UIView(frame:CGRectZero)
        dataTable3.tableFooterView = UIView(frame:CGRectZero)
        dataTable4.tableFooterView = UIView(frame:CGRectZero)

        populateContactList()
        
        let picker = ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        presentViewController(picker, animated: true, completion: nil)
        
        
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
    }

    @IBAction func setSelectionButtonTouchUp(sender: UIButton) {
        
        if itemSelected == ""
        {
            // do nothing
        }
        else
        {
            switch callingTable
            {
                case 1: TableTypeButton1.setTitle(itemSelected, forState: .Normal )
            
                case 2: TableTypeButton2.setTitle(itemSelected, forState: .Normal )
            
                case 3: TableTypeButton3.setTitle(itemSelected, forState: .Normal )
            
                case 4: TableTypeButton4.setTitle(itemSelected, forState: .Normal )
            
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

            setAddButtonState(callingTable, inTitle: itemSelected)

            populateArraysForTables("Table1")
            populateArraysForTables("Table2")
            populateArraysForTables("Table3")
            populateArraysForTables("Table4")
            
            reloadDataTables()
            
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
                workArray = parseContactDetails(personSelected)
            case "Calendar":
                workArray = parseCalendarDetails("Calendar",personSelected, eventStore)
            case "Reminders":
                workArray = parseCalendarDetails("Reminders",personSelected, eventStore)
            
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


        var myTaskFound = true
        
        switch inTable
        {
            case "Table1":
                dataType = TableTypeButton1.currentTitle!
                if table1Contents[rowID].displayText == "No reminders list found"
                {
                    myTaskFound = false
                }

            case "Table2":
                dataType = TableTypeButton2.currentTitle!
                if table2Contents[rowID].displayText == "No reminders list found"
                {
                    myTaskFound = false
            }
            
            case "Table3":
                dataType = TableTypeButton3.currentTitle!
                if table3Contents[rowID].displayText == "No reminders list found"
                {
                    myTaskFound = false
            }
            
            case "Table4":
                dataType = TableTypeButton4.currentTitle!
                if table4Contents[rowID].displayText == "No reminders list found"
                {
                    myTaskFound = false
            }

            default:
                println("dataCellClicked: inTable hit default for some reason")
            
        }
  
        if myTaskFound
        {
            var selectedType: String = getFirstPartofString(dataType)

            switch selectedType
            {
                case "Reminders":
                
                    reBuildTableName = inTable

                    let myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
                    openReminderEditView(inRecord.calendarItemIdentifier, inCalendarName: myFullName)
                
            default:
                let a = 1
            }
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
                workString = "Reminders - use List '\(inTitle)'"
            
            default:
                workString = inButton.currentTitle!
        }
        
        setAddButtonState(inButton.tag, inTitle: workString)
        
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
            let myFullName = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
            openReminderAddView(myFullName)
            
        default:
            let a = 1
        }

    }
    
    func setAddButtonState(inTable: Int, inTitle: String)
    {
        // Hide all of the buttons
        // Decide which buttons to show
        
        var selectedType: String = getFirstPartofString(inTitle)

        switch inTable
        {
            case 1:
                switch selectedType
                {
                case "Reminders":
                    buttonAdd1.hidden = false
                
                default:
                    buttonAdd1.hidden = true
                }

            case 2:
                switch selectedType
                {
                    case "Reminders":
                        buttonAdd2.hidden = false
                
                    default:
                        buttonAdd2.hidden = true
                }
            
            case 3:
                switch selectedType
                {
                case "Reminders":
                    buttonAdd3.hidden = false
                
                default:
                    buttonAdd3.hidden = true

                }
            
            case 4:
                switch selectedType
                {
                    case "Reminders":
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

}

