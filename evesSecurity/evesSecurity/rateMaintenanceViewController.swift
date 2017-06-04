//
//  rateMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 20/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class rateMaintenanceViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var btnStartDate: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtStaff: UITextField!
    @IBOutlet weak var txtClient: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    var communicationDelegate: myCommunicationDelegate?
    var workingRate: rate!
    
    fileprivate var displayList: [String] = Array()
    fileprivate var workingStaff: Double = 0.0
    fileprivate var workingClient: Double = 0.0
    
    override func viewDidLoad()
    {
        if workingRate != nil
        {
            txtName.text = workingRate.rateName
            
            workingStaff = workingRate.rateAmount
            txtStaff.text = workingStaff.formatCurrency
            
            workingClient = workingRate.chargeAmount
            txtClient.text = workingClient.formatCurrency

            if workingRate.startDate == getDefaultDate()
            {
                btnStartDate.setTitle("Set", for: .normal)
                
            }
            else
            {
                btnStartDate.setTitle(workingRate.displayStartDate, for: .normal)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editingDidBegin(_ sender: UITextField)
    {
        if sender == txtStaff
        {
             sender.text = "\(workingStaff)"
        }
        else if sender == txtClient
        {
            sender.text = "\(workingClient)"
        }
    }
    
    @IBAction func EditingDidEnd(_ sender: UITextField)
    {
        if let _ = Double(sender.text!)
        {
            if sender == txtStaff
            {
                workingStaff = Double(sender.text!)!
                sender.text = workingStaff.formatCurrency
            }
            else if sender == txtClient
            {
                workingClient = Double(sender.text!)!
                sender.text = workingClient.formatCurrency
            }
        }
    }

    @IBAction func btnSave(_ sender: UIButton)
    {
        if txtName.text == "" || btnStartDate.currentTitle == "Set"
        {
            let alert = UIAlertController(title: "Rate Maintenance", message: "You must provide a rate name and start date", preferredStyle: .actionSheet)
            
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
            // check to see if the values in the charge boxes are different that the stored value, as if they are then user clicked save from one of them and wants to save
            
            if let _ = Double(txtStaff.text!)
            {
                 workingStaff = Double(txtStaff.text!)!
            }
                
            if let _ = Double(txtClient.text!)
            {
                workingClient = Double(txtClient.text!)!
            }
    
            workingRate.rateName = txtName.text!
            workingRate.rateAmount = workingStaff
            workingRate.chargeAmount = workingClient
            
            workingRate.save()
            
            communicationDelegate?.refreshScreen!()
            self.dismiss(animated: true, completion: nil)
        }
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
        if workingRate.startDate == getDefaultDate()
        {
            pickerView.currentDate = Date()
        }
        else
        {
            pickerView.currentDate = workingRate.startDate
        }
        pickerView.showTimes = false
        
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }    
    
    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
        if source == "startDate"
        {
            workingRate.startDate = selectedDate

            if workingRate.startDate == getDefaultDate()
            {
                btnStartDate.setTitle("Set", for: .normal)
            }
            else
            {
                btnStartDate.setTitle(workingRate.displayStartDate, for: .normal)
            }
        }
    }
}


