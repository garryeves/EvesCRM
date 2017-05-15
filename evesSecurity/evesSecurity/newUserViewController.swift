//
//  newUserViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class newInstanceViewController: UIViewController, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var btnNew: UIButton!
    @IBOutlet weak var btnExisting: UIButton!
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var newTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var newButtonVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTextVerticalConstraint: NSLayoutConstraint!
    
    var loginDelegate: myLoginDelegate?
    
    private var keyboardDisplayed: Bool = false
    
    override func viewDidLoad()
    {
        btnExisting.isEnabled = false
     
        let myReachability = Reachability()
        if myReachability.isConnectedToNetwork()
        {
            btnNew.isEnabled = true
            txtEmail.isEnabled = true
            txtCode.isEnabled = true
        }
        else
        {
            // Not connected to Internet

            btnNew.isEnabled = false
            txtEmail.isEnabled = false
            txtCode.isEnabled = false
        }
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let myReachability = Reachability()
        if !myReachability.isConnectedToNetwork()
        {
            let alert = UIAlertController(title: "Team Maintenance", message: "You must be connected to the Internet to create or edit teams", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnNew(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
        loginDelegate?.orgEdit(nil)
    }

    @IBAction func btnExisting(_ sender: UIButton)
    {
        

    }
    
    @IBAction func txtEntry(_ sender: UITextField)
    {
        if txtCode.text!.characters.count > 0 && txtEmail.text!.characters.count > 0
        {
            btnExisting.isEnabled = true
        }
        else
        {
            btnExisting.isEnabled = false
        }
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        let deviceIdiom = getDeviceType()
        
        if deviceIdiom == .pad
        {
            if !keyboardDisplayed
            {
                newTextHeightConstraint.constant = newTextHeightConstraint.constant - 100
                newButtonVerticalConstraint.constant = newButtonVerticalConstraint.constant - 100
                newTextVerticalConstraint.constant = newTextVerticalConstraint.constant - 100
                
                keyboardDisplayed = true
            }
        }
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        let deviceIdiom = getDeviceType()
        
        if deviceIdiom == .pad
        {
            newTextHeightConstraint.constant = newTextHeightConstraint.constant + 100
            newButtonVerticalConstraint.constant = newButtonVerticalConstraint.constant + 100
            newTextVerticalConstraint.constant = newTextVerticalConstraint.constant + 100
            
            keyboardDisplayed = false
        }
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
    }
}
