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
    
    private var containerView: UIView!
    private var myDisplayArray: [AnyObject] = Array()
    
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
        
        buildTopLevel()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        myDisplayArray.removeAll()
        let myTeams = myDatabaseConnection.getAllTeams()
        
        for myTeamID in myTeams
        {
            let myTeam = team(inTeamID: myTeamID.teamID as Int)
            myDisplayArray.append(myTeam)
        }

        containerView = UIView()
        
        let contentHeight = buildDisplay(myDisplayArray, 200, 100, 40, 0, 0, containerView, self)

        // Set up the container view to hold your custom view hierarchy
        let containerSize = CGSizeMake(UIScreen.mainScreen().bounds.width, contentHeight)
        
        containerView.frame = CGRect(origin: CGPointMake(0.0, 0.0), size:containerSize)
        scrollDisplay.addSubview(containerView)

        
        // Tell the scroll view the size of the contents
        scrollDisplay.contentSize = containerSize;
        
        // Set up the minimum & maximum zoom scale
        let scrollViewFrame = scrollDisplay.frame
        let scaleWidth = scrollViewFrame.size.width / scrollDisplay.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollDisplay.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        
        scrollDisplay.minimumZoomScale = minScale
        scrollDisplay.maximumZoomScale = 1.0
        scrollDisplay.zoomScale = 1.0
        
        centerScrollViewContents()
        
    }
    
    func centerScrollViewContents()
    {
        let boundsSize = scrollDisplay.bounds.size
        var contentsFrame = containerView.frame
        
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
        
        containerView.frame = contentsFrame
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return containerView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView)
    {
        centerScrollViewContents()
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
        if sender.targetObject.isKindOfClass(team)
        {
   println("Name = \(sender.targetObject.name)")
            
      /*      let vc = purposeViewController()
            vc.modalPresentationStyle = .Popover
            let popRect = CGRect(x: 100, y: 100, width: 400, height: 600)
            let aPopover =  UIPopoverController(contentViewController: vc)
            aPopover.presentPopoverFromRect(popRect, inView: view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
      */
            
 

            
            let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("purposeController") as! purposeViewController
            popoverContent.modalPresentationStyle = .Popover
            var popover = popoverContent.popoverPresentationController
            
      //      popoverContent.popoverPresentationController!.sourceView = sender.myView
       //     popoverContent.popoverPresentationController!.preferredContentSize = CGSizeMake(500,400)
            popover!.delegate = self
            popover!.sourceView = sender.myView
            popoverContent.preferredContentSize = CGSizeMake(500,400)
            //popover!.sourceRect = CGRectMake(100,100,0,0)
            
      //      var nav = UINavigationController(rootViewController: popoverContent)
  //          popoverContent.modalPresentationStyle = UIModalPresentationStyle.Popover
  //          var popover = popoverContent.popoverPresentationController
  //          popoverContent.preferredContentSize = CGSizeMake(300,400)
  //          popover!.delegate = self
  //          popover!.sourceView = self.view
  //          popover!.sourceRect = CGRectMake(100,100,0,0)
            
            self.presentViewController(popoverContent, animated: true, completion: nil)


            
  //          let popoverVC = self.storyboard!.instantiateViewControllerWithIdentifier("MaintainPanes") as! MaintainPanesViewController
  //          popoverVC.modalPresentationStyle = .Popover
  //          let popoverController = popoverVC.popoverPresentationController
  //          popoverController!.sourceView = self.view
    //        popoverVC.delegate = self
            
       //     self.presentViewController(popoverVC, animated: true, completion: nil)
         
 //            performSegueWithIdentifier("purpose", sender: self)
            
            
          //  let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("purposeController") as! purposeViewController
 //           popoverVC.modalPresentationStyle = .Popover
       
            
//            let popoverController = popoverVC.popoverPresentationController
           // popoverController!.sourceView = self.view
           
//            popoverController!.sourceView = fromView
//            popoverController!.sourceRect = CGRect(x: 100, y: 100, width: 400, height: 600)
//            popoverController!.permittedArrowDirections = .Any
//            popoverController!.delegate = self
            
            
            
//            presentViewController(popoverVC, animated: true, completion: nil)
            

            
            
            
            
   /*
            var popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("purposeController") as! purposeController
            var nav = UINavigationController(rootViewController: popoverContent)
            nav.modalPresentationStyle = UIModalPresentationStyle.Popover
            var popover = nav.popoverPresentationController
            popoverContent.preferredContentSize = CGSizeMake(500,600)
        //    popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRectMake(100,100,0,0)
       //     nav.popoverPresentationController!.delegate = implOfUIAPCDelegate
            
            self.presentViewController(nav, animated: true, completion: nil)
            
  */          
            
    /*        var myPurposeViewController: purposeViewController = storyboard!.instantiateViewControllerWithIdentifier("purposeController") as! purposeViewController
            
            myPurposeViewController.modalPresentationStyle = .Popover
            myPurposeViewController.preferredContentSize = CGSizeMake(400, 600)
            
            let popoverMenuViewController = myPurposeViewController.popoverPresentationController
            popoverMenuViewController?.permittedArrowDirections = .Any
            popoverMenuViewController?.delegate = self
            popoverMenuViewController?.sourceView = self.view
            popoverMenuViewController?.sourceRect = CGRect(x: 100, y: 100, width: 400, height: 600)
            
            presentViewController(myPurposeViewController, animated: true, completion: nil)
    */
        }
    }
    
}