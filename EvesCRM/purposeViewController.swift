//
//  purposeViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 27/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation


class purposeViewController: UIViewController, UITextViewDelegate
{
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var txtStatus: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        txtNotes.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        txtNotes.delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
/*
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        //       projectNameText.endEditing(true)
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            passedGTD.delegate.myGTDPlanningDidFinish(self)
        }
    }
*/


    
}