//
//  maintainPanes.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 14/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol MyMaintainPanesDelegate
{
    func MaintainPanesDidFinish(_ controller:MaintainPanesViewController)
}

class MaintainPanesViewController: UIViewController
{
    @IBOutlet weak var Table1Picker: UIPickerView!
    @IBOutlet weak var Table2Picker: UIPickerView!
    @IBOutlet weak var Table3Picker: UIPickerView!
    @IBOutlet weak var Table4Picker: UIPickerView!
    @IBOutlet weak var btnResetPanes: UIButton!
    @IBOutlet weak var colPanes: UICollectionView!
    
    var delegate: MyMaintainPanesDelegate?
    fileprivate var myPanes: [displayPane]!
    fileprivate var mySelectedPane: String = ""
    fileprivate var mySelectedCurrentState: Bool = false
    fileprivate var myPicker1: [String]!
    fileprivate var myPicker2: [String]!
    fileprivate var myPicker3: [String]!
    fileprivate var myPicker4: [String]!
    
    let cellReuse = "reusePane"

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Go and get the Pane data
        myPanes = displayPanes().listPanes
        
        myPicker1 = Array()
        myPicker2 = Array()
        myPicker3 = Array()
        myPicker4 = Array()
        
        populatePicker()
        
        // Go and get the initial state for the pickers (i.e what is in the table.  If no initial statedefined, then default
        
        notificationCenter.addObserver(self, selector: #selector(self.removePane), name: NotificationRemovePane, object: nil)
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        colPanes.collectionViewLayout.invalidateLayout()
        
        colPanes.reloadData()
    }
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
        {
            // Do nothing
        }
        else
        {
            delegate?.MaintainPanesDidFinish(self)
        }
    }
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let myUpdatePanes = displayPanes()
        
        if pickerView == Table1Picker
        {
            myUpdatePanes.setDisplayPane(myPicker1[row], paneOrder: 1)
        }
        else if pickerView == Table2Picker
        {
            myUpdatePanes.setDisplayPane(myPicker2[row], paneOrder: 2)
        }
        else if pickerView == Table3Picker
        {
            myUpdatePanes.setDisplayPane(myPicker3[row], paneOrder: 3)
        }
        else if pickerView == Table4Picker
        {
            myUpdatePanes.setDisplayPane(myPicker4[row], paneOrder: 4)
        }
    }

    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return myPanes.count 
    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
   @objc(collectionView:cellForItemAtIndexPath:)  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell : myPaneItem!
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuse, for: indexPath as IndexPath) as! myPaneItem
        
        cell.lblPaneName.text = myPanes[indexPath.row].paneName
        
        if myPanes[indexPath.row].paneVisible
        {
            cell.btnHide.setTitle("Hide", for: UIControlState.normal)
        }
        else
        {
            cell.btnHide.setTitle("Show", for: UIControlState.normal)
        }
        
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = myRowColour
        }
        else
        {
            cell.backgroundColor = UIColor.clear
        }
        
        cell.layoutSubviews()
        
        return cell
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colPanes.bounds.size.width, height: 39)
        
        return retVal
    }

    func removePane()
    {
        myPanes = displayPanes().listPanes
        colPanes.reloadData()
        mySelectedPane = ""
        mySelectedCurrentState = false
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
        
        myPicker1.removeAll(keepingCapacity: false)
        myPicker2.removeAll(keepingCapacity: false)
        myPicker3.removeAll(keepingCapacity: false)
        myPicker4.removeAll(keepingCapacity: false)
        
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
            
            if myPane.paneName == "Tasks"
            {
                table4Default = loopCount
            }
            
            switch myPane.paneOrder
            {
                case 1: myIndex1 = loopCount
        
                case 2: myIndex2 = loopCount
                
                case 3: myIndex3 = loopCount
                
                case 4: myIndex4 = loopCount
                
                default:   NSLog("Do nothing")
            }
            
            loopCount += 1
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
    
    @IBAction func btnResetPanes(_ sender: UIButton)
    {
        // this is to allow cleaning of panes if needed
        
        myDatabaseConnection.deleteAllPanes()
        
        // End delete phase
        
        myPanes = displayPanes().listPanes
        
        colPanes.reloadData()
        myPicker1 = Array()
        myPicker2 = Array()
        myPicker3 = Array()
        myPicker4 = Array()
        
        populatePicker()
    }
}

class myPaneItem: UICollectionViewCell
{
    
    @IBOutlet weak var lblPaneName: UILabel!
    @IBOutlet weak var btnHide: UIButton!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnHide(_ sender: UIButton)
    {
        // Lets update the table
        
        let myUpdatePanes = displayPanes()
        
        myUpdatePanes.toogleVisibleStatus(lblPaneName.text!)
        
        notificationCenter.post(name: NotificationRemovePane, object: nil)
    }
}


