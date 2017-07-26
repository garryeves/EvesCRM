//
//  settingViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 15/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

struct decodeItem
{
    var name: String = ""
    var value: String = ""
    var source: String = ""
}
class settingsViewController: UIViewController, UIPopoverPresentationControllerDelegate, MyPickerDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tblCalendar: UITableView!
    @IBOutlet weak var tblSettings: UITableView!
    @IBOutlet weak var btnTeam: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    @IBOutlet weak var btnPerAddInfo: UIButton!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnDropbown: UIButton!
    @IBOutlet weak var btnSwitchUsers: UIButton!
    @IBOutlet weak var btnRestore: UIButton!
    @IBOutlet weak var btnNewTeam: UIButton!
    @IBOutlet weak var btnLinkPersonTask: UIButton!
    
    var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var calendarList: iOSCalendarList!
    fileprivate var decodeList: [decodeItem] = Array()
    
    private var displayList: [String] = Array()
    private var teamList: userTeams!
    private var newTeam: team!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        case tblCalendar:
            if calendarList != nil
            {
                return calendarList.list.count
            }
            else
            {
                return 0
            }
            
        case tblSettings:
            return decodeList.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblCalendar:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellCalendar", for: indexPath) as! oneLabelTable
                
                cell.lbl1.text = calendarList.list[indexPath.row].name
                
                if calendarList.list[indexPath.row].state
                {
                    cell.backgroundColor = cyanColour
                }
                else
                {
                    cell.backgroundColor = UIColor.white
                }
                
                return cell
            
            case tblSettings:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellSettings", for: indexPath) as! settingEntryItem
                
                cell.lblName.text = decodeList[indexPath.row].name
                cell.txtValue.text = decodeList[indexPath.row].value
                cell.source = decodeList[indexPath.row].source
                
                return cell
            
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblCalendar:
               calendarList.list[indexPath.row].state = !calendarList.list[indexPath.row].state
                
                tblCalendar.reloadData()
                
            case tblSettings:
                let _ = 1
                
                
            default:
                let _ = 1
        }
    }
    
    @IBAction func btnTeam(_ sender: UIButton)
    {
        let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
        orgEditViewControl.workingOrganisation = currentUser!.currentTeam
        self.present(orgEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnPassword(_ sender: UIButton)
    {
        let passwordView = loginStoryboard.instantiateViewController(withIdentifier: "setPassword") as! setPasswordViewController
        passwordView.modalPresentationStyle = .popover
        
        let popover = passwordView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        passwordView.preferredContentSize = CGSize(width: 600,height: 500)
        
        self.present(passwordView, animated: true, completion: nil)
    }
    
    @IBAction func btnPerAddInfo(_ sender: UIButton)
    {
        let addPerInfoViewControl = personStoryboard.instantiateViewController(withIdentifier: "AddPersonInfo") as! addPerInfoMaintenanceViewController
        self.present(addPerInfoViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnDropdowns(_ sender: UIButton)
    {
        let dropdownEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "dropdownMaintenance") as! dropdownMaintenanceViewController
        self.present(dropdownEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnRestore(_ sender: UIButton)
    {
        let deletedItemsViewControl = settingsStoryboard.instantiateViewController(withIdentifier: "securityDeletedItems") as! securityDeletedItemsViewController
        self.present(deletedItemsViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnSwitchUsers(_ sender: UIButton)
    {
        teamList = userTeams(userID: currentUser.userID)
        displayList.removeAll()
        
        for myItem in teamList.UserTeams
        {
            let tempTeam = team(teamID: myItem.teamID)
            displayList.append(tempTeam.name)
        }
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "TeamList"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "TeamList"
        {
            if selectedItem >= 0
            {
                currentUser.currentTeam = team(teamID: teamList.UserTeams[selectedItem].teamID)
                writeDefaultInt("teamID", value: currentUser.currentTeam!.teamID)
            }
        }
    }
    
    @IBAction func btnNewTeam(_ sender: UIButton)
    {
        // Create a new team
        
        notificationCenter.addObserver(self, selector: #selector(self.teamCreated), name: NotificationTeamCreated, object: nil)
        
        btnSwitchUsers.isEnabled = false
        btnTeam.isEnabled = false
        btnPerAddInfo.isEnabled = false
        btnDropbown.isEnabled = false
        btnRestore.isEnabled = false
        btnTeam.isEnabled = false
        btnNewTeam.isEnabled = false
        btnBack.isEnabled = false
        btnPassword.isEnabled = false
        
        newTeam = team()
    }
    
    func teamCreated()
    {
        notificationCenter.removeObserver(NotificationTeamCreated)
        
        // Add team to use
        
        currentUser.addTeamToUser(newTeam)
        
        newTeam.teamOwner = currentUser.userID
        
        currentUser.currentTeam = newTeam
        
        currentUser.addInitialUserRoles()
        
        // Pass this into team maintence screen
        writeDefaultInt("teamID", value: newTeam!.teamID)
        
        refreshScreen()
        btnBack.isEnabled = true
        btnPassword.isEnabled = true
        
        let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
        orgEditViewControl.workingOrganisation = currentUser!.currentTeam
        self.present(orgEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnBack(_ sender: Any)
    {
        communicationDelegate!.refreshScreen!()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnLinkPersonTask(_ sender: UIButton)
    {
        let personTaskLinkViewControl = personStoryboard.instantiateViewController(withIdentifier: "personTaskLink") as! personTaskLinkViewController
        personTaskLinkViewControl.modalPresentationStyle = .popover
        
        let popover = personTaskLinkViewControl.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        personTaskLinkViewControl.preferredContentSize = CGSize(width: 500,height: 300)
        
        self.present(personTaskLinkViewControl, animated: true, completion: nil)
    }
    
    func refreshScreen()
    {
        if userTeams(userID: currentUser.userID).UserTeams.count > 1
        {
            DispatchQueue.main.async
            {
                self.btnSwitchUsers.isHidden = false
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                self.btnSwitchUsers.isHidden = true
            }
        }
        
        if currentUser.checkPermission(adminRoleType) != noPermission
        {
            DispatchQueue.main.async
            {
                self.btnTeam.isEnabled = true
                self.btnPerAddInfo.isEnabled = true
                self.btnDropbown.isEnabled = true
                self.btnRestore.isEnabled = true
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                self.btnTeam.isEnabled = false
                self.btnPerAddInfo.isEnabled = false
                self.btnDropbown.isEnabled = false
                self.btnRestore.isEnabled = false
            }
        }
        
        if currentUser.currentTeam!.teamOwner == currentUser.userID
        {
            DispatchQueue.main.async
            {
                self.btnTeam.isEnabled = true
            }
        }
        
        DispatchQueue.main.async
        {
            self.calendarList = iOSCalendarList()
            self.tblCalendar.reloadData()
            self.buildDecodeArray()
        }
    }
    
    func buildDecodeArray()
    {
        decodeList.removeAll()
        
        var calBefore = readDefaultInt("CalBefore") as Int
        
        if calBefore == -1
        {
            writeDefaultInt("CalBefore", value: 2)
            calBefore = 2
        }
        
        let newItemBefore = decodeItem(name: "Number of weeks before today", value: "\(calBefore)", source: "CalBefore")
        decodeList.append(newItemBefore)
        
        var calAfter = readDefaultInt("CalAfter") as Int
        
        if calAfter == -1
        {
            writeDefaultInt("CalAfter", value: 4)
            calAfter = 4
        }
        let newItemAfter = decodeItem(name: "Number of weeks after today", value: "\(calAfter)", source: "CalAfter")
        decodeList.append(newItemAfter)
        
        tblSettings.reloadData()
    }
}

class settingEntryItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtValue: UITextField!
    
    var source: String!
    
    @IBAction func txtValue(_ sender: UITextField)
    {
        if source == "CalBefore" || source == "CalAfter"
        {
            if sender.text!.isNumber
            {
                writeDefaultInt(source, value: Int(sender.text!)!)
            }
        }
    }
}
