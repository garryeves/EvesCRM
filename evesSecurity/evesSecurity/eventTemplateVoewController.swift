//
//  eventTemplateVoewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 23/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit


let eventDayArray = [  [ "Event Day - 2", -2],
                       [ "Event Day - 1", -1],
                       [ "Event Day", 0],
                       [ "Event Day + 1", 1],
                       [ "Event Day + 2", 2]
                    ]

class eventTemplateVoewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    @IBOutlet weak var tblTemplates: UITableView!
    @IBOutlet weak var tblRoles: UITableView!
    @IBOutlet weak var txtNumRequired: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnOn: UIButton!
    @IBOutlet weak var btnRole: UIButton!
    @IBOutlet weak var btnEndTime: UIButton!
    @IBOutlet weak var btnStartTime: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnNewTemplates: UIButton!
    @IBOutlet weak var lblTemplateName: UILabel!
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var lblNumRequired: UILabel!
    @IBOutlet weak var lblOn: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblEnd: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    var communicationDelegate: myCommunicationDelegate?

    fileprivate var templates: eventTemplateHeads!
    fileprivate var currentTemplate: eventTemplateHead!
    fileprivate var displayList: [String] = Array()
    fileprivate var startTime: Date = getDefaultDate()
    fileprivate var endTime: Date = getDefaultDate()
    fileprivate var dateModifier: Int!
    
    override func viewDidLoad()
    {
        hideFields()
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
            case tblTemplates:
                if templates == nil
                {
                    return 0
                }
                else
                {
                    return templates.templates.count
                }
                
            case tblRoles:
                if currentTemplate == nil
                {
                 return 0
                }
                else
                {
                    if currentTemplate.roles == nil
                    {
                        return 0
                    }
                    else
                    {
                        return currentTemplate.roles!.roles!.count
                    }
                }
            
            default:
                return 0
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblTemplates:
                let cell = tableView.dequeueReusableCell(withIdentifier:"templateCell", for: indexPath) as! templateListItem
                
                cell.lblName.text = templates.templates[indexPath.row].eventName
                
                return cell
                
            case tblRoles:
                let cell = tableView.dequeueReusableCell(withIdentifier:"roleCell", for: indexPath) as! templateRoleItem
                
                cell.lblRole.text = currentTemplate.roles!.roles![indexPath.row].role
                cell.lblNumRequired.text = "\(currentTemplate.roles!.roles![indexPath.row].numRequired)"
                displayTime(cell.lblEndTime, workingTime: currentTemplate.roles!.roles![indexPath.row].endTime)
                displayTime(cell.lblStartTime, workingTime: currentTemplate.roles!.roles![indexPath.row].startTime)

                for myItem in eventDayArray
                {
                    if (myItem[1] as! Int) == currentTemplate.roles!.roles![indexPath.row].dateModifier
                    {
                        cell.lblDay.text = myItem[0] as? String
                    }
                }

                return cell
            
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblTemplates:
                currentTemplate = templates.templates[indexPath.row]

                showFields()
                refreshScreen()
            
            case tblRoles:
                let _ = 1

            
            default:
                let _ = 1
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if tableView == tblRoles
        {
            let headerView = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! templateRoleItem
            return headerView
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if tableView == tblRoles
        {
            return 30
        }
        else
        {
            return 0
        }
    }
    
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
        if txtName.text == ""
        {
            let alert = UIAlertController(title: "Template Maintenance", message: "You must provide a template name", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                                          handler: { (action: UIAlertAction) -> () in
                                            self.dismiss(animated: true, completion: nil)
            }))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
        else
        {
            currentTemplate.eventName = txtName.text!
            
            currentTemplate.save()
            
            refreshScreen()
        }

    }
    
    @IBAction func btnOn(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in eventDayArray
        {
            displayList.append(myItem[0] as! String)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "on"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnRole(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: "ShowRole"))!
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "role"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnNewTemplate(_ sender: UIButton)
    {
        currentTemplate = eventTemplateHead(teamID: currentUser.currentTeam!.teamID)
        btnSave.isHidden = false
        txtName.isHidden = false
        lblTemplateName.isHidden = false
        btnRole.setTitle("Select", for: .normal)
        btnOn.setTitle("Select", for: .normal)
        btnEndTime.setTitle("Select", for: .normal)
        btnStartTime.setTitle("Select", for: .normal)
        
        txtName.becomeFirstResponder()
    }
    
    @IBAction func btnAdd(_ sender: UIButton)
    {
        if txtNumRequired.text == ""
        {
            let alert = UIAlertController(title: "Template Maintenance", message: "You must provide the number of people required", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                                          handler: { (action: UIAlertAction) -> () in
                                            self.dismiss(animated: true, completion: nil)
            }))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
        else if !(txtNumRequired.text?.isNumber)!
        {
            let alert = UIAlertController(title: "Template Maintenance", message: "You must provide an Integer value", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                                          handler: { (action: UIAlertAction) -> () in
                                            self.dismiss(animated: true, completion: nil)
            }))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
        else if txtNumRequired.text == "0"
        {
            let alert = UIAlertController(title: "Template Maintenance", message: "You must provide an Integer greater than 0", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                                          handler: { (action: UIAlertAction) -> () in
                                            self.dismiss(animated: true, completion: nil)
            }))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
        else
        {
            // after all that we know we have a valid number, so lets go and create the record
            let _ = currentTemplate.addRole(role: btnRole.currentTitle!,
                                            numRequired: Int(txtNumRequired.text!)!,
                                            dateModifier: dateModifier,
                                            startTime: startTime,
                                            endTime: endTime)
            refreshScreen()
        }
    }
    
    @IBAction func btnStartTime(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "startTime"
        pickerView.delegate = self
        pickerView.currentDate = getDefaultDate()

        pickerView.showDates = false
        pickerView.showTimes = true

        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnEndTime(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "endTime"
        pickerView.delegate = self
        pickerView.currentDate = getDefaultDate()
        pickerView.showDates = false
        pickerView.showTimes = true
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    private func checkCanAdd()
    {
        if btnRole.currentTitle == "Select" ||
            btnOn.currentTitle == "Select" ||
            btnStartTime.currentTitle == "Select" ||
            btnEndTime.currentTitle == "Select"
        {
            btnAdd.isHidden = true
        }
        else
        {
            btnAdd.isHidden = false
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "role"
        {
            if displayList[selectedItem] == ""
            {
                btnRole.setTitle("Select", for: .normal)
            }
            else
            {
                btnRole.setTitle(displayList[selectedItem], for: .normal)
            }
        }
        
        if source == "on"
        {
            if selectedItem > 0
            {
                btnOn.setTitle(eventDayArray[selectedItem - 1][0] as? String, for: .normal)
                dateModifier = eventDayArray[selectedItem - 1][1] as! Int
            }
            else
            {
                btnOn.setTitle("Select", for: .normal)
                dateModifier = 0
            }
        }
        checkCanAdd()
    }
    
    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        if source == "startTime"
        {
            startTime = selectedDate
            
            if selectedDate == getDefaultDate()
            {
                btnStartTime.setTitle("Select", for: .normal)
            }
            else
            {
                displayTime(btnStartTime, workingTime: selectedDate)
            }
        }
        else if source == "endTime"
        {
            endTime = selectedDate
            
            if selectedDate == getDefaultDate()
            {
                btnEndTime.setTitle("Select", for: .normal)
            }
            else
            {
                displayTime(btnEndTime, workingTime: selectedDate)
            }
        }
        checkCanAdd()
    }
    
    private func displayTime(_ sender: UIButton, workingTime: Date)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        sender.setTitle(dateFormatter.string(from: workingTime), for: .normal)
    }
    
    private func displayTime(_ sender: UILabel, workingTime: Date)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        sender.text = dateFormatter.string(from: workingTime)
    }

    func hideFields()
    {
        tblRoles.isHidden = true
        txtNumRequired.isHidden = true
        txtName.isHidden = true
        btnOn.isHidden = true
        btnRole.isHidden = true
        btnEndTime.isHidden = true
        btnStartTime.isHidden = true
        btnAdd.isHidden = true
        lblTemplateName.isHidden = true
        lblRole.isHidden = true
        lblNumRequired.isHidden = true
        lblOn.isHidden = true
        lblStart.isHidden = true
        lblEnd.isHidden = true
        btnSave.isHidden = true
    }
    
    func showFields()
    {
        tblRoles.isHidden = false
        txtNumRequired.isHidden = false
        btnOn.isHidden = false
        btnRole.isHidden = false
        btnEndTime.isHidden = false
        btnStartTime.isHidden = false
        lblTemplateName.isHidden = false
        lblRole.isHidden = false
        lblNumRequired.isHidden = false
        lblOn.isHidden = false
        lblStart.isHidden = false
        lblEnd.isHidden = false
        btnSave.isHidden = false
        txtName.isHidden = false
    }
    
    func refreshScreen()
    {
        templates = eventTemplateHeads(teamID: currentUser.currentTeam!.teamID)
        tblTemplates.reloadData()
        
        if currentTemplate != nil
        {
            txtName.text = currentTemplate.eventName

            currentTemplate.loadRoles()
            tblRoles.reloadData()
            
            btnRole.setTitle("Select", for: .normal)
            btnOn.setTitle("Select", for: .normal)
            btnEndTime.setTitle("Select", for: .normal)
            btnStartTime.setTitle("Select", for: .normal)
            txtNumRequired.text = "0"
        }
    }
}

class templateListItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class templateRoleItem: UITableViewCell
{
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var lblNumRequired: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

