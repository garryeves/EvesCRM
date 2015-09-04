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
    
    var inAreaObject: areaOfResponsibility!
    var inGoalObject: goalAndObjective!
    var inPurposeObject: purposeAndCoreValue!
    var inVisionObject: gvision!
    
    var objectType: String = ""
    
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
        
        switch objectType
        {
            case "purpose":
                txtTitle.text = inPurposeObject.title
                txtNotes.text = inPurposeObject.note
                txtFrequency.text = "\(inPurposeObject.reviewFrequency)"
                
                if inPurposeObject.displayLastReviewDate == ""
                {
                    btnLastReview.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnLastReview.setTitle(inPurposeObject.displayLastReviewDate, forState: .Normal)
                }
                
                if inPurposeObject.reviewPeriod == ""
                {
                    btnPeriod.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnPeriod.setTitle(inPurposeObject.reviewPeriod, forState: .Normal)
                }
                
                if inPurposeObject.status == ""
                {
                    btnStatus.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnStatus.setTitle(inPurposeObject.status, forState: .Normal)
                }
                
            case "vision":
                txtTitle.text = inVisionObject.title
                txtNotes.text = inVisionObject.note
                txtFrequency.text = "\(inVisionObject.reviewFrequency)"
                if inVisionObject.displayLastReviewDate == ""
                {
                    btnLastReview.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnLastReview.setTitle(inVisionObject.displayLastReviewDate, forState: .Normal)
                }
                
                if inVisionObject.reviewPeriod == ""
                {
                    btnPeriod.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnPeriod.setTitle(inVisionObject.reviewPeriod, forState: .Normal)
                }
                
                if inVisionObject.status == ""
                {
                    btnStatus.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnStatus.setTitle(inVisionObject.status, forState: .Normal)
                }

            
            case "goal":
                txtTitle.text = inGoalObject.title
                txtNotes.text = inGoalObject.note
                txtFrequency.text = "\(inGoalObject.reviewFrequency)"
                if inGoalObject.displayLastReviewDate == ""
                {
                    btnLastReview.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnLastReview.setTitle(inGoalObject.displayLastReviewDate, forState: .Normal)
                }
                
                if inGoalObject.reviewPeriod == ""
                {
                    btnPeriod.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnPeriod.setTitle(inGoalObject.reviewPeriod, forState: .Normal)
                }
                
                if inGoalObject.status == ""
                {
                    btnStatus.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnStatus.setTitle(inGoalObject.status, forState: .Normal)
                }

            
            case "area":
                txtTitle.text = inAreaObject.title
                txtNotes.text = inAreaObject.note
                txtFrequency.text = "\(inAreaObject.reviewFrequency)"
                if inAreaObject.displayLastReviewDate == ""
                {
                    btnLastReview.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnLastReview.setTitle(inAreaObject.displayLastReviewDate, forState: .Normal)
                }
                
                if inAreaObject.reviewPeriod == ""
                {
                    btnPeriod.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnPeriod.setTitle(inAreaObject.reviewPeriod, forState: .Normal)
                }
                
                if inAreaObject.status == ""
                {
                    btnStatus.setTitle("Set", forState: .Normal)
                }
                else
                {
                    btnStatus.setTitle(inAreaObject.status, forState: .Normal)
                }

            default:
                print("GTDEditViewController: viewDidLoad: No objectType found")
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
    
 /*
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Which item is the current first responder, as will need to save it if it is a text field
        
        switch objectType
        {
        case "purpose":
            inPurposeObject.save()
            
        case "vision":
            inVisionObject.save()
            
        case "goal":
            inGoalObject.save()
            
        case "area":
            inAreaObject.save()
            
        default:
            println("GTDEditViewController: viewWillDisappear:  No objectType found")
        }

    }
*/    
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
        switch objectType
        {
            case "purpose":
                inPurposeObject.reviewFrequency = Int(txtFrequency.text!)!
            
            case "vision":
                inVisionObject.reviewFrequency = Int(txtFrequency.text!)!
            
            case "goal":
                inGoalObject.reviewFrequency = Int(txtFrequency.text!)!
            
            case "area":
                inAreaObject.reviewFrequency = Int(txtFrequency.text!)!
            
            default:
                print("GTDEditViewController: txtFrequency:  No objectType found")
        }
    }
    
    @IBAction func txtTitle(sender: UITextField)
    {
        switch objectType
        {
            case "purpose":
                inPurposeObject.title = txtTitle.text!
            
            case "vision":
                inVisionObject.title = txtTitle.text!
            
            case "goal":
                inGoalObject.title = txtTitle.text!
            
            case "area":
                inAreaObject.title = txtTitle.text!
            
            default:
                print("GTDEditViewController: txtTitle:  No objectType found")
        }
    }
    
    func textViewDidEndEditing(textView: UITextView)
    { //Handle the text changes here
        
        switch objectType
        {
            case "purpose":
                inPurposeObject.note = textView.text
            
            case "vision":
                inVisionObject.note = textView.text
            
            case "goal":
                inGoalObject.note = textView.text
            
            case "area":
                inAreaObject.note = textView.text
            
            default:
                print("GTDEditViewController: textViewDidEndEditing:  No objectType found")
        }
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
            
            switch objectType
            {
                case "purpose":
                    inPurposeObject.lastReviewDate = myDatePicker.date
                
                case "vision":
                    inVisionObject.lastReviewDate = myDatePicker.date
                
                case "goal":
                    inGoalObject.lastReviewDate = myDatePicker.date
                
                case "area":
                    inAreaObject.lastReviewDate = myDatePicker.date
                
                default:
                    print("GTDEditViewController: btnTargetDate:  No objectType found")
            }
        }
        
        if pickerTarget == "Status"
        {
            btnStatus.setTitle(pickerOptions[selectedRow], forState: .Normal)
            
            switch objectType
            {
            case "purpose":
                inPurposeObject.status = pickerOptions[selectedRow]
                
            case "vision":
                inVisionObject.status = pickerOptions[selectedRow]
                
            case "goal":
                inGoalObject.status = pickerOptions[selectedRow]
                
            case "area":
                inAreaObject.status = pickerOptions[selectedRow]
                
            default:
                print("GTDEditViewController: pickerView: Status:  No objectType found")
            }
        }
        
        if pickerTarget == "Period"
        {
            btnPeriod.setTitle(pickerOptions[selectedRow], forState: .Normal)
            
            switch objectType
            {
            case "purpose":
                inPurposeObject.reviewPeriod = pickerOptions[selectedRow]
                
            case "vision":
                inVisionObject.reviewPeriod = pickerOptions[selectedRow]
                
            case "goal":
                inGoalObject.reviewPeriod = pickerOptions[selectedRow]
                
            case "area":
                inAreaObject.reviewPeriod = pickerOptions[selectedRow]
                
            default:
                print("GTDEditViewController: pickerView: Period:  No objectType found")
            }
        }

        myPicker.hidden = true
        myDatePicker.hidden = true
        btnTargetDate.hidden = true
        
        showFields()
    }
    
    @IBAction func btnPeriod(sender: UIButton)
    {
        btnTargetDate.setTitle("Set Review period", forState: .Normal)
        btnTargetDate.hidden = false
        
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("")
        pickerOptions.append("Days")
        pickerOptions.append("Weeks")
        pickerOptions.append("Months")
        pickerOptions.append("Years")
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Period"
        myPicker.selectRow(0,inComponent: 0, animated: true)
    }
    
    @IBAction func btnStatus(sender: UIButton)
    {
        btnTargetDate.setTitle("Set Status", forState: .Normal)
        btnTargetDate.hidden = false
        
        pickerOptions.removeAll(keepCapacity: false)
        pickerOptions.append("")
        pickerOptions.append("Open")
        pickerOptions.append("Closed")
        hideFields()
        myPicker.hidden = false
        myPicker.reloadAllComponents()
        pickerTarget = "Status"
        myPicker.selectRow(0,inComponent: 0, animated: true)
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
        
        switch objectType
        {
            case "purpose":
                inPurposeObject.note = txtNotes.text
                inPurposeObject.title = txtTitle.text!
                inPurposeObject.reviewFrequency = Int(txtFrequency.text!)!
            
            case "vision":
                inVisionObject.note = txtNotes.text
                inVisionObject.title = txtTitle.text!
                inVisionObject.reviewFrequency = Int(txtFrequency.text!)!
            
            case "goal":
                inGoalObject.note = txtNotes.text
                inGoalObject.title = txtTitle.text!
                inGoalObject.reviewFrequency = Int(txtFrequency.text!)!
            
            case "area":
                inGoalObject.note = txtNotes.text
                inGoalObject.title = txtTitle.text!
                inGoalObject.reviewFrequency = Int(txtFrequency.text!)!
            
            default:
                print("GTDEditViewController: prepareForFillSwitch:  No objectType found")
        }
        
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