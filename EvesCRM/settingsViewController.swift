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
    func mySettingsDidFinish(_ controller:settingsViewController)
}

class settingsViewController: UIViewController
{
    @IBOutlet weak var buttonConnectEvernote: UIButton!
    @IBOutlet weak var ButtonConnectDropbox: UIButton!
    @IBOutlet weak var colDecodes: UICollectionView!
    @IBOutlet weak var btnSyncFromCloud: UIButton!
    @IBOutlet weak var btnSyncToCloud: UIButton!
    @IBOutlet weak var lblRefreshMessage: UILabel!
    
    var delegate: MySettingsDelegate?
    
    fileprivate var myDecodes: [Decodes]!
    
    fileprivate var evernotePass1: Bool = false
    fileprivate var EvernoteAuthenticationDone: Bool = false
    var evernoteSession: ENSession!
    fileprivate var myEvernote: EvernoteDetails!
//GRE    var dropboxCoreService: DropboxCoreService!
    
    fileprivate var syncDate: Date!
    fileprivate var syncStart: Date!
    fileprivate var firstLoadflag: Bool = true

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if firstLoadflag
        {
            firstLoad()
        }
    }
    
    func firstLoad()
    {
        lblRefreshMessage.isHidden = true
        
        // Load the decodes
        myDecodes = myDatabaseConnection.getVisibleDecodes()
        
        if evernoteSession.isAuthenticated
        {
            buttonConnectEvernote.isHidden = true
        }
        
//GRE        if dropboxCoreService.isAlreadyInitialised()
 //GRE       {
//GRE            ButtonConnectDropbox.isHidden = true
//GRE        }
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(settingsViewController.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(settingsViewController.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
        notificationCenter.addObserver(self, selector: #selector(settingsViewController.myEvernoteAuthenticationDidFinish), name: NotificationEvernoteAuthenticationDidFinish, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(settingsViewController.changeSettings(_:)), name: NotificationChangeSettings, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(settingsViewController.syncToCloud), name: NotificationCloudSyncStart, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(settingsViewController.syncToCloudDone), name: NotificationCloudSyncFinished, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(settingsViewController.syncFromCloud), name: NotificationCloudReLoadStart, object: nil)
        
        firstLoadflag = false
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
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.left
        {
            // Do nothing
        }
        else
        {
            delegate?.mySettingsDidFinish(self)
        }
    }

    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return myDecodes.count
    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, cellForItem indexPath: IndexPath) -> UICollectionViewCell
    {
        if myDecodes[indexPath.row].decodeType == "stepper"
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseStepper", for: indexPath as IndexPath) as! mySettingStepper
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
                    cell.backgroundColor = UIColor.clear
                }
                
                cell.layoutSubviews()
                return cell
            }
            else if myDecodes[indexPath.row].decodeType == "number"
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseNumber", for: indexPath as IndexPath) as! mySettingNumber
                cell.lblKey.text = myDecodes[indexPath.row].decode_name
                cell.txtValue.text = myDecodes[indexPath.row].decode_value
                cell.lookupKey = myDecodes[indexPath.row].decodeType
                
                if (indexPath.row % 2 == 0)  // was .row
                {
                    cell.backgroundColor = myRowColour
                }
                else
                {
                    cell.backgroundColor = UIColor.clear
                }
                
                cell.layoutSubviews()
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseString", for: indexPath as IndexPath) as! mySettingString
                cell.lblKey.text = myDecodes[indexPath.row].decode_name
                cell.txtValue.text = myDecodes[indexPath.row].decode_value
                cell.lookupKey = myDecodes[indexPath.row].decodeType
                
                if (indexPath.row % 2 == 0)  // was .row
                {
                    cell.backgroundColor = myRowColour
                }
                else
                {
                    cell.backgroundColor = UIColor.clear
                }
                
                cell.layoutSubviews()
                return cell
            }
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        retVal = CGSize(width: colDecodes.bounds.size.width, height: 39)

        return retVal
    }
    
    @IBAction func ButtonConnectDropboxClick(_ sender: UIButton)
    {
        connectToDropbox()
    }
    
    @IBAction func buttonConnectEvernoteClick(_ sender: UIButton)
    {
        connectToEvernote()
    }

    //Evernote
    
    func connectToEvernote()
    {
        // Authenticate to Evernote if needed
        
        if !evernotePass1
        {
            evernoteSession.authenticate (with: self, preferRegistration:false, completion: {
                (error: Error?) in
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
                notificationCenter.post(name: NotificationEvernoteAuthenticationDidFinish, object: nil)
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
 //GRE       if !dropboxCoreService.isAlreadyInitialised()
  //GRE      {
   //GRE         dropboxCoreService.initiateAuthentication(self)
 //GRE       }
    }
        
    func changeSettings(_ notification: Notification)
    {
        myDecodes = myDatabaseConnection.getVisibleDecodes()
        colDecodes.reloadData()
    }
    
    @IBAction func btnSyncFromCloud(_ sender: UIButton)
    {
        // Display message that may take some time
        lblRefreshMessage.isHidden = false
        colDecodes.isHidden = true
        btnSyncFromCloud.isHidden = true
        btnSyncToCloud.isHidden = true
        
        notificationCenter.post(name: NotificationCloudReLoadStart, object: nil)
    }
    
    func syncFromCloud()
    {
        let qualityOfServiceClass = DispatchQoS.QoSClass.userInitiated
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            self.syncStart = Date()
            
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateStyle = DateFormatter.Style.short
                
            self.syncDate = myDateFormatter.date(from: "01/01/15")
            
            myDBSync.refreshRunning = true
            // Delete the entries from the current tables
            
            myDBSync.deleteAllFromCoreData()
            // Load
            
            myDBSync.replaceWithCloudKit()
            myDBSync.refreshRunning = false
        })
    }
    
    @IBAction func btnSyncToCloud(_ sender: UIButton)
    {
        // Display message that may take some time
        
        lblRefreshMessage.isHidden = false
        colDecodes.isHidden = true
        btnSyncFromCloud.isHidden = true
        btnSyncToCloud.isHidden = true
        
        notificationCenter.post(name: NotificationCloudSyncStart, object: nil)
    }
    
    func syncToCloud()
    {
        let qualityOfServiceClass = DispatchQoS.QoSClass.userInitiated
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
        
            self.syncStart = Date()
        
            // Get the last sync date
        
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateStyle = DateFormatter.Style.short
        
            self.syncDate = myDateFormatter.date(from: "01/01/15")

            myDBSync.refreshRunning = true
            // Delete the entries from the current tables

            myDBSync.deleteAllFromCloudKit()
        
            // Load
        
            myDBSync.syncToCloudKit(self.syncDate)
            myDBSync.refreshRunning = false
        })
    }
    
    func syncToCloudDone()
    {
        // Update last sync date
        
        let dateString = "\(syncStart)"
        
        myDatabaseConnection.updateDecodeValue("CloudKit Sync", inCodeValue: dateString, inCodeType: "hidden")
        
        lblRefreshMessage.isHidden = true
        colDecodes.isHidden = false
        btnSyncFromCloud.isHidden = false
        btnSyncToCloud.isHidden = false
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
    
    @IBAction func myStepper(_ sender: UIStepper)
    {
        myDatabaseConnection.updateDecodeValue(lblKey.text!, inCodeValue: "\(Int(myStepper.value))", inCodeType: lookupKey)
        lblValue.text = "\(myStepper.value)"
        notificationCenter.post(name: NotificationChangeSettings, object: nil, userInfo:["setting":"Decode"])
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
    
    @IBAction func txtValue(_ sender: UITextField)
    {
        if txtValue.text == ""
        {
            // Do nothing as can not have blannk string
        }
        else
        {
            myDatabaseConnection.updateDecodeValue(lblKey.text!, inCodeValue: txtValue.text!, inCodeType: lookupKey)
            notificationCenter.post(name: NotificationChangeSettings, object: nil, userInfo:["setting":"Decode"])
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
    
    @IBAction func txtValue(_ sender: UITextField)
    {
        if txtValue.text == ""
        {
            // Do nothing as can not have blannk string
        }
        else
        {
            myDatabaseConnection.updateDecodeValue(lblKey.text!, inCodeValue: txtValue.text!, inCodeType: lookupKey)
            notificationCenter.post(name: NotificationChangeSettings, object: nil, userInfo:["setting":"Decode"])
        }

    }
}

