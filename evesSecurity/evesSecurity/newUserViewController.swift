//
//  newUserViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class newUserViewController: UIViewController
{
    @IBOutlet weak var btnNew: UIButton!
    @IBOutlet weak var btnExisting: UIButton!
    @IBOutlet weak var txtCode: UITextField!
    
    var loginDelegate: myLoginDelegate?
    
    override func viewDidLoad()
    {
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
}
