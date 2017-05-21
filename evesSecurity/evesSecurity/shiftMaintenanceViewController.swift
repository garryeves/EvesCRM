//
//  shiftMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 21/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class shiftMaintenanceViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var lblWEDate: UILabel!
    @IBOutlet weak var lblWETitle: UILabel!
    @IBOutlet weak var tblShifts: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnCreateShift: UIButton!

    var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var peopleList: people!
    fileprivate var shiftList: [shift] = Array()
    fileprivate var currentWeekEndingDate: Date!
    
    override func viewDidLoad()
    {
        // work out the current weekending date
        let dateModifier = (7 - getDayOfWeek(Date())!) + 1
        
        if dateModifier != 7
        {
            currentWeekEndingDate = addDays(to: Date(), days: dateModifier)
        }
        else
        {
            currentWeekEndingDate = Date()
        }
        
        refreshScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return shiftList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        // if rate has a shift them do not allow iot to be removed, unenable button
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"cellRoster", for: indexPath) as! shiftListItem
//        
//        
//        
//        
//        
//        
//        cell.lblContract
//        cell.txtDescription
//        
//        
//        cell.txtStartMon
//        cell.txtToMon
//        cell.btnRateMon
//        cell.btnPersonMon
//        cell.lblTitleMon
//        
//        cell.txtStartTue
//        cell.txtToTue
//        cell.btnRateTue
//        cell.btnPersonTue
//        cell.lblTitleTue
//        
//        cell.txtStartWed
//        cell.txtToWed
//        cell.btnRateWed
//        cell.btnPersonWed
//       cell.lblTitleWed
//        
//        cell.txtStartThu
//        cell.txtToThu
//        cell.btnRateThu
//        cell.btnPersonThu
//        cell.lblTitleThu
//        
//        cell.txtStartFri
//        cell.txtToFri
//        cell.btnRateFri
//        cell.btnPersonFri
//        cell.blTitleFri
//        
//       cell.txtStartSat
//        cell.xtToSat
//        cell.btnRateSat
//        cell.btnPersonSat
//        cell.lblTitleSat
//        
//        cell.txtStartSun
//        cell.txtToSun
//        cell.btnRateSun
//        cell.btnPersonSun
//        cell.lblTitleSun
//        
//        cell.lblName.text = ratesList.rates[indexPath.row].rateName
//        cell.lblClient.text = formatCurrency(value: ratesList.rates[indexPath.row].chargeAmount)
//        cell.lblStaff.text = formatCurrency(value: ratesList.rates[indexPath.row].rateAmount)
//        cell.lblStart.text = ratesList.rates[indexPath.row].displayStartDate
//        
//        // Calculate GP%
//        
//        let GP = ((ratesList.rates[indexPath.row].chargeAmount - ratesList.rates[indexPath.row].rateAmount) / ratesList.rates[indexPath.row].chargeAmount) * 100
//        
//        cell.lblGP.text = String(format: "%.1f", GP)
//        
//        if ratesList.rates[indexPath.row].hasShiftEntry
//        {
//            cell.btnRemove.isEnabled = false
//        }
//        else
//        {
//            cell.btnRemove.isEnabled = true
//        }
//        
        return UITableViewCell()
    }
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAdd(_ sender: UIButton)
    {
    }
    
    @IBAction func btnCreateShift(_ sender: UIButton)
    {
    }
    
    
    
    @IBAction func editingDidBegin(_ sender: UITextField)
    {
//        if sender == txtStaff
//        {
//            sender.text = "\(workingStaff)"
//        }
//        else if sender == txtClient
//        {
//            sender.text = "\(workingClient)"
//        }
    }
    
    @IBAction func EditingDidEnd(_ sender: UITextField)
    {
//        if let _ = Double(sender.text!)
//        {
//            if sender == txtStaff
//            {
//                workingStaff = Double(sender.text!)!
//                sender.text = formatCurrency(value: workingStaff)
//            }
//            else if sender == txtClient
//            {
//                workingClient = Double(sender.text!)!
//                sender.text = formatCurrency(value: workingClient)
//            }
//        }
    }
    
    @IBAction func btnSave(_ sender: UIButton)
    {
//        if txtName.text == "" || btnStartDate.currentTitle == "Set"
//        {
//            let alert = UIAlertController(title: "Rate Maintenance", message: "You must provide a rate name and start date", preferredStyle: .actionSheet)
//            
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
//                                          handler: { (action: UIAlertAction) -> () in
//                                            self.dismiss(animated: true, completion: nil)
//            }))
//            
//            alert.isModalInPopover = true
//            let popover = alert.popoverPresentationController
//            popover!.delegate = self
//            popover!.sourceView = self.view
//            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
//            
//            self.present(alert, animated: false, completion: nil)
//        }
//        else
//        {
//            // check to see if the values in the charge boxes are different that the stored value, as if they are then user clicked save from one of them and wants to save
//            
//            if let _ = Double(txtStaff.text!)
//            {
//                workingStaff = Double(txtStaff.text!)!
//            }
//            
//            if let _ = Double(txtClient.text!)
//            {
//                workingClient = Double(txtClient.text!)!
//            }
//            
//            workingRate.rateName = txtName.text!
//            workingRate.rateAmount = workingStaff
//            workingRate.chargeAmount = workingClient
//            
//            workingRate.save()
//            
//            communicationDelegate?.refreshScreen!()
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
    @IBAction func btnStartDate(_ sender: UIButton)
    {
//        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "datePicker") as! dateTimePickerView
//        pickerView.modalPresentationStyle = .popover
//        //      pickerView.isModalInPopover = true
//        
//        let popover = pickerView.popoverPresentationController!
//        popover.delegate = self
//        popover.sourceView = sender
//        popover.sourceRect = sender.bounds
//        popover.permittedArrowDirections = .any
//        
//        pickerView.source = "startDate"
//        pickerView.delegate = self
//        if workingRate.startDate == getDefaultDate()
//        {
//            pickerView.currentDate = Date()
//        }
//        else
//        {
//            pickerView.currentDate = workingRate.startDate
//        }
//        pickerView.showTimes = false
//        
//        pickerView.preferredContentSize = CGSize(width: 400,height: 400)
//        
//        self.present(pickerView, animated: true, completion: nil)
    }
    
    func myPickerDidFinish(_ source: String, selectedDate:Date)
    {
//        if source == "startDate"
//        {
//            workingRate.startDate = selectedDate
//            
//            if workingRate.startDate == getDefaultDate()
//            {
//                btnStartDate.setTitle("Set", for: .normal)
//            }
//            else
//            {
//                btnStartDate.setTitle(workingRate.displayStartDate, for: .normal)
//            }
//        }
    }
    
    func refreshScreen()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        lblWEDate.text = dateFormatter.string(from: currentWeekEndingDate)
        
        peopleList = people(teamID: currentUser.currentTeam!.teamID)
        
        let shiftEntries = shifts(teamID: currentUser.currentTeam!.teamID, WEDate: currentWeekEndingDate)

        if shiftEntries.shifts.count == 0
        {
            lblWETitle.isHidden = true
            btnCreateShift.isHidden = false
        }
        else
        {
            lblWETitle.isHidden = false
            btnCreateShift.isHidden = true
        }
        
//        for myShiftEntry in
//        {
//            
//        }
//        

        
    }
    
}

class shiftListItem: UITableViewCell, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var lblContract: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtStartMon: UITextField!
    @IBOutlet weak var txtToMon: UITextField!
    @IBOutlet weak var btnRateMon: UIButton!
    @IBOutlet weak var btnPersonMon: UIButton!
    @IBOutlet weak var lblTitleMon: UILabel!
    
    @IBOutlet weak var txtStartTue: UITextField!
    @IBOutlet weak var txtToTue: UITextField!
    @IBOutlet weak var btnRateTue: UIButton!
    @IBOutlet weak var btnPersonTue: UIButton!
    @IBOutlet weak var lblTitleTue: UILabel!
    
    @IBOutlet weak var txtStartWed: UITextField!
    @IBOutlet weak var txtToWed: UITextField!
    @IBOutlet weak var btnRateWed: UIButton!
    @IBOutlet weak var btnPersonWed: UIButton!
    @IBOutlet weak var lblTitleWed: UILabel!
    
    @IBOutlet weak var txtStartThu: UITextField!
    @IBOutlet weak var txtToThu: UITextField!
    @IBOutlet weak var btnRateThu: UIButton!
    @IBOutlet weak var btnPersonThu: UIButton!
    @IBOutlet weak var lblTitleThu: UILabel!
    
    @IBOutlet weak var txtStartFri: UITextField!
    @IBOutlet weak var txtToFri: UITextField!
    @IBOutlet weak var btnRateFri: UIButton!
    @IBOutlet weak var btnPersonFri: UIButton!
    @IBOutlet weak var lblTitleFri: UILabel!
    
    @IBOutlet weak var txtStartSat: UITextField!
    @IBOutlet weak var txtToSat: UITextField!
    @IBOutlet weak var btnRateSat: UIButton!
    @IBOutlet weak var btnPersonSat: UIButton!
    @IBOutlet weak var lblTitleSat: UILabel!
    
    @IBOutlet weak var txtStartSun: UITextField!
    @IBOutlet weak var txtToSun: UITextField!
    @IBOutlet weak var btnRateSun: UIButton!
    @IBOutlet weak var btnPersonSun: UIButton!
    @IBOutlet weak var lblTitleSun: UILabel!

    var peopleList: people!
    var rateList: rates!
    
    var sourceView: shiftListItem!
    var mainView: shiftMaintenanceViewController!
    
    fileprivate var displayList: [String] = Array()
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }

    @IBAction func btnRate(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in rateList.rates
        {
            displayList.append(myItem.rateName)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "status"
        pickerView.delegate = mainView
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        mainView.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnPerson(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in peopleList.people
        {
            displayList.append(myItem.name)
        }
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = sourceView
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "status"
        pickerView.delegate = mainView
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        mainView.present(pickerView, animated: true, completion: nil)
    }
}

