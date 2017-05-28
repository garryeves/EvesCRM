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
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    var workingUser: userItem!
    var communicationDelegate: myCommunicationDelegate?
    var initialUser: Bool = false
    
    fileprivate var userList: userItems!
    
    override func viewDidLoad()
    {
        if !initialUser
        {
            if workingUser == nil
            {
                getUserList()
            }
        }
        
        let myReachability = Reachability()
        if myReachability.isConnectedToNetwork()
        {
            // Go and get the list of users for the team
            
            if workingUser != nil
            {
                tblUsers.isHidden = true
                populateForm()
            }
        }
        else
        {
            // Not connected to Internet

        }
        
        hideFields()
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
        return userList.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cellUser", for: indexPath) as! userDisplayItem
        
        cell.lblName.text = userList.users[indexPath.row].name
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        workingUser = userItem(userID: userList.users[indexPath.row].userID)
        workingUser.name = userList.users[indexPath.row].name
        workingUser.email = userList.users[indexPath.row].email
        workingUser.passPhrase = userList.users[indexPath.row].passPhrase
        workingUser.phraseDate = userList.users[indexPath.row].phraseDate
        populateForm()
    }

    @IBAction func btnSave(_ sender: UIButton)
    {
        workingUser.name = txtName.text!
        workingUser.email = txtEmail.text!
            
        workingUser.save()
        
        getUserList()
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
        btnSave.isEnabled = false
        notificationCenter.addObserver(self, selector: #selector(self.userCreated), name: NotificationUserCreated, object: nil)
        workingUser = userItem(currentTeam: currentUser.currentTeam!)
        
        populateForm()
    }
    
    func userCreated()
    {
        workingUser.addInitialUserRoles()
        
        currentUser.syncDatabase()
        
        DispatchQueue.main.async
        {
            self.btnSave.isEnabled = true
        }
    }
    
    func hideFields()
    {
        txtName.isHidden = true
        txtEmail.isHidden = true
        lblPhrase.isHidden = true
        lblDate.isHidden = true
        lblPhrase.isHidden = true
        lblDate.isHidden = true
        lblName.isHidden = true
        lblEmail.isHidden = true
        btnSave.isHidden = true
        btnPassPhrase.isHidden = true
        if initialUser
        {
            btnAdd.isHidden = true
        }
        else
        {
            btnAdd.isHidden = false
        }
    }
    
    func showFields()
    {
        txtName.isHidden = false
        txtEmail.isHidden = false
        lblPhrase.isHidden = false
        lblDate.isHidden = false
        lblPhrase.isHidden = false
        lblDate.isHidden = false
        lblName.isHidden = false
        lblEmail.isHidden = false
        btnSave.isHidden = false
        btnPassPhrase.isHidden = false
        if initialUser
        {
            btnAdd.isHidden = true
        }
        else
        {
            btnAdd.isHidden = false
        }
    }
    
    func populateForm()
    {
        txtName.text = workingUser.name
        txtEmail.text = workingUser.email
        lblPhrase.text = workingUser.passPhrase
        lblDate.text = workingUser.phraseDateText
        
        showFields()
    }
    
    func getUserList()
    {
        let teamList = userTeams(teamID: currentUser.currentTeam!.teamID)
        
        var firstRecordDone: Bool = false
        var userString: String = ""
        
        for myItem in teamList.UserTeams
        {
            if firstRecordDone
            {
                userString += ", "
            }
            
            userString += "\(myItem.userID)"
            
            firstRecordDone = true
        }
        print("string : \(userString)")
        
        notificationCenter.addObserver(self, selector: #selector(self.userListRetrieved), name: NotificationUserListLoaded, object: nil)
        
        userList = userItems(userList: userString)
    }
    
    func userListRetrieved()
    {
        notificationCenter.removeObserver(NotificationUserListLoaded)
        DispatchQueue.main.async
        {
            self.tblUsers.reloadData()
        }
    }
}

class userDisplayItem: UITableViewCell
{
    @IBOutlet weak var lblName: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

