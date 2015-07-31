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
    
    private let reuseAgendaTime = "reuseAgendaTime"
    private let reuseAgendaTitle = "reuseAgendaTitle"
    private let reuseAgendaOwner = "reuseAgendaOwner"
    private let reuseAgendaAction = "reuseAgendaAction"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        passedMeeting = (tabBarController as! meetingTabViewController).myPassedMeeting

        passedMeeting.event.saveAgenda()
        
        if passedMeeting.actionType != "Agenda"
        {
            btnAddAgendaItem.hidden = true
        }
        
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
    
    @IBAction func btnBackClick(sender: UIButton)
    {
        passedMeeting.delegate.myMeetingsAgendaDidFinish(self)
    }
    
    @IBAction func btnAddAgendaItem(sender: UIButton)
    {
        let agendaViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("AgendaItems") as! agendaItemViewController
        agendaViewControl.delegate = self
        agendaViewControl.event = passedMeeting.event
        agendaViewControl.actionType = passedMeeting.actionType
        
        let newAgendaItem = meetingAgendaItem(inMeetingID: passedMeeting.event.eventID)
        agendaViewControl.agendaItem = newAgendaItem
        
        self.presentViewController(agendaViewControl, animated: true, completion: nil)
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

