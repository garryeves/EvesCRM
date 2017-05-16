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

class addressesViewController: UIViewController
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
    
    override func viewDidLoad()
    {
//        hideFields()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAddressType(_ sender: UIButton)
    {
        
        showFields()
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
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

