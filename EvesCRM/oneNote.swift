//
//  oneNote.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 25/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation


func loadOneNoteData(displayType: String, oneNoteStore: LiveConnectClient)
{
println("loadOneNoteData")
    
    if displayType == "Project"
    {
println("Project")
    }
    else
    {
println("person")
    }
    

    
    
    let url = NSURL(string: "http://www.stackoverflow.com")
    
    let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
        println(NSString(data: data, encoding: NSUTF8StringEncoding))
    }
    
//    oneNoteStore.getWithPath("Notebook", self)
    
    
    
    /*
    
    NSString *date = dateInISO8601Format();
    NSString *simpleHtml = [NSString stringWithFormat:
    @"<html>"
    "<head>"
    "<title>A simple page created from basic HTML-formatted text from iOS</title>"
    "<meta name=\"created\" content=\"%@\" />"
    "</head>"
    "<body>"
    "<p>This is a page that just contains some simple <i>formatted</i> <b>text</b></p>"
    "</body>"
    "</html>", date];
    
    NSData *presentation = [simpleHtml dataUsingEncoding:NSUTF8StringEncoding];
    NSString *endpointToRequest = [ONSCPSCreateExamples getPagesEndpointUrlWithSectionName:sectionName];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpointToRequest]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = presentation;
    [request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    
    */
    
    
    
  //  var client = MSOneNoteServicesClient(url: "https://outlook.office365.com/api/v1.0", dependencyResolver: authenticationController.getDependencyResolver());
    
    
    // first lets go and get list of Notebooks

}

private class oneNoteNotebook
{
    private var myName: String = ""
    private var mySectionsUrl: String = ""
    private var mySectionsGroupsUrl: String = ""
    private var myLastModifiedTime: String = ""
    private var myId: String = ""
    private var myUrlCallback: String = ""
    
    var name: String
    {
        get
        {
            return myName
        }
        set
        {
            myName = newValue
        }
    }

    var sectionsUrl: String
    {
        get
        {
            return mySectionsUrl
        }
        set
        {
            mySectionsUrl = newValue
        }
    }

    var sectionsGroupsUrl: String
    {
        get
        {
            return mySectionsGroupsUrl
        }
        set
        {
            mySectionsGroupsUrl = newValue
        }
    }

    var lastModifiedTime: String
    {
        get
        {
            return myLastModifiedTime
        }
        set
        {
            myLastModifiedTime = newValue
        }
    }

    var id: String
    {
        get
        {
            return myId
        }
        set
        {
            myId = newValue
        }
    }

    var urlCallback: String
    {
        get
        {
            return myUrlCallback
        }
        set
        {
            myUrlCallback = newValue
        }
    }
    
    // Need to do logic for sections and pages.  Only load sections if user requests Sections for notebook, and only do pages if user requests pages in section - this is to minimise network
    
}

class oneNoteNotebooks: NSObject, LiveAuthDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate
{
    private var myNotebooks: [oneNoteNotebook] = []
    
    var liveClient: LiveConnectClient!
    // Set the CLIENT_ID value to be the one you get from http://manage.dev.live.com/
    private let CLIENT_ID = "000000004C152111"; //@"%CLIENT_ID%";
    private let OneNoteScopeText = ["wl.signin", "wl.skydrive", "wl.skydrive_update", "wl.offline_access", "office.onenote_create"]
    // The in-progress connection
    private var currentConnection = NSURLConnection()
    
    // Response from the current in-progress request
    private var returnResponse = NSHTTPURLResponse()
    
    // Data being built for the current in-progress request
    private var returnData = NSMutableData()
    //  var returnData = NSData()
    
    // The endpoint for the OneNote service
    private let PagesEndPoint = "https://www.onenote.com/api/v1.0/pages"
    
    private let OneNoteNotebookEndPoint = "https://www.onenote.com/api/v1.0/notebooks"
    
    private var mySourceViewController: UIViewController!
    
 /*   init(inViewController: UIViewController)
    {
        sourceViewController = inViewController
    }
*/
    
    init(inViewController: UIViewController)
    {
        super.init()
        mySourceViewController = inViewController
        if liveClient == nil
        {
            liveClient = LiveConnectClient(clientId: CLIENT_ID, scopes:OneNoteScopeText, delegate:self, userState: "init")
        }
        else
        {
            getOneNoteNotebooks()
        }
    }
    
  /*
    init(inString: String)
    {
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
    }
 */
    
    private func splitString(inString: String)
    {
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
    }

    func listNotebooks()
    {
        for myNotebook in myNotebooks
        {
            println("name - \(myNotebook.name)")
            println("sectionsUrl - \(myNotebook.sectionsUrl)")
            println("sectionsGroupsUrl - \(myNotebook.sectionsGroupsUrl)")
            println("lastModifiedTime - \(myNotebook.lastModifiedTime)")
            println("id - \(myNotebook.id)")
            println("urlCallback - \(myNotebook.urlCallback)")
            println("\n\n")
        }
    }
    
    private func getOneNoteNotebooks()
    {
        var url: NSURL = NSURL(string: OneNoteNotebookEndPoint)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        if liveClient.session != nil
        {
            request.setValue("Bearer \(liveClient.session.accessToken)", forHTTPHeaderField: "Authorization")
            // Send the HTTP request
            currentConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        }
    }

    
    
    
    
    // Delegate code
    
    
    @objc func authCompleted(status: LiveConnectSessionStatus, session: LiveConnectSession, userState: AnyObject)
    {
        //   OneNoteScopeText = session.scopes.componentsJoinedByString(" ")
        
        if liveClient.session == nil
        {
            liveClient.login(mySourceViewController, delegate:self, userState: "login")
        }
        getOneNoteNotebooks()
    }
    /*
    func authFailed(error: NSError)
    {
    println("OneNote auth failed")
    }
    */
    
    
    
    // When body data arrives, store it
    func connection(connection: NSURLConnection, didReceiveData conData: NSData)
    {
        returnData.appendData(conData)
    }
    
    // When a response starts to arrive, allocate a data buffer for the body
    func connection(didReceiveResponse: NSURLConnection, didReceiveResponse response: NSURLResponse)
    {
        returnData = NSMutableData()
        returnResponse = response as! NSHTTPURLResponse
    }
    
    
    // Handle parsing the response from a finished service call
    func connectionDidFinishLoading(connection: NSURLConnection)
    {
        let status = returnResponse.statusCode
        
        if status == 200
        {
            // this means data was retrieved OK
            let returnString = NSString(data: returnData, encoding: NSUTF8StringEncoding) as! String
            
            splitString(returnString)
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationOneNoteNotebooksLoaded", object: nil)
            
      //      let myOneNoteNotebooks = oneNoteNotebooks(inString: newStr)
      //      myOneNoteNotebooks.listNotebooks()
            
        }
        else if status == 201
        {
            println("Notebooks: Page created!")
        }
        else
        {
            println("Notebooks: connectionDidFinishLoading: There was an error creating the page. Response code: \(status)")
        }
        
        
    }
    

    
}
