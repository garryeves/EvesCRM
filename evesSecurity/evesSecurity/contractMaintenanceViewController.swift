//
//  contractMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 19/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class contractMaintenanceViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtNote: UITextView!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var btnStartDate: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnContacts: UIButton!
    
    var communicationDelegate: myCommunicationDelegate?
    var workingContract: project!
    
    fileprivate var displayList: [String] = Array()
    
    override func viewDidLoad()
    {
        txtNote.layer.borderColor = UIColor.lightGray.cgColor
        txtNote.layer.borderWidth = 0.5
        txtNote.layer.cornerRadius = 5.0
        txtNote.layer.masksToBounds = true
        
        if workingContract != nil
        {
            txtName.text = workingContract.projectName
            txtNote.text = workingContract.note
            
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
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSave(_ sender: UIButton)
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
            workingContract.save()
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: "Stages"))!
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
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
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
}
