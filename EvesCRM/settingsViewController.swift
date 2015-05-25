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

class settingsViewController: UIViewController, MyMaintainPanesDelegate, LiveAuthDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    
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
    
  
    @IBOutlet weak var buttonMaintainPanes: UIButton!
    @IBOutlet weak var buttonConnectEvernote: UIButton!
    @IBOutlet weak var ButtonConnectDropbox: UIButton!
    @IBOutlet weak var buttonConnectOneNote: UIButton!
    
    var delegate: MySettingsDelegate?
    
    private var myRoles: [Roles]!
    private var myStages: [Stages]!
    private var myRoleSelected: Int = -1
    private var myStageSelected: Int = -1
    
    private let ROLE_CELL_IDENTIFER = "roleNameCell"
    private let STAGE_CELL_IDENTIFER = "stageNameCell"
    
    private var evernotePass1: Bool = false
    private var EvernoteTimer = NSTimer()
    private var EvernoteAuthenticationDone: Bool = false
    var evernoteSession: ENSession!
    private var EvernoteUserTimerCount: Int = 0
    private var myEvernote: EvernoteDetails!
    var dropboxCoreService: DropboxCoreService!
    var myManagedContext: NSManagedObjectContext!
    
    var liveClient: LiveConnectClient!
    // Set the CLIENT_ID value to be the one you get from http://manage.dev.live.com/
    var CLIENT_ID: String = ""
    var OneNoteScopeText: [String] = Array()

    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.roleTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: ROLE_CELL_IDENTIFER)
        self.stagesTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: STAGE_CELL_IDENTIFER)
        
        // Set textfields to be disable to force use of Stepper to change the numbers
        textBeforeCal.enabled = false
        textAfterCal.enabled = false
        textAfterDueDate.enabled = false
        textBeforeDueDate.enabled = false
        textSinceLastUpdate.enabled = false

        roleTable.estimatedRowHeight = 12.0
        roleTable.rowHeight = UITableViewAutomaticDimension
        stagesTable.estimatedRowHeight = 12.0
        stagesTable.rowHeight = UITableViewAutomaticDimension
        
        // Populate the data fields
        
        var decodeString: String = ""
        
        decodeString = getDecodeValue("CalBeforeWeeks")
        
        textBeforeCal.text = decodeString
        
        calStepperPrevious.value = (decodeString as NSString).doubleValue
        
        decodeString = getDecodeValue("CalAfterWeeks")
        
        textAfterCal.text = decodeString
        CalStepperAfter.value = (decodeString as NSString).doubleValue
        
        decodeString = getDecodeValue("OmniRed")
        
        textAfterDueDate.text = decodeString
        calStepperRed.value = (decodeString as NSString).doubleValue
        
        decodeString = getDecodeValue("OmniOrange")
        
        textBeforeDueDate.text = decodeString
        CalStepperOrange.value = (decodeString as NSString).doubleValue

        decodeString = getDecodeValue("OmniPurple")
        
        textSinceLastUpdate.text = decodeString
        CalStepperPurple.value = (decodeString as NSString).doubleValue
        
        // Load the roles table
        
        myRoles = getRoles()
        
        myStages = getStages()
        
        if evernoteSession.isAuthenticated
        {
            buttonConnectEvernote.hidden = true
        }
        
        if dropboxCoreService.isAlreadyInitialised()
        {
            ButtonConnectDropbox.hidden = true
        }
        
        liveClient =  LiveConnectClient(clientId: CLIENT_ID, scopes:OneNoteScopeText, delegate:self, userState: "init")
        let session = self.liveClient.session
        
        if (session == nil)
        {
            buttonConnectOneNote.hidden = false
        }
        else
        {
            buttonConnectOneNote.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        var retVal: Int = 0
        
        if (tableView == roleTable)
        {
            retVal = self.myRoles.count ?? 0
        }
        else if (tableView == stagesTable)
        {
            retVal = self.myStages.count ?? 0
        }
        return retVal
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (tableView == roleTable)
        {
            let cell = roleTable.dequeueReusableCellWithIdentifier(ROLE_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = myRoles[indexPath.row].roleDescription
            return cell
            
        }
        else if (tableView == stagesTable)
        {
            let cell = stagesTable.dequeueReusableCellWithIdentifier(STAGE_CELL_IDENTIFER) as! UITableViewCell
            cell.textLabel!.text = myStages[indexPath.row].stageDescription
            
            return cell
        }
        else
        {
            // Dummy statements to allow use of else
            let cell = roleTable.dequeueReusableCellWithIdentifier(ROLE_CELL_IDENTIFER) as! UITableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        myRoleSelected = -1
        myStageSelected = -1
        
        if tableView == roleTable
        {
            myRoleSelected = indexPath.row
        }
        else if tableView == stagesTable
        {
            myStageSelected = indexPath.row
        }
    }
    
    @IBAction func backButton(sender: UIButton)
    {
        delegate?.mySettingsDidFinish(self)
    }
    
    @IBAction func calStepperPreviousClick(sender: UIStepper)
    {
        var decodeString: String = "\(Int(calStepperPrevious.value))"
        
        updateDecodeValue("CalBeforeWeeks", decodeString)
       
        textBeforeCal.text = decodeString
    }
    
    @IBAction func CalStepperAfterClick(sender: UIStepper)
    {
        var decodeString: String = "\(Int(CalStepperAfter.value))"
        
        updateDecodeValue("CalAfterWeeks", decodeString)
        
        textAfterCal.text = decodeString
    }
    
    @IBAction func calStepperRedClick(sender: UIStepper)
    {
        var decodeString: String = "\(Int(calStepperRed.value))"
        
        updateDecodeValue("OmniRed", decodeString)
        
        textAfterDueDate.text = decodeString
    }
    
    @IBAction func CalStepperOrangeClick(sender: UIStepper)
    {
        var decodeString: String = "\(Int(CalStepperOrange.value))"
        
        updateDecodeValue("OmniOrange", decodeString)
        
        textBeforeDueDate.text = decodeString
    }
    
    @IBAction func CalStepperPurpleClick(sender: UIStepper)
    {
        var decodeString: String = "\(Int(CalStepperPurple.value))"
        
        updateDecodeValue("OmniPurple", decodeString)
        
        textSinceLastUpdate.text = decodeString
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
            
            createRole(textRole.text)
            myRoles = getRoles()
            roleTable.reloadData()
            textRole.text = ""
        }
    }
    
    @IBAction func deleteRoleClick(sender: UIButton)
    {
        if myRoleSelected < 0
        {
            var alert = UIAlertController(title: "Delete Role", message:
                "You need to select a role before you can delete it", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
        }
        else
        {
            // Delete the new role
            
            deleteRoleEntry(myRoles[myRoleSelected].roleDescription)
            
            myRoles = getRoles()
            roleTable.reloadData()
            
            myRoleSelected = -1
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
            
            createStage(textStage.text)
            myStages = getStages()
            stagesTable.reloadData()
            textStage.text = ""
        }
    }
    
    @IBAction func deleteStageClick(sender: UIButton)
    {
        if myStageSelected < 0
        {
            var alert = UIAlertController(title: "Delete Stage", message:
                "You need to select a stage before you can delete it", preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                handler: nil))
        }
        else
        {
            if myStages[myStageSelected].stageDescription == "Archived"
            {
                var alert = UIAlertController(title: "Delete Stage", message:
                    "You can not delete the Archived stage", preferredStyle: UIAlertControllerStyle.Alert)
                
                self.presentViewController(alert, animated: false, completion: nil)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                    handler: nil))
            }
            else
            {
                // Delete the new role
            
                deleteStageEntry(myStages[myStageSelected].stageDescription)
                
                myStages = getStages()
                stagesTable.reloadData()
            }
            myStageSelected = -1
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
    
    @IBAction func buttonMaintainPanesClick(sender: UIButton)
    {
        let maintainPaneViewControl = self.storyboard!.instantiateViewControllerWithIdentifier("MaintainPanes") as! MaintainPanesViewController
        
        maintainPaneViewControl.delegate = self
        maintainPaneViewControl.myManagedContext = myManagedContext
        
        self.presentViewController(maintainPaneViewControl, animated: true, completion: nil)
    }
    
    func MaintainPanesDidFinish(controller:MaintainPanesViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
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
                self.EvernoteAuthenticationDone = true
            })
        }
        
        EvernoteTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("myEvernoteAuthenticationDidFinish"), userInfo: nil, repeats: false)
        
        evernotePass1 = true  // This is to allow only one attempt to launch Evernote
    }
    
    func myEvernoteAuthenticationDidFinish()
    {
        if !EvernoteAuthenticationDone
        {  // Async not yet complete
            if EvernoteUserTimerCount > 5
            {
                var alert = UIAlertController(title: "Evernote", message:
                    "Unable to load Evernote in a timely manner", preferredStyle: UIAlertControllerStyle.Alert)
                
                self.presentViewController(alert, animated: false, completion: nil)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                    handler: nil))
            }
            else
            {
                EvernoteUserTimerCount = EvernoteUserTimerCount + 1
                EvernoteTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("myEvernoteAuthenticationDidFinish"), userInfo: nil, repeats: false)
            }
        }
                }
    
    func connectToDropbox()
    {
        if !dropboxCoreService.isAlreadyInitialised()
        {
            dropboxCoreService.initiateAuthentication(self)
        }
    }

    @IBAction func buttonConnectOneNoteClick(sender: UIButton)
    {
    }
    
    
    func configureLiveClientWithScopes()
    {
        //      if ([CLIENT_ID isEqualToString:@"%CLIENT_ID%"])
        //      {
        //          [NSException raise:NSInvalidArgumentException format:@"The CLIENT_ID value must be specified."];
        //      }
        
        
 //       liveClient =  LiveConnectClient(clientId: CLIENT_ID, scopes:OneNoteScopeText, delegate:self, userState: "init")
 
  /*
            - (id) initWithClientId:(NSString *)clientId
        scopes:(NSArray *)scopes
        delegate:(id<LiveAuthDelegate>)delegate
        userState:(id)userState;
        
        
     */
        
        //  self.liveClient = [[[LiveConnectClient alloc] initWithClientId:CLIENT_ID
        //      scopes:[scopeText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
        //      delegate:self
        //      userState:@"init"]
        //      autorelease ];
    }
    
    
    func authCompleted(status: LiveConnectSessionStatus, session: LiveConnectSession, userState: AnyObject)
    {
     //   OneNoteScopeText = session.scopes.componentsJoinedByString(" ")
 println("Onenote connected")
    }
 /*
    func authFailed(error: NSError)
    {
        println("OneNote auth failed")
    }
 */

    
}