//
//  addressesViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 16/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

//
//  newUserViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class addressesViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var lblAddressType: UILabel!
    @IBOutlet weak var lblSreet1: UILabel!
    @IBOutlet weak var lblStreet2: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblPostcode: UILabel!
    @IBOutlet weak var btnAddressType: UIButton!
    @IBOutlet weak var txtStreet1: UITextField!
    @IBOutlet weak var txtStreet2: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtPostcode: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    var workingPerson: person!
    var workingClient: client!
    var workingProject: project!
    
    private var displayList: [String] = Array()
    var workingAddress: address!
    
    override func viewDidLoad()
    {
        if workingPerson.addresses.count > 0
        {
            if workingAddress == nil
            {
                workingAddress = workingPerson.addresses[0]
            }
            displayItem()
        }
        else
        {
            btnAddressType.setTitle("Select", for: .normal)
            hideFields()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAddressType(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: "Address"))!
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
  //      pickerView.isModalInPopover = true
        
        if displayList.count > 0
        {
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "address"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = btnAddressType.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
        workingAddress.addressLine1 = txtStreet1.text!
        workingAddress.addressLine2 = txtStreet2.text!
        workingAddress.city = txtCity.text!
        workingAddress.state = txtState.text!
        workingAddress.country = txtCountry.text!
        workingAddress.postcode = txtPostcode.text!
        workingAddress.addressType = btnAddressType.currentTitle!
        workingAddress.save()
        workingPerson.loadAddresses()
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "address"
        {
            // loop through addresses to find matching record.  If none found then create a new address
            var itemFound: Bool = false
            
            for myItem in workingPerson.addresses
            {
                if myItem.addressType == displayList[selectedItem]
                {
                    workingAddress = myItem
                    itemFound = true
                    break
                }
            }
            
            if !itemFound
            {
                workingAddress = address(teamID: currentUser.currentTeam!.teamID)
                if workingPerson != nil
                {
                    workingAddress.personID = workingPerson.personID
                }
                if workingClient != nil
                {
                    workingAddress.clientID = workingClient.clientID
                }
                if workingProject != nil
                {
                    workingAddress.projectID = workingProject.projectID
                }
                workingAddress.addressType = displayList[selectedItem]
            }
            
            displayItem()
            showFields()
        }
    }
    
    func displayItem()
    {
        txtStreet1.text = workingAddress.addressLine1
        txtStreet2.text = workingAddress.addressLine2
        txtCity.text = workingAddress.city
        txtState.text = workingAddress.state
        txtCountry.text = workingAddress.country
        txtPostcode.text = workingAddress.postcode
        btnAddressType.setTitle(workingAddress.addressType, for: .normal)
    }
    
    func hideFields()
    {
        lblSreet1.isHidden = true
        lblStreet2.isHidden = true
        lblCity.isHidden = true
        lblState.isHidden = true
        lblCountry.isHidden = true
        lblPostcode.isHidden = true
        txtStreet1.isHidden = true
        txtStreet2.isHidden = true
        txtCity.isHidden = true
        txtState.isHidden = true
        txtCountry.isHidden = true
        txtPostcode.isHidden = true
        btnSave.isHidden = true
    }
    
    func showFields()
    {
        lblSreet1.isHidden = false
        lblStreet2.isHidden = false
        lblCity.isHidden = false
        lblState.isHidden = false
        lblCountry.isHidden = false
        lblPostcode.isHidden = false
        txtStreet1.isHidden = false
        txtStreet2.isHidden = false
        txtCity.isHidden = false
        txtState.isHidden = false
        txtCountry.isHidden = false
        txtPostcode.isHidden = false
        btnSave.isHidden = false
    }
}

