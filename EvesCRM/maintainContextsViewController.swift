//
//  maintainContexts.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 1/10/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import ContactsUI

protocol MyMaintainContextsDelegate{
    func myMaintainContextsDidFinish(_ controller:MaintainContextsViewController)
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
    
    fileprivate var peopleArray: [context] = Array()
    fileprivate var placeArray: [context] = Array()
    fileprivate var toolArray: [context] = Array()
    
    fileprivate var kbHeight: CGFloat!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
        notificationCenter.addObserver(self, selector: #selector(self.deleteContext(_:)), name:NotificationMaintainContextsDeleteContext, object: nil)
        
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
    
    override func viewWillAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        notificationCenter.removeObserver(self)
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
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
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
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        
        if collectionView == colPeople
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPeople", for: indexPath) as! myContextDetails
            
            cell.lblName.text = peopleArray[indexPath.row].name
            cell.rowID = indexPath.row
            cell.contextType = peopleArray[indexPath.row].contextType
            
            if (indexPath.row % 2 == 0)
            {
                cell.backgroundColor = myRowColour
            }
            else
            {
                cell.backgroundColor = UIColor.clear
            }
            
            cell.layoutSubviews()
            
            return cell
        }
        else if collectionView == colPlace
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPlace", for: indexPath) as! myContextDetails
            
            cell.lblName.text = placeArray[indexPath.row].name
            cell.rowID = indexPath.row
            cell.contextType = placeArray[indexPath.row].contextType
            
            if (indexPath.row % 2 == 0)
            {
                cell.backgroundColor = myRowColour
            }
            else
            {
                cell.backgroundColor = UIColor.clear
            }
            
            cell.layoutSubviews()
            
            return cell
        }
        else // collectionView == colTool
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellTool", for: indexPath) as! myContextDetails
            
            cell.lblName.text = toolArray[indexPath.row].name
            cell.rowID = indexPath.row
            cell.contextType = toolArray[indexPath.row].contextType
            
            if (indexPath.row % 2 == 0)
            {
                cell.backgroundColor = myRowColour
            }
            else
            {
                cell.backgroundColor = UIColor.clear
            }
            
            cell.layoutSubviews()
            
            return cell
        }
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:IndexPath) -> CGSize
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
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact)
    {
        picker.dismiss(animated: true, completion: nil)
        
        let fullname = CNContactFormatter.string(from: contact, style: CNContactFormatterStyle.fullName)
        
        let newContext = context(inTeamID: myCurrentTeam.teamID)
        
        newContext.name = fullname!
        newContext.contextType = "Person"
        newContext.personID = Int32(contact.identifier)!
        newContext.status = "Open"
        
        let contextList = contexts()
        
        peopleArray = contextList.people
        
        colPeople.reloadData()
    }
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
        {
            // Do nothing
        }
        else
        {
            delegate!.myMaintainContextsDidFinish(self)
        }
    }
    
    @IBAction func btnAddPerson(_ sender: UIButton)
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
    
    @IBAction func btnAddPlace(_ sender: UIButton)
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
    
    @IBAction func btnAddTool(_ sender: UIButton)
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
    
    @IBAction func btnSelectPerson(_ sender: UIButton)
    {
        let picker = CNContactPickerViewController()
        
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func deleteContext(_ notification: Notification)
    {
        let rowID = notification.userInfo!["rowID"] as! Int
        let contextType = notification.userInfo!["contextType"] as! String
        
        switch contextType
        {
            case "Person" :
                let _ = peopleArray[rowID].delete()
            
            case "Place":
                let _ = placeArray[rowID].delete()
            
            case "Tool" :
                let _ = toolArray[rowID].delete()
            
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
    
    func keyboardWillShow(_ notification: Notification)
    {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        self.animateTextField(false)
    }
    
    func animateTextField(_ up: Bool)
    {
        let movement = (up ? -kbHeight : kbHeight)
        
        UIView.animate(withDuration: 0.3, animations: { self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement!)
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
    
    @IBAction func btnRemove(_ sender: UIButton)
    {
        notificationCenter.post(name: NotificationMaintainContextsDeleteContext, object: nil, userInfo:["rowID":rowID, "contextType":contextType])
    }
}
