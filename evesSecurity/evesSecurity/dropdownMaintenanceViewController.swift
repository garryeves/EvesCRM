//
//  dropdownMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 17/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class dropdownMaintenanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var tblDropdowns: UITableView!
    @IBOutlet weak var tblValues: UITableView!
    @IBOutlet weak var lblNewValue: UILabel!
    @IBOutlet weak var txtValue: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    
    var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var dropdownList: [String] = Array()
    fileprivate var valueList: dropdowns!
    fileprivate var currentDropdownType: String = ""
    
    override func viewDidLoad()
    {
        hideFields()
        
        // Load the list of dropdown type list
        
        dropdownList = dropdowns(teamID: currentUser.currentTeam!.teamID).dropDownTypes
        refreshScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblDropdowns:
                return dropdownList.count
            
            case tblValues:
                if valueList == nil
                {
                    return 0
                }
                else
                {
                    return valueList.dropdowns.count
                }
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblDropdowns:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellDropdown", for: indexPath) as! oneLabelTable
                
                cell.lbl1.text = dropdownList[indexPath.row]
                return cell
            
            case tblValues:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellValue", for: indexPath) as! oneLabelTable
                
                cell.lbl1.text = valueList.dropdowns[indexPath.row].dropdownValue
                
                return cell
            
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblDropdowns:
                currentDropdownType = dropdownList[indexPath.row]
                
                refreshScreen()
            
            default:
                let _ = 1
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if tableView == tblValues
        {
            if editingStyle == .delete
            {
                if valueList.dropdowns[indexPath.row].dropdownValue != "Archived"
                {
                    valueList.dropdowns[indexPath.row].delete()
                    refreshScreen()
                }
                else
                {
                    let alert = UIAlertController(title: "Dropdown Maintenance", message:
                        "You can not delete the Archived value.  This is a System Required value.", preferredStyle: .alert)
                    
                    let yesOption = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    
                    alert.addAction(yesOption)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func txtValue(_ sender: UITextField)
    {
        if txtValue.text! == ""
        {
            btnAdd.isHidden = true
        }
        else
        {
            btnAdd.isHidden = false
        }
    }
    
    @IBAction func btnAdd(_ sender: UIButton)
    {
        let _ = dropdownItem(dropdownType: currentDropdownType, dropdownValue: txtValue.text!, teamID: currentUser.currentTeam!.teamID)
        
        txtValue.text = ""
        btnAdd.isHidden = true
        
        refreshScreen()
    }
    
    func refreshScreen()
    {
        if currentDropdownType != ""
        {
            valueList = dropdowns(dropdownType: currentDropdownType, teamID: currentUser.currentTeam!.teamID)
            tblValues.reloadData()
            showFields()
        }
    }
    
    func showFields()
    {
        tblDropdowns.isHidden = false
        tblValues.isHidden = false
        lblNewValue.isHidden = false
        txtValue.isHidden = false
        if txtValue.text! == ""
        {
            btnAdd.isHidden = true
        }
        else
        {
            btnAdd.isHidden = false
        }
    }
    
    func hideFields()
    {
        tblDropdowns.isHidden = false
        tblValues.isHidden = true
        lblNewValue.isHidden = true
        txtValue.isHidden = true
        btnAdd.isHidden = true
    }
}
