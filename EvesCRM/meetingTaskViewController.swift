//
//  meetingTaskViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 22/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MyMeetingTaskDelegate
{
    func myMeetingTaskDidFinish(controller:meetingTaskViewController, actionType: String)
}

class meetingTaskViewController: UIViewController
{
    var delegate: MyMeetingTaskDelegate?
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblTaskTitle: UILabel!
    @IBOutlet weak var lblTaskDescription: UILabel!
    @IBOutlet weak var lblTargetDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblUpdateHistory: UILabel!
    @IBOutlet weak var lblAddUpdate: UILabel!
    @IBOutlet weak var lblUpdateSource: UILabel!
    @IBOutlet weak var lblUpdateDetails: UILabel!
    @IBOutlet weak var btnAddUpdate: UIButton!
    @IBOutlet weak var txtTaskTitle: UITextField!
    @IBOutlet weak var txtTaskDescription: UITextView!
    @IBOutlet weak var txtUpdateSource: UITextField!
    @IBOutlet weak var txtUpdateDetails: UITextView!
    @IBOutlet weak var colHistory: UICollectionView!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var btnTargetDate: UIButton!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var btnStatus: UIButton!
    
    private let resuseID = "historyCell"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
 //       colHistory.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func btnCancel(sender: UIButton)
    {
        delegate?.myMeetingTaskDidFinish(self, actionType: "Cancel")
    }
    
    @IBAction func btnSave(sender: UIButton)
    {
        delegate?.myMeetingTaskDidFinish(self, actionType: "Changed")
    }
    
    @IBAction func btnAddUpdate(sender: UIButton)
    {

    }
    
    @IBAction func btnTargetDate(sender: UIButton)
    {

    }
    
    @IBAction func btnOwner(sender: UIButton)
    {

    }
    
    @IBAction func btnStatus(sender: UIButton)
    {

    }
    
}

class myHistory: UICollectionViewCell
{
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var txtUpdate: UITextView!
    @IBOutlet weak var lblSource: UILabel!
}