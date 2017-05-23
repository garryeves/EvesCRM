//
//  eventPlanningViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 23/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class eventPlanningViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, myCommunicationDelegate
{
    @IBOutlet weak var btnTemplate: UIButton!
    @IBOutlet weak var btnCreatePlan: UIButton!
    @IBOutlet weak var btnMaintainTemplates: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblEvents: UITableView!
    
    var communicationDelegate: myCommunicationDelegate?
    
    override func viewDidLoad()
    {
        
        hideFields()
        refreshScreen()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
//        switch tableView
//        {
//        case tblClients:
//            if clientList == nil
//            {
//                return 0
//            }
//            else
//            {
//                return clientList.clients.count
//            }
//            
//        case tblContracts:
//            if contractsList == nil
//            {
//                return 0
//            }
//            else
//            {
//                return contractsList.projects.count
//            }
//            
//        default:
//            return 0
//        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
//        switch tableView
//        {
//        case tblClients:
//            let cell = tableView.dequeueReusableCell(withIdentifier:"cellClients", for: indexPath) as! clientsListItem
//            
//            cell.lblName.text = clientList.clients[indexPath.row].name
//            
//            return cell
//            
//        case tblContracts:
//            let cell = tableView.dequeueReusableCell(withIdentifier:"cellContract", for: indexPath) as! contractsSummaryItem
//            
//            cell.lblContractName.text = contractsList.projects[indexPath.row].projectName
//            
//            return cell
//            
//        default:
//            return UITableViewCell()
//        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        switch tableView
//        {
//        case tblClients:
//            selectedClient = clientList.clients[indexPath.row]
//            contractsList = projects(clientID: selectedClient.clientID)
//            
//            txtName.text = selectedClient.name
//            txtNotes.text = selectedClient.note
//            showFields()
//            
//            tblContracts.reloadData()
//            
//        case tblContracts:
//            selectedContract = contractsList.projects[indexPath.row]
//            let contractEditViewControl = projectsStoryboard.instantiateViewController(withIdentifier: "contractMaintenance") as! contractMaintenanceViewController
//            contractEditViewControl.communicationDelegate = self
//            contractEditViewControl.workingContract = selectedContract
//            self.present(contractEditViewControl, animated: true, completion: nil)
//            
//        default:
//            let _ = 1
//        }
    }
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        communicationDelegate?.refreshScreen!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnMaintainTemplates(_ sender: UIButton)
    {
        let templatesViewControl = shiftsStoryboard.instantiateViewController(withIdentifier: "eventTemplateForm") as! eventTemplateVoewController
        templatesViewControl.communicationDelegate = self
        self.present(templatesViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnCreatePlan(_ sender: UIButton)
    {
    }
    
    @IBAction func btnTemplate(_ sender: UIButton)
    {
    }
    
    func hideFields()
    {
     }
    
    func showFields()
    {
      
    }
    
    func refreshScreen()
    {
//        clientList = clients(teamID: currentUser.currentTeam!.teamID)
//        tblClients.reloadData()
//        
//        if selectedClient == nil
//        {
//            txtName.text = ""
//            txtNotes.text = ""
//        }
//        else
//        {
//            contractsList = projects(clientID: selectedClient.clientID)
//            tblContracts.reloadData()
//            
//            txtName.text = selectedClient.name
//            txtNotes.text = selectedClient.note
//        }
    }
}

//class contractsSummaryItem: UITableViewCell
//{
//    @IBOutlet weak var lblContractName: UILabel!
//    
//    override func layoutSubviews()
//    {
//        contentView.frame = bounds
//        super.layoutSubviews()
//    }
//}
//
//class clientsListItem: UITableViewCell
//{
//    @IBOutlet weak var lblName: UILabel!
//    
//    override func layoutSubviews()
//    {
//        contentView.frame = bounds
//        super.layoutSubviews()
//    }
//}

