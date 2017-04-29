//
//  evernoteDetails.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 30/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import AddressBook

struct evernoteDisplay
{
    var displayData: TableData!
    var guid: String!
}

class EvernoteDetails
{
    fileprivate var myENSession: ENSession!
    private var myEvernoteShard: String = ""
    private var myEvernoteUserID: Int = 0
    private var displayData: [evernoteDisplay] = Array()
    
    var searchString: String!
    var delegate: internalCommunicationDelegate!
    
    init(sourceView: UIViewController)
    {
        myENSession = ENSession.shared()
        if !myENSession.isAuthenticated
        {
            myENSession.authenticate (with: sourceView, preferRegistration:false, completion: {
                (error: Error?) in
                if error != nil
                {
                    // authentication failed
                    // show an alert, etc
                    // ...
                    print("Error connecting to Evernote")
                    notificationCenter.post(name: NotificationEvernoteAuthenticationDidFinish, object: nil)
                }
                else
                {
                    // authentication succeeded
                    // do something now that we're authenticated
                    // ...
                    print("Connected to Evernote")
                    self.getEvernoteUserDetails()
                }
            })
        }
        else
        {
            getEvernoteUserDetails()
        }
    }

    var shard: String
    {
        get
        {
            return myEvernoteShard
        }
    }
    
    func getEvernoteUserDetails()
    {
        //Now we are authenticated we can get the used id and shard details
        let myEnUserStore = myENSession.userStore
        
        myEnUserStore?.getUserWithSuccess({
            (findNotesResults) in
            self.myEvernoteShard = (findNotesResults?.shardId)!
            self.myEvernoteUserID = findNotesResults?.id as! Int
            notificationCenter.post(name: NotificationEvernoteAuthenticationDidFinish, object: nil)
        }
            , failure: {
                (findNotesError) in
                print("Failure")
                self.myEvernoteShard = ""
                self.myEvernoteUserID = 0
                notificationCenter.post(name: NotificationEvernoteAuthenticationDidFinish, object: nil)
        })
    }
    
    func findEvernoteNotes()
    {
        var searchText: ENNoteSearch!
        let searchNotebook: ENNotebook = ENNotebook()
        let searchScope: ENSessionSearchScope = ([ENSessionSearchScope.personal, ENSessionSearchScope.personalLinked, ENSessionSearchScope.business])
        let searchOrder = ENSessionSortOrder.recentlyUpdated
        let searchMaxResults: UInt = 100
    
        var returnArray: [TableData] = Array()

        displayData.removeAll(keepingCapacity: false)
        
        if !myENSession.isAuthenticated
        {
            let tempEntry = TableData(displayText: "Unable to connect to Evernote Service")
            let tempDisplay = evernoteDisplay(displayData: tempEntry, guid: "")
            
            displayData.append(tempDisplay)
            returnArray.append(tempEntry)
        }
        else
        {
            searchText = ENNoteSearch(search: searchString)

            let sem = DispatchSemaphore(value: 0);
            
            myENSession.findNotes(with: searchText, in: searchNotebook, orScope:searchScope, sortOrder: searchOrder, maxResults: searchMaxResults, completion: {
                (findNotesResults, findNotesError) in
                for result in findNotesResults!
                {
                    var myData: EvernoteData
                    
                    myData = EvernoteData()
                    
                    myData.title = (result as AnyObject).title!!
                    myData.updateDate = (result as AnyObject).updated
                    myData.identifier = (result as AnyObject).noteRef!.guid

                    // Each ENSessionFindNotesResult has a noteRef along with other important metadata.
                    
                    // Seup Date format for display
                    
                    let startDateFormatter = DateFormatter()
                    startDateFormatter.dateStyle = .medium
                    startDateFormatter.timeStyle = .short
            
                    let lastUpdateDate = startDateFormatter.string(from: myData.updateDate)

                    var myString = "\(myData.title)\n"
                    myString += "last updated \(lastUpdateDate)"
                    
                    let tempEntry = TableData(displayText: myString)
                    let tempDisplay = evernoteDisplay(displayData: tempEntry, guid: myData.identifier)
                    
                    self.displayData.append(tempDisplay)
                    returnArray.append(tempEntry)
                }

                if findNotesError != nil
                {
                    let tempEntry = TableData(displayText: "No Notes found - error")
                    let tempDisplay = evernoteDisplay(displayData: tempEntry, guid: "")
                    
                    self.displayData.append(tempDisplay)
                    returnArray.append(tempEntry)

                }
                
                sem.signal()
            })
            sem.wait()
        }
        
        if displayData.count == 0
        {
            let tempEntry = TableData(displayText: "No Notes found")
            let tempDisplay = evernoteDisplay(displayData: tempEntry, guid: "")
            
            displayData.append(tempDisplay)
            returnArray.append(tempEntry)
        }
        
        delegate.displayResults(sourceService: "Evernote", resultsArray: returnArray)
     }

    func canDisplay(rowID: Int) -> Bool
    {
        // Cherck to see if we can display the row
        if displayData[rowID].guid != ""
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func addNote(title: String)
    {
        // Lets build the date string
        let myDateFormatter = DateFormatter()
        
        let dateFormat = DateFormatter.Style.medium
        let timeFormat = DateFormatter.Style.short
        myDateFormatter.dateStyle = dateFormat
        myDateFormatter.timeStyle = timeFormat
        
        /* Instantiate the event store */
        let myDate = myDateFormatter.string(from: Date())
        
        let myTempPath = "evernote://x-callback-url/new-note?type=text&title=\(title) : \(myDate)"
        
        let myEnUrlPath = stringByChangingChars(myTempPath, oldChar: " ", newChar: "%20")
        
        let myEnUrl: URL = URL(string: myEnUrlPath)!
        
        if UIApplication.shared.canOpenURL(myEnUrl) == true
        {
            UIApplication.shared.open(myEnUrl, options: [:],
                                      completionHandler: {
                                        (success) in
                                        print("Open myEnUrl - \(myEnUrl): \(success)")})
        }
    }
    
    func openEvernote(rowID: Int)
    {
        if myEvernoteShard != ""
        {
            let myEnUrlPath = "evernote:///view/\(myEvernoteUserID)/\(myEvernoteShard)/\(displayData[rowID].guid!)/\(displayData[rowID].guid!)/"
            
            let myEnUrl: URL = URL(string: myEnUrlPath)!
            
            if UIApplication.shared.canOpenURL(myEnUrl) == true
            {
                UIApplication.shared.open(myEnUrl, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open myEnUrl - \(myEnUrl): \(success)")})
            }
        }
    }
}
