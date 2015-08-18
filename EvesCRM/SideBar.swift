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
        var displayObject: menuObject!
        // Get list of Projects
        
        menuDetails.removeAll(keepCapacity: false)
        
        let myProjects = myDatabaseConnection.getAllOpenProjects(myTeamID)
        
        displayObject = createMenuItem("Projects", inType: "Header", inObject: "Projects")
        menuDetails.append(displayObject)
        
        for myProject in myProjects
        {
            displayObject = createMenuItem(myProject.projectName, inType: "Project", inObject: myProject)
            menuDetails.append(displayObject)
        }
        
        // Get list of Contexts
        
        displayObject = createMenuItem("Contexts", inType: "Header", inObject: "Contexts")
        menuDetails.append(displayObject)
        
        let myContextList = contexts()
        
        for myContext in myContextList.contextsByHierarchy
        {
            displayObject = createMenuItem(myContext.contextHierarchy, inType: "Context", inObject: myContext)
            menuDetails.append(displayObject)
        }
        
        displayObject = createMenuItem("Actions", inType: "Header", inObject: "Contexts")
        menuDetails.append(displayObject)
        
        displayObject = createMenuItem("Address Book", inType: "Action", inObject: "Address Book")
        menuDetails.append(displayObject)
        
        displayObject = createMenuItem("Maintain Projects", inType: "Action", inObject: "Maintain Projects")
        menuDetails.append(displayObject)
        
        displayObject = createMenuItem("Maintain Display Panes", inType: "Action", inObject: "Maintain Display Panes")
        menuDetails.append(displayObject)
       
        displayObject = createMenuItem("Settings", inType: "Action", inObject: "Settings")
        menuDetails.append(displayObject)

        sideBarTableViewController.tableData = menuDetails
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
