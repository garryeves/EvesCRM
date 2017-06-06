//
//  contractMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 19/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class contractMaintenanceViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate, myCommunicationDelegate
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
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    var communicationDelegate: myCommunicationDelegate?
    var workingContract: project!
    
    fileprivate var displayList: [String] = Array()
    
    override func viewDidLoad()
    {
        txtNote.layer.borderColor = UIColor.lightGray.cgColor
        txtNote.layer.borderWidth = 0.5
        txtNote.layer.cornerRadius = 5.0
        txtNote.layer.masksToBounds = true
        
        refreshScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem)
    {
        if txtName.text == ""
        {
            let alert = UIAlertController(title: "Contract Maintenance", message: "You must provide a contract name", preferredStyle: .actionSheet)
            
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
            workingContract.projectName = txtName.text!
            workingContract.note = txtNote.text!
            workingContract.clientDept = txtDept.text!
            workingContract.invoicingDay = Int(txtInvoicingDay.text!)!
            workingContract.daysToPay = Int(txtDaysToPay.text!)!
            
            workingContract.save()
        }
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
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
        if source == "startDate"
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
        else if source == "endDate"
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