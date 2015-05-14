//
//  settingsViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 12/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MySettingsDelegate{
    func mySettingsDidFinish(controller:settingsViewController)
}

class settingsViewController: UIViewController {
    
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
    
    var delegate: MySettingsDelegate?
    
    private var myRoles: [Roles]!
    private var myStages: [Stages]!
    private var myRoleSelected: Int = -1
    private var myStageSelected: Int = -1
    
    private let ROLE_CELL_IDENTIFER = "roleNameCell"
    private let STAGE_CELL_IDENTIFER = "stageNameCell"
    
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
}