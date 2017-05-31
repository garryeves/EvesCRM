//
//  monthlyRosterViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 31/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class monthlyRosterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var tblRoster: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPerson: UIButton!
    @IBOutlet weak var tblContact: UITableView!
    @IBOutlet weak var tblPerson: UITableView!

    var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var selectedPerson: person!
    fileprivate var peopleList: people!
    fileprivate var displayList: [String] = Array()
    fileprivate var monthList: [String] = Array()
    
    override func viewDidLoad()
    {
        DispatchQueue.global().async
        {
            self.populateMonthList()
        }
        
        peopleList = people(teamID: currentUser.currentTeam!.teamID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblContact:
                if selectedPerson == nil
                {
                    return 0
                }
                else
                {
                    return selectedPerson.contacts.count
                }
                
            case tblRoster:
                if selectedPerson == nil
                {
                    return 0
                }
                else
                {
                    return selectedPerson.shiftArray.count
                }
            
            case tblPerson:
                if peopleList == nil
                {
                    return 0
                }
                else
                {
                    return peopleList.people.count
                }
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblContact:
                let cell = tableView.dequeueReusableCell(withIdentifier:"contactCell", for: indexPath) as! rosterContactItem
                
                cell.lblType.text = selectedPerson.contacts[indexPath.row].contactType
                cell.lblDetails.text = selectedPerson.contacts[indexPath.row].contactValue
                cell.btnShare.isHidden = true
                
                return cell
                
            case tblRoster:
                // if rate has a shift them do not allow iot to be removed, unenable button
                
                let cell = tableView.dequeueReusableCell(withIdentifier:"rosterCell", for: indexPath) as! rosterDisplayItem
                
                cell.lblDate.text = selectedPerson.shiftArray[indexPath.row].workDateString
                cell.lblFrom.text = selectedPerson.shiftArray[indexPath.row].startTimeString
                cell.lblTo.text = selectedPerson.shiftArray[indexPath.row].endTimeString
                
                let tempProject = project(projectID: selectedPerson.shiftArray[indexPath.row].projectID)
                cell.lblContract.text = tempProject.projectName
                
                return cell
            
            case tblPerson:
                let cell = tableView.dequeueReusableCell(withIdentifier:"personCell", for: indexPath) as! rosterPersonItem
                
                cell.lblName.text = peopleList.people[indexPath.row].name
                
                return cell
            
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblPerson:
                selectedPerson = peopleList.people[indexPath.row]
                selectedPerson.loadContacts()
                tblContact.reloadData()
                refreshScreen()
            
            default:
                let _ = 1
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnMonth(_ sender: UIButton)
    {
        displayList.removeAll()
        
        for myItem in monthList
        {
            displayList.append(myItem)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "month"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
        
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        var workingItem: Int = 0
        
        if selectedItem < 0
        {
            workingItem = 0
        }
        else
        {
            workingItem = selectedItem
        }
        
        if source == "month"
        {
            btnMonth.setTitle(displayList[workingItem], for: .normal)
        }
        else
        {
            print("unknown entry myPickerDidFinish - source - \(source)")
        }
        
        refreshScreen()
    }
        
    func refreshScreen()
    {
        if btnMonth.currentTitle! != "Select" && selectedPerson != nil
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY"
            let workingYear = dateFormatter.string(from: Date())
            selectedPerson.loadShifts(month: btnMonth.currentTitle!, year: workingYear)
            tblRoster.reloadData()
        }
    }

    func populateMonthList()
    {
        monthList.removeAll()
        
        for myItem in currentUser.currentTeam!.reportingMonths
        {
            monthList.append(myItem)
        }
    }
}

class rosterContactItem: UITableViewCell
{
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnShare(_ sender: UIButton)
    {
    }
}

class rosterDisplayItem: UITableViewCell
{
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTo: UILabel!
    @IBOutlet weak var lblContract: UILabel!
    @IBOutlet weak var lblFrom: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class rosterPersonItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!

    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}




