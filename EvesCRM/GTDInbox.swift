//
//  GTDInbox.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 25/09/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit

protocol MyGTDInboxDelegate
{
    func myGTDInboxDidFinish(_ controller:GTDInboxViewController)
}

class GTDInboxViewController: UIViewController, UIPopoverPresentationControllerDelegate
{
    var delegate: MyGTDInboxDelegate?
    
    @IBOutlet weak var colGTDInbox: UICollectionView!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var colEmailInbox: UICollectionView!
    @IBOutlet weak var myPicker: UIPickerView!
    
    fileprivate var myTaskList: [task] = Array()
    
    fileprivate let cellGTDInbox = "cellGTDInbox"
    fileprivate let cellEmailInbox = "cellEmailInbox"
    fileprivate var myGmailMessages: gmailMessages!
    fileprivate var myGmailData: gmailData!
    
    fileprivate var myGmailEmails: [gmailMessage] = Array()
    fileprivate var gmailDisplayMessage: String = ""
    
    fileprivate var myPickerOptions = ["Select Email Inbox", "GMail Inbox"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(self.gmailSignedIn(_:)), name: NotificationGmailInboxConnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.myGmailDidFinish), name: NotificationGmailInboxLoadDidFinish, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.displayTask(_:)), name: NotificationGTDInboxDisplayTask, object: nil)
        
        loadDataArray()
        
        myPicker.isHidden = true
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
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
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
        {
            // Do nothing
        }
        else
        {
            delegate?.myGTDInboxDidFinish(self)
        }
    }
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return myPickerOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return myPickerOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        btnEmail.setTitle(myPickerOptions[row], for: .normal)
        
        hidePicker()
        
        if myPickerOptions[row] == "GMail Inbox"
        {
            myGmailEmails.removeAll()
            
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
        }
        
    }
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
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
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == colGTDInbox
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellGTDInbox, for: indexPath as IndexPath) as! myGTDInboxItem
        
            cell.lblName.text = myTaskList[indexPath.row].title
        
            if (indexPath.row % 2 == 0)
            {
                cell.backgroundColor = myRowColour
            }
            else
            {
                cell.backgroundColor = UIColor.clear
            }
        
            cell.layoutSubviews()
        
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellEmailInbox, for: indexPath as IndexPath) as! myEmailInboxItem
            
            if myGmailEmails.count > 0
            {
                cell.lblDate.text = myGmailEmails[indexPath.row].dateReceived
                cell.lblFrom.text = myGmailEmails[indexPath.row].from
                cell.lblSubject.text = myGmailEmails[indexPath.row].subject
                cell.btnCreate.isHidden = false
                cell.emailMessage = myGmailEmails[indexPath.row]
            }
            else
            {
                cell.lblDate.text = ""
                cell.lblFrom.text = ""
                cell.lblSubject.text = gmailDisplayMessage
                cell.btnCreate.isHidden = true
            }
            
            if (indexPath.row % 2 == 0)
            {
                cell.backgroundColor = myRowColour
            }
            else
            {
                cell.backgroundColor = UIColor.clear
            }
            
            cell.layoutSubviews()
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath)
    {
        if collectionView == colGTDInbox
        {
            let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "tasks") as! taskViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
        
            popoverContent.passedTask = myTaskList[indexPath.row]
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            popover!.sourceRect = CGRect(x: 0, y: 0, width: 700, height: 700)
        
            self.present(popoverContent, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        if collectionView == colGTDInbox
        {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cellGTDItemHeader", for: indexPath as IndexPath) as! myGTDInboxHeaderItem
            
            return headerView
        }
        else
        {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cellEmailInboxHeader", for: indexPath as IndexPath) as! myEmailInboxHeaderItem
            
            return headerView
        }
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .fullScreen
        // return .None
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController?
    {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController)
    {
        if btnEmail.currentTitle == "GMail Inbox"
        {
            myGmailDidFinish()
        }
    }

    func loadDataArray()
    {
        // Get a list fo my teams
        myTaskList.removeAll()
        
        for myTeam in myDatabaseConnection.getMyTeams(myID)
        {
            // Get list of tasks without a Project
    
            let projectArray =  myDatabaseConnection.getTasksWithoutProject(myTeam.teamID)
        
            // Get list of tasks without a context
            
            let contextArray = myDatabaseConnection.getTaskWithoutContext(myTeam.teamID)
        
        
            for myProjectTask in projectArray
            {
                let tempTask = task(taskID: myProjectTask.taskID)
                myTaskList.append(tempTask)
            }
            
            for myContextTask in contextArray
            {
                // parse through array of tasks from project to see if the task from context already exists, if it does then no action needed, if does not exist then add the task from context
                let tempTask = task(taskID: myContextTask.taskID)
                
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
        
        DispatchQueue.global(qos: .userInitiated).async
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
        
        DispatchQueue.main.async
        {
            self.colEmailInbox.reloadData() // reload table/data or whatever here. However you want.
        }

    }
    
    func gmailSignedIn(_ notification: Notification)
    {
        loadEmailArray()
    }
    
    @IBAction func btnEmail(_ sender: UIButton)
    {
        displayPicker()
    }
    
    func displayTask(_ notification: Notification)
    {
        let newTask = notification.userInfo!["task"] as! task
        
        let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "tasks") as! taskViewController
        popoverContent.modalPresentationStyle = .popover
        let popover = popoverContent.popoverPresentationController
        popover!.delegate = self
        popover!.sourceView = self.view
        
        popoverContent.passedTask = newTask
        
        popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
        
        popover!.sourceRect = CGRect(x: 0, y: 0, width: 700, height: 700)
        self.present(popoverContent, animated: true, completion: nil)
    }
    
    func displayPicker()
    {
        colGTDInbox.isHidden = true
        btnEmail.isHidden = true
        colEmailInbox.isHidden = true
        myPicker.isHidden = false
    }
    
    func hidePicker()
    {
        colGTDInbox.isHidden = false
        btnEmail.isHidden = false
        colEmailInbox.isHidden = false
        myPicker.isHidden = true
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
    
    @IBAction func btnCreate(_ sender: UIButton)
    {
        let newTask = task(inTeamID: myCurrentTeam.teamID)
        newTask.title = emailMessage.subject
        
        var myBody: String = "From : \(emailMessage.from)"
        myBody += "\n"
        myBody += "Date received : \(emailMessage.dateReceived)"
        myBody += "\n\n\n"
        
        
    //    let plainBody = NSAttributedString(
    //        data: emailMessage.body.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true),
    //        options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
    //        documentAttributes: nil,
    //        error: nil)
        
        let plainBody = emailMessage.body.html2String
        
        myBody += plainBody
        
        newTask.details = myBody
        
        myDatabaseConnection.saveProcessedEmail(emailMessage.id, emailType: "GMail", processedDate: Date())
        NSLog("need something here to do the context")

        notificationCenter.post(name: NotificationGTDInboxDisplayTask, object: nil, userInfo:["task":newTask])
    }
 }
