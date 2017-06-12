//
//  contractMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 19/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class contractMaintenanceViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate, myCommunicationDelegate, UITextViewDelegate
{
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtNote: UITextView!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var btnStartDate: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var btnContacts: UIButton!
    @IBOutlet weak var txtDept: UITextField!
    @IBOutlet weak var txtInvoicingDay: UITextField!
    @IBOutlet weak var txtDaysToPay: UITextField!
    @IBOutlet weak var btnInvoicingFrequency: UIButton!
    @IBOutlet weak var btnType: UIButton!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    var communicationDelegate: myCommunicationDelegate?
    var workingContract: project!
    
    fileprivate var displayList: [String] = Array()
    
    override func viewDidLoad()
    {
        txtNote.layer.borderColor = UIColor.lightGray.cgColor
        txtNote.layer.borderWidth = 0.5
        txtNote.layer.cornerRadius = 5.0
        txtNote.layer.masksToBounds = true
        txtNote.delegate = self
        refreshScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func txtName(_ sender: UITextField)
    {
        if txtName.text! != ""
        {
            workingContract.projectName = txtName.text!
        }
    }
    
    @IBAction func txtDept(_ sender: UITextField)
    {
        workingContract.clientDept = txtDept.text!
    }
    
    @IBAction func txtInvoicingDay(_ sender: UITextField)
    {
        if txtInvoicingDay.text! != ""
        {
            if txtInvoicingDay.text!.isNumber
            {
                workingContract.invoicingDay = Int(txtInvoicingDay.text!)!
            }
        }
        else
        {
           workingContract.invoicingDay = 0
        }
    }
    
    @IBAction func txtDaysToPay(_ sender: UITextField)
    {
        if txtDaysToPay.text! != ""
        {
            if txtDaysToPay.text!.isNumber
            {
                workingContract.daysToPay = Int(txtDaysToPay.text!)!
            }
        }
        else
        {
            workingContract.daysToPay = 0
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView == txtNote
        {
            workingContract.note = txtNote.text!
        }
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        if txtName.isFirstResponder
        {
            if txtName.text! != ""
            {
                workingContract.projectName = txtName.text!
            }
        }
        
        if txtDept.isFirstResponder
        {
            workingContract.clientDept = txtDept.text!
        }
        
        if txtInvoicingDay.isFirstResponder
        {
            if txtInvoicingDay.text! != ""
            {
                if txtInvoicingDay.text!.isNumber
                {
                    workingContract.invoicingDay = Int(txtInvoicingDay.text!)!
                }
            }
            else
            {
                workingContract.invoicingDay = 0
            }
        }
        
        if txtName.isFirstResponder
        {
            if txtDaysToPay.text! != ""
            {
                if txtDaysToPay.text!.isNumber
                {
                    workingContract.daysToPay = Int(txtDaysToPay.text!)!
                }
            }
            else
            {
                workingContract.daysToPay = 0
            }
        }
        
        if txtNote.isFirstResponder
        {
            workingContract.note = txtNote.text!
        }
        
        self.dismiss(animated: true, completion: nil)
        communicationDelegate?.refreshScreen!()
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: btnType.currentTitle!))!
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
        
        pickerView.source = "status"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }

    @IBAction func btnStartDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "startDate"
        pickerView.delegate = self
        if workingContract.projectStartDate == getDefaultDate()
        {
            pickerView.currentDate = Date()
        }
        else
        {
            pickerView.currentDate = workingContract.projectStartDate
        }
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnEndDate(_ sender: UIButton)
    {
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "endDate"
        pickerView.delegate = self
        if workingContract.projectEndDate == getDefaultDate()
        {
            pickerView.currentDate = Date()
        }
        else
        {
            pickerView.currentDate = workingContract.projectEndDate
        }
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnContacts(_ sender: UIButton)
    {
        let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
        peopleEditViewControl.projectID = workingContract.projectID
        self.present(peopleEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnInvoicingFrequency(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        displayList.append("Annualy")
        displayList.append("At Completion")
        displayList.append("Milestones")
        displayList.append("Monthly")
        displayList.append("Quarterly")
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "InvoicingFrequency"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        self.present(pickerView, animated: true, completion: nil)
    }

    @IBAction func btnType(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: "ProjectType"))!
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
        
        pickerView.source = "type"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "status"
        {
            workingContract.projectStatus = displayList[selectedItem]
            if workingContract.projectStatus == ""
            {
                btnStatus.setTitle("Set", for: .normal)
            }
            else
            {
                btnStatus.setTitle(workingContract.projectStatus, for: .normal)
            }
        }
        else if source == "InvoicingFrequency"
        {
            workingContract.invoicingFrequency = displayList[selectedItem]
            if workingContract.invoicingFrequency == ""
            {
                btnInvoicingFrequency.setTitle("Set", for: .normal)
            }
            else
            {
                btnInvoicingFrequency.setTitle(workingContract.invoicingFrequency, for: .normal)
            }
        }
        else if source == "type"
        {
            workingContract.type = displayList[selectedItem]
            if workingContract.type == ""
            {
                btnType.setTitle("Set", for: .normal)
            }
            else
            {
                btnType.setTitle(workingContract.type, for: .normal)
            }
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(processDateChange(timer :)), userInfo: ["source": source, "selectedDate":selectedDate], repeats: false)
    }
    
    func processDateChange(timer: Timer)
    {
        let info = timer.userInfo as! [String:Any]
        let source = info["source"] as! String
        let selectedDate = info["selectedDate"] as! Date
        
        if source == "startDate"
        {
            var boolSave: Bool = true
            
            if workingContract.projectEndDate != getDefaultDate()
            {
                if selectedDate > workingContract.projectEndDate
                {
                    let alert = UIAlertController(title: "Contract Maintenance", message: "Start Date can not be after End Date of \(workingContract.displayProjectEndDate)", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                                                  handler: { (action: UIAlertAction) -> () in
                                                    let _ = 1
                    }))
                    
                    alert.isModalInPopover = true
                    let popover = alert.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = btnStartDate
                    
                    self.present(alert, animated: false, completion: nil)
                    
                    boolSave = false
                }
            }
            
            if boolSave
            {
                workingContract.projectStartDate = selectedDate
                if workingContract.projectStartDate == getDefaultDate()
                {
                    btnStartDate.setTitle("Set", for: .normal)
                }
                else
                {
                    btnStartDate.setTitle(workingContract.displayProjectStartDate, for: .normal)
                }
            }
        }
        else if source == "endDate"
        {
            var boolSave: Bool = true
            
            if workingContract.projectStartDate != getDefaultDate()
            {
                if selectedDate < workingContract.projectStartDate
                {
                    let alert = UIAlertController(title: "Contract Maintenance", message: "End Date can not be before Start Date of \(workingContract.displayProjectStartDate)", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                                                  handler: { (action: UIAlertAction) -> () in
                                                    let _ = 1
                    }))
                    
                    alert.isModalInPopover = true
                    let popover = alert.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = btnEndDate
                    
                    self.present(alert, animated: false, completion: nil)
                    
                    boolSave = false
                }
            }
            
            if boolSave
            {
                workingContract.projectEndDate = selectedDate
                if workingContract.projectEndDate == getDefaultDate()
                {
                    btnEndDate.setTitle("Set", for: .normal)
                }
                else
                {
                    btnEndDate.setTitle(workingContract.displayProjectEndDate, for: .normal)
                }
            }
        }
    }
    
    func refreshScreen()
    {
        if workingContract != nil
        {
            txtName.text = workingContract.projectName
            txtNote.text = workingContract.note
            txtDept.text = workingContract.clientDept
            txtInvoicingDay.text = "\(workingContract.invoicingDay)"
            txtDaysToPay.text = "\(workingContract.daysToPay)"
            
            if workingContract.projectStatus == ""
            {
                btnStatus.setTitle("Set", for: .normal)
            }
            else
            {
                btnStatus.setTitle(workingContract.projectStatus, for: .normal)
            }
            
            if workingContract.projectStartDate == getDefaultDate()
            {
                btnStartDate.setTitle("Set", for: .normal)
            }
            else
            {
                btnStartDate.setTitle(workingContract.displayProjectStartDate, for: .normal)
            }
            
            if workingContract.projectEndDate == getDefaultDate()
            {
                btnEndDate.setTitle("Set", for: .normal)
            }
            else
            {
                btnEndDate.setTitle(workingContract.displayProjectEndDate, for: .normal)
            }
            
            if workingContract.invoicingFrequency == ""
            {
                btnInvoicingFrequency.setTitle("Set", for: .normal)
            }
            else
            {
                btnInvoicingFrequency.setTitle(workingContract.invoicingFrequency, for: .normal)
            }
            
            if workingContract.type == ""
            {
                btnType.setTitle("Set", for: .normal)
                btnStatus.isEnabled = false
            }
            else
            {
                btnType.setTitle(workingContract.type, for: .normal)
                btnStatus.isEnabled = true
            }
        }
    }
}
