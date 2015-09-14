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
    private var myParentObject: AnyObject!
    private var mySelectedTeam: team!
    private var myBodyObjectType: String = ""
    private var myHeadObjectType: String = ""
    private var mySavedParentObject: AnyObject!
    
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
        buildHead("Team", inHighlightedID: myCurrentTeam.teamID)
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellBody", forIndexPath: indexPath) as! myGTDDisplay
            
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
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(task)
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! task
                cell.lblName.text = tempObject.title
                cell.lblChildren.text = ""
                
                if highlightID == tempObject.taskID
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
            
            
            let lpgr = textLongPressGestureRecognizer(target: self, action: "handleLongPress:")
            lpgr.minimumPressDuration = 0.5
            lpgr.delaysTouchesBegan = true
            lpgr.delegate = self
            lpgr.displayView = cell.contentView
            self.colBody.addGestureRecognizer(lpgr)
            
            cell.layoutSubviews()
            return cell
        }
        else
        {  // Body
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellBody", forIndexPath: indexPath) as! myGTDDisplay

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
            else if myDisplayBodyArray[indexPath.row].isKindOfClass(task)
            {
                let tempObject = myDisplayBodyArray[indexPath.row] as! task
                cell.lblName.text = tempObject.title
                cell.lblChildren.text = ""
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

            cell.layoutSubviews()
            return cell
        }
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        if collectionView == colBody
        {
            retVal = CGSize(width: 225, height: 125)
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
                buildBody("Team", inParentObject: tempObject)
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(workingGTDItem)
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! workingGTDItem
                highlightID = tempObject.GTDItemID
                buildBody("GTDItem", inParentObject: tempObject)
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(project)
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! project
                highlightID = tempObject.projectID
                buildBody("task", inParentObject: tempObject)
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(task)
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! task
                highlightID = tempObject.taskID
                buildBody("task", inParentObject: tempObject)
            }
            else if myDisplayHeadArray[indexPath.row].isKindOfClass(context)
            {
                let tempObject = myDisplayHeadArray[indexPath.row] as! context
                highlightID = tempObject.contextID
                buildBody("context", inParentObject:tempObject)
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
                    buildHead("GTDItem", inHighlightedID: highlightID)
                    buildBody("GTDItem",inParentObject: myObject)
                }
                else
                {
                    buildHead("GTDItem", inHighlightedID: highlightID)
                    buildBody("project",inParentObject: myObject)
                }
            }
            else if myDisplayBodyArray[indexPath.row].isKindOfClass(project)
            {
                myDisplayHeadArray = myDisplayBodyArray
                
                let myObject = myDisplayBodyArray[indexPath.row] as! project
                highlightID = myObject.projectID
                
                buildHead("project", inHighlightedID: highlightID)
                buildBody("task",inParentObject: myObject)
            }
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
            switch kind
            {
            case UICollectionElementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "cellSectionHeader", forIndexPath: indexPath)
                    as! GTDHeaderView
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
                
                return headerView
                
            default:
                assert(false, "Unexpected element kind")
            }
    }

    // Start move

    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void
    {
        NSLog("Action move")
        /*
        if fromIndexPath.item > myGTDHierarchy.count
        {
            NSLog("Do nothing, outside of rearrange")
        }
        else
        {
            //   let name = myDisplayHierarchy[fromIndexPath.item]
            //    let myObject = myGTDHierarchy[fromIndexPath.item]

            // We now need to update the underlying database tables

            myGTDHierarchy[fromIndexPath.item].moveLevel(toIndexPath.item + 1)

            loadHierarchy()
            for myItem in myGTDHierarchy
            {
                NSLog("Name = \(myItem.title) Level = \(myItem.GTDLevel)")
            }

            colHierarchy.reloadData()
            
            //    myDisplayHierarchy.removeAtIndex(fromIndexPath.item)
            //    myDisplayHierarchy.insert(name, atIndex: toIndexPath.item)
            //    myGTDHierarchy.removeAtIndex(fromIndexPath.item)
            //    myGTDHierarchy.insert(myObject, atIndex: toIndexPath.item)
        }
 
*/
    }
    
    // End move
    
    func handleLongPress(gestureReconizer: textLongPressGestureRecognizer)
    {
        
        if gestureReconizer.state == .Ended
        {
            let p = gestureReconizer.locationInView(self.colBody)
            let indexPath = self.colBody.indexPathForItemAtPoint(p)
        
            //var cell = self.colBody.cellForItemAtIndexPath(index)

            if let index = indexPath
            {
                if index.section == 0
                { // Head
                    if myDisplayHeadArray[index.row].isKindOfClass(team)
                    {
                        let tempObject = myDisplayHeadArray[indexPath!.row] as! team
                        highlightID = tempObject.teamID
                        
                        let myOptions = displayTeamOptions(gestureReconizer.displayView, inTeam: myDisplayHeadArray[index.row] as! team)
                        
                        myOptions.popoverPresentationController!.sourceView = gestureReconizer.displayView
                  //      myOptions.popoverPresentationController!.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
                        self.presentViewController(myOptions, animated: true, completion: nil)
                    }
                    else if myDisplayHeadArray[index.row].isKindOfClass(workingGTDItem)
                    {
                        let tempObject = myDisplayHeadArray[indexPath!.row] as! workingGTDItem
                        highlightID = tempObject.GTDItemID
                        let myOptions = displayGTDOptions(gestureReconizer.displayView, inGTDItem: myDisplayHeadArray[index.row] as! workingGTDItem, inDisplayType: "Head")
                        myOptions.popoverPresentationController!.sourceView = gestureReconizer.displayView
                  //      myOptions.popoverPresentationController!.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
                        self.presentViewController(myOptions, animated: true, completion: nil)
                    }
                    else if myDisplayHeadArray[index.row].isKindOfClass(project)
                    {
                        let tempObject = myDisplayHeadArray[indexPath!.row] as! project
                        highlightID = tempObject.projectID

                        let myOptions = displayProjectOptions(gestureReconizer.displayView, inProjectItem: myDisplayHeadArray[index.row] as! project, inDisplayType: "Head")
                        myOptions.popoverPresentationController!.sourceView = gestureReconizer.displayView
                   //     myOptions.popoverPresentationController!.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
                        self.presentViewController(myOptions, animated: true, completion: nil)
                    }
                }
                else
                { // Body
                    if myDisplayBodyArray[index.row].isKindOfClass(workingGTDItem)
                    {
                        let tempObject = myDisplayBodyArray[indexPath!.row] as! workingGTDItem
                        highlightID = tempObject.GTDItemID

                        let myOptions = displayGTDOptions(gestureReconizer.displayView, inGTDItem: myDisplayBodyArray[index.row] as! workingGTDItem, inDisplayType: "Body")
                        myOptions.popoverPresentationController!.sourceView = gestureReconizer.displayView
                  //      myOptions.popoverPresentationController!.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
                        self.presentViewController(myOptions, animated: true, completion: nil)
                    }
                    else if myDisplayBodyArray[index.row].isKindOfClass(project)
                    {
                        let tempObject = myDisplayBodyArray[indexPath!.row] as! project
                        highlightID = tempObject.projectID
                        
                        let myOptions = displayProjectOptions(gestureReconizer.displayView, inProjectItem: myDisplayBodyArray[index.row] as! project, inDisplayType: "Body")
                        myOptions.popoverPresentationController!.sourceView = gestureReconizer.displayView
                //        myOptions.popoverPresentationController!.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
                        self.presentViewController(myOptions, animated: true, completion: nil)
                    }
                }
                
            }
            else
            {
                NSLog("Could not find index path")
            }
            colBody.reloadData()
        }
    }
    
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
                
                    highlightID = myCurrentTeam.teamID
                    buildHead("Team", inHighlightedID: myCurrentTeam.teamID)
                }
                else
                { // parent is another GTD level
                    myDisplayHeadArray.removeAll()
                    let myArray = myDatabaseConnection.getGTDItemsForLevel(tempObject.GTDLevel - 1 as Int, inTeamID: tempObject.teamID)
                    for myItem in myArray
                    {
                        let myClass = workingGTDItem(inGTDItemID: myItem.gTDItemID as! Int, inTeamID: tempObject.teamID as Int)
                        myDisplayHeadArray.append(myClass)
                    }
                    
                    highlightID = tempObject.GTDItemID
                    buildHead("GTDItem", inHighlightedID: highlightID)
                }
            
            case "project":
                myDisplayHeadArray.removeAll()
            
                let myObject = myParentObject as! project  // this is the current head record
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
                    buildHead("Team", inHighlightedID: myCurrentTeam.teamID)
                }
                else
                { // parent is another GTD level
                    let myArray = myDatabaseConnection.getGTDItemsForLevel(myObject2.GTDLevel - 1 as Int, inTeamID: myObject2.teamID)
                    for myItem in myArray
                    {
                        let myClass = workingGTDItem(inGTDItemID: myItem.gTDItemID as! Int, inTeamID: myObject2.teamID as Int)
                        myDisplayHeadArray.append(myClass)
                    }
                    
                    highlightID = myObject2.GTDItemID
                    buildHead("GTDItem", inHighlightedID: highlightID)
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
    
    func buildHead(inObjectType: String, inHighlightedID: Int)
    {
        // Populate Head
        myHeadObjectType = inObjectType
        
        switch inObjectType
        {
            case "Team":
                btnUp.hidden = true
                
                for myItem in myDisplayHeadArray
                {
                    let myObject = myItem as! team
                    
                    if myObject.teamID == inHighlightedID
                    {
                        highlightID = myObject.teamID as Int
                        buildBody("Team", inParentObject: myObject)
                    }
                }
        
            case "GTDItem":
                var upSet: Bool = false
            
                for myItem in myDisplayHeadArray
                {
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
                    }
                    
                    if myObject.GTDItemID == inHighlightedID
                    {
                        highlightID = myObject.GTDItemID as Int
                        buildBody("GTDItem", inParentObject: myObject)
                    }
                }
        
            case "project":
                btnUp.hidden = false
                btnUp.setTitle("Up to Area of Responsibility", forState: .Normal)
            
                for myItem in myDisplayHeadArray
                {
                    let myObject = myItem as! project
                    
                    if myObject.projectID == inHighlightedID
                    {
                        highlightID = myObject.projectID as Int
                        buildBody("task", inParentObject: myObject)
                    }
                }
        
            case "task":
                btnUp.hidden = false
                btnUp.setTitle("Up to Activity", forState: .Normal)
        
            case "context":
                btnUp.hidden = false
                btnUp.setTitle("Up to Team", forState: .Normal)
        
            default :
                print("buildHead: hit default")
        }
    }
    
    func buildBody(inObjectType: String, inParentObject: AnyObject)
    {
        myDisplayBodyArray.removeAll()
        
        myBodyObjectType = inObjectType
        mySavedParentObject = inParentObject
        
        switch inObjectType
        {
            case "Team":
                let myObject = inParentObject as! team
                for myItem in myObject.GTDTopLevel
                {
                    myDisplayBodyArray.append(myItem)
                }
            
            case "GTDItem":
                let myObject = inParentObject as! workingGTDItem
                
                for myItem in myObject.children
                {
                    myDisplayBodyArray.append(myItem)
                }
            
            case "project":
                let myObject = inParentObject as! workingGTDItem
                for myItem in myObject.children
                {
                    myDisplayBodyArray.append(myItem)
                }
            
            case "task":
                NSLog("todo")
  //              let myObject = inParentObject as! task
 //               for myItem in myObject.tasks
 //               {
 //                   myDisplayBodyArray.append(myItem)
 //               }
            
            case "context":
                let myObject = inParentObject as! context
            NSLog("\(myObject.name)")
            
            default :
                print("buildBody: hit default")
        }
        colBody.reloadData()
    }

    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .FullScreen
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
        // Rebuild tables
      //  myBodyObjectType = inObjectType
      //  mySavedParentObject = inParentObject
        
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

                buildHead("Team", inHighlightedID: highlightID)
            
            case "GTDItem":
                myDisplayHeadArray.removeAll()
                let tempObject = mySavedParentObject as! workingGTDItem
            
                let myArray = myDatabaseConnection.getGTDItemsForLevel(tempObject.GTDLevel as Int, inTeamID: tempObject.teamID)
                for myItem in myArray
                {
                    let myClass = workingGTDItem(inGTDItemID: myItem.gTDItemID as! Int, inTeamID: tempObject.teamID as Int)
                    myDisplayHeadArray.append(myClass)
                }
                
                highlightID = tempObject.GTDItemID
                buildHead("GTDItem", inHighlightedID: highlightID)
            
            case "project":
                myDisplayHeadArray.removeAll()
            
                let myObject = myParentObject as! project  // this is the current head record
                let myObject2 = workingGTDItem(inGTDItemID: myObject.GTDItemID, inTeamID: myObject.teamID)  // This is the parent of that
            
                myDisplayHeadArray = myObject2.children
                
                highlightID = myObject2.GTDItemID
                buildHead("project", inHighlightedID: highlightID)
            
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
    
    func displayTeamOptions(inSourceView: UIView, inTeam: team) -> UIAlertController
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
            popover!.sourceView = inSourceView
            
            let tempChild = workingGTDItem(inTeamID: inTeam.teamID, inParentID: 0)
            tempChild.GTDLevel = 1
            popoverContent.inGTDObject = tempChild
            
            popoverContent.preferredContentSize = CGSizeMake(500,400)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        let myOption2 = UIAlertAction(title: "Edit Team", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("TeamMaintenance") as! teamMaintenanceViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = inSourceView
            
            let parentObject = inTeam
            popoverContent.myWorkingTeam = parentObject
            
            popoverContent.preferredContentSize = CGSizeMake(800,700)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        let myOption3 = UIAlertAction(title: "Maintain Team Settings", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MaintainTeamDecodes") as! teamDecodesViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = inSourceView
            
            let parentObject = inTeam
            popoverContent.myWorkingTeam = parentObject
            
            popoverContent.preferredContentSize = CGSizeMake(600,400)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        let myOption4 = UIAlertAction(title: "New Team", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("TeamMaintenance") as! teamMaintenanceViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = inSourceView
            
            let parentObject = team()
            popoverContent.myWorkingTeam = parentObject
            
            popoverContent.preferredContentSize = CGSizeMake(800,700)
            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        myOptions.addAction(myOption3)
        myOptions.addAction(myOption4)
        
        return myOptions
    }
    
    func displayGTDOptions(inSourceView: UIView, inGTDItem: workingGTDItem, inDisplayType: String) -> UIAlertController
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
            popover!.sourceView = inSourceView
            popover!.sourceRect = CGRectMake(500,400,0,0)
            
            popoverContent.inGTDObject = inGTDItem
                
            popoverContent.preferredContentSize = CGSizeMake(500,400)
            self.presentViewController(popoverContent, animated: true, completion: nil)
            })
            
        let myOption2 = UIAlertAction(title: "Delete entry", style: .Default, handler: { (action: UIAlertAction) -> () in
            if !inGTDItem.delete()
            {
                let alert = UIAlertController(title: "Delete item", message:
                    "Unable to delete item.  Check that there are not child records", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alert, animated: false, completion: nil)
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
                    popover!.sourceView = inSourceView
                
                    let tempChild = workingGTDItem(inTeamID: self.mySelectedTeam.teamID, inParentID: inGTDItem.GTDItemID)
                    tempChild.GTDLevel = inGTDItem.GTDLevel + 1
                    popoverContent.inGTDObject = tempChild
                
                    popoverContent.preferredContentSize = CGSizeMake(500,400)
                    self.presentViewController(popoverContent, animated: true, completion: nil)
                }
                else
                {  // Project
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MaintainProject") as! MaintainProjectViewController
                    popoverContent.modalPresentationStyle = .Popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = inSourceView
                    popover!.sourceRect = CGRectMake(700,700,0,0)
                    
                    let tempProject = project(inTeamID: self.mySelectedTeam.teamID)
                    self.myParentObject = tempProject
                    tempProject.GTDItemID = inGTDItem.GTDItemID
                    popoverContent.inProjectObject = tempProject
                    popoverContent.myActionType = "Add"
                    popoverContent.mySelectedTeam = self.mySelectedTeam
                        
                    popoverContent.preferredContentSize = CGSizeMake(700,700)
                        
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
                self.buildHead("GTDItem", inHighlightedID: self.highlightID)
                    
                self.buildBody("GTDItem",inParentObject: inGTDItem)
            })
            myOptions.addAction(myOption0)
        }
            
        myOptions.addAction(myOption1)
        myOptions.addAction(myOption2)
        
        return myOptions
    }
    
    func displayProjectOptions(inSourceView: UIView, inProjectItem: project, inDisplayType: String) -> UIAlertController
    {
        let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .ActionSheet)
        
        let myOption1 = UIAlertAction(title: "Edit", style: .Default, handler: { (action: UIAlertAction) -> () in
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MaintainProject") as! MaintainProjectViewController
            popoverContent.modalPresentationStyle = .Popover
            let popover = popoverContent.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = inSourceView
            popover!.sourceRect = CGRectMake(700,700,0,0)
            
            self.myParentObject = inProjectItem
            popoverContent.inProjectObject = inProjectItem
            popoverContent.myActionType = "Edit"
            popoverContent.mySelectedTeam = self.mySelectedTeam
            
            popoverContent.preferredContentSize = CGSizeMake(700,700)

            self.presentViewController(popoverContent, animated: true, completion: nil)
        })
        
        if inDisplayType == "Body"
        {
            let myOption0 = UIAlertAction(title: "Zoom", style: .Default, handler: { (action: UIAlertAction) -> () in
                self.myDisplayHeadArray = self.myDisplayBodyArray
                self.highlightID = inProjectItem.projectID as Int
                self.buildHead("project", inHighlightedID: self.highlightID)
                
                self.buildBody("task",inParentObject: inProjectItem)
            })
            myOptions.addAction(myOption0)
        }
        
        myOptions.addAction(myOption1)
        
        return myOptions
    }

}

class KDRearrangeableGTDDisplayHierarchy: UICollectionViewCell
{
    
    @IBOutlet weak var lblChildren: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
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
    
    
    @IBAction func btnAdd(sender: UIButton)
    {
      //  NSNotificationCenter.defaultCenter().postNotificationName("NotificationChangeSettings", object: nil, userInfo:["setting":"HierarchyUpdate", "Item": myGTDLevel])
        
        NSLog("Add pressed")
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