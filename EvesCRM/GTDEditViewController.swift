//
//  GTDiewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 27/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation


class GTDEditViewController: UIViewController, UITextViewDelegate, SMTEFillDelegate
{
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLastReview: UILabel!
    @IBOutlet weak var lblFrquency: UILabel!
    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var txtFrequency: UITextField!
    @IBOutlet weak var btnLastReview: UIButton!
    @IBOutlet weak var btnPeriod: UIButton!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var btnTargetDate: UIButton!
    
    var inGTDObject: workingGTDItem!
    
    private var pickerOptions: [String] = Array()
    private var pickerTarget: String = ""
    private var selectedRow: Int = 0
    
    // Textexpander
    
    private var snippetExpanded: Bool = false
    
    var textExpander: SMTEDelegateController!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        txtNotes.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.cornerRadius = 5.0
        txtNotes.layer.masksToBounds = true
        txtNotes.delegate = self
        
        myPicker.hidden = true
        myDatePicker.hidden = true
        btnTargetDate.hidden = true
        
        txtTitle.text = inGTDObject.title
        txtNotes.text = inGTDObject.note
        txtFrequency.text = "\(inGTDObject.reviewFrequency)"
                
        if inGTDObject.displayLastReviewDate == ""
        {
            btnLastReview.setTitle("Set", forState: .Normal)
        }
        else
        {
            btnLastReview.setTitle(inGTDObject.displayLastReviewDate, forState: .Normal)
        }
                
        if inGTDObject.reviewPeriod == ""
        {
            btnPeriod.setTitle("Set", forState: .Normal)
        }
        else
        {
            btnPeriod.setTitle(inGTDObject.reviewPeriod, forState: .Normal)
        }
                
        if inGTDObject.status == ""
        {
            btnStatus.setTitle("Set", forState: .Normal)
        }
        else
        {
            btnStatus.setTitle(inGTDObject.status, forState: .Normal)
        }
        
        // TextExpander
        textExpander = SMTEDelegateController()
        txtTitle.delegate = textExpander
        txtNotes.delegate = textExpander
        textExpander.clientAppName = "EvesCRM"
        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
        textExpander.fillDelegate = self
        textExpander.nextDelegate = self
        myCurrentViewController = GTDEditViewController()
        myCurrentViewController = self
        
        showFields()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(TableTypeSelection1: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerOptions.count
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return pickerOptions[row]
    }
    
    func pickerView(TableTypeSelection1: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedRow = row
    }
    
    @IBAction func txtFrequency(sender: UITextField)
    {
        inGTDObject.reviewFrequency = Int(txtFrequency.text!)!
    }
    
    @IBAction func txtTitle(sender: UITextField)
    {
        inGTDObject.title = txtTitle.text!
    }
    
    func textViewDidEndEditing(textView: UITextView)
    { //Handle the text changes here
        inGTDObject.note = textView.text
    }
    
    @IBAction func btnLastReview(sender: UIButton)
    {
        btnTargetDate.setTitle("Set Last Reviewed Date", forState: .Normal)
        pickerTarget = "ReviewDate"
        myDatePicker.datePickerMode = UIDatePickerMode.Date
        btnTargetDate.hidden = false
        myDatePicker.hidden = false
        hideFields()
    }
    
    @IBAction func btnTargetDate(sender: UIButton)
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        if pickerTarget == "ReviewDate"
        {
            btnLastReview.setTitle(dateFormatter.stringFromDate(myDatePicker.date), forState: .Normal)
            
            inGTDObject.lastReviewDate = myDatePicker.date
        }
        
        if pickerTarget == "Status"
        {
            btnStatus.setTitle(pickerOptions[selectedRow], forState: .Normal)
            
            inGTDObject.status = pickerOptions[selectedRow]
        }
        
        if pickerTarget == "Period"
        {
            btnPeriod.setTitle(pickerOptions[selectedRow], forState: .Normal)
            
            inGTDObject.reviewPeriod = pickerOptions[selectedRow]
        }

        myPicker.hidden = true
        myDatePicker.hidden = true
        btnTargetDate.hidden = true
        
        showFields()
    }
    
    @IBAction func btnPeriod(sender: UIButton)
    {
        var selectedRow: Int = 0

        btnTargetDate.setTitle("Set Review period", forState: .Normal)
        btnTargetDate.hidden = false
        
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("")
        
        if inGTDObject.reviewPeriod == "Days"
        {
            selectedRow = 1
        }
        pickerOptions.append("Days")
        
        if inGTDObject.reviewPeriod == "Weeks"
        {
            selectedRow = 2
        }
        pickerOptions.append("Weeks")
        
        if inGTDObject.reviewPeriod == "Months"
        {
            selectedRow = 3
        }
        pickerOptions.append("Months")
        
        if inGTDObject.reviewPeriod == "Years"
        {
            selectedRow = 4
        }
        pickerOptions.append("Years")
        
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Period"
        myPicker.selectRow(selectedRow,inComponent: 0, animated: true)
    }
    
    @IBAction func btnStatus(sender: UIButton)
    {
        var selectedRow: Int = 0

        btnTargetDate.setTitle("Set Status", forState: .Normal)
        btnTargetDate.hidden = false
        
        pickerOptions.removeAll(keepCapacity: false)
        
        pickerOptions.append("")
        if inGTDObject.status == "Open"
        {
            selectedRow = 1
        }
        pickerOptions.append("Open")
        
        if inGTDObject.status == "Closed"
        {
            selectedRow = 2
        }
        pickerOptions.append("Closed")
        
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Status"
        myPicker.selectRow(selectedRow,inComponent: 0, animated: true)
    }
    
    func hideFields()
    {
        txtTitle.hidden = true
        lblStatus.hidden = true
        lblNotes.hidden = true
        txtNotes.hidden = true
        lblTitle.hidden = true
        lblLastReview.hidden = true
        lblFrquency.hidden = true
        lblPeriod.hidden = true
        txtFrequency.hidden = true
        btnLastReview.hidden = true
        btnPeriod.hidden = true
        btnStatus.hidden = true
    }
    
    func showFields()
    {
        txtTitle.hidden = false
        lblStatus.hidden = false
        lblNotes.hidden = false
        txtNotes.hidden = false
        lblTitle.hidden = false
        lblLastReview.hidden = false
        lblFrquency.hidden = false
        lblPeriod.hidden = false
        txtFrequency.hidden = false
        btnLastReview.hidden = false
        btnPeriod.hidden = false
        btnStatus.hidden = false
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
    
    func identifierForTextArea(uiTextObject: AnyObject) -> String
    {
        var result: String = ""
        
        if uiTextObject.isKindOfClass(UITextField)
        {
            if uiTextObject.tag == 1
            {
                result = "txtTitle"
            }
        }
        
        if uiTextObject.isKindOfClass(UITextView)
        {
            if uiTextObject.tag == 1
            {
                result = "txtNotes"
            }
        }
        
        if uiTextObject.isKindOfClass(UISearchBar)
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

    func prepareForFillSwitch(textIdentifier: String) -> Bool
    {
        // At this point the app should save state since TextExpander touch is about
        // to activate.
        // It especially needs to save the contents of the textview/textfield!
        
        inGTDObject.note = txtNotes.text
        inGTDObject.title = txtTitle.text!
        inGTDObject.reviewFrequency = Int(txtFrequency.text!)!

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
    
    func makeIdentifiedTextObjectFirstResponder(textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: UnsafeMutablePointer<Int>) -> AnyObject
    {
        snippetExpanded = true
        
        let intIoInsertionPointLocation:Int = ioInsertionPointLocation.memory // grab the data and cast it to a Swift Int8
        
        if "txtNotes" == textIdentifier
        {
            txtNotes.becomeFirstResponder()
            let theLoc = txtNotes.positionFromPosition(txtNotes.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtNotes.selectedTextRange = txtNotes.textRangeFromPosition(theLoc!, toPosition: theLoc!)
            }
            return txtNotes
        }
        else if "txtTitle" == textIdentifier
        {
            txtTitle.becomeFirstResponder()
            let theLoc = txtTitle.positionFromPosition(txtTitle.beginningOfDocument, offset: intIoInsertionPointLocation)
            if theLoc != nil
            {
                txtTitle.selectedTextRange = txtTitle.textRangeFromPosition(theLoc!, toPosition: theLoc!)
            }
            return txtTitle
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
            
            return ""
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
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
    
    func twiddleText(textView: UITextView)
    {
        let SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO = UIDevice.currentDevice().systemVersion
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO >= "7.0"
        {
            textView.textStorage.edited(NSTextStorageEditActions.EditedCharacters,range:NSMakeRange(0, textView.textStorage.length),changeInLength:0)
        }
    }
    
    func textViewDidChange(textView: UITextView)
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