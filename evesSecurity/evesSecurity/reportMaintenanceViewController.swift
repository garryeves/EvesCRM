//
//  reportMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 15/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class reportMaintenanceViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var tblReports: UITableView!
    @IBOutlet weak var btnAdd: UIBarButtonItem!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblReportingCriteria: UILabel!
    @IBOutlet weak var lblSorting: UILabel!
    @IBOutlet weak var btnType: UIButton!
    @IBOutlet weak var btnSortType: UIButton!
    @IBOutlet weak var btnReport1: UIButton!
    @IBOutlet weak var btnReport2: UIButton!
    @IBOutlet weak var btnReport3: UIButton!
    @IBOutlet weak var btnReport4: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var tblResults: UITableView!
    @IBOutlet weak var btnSort: UIButton!
    
    var communicationDelegate: myCommunicationDelegate?
    fileprivate var currentReport: report!
    fileprivate var reportList: reports!
    fileprivate var displayList: [String] = Array()
    fileprivate var addInfo: personAdditionalInfos!
    
    override func viewDidLoad()
    {
        btnType.setTitle("Select", for: .normal)
        hideFields()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblReports:
                if reportList == nil
                {
                    return 0
                }
                else
                {
                    return reportList.reports.count
                }
            
            case tblResults:
                if currentReport == nil
                {
                    return 0
                }
                else
                {
                    return currentReport.lines.count
                }
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblReports:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellReport", for: indexPath) as! reportListItem
                
                cell.lblName.text = reportList.reports[indexPath.row].reportName
                cell.lblType.text = reportList.reports[indexPath.row].reportType
                return cell
            
            case tblResults:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellResult", for: indexPath) as! resultListItem
                
//                cell.lblRole.text = shiftList[indexPath.row].shiftDescription
//                cell.lblDate.text = shiftList[indexPath.row].workDateShortString
//                cell.btnRate.setTitle(shiftList[indexPath.row].rateDescription, for: .normal)
//                cell.btnPerson.setTitle(shiftList[indexPath.row].personName, for: .normal)
//                cell.btnStart.setTitle(shiftList[indexPath.row].startTimeString, for: .normal)
//                cell.btnEnd.setTitle(shiftList[indexPath.row].endTimeString, for: .normal)
//
//                cell.mainView = self
//                cell.sourceView = cell
//                cell.shiftRecord = shiftList[indexPath.row]
//                cell.peopleList = peopleList
//                cell.rateList = rateList
                
                return cell
            
            default:
                return UITableViewCell()
            }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblReports:
                currentReport = reportList.reports[indexPath.row]
                
                refreshScreen()
            
            default:
                let _ = 1
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if tableView == tblReports
        {
            if editingStyle == .delete
            {
                reportList.reports[indexPath.row].delete()
                
                refreshScreen()
            }
        }
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        if currentReport != nil
        {
            if txtName.text! != ""
            {
                currentReport.reportName = txtName.text!
                currentReport.save()
            }
        }
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAdd(_ sender: UIBarButtonItem)
    {
    }
    
    @IBAction func btnType(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        
        for myItem in (currentUser.currentTeam?.getDropDown(dropDownType: "Reports"))!
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
        
        pickerView.source = "btnType"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnSortType(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("")
        displayList.append("Ascending")
        displayList.append("Descending")
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "btnSortType"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func btnSort(_ sender: UIButton)
    {
        populatePeopleFields()
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        pickerView.source = "btnSort"
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    func populatePeopleFields()
    {
        displayList.removeAll()
        
        addInfo = personAdditionalInfos(teamID: currentUser.currentTeam!.teamID)
        
        for myItem in addInfo.personAdditionalInfos
        {
            displayList.append(myItem.addInfoName)
        }
    }
    @IBAction func btnReport(_ sender: UIButton)
    {
        var fieldType: String = ""
        
        switch sender
        {
            case btnReport1:
                fieldType = "btnReport1"
            
            case btnReport2:
                fieldType = "btnReport2"
            
            case btnReport3:
                fieldType = "btnReport3"
            
            case btnReport4:
                fieldType = "btnReport4"
            
            default:
                print("Report maintenance btnReport - hit default - \(sender)")
        }
        
        if currentReport.reportType == "People"
        {
            populatePeopleFields()
            
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = fieldType
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            
            self.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @IBAction func txtName(_ sender: UITextField)
    {
        if txtName.text != ""
        {
            currentReport.reportName = txtName.text!
            currentReport.save()
        }
    }
    
    func refreshScreen()
    {
        reportList = reports(teamID: currentUser.currentTeam!.teamID)
        
        if currentReport != nil
        {
            showFields()
            
            if currentReport.reportType != ""
            {
                btnType.setTitle(currentReport.reportType, for: .normal)
            }
            else
            {
                btnType.setTitle("Select", for: .normal)
            }
            
            if currentReport.sortOrder1 != ""
            {
                btnSort.setTitle(currentReport.sortOrder1, for: .normal)
            }
            else
            {
                btnSort.setTitle("Select", for: .normal)
            }
            
            if currentReport.sortOrder2 != ""
            {
                btnSortType.setTitle(currentReport.sortOrder2, for: .normal)
            }
            else
            {
                btnSortType.setTitle("Select", for: .normal)
            }
            
            if currentReport.selectionCriteria1 != ""
            {
                btnReport1.setTitle(currentReport.selectionCriteria1, for: .normal)
            }
            else
            {
                btnReport1.setTitle("Select", for: .normal)
            }
            
            if currentReport.selectionCriteria2 != ""
            {
                btnReport2.setTitle(currentReport.selectionCriteria2, for: .normal)
            }
            else
            {
                btnReport2.setTitle("Select", for: .normal)
            }
            
            if currentReport.selectionCriteria3 != ""
            {
                btnReport3.setTitle(currentReport.selectionCriteria3, for: .normal)
            }
            else
            {
                btnReport3.setTitle("Select", for: .normal)
            }
            
            if currentReport.selectionCriteria4 != ""
            {
                btnReport4.setTitle(currentReport.selectionCriteria4, for: .normal)
            }
            else
            {
                btnReport4.setTitle("Select", for: .normal)
            }
            
            txtName.text = currentReport.reportName
        }
    }
    
    func showFields()
    {
        tblReports.isHidden = false
        btnAdd.isEnabled = false
        lblType.isHidden = true
        btnType.isHidden = true
        lblName.isHidden = false
        lblReportingCriteria.isHidden = false
        lblSorting.isHidden = false
        btnSortType.isHidden = false
        btnReport1.isHidden = false
        btnReport2.isHidden = false
        btnReport3.isHidden = false
        btnReport4.isHidden = false
        txtName.isHidden = false
        tblResults.isHidden = false
        btnSort.isHidden = false
    }
    
    func hideFields()
    {
        tblReports.isHidden = false
        btnAdd.isEnabled = true
        lblType.isHidden = false
        btnType.isHidden = false
        lblName.isHidden = true
        lblReportingCriteria.isHidden = true
        lblSorting.isHidden = true
        btnSortType.isHidden = true
        btnReport1.isHidden = true
        btnReport2.isHidden = true
        btnReport3.isHidden = true
        btnReport4.isHidden = true
        txtName.isHidden = true
        tblResults.isHidden = true
        btnSort.isHidden = true
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        var workingItem = 0
        
        if selectedItem < 0
        {
            workingItem = 0
        }
        switch source
        {
            case "btnType":
                btnType.setTitle(displayList[workingItem], for: .normal)
                
                currentReport = report(teamID: currentUser.currentTeam!.teamID)
                currentReport.reportType = displayList[workingItem]
                currentReport.save()
            
            case "btnSortType":
                currentReport.sortOrder2 = displayList[workingItem]
                currentReport.save()
            
            case "btnSort":
                currentReport.sortOrder1 = displayList[workingItem]
                currentReport.save()
            
            case "btnReport1":
                currentReport.selectionCriteria1 = displayList[workingItem]
                currentReport.save()
            
            case "btnReport2":
                currentReport.selectionCriteria1 = displayList[workingItem]
                currentReport.save()
            
            case "btnReport3":
                currentReport.selectionCriteria1 = displayList[workingItem]
                currentReport.save()
            
            case "btnReport4":
                currentReport.selectionCriteria1 = displayList[workingItem]
                currentReport.save()
            
        default:
            print("Report Maintenance - myPickerDidFinish hit default - \(source)")
        }
        
        refreshScreen()
    }
}

class reportListItem: UITableViewCell
{
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class resultListItem: UITableViewCell
{
    @IBOutlet weak var lblData1: UILabel!
    @IBOutlet weak var lblData2: UILabel!
    @IBOutlet weak var lblData3: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}
