//
//  userFormViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 14/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class userFormViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnPassPhrase: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblPhrase: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var tblUsers: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    
    var workingUser: userItem!
    var communicationDelegate: myCommunicationDelegate?
    var initialUser: Bool = false
    
    override func viewDidLoad()
    {
        if initialUser
        {
            btnAdd.isHidden = true
        }
        
        let myReachability = Reachability()
        if myReachability.isConnectedToNetwork()
        {
            if workingUser != nil
            {
                populateForm()
            }
        }
        else
        {
            // Not connected to Internet

        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let myReachability = Reachability()
        if !myReachability.isConnectedToNetwork()
        {
            let alert = UIAlertController(title: "User Maintenance", message: "You must be connected to the Internet to create or edit users", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                                          handler: { (action: UIAlertAction) -> () in
                                            self.dismiss(animated: true, completion: nil)
            }))
            
            alert.isModalInPopover = true
            let popover = alert.popoverPresentationController
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: (self.view.bounds.width / 2) - 850,y: (self.view.bounds.height / 2) - 350,width: 700 ,height: 700)
            
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
//        let cell = tableView.dequeueReusableCell(withIdentifier:"addInfoCell", for: indexPath) as! personAddInfoItem
//        
//        cell.lblDescription.text = addInfoRecords.personAdditionalInfos[indexPath.row].addInfoName
//        cell.lblType.text = addInfoRecords.personAdditionalInfos[indexPath.row].addInfoType
//        cell.addInfoID = addInfoRecords.personAdditionalInfos[indexPath.row].addInfoID
//        
        return UITableViewCell()
    }

    @IBAction func btnSave(_ sender: UIButton)
    {
        workingUser.name = txtName.text!
        workingUser.email = txtEmail.text!
            
        workingUser.save()
    }
    
    @IBAction func btnCancel(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
        if communicationDelegate != nil
        {
            communicationDelegate?.callLoadMainScreen!()
        }
    }
    
    @IBAction func btnPassPhrase(_ sender: UIButton)
    {
        workingUser.generatePassPhrase()
        lblPhrase.text = workingUser.passPhrase
        lblDate.text = workingUser.phraseDateText
    }
    
    @IBAction func btnAdd(_ sender: UIButton)
    {
    }
    
    func populateForm()
    {
        txtName.text = workingUser.name
        txtEmail.text = workingUser.email
        lblPhrase.text = workingUser.passPhrase
        lblDate.text = workingUser.phraseDateText
    }
}

