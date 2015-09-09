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

class MaintainGTDPlanningViewController: UIViewController,  UIScrollViewDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate, KDRearrangeableCollectionViewDelegate
{
    
    @IBInspectable var popoverOniPhone:Bool = false
    @IBInspectable var popoverOniPhoneLandscape:Bool = true
    
    var passedGTD: GTDModel!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var scrollHead: UIScrollView!
    @IBOutlet weak var btnUp: UIButton!
    @IBOutlet weak var colBody: UICollectionView!
    
    private var containerViewHead: UIView!

    private var myDisplayHeadArray: [AnyObject] = Array()
    private var myDisplayBodyArray: [AnyObject] = Array()
    private var highlightID: Int = 0
    private var myParentObject: AnyObject!
    private var myParentType: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
   //     passedGTD = (tabBarController as! GTDPlanningTabViewController).myPassedGTD
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
        containerViewHead = UIView()
        
        myDisplayHeadArray.removeAll()
        
        let myTeamArray = myDatabaseConnection.getAllTeams()
        for myTeamItem in myTeamArray
        {
            let myTeam = team(inTeamID: myTeamItem.teamID as Int)
            myDisplayHeadArray.append(myTeam)
        }
        
        highlightID = myCurrentTeam.teamID
        buildHead("team", inHighlightedID: myCurrentTeam.teamID)
        
   //     if passedGTD.actionSource == "Project"
   //     {
   //         buildTopLevel()
   //     }
   //     else if passedGTD.actionSource == "Context"
   //     {
//println("Put in initial context code here")
//        }
//        else
 //       {
   //         println("No action sent")
   //     }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()

        if myDisplayHeadArray.count > 0
        {
            let contentWidth = buildDisplayHead(myDisplayHeadArray, inWidth: 200, inHeight: 100, inSpacing: 40, inStartX: 0, inStartY: 0, inHighlightID: highlightID)
        
            // Set up the container view to hold your custom view hierarchy
            let containerSize = CGSizeMake(contentWidth, 120)
        
            containerViewHead.frame = CGRect(origin: CGPointMake(0.0, 0.0), size:containerSize)
        }
        
        if myDisplayBodyArray.count > 0
        {
            colBody.collectionViewLayout.invalidateLayout()
            colBody.reloadData()
        }
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == colBody
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
   //     if collectionView == colBody
   //     {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellBody", forIndexPath: indexPath) as! myGTDDisplay

            if myDisplayBodyArray[indexPath.row].isKindOfClass(team)
            {
                cell.lblName.text = myDisplayBodyArray[indexPath.row].name
                cell.lblChildren.text = ""
            }
            else if myDisplayBodyArray[indexPath.row].isKindOfClass(purposeAndCoreValue)
            {
                let tempObject = myDisplayBodyArray[indexPath.row] as! purposeAndCoreValue
                
                cell.lblName.text = tempObject.title
                
                let myChildRecords = tempObject.vision.count
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
            else if myDisplayBodyArray[indexPath.row].isKindOfClass(gvision)
            {
                let tempObject = myDisplayBodyArray[indexPath.row] as! gvision
                cell.lblName.text = tempObject.title
                
                let myChildRecords = tempObject.goals.count
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
            else if myDisplayBodyArray[indexPath.row].isKindOfClass(goalAndObjective)
            {
                let tempObject = myDisplayBodyArray[indexPath.row] as! goalAndObjective
                cell.lblName.text = tempObject.title
                
                let myChildRecords = tempObject.areas.count
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
            else if myDisplayBodyArray[indexPath.row].isKindOfClass(areaOfResponsibility)
            {
                let tempObject = myDisplayBodyArray[indexPath.row] as! areaOfResponsibility
                cell.lblName.text = tempObject.title
                
                let myChildRecords = tempObject.projects.count
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
            
            cell.layer.borderColor = UIColor.lightGrayColor().CGColor
            cell.layer.borderWidth = 0.5
            cell.layer.cornerRadius = 5.0
            cell.layer.masksToBounds = true

            cell.layoutSubviews()
            return cell
     /*   }
        else
        {  // colHierarchy
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellHierarchy", forIndexPath: indexPath) as! mySettingHierarchy
            cell.lblName.text  = myDisplayHierarchy[indexPath.row]
            
            if myDisplayHierarchy[indexPath.row] == "Projects" || myDisplayHierarchy[indexPath.row] == "Tasks"
            {
                cell.btnRemove.hidden = true
                cell.btnRename.hidden = true
            }
            else
            {
                cell.btnRemove.hidden = false
                cell.btnRename.hidden = false
                cell.myGTDLevel = myGTDHierarchy[indexPath.row]
            }
            
            if (indexPath.row % 2 == 0)  // was .row
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
*/
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        if collectionView == colBody
        {
            retVal = CGSize(width: 225, height: 125)
        }
    //    else
     //   {
     //       retVal = CGSize(width: colHierarchy.bounds.size.width, height: 100)
     //   }
        
        return retVal
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        var workingClassType: String = ""
        if collectionView == colBody
        {
            var myOption0: UIAlertAction!
            
            let myOptions: UIAlertController = UIAlertController(title: "Select Action", message: "Select action to take", preferredStyle: .ActionSheet)
            myOptions.popoverPresentationController!.sourceView = self.view;
            myOptions.popoverPresentationController!.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
            
            if myDisplayBodyArray[indexPath.row].isKindOfClass(purposeAndCoreValue)
            {
                workingClassType = "purposeAndCoreValue"
                myOption0 = UIAlertAction(title: "Zoom", style: .Default, handler: { (action: UIAlertAction) -> () in
                    self.myDisplayHeadArray = self.myDisplayBodyArray
                    let myObject = self.myDisplayBodyArray[indexPath.row] as! purposeAndCoreValue
                    self.highlightID = myObject.purposeID as Int
                    self.buildHead("purposeAndCoreValue", inHighlightedID: self.highlightID)
                    
                    self.buildBody("gvision",inParentObject: myObject)
                    self.lblDetail.text = "My Visions"
                })

            }
            if myDisplayBodyArray[indexPath.row].isKindOfClass(gvision)
            {
                workingClassType = "gvision"
                myOption0 = UIAlertAction(title: "Zoom", style: .Default, handler: { (action: UIAlertAction) -> () in
                    self.myDisplayHeadArray = self.myDisplayBodyArray
                    let myObject = self.myDisplayBodyArray[indexPath.row] as! gvision
                    self.highlightID = myObject.visionID as Int
                    self.buildHead("gvision", inHighlightedID: self.highlightID)
                    self.buildBody("goalAndObjective",inParentObject: myObject)
                    self.lblDetail.text = "My Goal and Objectives"
                })
            }
            if myDisplayBodyArray[indexPath.row].isKindOfClass(goalAndObjective)
            {
                workingClassType = "goalAndObjective"
                myOption0 = UIAlertAction(title: "Zoom", style: .Default, handler: { (action: UIAlertAction) -> () in
                    self.myDisplayHeadArray = self.myDisplayBodyArray
                    let myObject = self.myDisplayBodyArray[indexPath.row] as! goalAndObjective
                    self.highlightID = myObject.goalID as Int
                    self.buildHead("goalAndObjective", inHighlightedID: self.highlightID)
                    self.buildBody("areaOfResponsibility",inParentObject: myObject)
                    self.lblDetail.text = "My Area of Responsibilitys"
                })
            }
            if myDisplayBodyArray[indexPath.row].isKindOfClass(areaOfResponsibility)
            {
                workingClassType = "areaOfResponsibility"
                myOption0 = UIAlertAction(title: "Zoom", style: .Default, handler: { (action: UIAlertAction) -> () in
                    self.myDisplayHeadArray = self.myDisplayBodyArray
                    let myObject = self.myDisplayBodyArray[indexPath.row] as! areaOfResponsibility
                    self.highlightID = myObject.areaID as Int
                    self.buildHead("areaOfResponsibility", inHighlightedID: self.highlightID)
                    self.buildBody("project",inParentObject: myObject)
                    self.lblDetail.text = "My Projects"
                })
            }
            if myDisplayBodyArray[indexPath.row].isKindOfClass(project)
            {
                workingClassType = "project"
                myOption0 = UIAlertAction(title: "Zoom", style: .Default, handler: { (action: UIAlertAction) -> () in
                    self.myDisplayHeadArray = self.myDisplayBodyArray
                    let myObject = self.myDisplayBodyArray[indexPath.row] as! project
                    self.highlightID = myObject.projectID as Int
                    self.buildHead("project", inHighlightedID: self.highlightID)
                    self.buildBody("task",inParentObject: myObject)
                    self.lblDetail.text = "My Tasks"
                })
            }
            if myDisplayBodyArray[indexPath.row].isKindOfClass(task)
            {
                workingClassType = "task"
                myOption0 = UIAlertAction(title: "Zoom", style: .Default, handler: { (action: UIAlertAction) -> () in
                    self.myDisplayHeadArray = self.myDisplayBodyArray
                    let myObject = self.myDisplayBodyArray[indexPath.row] as! task
                    self.highlightID = myObject.taskID as Int
                    self.buildHead("task", inHighlightedID: self.highlightID)
                //    self.buildBody("task",inParentObject: myObject)
                //    self.lblDetail.text = "My Tasks"
                })
            }
            if myDisplayBodyArray[indexPath.row].isKindOfClass(context)
            {
                workingClassType = "context"
                myOption0 = UIAlertAction(title: "Zoom", style: .Default, handler: { (action: UIAlertAction) -> () in
                    self.myDisplayHeadArray = self.myDisplayBodyArray
                    let myObject = self.myDisplayBodyArray[indexPath.row] as! context
                    self.highlightID = myObject.contextID as Int
                    self.buildHead("context", inHighlightedID: self.highlightID)
                    //    self.buildBody("task",inParentObject: myObject)
                    //    self.lblDetail.text = "My Tasks"
                })
            }
            
            if myDisplayBodyArray[indexPath.row].isKindOfClass(purposeAndCoreValue) ||
               myDisplayBodyArray[indexPath.row].isKindOfClass(gvision) ||
               myDisplayBodyArray[indexPath.row].isKindOfClass(goalAndObjective) ||
               myDisplayBodyArray[indexPath.row].isKindOfClass(areaOfResponsibility)
            {
                let myOption1 = UIAlertAction(title: "Edit", style: .Default, handler: { (action: UIAlertAction) -> () in
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("GTDEditController") as! GTDEditViewController
                    popoverContent.modalPresentationStyle = .Popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = self.view
                    popover!.sourceRect = CGRectMake(500,400,0,0)
                    
                switch workingClassType
                {
                case "purposeAndCoreValue" :
                    let parentObject = self.myDisplayBodyArray[indexPath.row] as! purposeAndCoreValue
                    popoverContent.inPurposeObject = parentObject
                    popoverContent.objectType = "purpose"

                    
                case "gvision" :
                    let parentObject = self.myDisplayBodyArray[indexPath.row] as! gvision
                    popoverContent.inVisionObject = parentObject
                    popoverContent.objectType = "vision"
                    
                case "goalAndObjective" :
                    let parentObject = self.myDisplayBodyArray[indexPath.row] as! goalAndObjective
                    popoverContent.inGoalObject = parentObject
                    popoverContent.objectType = "goal"
                    
                case "areaOfResponsibility" :
                    let parentObject = self.myDisplayBodyArray[indexPath.row] as! areaOfResponsibility
                    popoverContent.inAreaObject = parentObject
                    popoverContent.objectType = "area"
                    
                default:
                    print("")
                }
                
                popoverContent.preferredContentSize = CGSizeMake(500,400)
                self.presentViewController(popoverContent, animated: true, completion: nil)
                })
            
                let myOption2 = UIAlertAction(title: "Delete entry", style: .Default, handler: { (action: UIAlertAction) -> () in
                    switch workingClassType
                    {
                    case "purposeAndCoreValue" :
                        let parentObject = self.myDisplayBodyArray[indexPath.row] as! purposeAndCoreValue
                        if !parentObject.delete()
                        {
                            let alert = UIAlertController(title: "Delete Purpose", message:
                            "Unable to delete Purpose.  Check that there are not child records", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alert, animated: false, completion: nil)
                        }
                    
                    case "gvision" :
                        let parentObject = self.myDisplayBodyArray[indexPath.row] as! gvision
                        if !parentObject.delete()
                        {
                            let alert = UIAlertController(title: "Delete Vision", message:
                            "Unable to delete Vision.  Check that there are not child records", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alert, animated: false, completion: nil)
                        }
                    
                    case "goalAndObjective" :
                        let parentObject = self.myDisplayBodyArray[indexPath.row] as! goalAndObjective
                        if !parentObject.delete()
                        {
                            let alert = UIAlertController(title: "Delete Goal", message:
                            "Unable to delete Goal.  Check that there are not child records", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alert, animated: false, completion: nil)
                        }
                    
                    case "areaOfResponsibility" :
                        let parentObject = self.myDisplayBodyArray[indexPath.row] as! areaOfResponsibility
                        if !parentObject.delete()
                        {
                            let alert = UIAlertController(title: "Delete Area of Responsibility", message:
                            "Unable to delete Area of Responsibility.  Check that there are not child records", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alert, animated: false, completion: nil)
                        }
                    
                    default:
                        print("")
                    }
                })
                
                myOptions.addAction(myOption0)
                myOptions.addAction(myOption1)
                myOptions.addAction(myOption2)
            }
            self.presentViewController(myOptions, animated: true, completion: nil)
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
    
    
    
    
    
    
    
    @IBAction func btnUp(sender: UIButton)
    {
        switch myParentType
        {
            case "purposeAndCoreValue":
                myDisplayHeadArray.removeAll()
                
                let myTeamArray = myDatabaseConnection.getAllTeams()
                for myTeamItem in myTeamArray
                {
                    let myTeam = team(inTeamID: myTeamItem.teamID as Int)
                    myDisplayHeadArray.append(myTeam)
                }
                
                highlightID = myCurrentTeam.teamID
                buildHead("team", inHighlightedID: myCurrentTeam.teamID)
            
            case "gvision":
                myDisplayHeadArray.removeAll()
                
                let myObject = myParentObject as! gvision
                let myArray = myDatabaseConnection.getAllPurpose(myObject.teamID as Int)
                for myItem in myArray
                {
                    let myClass = purposeAndCoreValue(inPurposeID: myItem.purposeID as Int, inTeamID: myObject.teamID as Int)
                    myDisplayHeadArray.append(myClass)
                }

                highlightID = myObject.purposeID
                buildHead("purposeAndCoreValue", inHighlightedID: myObject.purposeID)
            
            case "goalAndObjective":
                myDisplayHeadArray.removeAll()
                
                let myObject = myParentObject as! goalAndObjective  // this is the current head record
                let myObject2 = gvision(inVisionID: myObject.visionID, inTeamID: myObject.teamID)  // This is the parent of that
                let myObject3 = purposeAndCoreValue(inPurposeID: myObject2.purposeID, inTeamID: myObject2.teamID)
                
                // Now get all the child visions

                for myItem in myObject3.vision
                {
                    myDisplayHeadArray.append(myItem)
                }
                
                highlightID = myObject.visionID
                buildHead("gvision", inHighlightedID: myObject.visionID)
 
            case "areaOfResponsibility":
                myDisplayHeadArray.removeAll()
            
                let myObject = myParentObject as! areaOfResponsibility  // this is the current head record
                let myObject2 = goalAndObjective(inGoalID: myObject.goalID, inTeamID: myObject.teamID)  // This is the parent of that
                let myObject3 = gvision(inVisionID: myObject2.visionID, inTeamID: myObject.teamID)

                for myItem in myObject3.goals
                {
                    myDisplayHeadArray.append(myItem)
                }
            
                highlightID = myObject.goalID
                buildHead("goalAndObjective", inHighlightedID: myObject.goalID)

            case "project":
                myDisplayHeadArray.removeAll()
            
                let myObject = myParentObject as! project  // this is the current head record
                let myObject2 = areaOfResponsibility(inAreaID: myObject.areaID, inTeamID: myObject.teamID)  // This is the parent of that
                let myObject3 = goalAndObjective(inGoalID: myObject2.goalID, inTeamID: myObject.teamID)
            
                for myItem in myObject3.areas
                {
                    myDisplayHeadArray.append(myItem)
                }
            
                highlightID = myObject.areaID
                buildHead("areaOfResponsibility", inHighlightedID: myObject.areaID)

            case "task":
                myDisplayHeadArray.removeAll()
            
                let myObject = myParentObject as! task  // this is the current head record
                let myObject2 = project(inProjectID: myObject.projectID, inTeamID: myObject.teamID)  // This is the parent of that
                let myObject3 = areaOfResponsibility(inAreaID: myObject2.areaID, inTeamID: myObject.teamID)
            
                for myItem in myObject3.projects
                {
                    myDisplayHeadArray.append(myItem)
                }
            
                highlightID = myObject.projectID
                buildHead("project", inHighlightedID: myObject.projectID)
            
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

        switch inObjectType
        {
            case "team":
                lblHeader.text = "My Teams"
                
                lblDetail.text = "My Purpose/Core Values"
                btnUp.hidden = true
                
                for myItem in myDisplayHeadArray
                {
                    let myObject = myItem as! team
                    
                    if myObject.teamID == inHighlightedID
                    {
                        highlightID = myObject.teamID as Int
                        buildBody("purposeAndCoreValue", inParentObject: myObject)
                    }
                }
        
            case "purposeAndCoreValue":
                lblHeader.text = "My Purpose/Core Values"
                btnUp.hidden = false
                btnUp.setTitle("Up to Team", forState: .Normal)
            
                for myItem in myDisplayHeadArray
                {
                    let myObject = myItem as! purposeAndCoreValue
                    
                    if myObject.purposeID == inHighlightedID
                    {
                        highlightID = myObject.purposeID as Int
                        buildBody("gvision", inParentObject: myObject)
                    }
                }
        
            case "gvision":
                lblHeader.text = "My Visions"
                btnUp.hidden = false
                btnUp.setTitle("Up to Purpose", forState: .Normal)
        
                for myItem in myDisplayHeadArray
                {
                    let myObject = myItem as! gvision
                    
                    if myObject.visionID == inHighlightedID
                    {
                        highlightID = myObject.visionID as Int
                        buildBody("goalAndObjective", inParentObject: myObject)
                    }
                }

            case "goalAndObjective":
                lblHeader.text = "My Goal and Objectives"
                btnUp.hidden = false
                btnUp.setTitle("Up to Vision", forState: .Normal)
            
                for myItem in myDisplayHeadArray
                {
                    let myObject = myItem as! goalAndObjective
                    
                    if myObject.goalID == inHighlightedID
                    {
                        highlightID = myObject.goalID as Int
                        buildBody("areaOfResponsibility", inParentObject: myObject)
                    }
                }
        
            case "areaOfResponsibility":
                lblHeader.text = "My Area of Responsibilitys"
                btnUp.hidden = false
                btnUp.setTitle("Up to Goals", forState: .Normal)
            
                for myItem in myDisplayHeadArray
                {
                    let myObject = myItem as! areaOfResponsibility
                    
                    if myObject.areaID == inHighlightedID
                    {
                        highlightID = myObject.areaID as Int
                        buildBody("project", inParentObject: myObject)
                    }
                }
        
            case "project":
                lblHeader.text = "My Projects"
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
                lblHeader.text = "My Tasks"
                btnUp.hidden = false
                btnUp.setTitle("Up to Project", forState: .Normal)
        
            case "context":
                lblHeader.text = "My Contexts"
                btnUp.hidden = false
                btnUp.setTitle("Up to Team", forState: .Normal)
        
            default :
                print("buildHead: hit default")
        }
        
        var contentWidth = buildDisplayHead(myDisplayHeadArray, inWidth: 200, inHeight: 100, inSpacing: 40, inStartX: 0, inStartY: 0, inHighlightID: inHighlightedID)
        
        if contentWidth < UIScreen.mainScreen().bounds.width
        {
            contentWidth = UIScreen.mainScreen().bounds.width
        }
        
        // Set up the container view to hold your custom view hierarchy
        let containerSize = CGSizeMake(contentWidth, 100)
        
        containerViewHead.frame = CGRect(origin: CGPointMake(0.0, 0.0), size:containerSize)
        scrollHead.addSubview(containerViewHead)
        
        // Tell the scroll view the size of the contents
        scrollHead.contentSize = containerSize;
        
        // Set up the minimum & maximum zoom scale
        let scrollViewFrame = scrollHead.frame
        let scaleWidth = scrollViewFrame.size.width / scrollHead.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollHead.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        
        scrollHead.minimumZoomScale = minScale
        scrollHead.maximumZoomScale = 1.0
        scrollHead.zoomScale = 1.0
        
        centerScrollViewContentsHead()
    }
    
    func buildBody(inObjectType: String, inParentObject: AnyObject)
    {
        myDisplayBodyArray.removeAll()
        
        switch inObjectType
        {
            case "purposeAndCoreValue":
                lblDetail.text = "My Purpose/Core Values"
                
                let myObject = inParentObject as! team
                let myArray = myDatabaseConnection.getAllPurpose(myObject.teamID as Int)
                for myItem in myArray
                {
                    let myClass = purposeAndCoreValue(inPurposeID: myItem.purposeID as Int, inTeamID: myObject.teamID as Int)
                    myDisplayBodyArray.append(myClass)
                }
            
            case "gvision":
                lblDetail.text = "My Visions"
                
                let myObject = inParentObject as! purposeAndCoreValue
                
                for myItem in myObject.vision
                {
                    myDisplayBodyArray.append(myItem)
                }
            
            case "goalAndObjective":
                lblDetail.text = "My Goal and Objectives"
            
                let myObject = inParentObject as! gvision
                for myItem in myObject.goals
                {
                    myDisplayBodyArray.append(myItem)
                }
            
            case "areaOfResponsibility":
                lblDetail.text = "My Area of Responsibilitys"
            
                let myObject = inParentObject as! goalAndObjective
                for myItem in myObject.areas
                {
                    myDisplayBodyArray.append(myItem)
                }
            
            case "project":
                lblDetail.text = "My Projects"
            
                let myObject = inParentObject as! areaOfResponsibility
                for myItem in myObject.projects
                {
                    myDisplayBodyArray.append(myItem)
                }
            
            case "task":
                lblDetail.text = "My Tasks"
            
                let myObject = inParentObject as! project
                for myItem in myObject.tasks
                {
                    myDisplayBodyArray.append(myItem)
                }
            
            case "context":
                lblDetail.text = "My Contexts"
            
                let myObject = inParentObject as! context
            NSLog("\(myObject.name)")
            
            default :
                print("buildBody: hit default")
        }

        /*
        let contentHeight = buildDisplayBody(myDisplayBodyArray, inWidth: 200, inHeight: 100, inSpacing: 40, inStartX: 0, inStartY: 0)
        
        // Set up the container view to hold your custom view hierarchy
        let containerSize2 = CGSizeMake(UIScreen.mainScreen().bounds.width, contentHeight)
        
        containerViewBody.frame = CGRect(origin: CGPointMake(0.0, 0.0), size:containerSize2)
        scrollDisplay.addSubview(containerViewBody)
        
        // Tell the scroll view the size of the contents
        scrollDisplay.contentSize = containerSize2
        
        // Set up the minimum & maximum zoom scale
        let scrollViewFrame2 = scrollDisplay.frame
        let scaleWidth2 = scrollViewFrame2.size.width / scrollDisplay.contentSize.width
        let scaleHeight2 = scrollViewFrame2.size.height / scrollDisplay.contentSize.height
        let minScale2 = min(scaleWidth2, scaleHeight2)
        
        scrollDisplay.minimumZoomScale = minScale2
        scrollDisplay.maximumZoomScale = 1.0
        scrollDisplay.zoomScale = 1.0
        
        centerScrollViewContentsBody()
*/
    }
    
/*    func centerScrollViewContentsBody()
    {
        let boundsSize = scrollDisplay.bounds.size
        var contentsFrame = containerViewBody.frame
        
        if contentsFrame.size.width < boundsSize.width
        {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        }
        else
        {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height
        {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        }
        else
        {
            contentsFrame.origin.y = 0.0
        }
        
        containerViewBody.frame = contentsFrame
    }*/
    
    func centerScrollViewContentsHead()
    {
        let boundsSize = scrollHead.bounds.size
        var contentsFrame = containerViewHead.frame
        
        if contentsFrame.size.width < boundsSize.width
        {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        }
        else
        {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height
        {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        }
        else
        {
            contentsFrame.origin.y = 0.0
        }
        
        containerViewHead.frame = contentsFrame
    }

    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return containerViewHead
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView)
    {
        centerScrollViewContentsHead()
      //  centerScrollViewContentsBody()
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
    
    func handleSingleTap(sender: textViewTapGestureRecognizer)
    {
        //Code in here fort zoom
        if sender.headBody == "head"
        {
            switch sender.type
            {
                case "team":
                    let myObject = sender.targetObject as! team
                    highlightID = myObject.teamID as Int
                    buildHead("team", inHighlightedID: highlightID)
                    buildBody("purposeAndCoreValue", inParentObject: sender.targetObject)
                
                case "purposeAndCoreValue":
                    let myObject = sender.targetObject as! purposeAndCoreValue
                    highlightID = myObject.purposeID as Int
                    buildHead("purposeAndCoreValue", inHighlightedID: highlightID)
                    buildBody("gvision", inParentObject: sender.targetObject)

                case "gvision":
                    let myObject = sender.targetObject as! gvision
                    highlightID = myObject.visionID as Int
                    buildHead("gvision", inHighlightedID: highlightID)
                    buildBody("goalAndObjective", inParentObject: sender.targetObject)

                case "goalAndObjective":
                    let myObject = sender.targetObject as! goalAndObjective
                    highlightID = myObject.goalID as Int
                    buildHead("goalAndObjective", inHighlightedID: highlightID)
                    buildBody("areaOfResponsibility", inParentObject: sender.targetObject)

                case "areaOfResponsibility":
                    let myObject = sender.targetObject as! areaOfResponsibility
                    highlightID = myObject.areaID as Int
                    buildHead("areaOfResponsibility", inHighlightedID: highlightID)
                    buildBody("project", inParentObject: sender.targetObject)
                
                case "project":
                    let myObject = sender.targetObject as! project
                    highlightID = myObject.projectID as Int
                    buildHead("project", inHighlightedID: highlightID)
                    buildBody("task", inParentObject: sender.targetObject)

                
                case "task":
                    let myObject = sender.targetObject as! task
                    highlightID = myObject.taskID as Int
                    buildHead("task", inHighlightedID: highlightID)
                    //buildBody("project", inParentObject: sender.targetObject)

                
                case "context":
                    let myObject = sender.targetObject as! context
                    highlightID = myObject.contextID as Int
                    buildHead("context", inHighlightedID: highlightID)
                //buildBody("project", inParentObject: sender.targetObject)

            
                default:
                    print("handleSingleTap: hit default")
            }
        }
        else
        { // Body
            switch sender.type
            {
                case "purposeAndCoreValue":
                    myDisplayHeadArray = myDisplayBodyArray
                    let myObject = sender.targetObject as! purposeAndCoreValue
                    highlightID = myObject.purposeID as Int
                    buildHead("purposeAndCoreValue", inHighlightedID: highlightID)
                
                    buildBody("gvision",inParentObject: myObject)
                    lblDetail.text = "My Visions"
                
                case "gvision":
                    myDisplayHeadArray = myDisplayBodyArray
                    let myObject = sender.targetObject as! gvision
                    highlightID = myObject.visionID as Int
                    buildHead("gvision", inHighlightedID: highlightID)

                    buildBody("goalAndObjective",inParentObject: myObject)
                    lblDetail.text = "My Goal and Objectives"
                
                case "goalAndObjective":
                    myDisplayHeadArray = myDisplayBodyArray
                    let myObject = sender.targetObject as! goalAndObjective
                    highlightID = myObject.goalID as Int
                    buildHead("goalAndObjective", inHighlightedID: highlightID)

                    buildBody("areaOfResponsibility",inParentObject: myObject)
                    lblDetail.text = "My Area of Responsibilitys"
                
                case "areaOfResponsibility":
                    myDisplayHeadArray = myDisplayBodyArray
                    let myObject = sender.targetObject as! areaOfResponsibility
                    highlightID = myObject.areaID as Int
                    buildHead("areaOfResponsibility", inHighlightedID: highlightID)

                    buildBody("project",inParentObject: myObject)
                    lblDetail.text = "My Projects"
                
                case "project":
                    myDisplayHeadArray = myDisplayBodyArray
                    let myObject = sender.targetObject as! project
                    highlightID = myObject.projectID as Int
                    buildHead("project", inHighlightedID: highlightID)
                
                    buildBody("task",inParentObject: myObject)
                    lblDetail.text = "My Tasks"

                case "task":
                    myDisplayHeadArray = myDisplayBodyArray
                    let myObject = sender.targetObject as! task
                    highlightID = myObject.taskID as Int
                    buildHead("task", inHighlightedID: highlightID)
                
             //   buildBody("task",inParentObject: myObject)
              //  lblDetail.text = "My Projects"

                case "context":
                    myDisplayHeadArray = myDisplayBodyArray
                    let myObject = sender.targetObject as! context
                    highlightID = myObject.contextID as Int
                    buildHead("context", inHighlightedID: highlightID)
                
                 //   buildBody("task",inParentObject: myObject)
                 //   lblDetail.text = "My Tasks"

                
                default:
                    print("handleSingleTap: hit default")
            }
        }
    }
    
    func handleLongPress(sender:textLongPressGestureRecognizer)
    {
        var myHeader: String = ""
        var myMessage: String = ""
        var myDeleteMessage: String = ""
        
        if sender.state == .Ended
        {
            switch sender.type
            {
                case "team" :
                    myHeader = "Team Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Purpose/Core Value"
                    }
                    else
                    {
                        myMessage = "Edit Team"
                    }
                    myDeleteMessage = "Delete Team"
                
                case "purposeAndCoreValue" :
                    myHeader = "Purpose/Core Value Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Vision"
                    }
                    else
                    {
                        myMessage = "Edit Purpose/Core Value"
                    }
                    myDeleteMessage = "Delete Purpose/Core Value"
                
                case "gvision" :
                    myHeader = "Vision Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Goal and Objective"
                    }
                    else
                    {
                        myMessage = "Edit Vision"
                    }
                    myDeleteMessage = "Delete Vision"
                
                case "goalAndObjective" :
                    myHeader = "Goal and Objective Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Area of Responsibility"
                    }
                    else
                    {
                        myMessage = "Edit Goal and Objective"
                    }
                    myDeleteMessage = "Delete Goal and Objective"
                
                case "areaOfResponsibility" :
                    myHeader = "Area of Responsibility Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Project"
                    }
                    else
                    {
                        myMessage = "Edit Area of Responsibility"
                    }
                    myDeleteMessage = "Delete Area of Responsibility"
                
                case "project" :
                    myHeader = "Project Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Task"
                    }
                    else
                    {
                        myMessage = "Edit Project"
                    }
                    myDeleteMessage = "Delete Project"
                
                case "task" :
                    myHeader = "Task Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Task"
                    }
                    else
                    {
                        myMessage = "Edit Task"
                    }
                    myDeleteMessage = "Delete Task"
                
                case "context" :
                    myHeader = "Context Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Sub-Context"
                    }
                    else
                    {
                        myMessage = "Edit Context"
                    }
                    myDeleteMessage = "Delete Context"
                
                default :
                    print("Handle long press hit default")
            }

            let myOptions: UIAlertController = UIAlertController(title: myHeader, message: "Select action to take", preferredStyle: .ActionSheet)

            if sender.type == "team" && sender.headBody == "head"
            {
                let myOption1 = UIAlertAction(title: myMessage, style: .Default, handler: { (action: UIAlertAction) -> () in
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("GTDEditController") as! GTDEditViewController
                    popoverContent.modalPresentationStyle = .Popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = sender.displayView
                    
                    if sender.headBody == "head"
                    {
                        let parentObject = sender.targetObject as! team
                        popoverContent.inPurposeObject = purposeAndCoreValue(inTeamID: parentObject.teamID as Int)
                        popoverContent.objectType = "purpose"
                        
                    }
                    else
                    {
  //                      popoverContent.workingObject = sender.targetObject
                    }
                    popoverContent.preferredContentSize = CGSizeMake(500,400)
                    self.presentViewController(popoverContent, animated: true, completion: nil)
                })
                
                let myOption2 = UIAlertAction(title: "Edit Team", style: .Default, handler: { (action: UIAlertAction) -> () in
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("TeamMaintenance") as! teamMaintenanceViewController
                    popoverContent.modalPresentationStyle = .Popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = sender.displayView
                    
                    if sender.headBody == "head"
                    {
                        let parentObject = sender.targetObject as! team
                        popoverContent.myWorkingTeam = parentObject
                    }
                    else
                    {
                        //                      popoverContent.workingObject = sender.targetObject
                    }
                    popoverContent.preferredContentSize = CGSizeMake(800,700)
                    self.presentViewController(popoverContent, animated: true, completion: nil)
                })

                let myOption3 = UIAlertAction(title: "Maintain Team Settings", style: .Default, handler: { (action: UIAlertAction) -> () in
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MaintainTeamDecodes") as! teamDecodesViewController
                    popoverContent.modalPresentationStyle = .Popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = sender.displayView
                    
                    if sender.headBody == "head"
                    {
                        let parentObject = sender.targetObject as! team
                        popoverContent.myWorkingTeam = parentObject
                    }
                    else
                    {
                        //                      popoverContent.workingObject = sender.targetObject
                    }
                    popoverContent.preferredContentSize = CGSizeMake(600,400)
                    self.presentViewController(popoverContent, animated: true, completion: nil)
                })
                
                let myOption4 = UIAlertAction(title: "New Team", style: .Default, handler: { (action: UIAlertAction) -> () in
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("TeamMaintenance") as! teamMaintenanceViewController
                    popoverContent.modalPresentationStyle = .Popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = sender.displayView
                    
                    if sender.headBody == "head"
                    {
                        let parentObject = team()
                        popoverContent.myWorkingTeam = parentObject
                    }
                    else
                    {
                        //                      popoverContent.workingObject = sender.targetObject
                    }
                    popoverContent.preferredContentSize = CGSizeMake(800,700)
                    self.presentViewController(popoverContent, animated: true, completion: nil)
                })

                myOptions.addAction(myOption1)
                myOptions.addAction(myOption2)
                myOptions.addAction(myOption3)
                myOptions.addAction(myOption4)

            }
            else if sender.type == "areaOfResponsibility" && sender.headBody == "head"
            {  // put in code here to add a new project
             //   popoverContent.workingObject = project()
                
                let myOption1 = UIAlertAction(title: myMessage, style: .Default, handler: { (action: UIAlertAction) -> () in
                let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MaintainProject") as! MaintainProjectViewController
                popoverContent.modalPresentationStyle = .Popover
                let popover = popoverContent.popoverPresentationController
                popover!.delegate = self
                popover!.sourceView = sender.displayView
                
                let parentObject = sender.targetObject as! areaOfResponsibility
                if sender.headBody == "head"
                {
                    let workingObject = project(inTeamID: parentObject.teamID as Int)
                    parentObject.addProject(workingObject)
                    popoverContent.inProjectObject = workingObject
                    popoverContent.myActionType = "Add"
                }

                popoverContent.preferredContentSize = CGSizeMake(700,700)
                self.presentViewController(popoverContent, animated: true, completion: nil)
                })
                
                myOptions.addAction(myOption1)
                
            }
            else if sender.type == "purposeAndCoreValue" || sender.type ==  "gvision" || sender.type ==  "goalAndObjective" || sender.type ==  "areaOfResponsibility"
            {
                let myOption1 = UIAlertAction(title: myMessage, style: .Default, handler: { (action: UIAlertAction) -> () in
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("GTDEditController") as! GTDEditViewController
                    popoverContent.modalPresentationStyle = .Popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = sender.displayView

                    switch sender.type
                    {
                        case "purposeAndCoreValue" :
                            let parentObject = sender.targetObject as! purposeAndCoreValue
                            if sender.headBody == "head"
                            {
                                let workingObject = gvision(inTeamID: parentObject.teamID as Int)
                                parentObject.addVision(workingObject)
                                popoverContent.inVisionObject = workingObject
                                popoverContent.objectType = "vision"
                            }
                            else
                            {
                                popoverContent.inPurposeObject = parentObject
                                popoverContent.objectType = "purpose"
                            }
                    
                        case "gvision" :
                            let parentObject = sender.targetObject as! gvision
                            if sender.headBody == "head"
                            {
                                let workingObject = goalAndObjective(inTeamID: parentObject.teamID as Int)
                                parentObject.addGoal(workingObject)
                                popoverContent.inGoalObject = workingObject
                                popoverContent.objectType = "goal"
                            }
                            else
                            {
                                popoverContent.inVisionObject = parentObject
                                popoverContent.objectType = "vision"
                            }
                    
                        case "goalAndObjective" :
                            let parentObject = sender.targetObject as! goalAndObjective
                            if sender.headBody == "head"
                            {
                                let workingObject = areaOfResponsibility(inTeamID: parentObject.teamID as Int)
                                parentObject.addArea(workingObject)
                                popoverContent.inAreaObject = workingObject
                                popoverContent.objectType = "area"
                            }
                            else
                            {
                                popoverContent.inGoalObject = parentObject
                                popoverContent.objectType = "goal"
                            }
                    
                        case "areaOfResponsibility" :
                            let parentObject = sender.targetObject as! areaOfResponsibility
                            if sender.headBody != "head"
                            {
                                popoverContent.inAreaObject = parentObject
                                popoverContent.objectType = "area"
                            }
            
                    default:
                        print("")
                    }

                    popoverContent.preferredContentSize = CGSizeMake(500,400)
                    self.presentViewController(popoverContent, animated: true, completion: nil)
                })

                let myOption2 = UIAlertAction(title: myDeleteMessage, style: .Default, handler: { (action: UIAlertAction) -> () in
                    switch sender.type
                    {
                        case "purposeAndCoreValue" :
                            let parentObject = sender.targetObject as! purposeAndCoreValue
                            if sender.headBody == "body"
                            {
                                if !parentObject.delete()
                                {
                                    let alert = UIAlertController(title: "Delete Purpose", message:
                                        "Unable to delete Purpose.  Check that there are not child records", preferredStyle: UIAlertControllerStyle.Alert)
                                    
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                                    self.presentViewController(alert, animated: false, completion: nil)
                                }
                            }
                        
                    case "gvision" :
                        let parentObject = sender.targetObject as! gvision
                        if sender.headBody == "body"
                        {
                            if !parentObject.delete()
                            {
                                let alert = UIAlertController(title: "Delete Vision", message:
                                    "Unable to delete Vision.  Check that there are not child records", preferredStyle: UIAlertControllerStyle.Alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                                self.presentViewController(alert, animated: false, completion: nil)
                            }
                        }
                        
                    case "goalAndObjective" :
                        let parentObject = sender.targetObject as! goalAndObjective
                        if sender.headBody == "body"
                        {
                            if !parentObject.delete()
                            {
                                let alert = UIAlertController(title: "Delete Goal", message:
                                    "Unable to delete Goal.  Check that there are not child records", preferredStyle: UIAlertControllerStyle.Alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                                self.presentViewController(alert, animated: false, completion: nil)
                            }
                        }
                        
                    case "areaOfResponsibility" :
                        let parentObject = sender.targetObject as! areaOfResponsibility
                        if sender.headBody == "body"
                        {
                            if !parentObject.delete()
                            {
                                let alert = UIAlertController(title: "Delete Area of Responsibility", message:
                                    "Unable to delete Area of Responsibility.  Check that there are not child records", preferredStyle: UIAlertControllerStyle.Alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                                self.presentViewController(alert, animated: false, completion: nil)
                            }
                        }
                        
                    default:
                        print("")
                    }
                    
                    self.refreshBody()
                })
                
                myOptions.addAction(myOption1)
                myOptions.addAction(myOption2)
            }
            else if sender.type == "project"
            {
                let myOption1 = UIAlertAction(title: myMessage, style: .Default, handler: { (action: UIAlertAction) -> () in
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("MaintainProject") as! MaintainProjectViewController
                    popoverContent.modalPresentationStyle = .Popover
                    let popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = sender.displayView
                    
                    let parentObject = sender.targetObject as! project
                    if sender.headBody == "body"
                    {
                        popoverContent.inProjectObject = parentObject
                        popoverContent.myActionType = "Edit"
                    }
                    
                    popoverContent.preferredContentSize = CGSizeMake(700,700)
                    popover!.sourceRect = CGRectMake(100,100,0,0)
                    self.presentViewController(popoverContent, animated: true, completion: nil)
                })
                
                myOptions.addAction(myOption1)

            }
            else
            {  // Selected in body
                // code
            }
            
            myOptions.popoverPresentationController?.sourceView = sender.displayView
            
            self.presentViewController(myOptions, animated: true, completion: nil)
        }
    }
    
 //not tested for dragging around screen
//    func detectPan(sender:UIPanGestureRecognizer) {
 //       self.view.bringSubviewToFront(sender.view!)
 //       var translation = sender.translationInView(self.view)
//        sender.view!.center = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y + translation.y)
//        sender.setTranslation(CGPointZero, inView: self.view)
///}
    
    func refreshBody()
    {
        switch myParentType
        {
        case "team":
            let myObject = myParentObject as! team
            buildBody("purposeAndCoreValue", inParentObject: myObject)
            
        case "purposeAndCoreValue":
            let myObject = myParentObject as! purposeAndCoreValue
            myObject.loadVision()
            buildBody("gvision", inParentObject: myObject)
            
        case "gvision":
            let myObject = myParentObject as! gvision
            myObject.loadGoals()
            buildBody("goalAndObjective", inParentObject: myObject)
            
        case "goalAndObjective":
            let myObject = myParentObject as! goalAndObjective
            myObject.loadAreas()
            buildBody("areaOfResponsibility", inParentObject: myObject)
            
        case "areaOfResponsibility":
            let myObject = myParentObject as! areaOfResponsibility
            myObject.loadProjects()
            buildBody("project", inParentObject: myObject)
            
        default:
            print("popoverPresentationControllerDidDismissPopover: hit default")
        }
    }
    
    private func displayEntry(inString: String, xPos: CGFloat, yPos: CGFloat, rectWidth: CGFloat, rectHeight: CGFloat, inRowID: Int, inTargetObject: AnyObject, inView: UIView, inHeadBody: String, inChildRecords: Int, inHighlightObject: Bool = false)
    {
     //   var myView: UIView = UIView()
        
        let txtView: UITextView = UITextView(frame: CGRect(x: xPos, y: yPos, width: rectWidth, height: rectHeight))
        
        txtView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        txtView.text = inString
        txtView.layer.borderColor = UIColor.blackColor().CGColor
        txtView.layer.borderWidth = 0.5
        
        txtView.layer.cornerRadius = 5.0
        txtView.clipsToBounds = true
        
        txtView.textAlignment = NSTextAlignment.Center
        txtView.tag = inRowID
        txtView.editable = false
        txtView.selectable = false
        if inHighlightObject
        {
            txtView.backgroundColor = myRowColour
        }
        
        let singleTap: textViewTapGestureRecognizer = textViewTapGestureRecognizer(target: self, action: "handleSingleTap:")
        singleTap.numberOfTapsRequired = 1
        singleTap.tag = inRowID
        singleTap.targetObject = inTargetObject
 //       singleTap.displayView = myView
        singleTap.displayView = txtView
        singleTap.headBody = inHeadBody
        
  //      myView.addGestureRecognizer(singleTap)
        txtView.addGestureRecognizer(singleTap)
        
        let lpgr = textLongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.tag = inRowID
        lpgr.targetObject = inTargetObject
        lpgr.displayView = txtView
 //       lpgr.displayView = myView

        lpgr.headBody = inHeadBody
        
        txtView.addGestureRecognizer(lpgr)
   //      myView.addGestureRecognizer(lpgr)
        
        // not tested, need to have the stuff loaded first
  //      var panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
  //      txtView.addGestureRecognizer(panRecognizer)
        
        
        
     //   myView.addSubview(txtView)
    //
     //   inView.addSubview(myView)

        inView.addSubview(txtView)
        
        if inChildRecords > 0
        {
            let txtfield: UILabel = UILabel(frame: CGRect(x: xPos, y: yPos + rectHeight, width: rectWidth, height: 30))
        
            txtfield.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
            txtfield.text = " \(inChildRecords) child records"
     //   txtfield.layer.borderColor = UIColor.blackColor().CGColor
     //   txtfield.layer.borderWidth = 0.5
        
     //   txtfield.layer.cornerRadius = 5.0
     //   txtfield.clipsToBounds = true
        
            txtfield.textAlignment = NSTextAlignment.Left
    //    txtfield.editable = false
     //   txtfield.selectable = false
        
            inView.addSubview(txtfield)
        }
        
    }
    
    func buildDisplayHead(inDisplayArray: [AnyObject], inWidth: CGFloat, inHeight: CGFloat, inSpacing: CGFloat, inStartX: CGFloat, inStartY: CGFloat, inHighlightID: Int) -> CGFloat
    {
        var myX: CGFloat = inStartX
        let myY: CGFloat = inStartY
        var myRowID: Int = 0
        var boolHighlight: Bool = false
        var displayString: String = ""
        var myChildRecords: Int = 0
        
        // Work out the position of the first box.  This is calulated using screen width and the number of entries

        for view in containerViewHead.subviews
        {
            view.removeFromSuperview()
        }
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let midpoint = screenSize.width / 2
        let halfWidth = inWidth / 2
        let halfSpace = inSpacing / 2
        let displayMultiplier: CGFloat = CGFloat(inDisplayArray.count - 1)
        
        if inDisplayArray.count == 1
        {
            myX = midpoint - halfWidth
        }
        else
        {
            if CGFloat(inDisplayArray.count) * (inWidth + inSpacing) < screenSize.width
            {  // number of items fits on the screen Ok
                myX = midpoint - halfWidth - (displayMultiplier * (halfWidth + halfSpace))
            }
            else
            {  // Number of items will exceed screen space
                // what is max items we can display
                
                let myMaxItemsPerRow = screenSize.width / (inWidth + inSpacing)
                
                let maxInt = Int(myMaxItemsPerRow)
                
                myX = midpoint - halfWidth - (CGFloat(maxInt - 1) * (halfWidth + halfSpace))
            }
        }
        
        for myItem in inDisplayArray
        {
            displayString = ""
            boolHighlight = false
            
            if myItem.isKindOfClass(team)
            {
                let tempObject = myItem as! team
                
                if tempObject.teamID == inHighlightID
                {
                    boolHighlight = true
                    myParentObject = tempObject
                    myParentType = "team"
                }
                
                displayString = tempObject.name
                myChildRecords = 0
            }
            else if myItem.isKindOfClass(purposeAndCoreValue)
            {
                let tempObject = myItem as! purposeAndCoreValue
                if tempObject.purposeID == inHighlightID
                {
                    boolHighlight = true
                    myParentObject = tempObject
                    myParentType = "purposeAndCoreValue"
                }
                
                displayString = tempObject.title
                myChildRecords = tempObject.vision.count
            }
            else if myItem.isKindOfClass(gvision)
            {
                let tempObject = myItem as! gvision
                if tempObject.visionID == inHighlightID
                {
                    boolHighlight = true
                    myParentObject = tempObject
                    myParentType = "gvision"
                }
                
                displayString = tempObject.title
                myChildRecords = tempObject.goals.count
            }
            else if myItem.isKindOfClass(goalAndObjective)
            {
                let tempObject = myItem as! goalAndObjective
                if tempObject.goalID == inHighlightID
                {
                    boolHighlight = true
                    myParentObject = tempObject
                    myParentType = "goalAndObjective"
                }
                
                displayString = tempObject.title
                myChildRecords = tempObject.areas.count
            }
            else if myItem.isKindOfClass(areaOfResponsibility)
            {
                let tempObject = myItem as! areaOfResponsibility
                if tempObject.areaID == inHighlightID
                {
                    boolHighlight = true
                    myParentObject = tempObject
                    myParentType = "areaOfResponsibility"
                }
                
                displayString = tempObject.title
                myChildRecords = tempObject.projects.count
            }
            else if myItem.isKindOfClass(project)
            {
                let tempObject = myItem as! project
                if tempObject.projectID == inHighlightID
                {
                    boolHighlight = true
                    myParentObject = tempObject
                    myParentType = "project"
                }
                
                displayString = tempObject.projectName
                myChildRecords = tempObject.tasks.count
            }
            else if myItem.isKindOfClass(task)
            {
                let tempObject = myItem as! task
                if tempObject.taskID == inHighlightID
                {
                    boolHighlight = true
                    myParentObject = tempObject
                    myParentType = "task"
                }
                
                displayString = tempObject.title
                myChildRecords = 0
            }
            else if myItem.isKindOfClass(context)
            {
                let tempObject = myItem as! context
                if tempObject.contextID == inHighlightID
                {
                    boolHighlight = true
                    myParentObject = tempObject
                    myParentType = "context"
                }
                
                displayString = tempObject.name
                myChildRecords = 0
            }
            else if myItem is String
            {
                displayString = myItem as! String
                myChildRecords = 0
            }
            
            displayEntry(displayString, xPos: myX, yPos: myY, rectWidth: inWidth, rectHeight: inHeight, inRowID: myRowID, inTargetObject: myItem, inView: containerViewHead, inHeadBody: "head", inChildRecords: myChildRecords, inHighlightObject: boolHighlight)
            
            myRowID++
            

            myX += inWidth + inSpacing
        }
        
        return myX
    }
    
    func buildDisplayBody(inDisplayArray: [AnyObject], inWidth: CGFloat, inHeight: CGFloat, inSpacing: CGFloat, inStartX: CGFloat, inStartY: CGFloat) -> CGFloat
    {
        var myX: CGFloat = inStartX
        var myY: CGFloat = inStartY
        var myRowID: Int = 0
        var displayString: String = ""
        var myChildRecords: Int = 0
        
        // Work out the position of the first box.  This is calulated using screen width and the number of entries
        
        //        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
 //       for view in containerViewBody.subviews
 //       {
 //           view.removeFromSuperview()
 //       }
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let midpoint = screenSize.width / 2
        let halfWidth = inWidth / 2
        let halfSpace = inSpacing / 2
        let displayMultiplier: CGFloat = CGFloat(inDisplayArray.count - 1)
        
        if inDisplayArray.count == 1
        {
            myX = midpoint - halfWidth
        }
        else
        {
            if CGFloat(inDisplayArray.count) * (inWidth + inSpacing) < screenSize.width
            {  // number of items fits on the screen Ok
                myX = midpoint - halfWidth - (displayMultiplier * (halfWidth + halfSpace))
            }
            else
            {  // Number of items will exceed screen space
                // what is max items we can display
                
                let myMaxItemsPerRow = screenSize.width / (inWidth + inSpacing)
                
                let maxInt = Int(myMaxItemsPerRow)
                
                myX = midpoint - halfWidth - (CGFloat(maxInt - 1) * (halfWidth + halfSpace))
            }
        }
        
        let myStartingX = myX
        
        for myItem in inDisplayArray
        {
            displayString = ""
            if myItem.isKindOfClass(team)
            {
                displayString = myItem.name

            }
            else if myItem.isKindOfClass(purposeAndCoreValue)
            {
                let tempObject = myItem as! purposeAndCoreValue
                
                displayString = tempObject.title
                myChildRecords = tempObject.vision.count
            }
            else if myItem.isKindOfClass(gvision)
            {
                let tempObject = myItem as! gvision
                displayString = tempObject.title
                myChildRecords = tempObject.goals.count
            }
            else if myItem.isKindOfClass(goalAndObjective)
            {
                let tempObject = myItem as! goalAndObjective
                displayString = tempObject.title
                myChildRecords = tempObject.areas.count
            }
            else if myItem.isKindOfClass(areaOfResponsibility)
            {
                let tempObject = myItem as! areaOfResponsibility
                displayString = tempObject.title
                myChildRecords = tempObject.projects.count
            }
            else if myItem.isKindOfClass(project)
            {
                let tempObject = myItem as! project
                displayString = tempObject.projectName
                myChildRecords = tempObject.tasks.count
            }
            else if myItem.isKindOfClass(task)
            {
                let tempObject = myItem as! task
                displayString = tempObject.title
                myChildRecords = 0
            }
            else if myItem.isKindOfClass(context)
            {
                let tempObject = myItem as! context
                displayString = tempObject.name
                myChildRecords = 0
            }
            else if myItem is String
            {
                displayString = myItem as! String
                myChildRecords = 0
            }
            
   //         displayEntry(displayString, xPos: myX, yPos: myY, rectWidth: inWidth, rectHeight: inHeight, inRowID: myRowID, inTargetObject: myItem, inView: containerViewBody, inHeadBody: "body", inChildRecords: myChildRecords)
            myRowID++
            
            if myX + (inWidth * 2) + inSpacing > screenSize.width  // Doing inwidth * 2 + space because myX is start position, so need to make sure can have both boxes and space
            {
                myX = myStartingX
                myY += inHeight + inSpacing + 30
            }
            else
            {
                myX += inWidth + inSpacing
            }
        }
        
        return myY + inHeight
    }
}

class KDRearrangeableGTDDisplayHierarchy: UICollectionViewCell
{
    
    @IBOutlet weak var lblChildren: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
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