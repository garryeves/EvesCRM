//
//  reportMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 15/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class reportMaintenanceViewController: UIViewController, MyPickerDelegate, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tblReports: UITableView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblReportingCriteria: UILabel!
    @IBOutlet weak var lblSorting: UILabel!
    @IBOutlet weak var btnType: UIButton!
    @IBOutlet weak var btnSortType: UIButton!
    @IBOutlet weak var btnReport1: UIButton!
    @IBOutlet weak var btnReport3: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var tblResults: UITableView!
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet weak var lblCriteria1: UILabel!
    @IBOutlet weak var lblCriteria2: UILabel!
    @IBOutlet weak var txtCriteria1: UITextField!
    @IBOutlet weak var txtCriteria2: UITextField!
    @IBOutlet weak var btnCriteria1: UIButton!
    @IBOutlet weak var btnCriteria2: UIButton!
    
    var communicationDelegate: myCommunicationDelegate?
    fileprivate var currentReport: report!
    fileprivate var reportList: reports!
    fileprivate var displayList: [String] = Array()
    fileprivate var addInfo: personAdditionalInfos!
    
    override func viewDidLoad()
    {
        btnType.setTitle("Select", for: .normal)
        hideFields()
        
        refreshScreen()
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
                
                cell.lblData1.text = currentReport.lines[indexPath.row].column1
                cell.lblData2.text = currentReport.lines[indexPath.row].column2
                cell.lblData3.text = currentReport.lines[indexPath.row].column3
                
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
                if currentReport != nil
                {
                    if txtName.text! != currentReport.reportName
                    {
                        currentReport.reportName = txtName.text!
                        currentReport.save()
                    }
                }
                
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
            if txtName.text! != currentReport.reportName
            {
                currentReport.reportName = txtName.text!
                currentReport.save()
            }
        }
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
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
        displayList.removeAll()
        
        displayList.append("Name")
        
        if currentReport != nil
        {
            if currentReport.selectionCriteria1 != ""
            {
                displayList.append(currentReport.selectionCriteria1)
            }
        }
        
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
            
            case btnReport3:
                fieldType = "btnReport3"
            
            default:
                print("Report maintenance btnReport - hit default - \(sender)")
        }
        
        if currentReport.reportType == reportPeopleType
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
    
    @IBAction func btnCriteria(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append("Yes")
        displayList.append("No")
        
        let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
        pickerView.modalPresentationStyle = .popover
        
        let popover = pickerView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        if sender == btnCriteria1
        {
            pickerView.source = "btnCriteria1"
        }
        else
        {
            pickerView.source = "btnCriteria2"
        }
        pickerView.delegate = self
        pickerView.pickerValues = displayList
        pickerView.preferredContentSize = CGSize(width: 200,height: 250)
        
        self.present(pickerView, animated: true, completion: nil)
    }
    
    @IBAction func txtName(_ sender: UITextField)
    {
        if txtName.text != ""
        {
            currentReport.reportName = txtName.text!
            currentReport.save()
        }
    }
    
    @IBAction func txtCriteria(_ sender: UITextField)
    {
        if currentReport != nil
        {
            if sender == txtCriteria1
            {
                currentReport.selectionCriteria2 = sender.text!
                currentReport.save()
                currentReport.run()
                tblResults.reloadData()
            }
            else if sender == txtCriteria2
            {
                currentReport.selectionCriteria4 = sender.text!
                currentReport.save()
                currentReport.run()
                tblResults.reloadData()
            }
        }
    }
    
    func refreshScreen()
    {
        reportList = reports(teamID: currentUser.currentTeam!.teamID)
        
        if currentReport != nil
        {
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
            
            txtCriteria1.text = currentReport.selectionCriteria2
            
            if currentReport.selectionCriteria3 != ""
            {
                btnReport3.setTitle(currentReport.selectionCriteria3, for: .normal)
            }
            else
            {
                btnReport3.setTitle("Select", for: .normal)
            }
            
            txtCriteria2.text = currentReport.selectionCriteria4
            
            btnCriteria1.setTitle(currentReport.selectionCriteria2, for: .normal)
            btnCriteria2.setTitle(currentReport.selectionCriteria4, for: .normal)
            
            txtName.text = currentReport.reportName
            
            showFields()
            
            currentReport.run()
            tblResults.reloadData()
        }
        tblReports.reloadData()
    }
    
    func showFields()
    {
        if currentReport != nil
        {
            if btnType.currentTitle! == reportPeopleType
            {
                btnReport1.isHidden = false
                btnReport3.isHidden = true
                
                if currentReport.showCriteria1
                {
                    lblCriteria1.isHidden = false
                    
                    if currentReport.criteriaType1 == perInfoYesNo
                    {
                        txtCriteria1.isHidden = true
                        btnCriteria1.isHidden = false
                    }
                    else
                    {
                        txtCriteria1.isHidden = false
                        btnCriteria1.isHidden = true
                    }
                }
                else
                {
                    lblCriteria1.isHidden = true
                    txtCriteria1.isHidden = true
                    btnCriteria1.isHidden = true
                }
                
                if currentReport.showCriteria2
                {
                    lblCriteria2.isHidden = false
                    if currentReport.criteriaType2 == perInfoYesNo
                    {
                        txtCriteria2.isHidden = true
                        btnCriteria2.isHidden = false
                    }
                    else
                    {
                        txtCriteria2.isHidden = false
                        btnCriteria2.isHidden = true
                    }
                }
                else
                {
                    lblCriteria2.isHidden = true
                    txtCriteria2.isHidden = true
                    btnCriteria2.isHidden = true
                }
            }
            else
            {
                btnReport1.isHidden = true
                btnReport3.isHidden = true
                lblCriteria1.isHidden = true
                txtCriteria1.isHidden = true
                lblCriteria2.isHidden = true
                txtCriteria2.isHidden = true
            }
            
            if currentReport.selectionCriteria1 == ""
            {
                lblSorting.isHidden = true
                btnSortType.isHidden = true
                btnSort.isHidden = true
            }
            else
            {
                lblSorting.isHidden = false
                btnSortType.isHidden = false
                btnSort.isHidden = false
            }
        }
        else
        {
            btnReport1.isHidden = true
            btnReport3.isHidden = true
            lblCriteria1.isHidden = true
            txtCriteria1.isHidden = true
            lblCriteria2.isHidden = true
            txtCriteria2.isHidden = true
            lblSorting.isHidden = true
            btnSortType.isHidden = true
            btnSort.isHidden = true
        }
        
        tblReports.isHidden = false
        lblType.isHidden = true
        btnType.isHidden = true
        lblName.isHidden = false
        lblReportingCriteria.isHidden = false
        btnReport1.isHidden = false
        txtName.isHidden = false
        tblResults.isHidden = false
    }
    
    func hideFields()
    {
        tblReports.isHidden = false
        lblType.isHidden = false
        btnType.isHidden = false
        lblName.isHidden = true
        lblReportingCriteria.isHidden = true
        lblSorting.isHidden = true
        btnSortType.isHidden = true
        btnReport1.isHidden = true
        btnReport3.isHidden = true
        txtName.isHidden = true
        tblResults.isHidden = true
        btnSort.isHidden = true
        lblCriteria1.isHidden = true
        lblCriteria2.isHidden = true
        txtCriteria1.isHidden = true
        txtCriteria2.isHidden = true
        btnCriteria1.isHidden = true
        btnCriteria2.isHidden = true
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        var workingItem = selectedItem
        
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
                currentReport.reportName = displayList[workingItem]
                currentReport.columnTitle1 = "Name"
                currentReport.columnWidth1 = 20.0
                currentReport.columnWidth2 = 70.0
                
                currentReport.save()
            
            case "btnSortType":
                currentReport.sortOrder2 = displayList[workingItem]
                currentReport.save()
            
            case "btnSort":
                currentReport.sortOrder1 = displayList[workingItem]
                currentReport.save()
            
            case "btnReport1":
                currentReport.selectionCriteria1 = displayList[workingItem]
                if currentReport.criteriaType1 == perInfoYesNo
                {
                    if currentReport.selectionCriteria2 == ""
                    {
                        currentReport.selectionCriteria2 = "Yes"
                        btnCriteria1.setTitle("Yes", for: .normal)
                    }
                }
                currentReport.columnTitle2 = displayList[workingItem]
                currentReport.save()
            
            case "btnReport3":
                currentReport.selectionCriteria3 = displayList[workingItem]
                if currentReport.criteriaType2 == perInfoYesNo
                {
                    if currentReport.selectionCriteria4 == ""
                    {
                        currentReport.selectionCriteria4 = "Yes"
                        btnCriteria2.setTitle("Yes", for: .normal)
                    }
                }
                currentReport.save()
            
            case "btnCriteria1":
                currentReport.selectionCriteria2 = displayList[workingItem]
            
            case "btnCriteria2":
                currentReport.selectionCriteria4 = displayList[workingItem]
            
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
