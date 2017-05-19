//
//  securityViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 15/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//
import UIKit

class securityViewController: UIViewController, myCommunicationDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var btnPeople: UIButton!
    @IBOutlet weak var btnClients: UIButton!
    @IBOutlet weak var tblData1: UITableView!
    
    fileprivate var contractList: projects!
    
    fileprivate var lastClientID: Int = 0
    
    var communicationDelegate: myCommunicationDelegate?
    
    override func viewDidLoad()
    {
        btnSettings.setTitle(NSString(string: "\u{2699}") as String, for: UIControlState())
        
        btnPeople.setTitle("Maintain People", for: .normal)
        
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
            case tblData1:
                if contractList == nil
                {
                    return 0
                }
                else
                {
                    lastClientID = 0
                    return contractList.projects.count
                }
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblData1:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellData1", for: indexPath) as! contractsListItem
                
                cell.lblName.text = contractList.projects[indexPath.row].projectName
                cell.lblStartDate.text = contractList.projects[indexPath.row].displayProjectStartDate
                cell.lblEndDate.text = contractList.projects[indexPath.row].displayProjectEndDate

                if contractList.projects[indexPath.row].clientID != lastClientID
                {
                    let tempClient = client(clientID: contractList.projects[indexPath.row].clientID)
                    cell.lblClient.text = tempClient.name
                    lastClientID = contractList.projects[indexPath.row].clientID
                }
                else
                {
                    cell.lblClient.text = ""
                }
                
                return cell
            
            default:
                return UITableViewCell()
            }
    }
    
    @IBAction func btnSettings(_ sender: UIButton)
    {
        let userEditViewControl = self.storyboard?.instantiateViewController(withIdentifier: "settings") as! settingsViewController
        self.present(userEditViewControl, animated: true, completion: nil)
    }

    @IBAction func btnPeople(_ sender: UIButton)
    {
        let peopleEditViewControl = personStoryboard.instantiateViewController(withIdentifier: "personForm") as! personViewController
        self.present(peopleEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnClients(_ sender: UIButton)
    {
        let clientMaintenanceViewControl = clientsStoryboard.instantiateViewController(withIdentifier: "clientMaintenance") as! clientMaintenanceViewController
        clientMaintenanceViewControl.communicationDelegate = self
        self.present(clientMaintenanceViewControl, animated: true, completion: nil)
    }
    
    func refreshScreen()
    {
        contractList = projects(teamID: currentUser.currentTeam!.teamID)
        tblData1.reloadData()
    }
}

class contractsListItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    @IBOutlet weak var btnRoster: UIButton!
    @IBOutlet weak var lblClient: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnRoster(_ sender: UIButton)
    {
    }
}
