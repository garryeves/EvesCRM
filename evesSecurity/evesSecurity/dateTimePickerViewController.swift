//
//  dateTimePickerViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 14/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UIKit

class dateTimePickerView: UIViewController
{
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnSelect: UIBarButtonItem!
    
    var currentDate: Date!
    var source: String?
    var delegate: MyPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        datePicker.minimumDate = Date()
        
        if currentDate != nil
        {
            datePicker.date = currentDate
        }
        else
        {
            datePicker.date = Date()
        }
        
        btnSelect.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker)
    {
        btnSelect.isEnabled = true
    }
    
    @IBAction func btnSelect(_ sender: UIBarButtonItem)
    {
        delegate!.myPickerDidFinish!(source!, selectedDate: datePicker.date)
        dismiss(animated: true, completion: nil)
    }
}
