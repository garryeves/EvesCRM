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
    private var myFrom: String = ""
    private var myTo: String = ""
    private var myDate: String = ""
    private var myID: String = ""
    private var myThreadId: String = ""
    private var mySnippet: String = ""
    
    var subject: String
    {
        get
        {
            return mySubject
        }
    }
    
    var id: String
        {
        get
        {
            return myID
        }
        set
        {
            myID = newValue
        }
    }
    
    var threadId: String
        {
        get
        {
            return myThreadId
        }
        set
        {
            myThreadId = newValue
        }
    }

    var snippet: String
        {
        get
        {
            return mySnippet
        }
    }

    var from: String
        {
        get
        {
            return myFrom
        }
    }

    var to: String
        {
        get
        {
            return myTo
        }
    }

    var dateReceived: String
        {
        get
        {
            return myDate
        }
    }

    func populateMessage(inData: gmailData)
    {
        // Make call to get the full details of the message
        
        var workingString = "https://www.googleapis.com/gmail/v1/users/me/messages/\(myID)?format=full"
        
        let myString = inData.getData(workingString)
        
       splitString(myString)
    }
    
    private func splitString(inString: String)
    {
        
        var processedFileHeader: Bool = false
        var oneNoteDataType: String = ""
        var firstItem2: Bool = true
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back
        
        let tempStr3 = inString.stringByReplacingOccurrencesOfString("\\u003e,", withString: "")
        let tempStr4 = tempStr3.stringByReplacingOccurrencesOfString("\\u003c,", withString: "")
        let tempStr5 = tempStr4.stringByReplacingOccurrencesOfString("\\u003e", withString: "")
        let tempStr6 = tempStr5.stringByReplacingOccurrencesOfString("\\u003c", withString: "")

        
        let split = tempStr6.componentsSeparatedByString("],")
        var passNum: Int = 1
        var messageType : String = "RECEIVED"

        for myItem in split
        {
            if passNum == 1
            {
                // This is a wrapper portion so we do nothing
                
                if myItem.rangeOfString("CHAT") != nil
                {
                    //This is a chat so lets ignore it.
                    messageType = "CHAT"
                    passNum = 10
                    mySubject = "DELETEME"
                }
                
                if myItem.rangeOfString("SENT") != nil
                {
                    //This is a messgae that ahs been SENT as opposed to received
                    messageType = "SENT"
                }

            }
            
            if passNum == 2 // && messageType == "RECEIVED"
            {
                let split2 = myItem.componentsSeparatedByString("\"headers\": [")
                
                var pass2Num: Int = 1
                for myItem2 in split2
                {
                    // lets get rid of the "
                    let tempPassStr = myItem2.stringByReplacingOccurrencesOfString("\"\"", withString: "\".\"")
                    
                    if pass2Num == 1
                    {
                        let split3 = tempPassStr.componentsSeparatedByString("\",")
                        for myItem3 in split3
                        {
                            if myItem3.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != ""
                            {
                                let split4 = myItem3.componentsSeparatedByString("\":")
                                var keyString = split4[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                                let keyString2 = keyString.stringByReplacingOccurrencesOfString("\"", withString: "")
                                var valueString = split4[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                                let valueString2 = valueString.stringByReplacingOccurrencesOfString("\"", withString: "")
                            
                                if keyString2 == "snippet"
                                {
                                    let sDecode1 = valueString2.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                                    let sDecode2 = sDecode1.stringByReplacingOccurrencesOfString("&#39;", withString: "'")
                                    let sDecode3 = sDecode2.stringByReplacingOccurrencesOfString("&quot;", withString: "\"")
                                    let sDecode4 = sDecode3.stringByReplacingOccurrencesOfString("&lt;", withString: "<")
                                    let sDecode5 = sDecode4.stringByReplacingOccurrencesOfString("&gt;", withString: ">")
                                    
                                    mySnippet = sDecode5
                                }
                            }
                        }
                    }
                    
                    if pass2Num == 2
                    {
                        
                        processMessageDetails(tempPassStr)
                    }
                    pass2Num = pass2Num + 1
                }
            }

            if passNum == 3 && messageType == "SENT"
            {
                processMessageDetails(myItem)
            }

            if passNum == 4
            {
                // Body part 2 - at moment do nothing
            }

            if passNum == 5
            {
 //println("Message body")

            }

            passNum = passNum + 1
        }
}
    
    private func processMessageDetails(inString: String)
    {
        let temp2Pass = inString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let temp2Pass0 = temp2Pass.stringByReplacingOccurrencesOfString("},", withString: "*^&,")
        let temp2Pass1 = temp2Pass0.stringByReplacingOccurrencesOfString("\",", withString: "\"*^&,")
        let temp2Pass2 = temp2Pass1.stringByReplacingOccurrencesOfString("}", withString: "")
        let temp2Pass3 = temp2Pass2.stringByReplacingOccurrencesOfString("{", withString: "")
        
        // Dates have a comma so need to get rid of them
        
        let temp2Pass4 = temp2Pass3.stringByReplacingOccurrencesOfString("Mon,", withString: "Mon")
        let temp2Pass5 = temp2Pass4.stringByReplacingOccurrencesOfString("Tue,", withString: "Tue")
        let temp2Pass6 = temp2Pass5.stringByReplacingOccurrencesOfString("Wed,", withString: "Wed")
        let temp2Pass7 = temp2Pass6.stringByReplacingOccurrencesOfString("Thu,", withString: "Thu")
        let temp2Pass8 = temp2Pass7.stringByReplacingOccurrencesOfString("Fri,", withString: "Fri")
        let temp2Pass9 = temp2Pass8.stringByReplacingOccurrencesOfString("Sat,", withString: "Sat")
        let temp2Pass10 = temp2Pass9.stringByReplacingOccurrencesOfString("Sun,", withString: "Sun")
        let temp2Pass11 = temp2Pass10.stringByReplacingOccurrencesOfString("to:", withString: "to")
        let temp2Pass12 = temp2Pass11.stringByReplacingOccurrencesOfString("http:", withString: "http")
        let temp2Pass13 = temp2Pass12.stringByReplacingOccurrencesOfString("https:", withString: "https")
        let temp2Pass14 = temp2Pass13.stringByReplacingOccurrencesOfString(", ", withString: " ")
        let temp2Pass15 = temp2Pass14.stringByReplacingOccurrencesOfString("\\", withString: "")
        
        let split3 = temp2Pass15.componentsSeparatedByString("*^&,")
        var split3Pass1: Bool = true
        var keyString2: String = ""
        var valueString2: String = ""
        for myItem3 in split3
        {
            let stripSpaces = myItem3.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            if stripSpaces != ""
            {
                
                let split4 = stripSpaces.componentsSeparatedByString("\":")

                if split4.count > 1
                {
                    if split3Pass1
                    {
                        // Item is the key
                        var keyString = split4[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        keyString2 = keyString.stringByReplacingOccurrencesOfString("\"", withString: "")
                        split3Pass1 = false
                    }
                    else
                    {
                        var valueString = split4[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        valueString2 = valueString.stringByReplacingOccurrencesOfString("\"", withString: "")

                        switch keyString2
                        {
                        case "Subject":
                            mySubject = valueString2
                        
                        case "From":
                            myFrom = valueString2
                        
                        case "To":
                            myTo = valueString2
                        
                        case "Date":
                            myDate = valueString2
                        
                        default:
                            let a = 1
                        
                        }
                    
                        keyString2 = ""
                        valueString2 = ""
                    
                        split3Pass1 = true
                    }
                }
            }
        }
    }
}

class gmailMessages: NSObject
{
    private var myMessages: [gmailMessage] = []
    private var mySourceViewController: UIViewController!
    private var myGmailData: gmailData!
    private var myInString: String = ""
    
    var messages: [gmailMessage]
        {
        get
        {
            return myMessages
        }
    }
    
    init(inViewController: UIViewController, inString: String)
    {
        super.init()
        mySourceViewController = inViewController
        myInString = inString
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gmailSignedIn:", name:"NotificationGmailConnected", object: nil)
        if myGmailData != nil
        {
            if !myGmailData.connected
            {
                myGmailData = gmailData()
                myGmailData.sourceViewController = inViewController
                myGmailData.connectToGmail()
            }
        }
        else
        {
            myGmailData = gmailData()
            myGmailData.sourceViewController = inViewController
            myGmailData.connectToGmail()
        }
    }
    
    func getMessages(inString: String)
    {
        // this is used to get the messages
        
        var workingString = "https://www.googleapis.com/gmail/v1/users/me/messages"
        
        let myString = myGmailData.getData(workingString)
        
        splitString(myString)
        
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationGmailDidFinish", object: nil)
    }
    
    func gmailSignedIn(notification: NSNotification)
    {
        getMessages(myInString)
    }
    
    private func splitString(inString: String)
    {
        var processedFileHeader: Bool = false
        var oneNoteDataType: String = ""
        var firstItem2: Bool = true
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back
        
        let tempStr1 = inString.stringByReplacingOccurrencesOfString("},", withString: "")
        let tempStr2 = tempStr1.stringByReplacingOccurrencesOfString("}", withString: "")
        let tempStr3 = tempStr2.stringByReplacingOccurrencesOfString("],", withString: "")
        let tempStr4 = tempStr3.stringByReplacingOccurrencesOfString("\"", withString: "")

        let split = tempStr4.componentsSeparatedByString("{")
        
        myMessages = Array()
        
        for myItem in split
        {
            if !processedFileHeader
            {
                // Ignore the first line, it is a header
                processedFileHeader = true
            }
            else
            {
                // need to further split the items into its component parts
                let split2 = myItem.componentsSeparatedByString(",")
                firstItem2 = true
                let myMessage = gmailMessage()
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

                    var keyString = split3[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    var valueString = split3[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    // now split each of these into value pairs - how to store?  Maybe in a Collection??

                    switch keyString
                    {
                    case "id" :
                        myMessage.id = valueString
                        
                    case "threadId" :
                        myMessage.threadId = valueString
                        
                    default:
                        let a = 1
                    }
                }
                
                if myMessage.id != ""
                {
                    myMessages.append(myMessage)
                }
            }
        }
        
        // Make call to populate Messages with full details
        
        var tempMessages: [gmailMessage] = Array()
        
        for myMessage in myMessages
        {
            myMessage.populateMessage(myGmailData)
            if myMessage.mySubject != "DELETEME"
            {
                tempMessages.append(myMessage)
            }
        }

        myMessages = tempMessages
        
        
  //      listMessages()
    }
    
    func listMessages()
    {
        for myMessage in myMessages
        {
            println("id = \(myMessage.id) - subject - \(myMessage.subject)")
            println("from = \(myMessage.from) - to - \(myMessage.to)")
            println("sent = \(myMessage.dateReceived)")
            
            
            println("\n\n")
        }
    }
    
//    func getMessage(inMessageId: String)
//    {
//        if myNotebookFound
//        {
//            NSNotificationCenter.defaultCenter().postNotificationName("NotificationOneNotePagesReady", object: nil)
//        }
//        else
//        {
//            NSNotificationCenter.defaultCenter().postNotificationName("NotificationOneNoteNoNotebookFound", object: nil)
//        }
//    }
}

class gmailData: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate, GIDSignInUIDelegate
{
//    var liveClient: LiveConnectClient!
    // Set the CLIENT_ID value to be the one you get from http://manage.dev.live.com/
    private let CLIENT_ID = "344184320417-h2nr89gi0ji02tbcs7f7kpj0kevuhq6f.apps.googleusercontent.com"
    private let gmailSecret = "USKddrDHh2aL6C2rzQGmrYku"
    private let kKeychainItemName = "OAuth Sample: Google Mail"
    private let kShouldSaveInKeychainKey = "shouldSaveInKeychain"
    private var mySourceViewController: UIViewController!
    
    private var auth: GTMOAuth2Authentication!
    private var currentUser: GIDGoogleUser!
    
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
  
    override init()
    {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gmailSignedIn:", name:"NotificationGmailSignedIn", object: nil)
    }
    
    func shouldSaveInKeychain() -> Bool
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let flag = defaults.boolForKey(kShouldSaveInKeychainKey)
        return flag
    }
    
    func connectToGmail()
    {
        if currentUser == nil
        {
            GIDSignIn.sharedInstance().uiDelegate = self
                
            GIDSignIn.sharedInstance().clientID = CLIENT_ID
            GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/gmail.readonly"]
                
                // Uncomment to automatically sign in the user.
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    func getData(inURLString: String) -> String
    {
        var response: NSURLResponse?
        var error: NSError?
        var myReturnString: String = ""
        
        // Swap userId for the userd ID
        
 //       let tempStr1 = inURLString.stringByReplacingOccurrencesOfString("userId", withString:GIDSignIn.sharedInstance().currentUser.userID)

        var url: NSURL = NSURL(string: inURLString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        if currentUser != nil
        {
            request.setValue("Bearer \(GIDSignIn.sharedInstance().currentUser.authentication.accessToken)", forHTTPHeaderField: "Authorization")
            // Send the HTTP request
            
            let result = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&error)

            let httpResponse = response as? NSHTTPURLResponse
            
            let status = httpResponse!.statusCode
            
            if status == 200
            {
                // this means data was retrieved OK
                myReturnString = NSString(data: result!, encoding: NSUTF8StringEncoding) as! String
            }
            else if status == 201
            {
                println("gmailData: Page created!")
            }
            else
            {
                println("gmailData: getData: There was an error accessing the gmailData data. Response code: \(status)")
            }
        }
        return myReturnString
    }
    
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
    
    func gmailSignedIn(notification: NSNotification)
    {
        currentUser = GIDSignIn.sharedInstance().currentUser
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationGmailConnected", object: nil)
    }
}
