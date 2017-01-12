//
//  oneNote.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 25/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

class oneNotePage: NSObject
{
    fileprivate var myTitle: String = ""
    fileprivate var myPageUrl: String = ""
    fileprivate var myLastModifiedTime: Date!
    fileprivate var myId: String = ""
    fileprivate var myUrlCallback: String = ""
    fileprivate var mySectionName: String = ""
    
    var sectionName: String
        {
        get
        {
            return mySectionName
        }
        set
        {
            mySectionName = newValue
        }
    }
    
    var title: String
        {
        get
        {
            return myTitle
        }
        set
        {
            myTitle = newValue
        }
    }
    var pageUrl: String
        {
        get
        {
            return myPageUrl
        }
        set
        {
            myPageUrl = newValue
        }
    }
    
    var lastModifiedTime: Date
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

class oneNoteSection: NSObject
{
    fileprivate var myPages: [oneNotePage]!
    
    fileprivate var myName: String = ""
    fileprivate var myPagesUrl: String = ""
    fileprivate var myLastModifiedTime: String = ""
    fileprivate var myId: String = ""
    fileprivate var myUrlCallback: String = ""
    
    fileprivate var myOneNoteData: oneNoteData!
    fileprivate var gettingData: Bool = false
    
    override init()
    {
        super.init()
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
    
    var pages: [oneNotePage]
    {
        get
        {
            return myPages
        }
    }
    
    // Need to do logic for sections and pages.  Only load sections if user requests Sections for notebook, and only do pages if user requests pages in section - this is to minimise network
    
    func getPages(_ inSectionName: String)
    {
        let myPagesEndPoint: String = "https://www.onenote.com/api/v1.0/sections/\(myId)/pages"
        gettingData = true
        
        myOneNoteData.QueryType = "Pages"
        
        let myReturnString = myOneNoteData.getData(myPagesEndPoint)
        
        splitString(myReturnString, inSectionName: inSectionName)
        gettingData = false
    }
    
    fileprivate func splitString(_ inString: String, inSectionName: String)
    {
        var processedFileHeader: Bool = false

        // need to do a "dirty" change here, as we need to put insomething to split on, but ther eis no easy identifier.  title is the first field in the return string so am going to do something to that in order to provide an artificial test to split
        
        let tempStr = inString.replacingOccurrences(of: "\"title\":", with:"isDefault\"title\":")
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back

        let fixedString = fixStringForSearch(tempStr)
        
        let split = fixedString.components(separatedBy: "isDefault")
        
        myPages = Array()
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
                let myPage = oneNotePage()
                myPage.sectionName = inSectionName
                for myItem2 in split2
                {
                    if myItem2.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""
                    {
                        let split3 = myItem2.components(separatedBy: ":")
                    
                        let keyString = split3[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let valueString = split3[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

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
         
                                let myDate = myDateFormatter.date(from: myTempString)
         
                                myPage.lastModifiedTime = myDate!
                                
                            case "id" :
                                myPage.id = returnSearchStringToNormal(valueString)
                                
                            case "oneNoteClientUrl" :
                                myPage.urlCallback = returnSearchStringToNormal(valueString)
                                
                            default:
                                NSLog("Do nothing")
                        }
                    }
                }
                myPages.append(myPage)
            }
        }
        
    //    listPages()
        
   //GRE     notificationCenter.post(name: NotificationOneNotePageLoadDone, object: nil, userInfo:["Identity":myName])
    }
    
    func listPages()
    {
        for myPage in myPages
        {
            print("title - \(myPage.title)")
            print("contentUrl - \(myPage.pageUrl)")
            print("lastModifiedTime - \(myPage.lastModifiedTime)")
            print("id - \(myPage.id)")
            print("urlCallback - \(myPage.urlCallback)")
            print("\n\n")
        }
    }

}

class oneNoteNotebook: NSObject
{
    fileprivate var mySections: [oneNoteSection]!
    fileprivate var myName: String = ""
    fileprivate var mySectionsUrl: String = ""
    fileprivate var mySectionsGroupsUrl: String = ""
    fileprivate var myLastModifiedTime: String = ""
    fileprivate var myId: String = ""
    fileprivate var myUrlCallback: String = ""
    
    fileprivate var myOneNoteData: oneNoteData!
    fileprivate var gettingData: Bool = false
    fileprivate var mySectionNumber: Int = 0
    fileprivate var gettingPages: Bool = false
    
    fileprivate var processedFileHeader: Bool = false
    fileprivate var oneNoteDataType: String = ""
    fileprivate var firstItem2: Bool = true
    fileprivate var inFooter:Bool = false
    
    override init()
    {
        super.init()
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
    
    var sections: [oneNoteSection]
    {
        get
        {
            return mySections
        }
    }
    
    var sectionCount: Int
        {
        get
        {
            var ret_val = 0
            if mySections == nil
            {
                ret_val = 0
            }
            else
            {
                ret_val = mySections.count
            }
            return ret_val
        }

    }
    
    // Need to do logic for sections and pages.  Only load sections if user requests Sections for notebook, and only do pages if user requests pages in section - this is to minimise network
    
    func getSections()
    {
        let mySectionEndPoint: String = "https://www.onenote.com/api/v1.0/notebooks/\(myId)/sections"
        
        gettingData = true
        
        myOneNoteData.QueryType = "Sections"
        
        let myReturnString = myOneNoteData.getData(mySectionEndPoint)
        
        splitString(myReturnString)

        for mySection in mySections
        {
            mySection.OneNoteData = myOneNoteData
            mySection.getPages(mySection.name)
        }
    }
    
    fileprivate func splitString(_ inString: String)
    {
        processedFileHeader = false
        oneNoteDataType = ""
        firstItem2 = true
        inFooter = false
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back
        let fixedString = fixStringForSearch(inString)

        let split = fixedString.components(separatedBy: "isDefault")

        mySections = Array()
        for myItem in split
        {
            let mySection = performSplit(myItem)
            if mySection.name != ""
            {
                mySections.append(mySection)
            }
        }
    }
    
    fileprivate func performSplit(_ inString: String) -> oneNoteSection
    {
        if !processedFileHeader
        {
            if inString.lowercased().range(of: "http") != nil
            {
                if inString.lowercased().range(of: "sections") != nil
                {
                    oneNoteDataType = "sections"
                }
            }
            processedFileHeader = true
            return oneNoteSection()
        }
        else
        {
            // need to further split the items into its component parts
            let split2 = inString.components(separatedBy: ",")
            firstItem2 = true
            inFooter = false
            let mySection = oneNoteSection()
            for myItem2 in split2
            {
                if myItem2.lowercased().range(of: "parentnotebook") != nil
                {
                    inFooter = true
                }
                
                if myItem2.lowercased().range(of: "parentsectiongroup") != nil
                {
                    inFooter = true
                }
                
                if !inFooter
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
                            NSLog("Do nothing")
                        }
                    }
                }
            }
      //      mySection.OneNoteData = myOneNoteData
     //       mySection.getPages(mySection.name)
            
            return mySection
        }
    }
    
    func listSections()
    {
        for mySection in mySections
        {
            print("name - \(mySection.name)")
            print("sectionsUrl - \(mySection.pagesUrl)")
            print("lastModifiedTime - \(mySection.lastModifiedTime)")
            print("id - \(mySection.id)")
            print("urlCallback - \(mySection.urlCallback)")
            print("\n\n")
        }
    }

}

class oneNoteNotebooks: NSObject
{
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
        notificationCenter.addObserver(self, selector: #selector(oneNoteNotebooks.OneNoteConnected(_:)), name: NotificationOneNoteConnected, object: nil)

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
    
    func OneNoteConnected(_ notification: Notification)
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

class oneNoteData: NSObject, LiveAuthDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate
{
    var liveClient: LiveConnectClient!
    // Set the CLIENT_ID value to be the one you get from http://manage.dev.live.com/
    fileprivate let CLIENT_ID = "000000004C152111"; //@"%CLIENT_ID%";
    fileprivate let OneNoteScopeText = ["wl.signin", "wl.skydrive", "wl.skydrive_update", "wl.offline_access", "office.onenote_create", "office.onenote", "office.onenote_update"]
    
    fileprivate var mySourceViewController: UIViewController!
    
    fileprivate var myOneNoteConnected: Bool = false
    fileprivate var myOneNoteFinished: Bool = false
    
    fileprivate var myInString: String = ""
    fileprivate var myQueryType: String = ""
    
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

    var oneNoteConnected: Bool
        {
        get
        {
            return myOneNoteConnected
        }
    }
    override init()
    {
        super.init()
        if !myOneNoteConnected
        {
            if liveClient == nil
            {
                liveClient = LiveConnectClient(clientId: CLIENT_ID, scopes:OneNoteScopeText, delegate:self, userState: "init")
            }
        }
    }
    
    func createOneNoteObject(_ inName: String, inType: String, inParent: String) -> String
    {
        var ret_val: String = ""
//        var response: NSURLResponse?
        
        var myCommand: String = ""
        var myBody: String = ""
        
        
        if !myOneNoteConnected
        {
            if liveClient == nil
            {
                liveClient = LiveConnectClient(clientId: CLIENT_ID, scopes:OneNoteScopeText, delegate:self, userState: "init")
            }
        }
        else
        {
            switch inType
            {
                case "Notebook" :
                    myCommand = "https://www.onenote.com/api/v1.0/notebooks"
                    myBody = "{ name: \"\(inName)\" }"
                
                case "Section" :
                    myCommand = "https://www.onenote.com/api/v1.0/notebooks/\(inParent)/sections"
                    myBody = "{ name: \"\(inName)\" }"
                
                default: print("createOneNoteObject: invalid type passed in")
            }

            let presentation = myBody.data(using: String.Encoding.utf8)
            
            myOneNoteFinished = false
            let url: URL = URL(string: myCommand)!
            //        let request = NSMutableURLRequest(url: url)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = presentation
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
            
            if liveClient.session != nil
            {
                request.setValue("Bearer \(liveClient.session.accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Send the HTTP request
                
  //          let result: NSData?
  //              do
  //              {
  //                  result = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
  //              }
  //              catch let error1 as NSError
  //              {
  //                  NSLog("createOneNoteObject\(error1)")
 //                   result = nil
 //               }
                
                let session = URLSession.shared
                
                let sem = DispatchSemaphore(value: 0);
                
                let task = session.dataTask(with: request, completionHandler: {data, myresponse, error -> Void in
                    
                    let httpResponse = myresponse as? HTTPURLResponse
                    
                    let status = httpResponse!.statusCode
                    
                    let myReturnString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String
                    
                    if status == 201
                    {
                        switch inType
                        {
                        case "Notebook" :
                            ret_val = self.processNotebookCreateReturn(myReturnString)
                            
                        case "Section" :
                            ret_val = self.processNotebookCreateReturn(myReturnString)
                            
                        default: print("createOneNoteObject: invalid type passed in")
                        }

                    }
                    else
                    {
                        print("oneNoteData: createOneNoteObject: There was an error accessing the OneNote data. Response code: \(status)")
                    }
                    sem.signal()
                })
                
                task.resume()
                sem.wait()

     /*
                let httpResponse = response as? NSHTTPURLResponse
                
                let status = httpResponse!.statusCode
                
                let myReturnString = NSString(data: result!, encoding: NSUTF8StringEncoding) as! String
                
                if status == 201
                {
                    switch inType
                    {
                        case "Notebook" :
                            ret_val = processNotebookCreateReturn(myReturnString)
                        
                        case "Section" :
                            ret_val = processNotebookCreateReturn(myReturnString)

                        default: print("createOneNoteObject: invalid type passed in")
                    }
                }
                else
                {
                    print("oneNoteData: createOneNoteObject: There was an error accessing the OneNote data. Response code: \(status)")
                }
*/
            }
        }
    
        return ret_val
    }

    func createOneNotePage(_ inName: String, inType: String, inParent: String) -> String
    {
        var ret_val: String = ""
//        var response: NSURLResponse?
        
        var myCommand: String = ""
        var myBody: String = ""
        
        
        if !myOneNoteConnected
        {
            if liveClient == nil
            {
                liveClient = LiveConnectClient(clientId: CLIENT_ID, scopes:OneNoteScopeText, delegate:self, userState: "init")
            }
        }
        else
        {
            myCommand = "https://www.onenote.com/api/v1.0/sections/\(inParent)/pages"
            
            myBody = "<html>"
            myBody += "<head>"
            myBody += "<title>\(inName)</title>"
            myBody += "</head>"
            myBody += "<body>"
            myBody += "</body>"
            myBody += "</html>";

            let presentation = myBody.data(using: String.Encoding.utf8)
            
            myOneNoteFinished = false
            let url: URL = URL(string: myCommand)!
            //        let request = NSMutableURLRequest(url: url)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = presentation
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
            
            if liveClient.session != nil
            {
                request.setValue("Bearer \(liveClient.session.accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("text/html", forHTTPHeaderField: "Content-Type")
                
                // Send the HTTP request
                
          /*  let result: NSData?
                do
                {
                    result = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                }
                catch let error1 as NSError
                {
                    NSLog("createOneNotePage\(error1)")
                    result = nil
                }
              */
                
                let session = URLSession.shared
                
                let sem = DispatchSemaphore(value: 0);
                
                let task = session.dataTask(with: request, completionHandler: {data, myresponse, error -> Void in
                    
                    let httpResponse = myresponse as? HTTPURLResponse
                    
                    let status = httpResponse!.statusCode
                    
                    let myReturnString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String
                    
                    if status == 201
                    {
                        ret_val = self.processPageCreateReturn(myReturnString)
                    }
                    else
                    {
                        print("oneNoteData: createOneNotePage: There was an error accessing the OneNote data. Response code: \(status)")
                    }
                    sem.signal()
                })
                
                task.resume()
                sem.wait()
                
                
                /*
                let httpResponse = response as? NSHTTPURLResponse
                
                let status = httpResponse!.statusCode
                
                let myReturnString = NSString(data: result!, encoding: NSUTF8StringEncoding) as! String
                
                if status == 201
                {
                    ret_val = processPageCreateReturn(myReturnString)
                }
                else
                {
                    print("oneNoteData: createOneNotePage: There was an error accessing the OneNote data. Response code: \(status)")
                }
*/
            }
            
        }
        
        return ret_val
    }

    func processNotebookCreateReturn(_ inString: String) -> String
    {
        var ret_val: String = ""
        
        var processedFileHeader: Bool = false
        var firstItem2: Bool = true
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back
        
        let fixedString = fixStringForSearch(inString)
        
        let split = fixedString.components(separatedBy: "isDefault")
        
        for myItem in split
        {
            if !processedFileHeader
            {
                // ignore first line
                processedFileHeader = true
            }
            else
            {
                // need to further split the items into its component parts
                let split2 = myItem.components(separatedBy: ",")
                firstItem2 = true
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
                    
                    let keyString = split3[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let valueString = split3[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                    if keyString == "id"
                    {
                        ret_val = returnSearchStringToNormal(valueString)
                    }
                }
            }
        }
        return ret_val
    }
    
    func processPageCreateReturn(_ inString: String) -> String
    {
        var ret_val: String = ""
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back
        
        let fixedString = fixStringForSearch(inString)
        
        let split2 = fixedString.components(separatedBy: ",")
        for myItem2 in split2
        {
            let split3 = myItem2.components(separatedBy: ":")

            // now split each of these into value pairs - how to store?  Maybe in a Collection??
            
            let keyString = split3[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let valueString = split3[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
            if keyString == "oneNoteClientUrl"
            {
                ret_val = returnSearchStringToNormal(valueString)
            }
        }
        return ret_val
    }
    
    func getData(_ inURLString: String) -> String
    {
        var myReturnString: String = ""

        myInString = inURLString
        
        if !myOneNoteConnected
        {
            if liveClient == nil
            {
                liveClient = LiveConnectClient(clientId: CLIENT_ID, scopes:OneNoteScopeText, delegate:self, userState: "init")
            }
        }
        else
        {
            myReturnString = performGetData(inURLString)
        }
        return myReturnString
    }
    
    fileprivate func performGetData(_ inURLString: String) -> String
    {
  //      var response: NSURLResponse?
        var myReturnString: String = ""
        
        myOneNoteFinished = false
        let url: URL = URL(string: inURLString)!
//        let request = NSMutableURLRequest(url: url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        if liveClient.session != nil
        {
            request.setValue("Bearer \(liveClient.session.accessToken)", forHTTPHeaderField: "Authorization")
            // Send the HTTP request

  /*      let result: NSData?
            do
            {
                result = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
            }
            catch let error1 as NSError
            {
                NSLog("performGetData\(error1)")
                result = nil
            }
      */
            
            let session = URLSession.shared
            
            let sem = DispatchSemaphore(value: 0);
            
            let task = session.dataTask(with: request, completionHandler: {data, myresponse, error -> Void in
                
                let httpResponse = myresponse as? HTTPURLResponse
                
                let status = httpResponse!.statusCode
                
                if status == 200
                {
                    // this means data was retrieved OK
                    myReturnString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String
                }
                else if status == 201
                {
                    print("oneNoteData: Page created!")
                }
                else
                {
                    print("oneNoteData: connectionDidFinishLoading: There was an error accessing the OneNote data. Response code: \(status)")
                }
                sem.signal()
            })
            
            task.resume()
            sem.wait()
            
            
            /*
            
            let httpResponse = response as? NSHTTPURLResponse
          
            let status = httpResponse!.statusCode
            
            if status == 200
            {
                // this means data was retrieved OK
                myReturnString = NSString(data: result!, encoding: NSUTF8StringEncoding) as! String
            }
            else if status == 201
            {
                print("oneNoteData: Page created!")
            }
            else
            {
                print("oneNoteData: connectionDidFinishLoading: There was an error accessing the OneNote data. Response code: \(status)")
            }
*/
        }
        return myReturnString
    }

    @objc func authCompleted(_ status: LiveConnectSessionStatus, session: LiveConnectSession, userState: Any)
    {
        if liveClient.session == nil
        {
            liveClient.login(mySourceViewController, delegate:self, userState: "login")
        }
        
        myOneNoteConnected = true
        notificationCenter.post(name: NotificationOneNoteConnected, object: nil)
    }
}
