//
//  ViewController.swift
//  EvesCRM
//
//  Created by Garry Eves on 15/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import AddressBook
import EventKit

private let CONTACT_CELL_IDENTIFER = "contactNameCell"
private let dataTable1_CELL_IDENTIFER = "dataTable1Cell"

class ViewController: UIViewController {

    @IBOutlet weak var peopleTable: UITableView!
    
    @IBOutlet weak var TableTypeSelection1: UIPickerView!
    
    // setup grid header buttons
    @IBOutlet weak var TableTypeButton1: UIButton!
    @IBOutlet weak var TableTypeButton2: UIButton!
    @IBOutlet weak var TableTypeButton3: UIButton!
    @IBOutlet weak var TableTypeButton4: UIButton!
    
    
    // Setup data tables for initial values
    @IBOutlet weak var dataTable1: UITableView!
    @IBOutlet weak var dataTable2: UITableView!
    @IBOutlet weak var dataTable3: UITableView!
    @IBOutlet weak var dataTable4: UITableView!
    
    @IBOutlet weak var StartLabel: UILabel!
    
    @IBOutlet weak var setSelectionButton: UIButton!
    
    var TableOptions = ["Contact Details", "Calendar", "Omnifocus", "Evernote", "Mail", "Twitter", "Facebook", "LinkedIn", "Reminders"]
    
    // Store the tag number of the button pressed so that we can make sure we update the correct button text and table
    var callingTable = 0
    
    // Default for the table type selected
    var itemSelected = "Contact Details"
    
    // Define array to hold the contact names
    
    var contacts:[String]?
    var contactDetails:[ABRecord]?
    var headerRows:[Int]?
    
    // define arrasy to store the table displays
    
    var table1Contents:[String] = [""]
    var table2Contents:[String] = [""]
    var table3Contents:[String] = [""]
    var table4Contents:[String] = [""]
    
    // store the name of the person selected in the People table
    var personSelected = ""
    var personSelectedIndex: Int = 0
    var table1SelectedIndex: Int = 0
    var table2SelectedIndex: Int = 0
    var table3SelectedIndex: Int = 0
    var table4SelectedIndex: Int = 0
    
    var adbk : ABAddressBook!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Setup for calendar access
        // 1
        let eventStore = EKEventStore()
        
        // 2
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
        self.peopleTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: CONTACT_CELL_IDENTIFER)
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
        
        peopleTable.hidden = false

        populateContactList()
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
        
        peopleTable.hidden = true
    
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
            peopleTable.hidden = false
            dataTable1.hidden = false
            dataTable2.hidden = false
            dataTable3.hidden = false
            dataTable4.hidden = false
            StartLabel.hidden = true
            
            populateArraysForTables(personSelectedIndex, inTable: "Table1")
            populateArraysForTables(personSelectedIndex, inTable: "Table2")
            populateArraysForTables(personSelectedIndex, inTable: "Table3")
            populateArraysForTables(personSelectedIndex, inTable: "Table4")
            
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
    
    func getContactNames()
    {
        var errorRef: Unmanaged<CFError>?
        
        contacts=Array()
        contactDetails=Array()
        headerRows=Array()
        
        var addressBook: ABAddressBookRef! = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))

        var sources: NSArray = ABAddressBookCopyArrayOfAllSources(addressBook).takeRetainedValue()
        
        for source in sources
        {
            
         //   source.
            var dummyTitle: String = (ABRecordCopyValue(source, kABSourceNameProperty).takeRetainedValue() as! String)
            
            switch dummyTitle
            {
                case "Card" : dummyTitle = "iCloud"
                
                case "Address Book" : dummyTitle = "Google"
                
                default : dummyTitle = "Unknown"
            }
            
            contacts!.append(dummyTitle)
            let dummyRecord: ABRecordRef = "Title" as ABRecordRef
            contactDetails!.append(dummyRecord)
            headerRows!.append(contacts!.count)
            
            var contactList = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, ABPersonSortOrdering(kABPersonSortByLastName)).takeRetainedValue() as [ABRecordRef]
            
            
            for record:ABRecordRef in contactList {
                var contactName: String = ABRecordCopyCompositeName(record).takeRetainedValue() as String
                
                contacts!.append(contactName)
                contactDetails!.append(record)
            }
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
        getContactNames()
        
        peopleTable.reloadData()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {

        var retVal: CGFloat = 0.0
    
        
        if (tableView == peopleTable)
        {
            let cell = peopleTable.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            
            let titleText = contacts![indexPath.row]
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        if (tableView == dataTable1)
        {
            let cell = dataTable1.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            let titleText = table1Contents[indexPath.row]
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        if (tableView == dataTable2)
        {
            let cell = dataTable2.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            let titleText = table2Contents[indexPath.row]
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        if (tableView == dataTable3)
        {
            let cell = dataTable3.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            let titleText = table3Contents[indexPath.row]
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        if (tableView == dataTable4)
        {
            let cell = dataTable4.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            let titleText = table4Contents[indexPath.row]
            let titleRect = titleText.boundingRectWithSize(CGSizeMake(self.view.frame.size.width - 64, 128), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil, context: nil)
            
            retVal = titleRect.height
        }
        
        return retVal + 36.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        var retVal: Int = 0
        if (tableView == peopleTable)
        {
            retVal = self.contacts?.count ?? 0
        }
        else if (tableView == dataTable1)
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
        if (tableView == peopleTable)
        {
            let cell = peopleTable.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            
            // check to see if we are a header row, as if so need to change the font details
            
            var foundHeader = false
            
            for loopCount in headerRows!
            {
                if (loopCount - 1) == indexPath.row
                {
                    foundHeader = true
                    
                    println("Loopcount = \(loopCount) inex = \(indexPath.row)  value = \(contacts![indexPath.row])")
                    
                }
            }
            if foundHeader
            {
                cell.textLabel!.font = UIFont.boldSystemFontOfSize(30.0)
            }
            else
            {
                cell.textLabel!.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
            }

            cell.textLabel!.text = contacts![indexPath.row]
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
            return cell
        }
        else if (tableView == dataTable1)
        {
            let cell = dataTable1.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table1Contents[indexPath.row]
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
            return cell
        }
        else if (tableView == dataTable2)
        {
            let cell = dataTable2.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table2Contents[indexPath.row]
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
            return cell
        }
        else if (tableView == dataTable3)
        {
            let cell = dataTable3.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table3Contents[indexPath.row]
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
            return cell
        }
        else if (tableView == dataTable4)
        {
            let cell = dataTable4.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = table4Contents[indexPath.row]
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
            return cell
        }
        else
        {
            // Dummy statements to allow use of else
            let cell = peopleTable.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

  
        if (tableView == peopleTable)
        {
            //  Here we are checking to seeif a Header row was clicked, so we do not try and populate details for a Header
            var foundHeader = false
            
            for loopCount in headerRows!
            {
                if (loopCount - 1) == indexPath.row
                {
                    foundHeader = true
                    
                    println("Loopcount = \(loopCount) inex = \(indexPath.row)  value = \(contacts![indexPath.row])")
                    
                }
            }
            if !foundHeader
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
            
                personSelectedIndex = indexPath.row
            
                table1Contents = Array()
                table2Contents = Array()
                table3Contents = Array()
                table4Contents = Array()
            
                populateArraysForTables(indexPath.row, inTable: "Table1")
                populateArraysForTables(indexPath.row, inTable: "Table2")
                populateArraysForTables(indexPath.row, inTable: "Table3")
                populateArraysForTables(indexPath.row, inTable: "Table4")
            
                reloadDataTables()
            }
        }
            
        else if tableView == dataTable1
        {
            table1SelectedIndex = indexPath.row
            println("Click \(table1Contents[indexPath.row])")
        }
        else if tableView == dataTable2
        {
            table2SelectedIndex = indexPath.row
            println("Click \(table2Contents[indexPath.row])")
        }
        else if tableView == dataTable3
        {
            table3SelectedIndex = indexPath.row
            println("Click \(table3Contents[indexPath.row])")
        }
        else if tableView == dataTable4
        {
            table4SelectedIndex = indexPath.row
            println("Click \(table4Contents[indexPath.row])")
        }
        
    }
   
    func populateArraysForTables(rowID: Int, inTable : String)
    {
        // work out the table we are populating so we can then use this later
        switch inTable
        {
            case "Table1":
                table1Contents = populateArrayDetails(rowID, inTable: inTable)
            
            case "Table2":
                table2Contents = populateArrayDetails(rowID, inTable: inTable)
            
            case "Table3":
                table3Contents = populateArrayDetails(rowID, inTable: inTable)
            
            case "Table4":
                table4Contents = populateArrayDetails(rowID, inTable: inTable)
            
            default:
                println("populateArraysForTables: hit default for some reason")
            
        }
    }
    
    func populateArrayDetails(rowID: Int, inTable: String ) -> [String]
    {
        var workArray: [String] = [""]
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
        
        let start = dataType.startIndex
        let end = find(dataType, " ")
        
        var selectedType: String = ""
        
        if end != nil
        {
            let myEnd = end?.predecessor()
            selectedType = dataType[start...myEnd!]
        }
        else
        { // no space found
            selectedType = dataType
        }
        
        // This is where we have the logic to work out which type of data we are goign to populate with
        switch selectedType
        {
            case "Contact":
                workArray = parseContactDetails(contactDetails![rowID])
            case "Calendar":
                workArray = parseCalendarDetails("Calendar",contactDetails![rowID])
            case "Reminders":
                workArray = parseCalendarDetails("Reminders",contactDetails![rowID])
            
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
}

