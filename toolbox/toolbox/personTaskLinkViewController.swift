//
//  personTaskLinkViewController.swift
//  toolbox
//
//  Created by Garry Eves on 26/7/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class personTaskLinkViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var lblSelect: UILabel!
    @IBOutlet weak var btnPeople: UIButton!
    @IBOutlet weak var txtDescription: UITextView!
    
    private var displayList: [String] = Array()
    private var peopleList: people!
    
    override func viewDidLoad()
    {
        txtDescription.text = "Please select the your name.\n\nThis is the name that will be used when Tasks are assigned to you.\n\nIf you can not find your name then Click on the “People” button to access the screen so you can add in your name."

        // Build up the name of the entry in
        
        if currentUser.personTaskLink == 0
        {
            btnSelect.setTitle("Select", for: .normal)
        }
        else
        {
            let tempPerson = person(personID: currentUser.personTaskLink, teamID: currentUser.currentTeam!.teamID)
            btnSelect.setTitle(tempPerson.name, for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSelect(_ sender: UIButton)
    {
        displayList.removeAll()
        
        peopleList = people(teamID: currentUser.currentTeam!.teamID)
        for myItem in peopleList.people
        {
            displayList.append(myItem.name)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        //      pickerView.isModalInPopover = true
        
        if displayList.count > 0
        {
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "people"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnPeople(_ sender: UIButton)
    {
        let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
        self.present(peopleEditViewControl, animated: true, completion: nil)
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "people"
        {
            currentUser.personTaskLink = peopleList.people[selectedItem].personID
            btnSelect.setTitle(peopleList.people[selectedItem].name, for: .normal)
        }
    }
}
