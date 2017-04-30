//
//  settingsViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 12/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
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
    
    fileprivate var syncDate: NSDate!
    fileprivate var syncStart: NSDate!
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
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        

        
        notificationCenter.addObserver(self, selector: #selector(self.changeSettings(_:)), name: NotificationChangeSettings, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.syncToCloud), name: NotificationCloudSyncStart, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.syncToCloudDone), name: NotificationCloudSyncFinished, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.syncFromCloud), name: NotificationCloudReLoadStart, object: nil)
        
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
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if myDecodes[indexPath.row].decodeType == "stepper"
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseStepper", for: indexPath as IndexPath) as! mySettingStepper
                cell.lblKey.text = myDecodes[indexPath.row].decode_name
                cell.lblValue.text = myDecodes[indexPath.row].decode_value
                cell.myStepper.value = NSString(string: myDecodes[indexPath.row].decode_value!).doubleValue
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
  //      connectToEvernote()
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
            
            self.syncStart = NSDate()
            
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateStyle = DateFormatter.Style.short
                
            self.syncDate = myDateFormatter.date(from: "01/01/15")! as NSDate
            
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
        
            self.syncStart = NSDate()
        
            // Get the last sync date
        
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateStyle = DateFormatter.Style.short
        
            self.syncDate = myDateFormatter.date(from: "01/01/15")! as NSDate

            myDBSync.refreshRunning = true
            // Delete the entries from the current tables

            myDBSync.deleteAllFromCloudKit()
        
            // Load
        
            myDBSync.syncToCloudKit()
            myDBSync.refreshRunning = false
        })
    }
    
    func syncToCloudDone()
    {
        // Update last sync date
        
        let dateString = "\(syncStart)"
        
        myDatabaseConnection.updateDecodeValue("\(appName) Sync", codeValue: dateString, codeType: "hidden")
        
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
        myDatabaseConnection.updateDecodeValue(lblKey.text!, codeValue: "\(Int(myStepper.value))", codeType: lookupKey)
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
            myDatabaseConnection.updateDecodeValue(lblKey.text!, codeValue: txtValue.text!, codeType: lookupKey)
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
            myDatabaseConnection.updateDecodeValue(lblKey.text!, codeValue: txtValue.text!, codeType: lookupKey)
            notificationCenter.post(name: NotificationChangeSettings, object: nil, userInfo:["setting":"Decode"])
        }

    }
}

