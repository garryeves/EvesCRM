//
//  GTDInbox.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 25/09/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MyGTDInboxDelegate
{
    func myGTDInboxDidFinish(controller:GTDInboxViewController)
}

class GTDInboxViewController: UIViewController, UIPopoverPresentationControllerDelegate
{
    var delegate: MyGTDInboxDelegate?
    
    @IBOutlet weak var colGTDInbox: UICollectionView!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var colEmailInbox: UICollectionView!
    
    private var myTaskList: [task] = Array()
    
    private let cellGTDInbox = "cellGTDInbox"
    private let cellEmailInbox = "cellEmailInbox"
    private var myGmailMessages: gmailMessages!
    private var myGmailData: gmailData!
    
    private var myGmailEmails: [gmailMessage] = Array()
    private var gmailDisplayMessage: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gmailSignedIn:", name:"NotificationGmailInboxConnected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "myGmailDidFinish", name:"NotificationGmailInboxLoadDidFinish", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayTask:", name:"NotificationGTDInboxDisplayTask", object: nil)
        
        loadDataArray()
        
        gmailDisplayMessage = "Retrieving GMail messages.  Screen will refresh when done."
        
        if myGmailData == nil
        {
            myGmailData = gmailData()
            myGmailData.sourceViewController = self
            myGmailData.connectToGmail()
        }
        else
        {
            loadEmailArray()
        }
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        colGTDInbox.collectionViewLayout.invalidateLayout()
        
        colGTDInbox.reloadData()
        colEmailInbox.reloadData()
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            delegate?.myGTDInboxDidFinish(self)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == colGTDInbox
        {
            return myTaskList.count
        }
        else
        {
            if myGmailEmails.count == 0
            {
                return 1
            }
            else
            {
                return myGmailEmails.count
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if collectionView == colGTDInbox
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellGTDInbox, forIndexPath: indexPath) as! myGTDInboxItem
        
            cell.lblName.text = myTaskList[indexPath.row].title
        
            if (indexPath.row % 2 == 0)
            {
                cell.backgroundColor = myRowColour
            }
            else
            {
                cell.backgroundColor = UIColor.clearColor()
            }
        
            cell.layoutSubviews()
        
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellEmailInbox, forIndexPath: indexPath) as! myEmailInboxItem
            
            if myGmailEmails.count > 0
            {
                cell.lblDate.text = myGmailEmails[indexPath.row].dateReceived
                cell.lblFrom.text = myGmailEmails[indexPath.row].from
                cell.lblSubject.text = myGmailEmails[indexPath.row].subject
                cell.btnCreate.hidden = false
                cell.emailMessage = myGmailEmails[indexPath.row]
            }
            else
            {
                cell.lblDate.text = ""
                cell.lblFrom.text = ""
                cell.lblSubject.text = gmailDisplayMessage
                cell.btnCreate.hidden = true
            }
            
            if (indexPath.row % 2 == 0)
            {
                cell.backgroundColor = myRowColour
            }
            else
            {
                cell.backgroundColor = UIColor.clearColor()
            }
            
            cell.layoutSubviews()
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if collectionView == colGTDInbox
        {
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("tasks") as! taskViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
        
            popoverContent.passedTask = myTaskList[indexPath.row]
            popoverContent.preferredContentSize = CGSizeMake(700,700)
            popover!.sourceRect = CGRectMake(0, 0, 700, 700)
        
            self.presentViewController(popoverContent, animated: true, completion: nil)
        }
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
     
        if collectionView == colGTDInbox
        {
            retVal = CGSize(width: colGTDInbox.bounds.size.width, height: 39)
        }
        else
        {
            retVal = CGSize(width: colEmailInbox.bounds.size.width, height: 39)
        }
        return retVal
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        if collectionView == colGTDInbox
        {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "cellGTDItemHeader", forIndexPath: indexPath) as! myGTDInboxHeaderItem
            
            return headerView
        }
        else
        {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "cellEmailInboxHeader", forIndexPath: indexPath) as! myEmailInboxHeaderItem
            
            return headerView
        }
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .FullScreen
        // return .None
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController?
    {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController)
    {
        myGmailDidFinish()
    }

    func loadDataArray()
    {
        // Get a list fo my teams
        myTaskList.removeAll()
        
        for myTeam in myDatabaseConnection.getMyTeams(myID)
        {
            // Get list of tasks without a Project
    
            let projectArray =  myDatabaseConnection.getTasksWithoutProject(myTeam.teamID as Int)
        
            // Get list of tasks without a context
            
            let contextArray = myDatabaseConnection.getTaskWithoutContext(myTeam.teamID as Int)
        
        
            for myProjectTask in projectArray
            {
                let tempTask = task(taskID: myProjectTask.taskID as Int)
                myTaskList.append(tempTask)
            }
            
            for myContextTask in contextArray
            {
                // parse through array of tasks from project to see if the task from context already exists, if it does then no action needed, if does not exist then add the task from context
                let tempTask = task(taskID: myContextTask.taskID as Int)
                
                var taskFound: Bool = false
                
                for myItem in myTaskList
                {
                    if myItem.taskID == tempTask.taskID
                    {
                        // Match found
                        taskFound = true
                        break
                    }
                }
                
                if !taskFound
                {
                    myTaskList.append(tempTask)
                }
            }
        }
    }
    
    func loadEmailArray()
    {
        if myGmailMessages == nil
        {
            myGmailMessages = gmailMessages(inGmailData: myGmailData)
        }
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0))
        {
            self.myGmailMessages.getInbox()
        }
    }
    
    func myGmailDidFinish()
    {
        myGmailEmails.removeAll()
        
        if myGmailMessages.messages.count == 0
        {
            gmailDisplayMessage = "No GMail emails found."
        }
        else
        {
            for myMessage in myGmailMessages.messages
            {
                let myCheckEmail = myDatabaseConnection.getProcessedEmail(myMessage.id)
                if myCheckEmail.count == 0
                {
                    myGmailEmails.append(myMessage)
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue())
        {
            self.colEmailInbox.reloadData() // reload table/data or whatever here. However you want.
        }

    }
    
    func gmailSignedIn(notification: NSNotification)
    {
        loadEmailArray()
    }
    
    @IBAction func btnEmail(sender: UIButton)
    {
        NSLog("To do once I have multple email accounts available")
    }
    
    func displayTask(notification: NSNotification)
    {
        let newTask = notification.userInfo!["task"] as! task
        
        let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("tasks") as! taskViewController
        popoverContent.modalPresentationStyle = .Popover
        let popover = popoverContent.popoverPresentationController
        popover!.delegate = self
        popover!.sourceView = self.view
        
        popoverContent.passedTask = newTask
        
        popoverContent.preferredContentSize = CGSizeMake(700,700)
        
        popover!.sourceRect = CGRectMake(0, 0, 700, 700)
        self.presentViewController(popoverContent, animated: true, completion: nil)
    }
}

class myGTDInboxHeaderItem: UICollectionViewCell
{
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class myGTDInboxItem: UICollectionViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnCloseTask: UIButton!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class myEmailInboxHeaderItem: UICollectionViewCell
{
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class myEmailInboxItem: UICollectionViewCell
{
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblFrom: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var btnCreate: UIButton!
    
    var emailMessage: gmailMessage!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnCreate(sender: UIButton)
    {
        let newTask = task(inTeamID: myCurrentTeam.teamID)
        newTask.title = emailMessage.subject
        
        var myBody: String = emailMessage.from
        myBody += "\n"
        myBody += emailMessage.dateReceived
        myBody += "\n\n\n"
        myBody += emailMessage.body
        
        newTask.details = myBody
        
        myDatabaseConnection.saveProcessedEmail(emailMessage.id, emailType: "GMail", processedDate: NSDate())
        NSLog("need something here to do the context")

        NSNotificationCenter.defaultCenter().postNotificationName("NotificationGTDInboxDisplayTask", object: nil, userInfo:["task":newTask])
    }
}