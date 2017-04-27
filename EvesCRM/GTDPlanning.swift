//
//  GTDPlanning.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 26/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit


enum AdaptiveMode
{
    case `default`
    case landscapePopover
    case alwaysPopover
}

class MaintainGTDPlanningViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate, KDRearrangeableCollectionViewDelegate, UIGestureRecognizerDelegate
{
    @IBInspectable var popoverOniPhone:Bool = false
    @IBInspectable var popoverOniPhoneLandscape:Bool = true
    
    var passedGTD: GTDModel!
    
    @IBOutlet weak var btnUp: UIButton!
    @IBOutlet weak var colBody: UICollectionView!

    fileprivate var myDisplayHeadArray: [AnyObject] = Array()
    fileprivate var myDisplayBodyArray: [AnyObject] = Array()
    fileprivate var highlightID: Int32 = 0
//    private var myParentObject: AnyObject!
    fileprivate var mySelectedTeam: team!
    fileprivate var myHeadObjectType: String = ""
    fileprivate var mySavedParentObject: AnyObject!
    fileprivate var myHeadCells: [cellDetails] = Array()
    fileprivate var myBodyCells: [cellDetails] = Array()
    fileprivate var headerSize: CGFloat = 0.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
        myDisplayHeadArray.removeAll()
        
        let myTeamArray = myDatabaseConnection.getAllTeams()
        for myTeamItem in myTeamArray
        {
            let myTeam = team(inTeamID: myTeamItem.teamID)
            myDisplayHeadArray.append(myTeam)
        }
        
        highlightID = myCurrentTeam.teamID
        mySelectedTeam = myCurrentTeam
        buildHead(myCurrentTeam.teamID)
        
        notificationCenter.addObserver(self, selector: #selector(self.displaySubmenu(_:)), name:NotificationDisplayGTDSubmenu, object: nil)
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
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        myHeadCells.removeAll()
        myBodyCells.removeAll()
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
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
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    //    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell?


    
   //func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    
    
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if indexPath.section == 0
        {  // Head
            if myDisplayHeadArray[indexPath.row] is task
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellTask", for: indexPath as IndexPath) as! myGTDTaskDisplay
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
                    cell.backgroundColor = UIColor.clear
                }
                
                cell.layer.borderColor = UIColor.lightGray.cgColor
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
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellBody", for: indexPath as IndexPath) as! myGTDDisplay

                cell.sectionType = "head"
                cell.rowNumber = indexPath.row
                if myDisplayHeadArray[indexPath.row] is team
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
                        cell.backgroundColor = UIColor.clear
                    }
                }
                else if myDisplayHeadArray[indexPath.row] is workingGTDItem
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
                        cell.backgroundColor = UIColor.clear
                    }
                }
                else if myDisplayHeadArray[indexPath.row] is project
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
                        cell.backgroundColor = UIColor.clear
                    }
                }
                else if myDisplayHeadArray[indexPath.row] is context
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
                        cell.backgroundColor = UIColor.clear
                    }
                }
                else if myDisplayHeadArray[indexPath.row] is String
                {
                    cell.lblName.text = myDisplayHeadArray[indexPath.row] as? String
                    cell.lblChildren.text = ""
                }

                cell.layer.borderColor = UIColor.lightGray.cgColor
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
            if myDisplayBodyArray[indexPath.row] is task
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellTask", for: indexPath as IndexPath) as! myGTDTaskDisplay
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
                
                cell.layer.borderColor = UIColor.lightGray.cgColor
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
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellBody", for: indexPath as IndexPath) as! myGTDDisplay

                cell.sectionType = "body"
                cell.rowNumber = indexPath.row
            
                if myDisplayBodyArray[indexPath.row] is workingGTDItem
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
                else if myDisplayBodyArray[indexPath.row] is project
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
                else if myDisplayBodyArray[indexPath.row] is context
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
            
                cell.backgroundColor = UIColor.clear
                cell.layer.borderColor = UIColor.lightGray.cgColor
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
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        if collectionView == colBody
        {
            if indexPath.section == 0
            {
                // Head
                if myDisplayHeadArray[indexPath.row] is task
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
                if myDisplayBodyArray[indexPath.row] is task
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if indexPath.section == 0
        { // Head
            if myDisplayHeadArray[indexPath.row] is team
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! team
                highlightID = tempObject.teamID
                mySelectedTeam = tempObject
                buildBody(tempObject)
            }
            else if myDisplayHeadArray[indexPath.row] is workingGTDItem
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! workingGTDItem
                highlightID = tempObject.GTDItemID
                buildBody(tempObject)
            }
            else if myDisplayHeadArray[indexPath.row] is project
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! project
                highlightID = tempObject.projectID
                buildBody(tempObject)
            }
            else if myDisplayHeadArray[indexPath.row] is task
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! task
                highlightID = tempObject.taskID
                buildBody(tempObject)
            }
            else if myDisplayHeadArray[indexPath.row] is context
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
            if myDisplayBodyArray[indexPath.row] is workingGTDItem
            {
                myDisplayHeadArray = myDisplayBodyArray
                
                let myObject = myDisplayBodyArray[indexPath.row] as! workingGTDItem
                highlightID = myObject.GTDItemID
                
                if myObject.GTDLevel < Int32(mySelectedTeam.GTDLevels.count)
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
            else if myDisplayBodyArray[indexPath.row] is project
            {
                myDisplayHeadArray = myDisplayBodyArray
                
                let myObject = myDisplayBodyArray[indexPath.row] as! project
                highlightID = myObject.projectID
                
                buildHead(highlightID)
                buildBody(myObject)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cellSectionHeader", for: indexPath as IndexPath) as! GTDHeaderView
        
        if indexPath.section == 0
        {
            if myDisplayHeadArray[indexPath.row] is team
            {
                headerView.lblTitle.text = "My Teams"
            }
            else if myDisplayHeadArray[indexPath.row] is project
            {
                headerView.lblTitle.text = "My Activities"
            }
            else if myDisplayHeadArray[indexPath.row] is task
            {
                headerView.lblTitle.text = "My Actions"
            }
            else if myDisplayHeadArray[indexPath.row] is context
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
                if myDisplayBodyArray[indexPath.row] is team
                {
                    headerView.lblTitle.text = "My Teams"
                }
                else if myDisplayBodyArray[indexPath.row] is project
                {
                    headerView.lblTitle.text = "My Activities"
                }
                else if myDisplayBodyArray[indexPath.row] is task
                {
                    headerView.lblTitle.text = "My Actions"
                }
                else if myDisplayBodyArray[indexPath.row] is context
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

    func moveDataItem(_ toIndexPath : IndexPath, fromIndexPath: IndexPath) -> Void
    {
        var fromID: Int32 = 0
        var fromCurrentPredecessor: Int32 = 0
        
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
                    if myDisplayBodyArray[fromIndexPath.item] is workingGTDItem
                    {
                        let fromItem = myDisplayBodyArray[fromIndexPath.item] as! workingGTDItem
                        
                        fromID = fromItem.GTDItemID
                        
                        fromCurrentPredecessor = myDatabaseConnection.getGTDItemSuccessor(fromItem.GTDItemID)
                    }

                    if myDisplayBodyArray[fromIndexPath.item] is project
                    {
                        let fromItem = myDisplayBodyArray[fromIndexPath.item] as! project

                        fromID = fromItem.projectID
                     
                        fromCurrentPredecessor = myDatabaseConnection.getProjectSuccessor(fromID)
                    }

                    if myDisplayBodyArray[toIndexPath.item] is workingGTDItem
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
                                "Unable to move item as the item being moved is already in the predecessor chain", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alert, animated: false, completion: nil)
                        }
                    }

                    if myDisplayBodyArray[toIndexPath.item] is project
                    {
                        let toItem = myDisplayBodyArray[toIndexPath.item] as! project

                        toItem.predecessor = fromID
                        
                        // check to make sure will not get circualr reference and then update if possible
                        if !parseForCircularReference(myDisplayBodyArray, movingID: toItem.projectID, predecessorID: fromID)
                        {
                            toItem.predecessor = fromID
                            
                            if fromCurrentPredecessor > 0
                            {
                                let tempSuccessor = project(inProjectID: fromCurrentPredecessor)
                                tempSuccessor.predecessor = toItem.projectID
                            }
                        }
                        else
                        {
                            let alert = UIAlertController(title: "Move item", message:
                                "Unable to move item as the item being moved is already in the predecessor chain", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alert, animated: false, completion: nil)
                        }
                    }
                }
                else
                {
                    if myDisplayBodyArray[fromIndexPath.item] is workingGTDItem
                    {
                        let fromItem = myDisplayBodyArray[fromIndexPath.item] as! workingGTDItem
                        fromID = fromItem.GTDItemID
                        
                        // Get any current success
                    
                        fromCurrentPredecessor = myDatabaseConnection.getGTDItemSuccessor(fromItem.GTDItemID)
                    }

                    if myDisplayBodyArray[fromIndexPath.item] is project
                    {
                        let fromItem = myDisplayBodyArray[fromIndexPath.item] as! project
                        fromID = fromItem.projectID
                        
                        // Get any current success
                        
                        fromCurrentPredecessor = myDatabaseConnection.getProjectSuccessor(fromItem.projectID)
                    }
                    
                    if myDisplayBodyArray[toIndexPath.item] is workingGTDItem
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
                                "Unable to move item as the item being moved is already in the predecessor chain", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alert, animated: false, completion: nil)
                        }
                    }
                    
                    if myDisplayBodyArray[toIndexPath.item] is project
                    {
                        let toItem = myDisplayBodyArray[toIndexPath.item] as! project
                        
                        // check to make sure will not get circualr reference and then update if possible
                        if !parseForCircularReference(myDisplayBodyArray, movingID: toItem.projectID, predecessorID: fromID)
                        {
                            toItem.predecessor = fromID

                            if fromCurrentPredecessor > 0
                            {
                                let tempSuccessor = project(inProjectID: fromCurrentPredecessor)
                                tempSuccessor.predecessor = toItem.projectID
                            }
                        }
                        else
                        {
                            let alert = UIAlertController(title: "Move item", message:
                                "Unable to move item as the item being moved is already in the predecessor chain", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alert, animated: false, completion: nil)
                        }
                    }
                }

                buildBody(mySavedParentObject)
            }
        }

    //    colBody.reloadData()  this is called in buildbody
    }

    func parseForCircularReference(_ referenceArray: [AnyObject], movingID: Int32, predecessorID: Int32) -> Bool
    {
        var foundCircularReference: Bool = false
        var checkItemID: Int32 = 0
        var checkItemPredecessor: Int32 = 0

        for myItem in referenceArray
        {
            if myItem is project
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

    @IBAction func btnUp(_ sender: UIButton)
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
                        let myTeam = team(inTeamID: myTeamItem.teamID)
                        myDisplayHeadArray.append(myTeam)
                    }
                
                    highlightID = tempObject.teamID
                    buildHead(tempObject.teamID)
                }
                else
                { // parent is another GTD level
                    var tempArray: [workingGTDItem] = Array()
                    
                    let myArray = myDatabaseConnection.getGTDItemsForLevel(tempObject.GTDLevel - 1, inTeamID: tempObject.teamID)
                    for myItem in myArray
                    {
                        let myClass = workingGTDItem(inGTDItemID: myItem.gTDItemID, inTeamID: tempObject.teamID)
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
                        let myTeam = team(inTeamID: myTeamItem.teamID)
                        myDisplayHeadArray.append(myTeam)
                    }
                    
                    highlightID = myCurrentTeam.teamID
                    buildHead(myCurrentTeam.teamID)
                }
                else
                { // parent is another GTD level
                    var tempArray: [workingGTDItem] = Array()
                    
                    let myArray = myDatabaseConnection.getGTDItemsForLevel(myObject2.GTDLevel, inTeamID: myObject2.teamID)
                    for myItem in myArray
                    {
                        let myClass = workingGTDItem(inGTDItemID: myItem.gTDItemID, inTeamID: myObject2.teamID)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        //       projectNameText.endEditing(true)
    }
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
        {
            // Do nothing
        }
        else
        {
            passedGTD.delegate.myGTDPlanningDidFinish(self)
        }
    }
    
    func buildHead(_ inHighlightedID: Int32)
    {
        var upSet: Bool = false
        
        for myItem in myDisplayHeadArray
        {
            if myItem is team
            {
                myHeadObjectType = "Team"
                btnUp.isHidden = true
                let myObject = myItem as! team
                    
                if myObject.teamID == inHighlightedID
                {
                    highlightID = myObject.teamID
                    buildBody(myObject)
                }
            }
            else if myItem is workingGTDItem
            {
                myHeadObjectType = "GTDItem"
                
                let myObject = myItem as! workingGTDItem
                    
                if !upSet
                {
                    if myObject.GTDLevel == 1
                    {
                        btnUp.isHidden = false
                        btnUp.setTitle("Up to Team", for: .normal)
                    }
                    else
                    {
                        let tempGTD = workingGTDLevel(inGTDLevel: myObject.GTDLevel - 1, inTeamID: mySelectedTeam.teamID)
                            
                        if tempGTD.title == ""
                        {
                            btnUp.isHidden = true
                        }
                        else
                        {
                            btnUp.isHidden = false
                            btnUp.setTitle("Up to \(tempGTD.title)", for: .normal)
                        }
                    }
                    upSet = true

                    
                    if myObject.GTDItemID == inHighlightedID
                    {
                        highlightID = myObject.GTDItemID
                        buildBody(myObject)
                    }
                }
            }
            else if myItem is project
            {
                myHeadObjectType = "project"
                
                btnUp.isHidden = false
                btnUp.setTitle("Up to Area of Responsibility", for: .normal)
                
                let myObject = myItem as! project
                    
                if myObject.projectID == inHighlightedID
                {
                    highlightID = myObject.projectID
                    buildBody(myObject)
                }
            }
            else if myItem is task
            {
                myHeadObjectType = "task"
                
                btnUp.isHidden = false
                btnUp.setTitle("Up to Activity", for: .normal)
                // todo
            }
            else if myItem is context
            {
                myHeadObjectType = "context"
                
                btnUp.isHidden = false
                btnUp.setTitle("Up to Team", for: .normal)
                
                // todo, also should there be an option for a context as a child of team??
            }
            else
            {
               // Do nothing
                myHeadObjectType = ""
            }
        }
    }
    
    func buildBody(_ inParentObject: AnyObject)
    {
        var myBodyObjectType: String = ""
        
        var myWorkingArray: [AnyObject]!
        
        myDisplayBodyArray.removeAll()
        
        if inParentObject is team
        {
            myBodyObjectType = "GTDItem"
            
            let myObject = inParentObject as! team
            myObject.loadGTDTopLevel()
            myWorkingArray = myObject.GTDTopLevel
        }
        else if inParentObject is workingGTDItem
        {
            let myObject = inParentObject as! workingGTDItem
            myObject.loadChildren()
            myWorkingArray = myObject.children
            
            if myWorkingArray.count > 0
            {
                if myWorkingArray[0] is workingGTDItem
                {
                    myBodyObjectType = "GTDItem"
                }
                else
                {
                    myBodyObjectType = "project"
                }
            }
        }
        else if inParentObject is project
        {
            myBodyObjectType = "task"
            
            let myObject = inParentObject as! project
            myObject.loadTasks()
            myWorkingArray = myObject.tasks
            
            // todo
        }
        else if inParentObject is task
        {
            myBodyObjectType = "task"
            
            // todo
        }
        else if inParentObject is context
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
    
    func buildGTDItemArray(_ myWorkingArray: [AnyObject]) -> [workingGTDItem]
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
                            
                            returnArray.insert(myItem, at: indexCount + 1)
                        }
                        else
                        {
                            
                            returnArray.append(myItem)
                        }
                    }
                    indexCount += 1
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
    
    func buildProjectArray(_ myWorkingArray: [AnyObject]) -> [project]
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
                            
                            returnArray.insert(myItem, at: indexCount + 1)
                        }
                        else
                        {
                            
                            returnArray.append(myItem)
                        }
                    }
                    indexCount += 1
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
    
    func buildTaskArray(_ myWorkingArray: [AnyObject]) -> [task]
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
                                returnArray.insert(myItem, at: indexCount + 1)
                            }
                            else
                            {
                                returnArray.append(myItem)
                            }
                        }
                    }
                    indexCount += 1
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
                    let myTeam = team(inTeamID: myTeamItem.teamID)
                    myDisplayHeadArray.append(myTeam)
                }

                buildHead(highlightID)
            
            case "GTDItem":
                let tempObject = mySavedParentObject as! workingGTDItem
                var tempArray: [workingGTDItem] = Array()
            
                let myArray = myDatabaseConnection.getGTDItemsForLevel(tempObject.GTDLevel, inTeamID: tempObject.teamID)
                for myItem in myArray
                {
                    let myClass = workingGTDItem(inGTDItemID: myItem.gTDItemID, inTeamID: tempObject.teamID)
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
    
    func displayTeamOptions(_ inTeam: team) -> UIAlertController
    {
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .actionSheet)
        
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
        
        let myOption1 = UIAlertAction(title: myMessage, style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = GTDStoryboard.instantiateViewController(withIdentifier: "GTDEditController") as! GTDEditViewController
            popoverContent.modalPresentationStyle = .popover
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
            popover!.sourceRect = CGRect(x: 0, y: 0, width: 500, height: 400)
            
            popoverContent.preferredContentSize = CGSize(width: 500,height: 400)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        let myOption2 = UIAlertAction(title: "Edit Team", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = teamStoryboard.instantiateViewController(withIdentifier: "TeamMaintenance") as! teamMaintenanceViewController
            popoverContent.modalPresentationStyle = .popover
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
            popover!.sourceRect = CGRect(x: 0, y: 0, width: 800, height: 700)
            
            popoverContent.preferredContentSize = CGSize(width: 800,height: 700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        let myOption3 = UIAlertAction(title: "Maintain Team Settings", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = teamStoryboard.instantiateViewController(withIdentifier: "MaintainTeamDecodes") as! teamDecodesViewController
            popoverContent.modalPresentationStyle = .popover
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
            popover!.sourceRect = CGRect(x: 0, y: 0, width: 600, height: 400)
            
            popoverContent.preferredContentSize = CGSize(width: 600,height: 400)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        let myOption4 = UIAlertAction(title: "New Team", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = teamStoryboard.instantiateViewController(withIdentifier: "TeamMaintenance") as! teamMaintenanceViewController
            popoverContent.modalPresentationStyle = .popover
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
            popover!.sourceRect = CGRect(x: 0, y: 0, width: 800, height: 700)
            
            popoverContent.preferredContentSize = CGSize(width: 800,height: 700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.present(popoverContent, animated: true, completion: nil)

        })
        
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        myOptions.addAction(myOption3)
        myOptions.addAction(myOption4)
        
        return myOptions
    }
    
    func displayGTDOptions(_ inGTDItem: workingGTDItem, inDisplayType: String, xPos: CGFloat, yPos: CGFloat) -> UIAlertController
    {
        // Need to get the name of the GTD Level
        
        var myChildType: String = ""
        var myLevelType: String = ""
        var actionType: String = ""
        
        if inGTDItem.GTDLevel == Int32(mySelectedTeam.GTDLevels.count)
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
        
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .actionSheet)
        
        let myOption1 = UIAlertAction(title: "Edit \(myLevelType)", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = GTDStoryboard.instantiateViewController(withIdentifier: "GTDEditController") as! GTDEditViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            
            popoverContent.inGTDObject = inGTDItem
                
            popoverContent.preferredContentSize = CGSize(width: 500,height: 400)
            
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 500, 400)
            popover!.sourceRect = CGRect(x: 0, y: 0, width: 500, height: 400)
            
      //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
      //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.present(popoverContent, animated: true, completion: nil)
            })
            
        let myOption2 = UIAlertAction(title: "Delete entry", style: .default, handler: { (action: UIAlertAction) -> () in
            if !inGTDItem.delete()
            {
                let alert = UIAlertController(title: "Delete item", message:
                    "Unable to delete item.  Check that there are no child records", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert, animated: false, completion: nil)
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
            myOption0 = UIAlertAction(title: "Add \(myChildType)", style: .default, handler: { (action: UIAlertAction) -> () in
                if actionType == "GTDItem"
                { // GTDItem
                    let popoverContent = GTDStoryboard.instantiateViewController(withIdentifier: "GTDEditController") as! GTDEditViewController
                    popoverContent.modalPresentationStyle = .popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = self.view
                
                    let tempChild = workingGTDItem(inTeamID: self.mySelectedTeam.teamID, inParentID: inGTDItem.GTDItemID)
                    tempChild.GTDLevel = inGTDItem.GTDLevel + 1
                    popoverContent.inGTDObject = tempChild
                
                    popoverContent.preferredContentSize = CGSize(width: 500,height: 400)
                    
                    //  Calculate the start position based on screen width and position of the item
                    //            let myXPos = xPos
                    //            let myYPos = yPos
                    //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
                    
                    //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 500, 400)
                    popover!.sourceRect = CGRect(x: 0, y: 0, width: 500, height: 400)
                    
                    //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
                    //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
                    self.present(popoverContent, animated: true, completion: nil)

                }
                else
                {  // Project
                    let popoverContent = projectsStoryboard.instantiateViewController(withIdentifier: "MaintainProject") as! MaintainProjectViewController
                    popoverContent.modalPresentationStyle = .popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = self.view
                    
                    let tempProject = project(inTeamID: self.mySelectedTeam.teamID)
 //                   self.myParentObject = tempProject
                    tempProject.GTDItemID = inGTDItem.GTDItemID
                    popoverContent.inProjectObject = tempProject
                    popoverContent.myActionType = "Add"
                    popoverContent.mySelectedTeam = self.mySelectedTeam
                        
                    popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
                        
                    //  Calculate the start position based on screen width and position of the item
                    //            let myXPos = xPos
                    //            let myYPos = yPos
                    //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
                    
                    //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
                    popover!.sourceRect = CGRect(x: 0, y: 0, width: 700, height: 700)
                    
                    //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
                    //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
                    self.present(popoverContent, animated: true, completion: nil)
                }
            })
            myOptions.addAction(myOption0)
        }
        else if inDisplayType == "Body"
        {
            myOption0 = UIAlertAction(title: "Zoom", style: .default, handler: { (action: UIAlertAction) -> () in
                self.myDisplayHeadArray = self.myDisplayBodyArray
                self.highlightID = inGTDItem.GTDItemID
                self.buildHead(self.highlightID)
                    
                self.buildBody(inGTDItem)
            })
            myOptions.addAction(myOption0)
        }
            
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        
        return myOptions
    }
    
    func displayProjectOptions(_ inProjectItem: project, inDisplayType: String, xPos: CGFloat, yPos: CGFloat) -> UIAlertController
    {
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .actionSheet)
        
        let myOption1 = UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = projectsStoryboard.instantiateViewController(withIdentifier: "MaintainProject") as! MaintainProjectViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            
            popoverContent.inProjectObject = inProjectItem
            popoverContent.myActionType = "Edit"
            popoverContent.mySelectedTeam = self.mySelectedTeam
            
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRect(x: 0, y: 0, width: 700, height: 700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        if inDisplayType == "Body"
        {
            let myOption0 = UIAlertAction(title: "Zoom", style: .default, handler: { (action: UIAlertAction) -> () in
                self.myDisplayHeadArray = self.myDisplayBodyArray
                self.highlightID = inProjectItem.projectID
                self.buildHead(self.highlightID)
                
                self.buildBody(inProjectItem)
            })
            myOptions.addAction(myOption0)
            
            let myOption2 = UIAlertAction(title: "Delete Activity", style: .default, handler: { (action: UIAlertAction) -> () in
                if !inProjectItem.delete()
                {
                    let alert = UIAlertController(title: "Delete Activity", message:
                        "Unable to delete Activity.  Check that there are no Actions", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert, animated: false, completion: nil)
                }
                else
                {
                    self.buildHead(self.highlightID)
                    self.buildBody(self.mySavedParentObject)
                }
            })
            myOptions.addAction(myOption2)
        }
        
        let myOption3 = UIAlertAction(title: "Add Action", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "tasks") as! taskViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            
            let newTask = task(inTeamID: self.mySelectedTeam.teamID)
            newTask.projectID = inProjectItem.projectID
            popoverContent.passedTask = newTask
            
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRect(x: 0, y: 0, width: 700, height: 700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.present(popoverContent, animated: true, completion: nil)
        })

        myOptions.addAction(myOption1)
        myOptions.addAction(myOption3)
        
        return myOptions
    }
    
    func displayTaskOptions(_ workingTask: task, displayType: String, xPos: CGFloat, yPos: CGFloat) -> UIAlertController
    {
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .actionSheet)

        let myOption1 = UIAlertAction(title: "Edit Action", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "tasks") as! taskViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            
            popoverContent.passedTask = workingTask
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            
            //  Calculate the start position based on screen width and position of the item
            //            let myXPos = xPos
            //            let myYPos = yPos
            //            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
            //            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRect(x: 0, y: 0, width: 700, height: 700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        let myOption2 = UIAlertAction(title: "Action Updates", style: .default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = tasksStoryboard.instantiateViewController(withIdentifier: "taskUpdate") as! taskUpdatesViewController
            popoverContent.modalPresentationStyle = .popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            
            //  Calculate the start position based on screen width and position of the item
//            let myXPos = xPos
//            let myYPos = yPos
//            let arrowRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 10, 10)
            
//            popover!.sourceRect = CGRectMake(myXPos + 20, myYPos + self.headerSize, 700, 700)
            popover!.sourceRect = CGRect(x: 0, y: 0, width: 700, height: 700)
 
            popoverContent.passedTask = workingTask
            popoverContent.preferredContentSize = CGSize(width: 700,height: 700)
            
            //      let aPopover =  UIPopoverController(contentViewController: popoverContent)
            //      aPopover.presentPopoverFromRect(arrowRect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            self.present(popoverContent, animated: true, completion: nil)
        })
        
        let myOption3 = UIAlertAction(title: "Delete Action", style: .default, handler: { (action: UIAlertAction) -> () in
            let _ = workingTask.delete()
        })

        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        myOptions.addAction(myOption3)
        
        return myOptions
    }
    
    func displaySubmenu(_ notification: Notification)
    {
        let sectionType = notification.userInfo!["sectionType"] as! String
        let rowString = notification.userInfo!["rowNumber"] as! String
        
        let rowNumber = Int(rowString)
        
        if sectionType == "head"
        { // Head
            var myOptions: UIAlertController!
                    
            if myDisplayHeadArray[rowNumber!] is team
            {
                let tempObject = myDisplayHeadArray[rowNumber!] as! team
                highlightID = tempObject.teamID
                        
                myOptions = displayTeamOptions(myDisplayHeadArray[rowNumber!] as! team)
            }
            else if myDisplayHeadArray[rowNumber!] is workingGTDItem
            {
                let tempObject = myDisplayHeadArray[rowNumber!] as! workingGTDItem
                highlightID = tempObject.GTDItemID
                myOptions = displayGTDOptions(myDisplayHeadArray[rowNumber!] as! workingGTDItem, inDisplayType: "Head", xPos: myHeadCells[rowNumber!].displayX, yPos: myHeadCells[rowNumber!].displayY)
            }
            else if myDisplayHeadArray[rowNumber!] is project
            {
                let tempObject = myDisplayHeadArray[rowNumber!] as! project
                highlightID = tempObject.projectID
                        
                myOptions = displayProjectOptions(myDisplayHeadArray[rowNumber!] as! project, inDisplayType: "Head", xPos: myHeadCells[rowNumber!].displayX, yPos: myHeadCells[rowNumber!].displayY)
            }
            myOptions.popoverPresentationController!.sourceView = self.view
                    
            myOptions.popoverPresentationController!.sourceRect = CGRect(x: myHeadCells[rowNumber!].displayX + 20,y:  myHeadCells[rowNumber!].displayY + headerSize, width: 0, height: 0)
                    
            self.present(myOptions, animated: true, completion: nil)
        }
        else
        { // Body
            var myOptions: UIAlertController!
            if myDisplayBodyArray[rowNumber!] is workingGTDItem
            {
                let tempObject = myDisplayBodyArray[rowNumber!] as! workingGTDItem
                highlightID = tempObject.GTDItemID
                        
                myOptions = displayGTDOptions(myDisplayBodyArray[rowNumber!] as! workingGTDItem, inDisplayType: "Body", xPos: myBodyCells[rowNumber!].displayX, yPos: myBodyCells[rowNumber!].displayY)
            }
            else if myDisplayBodyArray[rowNumber!] is project
            {
                let tempObject = myDisplayBodyArray[rowNumber!] as! project
                highlightID = tempObject.projectID
                        
                myOptions = displayProjectOptions(myDisplayBodyArray[rowNumber!] as! project, inDisplayType: "Body", xPos: myBodyCells[rowNumber!].displayX, yPos: myBodyCells[rowNumber!].displayY)
            }
            else if myDisplayBodyArray[rowNumber!] is task
            {
                myOptions = displayTaskOptions(myDisplayBodyArray[rowNumber!] as! task, displayType: "Body", xPos: myBodyCells[rowNumber!].displayX, yPos: myBodyCells[rowNumber!].displayY)
            }
                    
            myOptions.popoverPresentationController!.sourceView = self.view
                    
            myOptions.popoverPresentationController!.sourceRect = CGRect(x: myBodyCells[rowNumber!].displayX + 20, y: myBodyCells[rowNumber!].displayY + headerSize, width: 0, height: 0)
                    
            self.present(myOptions, animated: true, completion: nil)
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
    
    @IBAction func btnDetails(_ sender: UIButton)
    {
        let selectedDictionary = ["sectionType" : sectionType, "rowNumber": "\(rowNumber)"]
        notificationCenter.post(name: NotificationDisplayGTDSubmenu, object: nil, userInfo:selectedDictionary as [String : String])
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
    
    @IBAction func btnDetails(_ sender: UIButton)
    {
        let selectedDictionary = ["sectionType" : sectionType, "rowNumber": "\(rowNumber)"]
        notificationCenter.post(name: NotificationDisplayGTDSubmenu, object: nil, userInfo:selectedDictionary as [String : String])
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
