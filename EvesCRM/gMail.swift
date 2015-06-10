//
//  gMail.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 9/06/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation


class gmailMessage: NSObject
{
    private var mySubject: String = ""
    
    var subject: String
    {
        get
        {
            return mySubject
        }
        set
        {
            mySubject = newValue
        }
    }
}

class gmailMessages: NSObject
{
    private var myMessages: [gmailMessage] = []
    private var mySourceViewController: UIViewController!
    private var myGmailData: gmailData!
    
    var messages: [gmailMessage]
        {
        get
        {
            return myMessages
        }
    }
    
    init(inViewController: UIViewController)
    {
        super.init()
        mySourceViewController = inViewController
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gmailConnected:", name:"NotificationGmailConnected", object: nil)
println("In gmailMessages init")
        if myGmailData != nil
        {
println("In gmailMessages not nil")
            if !myGmailData.connected
            {
println("In gmailMessages not connected")
                myGmailData = gmailData()
                myGmailData.sourceViewController = inViewController
                myGmailData.connectToGmail()
            }
        }
        else
        {
println("In gmailMessages nil")
            myGmailData = gmailData()
            myGmailData.sourceViewController = inViewController
            myGmailData.connectToGmail()
        }
    }
    
    func gmailConnected(notification: NSNotification)
    {
 //       myOneNoteData.QueryType = "Notebooks"
 //       let myReturnString = myOneNoteData.getData("https://www.onenote.com/api/v1.0/notebooks")
//        splitString(myReturnString)
//        NSNotificationCenter.defaultCenter().postNotificationName("NotificationOneNoteNotebooksLoaded", object: nil)
    }
    
    private func splitString(inString: String)
    {

/*
        var processedFileHeader: Bool = false
        var oneNoteDataType: String = ""
        var firstItem2: Bool = true
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back
        
        let fixedString = fixStringForSearch(inString)
        
        let split = fixedString.componentsSeparatedByString("isDefault")
        
        myNotebooks = Array()
        
        for myItem in split
        {
            if !processedFileHeader
            {
                if myItem.lowercaseString.rangeOfString("http") != nil
                {
                    if myItem.lowercaseString.rangeOfString("notebooks") != nil
                    {
                        oneNoteDataType = "notebooks"
                    }
                }
                processedFileHeader = true
            }
            else
            {
                // need to further split the items into its component parts
                let split2 = myItem.componentsSeparatedByString(",")
                firstItem2 = true
                let myNotebook = oneNoteNotebook()
                for myItem2 in split2
                {
                    var split3: [String]
                    
                    if firstItem2
                    {  // strip out characters upto and including the first comma
                        let end = advance(myItem2.endIndex, -1)
                        let start = find(myItem2, ",")
                        
                        var selectedString: String = ""
                        
                        if start != nil
                        {
                            let myStart = start?.successor()
                            selectedString = myItem2[myStart!...end]
                        }
                        else
                        { // no space found
                            selectedString = myItem2
                        }
                        
                        split3 = selectedString.componentsSeparatedByString(":")
                        firstItem2 = false
                    }
                    else
                    {
                        split3 = myItem2.componentsSeparatedByString(":")
                    }
                    
                    // now split each of these into value pairs - how to store?  Maybe in a Collection??
                    
                    switch split3[0]
                    {
                    case "sectionsUrl" :
                        myNotebook.sectionsUrl = returnSearchStringToNormal(split3[1])
                        
                    case "sectionsGroupsUrl" :
                        myNotebook.sectionsUrl = returnSearchStringToNormal(split3[1])
                        
                    case "name" :
                        myNotebook.name = returnSearchStringToNormal(split3[1])
                        
                    case "lastModifiedTime" :
                        myNotebook.lastModifiedTime = returnSearchStringToNormal(split3[1])
                        
                    case "id" :
                        myNotebook.id = returnSearchStringToNormal(split3[1])
                        
                    case "self" :
                        myNotebook.urlCallback = returnSearchStringToNormal(split3[1])
                        
                    default:
                        let a = 1
                    }
                }
                myNotebooks.append(myNotebook)
            }
        }
*/
    }
    
    func listMessages()
    {
        for myMessage in myMessages
        {
            println("subject - \(myMessage.subject)")
            println("\n\n")
        }
    }
    
    func getMessage(inMessageId: String)
    {
//        if myNotebookFound
//        {
//            NSNotificationCenter.defaultCenter().postNotificationName("NotificationOneNotePagesReady", object: nil)
//        }
//        else
//        {
//            NSNotificationCenter.defaultCenter().postNotificationName("NotificationOneNoteNoNotebookFound", object: nil)
//        }
    }
}

class gmailData: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate, GIDSignInUIDelegate
{
//    var liveClient: LiveConnectClient!
    // Set the CLIENT_ID value to be the one you get from http://manage.dev.live.com/
    private let CLIENT_ID = "mygmailData"
    private let gmailSecret = "USKddrDHh2aL6C2rzQGmrYku"
    private let kKeychainItemName = "OAuth Sample: Google Mail"
    private let kShouldSaveInKeychainKey = "shouldSaveInKeychain"
    private var mySourceViewController: UIViewController!
    
    private var auth: GTMOAuth2Authentication!
    
    private var myGmailConnected: Bool = false
    
    private var myInString: String = ""
    private var myQueryType: String = ""
    
    var sourceViewController: UIViewController
        {
        get
        {
            return mySourceViewController
        }
        set
        {
            mySourceViewController = newValue
        }
    }
    
    var connected: Bool
        {
        get
        {
            return myGmailConnected
        }
    }
  
    func shouldSaveInKeychain() -> Bool
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let flag = defaults.boolForKey(kShouldSaveInKeychainKey)
        return flag
    }
    
    func connectToGmail()
    {
        println("In gmailData init")
        if !myGmailConnected
        {
            
            println("In gmailData before Auth")
            auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(kKeychainItemName, clientID: CLIENT_ID, clientSecret: gmailSecret)
            
            
            if auth.canAuthorize
            {
                println("In gmailData in canAuthorise")
                // Select the Google service segment
                //             self.serviceSegments.selectedSegmentIndex = 0;
            }
            else
            {
                
                GIDSignIn.sharedInstance().uiDelegate = self
                
                // Uncomment to automatically sign in the user.
                GIDSignIn.sharedInstance().signIn()
                
              //  GIDSignIn.sharedInstance().signInSilently()

                
                
    /*
                
                var signIn = GPPSignIn.sharedInstance();
                signIn.shouldFetchGooglePlusUser = true;
                signIn.clientID = kClientId;
                signIn.shouldFetchGoogleUserEmail = toggleFetchEmail.on;
                signIn.shouldFetchGoogleUserID = toggleFetchUserID.on;
                signIn.scopes = [kGTLAuthScopePlusLogin];
                signIn.trySilentAuthentication();
                signIn.delegate = self;

                
      */
                
                
                
                
                
                
        /*
                
                
                
                // Not connected, so go ahead and sign in
                var keychainItemName: String = ""
                
                if shouldSaveInKeychain()
                {
                    keychainItemName = kKeychainItemName
                }
                
                // For Google APIs, the scope strings are available
                // in the service constant header files.
                
                let scope = "https://www.googleapis.com/auth/gmail.readonly"
                
                // Note:
                // GTMOAuth2ViewControllerTouch is not designed to be reused. Make a new
                // one each time you are going to show it.
                
                // Display the autentication view.
                
                let finishedSel: Selector = Selector("authentication:finishedWithAuth:error:")
                
                
                let oauthController: GTMOAuth2ViewControllerTouch = createAuthController();
                
                
                oauthController.navigationItem.leftBarButtonItem = backButton;
                self.navigationController.pushViewController(oauthController, animated: true)
                
                
                let viewController = GTMOAuth2ViewControllerTouch(scope: scope, clientID: CLIENT_ID, clientSecret: gmailSecret,keychainItemName: keychainItemName, delegate: self, finishedSelector:finishedSel)
                
                // You can set the title of the navigationItem of the controller here, if you
                // want.
                
                // If the keychainItemName is not nil, the user's authorization information
                // will be saved to the keychain. By default, it saves with accessibility
                // kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, but that may be
                // customized here. For example,
                //
                //   viewController.keychainItemAccessibility = kSecAttrAccessibleAlways;
                
                // During display of the sign-in window, loss and regain of network
                // connectivity will be reported with the notifications
                // kGTMOAuth2NetworkLost/kGTMOAuth2NetworkFound
                //
                // See the method signInNetworkLostOrFound: for an example of handling
                // the notification.
                
                // Optional: Google servers allow specification of the sign-in display
                // language as an additional "hl" parameter to the authorization URL,
                // using BCP 47 language codes.
                //
                // For this sample, we'll force English as the display language.
                
                
                var params: NSDictionary = NSDictionary(object: "en", forKey: "hl")
                
                viewController.signIn.additionalAuthorizationParameters = params as [NSObject : AnyObject]
                
                // By default, the controller will fetch the user's email, but not the rest of
                // the user's profile.  The full profile can be requested from Google's server
                // by setting this property before sign-in:
                //
                //   viewController.signIn.shouldFetchGoogleUserProfile = YES;
                //
                // The profile will be available after sign-in as
                //
                //   NSDictionary *profile = viewController.signIn.userProfile;
                
                // Optional: display some html briefly before the sign-in page loads
                let html = "<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>"
                viewController.initialHTMLString = html
                
                
                //      self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("view2") as UIViewController, animated: true)
                mySourceViewController.presentViewController(viewController, animated: true, completion: nil)
                
                
                //     self.pushViewController(viewController, animated:true)
                
                // The view controller will be popped before signing in has completed, as
                // there are some additional fetches done by the sign-in controller.
                // The kGTMOAuth2UserSignedIn notification will be posted to indicate
                // that the view has been popped and those additional fetches have begun.
                // It may be useful to display a temporary UI when kGTMOAuth2UserSignedIn is
                // posted, just until the finished selector is invoked.

*/
            }
            println("In gmailData Done")
            //self.plusService.authorizer = auth;
            

            
            //            if liveClient == nil
            //            {
            //                liveClient = LiveConnectClient(clientId: CLIENT_ID, scopes:OneNoteScopeText, delegate:self, userState: "init")
            //            }
        }
    }
    
    func getData(inURLString: String) -> String
    {
        var myReturnString: String = ""
        
        myInString = inURLString
        
        if !myGmailConnected
        {
 //           if liveClient == nil
 //           {
 //               liveClient = LiveConnectClient(clientId: CLIENT_ID, scopes:OneNoteScopeText, delegate:self, userState: "init")
 //           }
        }
 //       else
//        {
//            myReturnString = performGetData(inURLString)
//        }
        return myReturnString
    }
    
    private func performGetData(inURLString: String) -> String
    {
        var response: NSURLResponse?
        var error: NSError?
        var myReturnString: String = ""
        
  //      myOneNoteFinished = false
 //       var url: NSURL = NSURL(string: inURLString)!
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "GET"
//        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
//        if liveClient.session != nil
//        {
//            request.setValue("Bearer \(liveClient.session.accessToken)", forHTTPHeaderField: "Authorization")
            // Send the HTTP request
            
//            let result = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&error)
            
//            let httpResponse = response as? NSHTTPURLResponse
            
//            let status = httpResponse!.statusCode
            
//            if status == 200
//            {
                // this means data was retrieved OK
//                myReturnString = NSString(data: result!, encoding: NSUTF8StringEncoding) as! String
//            }
//            else if status == 201
//            {
//                println("oneNoteData: Page created!")
//            }
//            else
//            {
//                println("oneNoteData: connectionDidFinishLoading: There was an error accessing the OneNote data. Response code: \(status)")
//            }
 //       }
        return myReturnString
    }
    
        /*
    @objc func authCompleted(status: LiveConnectSessionStatus, session: LiveConnectSession, userState: AnyObject)
    {
        if liveClient.session == nil
        {
            liveClient.login(mySourceViewController, delegate:self, userState: "login")
        }
        
        myOneNoteConnected = true
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationGmailConnected", object: nil)
    }

*/
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!)
    {
     //   myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!, presentViewController viewController: UIViewController!)
    {
            mySourceViewController.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!)
    {
            mySourceViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
