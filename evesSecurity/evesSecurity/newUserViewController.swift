//
//  newUserViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class newInstanceViewController: UIViewController
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
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
