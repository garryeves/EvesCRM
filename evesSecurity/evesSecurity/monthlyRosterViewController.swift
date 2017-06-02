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
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblContactDetails: UILabel!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var tblRoster: UITableView!
    @IBOutlet weak var tblContact: UITableView!
    @IBOutlet weak var tblPerson: UITableView!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var btnYear: UIButton!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!

    var communicationDelegate: myCommunicationDelegate?
    
    var selectedPerson: person!
    var month: String!
    var year: String!
    
    fileprivate var peopleList: people!
    fileprivate var displayList: [String] = Array()
    fileprivate var monthList: [String] = Array()
    
    
    override func viewDidLoad()
    {
        DispatchQueue.global().async
        {
            self.populateMonthList()
        }

        if month != nil
        {
            btnMonth.setTitle(month, for: .normal)
        }
        
        if year != nil
        {
            btnYear.setTitle(year, for: .normal)
        }
        else
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY"
            btnYear.setTitle(dateFormatter.string(from: Date()), for: .normal)
        }

        if selectedPerson != nil
        {
            selectedPerson.loadContacts()
            tblContact.reloadData()
            refreshScreen()
        }
        else
        {
            hideFields()
        }
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

    @IBAction func btnBack(_ sender: UIBarButtonItem)
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
        
    
    @IBAction func btnYear(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("2017")
        displayList.append("2018")
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "year"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnShare(_ sender: UIBarButtonItem)
    {
        var messageString: String = ""
        
        if selectedPerson != nil
        {
            messageString +=  "Your shifts for \(currentUser.currentTeam!.name) for the month of \(btnMonth.currentTitle!)\n\n"
            
            
            for myItem in selectedPerson.shiftArray
            {
                let tempProject = project(projectID: myItem.projectID)
                
                messageString += "\(myItem.workDateString) \(myItem.startTimeString) - \(myItem.endTimeString) at \(tempProject.projectName) \n\n"
            }
            
            let activityViewController: UIActivityViewController = createActivityController(messageString)
            
            activityViewController.popoverPresentationController!.sourceView = btnMonth
            
            present(activityViewController, animated:true, completion:nil)
        }
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
            peopleList = people(teamID: currentUser.currentTeam!.teamID, month: btnMonth.currentTitle!, year: btnYear.currentTitle!)
            tblPerson.reloadData()
            showFields()
        }
        else if source == "year"
        {
            btnYear.setTitle(displayList[workingItem], for: .normal)
            if btnMonth.currentTitle! != "Select"
            {
                peopleList = people(teamID: currentUser.currentTeam!.teamID, month: btnMonth.currentTitle!, year: btnYear.currentTitle!)
                tblPerson.reloadData()
                showFields()
            }
        }
        else
        {
            print("unknown entry myPickerDidFinish - source - \(source)")
        }
        
        refreshScreen()
    }
    
    func hideFields()
    {
        btnBack.isEnabled = true
        btnMonth.isHidden = false
        lblMonth.isHidden = true
        lblContactDetails.isHidden = true
        tblRoster.isHidden = true
        tblContact.isHidden = true
        tblPerson.isHidden = true
        lblYear.isHidden = true
        btnYear.isHidden = true
    }
    
    func showFields()
    {
        btnBack.isEnabled = true
        btnMonth.isHidden = false
        lblMonth.isHidden = false
        lblContactDetails.isHidden = false
        tblRoster.isHidden = false
        tblContact.isHidden = false
        tblPerson.isHidden = false
        lblYear.isHidden = false
        btnYear.isHidden = false
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
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
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




