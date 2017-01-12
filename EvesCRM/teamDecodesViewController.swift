//
//  teamDecodesViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 8/09/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation
import TextExpander

class teamDecodesViewController: UIViewController, SMTEFillDelegate
{
    @IBOutlet weak var lblRoles: UILabel!
    @IBOutlet weak var lblStages: UILabel!
    @IBOutlet weak var colRoles: UICollectionView!
    @IBOutlet weak var colStages: UICollectionView!
    @IBOutlet weak var txtRoles: UITextField!
    @IBOutlet weak var txtStage: UITextField!
    @IBOutlet weak var btnRole: UIButton!
    @IBOutlet weak var btnStage: UIButton!
    @IBOutlet weak var btnResetRoles: UIButton!
    @IBOutlet weak var btnResetStages: UIButton!
    
    fileprivate var myRoles: [Roles]!
    fileprivate var myStages: [Stages]!
    
    var myWorkingTeam: team!
    
    // Textexpander
    
    fileprivate var snippetExpanded: Bool = false
    
    var textExpander: SMTEDelegateController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Load the Roles
        myRoles = myWorkingTeam.roles
        
        // Load the Stages
        myStages = myWorkingTeam.stages
        
        // Load GTD
        
        notificationCenter.addObserver(self, selector: #selector(teamDecodesViewController.changeSettings(_:)), name: NotificationTeamDecodeChangeSettings, object: nil)
        
        // TextExpander
        textExpander = SMTEDelegateController()
        txtRoles.delegate = textExpander
        txtStage.delegate = textExpander
        textExpander.clientAppName = "EvesCRM"
        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
        textExpander.fillDelegate = self
        textExpander.nextDelegate = self
        myCurrentViewController = settingsViewController()
        myCurrentViewController = self
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        colRoles.collectionViewLayout.invalidateLayout()
        colRoles.reloadData()
        
        colStages.collectionViewLayout.invalidateLayout()
        colStages.reloadData()
    }
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == colRoles
        {
            return myRoles.count
        }
        else
        {
            return myStages.count
        }
    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, cellForItem indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == colRoles
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellRoles", for: indexPath as IndexPath) as! mySettingRoles
            cell.lblRole.text = myRoles[indexPath.row].roleDescription
            cell.teamID = myWorkingTeam.teamID
            
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellStages", for: indexPath as IndexPath) as! mySettingStages
            cell.lblRole.text  = myStages[indexPath.row].stageDescription
            cell.teamID = myWorkingTeam.teamID
            
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
        
        if collectionView == colRoles
        {
            retVal = CGSize(width: colRoles.bounds.size.width, height: 39)
        }
        else if collectionView == colStages
        {
            retVal = CGSize(width: colStages.bounds.size.width, height: 39)
        }
        
        return retVal
    }
    
    @IBAction func btnRole(_ sender: UIButton)
    {
        if txtRoles.text == ""
        {
            let alert = UIAlertController(title: "Add Role", message:
                "You need to enter a role name before you can add it", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                handler: nil))
            
            txtRoles.becomeFirstResponder()
        }
        else
        {
            // Add the new role
            
            myDatabaseConnection.saveRole(txtRoles.text!, teamID: myWorkingTeam.teamID)
            myWorkingTeam.loadRoles()
            myRoles = myWorkingTeam.roles
            colRoles.reloadData()
            txtRoles.text = ""
        }
    }
    
    @IBAction func btnStage(_ sender: UIButton)
    {
        if txtStage.text == ""
        {
            let alert = UIAlertController(title: "Add Stage", message:
                "You need to enter a stage name before you can add it", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                handler: nil))
            
            txtStage.becomeFirstResponder()
        }
        else
        {
            // Add the new role
            
            myDatabaseConnection.saveStage(txtStage.text!, teamID: myWorkingTeam.teamID)
            myWorkingTeam.loadStages()
            myStages = myWorkingTeam.stages
            colStages.reloadData()
            txtStage.text = ""
        }
    }
    
    @IBAction func buttonResetRolesClick(_ sender: UIButton)
    {
        myDatabaseConnection.deleteAllRoles(myWorkingTeam.teamID)
        populateRoles(myWorkingTeam.teamID)
        myWorkingTeam.loadRoles()
    
        myRoles = myWorkingTeam.roles
        colRoles.reloadData()
        txtRoles.text = ""
    }
    
    @IBAction func buttonResetStagesClick(_ sender: UIButton)
    {
        myDatabaseConnection.deleteAllStages(myWorkingTeam.teamID)
        populateStages(myWorkingTeam.teamID)
        myWorkingTeam.loadStages()
        myStages = myWorkingTeam.stages
        colStages.reloadData()
        txtStage.text = ""
    }
    
    func showFields()
    {
        lblRoles.isHidden = false
        lblStages.isHidden = false
        colRoles.isHidden = false
        colStages.isHidden = false
        txtRoles.isHidden = false
        txtStage.isHidden = false
        btnRole.isHidden = false
        btnStage.isHidden = false
        btnResetRoles.isHidden = false
        btnResetStages.isHidden = false
    }
    
    func hideFields()
    {
        lblRoles.isHidden = true
        lblStages.isHidden = true
        colRoles.isHidden = true
        colStages.isHidden = true
        txtRoles.isHidden = true
        txtStage.isHidden = true
        btnRole.isHidden = true
        btnStage.isHidden = true
        btnResetRoles.isHidden = true
        btnResetStages.isHidden = true
    }
    
    func changeSettings(_ notification: Notification)
    {
        let settingChanged = notification.userInfo!["setting"] as! String
        
        if settingChanged == "Role"
        {
            myWorkingTeam.loadRoles()
            myRoles = myWorkingTeam.roles
            colRoles.reloadData()
        }
        else if settingChanged == "Stage"
        {
            myWorkingTeam.loadStages()
            myStages = myWorkingTeam.stages
            colStages.reloadData()
        }
    }
    //---------------------------------------------------------------
    // These three methods implement the SMTEFillDelegate protocol to support fill-ins
    
    /* When an abbreviation for a snippet that looks like a fill-in snippet has been
    * typed, SMTEDelegateController will call your fill delegate's implementation of
    * this method.
    * Provide some kind of identifier for the given UITextView/UITextField/UISearchBar/UIWebView
    * The ID doesn't have to be fancy, "maintext" or "searchbar" will do.
    * Return nil to avoid the fill-in app-switching process (the snippet will be expanded
    * with "(field name)" where the fill fields are).
    *
    * Note that in the case of a UIWebView, the uiTextObject passed will actually be
    * an NSDictionary with two of these keys:
    *     - SMTEkWebView          The UIWebView object (key always present)
    *     - SMTEkElementID        The HTML element's id attribute (if found, preferred over Name)
    *     - SMTEkElementName      The HTML element's name attribute (if id not found and name found)
    * (If no id or name attribute is found, fill-in's cannot be supported, as there is
    * no way for TE to insert the filled-in text.)
    * Unless there is only one editable area in your web view, this implies that the returned
    * identifier string needs to include element id/name information. Eg. "webview-field2".
    */
    
    //func identifierForTextArea(_ uiTextObject: AnyObject) -> String
    func identifier(forTextArea uiTextObject: Any) -> String
    {
        var result: String = ""
        
        if uiTextObject is UITextField
        {
            if (uiTextObject as AnyObject).tag == 1
            {
                result = "txtRoles"
            }
            if (uiTextObject as AnyObject).tag == 2
            {
                result = "txtStage"
            }
        }
        
        if uiTextObject is UISearchBar
        {
            result =  "mySearchBar"
        }
        
        return result
    }
    
    /* Usually called milliseconds after identifierForTextArea:, SMTEDelegateController is
    * about to call [[UIApplication sharedApplication] openURL: "tetouch-xc: *x-callback-url/fillin?..."]
    * In other words, the TEtouch is about to be activated. Your app should save state
    * and make any other preparations.
    *
    * Return NO to cancel the process.
    */
    
    func prepare(forFillSwitch textIdentifier: String) -> Bool
    {
        // At this point the app should save state since TextExpander touch is about
        // to activate.
        // It especially needs to save the contents of the textview/textfield!
        
        return true
    }
    
    /* Restore active typing location and insertion cursor position to a text item
    * based on the identifier the fill delegate provided earlier.
    * (This call is made from handleFillCompletionURL: )
    *
    * In the case of a UIWebView, this method should build and return an NSDictionary
    * like the one sent to the fill delegate in identifierForTextArea: when the snippet
    * was triggered.
    * That is, you should make the UIWebView become first responder, then return an
    * NSDictionary with two of these keys:
    *     - SMTEkWebView          The UIWebView object (key must be present)
    *     - SMTEkElementID        The HTML element's id attribute (preferred over Name)
    *     - SMTEkElementName      The HTML element's name attribute (only if no id)
    * TE will use the same Javascripts that it uses to expand normal snippets to focus the appropriate
    * element and insert the filled text.
    *
    * Note 1: If your app is still loaded after returning from TEtouch's fill window,
    * probably no work needs to be done (the text item will still be the first
    * responder, and the insertion cursor position will still be the same).
    * Note 2: If the requested insertionPointLocation cannot be honored (ie. text has
    * been reset because of the app switching), then update it to whatever is reasonable.
    *
    * Return nil to cancel insertion of the fill-in text. Users will not expect a cancel
    * at this point unless userCanceledFill is set. Even in the cancel case, they will likely
    * expect the identified text object to become the first responder.
    */
    
    // func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
    public func makeIdentifiedTextObjectFirstResponder(_ textIdentifier: String!, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>!) -> Any!
    {
        snippetExpanded = true
        
        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.pointee
        
        if "txtRoles" == textIdentifier
        {
            txtRoles.becomeFirstResponder()
            let theLoc = txtRoles.position(from: txtRoles.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtRoles.selectedTextRange = txtRoles.textRange(from: theLoc!, to: theLoc!)
            }
            return txtRoles
        }
        else if "txtStage" == textIdentifier
        {
            txtStage.becomeFirstResponder()
            let theLoc = txtStage.position(from: txtStage.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtStage.selectedTextRange = txtStage.textRange(from: theLoc!, to: theLoc!)
            }
            return txtStage
        }

            //        else if "mySearchBar" == textIdentifier
            //        {
            //            searchBar.becomeFirstResponder()
            // Note: UISearchBar does not support cursor positioning.
            // Since we don't save search bar text as part of our state, if our app was unloaded while TE was
            // presenting the fill-in window, the search bar might now be empty to we should return
            // insertionPointLocation of 0.
            //            let searchTextLen = searchBar.text.length
            //            if searchTextLen < ioInsertionPointLocation
            //            {
            //                ioInsertionPointLocation = searchTextLen
            //            }
            //            return searchBar
            //        }
        else
        {
            
            //return nil
            
            return "" as AnyObject
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if (textExpander.isAttemptingToExpandText)
        {
            snippetExpanded = true
        }
        return true
    }
    
    // Workaround for what appears to be an iOS 7 bug which affects expansion of snippets
    // whose content is greater than one line. The UITextView fails to update its display
    // to show the full content. Try commenting this out and expanding "sig1" to see the issue.
    //
    // Given other oddities of UITextView on iOS 7, we had assumed this would be fixed along the way.
    // Instead, we'll have to work up an isolated case and file a bug. We don't want to bake this kind
    // of workaround into the SDK, so instead we provide an example here.
    // If you have a better workaround suggestion, we'd love to hear it.
    
    func twiddleText(_ textView: UITextView)
    {
        let SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO = UIDevice.current.systemVersion
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO >= "7.0"
        {
            textView.textStorage.edited(NSTextStorageEditActions.editedCharacters,range:NSMakeRange(0, textView.textStorage.length),changeInLength:0)
        }
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        if snippetExpanded
        {
            usleep(10000)
            twiddleText(textView)
            
            // performSelector(twiddleText:, withObject: textView, afterDelay:0.01)
            snippetExpanded = false
        }
    }
    
    /*
    // The following are the UITextViewDelegate methods; they simply write to the console log for demonstration purposes
    
    func textViewDidBeginEditing(textView: UITextView)
    {
    println("nextDelegate textViewDidBeginEditing")
    }
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
    println("nextDelegate textViewShouldBeginEditing")
    return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool
    {
    println("nextDelegate textViewShouldEndEditing")
    return true
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
    println("nextDelegate textViewDidEndEditing")
    }
    
    func textViewDidChangeSelection(textView: UITextView)
    {
    println("nextDelegate textViewDidChangeSelection")
    }
    
    // The following are the UITextFieldDelegate methods; they simply write to the console log for demonstration purposes
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldBeginEditing")
    return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
    println("nextDelegate textFieldDidBeginEditing")
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldEndEditing")
    return true
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
    println("nextDelegate textFieldDidEndEditing")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
    println("nextDelegate textField:shouldChangeCharactersInRange: \(NSStringFromRange(range)) Original=\(textField.text), replacement = \(string)")
    return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldClear")
    return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
    println("nextDelegate textFieldShouldReturn")
    return true
    }
    */
    
}

class mySettingRoles: UICollectionViewCell
{
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    var teamID: Int = 0
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnRemove(_ sender: UIButton)
    {
        myDatabaseConnection.deleteRoleEntry(lblRole.text!, inTeamID: teamID)
        notificationCenter.post(name: NotificationTeamDecodeChangeSettings, object: nil, userInfo:["setting":"Role"])
    }
}

class mySettingStages: UICollectionViewCell
{
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    var teamID: Int = 0
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnRemove(_ sender: UIButton)
    {
        myDatabaseConnection.deleteStageEntry(lblRole.text!, inTeamID: teamID)
        notificationCenter.post(name: NotificationTeamDecodeChangeSettings, object: nil, userInfo:["setting":"Stage"])
    }
}
