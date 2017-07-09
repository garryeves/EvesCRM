//
//  securityDeletedItemsViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 25/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

private let projectType = "Contract/Project"
private let clientType = "Client"
private let peopleType = "People"

let NotificationItemDeleted = Notification.Name("NotificationItemDeleted")

class securityDeletedItemsViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate, MyPickerDelegate
{
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblItems: UILabel!
    @IBOutlet weak var btnSource: UIButton!
    @IBOutlet weak var tblItems: UITableView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    private var displayList: [String] = Array()
    private var selectedType: String = ""
    private var projectRecords: [Projects] = Array()
    private var clientRecords: [Clients] = Array()
    private var peopleRecords: [Person] = Array()
    
    override func viewDidLoad()
    {
        hideFields()
        
        refreshScreen()
        
        notificationCenter.addObserver(self, selector: #selector(self.refreshScreen), name: NotificationItemDeleted, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView
        {
            case tblItems:
                switch selectedType
                {
                    case projectType:
                        return projectRecords.count
                    
                    case clientType:
                        return clientRecords.count
                    
                    case peopleType:
                        return peopleRecords.count
                    
                    default:
                        return 0
                }
            
            default:
                return 0
       }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblItems:
                
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellItems", for: indexPath) as! deletedItem
                
                switch selectedType
                {
                    case projectType:
                        cell.lblName.text = projectRecords[indexPath.row].projectName
                        cell.lblDate.text = formatDate(projectRecords[indexPath.row].updateTime! as Date)
                        cell.source = projectType
                        cell.recordID = Int(projectRecords[indexPath.row].projectID)
                    
                    case clientType:
                        cell.lblName.text = clientRecords[indexPath.row].clientName
                        cell.lblDate.text = formatDate(clientRecords[indexPath.row].updateTime! as Date)
                        cell.source = clientType
                        cell.recordID = Int(clientRecords[indexPath.row].clientID)
                    
                    case peopleType:
                        cell.lblName.text = peopleRecords[indexPath.row].name
                        cell.lblDate.text = formatDate(peopleRecords[indexPath.row].updateTime! as Date)
                        cell.source = peopleType
                        cell.recordID = Int(peopleRecords[indexPath.row].personID)
                    
                    default:
                        print("refreshScreen unknow type - \(selectedType)")
                }
                
                return cell
            
            default:
                return UITableViewCell()
        }
    }
    
    func formatDate(_ stored: Date) -> String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        myDateFormatter.timeStyle = DateFormatter.Style.short
        
        return myDateFormatter.string(from: stored)
    }
        
    @IBAction func btnSource(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append(projectType)
        displayList.append(clientType)
        displayList.append(peopleType)
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            //      pickerView.isModalInPopover = true
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = self
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            
            pickerView.source = "source"
            pickerView.delegate = self
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 200,height: 250)
            pickerView.currentValue = sender.currentTitle!
            self.present(pickerView, animated: true, completion: nil)
        }
    }
        
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
        
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        if source == "source"
        {
            selectedType = displayList[selectedItem]
            btnSource.setTitle(displayList[selectedItem], for: .normal)
            refreshScreen()
        }
    }
        
    func hideFields()
    {
        lblItems.isHidden = true
        tblItems.isHidden = true
        lblName.isHidden = true
        lblDate.isHidden = true
    }
    
    func showFields()
    {
        lblItems.isHidden = false
        tblItems.isHidden = false
        lblName.isHidden = false
        lblDate.isHidden = false
    }
        
    func refreshScreen()
    {
      //  notificationCenter.removeObserver(NotificationItemDeleted)
        if selectedType == ""
        {
            hideFields()
        }
        else
        {
            showFields()
            switch selectedType
            {
                case projectType:
                    projectRecords = myDatabaseConnection.getDeletedProjects(currentUser.currentTeam!.teamID)
                
                case clientType:
                    clientRecords = myDatabaseConnection.getDeletedClients(currentUser.currentTeam!.teamID)
                
                case peopleType:
                    peopleRecords = myDatabaseConnection.getDeletedPeople(currentUser.currentTeam!.teamID)
                
                default:
                    print("refreshScreen unknown type - \(selectedType)")
            }
            tblItems.reloadData()
        }
   //     notificationCenter.addObserver(self, selector: #selector(self.refreshScreen), name: NotificationItemDeleted, object: nil)
    }
}
    
class deletedItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    var source: String!
    var recordID: Int!
    
    @IBAction func btnRestore(_ sender: UIButton)
    {
        switch source
        {
            case projectType:
                myDatabaseConnection.restoreProject(recordID, teamID: currentUser.currentTeam!.teamID)
            
            case clientType:
                myDatabaseConnection.restoreClient(recordID, teamID: currentUser.currentTeam!.teamID)
            
            case peopleType:
                myDatabaseConnection.restorePerson(recordID, teamID: currentUser.currentTeam!.teamID)
            
            default:
                print("deletedItem unknown type - \(source)")
        }
        
        notificationCenter.post(name: NotificationItemDeleted, object: nil)
    }
}
