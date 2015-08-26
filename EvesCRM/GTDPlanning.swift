//
//  GTDPlanning.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 26/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

class MaintainGTDPlanningViewController: UIViewController
{
    private var passedGTD: GTDModel!
    
    // Textexpander
    
    private var snippetExpanded: Bool = false
    
    let myImageWidth = 200
    let myImageHeight = 100
    
    var textExpander: SMTEDelegateController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        passedGTD = (tabBarController as! GTDPlanningTabViewController).myPassedGTD
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideGestureRecognizer)
        
        
        // TextExpander
        textExpander = SMTEDelegateController()
 //       projectNameText.delegate = textExpander
        textExpander.clientAppName = "EvesCRM"
        textExpander.fillCompletionScheme = "EvesCRM-fill-xc"
        textExpander.fillDelegate = self
        textExpander.nextDelegate = self
        myCurrentViewController = MaintainProjectViewController()
        myCurrentViewController = self
        
        var myX: Int = 0
        var myY: Int = 20
        var tempTextView: UITextView!
        
        tempTextView = displayEntry("My Life", xPos: myX, yPos: myY, rectWidth: myImageWidth, rectHeight: myImageHeight)
        
        myX += myImageWidth + 40
        
        tempTextView = displayEntry("Another life", xPos: myX, yPos: myY, rectWidth: myImageWidth, rectHeight: myImageHeight)
        
        myX += myImageWidth + 40
        
        tempTextView = displayEntry("A longer piece of text to see what happens to it when it is too long.  A longer piece of text to see what happens to it when it is too long.", xPos: myX, yPos: myY, rectWidth: myImageWidth, rectHeight: myImageHeight)
        
        myX += myImageWidth + 40
        
        tempTextView = displayEntry("fred", xPos: myX, yPos: myY, rectWidth: myImageWidth, rectHeight: myImageHeight)
        
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
 //       projectNameText.endEditing(true)
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
    {
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left
        {
            // Do nothing
        }
        else
        {
            passedGTD.delegate.myGTDPlanningDidFinish(self)
        }
    }
    
    func displayEntry(inString: String, xPos: Int, yPos: Int, rectWidth: Int, rectHeight: Int) -> UITextView
    {
        var txtField: UITextView = UITextView(frame: CGRect(x: xPos, y: yPos, width: rectWidth, height: rectHeight))
        
        txtField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        txtField.text = inString
        txtField.layer.borderColor = UIColor.blackColor().CGColor
        txtField.layer.borderWidth = 0.5
        txtField.textAlignment = NSTextAlignment.Center
 
 //       txtField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
     //   txtField.verticalAlignment = UIControlContentVerticalAlignment.Center
        
   //     let size = txtField.sizeThatFits(CGSizeMake(CGRectGetWidth(txtField.bounds), CGFloat(MAXFLOAT)))
        
   //     var topoffset = txtField.bounds.size.height - size.height
   //     topoffset = topoffset < 0.0 ? 0.0 : topoffset / 2
        
   //     txtField.contentOffset = CGPointMake(0, -topoffset)
        
        
 //       var topCorrect : CGFloat = (txtField.frame.height - txtField.contentSize.height);
  //      topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect / 2
  //      txtField.contentOffset = CGPoint(x: 0, y: -topCorrect)
        
        self.view.addSubview(txtField)
        
        return txtField
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
                result = "projectNameText"
            }
        }
        
        if uiTextObject.isKindOfClass(UITextView)
        {
            if uiTextObject.tag == 1
            {
                result = "unused"
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
    
    func makeIdentifiedTextObjectFirstResponder(textIdentifier: String, fillWasCanceled userCanceledFill: Bool, cursorPosition ioInsertionPointLocation: Int) -> AnyObject
    {
        snippetExpanded = true
        
        if "projectNameText" == textIdentifier
        {
 //           projectNameText.becomeFirstResponder()
 //           let theLoc = projectNameText.positionFromPosition(projectNameText.beginningOfDocument, offset: ioInsertionPointLocation)
 //           if theLoc != nil
 //           {
 //               projectNameText.selectedTextRange = projectNameText.textRangeFromPosition(theLoc, toPosition: theLoc)
 //           }
 //           return projectNameText
            return ""
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