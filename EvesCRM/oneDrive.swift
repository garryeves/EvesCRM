//
//  oneNote.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 25/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import OneDriveSDK

class oneDriveFiles: NSObject
{
    private var authenticatedDrive : ODDrive?
    private var authenticatedItem : ODItem?
    fileprivate var myNotebooks: [oneNoteNotebook] = []
    fileprivate var mySourceViewController: UIViewController!
    fileprivate var myOneNoteData: oneNoteData!
    fileprivate var myPages: [oneNotePage]!
        
    var pages: [oneNotePage]
    {
        get
        {
            return myPages
        }
    }
    
    init(inViewController: UIViewController)
    {
        super.init()

        if myOneNoteData != nil
        {
            if !myOneNoteData.oneNoteConnected
            {
                myOneNoteData = oneNoteData()
                myOneNoteData.sourceViewController = inViewController
            }
        }
        else
        {
            myOneNoteData = oneNoteData()
            myOneNoteData.sourceViewController = inViewController
        }
    }
    
    func getNoteBooks()
    {
        myOneNoteData.QueryType = "Notebooks"
        let myReturnString = myOneNoteData.getData("https://www.onenote.com/api/v1.0/notebooks")
        splitString(myReturnString)
        notificationCenter.post(name: NotificationOneNoteNotebooksLoaded, object: nil)
    }
    
    fileprivate func splitString(_ inString: String)
    {
        var processedFileHeader: Bool = false
        var firstItem2: Bool = true
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back
 
        let fixedString = fixStringForSearch(inString)
        
        let split = fixedString.components(separatedBy: "isDefault")
        
        myNotebooks = Array()
        
        for myItem in split
        {
            if !processedFileHeader
            {
                processedFileHeader = true
            }
            else
            {
                // need to further split the items into its component parts
                let split2 = myItem.components(separatedBy: ",")
                firstItem2 = true
                let myNotebook = oneNoteNotebook()
                for myItem2 in split2
                {
                    var split3: [String]
                    
                    if firstItem2
                    {  // strip out characters upto and including the first comma
                        let end = myItem2.characters.index(myItem2.endIndex, offsetBy: -1)
                        let start = myItem2.characters.index(of: ",")
                        
                        var selectedString: String = ""
                        
                        if start != nil
                        {
                            let myStart = myItem2.index(after: (start)!)
                            selectedString = myItem2[myStart...end]
                        }
                        else
                        { // no space found
                            selectedString = myItem2
                        }
                        
                        split3 = selectedString.components(separatedBy: ":")
                        firstItem2 = false
                    }
                    else
                    {
                        split3 = myItem2.components(separatedBy: ":")
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
                        NSLog("Do nothing")
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
            print("name - \(myNotebook.name)")
            print("sectionsUrl - \(myNotebook.sectionsUrl)")
            print("sectionsGroupsUrl - \(myNotebook.sectionsGroupsUrl)")
            print("lastModifiedTime - \(myNotebook.lastModifiedTime)")
            print("id - \(myNotebook.id)")
            print("urlCallback - \(myNotebook.urlCallback)")
            print("\n\n")
        }
    }
    
    func getNotesForProject(_ inProject: String)
    {
        var myWorkingArray: [oneNotePage] = []
        var myNotebookFound: Bool = false
        
        for myNotebook in myNotebooks
        {
            if myNotebook.name == inProject
            {
                myNotebookFound = true
                // We have a matching project, so now work with this one
                
                // See if we have already processed for this Notebook, if we have then there is np need to reload
                
                if myNotebook.sectionCount == 0
                {
                    myNotebook.OneNoteData = myOneNoteData
                    myNotebook.getSections()
                }
                    // Need to get a single array containing all of the pages
                
                for mySection in myNotebook.sections
                {
                    for myPage in mySection.pages
                    {
                        myWorkingArray.append(myPage)
                    }
                }
                
                myWorkingArray.sort(by: { $0.lastModifiedTime.compare($1.lastModifiedTime) == ComparisonResult.orderedDescending })
          
                myPages = myWorkingArray
            }
        }

        if myNotebookFound
        {
            notificationCenter.post(name: NotificationOneNotePagesReady, object: nil)
        }
        else
        {
            notificationCenter.post(name: NotificationOneNoteNoNotebookFound, object: nil)
        }
    }

    func getNotesForPerson(_ inPerson: String)
    {
        var myWorkingArray: [oneNotePage] = []
        
        for myNotebook in myNotebooks
        {
            if myNotebook.name == "People"
            {
                // We have a matching project, so now work with this one
                if myNotebook.sectionCount == 0
                {
                    myNotebook.OneNoteData = myOneNoteData
                    myNotebook.getSections()
                }
                
                // Need to get a single array containing all of the pages
                
                for mySection in myNotebook.sections
                {
                    if mySection.name == inPerson
                    {
                        for myPage in mySection.pages
                        {
                            myWorkingArray.append(myPage)
                        }
                    }
                }
                
                myWorkingArray.sort(by: { $0.lastModifiedTime.compare($1.lastModifiedTime) == ComparisonResult.orderedDescending })
                
                myPages = myWorkingArray
            }
        }
        notificationCenter.post(name: NotificationOneNotePagesReady, object: nil)
    }
    
    func checkExistenceOfNotebook(_ inNotebookName: String) -> Bool
    {
        var ret_val: Bool = false
        
        for myNotebook in myNotebooks
        {
            if myNotebook.name == inNotebookName
            {
                ret_val = true
                break
            }
        }
        
        return ret_val
    }
    
    func checkExistenceOfPerson(_ inPersonName: String) -> Bool
    {
        var ret_val: Bool = false
        
        for myNotebook in myNotebooks
        {
            if myNotebook.name == "People"
            {
                // We have a matching project, so now work with this one
                if myNotebook.sectionCount == 0
                {
                    myNotebook.OneNoteData = myOneNoteData
                    myNotebook.getSections()
                }
                
                // Need to get a single array containing all of the pages
                
                for mySection in myNotebook.sections
                {
                    if mySection.name == inPersonName
                    {
                        ret_val = true
                    }
                }
            }
        }
        return ret_val
    }

    func createNewNotebookForProject(_ inNotebookName: String) -> String
    {
        var ret_val: String = ""
        var targetString: String = ""
        
        // issue the command to create the notebook
        
        // Build up the command to create a new Notebook and get the notebook ID
        
        let myNotebookID = myOneNoteData.createOneNoteObject(inNotebookName, inType: "Notebook", inParent: "")
        
        // Issue the commands to create the Sections and get the ID for the "Background" section
        
        _ = myOneNoteData.createOneNoteObject("Thoughts", inType: "Section", inParent: myNotebookID)
        _ = myOneNoteData.createOneNoteObject("Reference", inType: "Section", inParent: myNotebookID)
        _ = myOneNoteData.createOneNoteObject("Dependencies", inType: "Section", inParent: myNotebookID)
        _ = myOneNoteData.createOneNoteObject("Issues", inType: "Section", inParent: myNotebookID)
        _ = myOneNoteData.createOneNoteObject("Risks", inType: "Section", inParent: myNotebookID)
        _ = myOneNoteData.createOneNoteObject("Status Updates", inType: "Section", inParent: myNotebookID)
        _ = myOneNoteData.createOneNoteObject("Meetings", inType: "Section", inParent: myNotebookID)
        targetString = myOneNoteData.createOneNoteObject("Background", inType: "Section", inParent: myNotebookID)
        
        //  Create empty page in the first section
        // Get the id for the page and return to main thread to allow OneNote app to be opened
        
        ret_val = myOneNoteData.createOneNotePage("Untitled Page", inType: "Page", inParent: targetString)

        return ret_val
    }

    func createNewSectionForPerson(_ inPersonName: String) -> String
    {
        var ret_val: String = ""
        var targetString: String = ""
        var myNotebookID: String = ""
        
        // Get the ID for the People Notebook

        for myNotebook in myNotebooks
        {
            if myNotebook.name == "People"
            {
                // We have a matching project, so now work with this one
                
                myNotebookID = myNotebook.id
            }
        }
        
        // Issue the commands to create the Sections and get the ID for the "Background" section
        
        targetString = myOneNoteData.createOneNoteObject(inPersonName, inType: "Section", inParent: myNotebookID)
        
        //  Create empty page in the first section
        // Get the id for the page and return to main thread to allow OneNote app to be opened
        
        ret_val = myOneNoteData.createOneNotePage("Untitled Page", inType: "Page", inParent: targetString)
        
        return ret_val
    }
    
    func searchOneNote(_ inSearchString: String)
    {
        let mySearchTerm: String = "https://www.onenote.com/api/v1.0/pages?search=\(inSearchString)&orderby=lastModifiedTime desc"
        let escapedAddress = mySearchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        let myReturnString = myOneNoteData.getData(escapedAddress!)
        splitSearchString(myReturnString)
        
        notificationCenter.post(name: NotificationOneNotePagesReady, object: nil)
    }
    
    fileprivate func splitSearchString(_ inString: String)
    {
        var processedFileHeader: Bool = false
        var firstItem2: Bool = true
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URLs. so need to change it to seomthign esle,
        //string out the : data and then change back
        
        let split = inString.components(separatedBy: "\"title\"")
        
        myPages = Array()
        
        for myItemLoop in split
        {
            let myItem = fixStringForSearch(myItemLoop)
 
            if !processedFileHeader
            {
                processedFileHeader = true
            }
            else
            {
                // need to further split the items into its component parts
                let split2 = myItem.components(separatedBy: ",")
                firstItem2 = true
                let myPage = oneNotePage()
                for myItem2 in split2
                {
                    if myItem2.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""
                    {
                        var split3: [String]
                    
                        if firstItem2
                        {  // need to add the title field back in
                        
                            let tempStr = "title\(myItem2)"
                            split3 = tempStr.components(separatedBy: ":")
                            firstItem2 = false
                        }
                        else
                        {
                            split3 = myItem2.components(separatedBy: ":")
                        }
                        
                        let keyString = split3[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let valueString = split3[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                        // now split each of these into value pairs - how to store?  Maybe in a Collection??

                        switch keyString
                        {
                            case "contentUrl" :
                                myPage.pageUrl = returnSearchStringToNormal(valueString)
                            
                            case "title" :
                                if returnSearchStringToNormal(valueString) == ""
                                {
                                    myPage.title = "Untitled Page"
                                }
                                else
                                {
                                    myPage.title = returnSearchStringToNormal(valueString)
                                }
                            
                            case "lastModifiedTime" :
                                // Convert the string to a date
                                var myTempString: String = ""
                                let str1 = returnSearchStringToNormal(valueString)
                                let start = str1.startIndex
                                let end = str1.characters.index(of: ".")
                            
                                if end != nil
                                {
                                    let myEnd = str1.index(before: (end)!)
                                    myTempString = str1[start...myEnd]
                                }
                                else
                                { // no period found
                                    myTempString = str1
                                }
                            
                                let myDateFormatter = DateFormatter()
                                myDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            
                                var myDate = myDateFormatter.date(from: myTempString)
                            
                                if myDate == nil
                                {
                                    myDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                                    
                                    myDate = myDateFormatter.date(from: myTempString)
                                }
                                
                                myPage.lastModifiedTime = myDate!
                            
                            case "id" :
                                myPage.id = returnSearchStringToNormal(valueString)
                            
                            case "oneNoteClientUrl" :
                                myPage.urlCallback = returnSearchStringToNormal(valueString)
                        
                            default:
                                let _ = 1
                        }
                    }
                }
                myPages.append(myPage)
            }
        }
    }
}

//class oneNoteData: NSObject, LiveAuthDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate
class oneDriveData: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate
{
    private var liveClient: ODClient!
    // Set the CLIENT_ID value to be the one you get from http://manage.dev.live.com/
    fileprivate let CLIENT_ID = "000000004C152111"; //@"%CLIENT_ID%";
    fileprivate let OneDriveScopes = ["offline_access", "onedrive.readonly"]
    
    override init()
    {
        super.init()
        
        connectToOneDrive()
    }
    
    func connectToOneDrive()
    {
        ODClient.setMicrosoftAccountAppId(CLIENT_ID, scopes: OneDriveScopes)
            
        let sem = DispatchSemaphore(value: 0);
            
        ODClient.client { (client, error) -> Void in
            if error == nil
            {
                self.liveClient = client
print("Connected")
            }
            sem.signal()
        }
        sem.wait()
            
print("After connection")
    }

    func getData(_ URLString: String) -> String
    {
  //      var response: NSURLResponse?
        var myReturnString: String = ""
        
        let url: URL = URL(string: URLString)!
//        let request = NSMutableURLRequest(url: url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        
        if liveClient != nil
        {
            liveClient.drive().items(     .items().requestURL.request().getWithCompletion({ (ODdrive, error) -> Void in
                
                if (error == nil)
                {
print("GRE - In get data")
//                    self.authenticatedDrive = ODdrive
//                    print(self.authenticatedDrive?.owner)
//                    print(self.authenticatedDrive?.driveType)
//                    print(self.authenticatedDrive?.quota)
//                    print(self.authenticatedDrive?.id)
//                    print( self.authenticatedDrive?.driveType)
                    //self.authenticatedOdClient?.drive().items().request().
                    
                }
                else{
                    print("error is", error!)
                }
                
//                self.getUserRootFolder()
            })
        }
//        if liveClient.session != nil
//        {
//            request.setValue("Bearer \(liveClient.session.accessToken)", forHTTPHeaderField: "Authorization")
//            // Send the HTTP request
//
//
//            
//            let session = URLSession.shared
//            
//            let sem = DispatchSemaphore(value: 0);
//            
//            let task = session.dataTask(with: request, completionHandler: {data, myresponse, error -> Void in
//                
//                let httpResponse = myresponse as? HTTPURLResponse
//                
//                let status = httpResponse!.statusCode
//                
//                if status == 200
//                {
//                    // this means data was retrieved OK
//                    myReturnString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String
//                }
//                else if status == 201
//                {
//                    print("oneNoteData: Page created!")
//                }
//                else
//                {
//                    print("oneNoteData: connectionDidFinishLoading: There was an error accessing the OneNote data. Response code: \(status)")
//                }
//                sem.signal()
//            })
//            
//            task.resume()
//            sem.wait()
//            
//
//        }
        return myReturnString
    }
}
