//
//  displayPanes.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 11/05/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData

class displayPanes
{
    fileprivate var myPanes: [displayPane]!
    
    init()
    {
        // Create a new pane
        // Put breakpoint on this to ensure only executed once
//        let myPane = displayPane()
//        myPane.createPane("DropBox")
        
        // Get the list of panes

        myPanes = Array()
        
        let tablePanes = myDatabaseConnection.getPanes()
        
        if tablePanes.count > 0
        {
            for myEntry in tablePanes
            {
                let myPane = displayPane()
                
                myPane.loadPane(myEntry.pane_name)
                
                myPanes.append(myPane)
            }
        }
        else
        {
            populatePanes()
        }
    }
        
    fileprivate func populatePanes()
    {
        // Populate roles with initial values
        //  Do this by checking to see if it exists already, if it does then do nothing otherwise create the pane
//        var loadSet = ["Calendar", "Details", "Evernote", "GMail", "Hangouts", "Omnifocus", "OneNote", "Project Membership", "Reminders", "Tasks"]
        
        let loadSet = ["Calendar", "Details", "DropBox", "Evernote", "GMail", "Hangouts", "OneNote", "Project Membership", "Reminders", "Tasks"]
 
        for myItem in loadSet
        {
            let myPane = displayPane()
            
            myPane.loadPane(myItem)

            if myPane.paneName == ""
            {
                // Nothing was returned so lets create a new one
                myPane.createPane(myItem)
                myPanes.append(myPane)
            }
        }
    }
    
    var listPanes: [displayPane]
    {
        get
        {
            return myPanes
        }
    }
    
    var listVisiblePanes: [displayPane]
    {
            get
            {
                var myListPanes: [displayPane] = Array()
                for myItem in myPanes
                {
                    if myItem.paneVisible
                    {
                        myListPanes.append(myItem)
                    }
                }
                return myListPanes
            }
    }
    
    func toogleVisibleStatus(_ inPane: String)
    {
        // find the pane
        
        for myItem in myPanes
        {
            if myItem.paneName == inPane
            {
                myItem.toggleVisible()
            }
        }

    }
    
    func setDisplayPane(_ inPane: String, inPaneOrder: Int)
    {
        // find the pane
        
        for myItem in myPanes
        {
            // "unset" current selection
            if myItem.paneOrder == inPaneOrder
            {
                myItem.paneOrder = 0
            }
            
            // set the new order
            if myItem.paneName == inPane
            {
                myItem.paneOrder = inPaneOrder
            }
        }
    }
}

class displayPane
{
    // This is for an instance of a pane
     
    fileprivate var myPaneName: String = ""
    fileprivate var myPaneAvailable: Bool = true
    fileprivate var myPaneVisible: Bool = true
    fileprivate var myPaneOrder: Int = 0
    fileprivate var paneLoaded: Bool = false
    
    func savePane()
    {
        myDatabaseConnection.savePane(myPaneName, inPaneAvailable: myPaneAvailable, inPaneVisible: myPaneVisible, inPaneOrder: myPaneOrder)
        
        paneLoaded = true
    }
    
    func createPane(_ paneName:String)
    {
        // Check to see if the pane exists
        if !paneLoaded
        {
            // Currently no pane loaded for this instance so lets check to see if an exisiting one exists
            
            loadPane(paneName)
            
            if !paneLoaded
            {
                // No pane was found so lets go ahead and enter the new details
                myPaneName = paneName
                myPaneAvailable = true
                myPaneVisible = true
                myPaneOrder = 0

                savePane()
            }
        }
    }
    
    func loadPane(_ paneName:String)
    {
        paneLoaded = false
        let fetchResults = myDatabaseConnection.getPane(paneName)
        
        if fetchResults.count > 0
        {
            for myPane in fetchResults
            {
                myPaneName = paneName
                myPaneAvailable = myPane.pane_available as! Bool
                myPaneVisible = myPane.pane_visible as! Bool
                myPaneOrder = myPane.pane_order as! Int
                paneLoaded = true
            }
        }
    }
    
    func toggleVisible()
    {
        myDatabaseConnection.togglePaneVisible(myPaneName)
        
        myPaneVisible = !myPaneVisible
    }
    
    var paneName: String
    {
        get
        {
            return myPaneName
        }
        set
        {
            myPaneName = newValue
        }
    }

    var paneAvailable: Bool
    {
        get
        {
            return myPaneAvailable
        }
        set
        {
            myPaneAvailable = newValue
        }
    }

    var paneVisible: Bool
    {
        get
        {
            return myPaneVisible
        }
        set
        {
            myPaneVisible = newValue
        }
    }

    var paneOrder: Int
    {
        get
        {
            return myPaneOrder
        }
        set
        {
            myPaneOrder = newValue
            myDatabaseConnection.setPaneOrder(myPaneName, paneOrder: newValue)
        }
    }
}
