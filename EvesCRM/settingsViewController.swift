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
    @IBOutlet weak var buttonConnectEvernote: UIButton!
    @IBOutlet weak var ButtonConnectDropbox: UIButton!
    @IBOutlet weak var colDecodes: UICollectionView!
    
    var delegate: MySettingsDelegate?
    
    private var myDecodes: [Decodes]!
    
    private var evernotePass1: Bool = false
    private var EvernoteAuthenticationDone: Bool = false
    var evernoteSession: ENSession!
    private var myEvernote: EvernoteDetails!
    var dropboxCoreService: DropboxCoreService!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
   
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        colDecodes.collectionViewLayout.invalidateLayout()
        colDecodes.reloadData()
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
        return myDecodes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
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
                    cell.backgroundColor = myRowColour
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
                    cell.backgroundColor = myRowColour
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
                    cell.backgroundColor = myRowColour
                }
                else
                {
                    cell.backgroundColor = UIColor.clearColor()
                }
                
                cell.layoutSubviews()
                return cell
            }
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colDecodes.bounds.size.width, height: 39)

        return retVal
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
        print("Evernote authenticated")
    }
    
    func connectToDropbox()
    {
        if !dropboxCoreService.isAlreadyInitialised()
        {
            dropboxCoreService.initiateAuthentication(self)
        }
    }
        
    func changeSettings(notification: NSNotification)
    {
        myDecodes = myDatabaseConnection.getVisibleDecodes()
        colDecodes.reloadData()
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
        myDatabaseConnection.updateDecodeValue(lblKey.text!, inCodeValue: "\(Int(myStepper.value))", inCodeType: lookupKey)
        lblValue.text = "\(myStepper.value)"
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationChangeSettings", object: nil, userInfo:["setting":"Decode"])
    }
}

class mySettingString: UICollectionViewCell
{
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var txtValue: UITextField!
    var lookupKey: String!

    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func txtValue(sender: UITextField)
    {
        if txtValue == ""
        {
            // Do nothing as can not have blannk string
        }
        else
        {
            myDatabaseConnection.updateDecodeValue(lblKey.text!, inCodeValue: txtValue.text!, inCodeType: lookupKey)
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationChangeSettings", object: nil, userInfo:["setting":"Decode"])
        }
    }
}

class mySettingNumber: UICollectionViewCell
{
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var txtValue: UITextField!
    var lookupKey: String!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func txtValue(sender: UITextField)
    {
        if txtValue == ""
        {
            // Do nothing as can not have blannk string
        }
        else
        {
            myDatabaseConnection.updateDecodeValue(lblKey.text!, inCodeValue: txtValue.text!, inCodeType: lookupKey)
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationChangeSettings", object: nil, userInfo:["setting":"Decode"])
        }

    }
}

