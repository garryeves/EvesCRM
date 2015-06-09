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
    private var mygmailData: gmailData!
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gmailConnected:", name:"NotificationGmailConnected", object: nil)
        
        if mygmailData != nil
        {
            if !mygmailData.connected
            {
                mygmailData = gmailData()
                mygmailData.sourceViewController = inViewController
            }
        }
        else
        {
            mygmailData = gmailData()
            mygmailData.sourceViewController = inViewController
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

class gmailData: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate
{
//    var liveClient: LiveConnectClient!
    // Set the CLIENT_ID value to be the one you get from http://manage.dev.live.com/
    private let CLIENT_ID = "mygmailData";//@"%CLIENT_ID%";
    private let gmailSecret = "USKddrDHh2aL6C2rzQGmrYku"
    
    private var mySourceViewController: UIViewController!
    
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
        if !myGmailConnected
        {
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
}
