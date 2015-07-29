//
//  maintainPanes.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 14/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData

protocol MyMaintainPanesDelegate
{
    func MaintainPanesDidFinish(controller:MaintainPanesViewController)
}

class MaintainPanesViewController: UIViewController {
    
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonChangeVisibile: UIButton!
    @IBOutlet weak var tablePane: UITableView!
    
    @IBOutlet weak var Table1Picker: UIPickerView!
    @IBOutlet weak var Table2Picker: UIPickerView!
    @IBOutlet weak var Table3Picker: UIPickerView!
    @IBOutlet weak var Table4Picker: UIPickerView!
    
    @IBOutlet weak var btnResetPanes: UIButton!
    
    var delegate: MyMaintainPanesDelegate?
    private var myPanes: [displayPane]!
    private var mySelectedPane: String = ""
    private var mySelectedCurrentState: Bool = false
    private var myPicker1: [String]!
    private var myPicker2: [String]!
    private var myPicker3: [String]!
    private var myPicker4: [String]!
    var myManagedContext: NSManagedObjectContext!
    
    let cellReuse = "tablePane"

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tablePane.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellReuse)

        // Go and get the Pane data
        myPanes = displayPanes().listPanes
        
        buttonChangeVisibile.hidden = true
        
        tablePane.estimatedRowHeight = 12.0
        tablePane.rowHeight = UITableViewAutomaticDimension
        tablePane.tableFooterView = UIView(frame:CGRectZero)
        myPicker1 = Array()
        myPicker2 = Array()
        myPicker3 = Array()
        myPicker4 = Array()
        
        populatePicker()
        
        // Go and get the initial state for the pickers (i.e what is in the table.  If no initial statedefined, then default
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var retVal: Int = 0
        
        if tableView == tablePane
        {
            retVal = myPanes.count ?? 0
        }
        return retVal
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if tableView == tablePane
        {
            let cell = tablePane.dequeueReusableCellWithIdentifier(cellReuse) as! UITableViewCell
            cell.textLabel!.text = "\(myPanes[indexPath.row].paneName) - "
            if myPanes[indexPath.row].paneVisible
            {
                cell.textLabel!.text = cell.textLabel!.text!  + "visible"
                let cell2 = setCellFormatting(cell,"")
                return cell2
            }
            else
            {
                cell.textLabel!.text = cell.textLabel!.text!  + "hidden"
                let cell2 = setCellFormatting(cell,"Gray")
                return cell2
            }
        }
        else
        {
            // Dummy statements to allow use of else
            let cell = tablePane.dequeueReusableCellWithIdentifier(cellReuse) as! UITableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        if tableView == tablePane
        {
            mySelectedPane = myPanes[indexPath.row].paneName
            mySelectedCurrentState = myPanes[indexPath.row].paneVisible
            
            var buttonText: String = "Press to "
            if mySelectedCurrentState
            {
                buttonText += "hide "
            }
            else
            {
                buttonText += "show "
            }
            
            buttonText += mySelectedPane
            
            buttonChangeVisibile.setTitle(buttonText, forState: UIControlState.Normal)
            buttonChangeVisibile.hidden = false
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        var retVal: Int = 0
        
        if pickerView == Table1Picker
        {
            retVal = myPicker1.count
        }
        else if pickerView == Table2Picker
        {
            retVal = myPicker2.count
        }
        else if pickerView == Table3Picker
        {
            retVal = myPicker3.count
        }
        else if pickerView == Table4Picker
        {
            retVal = myPicker4.count
        }
        return retVal
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        var retVal: String = ""
        
        if pickerView == Table1Picker
        {
            retVal =  myPicker1[row]
        }
        else if pickerView == Table2Picker
        {
            retVal =  myPicker2[row]
        }
        else if pickerView == Table3Picker
        {
            retVal =  myPicker3[row]
        }
        else if pickerView == Table4Picker
        {
            retVal =  myPicker4[row]
        }
        return retVal
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        var myUpdatePanes = displayPanes()
        
        if pickerView == Table1Picker
        {
            myUpdatePanes.setDisplayPane(myPicker1[row], inPaneOrder: 1)
        }
        else if pickerView == Table2Picker
        {
            myUpdatePanes.setDisplayPane(myPicker2[row], inPaneOrder: 2)
        }
        else if pickerView == Table3Picker
        {
            myUpdatePanes.setDisplayPane(myPicker3[row], inPaneOrder: 3)
        }
        else if pickerView == Table4Picker
        {
            myUpdatePanes.setDisplayPane(myPicker4[row], inPaneOrder: 4)
        }
    }

    
    @IBAction func buttonBackClick(sender: UIButton)
    {
        delegate?.MaintainPanesDidFinish(self)
    }
    @IBAction func buttonChangeVisibileClick(sender: UIButton)
    {
        // Lets update the table
        
        var myUpdatePanes = displayPanes()
        
        myUpdatePanes.toogleVisibleStatus(mySelectedPane)
        
        myPanes = displayPanes().listPanes
        tablePane.reloadData()
        mySelectedPane = ""
        mySelectedCurrentState = false
        buttonChangeVisibile.hidden = true
        populatePicker()
    }
    
    func populatePicker()
    {
        var table1Default: Int = 0
        var table2Default: Int = 0
        var table3Default: Int = 0
        var table4Default: Int = 0
        
        var myIndex1: Int = 0
        var myIndex2: Int = 0
        var myIndex3: Int = 0
        var myIndex4: Int = 0
        
        myPicker1.removeAll(keepCapacity: false)
        myPicker2.removeAll(keepCapacity: false)
        myPicker3.removeAll(keepCapacity: false)
        myPicker4.removeAll(keepCapacity: false)
        
        var loopCount: Int = 0
        for myPane in displayPanes().listVisiblePanes
        {
            myPicker1.append(myPane.paneName)
            myPicker2.append(myPane.paneName)
            myPicker3.append(myPane.paneName)
            myPicker4.append(myPane.paneName)
            
            if myPane.paneName == "Calendar"
            {
                table1Default = loopCount
            }
            
            if myPane.paneName == "Details"
            {
                table2Default = loopCount
            }
            
            if myPane.paneName == "Project Membership"
            {
                table3Default = loopCount
            }
            
            if myPane.paneName == "Reminders"
            {
                table4Default = loopCount
            }
            
            switch myPane.paneOrder
            {
                case 1: myIndex1 = loopCount
        
                case 2: myIndex2 = loopCount
                
                case 3: myIndex3 = loopCount
                
                case 4: myIndex4 = loopCount
                
                default:   var a = 1
            }
            
            loopCount++
        }
        
        if myIndex1 == 0
        {
            Table1Picker.selectRow(table1Default, inComponent: 0, animated: true)
        }
        else
        {
            Table1Picker.selectRow(myIndex1, inComponent: 0, animated: true)
        }

        if myIndex2 == 0
        {
            Table2Picker.selectRow(table2Default, inComponent: 0, animated: true)
        }
        else
        {
            Table2Picker.selectRow(myIndex2, inComponent: 0, animated: true)
        }

        if myIndex3 == 0
        {
            Table3Picker.selectRow(table3Default, inComponent: 0, animated: true)
        }
        else
        {
            Table3Picker.selectRow(myIndex3, inComponent: 0, animated: true)
        }

        if myIndex4 == 0
        {
            Table4Picker.selectRow(table4Default, inComponent: 0, animated: true)
        }
        else
        {
            Table4Picker.selectRow(myIndex4, inComponent: 0, animated: true)
        }
    }
    @IBAction func btnResetPanes(sender: UIButton)
    {
        // this is to allow cleaning of panes if needed
        
        myDatabaseConnection.deleteAllPanes()
        
        // End delete phase
        
        myPanes = displayPanes().listPanes
        
        tablePane.reloadData()
        buttonChangeVisibile.hidden = true
        myPicker1 = Array()
        myPicker2 = Array()
        myPicker3 = Array()
        myPicker4 = Array()
        
        populatePicker()
    }
}

