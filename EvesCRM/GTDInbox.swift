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
    
    private var myTaskList: [task] = Array()
    private let cellGTDInbox = "cellGTDInbox"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadDataArray()
        
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
        return myTaskList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
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
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colGTDInbox.bounds.size.width, height: 39)
        
        return retVal
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "cellGTDItemHeader", forIndexPath: indexPath) as! myGTDInboxHeaderItem
        
        return headerView
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