//
//  GTDPlanning.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 26/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation


enum AdaptiveMode
{
    case Default
    case LandscapePopover
    case AlwaysPopover
}

class MaintainGTDPlanningViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate, KDRearrangeableCollectionViewDelegate, UIGestureRecognizerDelegate
{
    @IBInspectable var popoverOniPhone:Bool = false
    @IBInspectable var popoverOniPhoneLandscape:Bool = true
    
    var passedGTD: GTDModel!
    
    @IBOutlet weak var btnUp: UIButton!
    @IBOutlet weak var colBody: UICollectionView!

    private var myDisplayHeadArray: [AnyObject] = Array()
    private var myDisplayBodyArray: [AnyObject] = Array()
    private var highlightID: Int = 0
//    private var myParentObject: AnyObject!
    private var mySelectedTeam: team!
    private var myHeadObjectType: String = ""
    private var mySavedParentObject: AnyObject!
    private var myHeadCells: [cellDetails] = Array()
    private var myBodyCells: [cellDetails] = Array()
    private var headerSize: CGFloat = 0.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
        myDisplayHeadArray.removeAll()
        
        let myTeamArray = myDatabaseConnection.getAllTeams()
        for myTeamItem in myTeamArray
        {
            let myTeam = team(inTeamID: myTeamItem.teamID as Int)
            myDisplayHeadArray.append(myTeam)
        }
        
        highlightID = myCurrentTeam.teamID
        mySelectedTeam = myCurrentTeam
        buildHead(myCurrentTeam.teamID)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displaySubmenu:", name:"NotificationDisplayGTDSubmenu", object: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        colBody.collectionViewLayout.invalidateLayout()
        colBody.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        myHeadCells.removeAll()
        myBodyCells.removeAll()
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if section == 0
        {
            return myDisplayHeadArray.count
        }
        else if section == 1
        {
            return myDisplayBodyArray.count
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if indexPath.section == 0
        {  // Head
            if myDisplayHeadArray[indexPath.row].isKindOfClass(task)
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellTask", forIndexPath: indexPath) as! myGTDTaskDisplay
                cell.sectionType = "head"
                cell.rowNumber = indexPath.row

                let tempObject = myDisplayHeadArray[indexPath.row] as! task
                
                cell.lblName.text = tempObject.title
                cell.lblStart.text = tempObject.displayStartDate
                cell.lblDue.text = tempObject.displayDueDate

                cell.lblChildren.text = ""
                
                var pass1: Bool = true
                var contextList: String = ""
                
                for myItem in tempObject.contexts
                {
                    if pass1
                    {
                        contextList = myItem.name
                        pass1 = false
                    }
                    else
                    {
                        contextList += ", \(myItem.name)"
                    }
                }
                cell.lblContexts.text = contextList
                
                if highlightID == tempObject.taskID
                {
                    cell.backgroundColor = myRowColour
                }
                else
                {
                    cell.backgroundColor = UIColor.clearColor()
                }
                
                cell.layer.borderColor = UIColor.lightGrayColor().CGColor
                cell.layer.borderWidth = 0.5
                cell.layer.cornerRadius = 5.0
                cell.layer.masksToBounds = true
                
                let myCell = cellDetails()
                myCell.displayView = cell.contentView
                
                myCell.frame = cell.frame
                myHeadCells.append(myCell)
                
                cell.layoutSubviews()
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellBody", forIndexPath: indexPath) as! myGTDDisplay

                cell.sectionType = "head"
                cell.rowNumber = indexPath.row
                if myDisplayHeadArray[indexPath.row].isKindOfClass(team)
                {
                    let tempObject = myDisplayHeadArray[indexPath.row] as! team
                    cell.lblName.text = tempObject.name
                    if tempObject.GTDTopLevel.count == 0
                    {
                    cell.lblChildren.text = ""
                    }
                    else if tempObject.GTDTopLevel.count == 1
                    {
                        cell.lblChildren.text = "1 child record"
                    }
                    else
                    {
                        cell.lblChildren.text = "\(tempObject.GTDTopLevel.count) child records"
                    }
                
                    if highlightID == tempObject.teamID
                    {
                        cell.backgroundColor = myRowColour
                    }
                    else
                    {
                        cell.backgroundColor = UIColor.clearColor()
                    }
                }
                else if myDisplayHeadArray[indexPath.row].isKindOfClass(workingGTDItem)
                {
                    let tempObject = myDisplayHeadArray[indexPath.row] as! workingGTDItem
                
                    cell.lblName.text = tempObject.title
                
                    let myChildRecords = tempObject.children.count
                    if myChildRecords == 0
                    {
                        cell.lblChildren.text = ""
                    }
                    else if myChildRecords == 1
                    {
                        cell.lblChildren.text = "1 child record"
                    }
                    else
                    {
                        cell.lblChildren.text = "\(myChildRecords) child records"
                    }
                
                    if highlightID == tempObject.GTDItemID
                    {
                        cell.backgroundColor = myRowColour
                    }
                    else
                    {
                        cell.backgroundColor = UIColor.clearColor()
                    }
                }
                else if myDisplayHeadArray[indexPath.row].isKindOfClass(project)
                {
                    let tempObject = myDisplayHeadArray[indexPath.row] as! project
                    cell.lblName.text = tempObject.projectName
                
                    let myChildRecords = tempObject.tasks.count
                    if myChildRecords == 0
                    {
                        cell.lblChildren.text = ""
                    }
                    else if myChildRecords == 1
                    {
                        cell.lblChildren.text = "1 child record"
                    }
                    else
                    {
                        cell.lblChildren.text = "\(myChildRecords) child records"
                    }
                
                    if highlightID == tempObject.projectID
                    {
                        cell.backgroundColor = myRowColour
                    }
                    else
                    {
                        cell.backgroundColor = UIColor.clearColor()
                    }
                }
                else if myDisplayHeadArray[indexPath.row].isKindOfClass(context)
                {
                    let tempObject = myDisplayBodyArray[indexPath.row] as! context
                    cell.lblName.text = tempObject.name
                    cell.lblChildren.text = ""
                
                    if highlightID == tempObject.contextID
                    {
                        cell.backgroundColor = myRowColour
                    }
                    else
                    {
                        cell.backgroundColor = UIColor.clearColor()
                    }
                }
                else if myDisplayHeadArray[indexPath.row] is String
                {
                    cell.lblName.text = myDisplayHeadArray[indexPath.row] as? String
                    cell.lblChildren.text = ""
                }

                cell.layer.borderColor = UIColor.lightGrayColor().CGColor
                cell.layer.borderWidth = 0.5
                cell.layer.cornerRadius = 5.0
                cell.layer.masksToBounds = true
                
                let myCell = cellDetails()
                myCell.displayView = cell.contentView
            
                myCell.frame = cell.frame
                myHeadCells.append(myCell)
                
                cell.layoutSubviews()
                return cell
            }
        }
        else
        {  // Body
            if myDisplayBodyArray[indexPath.row].isKindOfClass(task)
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellTask", forIndexPath: indexPath) as! myGTDTaskDisplay
                cell.sectionType = "body"
                cell.rowNumber = indexPath.row
              
                let tempObject = myDisplayBodyArray[indexPath.row] as! task
                
                cell.lblName.text = tempObject.title
                cell.lblStart.text = tempObject.displayStartDate
                cell.lblDue.text = tempObject.displayDueDate
                
                cell.lblChildren.text = ""
                
                var pass1: Bool = true
                var contextList: String = ""
                
                for myItem in tempObject.contexts
                {
                    if pass1
                    {
                        contextList = myItem.name
                        pass1 = false
                    }
                    else
                    {
                        contextList += ", \(myItem.name)"
                    }
                }
                cell.lblContexts.text = contextList
                
                cell.layer.borderColor = UIColor.lightGrayColor().CGColor
                cell.layer.borderWidth = 0.5
                cell.layer.cornerRadius = 5.0
                cell.layer.masksToBounds = true
                
                let myCell = cellDetails()
                myCell.displayView = cell.contentView
                
                myCell.frame = cell.frame
                myBodyCells.append(myCell)
                
                
                cell.layoutSubviews()
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellBody", forIndexPath: indexPath) as! myGTDDisplay

                cell.sectionType = "body"
                cell.rowNumber = indexPath.row
            
                if myDisplayBodyArray[indexPath.row].isKindOfClass(workingGTDItem)
                {
                    let tempObject = myDisplayBodyArray[indexPath.row] as! workingGTDItem
                
                    cell.lblName.text = tempObject.title
                
                    let myChildRecords = tempObject.children.count
                    if myChildRecords == 0
                    {
                        cell.lblChildren.text = ""
                    }
                    else if myChildRecords == 1
                    {
                        cell.lblChildren.text = "1 child record"
                    }
                    else
                    {
                        cell.lblChildren.text = "\(myChildRecords) child records"
                    }
                }
                else if myDisplayBodyArray[indexPath.row].isKindOfClass(project)
                {
                    let tempObject = myDisplayBodyArray[indexPath.row] as! project
                    cell.lblName.text = tempObject.projectName
                
                    let myChildRecords = tempObject.tasks.count
                    if myChildRecords == 0
                    {
                        cell.lblChildren.text = ""
                    }
                    else if myChildRecords == 1
                    {
                        cell.lblChildren.text = "1 child record"
                    }
                    else
                    {
                        cell.lblChildren.text = "\(myChildRecords) child records"
                    }
                }
                else if myDisplayBodyArray[indexPath.row].isKindOfClass(context)
                {
                    let tempObject = myDisplayBodyArray[indexPath.row] as! context
                    cell.lblName.text = tempObject.name
                    cell.lblChildren.text = ""
                }
                else if myDisplayBodyArray[indexPath.row] is String
                {
                    cell.lblName.text = myDisplayBodyArray[indexPath.row] as? String
                    cell.lblChildren.text = ""
                }
            
                cell.backgroundColor = UIColor.clearColor()
                cell.layer.borderColor = UIColor.lightGrayColor().CGColor
                cell.layer.borderWidth = 0.5
                cell.layer.cornerRadius = 5.0
                cell.layer.masksToBounds = true

                let myCell = cellDetails()
                myCell.displayView = cell.contentView
            
                myCell.frame = cell.frame
                myBodyCells.append(myCell)
                
                cell.layoutSubviews()
                return cell
            }
        }
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        if collectionView == colBody
        {
            if indexPath.section == 0
            {
                // Head
                if myDisplayHeadArray[indexPath.row].isKindOfClass(task)
                {
                    retVal = CGSize(width: 310, height: 125)
                }
                else
                {
                    retVal = CGSize(width: 225, height: 125)
                }
            }
            else
            {  // Body
                if myDisplayBodyArray[indexPath.row].isKindOfClass(task)
                {
                    retVal = CGSize(width: 310, height: 125)
                }
                else
                {
                    retVal = CGSize(width: 225, height: 125)
                }
            }
        }
        
        return retVal
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 0
        { // Head
            if myDisplayHeadArray[indexPath.row].isKindOfClass(team)
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! team
                highlightID = tempObject.teamID
                mySelectedTeam = tempObject
                buildBody(tempObject)
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(workingGTDItem)
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! workingGTDItem
                highlightID = tempObject.GTDItemID
                buildBody(tempObject)
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(project)
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! project
                highlightID = tempObject.projectID
                buildBody(tempObject)
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(task)
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! task
                highlightID = tempObject.taskID
                buildBody(tempObject)
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(context)
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! context
                highlightID = tempObject.contextID
                buildBody(tempObject)
            }
            else
            {
                NSLog("didSelectItemAtIndexPath - no class found")
            }
        }
        else 
        {  // Body
            if myDisplayBodyArray[indexPath.row].isKindOfClass(workingGTDItem)
            {
                myDisplayHeadArray = myDisplayBodyArray
                
                let myObject = myDisplayBodyArray[indexPath.row] as! workingGTDItem
                highlightID = myObject.GTDItemID
                
                if myObject.GTDLevel < mySelectedTeam.GTDLevels.count
                {
                    buildHead(highlightID)
                    buildBody(myObject)
                }
                else
                {
                    buildHead(highlightID)
                    buildBody(myObject)
                }
            }
            else if myDisplayBodyArray[indexPath.row].isKindOfClass(project)
            {
                myDisplayHeadArray = myDisplayBodyArray
                
                let myObject = myDisplayBodyArray[indexPath.row] as! project
                highlightID = myObject.projectID
                
                buildHead(highlightID)
                buildBody(myObject)
            }
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "cellSectionHeader", forIndexPath: indexPath) as! GTDHeaderView
        
        if indexPath.section == 0
        {
            if myDisplayHeadArray[indexPath.row].isKindOfClass(team)
            {
                headerView.lblTitle.text = "My Teams"
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(project)
            {
                headerView.lblTitle.text = "My Activities"
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(task)
            {
                headerView.lblTitle.text = "My Actions"
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(context)
            {
                headerView.lblTitle.text = "My Contexts"
            }
            else
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! workingGTDItem
                        
                let tempLevel = workingGTDLevel(inGTDLevel: tempObject.GTDLevel, inTeamID: tempObject.teamID)
                        
                headerView.lblTitle.text = "My \(tempLevel.title)"
            }
        }
        else
        {
            if myDisplayBodyArray.count > 0
            {
                if myDisplayBodyArray[indexPath.row].isKindOfClass(team)
                {
                    headerView.lblTitle.text = "My Teams"
                }
                else if myDisplayBodyArray[indexPath.row].isKindOfClass(project)
                {
                    headerView.lblTitle.text = "My Activities"
                }
                else if myDisplayBodyArray[indexPath.row].isKindOfClass(task)
                {
                    headerView.lblTitle.text = "My Actions"
                }
                else if myDisplayBodyArray[indexPath.row].isKindOfClass(context)
                {
                    headerView.lblTitle.text = "My Contexts"
                }
                else
                {
                    let tempObject = myDisplayBodyArray[indexPath.row] as! workingGTDItem
                        
                    let tempLevel = workingGTDLevel(inGTDLevel: tempObject.GTDLevel, inTeamID: tempObject.teamID)
                        
                    headerView.lblTitle.text = "My \(tempLevel.title)"
                }
            }
            else
            {
                headerView.lblTitle.text = ""
            }
        }
        
        headerSize = headerView.frame.size.height
        
        return headerView
    }
    
    // Start move

    func moveDataItem(toIndexPath : NSIndexPath, fromIndexPath: NSIndexPath) -> Void
    {
        var fromID: Int = 0
        var fromCurrentPredecessor: Int = 0
        
        if fromIndexPath.section == 0
        {
            // Header Section
            NSLog("header todo")
        }
        else
        {
            if fromIndexPath.item > myDisplayBodyArray.count
            {
                NSLog("Do nothing, outside of rearrange")
            }
            else
            {
                if fromIndexPath.item < toIndexPath.item
                {
                    if myDisplayBodyArray[fromIndexPath.item].isKindOfClass(workingGTDItem)
                    {
                        let fromItem = myDisplayBodyArray[fromIndexPath.item] as! workingGTDItem
                        
                        fromID = fromItem.GTDItemID
                        
                        fromCurrentPredecessor = myDatabaseConnection.getGTDItemSuccessor(fromItem.GTDItemID)
                    }

                    if myDisplayBodyArray[fromIndexPath.item].isKindOfClass(project)
                    {
                        let fromItem = myDisplayBodyArray[fromIndexPath.item] as! project

                        fromID = fromItem.projectID
                     
                        fromCurrentPredecessor = myDatabaseConnection.getProjectSuccessor(fromItem.projectID)
                    }

                    if myDisplayBodyArray[toIndexPath.item].isKindOfClass(workingGTDItem)
                    {
                        let toItem = myDisplayBodyArray[toIndexPath.item] as! workingGTDItem
                        
                        toItem.predecessor = fromID
                        
                        // check to make sure will not get circualr reference and then update if possible
                        if !parseForCircularReference(myDisplayBodyArray, movingID: toItem.GTDItemID, predecessorID: fromID)
                        {
                            toItem.predecessor = fromID
                            
                            if fromCurrentPredecessor > 0
                            {
                                let tempSuccessor = workingGTDItem(inGTDItemID: fromCurrentPredecessor, inTeamID: toItem.teamID)
                                tempSuccessor.predecessor = toItem.GTDItemID
                            }
                        }
                        else
                        {
                            let alert = UIAlertController(title: "Move item", message:
                                "Unable to move item as the item being moved is already in the predecessor chain", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alert, animated: false, completion: nil)
                        }
                    }

                    if myDisplayBodyArray[toIndexPath.item].isKindOfClass(project)
                    {
                        let toItem = myDisplayBodyArray[toIndexPath.item] as! project

                        toItem.predecessor = fromID
                        
                        // check to make sure will not get circualr reference and then update if possible
                        if !parseForCircularReference(myDisplayBodyArray, movingID: toItem.projectID, predecessorID: fromID)
                        {
                            toItem.predecessor = fromID
                            
                            if fromCurrentPredecessor > 0
                            {
                                let tempSuccessor = project(inProjectID: fromCurrentPredecessor, inTeamID: toItem.teamID)
                                tempSuccessor.predecessor = toItem.projectID
                            }
                        }
                        else
                        {
                            let alert = UIAlertController(title: "Move item", message:
                                "Unable to move item as the item being moved is already in the predecessor chain", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alert, animated: false, completion: nil)
                        }
                    }
                }
                else
                {
                    if myDisplayBodyArray[fromIndexPath.item].isKindOfClass(workingGTDItem)
                    {
                        let fromItem = myDisplayBodyArray[fromIndexPath.item] as! workingGTDItem
                        fromID = fromItem.GTDItemID
                        
                        // Get any current success
                    
                        fromCurrentPredecessor = myDatabaseConnection.getGTDItemSuccessor(fromItem.GTDItemID)
                    }

                    if myDisplayBodyArray[fromIndexPath.item].isKindOfClass(project)
                    {
                        let fromItem = myDisplayBodyArray[fromIndexPath.item] as! project
                        fromID = fromItem.projectID
                        
                        // Get any current success
                        
                        fromCurrentPredecessor = myDatabaseConnection.getProjectSuccessor(fromItem.projectID)
                    }
                    
                    if myDisplayBodyArray[toIndexPath.item].isKindOfClass(workingGTDItem)
                    {
                        let toItem = myDisplayBodyArray[toIndexPath.item] as! workingGTDItem
                        
                        // check to make sure will not get circualr reference and then update if possible
                        if !parseForCircularReference(myDisplayBodyArray, movingID: toItem.GTDItemID, predecessorID: fromID)
                        {
                            toItem.predecessor = fromID
                            
                            if fromCurrentPredecessor > 0
                            {
                                let tempSuccessor = workingGTDItem(inGTDItemID: fromCurrentPredecessor, inTeamID: toItem.teamID)
                                tempSuccessor.predecessor = toItem.GTDItemID
                            }
                        }
                        else
                        {
                            let alert = UIAlertController(title: "Move item", message:
                                "Unable to move item as the item being moved is already in the predecessor chain", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alert, animated: false, completion: nil)
                        }
                    }
                    
                    if myDisplayBodyArray[toIndexPath.item].isKindOfClass(project)
                    {
                        let toItem = myDisplayBodyArray[toIndexPath.item] as! project
                        
                        // check to make sure will not get circualr reference and then update if possible
                        if !parseForCircularReference(myDisplayBodyArray, movingID: toItem.projectID, predecessorID: fromID)
                        {
                            toItem.predecessor = fromID

                            if fromCurrentPredecessor > 0
                            {
                                let tempSuccessor = project(inProjectID: fromCurrentPredecessor, inTeamID: toItem.teamID)
                                tempSuccessor.predecessor = toItem.projectID
                            }
                        }
                        else
                        {
                            let alert = UIAlertController(title: "Move item", message:
                                "Unable to move item as the item being moved is already in the predecessor chain", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alert, animated: false, completion: nil)
                        }
                    }
                }

                buildBody(mySavedParentObject)
            }
        }

    //    colBody.reloadData()  this is called in buildbody
    }

    func parseForCircularReference(referenceArray: [AnyObject], movingID: Int, predecessorID: Int) -> Bool
    {
        var foundCircularReference: Bool = false
        var checkItemID: Int = 0
        var checkItemPredecessor: Int = 0

        for myItem in referenceArray
        {
            if myItem.isKindOfClass(project)
            {
                let tempProject = myItem as! project
                checkItemID = tempProject.projectID
                checkItemPredecessor = tempProject.predecessor
            }
            
            if checkItemID == predecessorID
            { // this is the record we are searching for
                if checkItemPredecessor == movingID
                { // we have founf a circular reference
                    foundCircularReference = true
                }
                else if checkItemPredecessor > 0
                {  // need to check next item down the line
                    foundCircularReference = parseForCircularReference(referenceArray, movingID: movingID, predecessorID: checkItemPredecessor)
                }
                break
            }
        }
        
        return foundCircularReference
    }
    
    // End move

    @IBAction func btnUp(sender: UIButton)
    {
        switch myHeadObjectType
        {
            case "GTDItem":
                let tempObject = mySavedParentObject as! workingGTDItem
                
                if tempObject.GTDLevel == 1
                {  // parent is a team
                    
                    myDisplayHeadArray.removeAll()
                
                    let myTeamArray = myDatabaseConnection.getAllTeams()
                    for myTeamItem in myTeamArray
                    {
                        let myTeam = team(inTeamID: myTeamItem.teamID as Int)
                        myDisplayHeadArray.append(myTeam)
                    }
                
                    highlightID = tempObject.teamID
                    buildHead(tempObject.teamID)
                }
                else
                { // parent is another GTD level
                    var tempArray: [workingGTDItem] = Array()
                    
                    let myArray = myDatabaseConnection.getGTDItemsForLevel(tempObject.GTDLevel - 1 as Int, inTeamID: tempObject.teamID)
                    for myItem in myArray
                    {
                        let myClass = workingGTDItem(inGTDItemID: myItem.gTDItemID as! Int, inTeamID: tempObject.teamID as Int)
                        tempArray.append(myClass)
                    }
                    
                    myDisplayHeadArray = buildGTDItemArray(tempArray)
                    highlightID = tempObject.GTDParentID
                    buildHead(highlightID)
                }
            
            case "project":
                myDisplayHeadArray.removeAll()
     
                let myObject = mySavedParentObject as! project  // this is the current head record

                let myObject2 = workingGTDItem(inGTDItemID: myObject.GTDItemID, inTeamID: myObject.teamID)  // This is the parent of that
                
                if myObject2.GTDLevel == 1
                {  // parent is a team
                    
                    myDisplayHeadArray.removeAll()
                    
                    let myTeamArray = myDatabaseConnection.getAllTeams()
                    for myTeamItem in myTeamArray
                    {
                        let myTeam = team(inTeamID: myTeamItem.teamID as Int)
                        myDisplayHeadArray.append(myTeam)
                    }
                    
                    highlightID = myCurrentTeam.teamID
                    buildHead(myCurrentTeam.teamID)
                }
                else
                { // parent is another GTD level
                    var tempArray: [workingGTDItem] = Array()
                    
                    let myArray = myDatabaseConnection.getGTDItemsForLevel(myObject2.GTDLevel as Int, inTeamID: myObject2.teamID)
                    for myItem in myArray
                    {
                        let myClass = workingGTDItem(inGTDItemID: myItem.gTDItemID as! Int, inTeamID: myObject2.teamID as Int)
                        tempArray.append(myClass)
                    }
                    
                    myDisplayHeadArray = buildGTDItemArray(tempArray)
                    
                    highlightID = myObject2.GTDItemID
                    buildHead(highlightID)
                }

            case "task":
            NSLog("task to do")
      //          myDisplayHeadArray.removeAll()
            
      //          let myObject = myParentObject as! task  // this is the current head record
      //          let myObject2 = project(inProjectID: myObject.projectID, inTeamID: myObject.teamID)  // This is the parent of that
         //       let myObject3 = areaOfResponsibility(inAreaID: myObject2.areaID, inTeamID: myObject.teamID)
            
  //              for myItem in myObject3.projects
  //              {
  //                  myDisplayHeadArray.append(myItem)
  //              }
            
  //              highlightID = myObject.projectID
  //              buildHead("project", inHighlightedID: myObject.projectID)
            
     //   case "context":

            default:
                print("Func btnUp hit default")
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
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
    
    func buildHead(inHighlightedID: Int)
    {
        var upSet: Bool = false
        
        for myItem in myDisplayHeadArray
        {
            if myItem.isKindOfClass(team)
            {
                myHeadObjectType = "Team"
                btnUp.hidden = true
                let myObject = myItem as! team
                    
                if myObject.teamID == inHighlightedID
                {
                    highlightID = myObject.teamID as Int
                    buildBody(myObject)
                }
            }
            else if myItem.isKindOfClass(workingGTDItem)
            {
                myHeadObjectType = "GTDItem"
                
                let myObject = myItem as! workingGTDItem
                    
                if !upSet
                {
                    if myObject.GTDLevel == 1
                    {
                        btnUp.hidden = false
                        btnUp.setTitle("Up to Team", forState: .Normal)
                    }
                    else
                    {
                        let tempGTD = workingGTDLevel(inGTDLevel: myObject.GTDLevel - 1, inTeamID: mySelectedTeam.teamID)
                            
                        if tempGTD.title == ""
                        {
                            btnUp.hidden = true
                        }
                        else
                        {
                            btnUp.hidden = false
                            btnUp.setTitle("Up to \(tempGTD.title)", forState: .Normal)
                        }
                    }
                    upSet = true

                    
                    if myObject.GTDItemID == inHighlightedID
                    {
                        highlightID = myObject.GTDItemID as Int
                        buildBody(myObject)
                    }
                }
            }
            else if myItem.isKindOfClass(project)
            {
                myHeadObjectType = "project"
                
                btnUp.hidden = false
                btnUp.setTitle("Up to Area of Responsibility", forState: .Normal)
                
                let myObject = myItem as! project
                    
                if myObject.projectID == inHighlightedID
                {
                    highlightID = myObject.projectID as Int
                    buildBody(myObject)
                }
            }
            else if myItem.isKindOfClass(task)
            {
                myHeadObjectType = "task"
                
                btnUp.hidden = false
                btnUp.setTitle("Up to Activity", forState: .Normal)
                // todo
            }
            else if myItem.isKindOfClass(context)
            {
                myHeadObjectType = "context"
                
                btnUp.hidden = false
                btnUp.setTitle("Up to Team", forState: .Normal)
                
                // todo, also should there be an option for a context as a child of team??
            }
            else
            {
               // Do nothing
                myHeadObjectType = ""
            }
        }
    }
    
    func buildBody(inParentObject: AnyObject)
    {
        var myBodyObjectType: String = ""
        
        var myWorkingArray: [AnyObject]!
        
        myDisplayBodyArray.removeAll()
        
        if inParentObject.isKindOfClass(team)
        {
            myBodyObjectType = "GTDItem"
            
            let myObject = inParentObject as! team
            myObject.loadGTDTopLevel()
            myWorkingArray = myObject.GTDTopLevel
        }
        else if inParentObject.isKindOfClass(workingGTDItem)
        {
            let myObject = inParentObject as! workingGTDItem
            myObject.loadChildren()
            myWorkingArray = myObject.children
            
            if myWorkingArray.count > 0
            {
                if myWorkingArray[0].isKindOfClass(workingGTDItem)
                {
                    myBodyObjectType = "GTDItem"
                }
                else
                {
                    myBodyObjectType = "project"
                }
            }
        }
        else if inParentObject.isKindOfClass(project)
        {
            myBodyObjectType = "task"
            
            let myObject = inParentObject as! project
            myObject.loadTasks()
            myWorkingArray = myObject.tasks
            
            // todo
        }
        else if inParentObject.isKindOfClass(task)
        {
            myBodyObjectType = "task"
            
            // todo
        }
        else if inParentObject.isKindOfClass(context)
        {
            myBodyObjectType = "context"
            
            // todo, also should there be an option for a context as a child of team??
        }
        else
        {
            myBodyObjectType = ""
        }

        mySavedParentObject = inParentObject
        
        switch myBodyObjectType
        {
            case "GTDItem":
                myDisplayBodyArray = buildGTDItemArray(myWorkingArray)
            
            case "project":
                myDisplayBodyArray = buildProjectArray(myWorkingArray)
            
            case "task":
                myDisplayBodyArray = buildTaskArray(myWorkingArray)
 //               let myObject = inParentObject as! task
//                for myItem in myObject.tasks
//                {
//                    myDisplayBodyArray.append(myItem)
//                }
            
            case "context":
                let myObject = inParentObject as! context
            NSLog("\(myObject.name)")
            
            default :
                print("buildBody: hit default")
        }
        colBody.reloadData()
    }
    
    func buildGTDItemArray(myWorkingArray: [AnyObject]) -> [workingGTDItem]
    {
        var predecessorArray: [workingGTDItem] = Array()
        var returnArray: [workingGTDItem] = Array()
        
        for myItem in myWorkingArray
        {
            let myWorkingItem = myItem as! workingGTDItem
            
            if myWorkingItem.predecessor == 0
            {
                returnArray.append(myWorkingItem)
            }
            else
            {
                predecessorArray.append(myWorkingItem)
            }
        }
        
        var tempArray = predecessorArray
        
        while tempArray.count > 0
        {
            let workingArray = tempArray
            tempArray.removeAll()
            
            // need to loop nthrough the array until we have found predecessors for all the items
            for myItem in workingArray
            {
                let myWorkingItem = myItem
                
                // Go through the array and find the "predecessor"
                var indexCount: Int = 0
                var itemFound: Bool = false
                
                for mySort in returnArray
                {
                    let myTempSort = mySort 
                    
                    if myTempSort.GTDItemID == myWorkingItem.predecessor
                    {
                        itemFound = true
                        if indexCount < returnArray.count
                        {
                            
                            returnArray.insert(myItem, atIndex: indexCount + 1)
                        }
                        else
                        {
                            
                            returnArray.append(myItem)
                        }
                    }
                    indexCount++
                }
                
                // if we have gone through the array an not found a match for the precessor, then we need to store for another go round
                if !itemFound
                {
                    tempArray.append(myItem)
                }
            }
        }
        return returnArray
    }
    
    func buildProjectArray(myWorkingArray: [AnyObject]) -> [project]
    {
        var returnArray: [project] = Array()
        var predecessorArray: [project] = Array()
        
        for myItem in myWorkingArray
        {
            let myWorkingItem = myItem as! project
            
            if myWorkingItem.predecessor == 0
            {
                returnArray.append(myWorkingItem)
            }
            else
            {
                predecessorArray.append(myWorkingItem)
            }
        }
        
        var tempArray = predecessorArray
        
        while tempArray.count > 0
        {
            let workingArray = tempArray
            tempArray.removeAll()
            
            // need to loop nthrough the array until we have found predecessors for all the items
            for myItem in workingArray
            {
                let myWorkingItem = myItem
                
                // Go through the array and find the "predecessor"
                var indexCount: Int = 0
                var itemFound: Bool = false
                
                for mySort in returnArray
                {
                    let myTempSort = mySort 
                    
                    if myTempSort.projectID == myWorkingItem.predecessor
                    {
                        itemFound = true
                        if indexCount < returnArray.count
                        {
                            
                            returnArray.insert(myItem, atIndex: indexCount + 1)
                        }
                        else
                        {
                            
                            returnArray.append(myItem)
                        }
                    }
                    indexCount++
                }
                
                // if we have gone through the array an not found a match for the precessor, then we need to store for another go round
                if !itemFound
                {
                    tempArray.append(myItem)
                }
            }
        }

        return returnArray
    }
    
    func buildTaskArray(myWorkingArray: [AnyObject]) -> [task]
    {
        var returnArray: [task] = Array()
        var predecessorArray: [task] = Array()

        for myItem in myWorkingArray
        {
            let myWorkingItem = myItem as! task
            
            if myWorkingItem.predecessors.count == 0
            {
                returnArray.append(myWorkingItem)
            }
            else
            {
                predecessorArray.append(myWorkingItem)
            }
        }
        
        var tempArray = predecessorArray
        
        while tempArray.count > 0
        {
            let workingArray = tempArray
            tempArray.removeAll()
            
            // need to loop nthrough the array until we have found predecessors for all the items
            for myItem in workingArray
            {
                let myWorkingItem = myItem
                
                // Go through the array and find the "predecessor"
                var indexCount: Int = 0
                var itemFound: Bool = false
                
                for mySort in returnArray
                {
                    let myTempSort = mySort
                    
                    for myPredecessor in myWorkingItem.predecessors
                    {
                        if myTempSort.taskID == myPredecessor.predecessorID
                        {
                            itemFound = true
                            if indexCount < returnArray.count
                            {
                                returnArray.insert(myItem, atIndex: indexCount + 1)
                            }
                            else
                            {
                                returnArray.append(myItem)
                            }
                        }
                    }
                    indexCount++
                }
                
                // if we have gone through the array an not found a match for the precessor, then we need to store for another go round
                if !itemFound
                {
                    tempArray.append(myItem)
                }
            }
        }
        
        return returnArray
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
        refreshBody()
    }
    
    func refreshBody()
    {
        switch myHeadObjectType
        {
            case "Team":
                myDisplayHeadArray.removeAll()
                let myTeamArray = myDatabaseConnection.getAllTeams()
                for myTeamItem in myTeamArray
                {
                    let myTeam = team(inTeamID: myTeamItem.teamID as Int)
                    myDisplayHeadArray.append(myTeam)
                }

                buildHead(highlightID)
            
            case "GTDItem":
                let tempObject = mySavedParentObject as! workingGTDItem
                var tempArray: [workingGTDItem] = Array()
            
                let myArray = myDatabaseConnection.getGTDItemsForLevel(tempObject.GTDLevel as Int, inTeamID: tempObject.teamID)
                for myItem in myArray
                {
                    let myClass = workingGTDItem(inGTDItemID: myItem.gTDItemID as! Int, inTeamID: tempObject.teamID as Int)
                    tempArray.append(myClass)
                }
                
                myDisplayHeadArray = buildGTDItemArray(tempArray)
                highlightID = tempObject.GTDItemID
                buildHead(highlightID)
            
            case "project":
                let myObject = mySavedParentObject as! project  // this is the current head record
                let myObject2 = workingGTDItem(inGTDItemID: myObject.GTDItemID, inTeamID: myObject.teamID)  // This is the parent of that
            
                myDisplayHeadArray = buildProjectArray(myObject2.children)
                
              //  highlightID = myObject2.GTDItemID
                buildHead(highlightID)
            
            case "task":
                NSLog("task to do")
            //          myDisplayHeadArray.removeAll()
            
            //          let myObject = myParentObject as! task  // this is the current head record
            //          let myObject2 = project(inProjectID: myObject.projectID, inTeamID: myObject.teamID)  // This is the parent of that
            //       let myObject3 = areaOfResponsibility(inAreaID: myObject2.areaID, inTeamID: myObject.teamID)
            
            //              for myItem in myObject3.projects
            //              {
            //                  myDisplayHeadArray.append(myItem)
            //              }
            
            //              highlightID = myObject.projectID
            //              buildHead("project", inHighlightedID: myObject.projectID)
            
            //   case "context":
            
            default:
                print("Func refreshbody hit default")
        }
    }
    
    func displayTeamOptions(inTeam: team) -> UIAlertController
    {
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .ActionSheet)
        
        var myMessage: String = ""

        // Need to get the name of the GTD Level
        
        let tempGTD = workingGTDLevel(inGTDLevel: 1, inTeamID: inTeam.teamID)
        
        if tempGTD.title == ""
        {
            myMessage = "Add Child"
        }
        else
        {
            myMessage = "Add \(tempGTD.title)"
        }
        
        let myOption1 = UIAlertAction(title: myMessage, style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("GTDEditController") as! GTDEditViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            
            let tempChild = workingGTDItem(inTeamID: inTeam.teamID, inParentID: 0)
            tempChild.GTDLevel = 1
            popoverContent.inGTDObject = tempChild
            
            popover!.sourceView = self.view
            
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 500, 400)
            popover!.sourceRect = CGRectMake(0, 0, 500, 400)
            
            popoverContent.preferredContentSize = CGSizeMake(500,400)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        let myOption2 = UIAlertAction(title: "Edit Team", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("TeamMaintenance") as! teamMaintenanceViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            
            let parentObject = inTeam
            popoverContent.myWorkingTeam = parentObject
            
            popover!.sourceView = self.view
            
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRectMake(0, 0, 800, 700)
            
            popoverContent.preferredContentSize = CGSizeMake(800,700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        let myOption3 = UIAlertAction(title: "Maintain Team Settings", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MaintainTeamDecodes") as! teamDecodesViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            
            let parentObject = inTeam
            popoverContent.myWorkingTeam = parentObject
            
            popover!.sourceView = self.view
            
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRectMake(0, 0, 600, 400)
            
            popoverContent.preferredContentSize = CGSizeMake(600,400)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        let myOption4 = UIAlertAction(title: "New Team", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("TeamMaintenance") as! teamMaintenanceViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            
            let parentObject = team()
            popoverContent.myWorkingTeam = parentObject
            
            
            popover!.sourceView = self.view
            
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRectMake(0, 0, 800, 700)
            
            popoverContent.preferredContentSize = CGSizeMake(800,700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.presentViewController(popoverContent, animated: true, completion: nil)

        })
        
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        myOptions.addAction(myOption3)
        myOptions.addAction(myOption4)
        
        return myOptions
    }
    
    func displayGTDOptions(inGTDItem: workingGTDItem, inDisplayType: String, xPos: CGFloat, yPos: CGFloat) -> UIAlertController
    {
        // Need to get the name of the GTD Level
        
        var myChildType: String = ""
        var myLevelType: String = ""
        var actionType: String = ""
        
        if inGTDItem.GTDLevel == mySelectedTeam.GTDLevels.count
        {
            myChildType = "Activity"
            actionType = "project"
        }
        else
        {
            let tempGTD = workingGTDLevel(inGTDLevel: inGTDItem.GTDLevel + 1, inTeamID: mySelectedTeam.teamID)
        
            if tempGTD.title == ""
            {
                myChildType = ""
            }
            else
            {
                myChildType = "\(tempGTD.title)"
            }
            
            let tempGTD2 = workingGTDLevel(inGTDLevel: inGTDItem.GTDLevel, inTeamID: mySelectedTeam.teamID)
            
            if tempGTD2.title == ""
            {
                myLevelType = ""
            }
            else
            {
                myLevelType = "\(tempGTD2.title)"
            }
            
            actionType = "GTDItem"
        }
        
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .ActionSheet)
        
        let myOption1 = UIAlertAction(title: "Edit \(myLevelType)", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("GTDEditController") as! GTDEditViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            
            popoverContent.inGTDObject = inGTDItem
                
            popoverContent.preferredContentSize = CGSizeMake(500,400)
            
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 500, 400)
            popover!.sourceRect = CGRectMake(0, 0, 500, 400)
            
      //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
      //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.presentViewController(popoverContent, animated: true, completion: nil)
            })
            
        let myOption2 = UIAlertAction(title: "Delete entry", style: .Default, handler: { (action: UIAlertAction) -> () in
            if !inGTDItem.delete()
            {
                let alert = UIAlertController(title: "Delete item", message:
                    "Unable to delete item.  Check that there are no child records", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alert, animated: false, completion: nil)
            }
            else
            {
                self.buildHead(self.highlightID)
                self.buildBody(self.mySavedParentObject)
            }
            })
        
        var myOption0: UIAlertAction!
        
        if inDisplayType == "Head"
        {
            myOption0 = UIAlertAction(title: "Add \(myChildType)", style: .Default, handler: { (action: UIAlertAction) -> () in
                if actionType == "GTDItem"
                { // GTDItem
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("GTDEditController") as! GTDEditViewController
                    popoverContent.modalPresentationStyle = .Popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = self.view
                
                    let tempChild = workingGTDItem(inTeamID: self.mySelectedTeam.teamID, inParentID: inGTDItem.GTDItemID)
                    tempChild.GTDLevel = inGTDItem.GTDLevel + 1
                    popoverContent.inGTDObject = tempChild
                
                    popoverContent.preferredContentSize = CGSizeMake(500,400)
                    
                    //  Calculate the start position based on screen width and position of the item
                    //            let myXPos = xPos
                    //            let myYPos = yPos
                    //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
                    
                    //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 500, 400)
                    popover!.sourceRect = CGRectMake(0, 0, 500, 400)
                    
                    //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
                    //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
                    self.presentViewController(popoverContent, animated: true, completion: nil)

                }
                else
                {  // Project
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MaintainProject") as! MaintainProjectViewController
                    popoverContent.modalPresentationStyle = .Popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = self.view
                    
                    let tempProject = project(inTeamID: self.mySelectedTeam.teamID)
 //                   self.myParentObject = tempProject
                    tempProject.GTDItemID = inGTDItem.GTDItemID
                    popoverContent.inProjectObject = tempProject
                    popoverContent.myActionType = "Add"
                    popoverContent.mySelectedTeam = self.mySelectedTeam
                        
                    popoverContent.preferredContentSize = CGSizeMake(700,700)
                        
                    //  Calculate the start position based on screen width and position of the item
                    //            let myXPos = xPos
                    //            let myYPos = yPos
                    //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
                    
                    //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
                    popover!.sourceRect = CGRectMake(0, 0, 700, 700)
                    
                    //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
                    //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
                    self.presentViewController(popoverContent, animated: true, completion: nil)
                }
            })
            myOptions.addAction(myOption0)
        }
        else if inDisplayType == "Body"
        {
            myOption0 = UIAlertAction(title: "Zoom", style: .Default, handler: { (action: UIAlertAction) -> () in
                self.myDisplayHeadArray = self.myDisplayBodyArray
                self.highlightID = inGTDItem.GTDItemID as Int
                self.buildHead(self.highlightID)
                    
                self.buildBody(inGTDItem)
            })
            myOptions.addAction(myOption0)
        }
            
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        
        return myOptions
    }
    
    func displayProjectOptions(inProjectItem: project, inDisplayType: String, xPos: CGFloat, yPos: CGFloat) -> UIAlertController
    {
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .ActionSheet)
        
        let myOption1 = UIAlertAction(title: "Edit", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MaintainProject") as! MaintainProjectViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            
            popoverContent.inProjectObject = inProjectItem
            popoverContent.myActionType = "Edit"
            popoverContent.mySelectedTeam = self.mySelectedTeam
            
            popoverContent.preferredContentSize = CGSizeMake(700,700)
            
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRectMake(0, 0, 700, 700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        if inDisplayType == "Body"
        {
            let myOption0 = UIAlertAction(title: "Zoom", style: .Default, handler: { (action: UIAlertAction) -> () in
                self.myDisplayHeadArray = self.myDisplayBodyArray
                self.highlightID = inProjectItem.projectID as Int
                self.buildHead(self.highlightID)
                
                self.buildBody(inProjectItem)
            })
            myOptions.addAction(myOption0)
            
            let myOption2 = UIAlertAction(title: "Delete Activity", style: .Default, handler: { (action: UIAlertAction) -> () in
                if !inProjectItem.delete()
                {
                    let alert = UIAlertController(title: "Delete Activity", message:
                        "Unable to delete Activity.  Check that there are no Actions", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alert, animated: false, completion: nil)
                }
                else
                {
                    self.buildHead(self.highlightID)
                    self.buildBody(self.mySavedParentObject)
                }
            })
            myOptions.addAction(myOption2)
        }
        
        let myOption3 = UIAlertAction(title: "Add Action", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("tasks") as! taskViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            
            let newTask = task(inTeamID: self.mySelectedTeam.teamID)
            newTask.projectID = inProjectItem.projectID
            popoverContent.passedTask = newTask
            
            popoverContent.preferredContentSize = CGSizeMake(700,700)
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRectMake(0, 0, 700, 700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })

        myOptions.addAction(myOption1)
        myOptions.addAction(myOption3)
        
        return myOptions
    }
    
    func displayTaskOptions(workingTask: task, displayType: String, xPos: CGFloat, yPos: CGFloat) -> UIAlertController
    {
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .ActionSheet)

        let myOption1 = UIAlertAction(title: "Edit Action", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("tasks") as! taskViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            
            popoverContent.passedTask = workingTask
            popoverContent.preferredContentSize = CGSizeMake(700,700)
            
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRectMake(0, 0, 700, 700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        let myOption2 = UIAlertAction(title: "Action Updates", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("taskUpdate") as! taskUpdatesViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            
            //  Calculate the start position based on screen width and position of the item
//            let myXPos = xPos
//            let myYPos = yPos
//            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
//            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRectMake(0, 0, 700, 700)
 
            popoverContent.passedTask = workingTask
            popoverContent.preferredContentSize = CGSizeMake(700,700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        
        return myOptions
    }
    
    func displaySubmenu(notification: NSNotification)
    {
        let sectionType = notification.userInfo!["sectionType"] as! String
        let rowString = notification.userInfo!["rowNumber"] as! String
        
        let rowNumber = Int(rowString)
        
        if sectionType == "head"
        { // Head
            var myOptions: UIAlertController!
                    
            if myDisplayHeadArray[rowNumber!].isKindOfClass(team)
            {
                let tempObject = myDisplayHeadArray[rowNumber!] as! team
                highlightID = tempObject.teamID
                        
                myOptions = displayTeamOptions(myDisplayHeadArray[rowNumber!] as! team)
            }
            else if myDisplayHeadArray[rowNumber!].isKindOfClass(workingGTDItem)
            {
                let tempObject = myDisplayHeadArray[rowNumber!] as! workingGTDItem
                highlightID = tempObject.GTDItemID
                myOptions = displayGTDOptions(myDisplayHeadArray[rowNumber!] as! workingGTDItem, inDisplayType: "Head", xPos: myHeadCells[rowNumber!].displayX, yPos: myHeadCells[rowNumber!].displayY)
            }
            else if myDisplayHeadArray[rowNumber!].isKindOfClass(project)
            {
                let tempObject = myDisplayHeadArray[rowNumber!] as! project
                highlightID = tempObject.projectID
                        
                myOptions = displayProjectOptions(myDisplayHeadArray[rowNumber!] as! project, inDisplayType: "Head", xPos: myHeadCells[rowNumber!].displayX, yPos: myHeadCells[rowNumber!].displayY)
            }
            myOptions.popoverPresentationController!.sourceView = self.view
                    
            myOptions.popoverPresentationController!.sourceRect = CGRectMake(myHeadCells[rowNumber!].displayX + 20, myHeadCells[rowNumber!].displayY + headerSize, 0, 0)
                    
            self.presentViewController(myOptions, animated: true, completion: nil)
        }
        else
        { // Body
            var myOptions: UIAlertController!
            if myDisplayBodyArray[rowNumber!].isKindOfClass(workingGTDItem)
            {
                let tempObject = myDisplayBodyArray[rowNumber!] as! workingGTDItem
                highlightID = tempObject.GTDItemID
                        
                myOptions = displayGTDOptions(myDisplayBodyArray[rowNumber!] as! workingGTDItem, inDisplayType: "Body", xPos: myBodyCells[rowNumber!].displayX, yPos: myBodyCells[rowNumber!].displayY)
            }
            else if myDisplayBodyArray[rowNumber!].isKindOfClass(project)
            {
                let tempObject = myDisplayBodyArray[rowNumber!] as! project
                highlightID = tempObject.projectID
                        
                myOptions = displayProjectOptions(myDisplayBodyArray[rowNumber!] as! project, inDisplayType: "Body", xPos: myBodyCells[rowNumber!].displayX, yPos: myBodyCells[rowNumber!].displayY)
            }
            else if myDisplayBodyArray[rowNumber!].isKindOfClass(task)
            {
                myOptions = displayTaskOptions(myDisplayBodyArray[rowNumber!] as! task, displayType: "Body", xPos: myBodyCells[rowNumber!].displayX, yPos: myBodyCells[rowNumber!].displayY)
            }
                    
            myOptions.popoverPresentationController!.sourceView = self.view
                    
            myOptions.popoverPresentationController!.sourceRect = CGRectMake(myBodyCells[rowNumber!].displayX + 20, myBodyCells[rowNumber!].displayY + headerSize, 0, 0)
                    
            self.presentViewController(myOptions, animated: true, completion: nil)
        }

        colBody.reloadData()
    }
}

class KDRearrangeableGTDDisplayHierarchy: UICollectionViewCell
{
    
    @IBOutlet weak var lblChildren: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnDetails: UIButton!
    
    var sectionType: String = ""
    var rowNumber: Int = 0
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    var dragging : Bool = false
        {
        didSet
        {
            
        }
        
    }
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnDetails(sender: UIButton)
    {
        let selectedDictionary = ["sectionType" : sectionType, "rowNumber": "\(rowNumber)"]
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationDisplayGTDSubmenu", object: nil, userInfo:selectedDictionary as [String : String])
    }
}

class myGTDDisplay: KDRearrangeableGTDDisplayHierarchy
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //  self.layer.cornerRadius = self.frame.size.width * 0.5
        self.clipsToBounds = true
    }
}

class GTDHeaderView: UICollectionReusableView
{
    @IBOutlet weak var lblTitle: UILabel!
}

class KDRearrangeableGTDTaskDisplay: UICollectionViewCell
{
    
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDue: UILabel!
    @IBOutlet weak var lblChildren: UILabel!
    @IBOutlet weak var lblContexts: UILabel!
    @IBOutlet weak var btnDetails: UIButton!
    
    var sectionType: String = ""
    var rowNumber: Int = 0
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    var dragging : Bool = false
        {
        didSet
        {
            
        }
        
    }
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnDetails(sender: UIButton)
    {
        let selectedDictionary = ["sectionType" : sectionType, "rowNumber": "\(rowNumber)"]
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationDisplayGTDSubmenu", object: nil, userInfo:selectedDictionary as [String : String])
    }
}

class myGTDTaskDisplay: KDRearrangeableGTDTaskDisplay
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //  self.layer.cornerRadius = self.frame.size.width * 0.5
        self.clipsToBounds = true
    }
}
