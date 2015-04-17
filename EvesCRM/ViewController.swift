//
//  ViewController.swift
//  EvesCRM
//
//  Created by Garry Eves on 15/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import AddressBook

private let CONTACT_CELL_IDENTIFER = "contactNameCell"

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
    
    
    @IBOutlet weak var setSelectionButton: UIButton!
    
    var TableOptions = ["Contact Details", "Calender", "Omnifocus", "Evernote", "Mail", "Twitter", "Facebook", "LinkedIn"]
    
    // Store the tag number of the button pressed so that we can make sure we update the correct button text and table
    var callingTable = 0
    
    // Default for the table type selected
    var itemSelected = "Contact Details"
    
    // Define array to hold the contact names
    
    var contacts:[String]?
    var contactDetails:[ABRecord]?
    
    // store the name of the person selected in the People table
    var personSelected = ""
    var personSelectedIndex: NSIndexPath = NSIndexPath()
    
    
    var adbk : ABAddressBook!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
       // Initial population of contact list
        self.peopleTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: CONTACT_CELL_IDENTIFER)
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
        
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        
        for record:ABRecordRef in contactList {
            var contactName: String = ABRecordCopyCompositeName(record).takeRetainedValue() as String
            contacts!.append(contactName)
            contactDetails!.append(record)
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
    
    
    func tableView(peopleTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts?.count ?? 0
    }
    
    func tableView(peopleTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = peopleTable.dequeueReusableCellWithIdentifier(CONTACT_CELL_IDENTIFER) as! UITableViewCell
        cell.textLabel!.text = contacts![indexPath.row]
        personSelectedIndex = indexPath
        return cell
    }
    
    func tableView(peopleTable: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        println("Selected someone: \(contacts![indexPath.row])")

        parseContactDetails(contactDetails![indexPath.row])
        
//        var contactRecord: ABRecord =  contactDetails![indexPath.row]
        
//        let firstName = ABRecordCopyValue(contactRecord, kABPersonFirstNameProperty)
        
//        let fn:String = (firstName.takeRetainedValue() as? String) ?? ""
                
//        println("Row2: \(fn)")
        
        
        
    }
    
}

