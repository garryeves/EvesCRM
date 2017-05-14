//
//  userFormViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 14/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class userFormViewController: UIViewController
{
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnPassPhrase: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblPhrase: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    var workingUser: userItem!
    
    override func viewDidLoad()
    {
        if workingUser != nil
        {
            populateForm()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnSave(_ sender: UIButton)
    {
        workingUser.name = txtName.text!
        workingUser.email = txtEmail.text!
            
        workingUser.save()
    }
    
    @IBAction func btnCancel(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnPassPhrase(_ sender: UIButton)
    {
        workingUser.generatePassPhrase()
        lblPhrase.text = workingUser.passPhrase
        lblDate.text = workingUser.phraseDateText
    }
    
    func populateForm()
    {
        txtName.text = workingUser.name
        txtEmail.text = workingUser.email
        lblPhrase.text = workingUser.passPhrase
        lblDate.text = workingUser.phraseDateText
    }
}

