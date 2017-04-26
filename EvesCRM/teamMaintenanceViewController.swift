//
//  teamMaintenanceViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 7/09/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation
import TextExpander

class teamMaintenanceViewController: UIViewController, SMTEFillDelegate, KDRearrangeableCollectionViewDelegate
{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var lblHierarchy: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var colHierarchy: UICollectionView!
    @IBOutlet weak var txtHierarchy: UITextField!
    @IBOutlet weak var btnHierarchy: UIButton!
    @IBOutlet weak var btnSetStatus: UIButton!
    @IBOutlet weak var myPickerView: UIPickerView!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblContext: UILabel!
    @IBOutlet weak var colContext: UICollectionView!
    
    fileprivate var myGTDHierarchy: [workingGTDLevel] = Array()
    fileprivate var myDisplayHierarchy: [String] = Array()
    fileprivate var myContext: [context] = Array()
    
    var myWorkingTeam: team!
    
    fileprivate var pickerDisplayArray: [String] = Array()
    fileprivate var mySelectedRow: Int = -1
    
    // Textexpander
    
    fileprivate var snippetExpanded: Bool = false
    
    var textExpander: SMTEDelegateController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()// Load GTD
        
        loadContexts()
        
        loadHierarchy()
        
        txtName.text = myWorkingTeam.name
        
        if myWorkingTeam.status == ""
        {
            btnStatus.setTitle("Select Status", for: .normal)
        }
        else
        {
            btnStatus.setTitle(myWorkingTeam.status, for: .normal)
        }
        txtNotes.text = myWorkingTeam.note
        
        myPickerView.isHidden = true
        btnSetStatus.isHidden = true
        
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        
        notificationCenter.addObserver(self, selector: #selector(teamMaintenanceViewController.changeSettings(_:)), name: NotificationChangeSettings, object: nil)
        
        // TextExpander
        textExpander = SMTEDelegateController()
        txtName.delegate = textExpander
        txtNotes.delegate = textExpander
        txtHierarchy.delegate = textExpander
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
        
        colContext.collectionViewLayout.invalidateLayout()
        colContext.reloadData()
        
        colHierarchy.collectionViewLayout.invalidateLayout()
        colHierarchy.reloadData()
    }
    
    func numberOfComponentsInPickerView(_ inPicker: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ inPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerDisplayArray.count
    }
    
    func pickerView(_ inPicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return pickerDisplayArray[row]
    }
    
    func pickerView(_ inPicker: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        mySelectedRow = row
    }
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == colContext
        {
            return myContext.count
        }
        else
        {
            return myDisplayHierarchy.count
        }
    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == colContext
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellContext", for: indexPath as IndexPath) as! mySettingContext
            cell.lblRole.text = myContext[indexPath.row].name
            
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
        {  // colHierarchy
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellHierarchy", for: indexPath as IndexPath) as! mySettingHierarchy
            cell.lblName.text  = myDisplayHierarchy[indexPath.row]
            
            if myDisplayHierarchy[indexPath.row] == "Activity" || myDisplayHierarchy[indexPath.row] == "Action"
            {
                cell.btnRemove.isHidden = true
                cell.btnRename.isHidden = true
            }
            else
            {
                cell.btnRemove.isHidden = false
                cell.btnRename.isHidden = false
                cell.myGTDLevel = myGTDHierarchy[indexPath.row]
            }
            
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
        
        if collectionView == colContext
        {
            retVal = CGSize(width: colContext.bounds.size.width, height: 39)
        }
        else
        {
            retVal = CGSize(width: colHierarchy.bounds.size.width, height: 39)
        }
        
        return retVal
    }
    
    // Start move
    
    func moveDataItem(_ toIndexPath : IndexPath, fromIndexPath: IndexPath) -> Void
    {
        if fromIndexPath.item > myGTDHierarchy.count
        {
            NSLog("Do nothing, outside of rearrange")
        }
        else
        {
         //   let name = myDisplayHierarchy[fromIndexPath.item]
        //    let myObject = myGTDHierarchy[fromIndexPath.item]
        
            // We now need to update the underlying database tables

            myGTDHierarchy[fromIndexPath.item].moveLevel(Int32(toIndexPath.item + 1))
            
            loadHierarchy()
            for myItem in myGTDHierarchy
            {
                NSLog("Name = \(myItem.title) Level = \(myItem.GTDLevel)")
            }
            
            colHierarchy.reloadData()
            
        //    myDisplayHierarchy.removeAtIndex(fromIndexPath.item)
        //    myDisplayHierarchy.insert(name, atIndex: toIndexPath.item)
        //    myGTDHierarchy.removeAtIndex(fromIndexPath.item)
        //    myGTDHierarchy.insert(myObject, atIndex: toIndexPath.item)
        }
    }
    
    // End move
    
    @IBAction func txtName(_ sender: UITextField)
    {
        myWorkingTeam.name = txtName.text!
    }
    
    @IBAction func btnStatus(_ sender: UIButton)
    {
        pickerDisplayArray.removeAll()
        pickerDisplayArray.append("")
        pickerDisplayArray.append("Open")
        pickerDisplayArray.append("Closed")

        btnSetStatus.setTitle("Select Status", for: .normal)
        myPickerView.reloadAllComponents()
        myPickerView.isHidden = false
        btnSetStatus.isHidden = false
        mySelectedRow = -1
        hideFields()
    }
    
    @IBAction func btnSetStatus(_ sender: UIButton)
    {
        myWorkingTeam.status = pickerDisplayArray[mySelectedRow]
        btnStatus.setTitle(myWorkingTeam.status, for: UIControlState.normal)

        myPickerView.isHidden = true
        btnSetStatus.isHidden = true
        showFields()
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    { //Handle the text changes here
        if textView == txtNotes
        {
            myWorkingTeam.note = textView.text
        }
    }
    
    @IBAction func btnHierarchy(_ sender: UIButton)
    {
        if txtHierarchy.text == ""
        {
            let alert = UIAlertController(title: "Add Hierarchy", message:
                "You need to enter a hierarchy name before you can add it", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: false, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                handler: nil))
            
            txtHierarchy.becomeFirstResponder()
        }
        else
        {
            _ = workingGTDLevel(inLevelName: txtHierarchy.text!, inTeamID: myWorkingTeam.teamID)
            myWorkingTeam.loadGTDLevels()
            loadHierarchy()
            colHierarchy.reloadData()
            txtHierarchy.text = ""
        }
    }
    
    func loadContexts()
    {
        myContext.removeAll()
        for myItem in myDatabaseConnection.getContexts(myWorkingTeam.teamID)
        {
            let tempContext = context(inContext: myItem)
            myContext.append(tempContext)
        }
    }
    
    func loadHierarchy()
    {
        myGTDHierarchy.removeAll()
        myDisplayHierarchy.removeAll()
        
        myWorkingTeam.loadGTDLevels()
        for myItem in myWorkingTeam.GTDLevels
        {
            myGTDHierarchy.append(myItem)
            myDisplayHierarchy.append(myItem.title)
        }
        myDisplayHierarchy.append("Activity")
        myDisplayHierarchy.append("Action")
    }
    
    func showFields()
    {
        lblName.isHidden = false
        lblStatus.isHidden = false
        lblNotes.isHidden = false
        lblHierarchy.isHidden = false
        txtName.isHidden = false
        txtNotes.isHidden = false
        colHierarchy.isHidden = false
        txtHierarchy.isHidden = false
        btnHierarchy.isHidden = false
        btnStatus.isHidden = false
        lblContext.isHidden = false
        colContext.isHidden = false
    }
    
    func hideFields()
    {
        lblName.isHidden = true
        lblStatus.isHidden = true
        lblNotes.isHidden = true
        lblHierarchy.isHidden = true
        txtName.isHidden = true
        txtNotes.isHidden = true
        colHierarchy.isHidden = true
        txtHierarchy.isHidden = true
        btnHierarchy.isHidden = true
        btnStatus.isHidden = true
        lblContext.isHidden = true
        colContext.isHidden = true
    }
    
    func changeSettings(_ notification: Notification)
    {
        let settingChanged = notification.userInfo!["setting"] as! String
        let workingItem = notification.userInfo!["Item"] as! workingGTDLevel
        
        if settingChanged == "Context"
        {
            loadContexts()
            colContext.reloadData()
        }
        else if settingChanged == "HierarchyDelete"
        {
            let deleteAlert = UIAlertController(title: "Delete Hierarchy", message: "Please confirm, if you delete this then any items associated with it will be lost", preferredStyle: UIAlertControllerStyle.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                workingItem.delete()
                self.myWorkingTeam.loadGTDLevels()
                self.loadHierarchy()
                self.colHierarchy.reloadData()

            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                NSLog("Do nothing")
            }))
            
            present(deleteAlert, animated: true, completion: nil)
        }
        else
        { // Hierarchy change
            
            //1. Create the alert controller.
            let newNameAlert = UIAlertController(title: "Hierarchy Rename", message: "Enter new name for Hierarchy Level", preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            newNameAlert.addTextField(configurationHandler: { (textField) -> Void in
                textField.text = workingItem.title
            })
            
            //3. Grab the value from the text field, and print it when the user clicks OK.
            newNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                let textField = newNameAlert.textFields![0] as UITextField
                workingItem.title = textField.text!
                self.myWorkingTeam.loadGTDLevels()
                self.loadHierarchy()
                self.colHierarchy.reloadData()
            }))
            
            // 4. Present the alert.
            self.present(newNameAlert, animated: true, completion: nil)
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
                result = "txtRole"
            }
            if (uiTextObject as AnyObject).tag == 2
            {
                result = "txtStage"
            }
        }
        
        if uiTextObject is UITextView
        {
            if (uiTextObject as AnyObject).tag == 1
            {
                result = "txtNotes"
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
        
        if "txtNotes" == textIdentifier
        {
            txtNotes.becomeFirstResponder()
            let theLoc = txtNotes.position(from: txtNotes.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtNotes.selectedTextRange = txtNotes.textRange(from: theLoc!, to: theLoc!)
            }
            return txtNotes
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

class mySettingContext: UICollectionViewCell
{
    @IBOutlet weak var lblRole: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class KDRearrangeableSettingHierarchy: UICollectionViewCell
{

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    
    @IBOutlet weak var btnRename: UIButton!
    
    var myGTDLevel: workingGTDLevel!
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    var dragging : Bool = false
    {
        didSet
        {
            
        }
        
    }
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    @IBAction func btnRemove(_ sender: UIButton)
    {
        notificationCenter.post(name: NotificationChangeSettings, object: nil, userInfo:["setting":"HierarchyDelete", "Item": myGTDLevel])
    }

    @IBAction func btnRename(_ sender: UIButton)
    {
        notificationCenter.post(name: NotificationChangeSettings, object: nil, userInfo:["setting":"HierarchyUpdate", "Item": myGTDLevel])
    }
}

class mySettingHierarchy: KDRearrangeableSettingHierarchy
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //  self.layer.cornerRadius = self.frame.size.width * 0.5
        self.clipsToBounds = true
    }
}
    
