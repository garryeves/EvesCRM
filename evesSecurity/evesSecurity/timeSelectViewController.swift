//
//  timeSelectViewController.swift
//  GroupFitness
//
//  Created by Garry Eves on 16/03/2016.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation

import UIKit

class timeSelectViewController: UIViewController
{
    @IBOutlet weak var txtMins: UITextField!
    @IBOutlet weak var txtSecs: UITextField!
    @IBOutlet weak var btnSelect: UIBarButtonItem!
    
    var pickerValues: Double?
    var source: String?
    var delegate: MyPickerDelegate?
    
    private var selectedRow: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if pickerValues! > 0.0
        {
            
            let numMins: Int = Int(floor(pickerValues! / 60))
            let numSecs: Int = Int(pickerValues!) - (numMins * 60)
            txtMins.text = "\(numMins)"
            txtSecs.text = "\(numSecs)"
        }
        else
        {
            txtMins.text = "0"
            txtSecs.text = "0"
        }
        
        btnSelect.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func txtMins(_ sender: UITextField)
    {
        if sender.text! == ""
        {
            btnSelect.isEnabled = false
        }
        else
        {
            if Int(sender.text!)! > 59
            {
                btnSelect.isEnabled = false
            }
            else
            {
                btnSelect.isEnabled = true
            }
        }
    }
    
    @IBAction func txtSecs(_ sender: UITextField)
    {
        if sender.text! == ""
        {
            btnSelect.isEnabled = false
        }
        else
        {
            if Int(sender.text!)! > 59
            {
                btnSelect.isEnabled = false
            }
            else
            {
                btnSelect.isEnabled = true
            }
        }
    }
    
    @IBAction func btnSelect(_ sender: UIBarButtonItem)
    {
        // work out the new time value
        
        pickerValues = Double((Int(txtMins.text!)! * 60)) + Double(txtSecs.text!)!
        
        delegate!.myPickerDidFinish!(source!, selectedDouble: pickerValues!)
        dismiss(animated: true, completion: nil)
    }
}
