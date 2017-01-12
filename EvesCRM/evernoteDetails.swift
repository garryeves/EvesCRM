//
//  evernoteDetails.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 30/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import AddressBook



class EvernoteDetails
{

    fileprivate var retrievedData: [EvernoteData] = [EvernoteData]()
    fileprivate var expectedSearchResults: Int = 0
    fileprivate var tableContents:[TableData] = [TableData]()
    fileprivate var myENSession: ENSession!
    fileprivate var isConnected = false
    fileprivate var asyncDone = false
    
    init(inSession: ENSession)
    {
        if inSession.isAuthenticated
        {
            myENSession = inSession
            isConnected = true
        }
    }

/*    func parseEvernoteDetails(personSelected: ABRecord, inTableNumber: String)->[TableData]
    {
        var myString: String = ""
    
        if !isConnected
        {
            myString = "Unable to connect to Evernote Service"
            writeRowToArray(myString, &tableContents)
        }
        else
        {
            findEvernoteNotes(personSelected, inTableNumber: inTableNumber)
        }
    
        return tableContents
    }
*/
    func findEvernoteNotes(_ searchString: String)
    {
    
        var searchText: ENNoteSearch!
        let searchNotebook: ENNotebook = ENNotebook()
        let searchScope: ENSessionSearchScope = ([ENSessionSearchScope.personal, ENSessionSearchScope.personalLinked, ENSessionSearchScope.business])
        let searchOrder = ENSessionSortOrder.recentlyUpdated
        let searchMaxResults: UInt = 100
    
        var myDisplayStrings: [String] = Array()

        tableContents.removeAll(keepingCapacity: false)
        retrievedData.removeAll(keepingCapacity: false)
        asyncDone = false
        
        if !isConnected
        {
            let myString = "Unable to connect to Evernote Service"
            writeRowToArray(myString, inTable: &tableContents)
        }
        else
        {
            searchText = ENNoteSearch(search: searchString)

            myENSession.findNotes(with: searchText, in: searchNotebook, orScope:searchScope, sortOrder: searchOrder, maxResults: searchMaxResults, completion: {
                (findNotesResults, findNotesError) in

                self.expectedSearchResults = (findNotesResults?.count)!
                if (findNotesResults?.count)! > 0
                {
                    for result in findNotesResults!
                    {
                        var myData: EvernoteData
                        
                        myData = EvernoteData()
                        
                        myData.title = (result as AnyObject).title!!
                        myData.updateDate = (result as AnyObject).updated
                        myData.createDate = (result as AnyObject).created
                        myData.identifier = (result as AnyObject).noteRef!.guid
                        myData.NoteRef = (result as AnyObject).noteRef
  
                        // Each ENSessionFindNotesResult has a noteRef along with other important metadata.
                        
                        // Seup Date format for display
                        
                        let startDateFormatter = DateFormatter()
                        startDateFormatter.dateStyle = .medium
                        startDateFormatter.timeStyle = .short
                
                        let lastUpdateDate = startDateFormatter.string(from: myData.updateDate)

                        var myString = "\(myData.title)\n"
                        
                        myString += "last updated \(lastUpdateDate)"
                        myDisplayStrings.append(myString)
                        
                        self.retrievedData.append(myData)
                    }
                    for displayString in myDisplayStrings
                    {
                        writeRowToArray(displayString, inTable: &self.tableContents)
                    }
                    notificationCenter.post(name: NotificationEvernoteComplete, object: nil)
                }
                else
                {
                    writeRowToArray("No Notes found", inTable: &self.tableContents)
                    notificationCenter.post(name: NotificationEvernoteComplete, object: nil)
                }
                if findNotesError != nil
                {
                    writeRowToArray("No Notes found - error", inTable: &self.tableContents)
                    notificationCenter.post(name: NotificationEvernoteComplete, object: nil)
                }
            })
        }
     }

    func isAsyncDone()-> Bool
    {
        return asyncDone
    }


    func getWriteString()->[TableData]
    {
        return tableContents
    }

    func isAuthenticated()-> Bool
    {
        return myENSession.isAuthenticated
    }

    func getEvernoteDataArray()->[EvernoteData]
    {
        return retrievedData
    }
}
