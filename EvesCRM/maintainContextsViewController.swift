//
//  maintainContexts.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 1/10/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI

protocol MyMaintainContextsDelegate{
    func myMaintainContextsDidFinish(controller:MaintainContextsViewController)
}

class MaintainContextsViewController: UIViewController, CNContactPickerDelegate//, SMTEFillDelegate, UITextViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var lblPeople: UILabel!
    @IBOutlet weak var lblPlaces: UILabel!
    @IBOutlet weak var lblTool: UILabel!
    @IBOutlet weak var colPeople: UICollectionView!
    @IBOutlet weak var colPlace: UICollectionView!
    @IBOutlet weak var colTool: UICollectionView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnAddPerson: UIButton!
    @IBOutlet weak var btnAddPlace: UIButton!
    @IBOutlet weak var btnAddTool: UIButton!
    @IBOutlet weak var btnSelectPerson: UIButton!
    
    @IBOutlet weak var constraintColPeopleHeight: NSLayoutConstraint!
    
    
    var delegate: MyMaintainContextsDelegate?
    
    private var peopleArray: [context] = Array()
    private var placeArray: [context] = Array()
    private var toolArray: [context] = Array()
    
    private var kbHeight: CGFloat!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteContext:", name:"NotificationMaintainContextsDeleteContext", object: nil)
        
        let contextList = contexts()
        
        peopleArray = contextList.people
        placeArray = contextList.places
        toolArray = contextList.tools
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated:Bool)
    {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        colPeople.collectionViewLayout.invalidateLayout()
        colPeople.reloadData()
        
        colPlace.collectionViewLayout.invalidateLayout()
        colPlace.reloadData()
        
        colTool.collectionViewLayout.invalidateLayout()
        colTool.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == colPeople
        {
            return peopleArray.count
        }
        else if collectionView == colPlace
        {
            return placeArray.count
        }
        else if collectionView == colTool
        {
            return toolArray.count
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        
        
        if collectionView == colPeople
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellPeople", forIndexPath: indexPath) as! myContextDetails
            
            cell.lblName.text = peopleArray[indexPath.row].name
            cell.rowID = indexPath.row
            cell.contextType = peopleArray[indexPath.row].contextType
            
            if (indexPath.row % 2 == 0)
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
        else if collectionView == colPlace
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellPlace", forIndexPath: indexPath) as! myContextDetails
            
            cell.lblName.text = placeArray[indexPath.row].name
            cell.rowID = indexPath.row
            cell.contextType = placeArray[indexPath.row].contextType
            
            if (indexPath.row % 2 == 0)
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
        else // collectionView == colTool
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellTool", forIndexPath: indexPath) as! myContextDetails
            
            cell.lblName.text = toolArray[indexPath.row].name
            cell.rowID = indexPath.row
            cell.contextType = toolArray[indexPath.row].contextType
            
            if (indexPath.row % 2 == 0)
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
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        if collectionView == colPeople
        {
            retVal = CGSize(width: colPeople.bounds.size.width, height: 39)
        }
        else if collectionView == colPlace
        {
            retVal = CGSize(width: colPlace.bounds.size.width, height: 39)
        }
        else if collectionView == colTool
        {
            retVal = CGSize(width: colTool.bounds.size.width, height: 39)
        }

        return retVal
    }
    
    func contactPickerDidCancel(picker: CNContactPickerViewController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let fullname = CNContactFormatter.stringFromContact(contact, style: CNContactFormatterStyle.FullName)
        
        let newContext = context(inTeamID: myCurrentTeam.teamID)
        
        newContext.name = fullname!
        newContext.contextType = "Person"
        newContext.personID = Int(contact.identifier)!
        newContext.status = "Open"
        
        let contextList = contexts()
        
        peopleArray = contextList.people
        
        colPeople.reloadData()
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            delegate!.myMaintainContextsDidFinish(self)
        }
    }
    
    @IBAction func btnAddPerson(sender: UIButton)
    {
        if txtName.text != ""
        {
            let newContext = context(inTeamID: myCurrentTeam.teamID)
            newContext.name = txtName.text!
            newContext.contextType = "Person"
            newContext.status = "Open"
        
            txtName.text = ""
            
            let contextList = contexts()
        
            peopleArray = contextList.people

            colPeople.reloadData()
        }
    }
    
    @IBAction func btnAddPlace(sender: UIButton)
    {
        if txtName.text != ""
        {
            let newContext = context(inTeamID: myCurrentTeam.teamID)
            newContext.name = txtName.text!
            newContext.contextType = "Place"
            newContext.status = "Open"
            
            txtName.text = ""
            
            let contextList = contexts()
            
            placeArray = contextList.places
            
            colPlace.reloadData()
        }
    }
    
    @IBAction func btnAddTool(sender: UIButton)
    {
        if txtName.text != ""
        {
            let newContext = context(inTeamID: myCurrentTeam.teamID)
            newContext.name = txtName.text!
            newContext.contextType = "Tool"
            newContext.status = "Open"
            
            txtName.text = ""
            
            let contextList = contexts()
            
            toolArray = contextList.tools
            
            colTool.reloadData()
        }
    }
    
    @IBAction func btnSelectPerson(sender: UIButton)
    {
        let picker = CNContactPickerViewController()
        
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func deleteContext(notification: NSNotification)
    {
        let rowID = notification.userInfo!["rowID"] as! Int
        let contextType = notification.userInfo!["contextType"] as! String
        
        switch contextType
        {
            case "Person" :
                peopleArray[rowID].delete()
            
            case "Place":
                placeArray[rowID].delete()
            
            case "Tool" :
                toolArray[rowID].delete()
            
            default :
                let _ = 1
        }
        
        let contextList = contexts()
        
        peopleArray = contextList.people
        placeArray = contextList.places
        toolArray = contextList.tools
        
        colPeople.reloadData()
        colPlace.reloadData()
        colTool.reloadData()
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.animateTextField(false)
    }
    
    func animateTextField(up: Bool)
    {
        let movement = (up ? -kbHeight : kbHeight)
        
        UIView.animateWithDuration(0.3, animations: { self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
            
        if up
        {
            constraintColPeopleHeight.constant = 150
        }
//        else
//        {
//            constraintColPeopleHeight.constant >= 100
//        }
    }
}

class myContextDetails: UICollectionViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    
    var rowID: Int = 0
    var contextType: String = ""
    
    @IBAction func btnRemove(sender: UIButton)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationMaintainContextsDeleteContext", object: nil, userInfo:["rowID":rowID, "contextType":contextType])
    }
}