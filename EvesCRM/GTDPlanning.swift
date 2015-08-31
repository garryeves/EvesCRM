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

class MaintainGTDPlanningViewController: UIViewController,  UIScrollViewDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate
{
    
    @IBInspectable var popoverOniPhone:Bool = false
    @IBInspectable var popoverOniPhoneLandscape:Bool = true
    
    private var passedGTD: GTDModel!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var scrollDisplay: UIScrollView!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var scrollHead: UIScrollView!
    
    private var containerViewHead: UIView!
    private var containerViewBody: UIView!

    private var myDisplayArray: [AnyObject] = Array()
    private var myDisplayBodyArray: [AnyObject] = Array()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        passedGTD = (tabBarController as! GTDPlanningTabViewController).myPassedGTD
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
        if passedGTD.actionSource == "Project"
        {
            buildTopLevel()
        }
        else if passedGTD.actionSource == "Context"
        {
println("Put in initial context code here")
        }
        else
        {
            println("No action sent")
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()

        let contentWidth = buildDisplayHead(myDisplayArray, inWidth: 200, inHeight: 100, inSpacing: 40, inStartX: 0, inStartY: 0)
        
        // Set up the container view to hold your custom view hierarchy
        let containerSize = CGSizeMake(contentWidth, 120)
        
        containerViewHead.frame = CGRect(origin: CGPointMake(0.0, 0.0), size:containerSize)
        
        let contentHeight = buildDisplayBody(myDisplayBodyArray, inWidth: 200, inHeight: 100, inSpacing: 40, inStartX: 0, inStartY: 0)
        
        // Set up the container view to hold your custom view hierarchy
        let containerSize2 = CGSizeMake(UIScreen.mainScreen().bounds.width, contentHeight)
        
        containerViewBody.frame = CGRect(origin: CGPointMake(0.0, 0.0), size:containerSize2)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
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
    
    func buildTopLevel()
    {
        lblHeader.text = "My Teams"
        lblDetail.text = "Purpose & Core Values"
        
        myDisplayArray.removeAll()
        let myTeams = myDatabaseConnection.getAllTeams()
        
        for myTeamID in myTeams
        {
            let myTeam = team(inTeamID: myTeamID.teamID as Int)
            myDisplayArray.append(myTeam)
        }

        // Populate Head
        
        containerViewHead = UIView()
        
        var contentWidth = buildDisplayHead(myDisplayArray, inWidth: 200, inHeight: 100, inSpacing: 40, inStartX: 0, inStartY: 0)

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
        
        // Setup up child records
        
        
        myDisplayBodyArray.removeAll()
        let myPurposes = myDatabaseConnection.getAllPurpose(1)
        
        for myPurposeItem in myPurposes
        {
            let myPurpose = purposeAndCoreValue(inPurposeID: myPurposeItem.purposeID as Int)
            myDisplayBodyArray.append(myPurpose)
        }
    
        containerViewBody = UIView()
        
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
    }
    
    func centerScrollViewContentsBody()
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
    }
    
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
        centerScrollViewContentsBody()
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
        //do som stuff from the popover
println("popoverPresentationControllerDidDismissPopover")
    }
    
    func handleSingleTap(sender: textViewTapGestureRecognizer)
    {
        //Code in here fort zoom
    }
    
    func handleLongPress(sender:textLongPressGestureRecognizer)
    {
        var myHeader: String = ""
        var myMessage: String = ""
        
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
                
                case "project" :
                    myHeader = "Project Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Task"
           //             workingObject = task()
                    }
                    else
                    {
                        myMessage = "Edit Project"
              //          workingObject = sender.targetObject
                    }
                
                case "task" :
                    myHeader = "Task Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Task"
           //             workingObject = task()
                    }
                    else
                    {
                        myMessage = "Edit Task"
            //            workingObject = sender.targetObject
                    }
                
                case "context" :
                    myHeader = "Context Options"
                    
                    if sender.headBody == "head"
                    {
                        myMessage = "Add Sub-Context"
        //                workingObject = context()
                    }
                    else
                    {
                        myMessage = "Edit Context"
          //              workingObject = sender.targetObject
                    }
                
                default :
                    println("Handle long press hit default")
            }

            let myOptions: UIAlertController = UIAlertController(title: myHeader, message: "Select action to take", preferredStyle: .ActionSheet)

            if sender.type == "team" && sender.headBody == "head"
            {
                let myOption1 = UIAlertAction(title: myMessage, style: .Default, handler: { (action: UIAlertAction!) -> () in
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("GTDEditController") as! GTDEditViewController
                    popoverContent.modalPresentationStyle = .Popover
                    var popover = popoverContent.popoverPresentationController
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
                
                myOptions.addAction(myOption1)
            }
            else if sender.type == "areaOfResponsibility" && sender.headBody == "head"
            {  // put in code here to add a new project
             //   popoverContent.workingObject = project()
                /*
                let myOption1 = UIAlertAction(title: myMessage, style: .Default, handler: { (action: UIAlertAction!) -> () in
                let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("GTDEditController") as! GTDEditViewController
                popoverContent.modalPresentationStyle = .Popover
                var popover = popoverContent.popoverPresentationController
                popover!.delegate = self
                popover!.sourceView = sender.displayView
                if sender.headBody == "head"
                {
                popoverContent.workingObject = purposeAndCoreValue()
                }
                else
                {
                popoverContent.workingObject = sender.targetObject
                }
                popoverContent.preferredContentSize = CGSizeMake(500,400)
                self.presentViewController(popoverContent, animated: true, completion: nil)
                })
                
                myOptions.addAction(myOption1)
                */
            }
            else if sender.type == "purposeAndCoreValue" || sender.type ==  "gvision" || sender.type ==  "goalAndObjective" || sender.type ==  "areaOfResponsibility"
            {
                let myOption1 = UIAlertAction(title: myMessage, style: .Default, handler: { (action: UIAlertAction!) -> () in
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("GTDEditController") as! GTDEditViewController
                    popoverContent.modalPresentationStyle = .Popover
                    var popover = popoverContent.popoverPresentationController
                    popover!.delegate = self
                    popover!.sourceView = sender.displayView

                    switch sender.type
                    {
                        case "purposeAndCoreValue" :
                            if sender.headBody == "head"
                            {
                                let parentObject = sender.targetObject as! purposeAndCoreValue
                                let workingObject = gvision(inTeamID: parentObject.teamID as Int)
                                parentObject.addVision(workingObject.visionID)
                                popoverContent.inVisionObject = workingObject
                                popoverContent.objectType = "vision"
                            }
                            else
                            {
                                popoverContent.inPurposeObject = sender.targetObject as! purposeAndCoreValue
                                popoverContent.objectType = "purpose"
                            }
                    
                        case "gvision" :
                            if sender.headBody == "head"
                            {
                                let parentObject = sender.targetObject as! gvision
                                let workingObject = goalAndObjective(inTeamID: parentObject.teamID as Int)
                                parentObject.addGoal(workingObject.goalID)
                                popoverContent.inGoalObject = workingObject
                                popoverContent.objectType = "goal"
                            }
                            else
                            {
                                popoverContent.inVisionObject = sender.targetObject as! gvision
                                popoverContent.objectType = "vision"
                            }
                    
                        case "goalAndObjective" :
                            if sender.headBody == "head"
                            {
                                let parentObject = sender.targetObject as! goalAndObjective
                                let workingObject = areaOfResponsibility(inTeamID: parentObject.teamID as Int)
                                parentObject.addArea(workingObject.areaID)
                                popoverContent.inAreaObject = workingObject
                                popoverContent.objectType = "area"
                            }
                            else
                            {
                                popoverContent.inGoalObject = sender.targetObject as! goalAndObjective
                                popoverContent.objectType = "goal"
                            }
                    
                        case "areaOfResponsibility" :
                            if sender.headBody != "head"
                            {
                                popoverContent.inAreaObject = sender.targetObject as! areaOfResponsibility
                                popoverContent.objectType = "area"
                            }
            
                    default:
                        println("")
                    }

                    popoverContent.preferredContentSize = CGSizeMake(500,400)
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
    
    
    
    private func displayEntry(inString: String, xPos: CGFloat, yPos: CGFloat, rectWidth: CGFloat, rectHeight: CGFloat, inRowID: Int, inTargetObject: AnyObject, inView: UIView, inHeadBody: String) -> UITextView
    {
        var txtView: UITextView = UITextView(frame: CGRect(x: xPos, y: yPos, width: rectWidth, height: rectHeight))
        
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
        
        var singleTap: textViewTapGestureRecognizer = textViewTapGestureRecognizer(target: self, action: "handleSingleTap:")
        singleTap.numberOfTapsRequired = 1
        singleTap.tag = inRowID
        singleTap.targetObject = inTargetObject
        singleTap.displayView = txtView
        singleTap.headBody = inHeadBody
        
        txtView.addGestureRecognizer(singleTap)
        
        var lpgr = textLongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.tag = inRowID
        lpgr.targetObject = inTargetObject
        lpgr.displayView = txtView
        lpgr.headBody = inHeadBody
        
        txtView.addGestureRecognizer(lpgr)
        
        // not tested, need to have the stuff loaded first
  //      var panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
  //      txtView.addGestureRecognizer(panRecognizer)
        
        inView.addSubview(txtView)
        
        return txtView
    }
    
    func buildDisplayHead(inDisplayArray: [AnyObject], inWidth: CGFloat, inHeight: CGFloat, inSpacing: CGFloat, inStartX: CGFloat, inStartY: CGFloat) -> CGFloat
    {
        var myX: CGFloat = inStartX
        var myY: CGFloat = inStartY
        var myRowID: Int = 0
        var tempTextView: UITextView!
        
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
        
        let myStartingX = myX
        
        for myItem in inDisplayArray
        {
            if myItem.isKindOfClass(team)
            {
                tempTextView = displayEntry(myItem.name, xPos: myX, yPos: myY, rectWidth: inWidth, rectHeight: inHeight, inRowID: myRowID, inTargetObject: myItem, inView: containerViewHead, inHeadBody: "head")
            }
            else if myItem is String
            {
                tempTextView = displayEntry(myItem as! String, xPos: myX, yPos: myY, rectWidth: inWidth, rectHeight: inHeight, inRowID: myRowID, inTargetObject: myItem, inView: containerViewHead, inHeadBody: "head")
            }
            
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
        var tempTextView: UITextView!
        
        // Work out the position of the first box.  This is calulated using screen width and the number of entries
        
        //        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        for view in containerViewBody.subviews
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
        
        let myStartingX = myX
        
        for myItem in inDisplayArray
        {
            if myItem.isKindOfClass(team)
            {
                tempTextView = displayEntry(myItem.name, xPos: myX, yPos: myY, rectWidth: inWidth, rectHeight: inHeight, inRowID: myRowID, inTargetObject: myItem, inView: containerViewBody, inHeadBody: "body")
            }
            else if myItem.isKindOfClass(purposeAndCoreValue)
            {
                let tempObject = myItem as! purposeAndCoreValue
                tempTextView = displayEntry(tempObject.title, xPos: myX, yPos: myY, rectWidth: inWidth, rectHeight: inHeight, inRowID: myRowID, inTargetObject: myItem, inView: containerViewBody, inHeadBody: "body")
            }
            else if myItem.isKindOfClass(gvision)
            {
                let tempObject = myItem as! gvision
                tempTextView = displayEntry(tempObject.title, xPos: myX, yPos: myY, rectWidth: inWidth, rectHeight: inHeight, inRowID: myRowID, inTargetObject: myItem, inView: containerViewBody, inHeadBody: "body")
            }
            else if myItem.isKindOfClass(goalAndObjective)
            {
                let tempObject = myItem as! goalAndObjective
                tempTextView = displayEntry(tempObject.title, xPos: myX, yPos: myY, rectWidth: inWidth, rectHeight: inHeight, inRowID: myRowID, inTargetObject: myItem, inView: containerViewBody, inHeadBody: "body")
            }
            else if myItem.isKindOfClass(areaOfResponsibility)
            {
                let tempObject = myItem as! areaOfResponsibility
                tempTextView = displayEntry(tempObject.title, xPos: myX, yPos: myY, rectWidth: inWidth, rectHeight: inHeight, inRowID: myRowID, inTargetObject: myItem, inView: containerViewBody, inHeadBody: "body")
            }                
            else if myItem is String
            {
                tempTextView = displayEntry(myItem as! String, xPos: myX, yPos: myY, rectWidth: inWidth, rectHeight: inHeight, inRowID: myRowID, inTargetObject: myItem, inView: containerViewBody, inHeadBody: "body")
            }
            
            myRowID++
            
            if myX + (inWidth * 2) + inSpacing > screenSize.width  // Doing inwidth * 2 + space because myX is start position, so need to make sure can have both boxes and space
            {
                myX = myStartingX
                myY += inHeight + inSpacing
            }
            else
            {
                myX += inWidth + inSpacing
            }
        }
        
        return myY + inHeight
    }
}