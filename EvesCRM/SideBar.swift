//
//  SideBar.swift
//  BlurrySideBar
//
//  Created by Training on 01/09/14.
//  Copyright (c) 2014 Training. All rights reserved.
//

import UIKit

@objc protocol SideBarDelegate
{
    func sideBarDidSelectButtonAtIndex(passedItem:menuObject)
    optional func sideBarWillClose()
    optional func sideBarWillOpen(target: UIView)
}

class SideBar: NSObject, SideBarTableViewControllerDelegate {
   
    let barWidth:CGFloat = 300.0
    let sideBarTableViewTopInset:CGFloat = 64.0
    let sideBarContainerView:UIView = UIView()
    let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
    var originView:UIView!
   
    var animator:UIDynamicAnimator!
    var delegate:SideBarDelegate?
    var isSideBarOpen:Bool = false
    var blurView:UIVisualEffectView!
    
    var menuDetails: [menuObject] = Array()
    
    override init()
    {
        super.init()
    }
    
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
    
    func loadMenuItems()
    {
        var numSections: Int = 1
        
        // Get list of Projects
        menuDetails.removeAll(keepCapacity: false)
        
        var headerArray: [menuObject] = Array()
        var fullArray: [menuEntry] = Array()
        
        let planningObject = createMenuItem("Planning", inType: "Header", inObject: "Projects")
        planningObject.section = "Header"
        
        menuDetails.append(planningObject)
        headerArray.append(planningObject)
        
        let doingObject = createMenuItem("Doing", inType: "Header-Disclosure", inObject: "Projects")
        doingObject.type = "disclosure"
        doingObject.section = "Header"
        menuDetails.append(doingObject)
        headerArray.append(doingObject)
        
        for myTeamItem in myDatabaseConnection.getAllTeams()
        {
            numSections++
            let myTeam = team(inTeamID: myTeamItem.teamID as Int)
            let teamObject = createMenuItem(myTeam.name, inType: "Disclosure", inObject: "Projects")
            teamObject.indentation = 1
            teamObject.type = "disclosure"
            teamObject.section = "Team"
            menuDetails.append(teamObject)
            
            let myProjects = myDatabaseConnection.getProjects(myTeam.teamID)
            for myProject in myProjects
            {
                let displayObject = createMenuItem(myProject.projectName, inType: "Project", inObject: myProject)
                displayObject.indentation = 2
                displayObject.section = "\(myTeam.teamID)"
                menuDetails.append(displayObject)
            }
        }
        
        let myContextList = contexts()
        // Get list of People Contexts
        
        let peopleObject = createMenuItem("People", inType: "Header-Disclosure", inObject: "People")
        peopleObject.type = "disclosure"
        peopleObject.section = "Header"
        menuDetails.append(peopleObject)
        headerArray.append(peopleObject)
        
        for myContext in myContextList.peopleContextsByHierarchy
        {
            numSections++
            let displayObject = createMenuItem(myContext.contextHierarchy, inType: "People", inObject: myContext)
            displayObject.indentation = 1
            peopleObject.section = "People"
            menuDetails.append(displayObject)
        }
        
        let addressObject = createMenuItem("Address Book", inType: "People", inObject: "Address Book")
        addressObject.indentation = 1
        addressObject.section = "People"
        menuDetails.append(addressObject)
        
        // Get list of Non People Contexts
        
        let contextObject = createMenuItem("Contexts", inType: "Header-Disclosure", inObject: "Contexts")
        contextObject.type = "disclosure"
        contextObject.section = "Header"
        menuDetails.append(contextObject)
        headerArray.append(contextObject)
        
        for myContext in myContextList.nonPeopleContextsByHierarchy
        {
            numSections++
            let displayObject = createMenuItem(myContext.contextHierarchy, inType: "Context", inObject: myContext)
            displayObject.indentation = 1
            displayObject.section = "Context"
            menuDetails.append(displayObject)
        }
        
        let actionsObject = createMenuItem("Actions", inType: "Header-Disclosure", inObject: "Action")
        actionsObject.type = "disclosure"
        actionsObject.section = "Header"
        menuDetails.append(actionsObject)
        headerArray.append(actionsObject)
        
        numSections++
        let displayPanesObject = createMenuItem("Maintain Display Panes", inType: "Action", inObject: "Maintain Display Panes")
        displayPanesObject.indentation = 1
        displayPanesObject.section = "Action"
        menuDetails.append(displayPanesObject)
       
        let textExpanderObject = createMenuItem("Load TextExpander Snippets", inType: "Action", inObject: "Load TextExpander Snippets")
        textExpanderObject.indentation = 1
        textExpanderObject.section = "Action"
        menuDetails.append(textExpanderObject)
        
        let settingObject = createMenuItem("Settings", inType: "Action", inObject: "Settings")
        settingObject.indentation = 1
        settingObject.section = "Action"
        menuDetails.append(settingObject)
        
        let headerEntry = menuEntry(menuType: "Header", menuEntries: headerArray)
        fullArray.append(headerEntry)
        
        sideBarTableViewController.tableData = menuDetails
        sideBarTableViewController.numberOfSections = numSections
        sideBarTableViewController.tableView.reloadData()
    }
    
    func createMenuItem(inName: String, inType: String, inObject: NSObject) -> menuObject
    {
        let myNewObject = menuObject()
        myNewObject.displayString = inName
        myNewObject.displayType = inType
        myNewObject.displayObject = inObject
        
        return myNewObject
    }
    
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
        
 //       let gravityX:CGFloat = (shouldOpen) ? 0.5 : -0.5
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
}
