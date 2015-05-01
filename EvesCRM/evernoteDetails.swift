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

    private var retrievedData: [EvernoteData] = [EvernoteData]()
    private var expectedSearchResults: Int = 0
    private var tableContents:[TableData] = [TableData]()
    private var myENSession: ENSession!
    private var isConnected = false
    private var asyncDone = false
    
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
    func findEvernoteNotes(personSelected: ABRecord)
    {
    
        var searchText: ENNoteSearch!
        var searchNotebook: ENNotebook!
        var searchScope = (ENSessionSearchScope.Personal | ENSessionSearchScope.PersonalLinked | ENSessionSearchScope.Business)
        var searchOrder = ENSessionSortOrder.RecentlyUpdated
        var searchMaxResults: UInt = 100
    
        var myDisplayStrings: [String] = Array()

        tableContents.removeAll(keepCapacity: false)
        asyncDone = false
        
        if !isConnected
        {
            var myString = "Unable to connect to Evernote Service"
            writeRowToArray(myString, &tableContents)
        }
        else
        {
            let searchString = (ABRecordCopyCompositeName(personSelected).takeRetainedValue() as? String) ?? ""
            searchText = ENNoteSearch(searchString: searchString)

            myENSession.findNotesWithSearch(searchText, inNotebook: searchNotebook, orScope:searchScope, sortOrder: searchOrder, maxResults: searchMaxResults, completion: {
                (findNotesResults, findNotesError) in

                self.expectedSearchResults = findNotesResults.count
                if findNotesResults.count > 0
                {
                    for result in findNotesResults
                    {
                        var myData: EvernoteData
                        
                        myData = EvernoteData()
                        
                        myData.title = result.title!!
                        myData.updateDate = result.updated
                        myData.createDate = result.created
                        myData.identifier = result.noteRef!.guid
  
                        // Each ENSessionFindNotesResult has a noteRef along with other important metadata.
                        
                        // Seup Date format for display
                        
                        var startDateFormatter = NSDateFormatter()
                        var endDateFormatter = NSDateFormatter()
                        var dateFormat = NSDateFormatterStyle.MediumStyle
                        var timeFormat = NSDateFormatterStyle.ShortStyle
                        startDateFormatter.dateStyle = dateFormat
                        startDateFormatter.timeStyle = timeFormat
                        endDateFormatter.timeStyle = timeFormat
                
                        let lastUpdateDate = startDateFormatter.stringFromDate(result.updated)

                        var myString = "\(result.title!!)  - (last updated \(lastUpdateDate))"
                        myDisplayStrings.append(myString)
                        self.retrievedData.append(myData)
                    }
                    self.asyncDone = true
                    for displayString in myDisplayStrings
                    {
                        writeRowToArray(displayString, &self.tableContents)
                    }

                }
                else
                {
                    writeRowToArray("No Notes found", &self.tableContents)
                    self.asyncDone = true
                }
                if findNotesError != nil
                {
                    writeRowToArray("No Notes found - error", &self.tableContents)
                    self.asyncDone = true
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