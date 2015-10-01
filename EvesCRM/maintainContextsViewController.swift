//
//  maintainContexts.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 1/10/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation
import AddressBook
import AddressBookUI

protocol MyMaintainContextsDelegate{
    func myMaintainContextsDidFinish(controller:MaintainContextsViewController)
}

class MaintainContextsViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate//, SMTEFillDelegate, UITextViewDelegate, UITextFieldDelegate
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
    
    var delegate: MyMaintainContextsDelegate?
    
    private var peopleArray: [context] = Array()
    private var placeArray: [context] = Array()
    private var toolArray: [context] = Array()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
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
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecordRef)
    {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
        
        let fullname = (ABRecordCopyCompositeName(person).takeRetainedValue() as String) ?? ""
        
        let newContext = context(inTeamID: myCurrentTeam.teamID)
        
        newContext.name = fullname
        newContext.contextType = "Person"
        newContext.personID = Int(ABRecordGetRecordID(person))
        newContext.status = "Open"
        
        let contextList = contexts()
        
        peopleArray = contextList.people
        
        colPeople.reloadData()
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController)
    {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
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
        let picker = ABPeoplePickerNavigationController()
        
        picker.peoplePickerDelegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
}

class myContextDetails: UICollectionViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    
    var contextType: String = ""
    
    @IBAction func btnRemove(sender: UIButton)
    {
        
    }
}