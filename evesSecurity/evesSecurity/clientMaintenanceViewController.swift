//
//  clientMaintenanceViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 19/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class clientMaintenanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate
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
    
    var communicationDelegate: myCommunicationDelegate?
    
    fileprivate var clientList: clients!
    fileprivate var contractsList: projects!
    fileprivate var selectedClient: client!
    fileprivate var selectedContract: project!
    
    
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
                contractsList = projects(clientID: selectedClient.clientID)
            
                txtName.text = selectedClient.name
                txtNotes.text = selectedClient.note
                showFields()
                
                tblContracts.reloadData()
                
            case tblContracts:
                selectedContract = contractsList.projects[indexPath.row]
                let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
                contractEditViewControl.communicationDelegate = self
                contractEditViewControl.workingContract = selectedContract
                self.present(contractEditViewControl, animated: true, completion: nil)
                
            default:
                let _ = 1
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
    }
    
    func refreshScreen()
    {
        clientList = clients(teamID: currentUser.currentTeam!.teamID)
        tblClients.reloadData()

        if selectedClient == nil
        {
            txtName.text = ""
            txtNotes.text = ""
        }
        else
        {
            contractsList = projects(clientID: selectedClient.clientID)
            tblContracts.reloadData()

            txtName.text = selectedClient.name
            txtNotes.text = selectedClient.note
        }
    }
}

class contractsSummaryItem: UITableViewCell
{
    @IBOutlet weak var lblContractName: UILabel!
    @IBOutlet weak var btnRates: UIButton!
    @IBOutlet weak var btnShifts: UIButton!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnRates(_ sender: UIButton)
    {
    }
    
    @IBAction func btnShifts(_ sender: UIButton)
    {
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
