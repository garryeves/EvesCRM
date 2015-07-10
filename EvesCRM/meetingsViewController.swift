//
//  meetingsViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 7/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MyMeetingsDelegate{
    func myMeetingsDidFinish(controller:meetingsViewController)
}

class meetingsViewController: UIViewController {

    var delegate: MyMeetingsDelegate?
    
    @IBOutlet weak var lblMeetingHead: UILabel!
    @IBOutlet weak var lblLocationHead: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblAT: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblTo: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblMeetingName: UILabel!
    @IBOutlet weak var lblChairHead: UILabel!
    @IBOutlet weak var lblMinutesHead: UILabel!
    @IBOutlet weak var lblAttendeesHead: UILabel!
    @IBOutlet weak var colAttendees: UICollectionView!
    @IBOutlet weak var btnChair: UIButton!
    @IBOutlet weak var btnMinutes: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblAddAttendee: UILabel!
    @IBOutlet weak var txtAttendeeName: UITextField!
    @IBOutlet weak var txtAttendeeEmail: UITextField!
    @IBOutlet weak var btnAddAttendee: UIButton!
    @IBOutlet weak var txtAttendeeStatus: UITextField!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    var event: myCalendarItem!
    
    private let reuseAttendeeIdentifier = "AttendeeCell"
    private let reuseAttendeeStatusIdentifier = "AttendeeStatusCell"
    private let reuseAttendeeAction = "AttendeeActionCell"
    
    
    private var searches = Array<Array<String>>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if event.attendees.count == 0
        {
            event.populateAttendeesFromInvite()
        }
        
  println ("incoming id = \(event.title)")


    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return event.attendees.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell : MyDisplayCollectionViewCell!
        
        if indexPath.indexAtPosition(1) == 0
        {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAttendeeIdentifier, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
            cell.Label.text = event.attendees[indexPath.indexAtPosition(0)].name
        }
        
        if indexPath.indexAtPosition(1) == 1
        {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAttendeeStatusIdentifier, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
            cell.Label.text = event.attendees[indexPath.indexAtPosition(0)].status
        }
        
        if indexPath.indexAtPosition(1) == 2
        {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAttendeeAction, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
            cell.Label.text = "Remove"
        }
    
        cell.Label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    
        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        if (indexPath.indexAtPosition(0) % 2 == 0)  // was .row
        {
            cell.backgroundColor = swiftColor
        }
        else
        {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MyDisplayCollectionViewCell
        if indexPath.indexAtPosition(1) == 0
        {
            println("Clicked Attendee \(cell.Label.text!)")
        }
        
        if indexPath.indexAtPosition(1) == 1
        {
            println("Clicked Status \(cell.Label.text!)")
        }

        if indexPath.indexAtPosition(1) == 2
        {
            event.removeAttendee(indexPath.indexAtPosition(0))
            colAttendees.reloadData()
        }

    }

    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        if indexPath.indexAtPosition(1) == 0
        {
            retVal = CGSize(width: 200, height: 40)
        }
        if indexPath.indexAtPosition(1) == 1
        {
            retVal = CGSize(width: 100, height: 40)
        }
        if indexPath.indexAtPosition(1) == 2
        {
            retVal = CGSize(width: 80, height: 40)
        }
        
        return retVal
    }
    
    @IBAction func btnChairClick(sender: UIButton)
    {
    }
    
    
    @IBAction func btnMinutes(sender: UIButton)
    {
    }
    
    @IBAction func btnBackClick(sender: UIButton)
    {
        delegate?.myMeetingsDidFinish(self)
    }
    
    @IBAction func btnAddAttendee(sender: UIButton)
    {
        if txtAttendeeName.text == ""
        {
            var alert = UIAlertController(title: "Agenda", message:
                "You need to enter the name of the attendee", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        }
        else
        {
            event.addAttendee(txtAttendeeName.text, inEmailAddress: txtAttendeeEmail.text, inType: "Participant" , inStatus: txtAttendeeStatus.text)
            colAttendees.reloadData()
            
            txtAttendeeName.text = ""
            txtAttendeeEmail.text = ""
        }
    }
    
    
    @IBAction func txtAttendeeStatus(sender: UITextField)
    {
        
        // need to display a picker here
    }
}

class MyDisplayCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var Label: UILabel! = UILabel()
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        Label.text = ""
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Label.text = ""
    }
}
