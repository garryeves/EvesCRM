//
//  meetingAgendaViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 31/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

class meetingAgendaViewController: UIViewController, MyAgendaItemDelegate
{
    
    private var passedMeeting: MeetingModel!
    
    @IBOutlet weak var lblAgendaItems: UILabel!
    @IBOutlet weak var colAgenda: UICollectionView!
    @IBOutlet weak var btnAddAgendaItem: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblAddAgendaItem: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTimeAllocation: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtTimeAllocation: UITextField!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var myPicker: UIPickerView!
    
    private let reuseAgendaTime = "reuseAgendaTime"
    private let reuseAgendaTitle = "reuseAgendaTitle"
    private let reuseAgendaOwner = "reuseAgendaOwner"
    private let reuseAgendaAction = "reuseAgendaAction"
    
    private var pickerOptions: [String] = Array()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        passedMeeting = (tabBarController as! meetingTabViewController).myPassedMeeting

        passedMeeting.event.saveAgenda()
        
        if passedMeeting.actionType != "Agenda"
        {
            btnAddAgendaItem.hidden = true
        }
        
        myPicker.hidden = true
        
        btnOwner.setTitle("Select Owner", forState: .Normal)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAgendaItem:", name:"NotificationUpdateAgendaItem", object: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        colAgenda.collectionViewLayout.invalidateLayout()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return passedMeeting.event.agendaItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell: myAgendaItem!
            
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAgendaTime, forIndexPath: indexPath) as! myAgendaItem
        cell.lblTime.text = "\(passedMeeting.event.agendaItems[indexPath.row].timeAllocation)"
        cell.lblItem.text = passedMeeting.event.agendaItems[indexPath.row].title
        cell.lblOwner.text = passedMeeting.event.agendaItems[indexPath.row].owner
        cell.btnAction.setTitle("Update", forState: .Normal)
        cell.btnAction.tag = indexPath.row
            
        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        if (indexPath.row % 2 == 0)  // was .row
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
    {  // Leaving stub in here for use in other collections
        
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var headerView:UICollectionReusableView!

        if kind == UICollectionElementKindSectionHeader
        {
        headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "agendaItemHeader", forIndexPath: indexPath) as! UICollectionReusableView
        }
        return headerView
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSize(width: colAgenda.bounds.size.width, height: 39)
    }
    
    func numberOfComponentsInPickerView(TableTypeSelection1: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerOptions[row]
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Write code for select
        btnOwner.setTitle(pickerOptions[row], forState: .Normal)
        
        myPicker.hidden = true
        showFields()
    }

    @IBAction func btnBackClick(sender: UIButton)
    {
        passedMeeting.delegate.myMeetingsAgendaDidFinish(self)
    }
    
    @IBAction func btnAddAgendaItem(sender: UIButton)
    {
        if txtDescription.text == ""
        {
            var alert = UIAlertController(title: "Add Agenda Item", message:
        "You must provide a description for the Agenda Item before you can Add it", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
    
            self.presentViewController(alert, animated: false, completion: nil)
        }
        else
        {
            let agendaItem = meetingAgendaItem(inMeetingID: passedMeeting.event.eventID)
            agendaItem.status = "Open"
            agendaItem.decisionMade = ""
            agendaItem.discussionNotes = ""
            if txtTimeAllocation.text == ""
            {
                agendaItem.timeAllocation = 10
            }
            else
            {
                agendaItem.timeAllocation = txtTimeAllocation.text.toInt()!
            }
            if btnOwner.currentTitle != "Select Owner"
            {
                agendaItem.owner = btnOwner.currentTitle!
            }
        
            agendaItem.title = txtDescription.text
        
            agendaItem.save()

            // reload the Agenda Items collection view
            passedMeeting.event.loadAgendaItems()
            colAgenda.reloadData()
            passedMeeting.event.saveAgenda()
        
            // set the fields to blank
        
            txtTimeAllocation.text = ""
            txtDescription.text = ""
            btnOwner.setTitle("Select Owner", forState: .Normal)
        }
    }
    
    @IBAction func btnOwner(sender: UIButton)
    {
        pickerOptions.removeAll(keepCapacity: false)
        for attendee in passedMeeting.event.attendees
        {
            pickerOptions.append(attendee.name)
        }
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
    }
    
    func hideFields()
    {
        lblAgendaItems.hidden = true
        colAgenda.hidden = true
        btnAddAgendaItem.hidden = true
        lblAddAgendaItem.hidden = true
        lblDescription.hidden = true
        lblTimeAllocation.hidden = true
        txtDescription.hidden = true
        txtTimeAllocation.hidden = true
        lblOwner.hidden = true
        btnOwner.hidden = true
    }
    
    func showFields()
    {
        lblAgendaItems.hidden = false
        colAgenda.hidden = false
        btnAddAgendaItem.hidden = false
        lblAddAgendaItem.hidden = false
        lblDescription.hidden = false
        lblTimeAllocation.hidden = false
        txtDescription.hidden = false
        txtTimeAllocation.hidden = false
        lblOwner.hidden = false
        btnOwner.hidden = false
    }

    func myAgendaItemDidFinish(controller:agendaItemViewController, actionType: String)
    {
        if actionType == "Cancel"
        {
            // Do nothing.  Including for calrity
        }
        else
        {
            // reload the Agenda Items collection view
            passedMeeting.event.loadAgendaItems()
            colAgenda.reloadData()
            passedMeeting.event.saveAgenda()
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateAgendaItem(notification: NSNotification)
    {
        passedMeeting.event.saveAgenda()
        let itemToUpdate = notification.userInfo!["itemNo"] as! Int
        
        let agendaViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("AgendaItems") as! agendaItemViewController
        agendaViewControl.delegate = self
        agendaViewControl.event = passedMeeting.event
        agendaViewControl.actionType = passedMeeting.actionType
        
        let agendaItem = passedMeeting.event.agendaItems[itemToUpdate]
        agendaViewControl.agendaItem = agendaItem
        
        self.presentViewController(agendaViewControl, animated: true, completion: nil)
    }
}

class myAgendaItemHeader: UICollectionReusableView
{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblAction: UILabel!
}

class myAgendaItem: UICollectionViewCell
{
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    
    @IBAction func btnAction(sender: UIButton)
    {
        if btnAction.currentTitle == "Update"
        {
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationUpdateAgendaItem", object: nil, userInfo:["itemNo":btnAction.tag])
        }
    }
}

