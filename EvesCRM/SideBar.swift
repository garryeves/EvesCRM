//
//  SideBar.swift
//  BlurrySideBar
//
//  Created by Training on 01/09/14.
//  Copyright (c) 2014 Training. All rights reserved.
//

#if os(iOS)
    import UIKit
    
    @objc protocol SideBarDelegate
    {
        func sideBarDidSelectButtonAtIndex(passedItem:menuObject)
        optional func sideBarWillClose()
        optional func sideBarWillOpen(target: UIView)
    }
#elseif os(OSX)
    import AppKit
#else
//    NSLog("Unexpected OS")
#endif


class SideBar: NSObject, SideBarTableViewControllerDelegate
{
    let barWidth:CGFloat = 300.0
    let sideBarTableViewTopInset:CGFloat = 64.0
    
    var fullArray: [menuEntry] = Array()
    var teamArray: [menuObject] = Array()
    var projectArray: [menuObject] = Array()
    var peopleArray: [menuObject] = Array()
    var placeArray: [menuObject] = Array()
    var toolArray: [menuObject] = Array()
    var optionArray: [menuObject] = Array()
    var headerArray: [menuObject] = Array()

    
    #if os(iOS)
        let sideBarContainerView:UIView = UIView()
        let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
        var originView:UIView!
   
        var animator:UIDynamicAnimator!
        var delegate:SideBarDelegate?
        var isSideBarOpen:Bool = false
        var blurView:UIVisualEffectView!
    
    #endif
   
    override init()
    {
        super.init()
    }

    #if os(iOS)
        init(sourceView:UIView)
        {
            super.init()
            originView = sourceView
        
 //       loadMenuItems()
        
            setupSideBar()
        
            animator = UIDynamicAnimator(referenceView: originView)
        
            let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
            showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
            originView.addGestureRecognizer(showGestureRecognizer)
        
            let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
            hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
            originView.addGestureRecognizer(hideGestureRecognizer)
        }
    #endif
    
    func loadMenuItems()
    {
        teamArray.removeAll()
        projectArray.removeAll()
        peopleArray.removeAll()
        placeArray.removeAll()
        toolArray.removeAll()
        optionArray.removeAll()
        headerArray.removeAll()

        fullArray.removeAll()
        
        let planningObject = createMenuItem("Planning", inType: "Header", inObject: "Projects")
        planningObject.section = "Header"
        
        headerArray.append(planningObject)

        let inboxObject = createMenuItem("Inbox", inType: "Header", inObject: "Inbox")
        inboxObject.section = "Header"
        
        headerArray.append(inboxObject)

        let doingObject = createMenuItem("Doing", inType: "Header", inObject: "Doing")
        doingObject.type = "disclosure"
        doingObject.section = "Header"
        doingObject.childSection = "Doing"

        headerArray.append(doingObject)
        
        for myTeamItem in myDatabaseConnection.getMyTeams(myID)
        {
            let myTeam = team(inTeamID: myTeamItem.teamID as Int)
            let teamObject = createMenuItem(myTeam.name, inType: "Disclosure", inObject: myTeam)
            teamObject.type = "disclosure"
            teamObject.section = doingObject.childSection
            teamObject.childSection = "Team \(myTeam.teamID)"
            
            let myProjects = myDatabaseConnection.getProjects(myTeam.teamID)
            for myProject in myProjects
            {
                // Get the number of items in the project
                
                let myReturnedData = myDatabaseConnection.getActiveTasksForProject(myProject.projectID as Int)
                
                let displayObject = createMenuItem("\(myProject.projectName) (\(myReturnedData.count))", inType: "Project", inObject: myProject)
                //displayObject.section = "\(myTeam.teamID)"
                displayObject.section = teamObject.childSection
                
                projectArray.append(displayObject)
            }
            let projectEntry = menuEntry(menuType: teamObject.childSection, menuEntries: projectArray)
            fullArray.append(projectEntry)
            teamArray.append(teamObject)
        }
        
        let teamEntry = menuEntry(menuType: doingObject.childSection, menuEntries: teamArray)
        fullArray.append(teamEntry)
        
        let myContextList = contexts()
        // Get list of People Contexts
        
        let peopleObject = createMenuItem("People", inType: "Header", inObject: "People")
        peopleObject.type = "disclosure"
        peopleObject.section = "Header"
        peopleObject.childSection = "People"

        headerArray.append(peopleObject)
        
        for myContext in myContextList.people
        {
            let myReturnedData = getContextCount(myContext.contextID)
            
            let displayObject = createMenuItem("\(myContext.contextHierarchy) (\(myReturnedData))", inType: "People", inObject: myContext)
            peopleObject.section = peopleObject.childSection

            peopleArray.append(displayObject)
        }

 //       let addressObject = createMenuItem("Address Book", inType: "People", inObject: "Address Book")
 //       addressObject.section = peopleObject.childSection

 //       peopleArray.append(addressObject)

        let contextMaintenceObject1 = createMenuItem("Maintain People", inType: "MaintainContexts", inObject: "Contexts")
        contextMaintenceObject1.section = peopleObject.childSection
        
        peopleArray.append(contextMaintenceObject1)
        
        let peopleEntry = menuEntry(menuType: peopleObject.childSection, menuEntries: peopleArray)
        fullArray.append(peopleEntry)
        // Get list of Non People Contexts
        
        let placeObject = createMenuItem("Places", inType: "Header", inObject: "Places")
        placeObject.type = "disclosure"
        placeObject.section = "Header"
        placeObject.childSection = "Place"

        headerArray.append(placeObject)
        
        for myContext in myContextList.places
        {
            let myReturnedData = getContextCount(myContext.contextID)

            let displayObject = createMenuItem("\(myContext.contextHierarchy) (\(myReturnedData))", inType: "Place", inObject: myContext)
            displayObject.section = placeObject.childSection

            placeArray.append(displayObject)
        }
        
        let contextMaintenceObject2 = createMenuItem("Maintain Places", inType: "MaintainContexts", inObject: "Contexts")
        contextMaintenceObject2.section = placeObject.childSection
        
        placeArray.append(contextMaintenceObject2)
        
        let placeEntry = menuEntry(menuType: placeObject.childSection, menuEntries: placeArray)
        fullArray.append(placeEntry)
        
        let toolObject = createMenuItem("Tools", inType: "Header", inObject: "Tools")
        toolObject.type = "disclosure"
        toolObject.section = "Header"
        toolObject.childSection = "Tool"
        
        for myContext in myContextList.tools
        {
            let myReturnedData = getContextCount(myContext.contextID)

            let displayObject = createMenuItem("\(myContext.contextHierarchy) (\(myReturnedData))", inType: "Tool", inObject: myContext)
            displayObject.section = toolObject.childSection
            
            toolArray.append(displayObject)
        }
        
        let contextMaintenceObject3 = createMenuItem("Maintain Tools", inType: "MaintainContexts", inObject: "Contexts")
        contextMaintenceObject3.section = toolObject.childSection
        
        toolArray.append(contextMaintenceObject3)
        
        headerArray.append(toolObject)

        let toolEntry = menuEntry(menuType: toolObject.childSection, menuEntries: toolArray)
        fullArray.append(toolEntry)
        
        let actionsObject = createMenuItem("Options", inType: "Header", inObject: "Options")
        actionsObject.type = "disclosure"
        actionsObject.section = "Header"
        actionsObject.childSection = "Options"

        headerArray.append(actionsObject)
        
        let displayPanesObject = createMenuItem("Maintain Display Panes", inType: "Action", inObject: "Maintain Display Panes")
        displayPanesObject.section = actionsObject.childSection

        optionArray.append(displayPanesObject)
       
        let textExpanderObject = createMenuItem("Load TextExpander Snippets", inType: "Action", inObject: "Load TextExpander Snippets")
        textExpanderObject.section = actionsObject.childSection

        optionArray.append(textExpanderObject)
        
        let settingObject = createMenuItem("Settings", inType: "Action", inObject: "Settings")
        settingObject.section = actionsObject.childSection

        optionArray.append(settingObject)
        
        let optionEntry = menuEntry(menuType: actionsObject.childSection, menuEntries: optionArray)
        fullArray.append(optionEntry)
        
        let headerEntry = menuEntry(menuType: "Header", menuEntries: headerArray)
        fullArray.append(headerEntry)
        
        #if os(iOS)
            sideBarTableViewController.fullArray = fullArray
            sideBarTableViewController.initialise()
            sideBarTableViewController.tableView.reloadData()
        #endif
    }
    
    func createMenuItem(inName: String, inType: String, inObject: NSObject) -> menuObject
    {
        let myNewObject = menuObject()
        myNewObject.displayString = inName
        myNewObject.displayType = inType
        myNewObject.displayObject = inObject
        
        return myNewObject
    }
    
    #if os(iOS)
        func setupSideBar()
        {
            sideBarContainerView.frame = CGRectMake(-barWidth - 1, originView.frame.origin.y, barWidth, originView.frame.size.height)
            sideBarContainerView.backgroundColor = UIColor.grayColor()
            sideBarContainerView.clipsToBounds = false
    
            originView.addSubview(sideBarContainerView)
        
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
            blurView.frame = sideBarContainerView.bounds
            sideBarContainerView.addSubview(blurView)

            sideBarTableViewController.delegate = self
            sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
            sideBarTableViewController.tableView.clipsToBounds = false
            sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            sideBarTableViewController.tableView.backgroundColor = UIColor.clearColor()
            sideBarTableViewController.tableView.scrollsToTop  = false
            sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        
            sideBarTableViewController.tableView.reloadData()
        
            sideBarContainerView.addSubview(sideBarTableViewController.tableView)
        }
    
        func handleSwipe(recognizer:UISwipeGestureRecognizer)
        {
            if recognizer.direction == UISwipeGestureRecognizerDirection.Left
            {
                showSideBar(false)
                delegate?.sideBarWillClose?()
            }
            else
            {
                loadMenuItems()
                showSideBar(true)
                delegate?.sideBarWillOpen?(sideBarContainerView)
            }
        }
    
        func showSideBar(shouldOpen:Bool)
        {
            animator.removeAllBehaviors()
            isSideBarOpen = shouldOpen
        
 //         let gravityX:CGFloat = (shouldOpen) ? 0.5 : -0.5
            let gravityX:CGFloat = (shouldOpen) ? 5.0 : -5.0
        
            let magnitude:CGFloat = (shouldOpen) ? 20 : -20
            //let magnitude:CGFloat = (shouldOpen) ? 1 : -1
        
            let boundaryX:CGFloat = (shouldOpen) ? barWidth : -barWidth - 1
        
            let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
            gravityBehavior.gravityDirection = CGVectorMake(gravityX, 0)
            animator.addBehavior(gravityBehavior)
        
            let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
            collisionBehavior.addBoundaryWithIdentifier("sideBarBoundary", fromPoint: CGPointMake(boundaryX, 20), toPoint: CGPointMake(boundaryX, originView.frame.size.height))
            animator.addBehavior(collisionBehavior)
        
            let pushBehavior:UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
            pushBehavior.magnitude = magnitude
            animator.addBehavior(pushBehavior)
        
            let sideBarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
            sideBarBehavior.elasticity = 0.0
            animator.addBehavior(sideBarBehavior)
        }
    
        func sideBarControlDidSelectRow(passedItem: menuObject)
        {
            delegate?.sideBarDidSelectButtonAtIndex(passedItem)
            showSideBar(false)
            delegate?.sideBarWillClose?()
        }
    
    #endif
    
    func getContextCount(contextID: Int) -> Int
    {
        var retVal: Int = 0
        
        // Get list of tasks for the context
        for myItem in myDatabaseConnection.getTasksForContext(contextID)
        {
            // get items that are open
            if myDatabaseConnection.getActiveTask(myItem.taskID as Int).count > 0
            {
                retVal++
            }
        }
        
        return retVal
    }
}
