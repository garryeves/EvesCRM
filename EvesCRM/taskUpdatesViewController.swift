//
//  taskUpdatesViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 31/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

//protocol MyTaskDelegate
//{
//    func myTaskDidFinish(controller:taskViewController, actionType: String, currentTask: task)
//}

class taskUpdatesViewController: UIViewController
{
    private var passedTask: TaskModel!
    
    @IBOutlet weak var lblAddUpdate: UILabel!
    @IBOutlet weak var lblUpdateSource: UILabel!
    @IBOutlet weak var lblUpdateDetails: UILabel!
    @IBOutlet weak var btnAddUpdate: UIButton!
    @IBOutlet weak var txtUpdateSource: UITextField!
    @IBOutlet weak var txtUpdateDetails: UITextView!
    @IBOutlet weak var colHistory: UICollectionView!
    
    private let resuseID = "historyCell"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        txtUpdateDetails.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtUpdateDetails.layer.borderWidth = 0.5
        txtUpdateDetails.layer.cornerRadius = 5.0
        txtUpdateDetails.layer.masksToBounds = true
        
        passedTask = (tabBarController as! tasksTabViewController).myPassedTask
        
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
        colHistory.collectionViewLayout.invalidateLayout()
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            // Move to previous item in tab hierarchy
            
            let myCurrentTab = self.tabBarController
            
            myCurrentTab!.selectedIndex = myCurrentTab!.selectedIndex - 1
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return passedTask.currentTask.history.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell : myHistory!
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(resuseID, forIndexPath: indexPath) as! myHistory
        
        if passedTask.currentTask.history.count > 0
        {
            cell.lblDate.text = passedTask.currentTask.history[indexPath.row].displayUpdateDate
            cell.lblSource.text = passedTask.currentTask.history[indexPath.row].source
            cell.txtUpdate.text = passedTask.currentTask.history[indexPath.row].details
            
            let fixedWidth = cell.txtUpdate.frame.size.width
            cell.txtUpdate.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            let newSize = cell.txtUpdate.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            var newFrame = cell.txtUpdate.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            cell.txtUpdate.frame = newFrame;
        }
        else
        {
            cell.lblDate.text = ""
            cell.txtUpdate.text = ""
            cell.lblSource.text = ""
        }
        
        if (indexPath.row % 2 == 0)  // was .row
        {
            cell.backgroundColor = myRowColour
            cell.txtUpdate.backgroundColor = myRowColour
        }
        else
        {
            cell.backgroundColor = UIColor.clearColor()
            cell.txtUpdate.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        var headerView:UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader
        {
            headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "taskItemHeader", forIndexPath: indexPath) as! UICollectionReusableView
        }
        
        return headerView
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colHistory.bounds.size.width, height: 80)
        
        //retVal = CGSize(width: colHistory.bounds.size.width, height: 39)
        
        return retVal
    }
    
    @IBAction func btnAddUpdate(sender: UIButton)
    {
        if count(txtUpdateDetails.text) > 0 && count(txtUpdateSource.text) > 0
        {
            passedTask.currentTask.addHistoryRecord(txtUpdateDetails.text, inHistorySource: txtUpdateSource.text)
            txtUpdateDetails.text = ""
            txtUpdateSource.text = ""
            colHistory.reloadData()
        }
        else
        {
            var alert = UIAlertController(title: "Add Task Update", message:
                "You need to enter update details and source", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
        }
    }    
}

class myHistory: UICollectionViewCell
{
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var txtUpdate: UITextView!
    @IBOutlet weak var lblSource: UILabel!
}