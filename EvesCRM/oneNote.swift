//
//  oneNote.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 25/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

private class oneNotePage: NSObject
{
    
}

private class oneNoteSection: NSObject
{
    private var myPages: [oneNotePage]!
    
    private var myName: String = ""
    private var myPagesUrl: String = ""
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
   
    var pagesUrl: String
        {
        get
        {
            return myPagesUrl
        }
        set
        {
            myPagesUrl = newValue
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
}

private class oneNoteNotebook: NSObject
{
    private var mySections: [oneNoteSection]!
    private var myName: String = ""
    private var mySectionsUrl: String = ""
    private var mySectionsGroupsUrl: String = ""
    private var myLastModifiedTime: String = ""
    private var myId: String = ""
    private var myUrlCallback: String = ""
    
    // The in-progress connection
    private var sectionConnection = NSURLConnection()
    
    // Response from the current in-progress request
    private var returnResponse = NSHTTPURLResponse()
    
    // Data being built for the current in-progress request
    private var returnData = NSMutableData()
    private var myOneNoteData: oneNoteData!
    private var gettingData: Bool = false
    
    override init()
    {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "OneNoteSectionsData:", name:"NotificationOneNoteSectionsData", object: nil)
    }
    
    var OneNoteData: oneNoteData
        {
        get
        {
            return myOneNoteData
        }
        set
        {
            myOneNoteData = newValue
        }
    }
    
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
    
    func getSections()
    {
        var mySectionEndPoint: String = "https://www.onenote.com/api/v1.0/notebooks/\(myId)/sections"
        
        gettingData = true
        
        myOneNoteData.QueryType = "Sections"
        
        myOneNoteData.getData(mySectionEndPoint)
    }
    
    @objc func OneNoteSectionsData(notification: NSNotification)
    {
        if gettingData
        {
            splitString(myOneNoteData.returnString)
            gettingData = false
        }
    //    NSNotificationCenter.defaultCenter().postNotificationName("NotificationOneNoteNotebooksLoaded", object: nil)
    }

    
    private func splitString(inString: String)
    {
        var processedFileHeader: Bool = false
        var oneNoteDataType: String = ""
        var firstItem2: Bool = true
        var inFooter:Bool = false
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back
        let fixedString = fixStringForSearch(inString)

        let split = fixedString.componentsSeparatedByString("isDefault")

        mySections = Array()
        for myItem in split
        {
            if !processedFileHeader
            {
                if myItem.lowercaseString.rangeOfString("http") != nil
                {
                    if myItem.lowercaseString.rangeOfString("sections") != nil
                    {
                        oneNoteDataType = "sections"
                    }
                }
                processedFileHeader = true
            }
            else
            {
                // need to further split the items into its component parts
                let split2 = myItem.componentsSeparatedByString(",")
                firstItem2 = true
                inFooter = false
                let mySection = oneNoteSection()
                for myItem2 in split2
                {
                    if myItem2.lowercaseString.rangeOfString("parentsectiongroup") != nil
                    {
                        inFooter = true
                    }
                    if !inFooter
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
                    
                    // now split each of these into value pairs - how to store?  Maybe in a Collection??
  
                            switch split3[0]
                            {
                                case "pagesUrl" :
                                    mySection.pagesUrl = returnSearchStringToNormal(split3[1])
                        
                                case "name" :
                                    mySection.name = returnSearchStringToNormal(split3[1])
                        
                                case "lastModifiedTime" :
                                    mySection.lastModifiedTime = returnSearchStringToNormal(split3[1])
                        
                                case "id" :
                                    mySection.id = returnSearchStringToNormal(split3[1])
                        
                                case "self" :
                                    mySection.urlCallback = returnSearchStringToNormal(split3[1])
                        
                                default:
                                    let a = 1
                            }
                        }
                    }
                }
                mySections.append(mySection)
            }
        }
    }
    
    func listSections()
    {
        for mySection in mySections
        {
            println("name - \(mySection.name)")
            println("sectionsUrl - \(mySection.pagesUrl)")
            println("lastModifiedTime - \(mySection.lastModifiedTime)")
            println("id - \(mySection.id)")
            println("urlCallback - \(mySection.urlCallback)")
            println("\n\n")
        }
    }

}

class oneNoteNotebooks: NSObject
  //  class oneNoteNotebooks: NSObject, LiveAuthDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate
{
    private var myNotebooks: [oneNoteNotebook] = []
    private var mySourceViewController: UIViewController!
    private var myOneNoteData: oneNoteData!
    
    init(inViewController: UIViewController)
    {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "OneNoteNotebookData:", name:"NotificationOneNoteNotebooksData", object: nil)
        
        myOneNoteData = oneNoteData()
        myOneNoteData.sourceViewController = inViewController
        myOneNoteData.QueryType = "Notebooks"

        myOneNoteData.getData("https://www.onenote.com/api/v1.0/notebooks")
    }
    
    func OneNoteNotebookData(notification: NSNotification)
    {
        splitString(myOneNoteData.returnString)
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationOneNoteNotebooksLoaded", object: nil)
    }
    
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
    
    func getNotesForProject(inProject: String) -> [TableData]
    {
        var notebookFound: Bool = false
        var returnArray: [TableData] = []
        
        for myNotebook in myNotebooks
        {
            if myNotebook.name == inProject
            {
                // We have a matching project, so now work with this one
                myNotebook.OneNoteData = myOneNoteData
                myNotebook.getSections()
                notebookFound = true
                break
            }
        }
        
        if !notebookFound
        {
            writeRowToArray("No matching OneNote Notebook found", &returnArray)
        }
        else
        {
            writeRowToArray("OneNote Notebook found", &returnArray)
        }

        return returnArray
    }

    func getNotesForPerson(inPerson: String) -> [TableData]
    {
        var notebookFound: Bool = false
        var returnArray: [TableData] = []
println("Get a person")
        
        return returnArray
    }

    
}

class oneNoteData: NSObject, LiveAuthDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate
{
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
    
    private var mySourceViewController: UIViewController!
    
    private var myOneNoteConnected: Bool = false
    private var myOneNoteFinished: Bool = false
    
    private var myReturnString: String = ""
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
    
    var QueryType: String
        {
        get
        {
            return myQueryType
        }
        set
        {
            myQueryType = newValue
        }
    }
    
    var oneNoteFinished: Bool
        {
        get
        {
            return myOneNoteFinished
        }
    }

    var returnString: String
        {
        get
        {
            return myReturnString
        }
    }
    
    func getData(inURLString: String)
    {
        myInString = inURLString
        if myOneNoteConnected
        {
            performGetData()
        }
        else
        {
            if liveClient == nil
            {
                liveClient = LiveConnectClient(clientId: CLIENT_ID, scopes:OneNoteScopeText, delegate:self, userState: "init")
            }
        }
    }
    
    private func performGetData()
    {
        myOneNoteFinished = false
        var url: NSURL = NSURL(string: myInString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        if liveClient.session != nil
        {
            request.setValue("Bearer \(liveClient.session.accessToken)", forHTTPHeaderField: "Authorization")
            // Send the HTTP request
            currentConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        }
    }

    @objc func authCompleted(status: LiveConnectSessionStatus, session: LiveConnectSession, userState: AnyObject)
    {
        if liveClient.session == nil
        {
            liveClient.login(mySourceViewController, delegate:self, userState: "login")
        }
        performGetData()
        myOneNoteConnected = true
    }
    
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
        myOneNoteFinished = true
        let status = returnResponse.statusCode
        
        if status == 200
        {
            // this means data was retrieved OK
            myReturnString = NSString(data: returnData, encoding: NSUTF8StringEncoding) as! String
            
            switch myQueryType
            {
                case "Notebooks":
                    NSNotificationCenter.defaultCenter().postNotificationName("NotificationOneNoteNotebooksData", object: nil)
                
                case "Sections":
                    NSNotificationCenter.defaultCenter().postNotificationName("NotificationOneNoteSectionsData", object: nil)
                
                default:
                    // Do nothing
                    let a = 1
            }
        }
        else if status == 201
        {
            println("oneNoteData: Page created!")
        }
        else
        {
            println("oneNoteData: connectionDidFinishLoading: There was an error creating the page. Response code: \(status)")
        }
    }
}
