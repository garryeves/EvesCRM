//
//  clientMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 19/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class clientMaintenanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var tblContracts: UITableView!
    @IBOutlet weak var btnAddContract: UIButton!
    @IBOutlet weak var btnAddClient: UIButton!
    @IBOutlet weak var btnContact: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblClients: UITableView!
    @IBOutlet weak var lblContracts: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tblRates: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblRates: UILabel!
    
    var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var clientList: clients!
    fileprivate var contractsList: projects!
    var selectedClient: client!
    fileprivate var selectedContract: project!
    fileprivate var ratesList: rates!
    
    override func viewDidLoad()
    {
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        
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
            case tblClients:
                if clientList == nil
                {
                    return 0
                }
                else
                {
                    return clientList.clients.count
                }
            
            case tblContracts:
                if contractsList == nil
                {
                    return 0
                }
                else
                {
                    return contractsList.projects.count
                }
            
            case tblRates:
                if ratesList == nil
                {
                    return 0
                }
                else
                {
                    return ratesList.rates.count
                }
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblClients:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellClients", for: indexPath) as! clientsListItem
        
                cell.lblName.text = clientList.clients[indexPath.row].name
                
                return cell
                
            case tblContracts:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellContract", for: indexPath) as! contractsSummaryItem
                
                cell.lblContractName.text = contractsList.projects[indexPath.row].projectName
            
                return cell
            
            case tblRates:
                // if rate has a shift them do not allow iot to be removed, unenable button
                
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellRates", for: indexPath) as! ratesListItem
                
                cell.lblName.text = ratesList.rates[indexPath.row].rateName
                cell.lblClient.text = formatCurrency(value: ratesList.rates[indexPath.row].chargeAmount)
                cell.lblStaff.text = formatCurrency(value: ratesList.rates[indexPath.row].rateAmount)
                cell.lblStart.text = ratesList.rates[indexPath.row].displayStartDate
                
                // Calculate GP%
                
                let GP = ((ratesList.rates[indexPath.row].chargeAmount - ratesList.rates[indexPath.row].rateAmount) / ratesList.rates[indexPath.row].chargeAmount) * 100
                
                cell.lblGP.text = String(format: "%.1f", GP)
                
                if ratesList.rates[indexPath.row].hasShiftEntry
                {
                    cell.btnRemove.isEnabled = false
                }
                else
                {
                    cell.btnRemove.isEnabled = true
                }
                
            return cell

            default:
                return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView
        {
            case tblClients:
                selectedClient = clientList.clients[indexPath.row]
                refreshScreen()
                
            case tblContracts:
                selectedContract = contractsList.projects[indexPath.row]
                let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
                contractEditViewControl.communicationDelegate = self
                contractEditViewControl.workingContract = selectedContract
                self.present(contractEditViewControl, animated: true, completion: nil)
            
            case tblRates:
                let rateMaintenanceEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "rateMaintenance") as! rateMaintenanceViewController
                rateMaintenanceEditViewControl.communicationDelegate = self
                rateMaintenanceEditViewControl.workingRate = ratesList.rates[indexPath.row]
                rateMaintenanceEditViewControl.modalPresentationStyle = .popover
                
                let popover = rateMaintenanceEditViewControl.popoverPresentationController!
                popover.delegate = self
                popover.sourceView = tableView
                popover.sourceRect = tableView.bounds
                popover.permittedArrowDirections = .any
                
                rateMaintenanceEditViewControl.preferredContentSize = CGSize(width: 500,height: 200)
                
                self.present(rateMaintenanceEditViewControl, animated: true, completion: nil)

            default:
                let _ = 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if tableView == tblRates
        {
            let headerView = tableView.dequeueReusableCell(withIdentifier: "cellHeader") as! ratesHeaderItem
            
            return headerView
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if tableView == tblRates
        {
            return 30
        }
        else
        {
            return 0
        }
    }

    @IBAction func btnSave(_ sender: UIButton)
    {
        selectedClient.name = txtName.text!
        selectedClient.note = txtNotes.text!
        selectedClient.save()
        
        refreshScreen()
    }
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnContact(_ sender: UIButton)
    {
        let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
        peopleEditViewControl.clientID = selectedClient.clientID
        self.present(peopleEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnAddContract(_ sender: UIButton)
    {
        let newProject = project(teamID: currentUser.currentTeam!.teamID)
        newProject.clientID = selectedClient.clientID
        newProject.save()
        
        let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
        contractEditViewControl.communicationDelegate = self
        contractEditViewControl.workingContract = newProject
        self.present(contractEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnAddClient(_ sender: UIButton)
    {
        selectedClient = client(teamID: currentUser.currentTeam!.teamID)
        showFields()
        refreshScreen()
    }
    
    @IBAction func btnAdd(_ sender: UIButton)
    {
        let tempRate = rate(clientID: selectedClient.clientID, teamID: currentUser.currentTeam!.teamID)
        
        let rateMaintenanceEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "rateMaintenance") as! rateMaintenanceViewController
        rateMaintenanceEditViewControl.communicationDelegate = self
        rateMaintenanceEditViewControl.workingRate = tempRate
        rateMaintenanceEditViewControl.modalPresentationStyle = .popover
        
        let popover = rateMaintenanceEditViewControl.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        
        rateMaintenanceEditViewControl.preferredContentSize = CGSize(width: 500,height: 200)
        
        self.present(rateMaintenanceEditViewControl, animated: true, completion: nil)
    }
    
    func hideFields()
    {
        txtName.isHidden = true
        txtNotes.isHidden = true
        tblContracts.isHidden = true
        btnAddContract.isHidden = true
        btnContact.isHidden = true
        btnSave.isHidden = true
        lblContracts.isHidden = true
        lblContact.isHidden = true
        lblNote.isHidden = true
        lblName.isHidden = true
        tblRates.isHidden = true
        btnAdd.isHidden = true
        lblRates.isHidden = true
    }
    
    func showFields()
    {
        txtName.isHidden = false
        txtNotes.isHidden = false
        tblContracts.isHidden = false
        btnAddContract.isHidden = false
        btnContact.isHidden = false
        btnSave.isHidden = false
        lblContracts.isHidden = false
        lblContact.isHidden = false
        lblNote.isHidden = false
        lblName.isHidden = false
        tblRates.isHidden = false
        btnAdd.isHidden = false
        lblRates.isHidden = false
    }
    
    func refreshScreen()
    {
        clientList = clients(teamID: currentUser.currentTeam!.teamID)
        tblClients.reloadData()

        if selectedClient == nil
        {
            txtName.text = ""
            txtNotes.text = ""
            tblRates.isHidden = true
            lblRates.isHidden = true
            btnAdd.isHidden = true
        }
        else
        {
            contractsList = projects(clientID: selectedClient.clientID)
            tblContracts.reloadData()

            txtName.text = selectedClient.name
            txtNotes.text = selectedClient.note
            
            ratesList = rates(clientID: selectedClient.clientID)
            
            showFields()
            
            if selectedClient.name == ""
            {
                tblRates.isHidden = true
                lblRates.isHidden = true
                btnAdd.isHidden = true
            }
            else
            {
                tblRates.isHidden = false
                lblRates.isHidden = false
                btnAdd.isHidden = false
                
                tblRates.reloadData()
            }
        }
    }
}

class contractsSummaryItem: UITableViewCell
{
    @IBOutlet weak var lblContractName: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class clientsListItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class ratesHeaderItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblStaff: UILabel!
    @IBOutlet weak var lblClient: UILabel!
}

class ratesListItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblStaff: UILabel!
    @IBOutlet weak var lblClient: UILabel!
    @IBOutlet weak var lblGP: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnRemove(_ sender: UIButton)
    {
    }
}

