//
//  settingsViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 12/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData

protocol MySettingsDelegate{
    func mySettingsDidFinish(controller:settingsViewController)
}

class settingsViewController: UIViewController
{
    @IBOutlet weak var calStepperPrevious: UIStepper!
    @IBOutlet weak var CalStepperAfter: UIStepper!
    @IBOutlet weak var calStepperRed: UIStepper!
    @IBOutlet weak var CalStepperOrange: UIStepper!
    @IBOutlet weak var CalStepperPurple: UIStepper!
    @IBOutlet weak var textBeforeCal: UITextField!
    @IBOutlet weak var textAfterCal: UITextField!
    @IBOutlet weak var textAfterDueDate: UITextField!
    @IBOutlet weak var textBeforeDueDate: UITextField!
    @IBOutlet weak var textSinceLastUpdate: UITextField!

    @IBOutlet weak var stagesTable: UITableView!
    @IBOutlet weak var roleTable: UITableView!
    @IBOutlet weak var textRole: UITextField!
    @IBOutlet weak var textStage: UITextField!
    @IBOutlet weak var addRole: UIButton!
    @IBOutlet weak var deleteRole: UIButton!
    @IBOutlet weak var addStage: UIButton!
    @IBOutlet weak var deleteStage: UIButton!
    @IBOutlet weak var buttonConnectEvernote: UIButton!
    @IBOutlet weak var ButtonConnectDropbox: UIButton!
    
    
    @IBOutlet weak var colRoles: UICollectionView!
    @IBOutlet weak var colStages: UICollectionView!
    @IBOutlet weak var colDecodes: UICollectionView!
    
    @IBOutlet weak var buttonResetRoles: UIButton!
    @IBOutlet weak var buttonResetStages: UIButton!
    
    var delegate: MySettingsDelegate?
    
    private var myRoles: [Roles]!
    private var myStages: [Stages]!
    private var myDecodes: [Decodes]!
    
    private let ROLE_CELL_IDENTIFER = "roleNameCell"
    private let STAGE_CELL_IDENTIFER = "stageNameCell"
    
    private var evernotePass1: Bool = false
    private var EvernoteAuthenticationDone: Bool = false
    var evernoteSession: ENSession!
    private var myEvernote: EvernoteDetails!
    var dropboxCoreService: DropboxCoreService!
    var myManagedContext: NSManagedObjectContext!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Load the Roles
        myRoles = myDatabaseConnection.getRoles()
        
        // Load the Stages
        myStages = myDatabaseConnection.getVisibleStages()
        
        // Load the decodes
        myDecodes = myDatabaseConnection.getVisibleDecodes()
        
        if evernoteSession.isAuthenticated
        {
            buttonConnectEvernote.hidden = true
        }
        
        if dropboxCoreService.isAlreadyInitialised()
        {
            ButtonConnectDropbox.hidden = true
        }
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "myEvernoteAuthenticationDidFinish", name:"NotificationEvernoteAuthenticationDidFinish", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeSettings:", name:"NotificationChangeSettings", object: nil)

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            delegate?.mySettingsDidFinish(self)
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == colRoles
        {
            return myRoles.count
        }
        else if collectionView == colStages
        {
            return myStages.count
        }
        else
        {
            return myDecodes.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        
        if collectionView == colRoles
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseRoles", forIndexPath: indexPath) as! mySettingRoles
            cell.lblRole.text = myRoles[indexPath.row].roleDescription
            
            if (indexPath.row % 2 == 0)  // was .row
            {
                cell.backgroundColor = swiftColor
            }
            else
            {
                cell.backgroundColor = UIColor.clearColor()
            }
            
            cell.layoutSubviews()
            return cell
        }
        else if collectionView == colStages
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseStages", forIndexPath: indexPath) as! mySettingStages
            cell.lblRole.text  = myStages[indexPath.row].stageDescription
            
            if (indexPath.row % 2 == 0)  // was .row
            {
                cell.backgroundColor = swiftColor
            }
            else
            {
                cell.backgroundColor = UIColor.clearColor()
            }
            
            cell.layoutSubviews()
            return cell
        }
        else
        {
            if myDecodes[indexPath.row].decodeType == "stepper"
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseStepper", forIndexPath: indexPath) as! mySettingStepper
                cell.lblKey.text = myDecodes[indexPath.row].decode_name
                cell.lblValue.text = myDecodes[indexPath.row].decode_value
                cell.myStepper.value = NSString(string: myDecodes[indexPath.row].decode_value).doubleValue
                cell.lookupKey = myDecodes[indexPath.row].decodeType
                
                if (indexPath.row % 2 == 0)  // was .row
                {
                    cell.backgroundColor = swiftColor
                }
                else
                {
                    cell.backgroundColor = UIColor.clearColor()
                }
                
                cell.layoutSubviews()
                return cell
            }
            else if myDecodes[indexPath.row].decodeType == "number"
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseNumber", forIndexPath: indexPath) as! mySettingNumber
                cell.lblKey.text = myDecodes[indexPath.row].decode_name
                cell.txtValue.text = myDecodes[indexPath.row].decode_value
                cell.lookupKey = myDecodes[indexPath.row].decodeType
                
                if (indexPath.row % 2 == 0)  // was .row
                {
                    cell.backgroundColor = swiftColor
                }
                else
                {
                    cell.backgroundColor = UIColor.clearColor()
                }
                
                cell.layoutSubviews()
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseString", forIndexPath: indexPath) as! mySettingString
                cell.lblKey.text = myDecodes[indexPath.row].decode_name
                cell.txtValue.text = myDecodes[indexPath.row].decode_value
                cell.lookupKey = myDecodes[indexPath.row].decodeType
                
                if (indexPath.row % 2 == 0)  // was .row
                {
                    cell.backgroundColor = swiftColor
                }
                else
                {
                    cell.backgroundColor = UIColor.clearColor()
                }
                
                cell.layoutSubviews()
                return cell
            }
        }
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        if collectionView == colRoles
        {
            retVal = CGSize(width: colRoles.bounds.size.width, height: 39)
        }
        else if collectionView == colStages
        {
            retVal = CGSize(width: colStages.bounds.size.width, height: 39)
        }
        else
        {
            retVal = CGSize(width: colDecodes.bounds.size.width, height: 39)
        }

        return retVal
    }
    
    @IBAction func addRoleClick(sender: UIButton)
    {
        if textRole.text == ""
        {
            var alert = UIAlertController(title: "Add Role", message:
                "You need to enter a role name before you can add it", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))

            textRole.becomeFirstResponder()
        }
        else
        {
            // Add the new role
            
            myDatabaseConnection.createRole(textRole.text, inTeamID: 0)
            myRoles = myDatabaseConnection.getRoles()
            roleTable.reloadData()
            textRole.text = ""
        }
    }
    
    @IBAction func addStageClick(sender: UIButton)
    {
        if textStage.text == ""
        {
            var alert = UIAlertController(title: "Add Stage", message:
                "You need to enter a stage name before you can add it", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
            
            textRole.becomeFirstResponder()
        }
        else
        {
            // Add the new role
            
            myDatabaseConnection.createStage(textStage.text, inTeamID: 0)
            myStages = myDatabaseConnection.getStages()
            stagesTable.reloadData()
            textStage.text = ""
        }
    }
    
    @IBAction func ButtonConnectDropboxClick(sender: UIButton)
    {
        connectToDropbox()
    }
    
    @IBAction func buttonConnectEvernoteClick(sender: UIButton)
    {
        connectToEvernote()
    }

    //Evernote
    
    func connectToEvernote()
    {
        // Authenticate to Evernote if needed
        
        if !evernotePass1
        {
            evernoteSession.authenticateWithViewController (self, preferRegistration:false, completion: {
                (error: NSError?) in
                if error != nil
                {
                    // authentication failed
                    // show an alert, etc
                    // ...
                }
                else
                {
                    // authentication succeeded
                    // do something now that we're authenticated
                    // ...
                    self.myEvernote = EvernoteDetails(inSession: self.evernoteSession)
                }
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationEvernoteAuthenticationDidFinish", object: nil)
            })
        }
        
        evernotePass1 = true  // This is to allow only one attempt to launch Evernote
    }
    
    func myEvernoteAuthenticationDidFinish()
    {
        println("Evernote authenticated")
    }
    
    func connectToDropbox()
    {
        if !dropboxCoreService.isAlreadyInitialised()
        {
            dropboxCoreService.initiateAuthentication(self)
        }
    }
    
    @IBAction func buttonResetRolesClick(sender: UIButton)
    {
        myDatabaseConnection.deleteAllRoles()
        populateRoles()
        
        myRoles = myDatabaseConnection.getRoles()
        roleTable.reloadData()
        textRole.text = ""
    }
    
    @IBAction func buttonResetStagesClick(sender: UIButton)
    {
        myDatabaseConnection.deleteAllStages()
        populateStages()
        
        myStages = myDatabaseConnection.getStages()
        stagesTable.reloadData()
        textStage.text = ""
    }
    
    func changeSettings(notification: NSNotification)
    {
        let settingChanged = notification.userInfo!["setting"] as! String
        
        if settingChanged == "Role"
        {
            myRoles = myDatabaseConnection.getRoles()
            colRoles.reloadData()
        }
        else if settingChanged == "Stage"
        {
            myStages = myDatabaseConnection.getVisibleStages()
            colStages.reloadData()
        }
        else
        {
            myDecodes = myDatabaseConnection.getVisibleDecodes()
            colDecodes.reloadData()
        }
    }
}

class mySettingRoles: UICollectionViewCell
{
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnRemove(sender: UIButton)
    {
        myDatabaseConnection.deleteRoleEntry(lblRole.text!, inTeamID: 0)
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationChangeSettings", object: nil, userInfo:["setting":"Role"])
    }
}

class mySettingStages: UICollectionViewCell
{
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnRemove(sender: UIButton)
    {
        myDatabaseConnection.deleteStageEntry(lblRole.text!, inTeamID: 0)
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationChangeSettings", object: nil, userInfo:["setting":"Stage"])
    }
}

class mySettingStepper: UICollectionViewCell
{
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var myStepper: UIStepper!
    var lookupKey: String!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func myStepper(sender: UIStepper)
    {
        myDatabaseConnection.updateDecodeValue(lblKey.text!, inCodeValue: "\(myStepper.value)", inCodeType: lookupKey)
        lblValue.text = "\(myStepper.value)"
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationChangeSettings", object: nil, userInfo:["setting":"Decode"])
    }
}

class mySettingString: UICollectionViewCell
{
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var txtValue: UITextField!
    @IBOutlet weak var btnSet: UIButton!
    var lookupKey: String!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnSet(sender: UIButton)
    {
        myDatabaseConnection.updateDecodeValue(lblKey.text!, inCodeValue: txtValue.text, inCodeType: lookupKey)
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationChangeSettings", object: nil, userInfo:["setting":"Decode"])
    }
}

class mySettingNumber: UICollectionViewCell
{
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var txtValue: UITextField!
    @IBOutlet weak var btnSet: UIButton!
    var lookupKey: String!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnSet(sender: UIButton)
    {
        myDatabaseConnection.updateDecodeValue(lblKey.text!, inCodeValue: txtValue.text, inCodeType: lookupKey)
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationChangeSettings", object: nil, userInfo:["setting":"Decode"])
    }
}

