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
    @IBOutlet weak var btnPassPhrase: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblPhrase: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var tblUsers: UITableView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnAdd: UIBarButtonItem!
    @IBOutlet weak var tblRoles: UITableView!
    @IBOutlet weak var lblLoadingUsers: UILabel!
    @IBOutlet weak var lblRoles: UILabel!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblPassPhraseTitle: UILabel!
    @IBOutlet weak var lblPassPhraseExpiryTitle: UILabel!
    
    var workingUser: userItem!
    var communicationDelegate: myCommunicationDelegate?
    var initialUser: Bool = false
    
    fileprivate var userList: userItems!
    
    override func viewDidLoad()
    {
        hideFields()
        if !initialUser
        {
            tblUsers.isHidden = true
            lblLoadingUsers.isHidden = false
            if workingUser == nil
            {
                getUserListForTeam()
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
            else
            {
                tblUsers.isHidden = false
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
        switch tableView
        {
            case tblUsers:
                if userList == nil
                {
                    return 0
                }
                else
                {
                    return userList.users.count
                }
            
            case tblRoles:
                if workingUser == nil
                {
                    return 0
                }
                else
                {
                    return workingUser.roles.userRole.count
            }
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView
        {
            case tblUsers:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellUser", for: indexPath) as! oneLabelTable
                
                cell.lbl1.text = userList.users[indexPath.row].name
                
                return cell
            
            case tblRoles:
                let cell = tableView.dequeueReusableCell(withIdentifier:"cellRoles", for: indexPath) as! userPermissions
                
                cell.lblRole.text = workingUser.roles.userRole[indexPath.row].roleType
                cell.btnPermission.setTitle(workingUser.roles.userRole[indexPath.row].accessLevel, for: .normal)
                cell.record = workingUser.roles.userRole[indexPath.row]
                cell.mainView = self
                cell.sourceView = cell
                
                return cell
            
            default:
                return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblUsers
        {
            workingUser = userItem(userID: userList.users[indexPath.row].userID)
            workingUser.name = userList.users[indexPath.row].name
            workingUser.email = userList.users[indexPath.row].email
            workingUser.passPhrase = userList.users[indexPath.row].passPhrase
            workingUser.phraseDate = userList.users[indexPath.row].phraseDate
            workingUser.currentTeam = currentUser.currentTeam
            populateForm()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        if tableView == tblUsers
        {
            return UITableViewCellEditingStyle.delete
        }
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if currentUser.checkPermission(adminRoleType) == writePermission
        {
            if tableView == tblUsers
            {
                if editingStyle == .delete
                {
                    let teamList = userTeams(userID: userList.users[indexPath.row].userID)
                    for myItem in teamList.UserTeams
                    {
                        if myItem.teamID == currentUser.currentTeam!.teamID
                        {
                            myItem.delete()
                        }
                    }
                    
                    getUserListForTeam()
                }
            }
        }
    }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem)
    {
        btnSave.isEnabled = false
        if workingUser == nil
        {
            lblLoadingUsers.text = "Creating and Saving User.  Please wait"
            lblLoadingUsers.isHidden = false
            notificationCenter.addObserver(self, selector: #selector(self.userCreated), name: NotificationUserCreated, object: nil)
            workingUser = userItem(currentTeam: currentUser.currentTeam!, userName: txtName.text!, userEmail: txtEmail.text!)
        }
        else
        {
            workingUser.name = txtName.text!
            workingUser.email = txtEmail.text!
            
            workingUser.save()
            
            getUserListForTeam()
        }
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
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
    
    @IBAction func btnAdd(_ sender: UIBarButtonItem)
    {
        if canAddUser()
        {
            lblPassPhraseTitle.isHidden = true
            lblPhrase.isHidden = true
            lblPassPhraseExpiryTitle.isHidden = true
            lblDate.isHidden = true
            btnPassPhrase.isHidden = true
            lblRoles.isHidden = true
            tblRoles.isHidden = true
            
            lblName.isHidden = false
            lblNameTitle.isHidden = false
            txtEmail.isHidden = false
            txtName.isHidden = false
            btnAdd.isEnabled = false
            workingUser = nil
            txtEmail.text = ""
            txtName.text = ""
            
            txtName.becomeFirstResponder()
        }
    }
    
    @IBAction func txtFieldChanged(_ sender: UITextField)
    {
        if txtName.text! != "" && txtEmail.text != ""
        {
            btnSave.isEnabled = true
            btnAdd.isEnabled = false
        }
        else
        {
            btnSave.isEnabled = false
            btnAdd.isEnabled = true
        }
    }
    
    func userCreated()
    {
//        DispatchQueue.global().async
//        {
//            myDBSync.sync()
//        }
        
        DispatchQueue.main.async
        {
            self.workingUser.addInitialUserRoles()
        }
        
        getUserListForTeam()
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
        btnSave.isEnabled = false
        lblNameTitle.isHidden = true
        lblPassPhraseTitle.isHidden = true
        lblPassPhraseExpiryTitle.isHidden = true
        btnPassPhrase.isHidden = true
        tblRoles.isHidden = true
        lblRoles.isHidden = true
        if initialUser
        {
            btnAdd.isEnabled = false
        }
        else
        {
            btnAdd.isEnabled = true
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
        btnSave.isEnabled = true
        lblNameTitle.isHidden = false
        lblPassPhraseTitle.isHidden = false
        lblPassPhraseExpiryTitle.isHidden = false
        btnPassPhrase.isHidden = false
        tblRoles.isHidden = false
        lblRoles.isHidden = false
        if initialUser
        {
            btnAdd.isEnabled = false
        }
        else
        {
            btnAdd.isEnabled = true
        }
    }
    
    func populateForm()
    {
        txtName.text = workingUser.name
        txtEmail.text = workingUser.email
        lblPhrase.text = workingUser.passPhrase
        lblDate.text = workingUser.phraseDateText
        
        showFields()
        btnSave.isEnabled = false
        tblRoles.reloadData()
        
        if currentUser.checkPermission(adminRoleType) != writePermission
        {
            btnAdd.isEnabled = false
            btnSave.isEnabled = false
        }
    }
    
    func getUserListForTeam()
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
        
        notificationCenter.addObserver(self, selector: #selector(self.userListRetrieved), name: NotificationUserListLoaded, object: nil)
        
        userList = userItems(userList: userString)
    }
    
    func userListRetrieved()
    {
        notificationCenter.removeObserver(NotificationUserListLoaded)

        DispatchQueue.main.async
        {
            self.tblUsers.isHidden = false
            self.lblLoadingUsers.isHidden = true
            self.tblUsers.reloadData()
            
            if self.workingUser != nil
            {
                self.lblLoadingUsers.isHidden = true
                self.btnSave.isEnabled = false
                self.btnAdd.isEnabled = true
                self.lblPassPhraseTitle.isHidden = false
                self.lblPhrase.isHidden = false
                self.lblPassPhraseExpiryTitle.isHidden = false
                self.lblDate.isHidden = false
                self.btnPassPhrase.isHidden = false
                self.lblRoles.isHidden = false
                self.tblRoles.isHidden = false
                self.populateForm()
            }
        }
    }
    
    func canAddUser() -> Bool
    {
        // here we are going to see how many users are declared for the owners teams.
        
        let teamOwner = currentUser.currentTeam!.teamOwner

        var userCount: Int = 0
        
        for myItem in myDatabaseConnection.getTeamsIOwn(teamOwner)
        {
            let tempTeam = userTeams(teamID: Int(myItem.teamID))
            
            userCount += tempTeam.UserTeams.count
        }
        
        if userCount > currentUser.currentTeam!.subscriptionLevel
        {
            let alert = UIAlertController(title: "Subscription Number Expired", message:
                "Your teams User count if \(userCount) has exceeded your permitted total of \(currentUser.currentTeam!.subscriptionLevel).  Either delete some users from your team, or contact your Administator to increase the maximum number of users.", preferredStyle: UIAlertControllerStyle.alert)
            
            let yesOption = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: nil)
            
            alert.addAction(yesOption)
            self.present(alert, animated: false, completion: nil)
            
            return false
        }
        
        return true
    }
}

class userPermissions: UITableViewCell, UIPopoverPresentationControllerDelegate, MyPickerDelegate
{
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var btnPermission: UIButton!
    
    var record: userRoleItem!
    var sourceView: userPermissions!
    var mainView: userFormViewController!
    
    fileprivate var displayList: [String] = Array()
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnPermission(_ sender: UIButton)
    {
        displayList.removeAll()
        
        displayList.append(noPermission)
        displayList.append(readPermission)
        displayList.append(writePermission)
        
        if displayList.count > 0
        {
            let pickerView = pickerStoryboard.instantiateViewController(withIdentifier: "pickerView") as! PickerViewController
            pickerView.modalPresentationStyle = .popover
            
            let popover = pickerView.popoverPresentationController!
            popover.delegate = sourceView
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            pickerView.source = "btnRateMon"
            
            pickerView.delegate = sourceView
            pickerView.pickerValues = displayList
            pickerView.preferredContentSize = CGSize(width: 300,height: 500)
            pickerView.currentValue = sender.currentTitle!
            mainView.present(pickerView, animated: true, completion: nil)
        }
    }
    
    func myPickerDidFinish(_ source: String, selectedItem:Int)
    {
        var workingItem: Int = 0
        
        if selectedItem >= 0
        {
            workingItem = selectedItem
        }
        
        if workingItem >= 0
        {
            record.accessLevel = displayList[workingItem]
            btnPermission.setTitle(displayList[workingItem], for: .normal)
        }
    }
}
