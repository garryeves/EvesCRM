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
    private var myPanes: [displayPane]!
    
    // This is used to control the panes that a user can see
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    init()
    {
        // Get the list of panes
        myPanes = Array()
        
        let tablePanes = getPanes()
        
        if tablePanes.count > 0
        {
            for myEntry in tablePanes
            {
                let myPane = displayPane()
                
                myPane.loadPane(myEntry.pane_name)
                
                myPanes.append(myPane)
            }
        }
        populatePanes()
    }
    
    private func populatePanes()
    {
        // Populate roles with initial values
        //  Do this by checking to see if it exists already, if it does then do nothing otherwise create the pane
        var loadSet = ["Calendar", "Details", "Evernote", "Omnifocus", "Project Membership", "Reminders"]
        
        for myItem in loadSet
        {
            var myPane = displayPane()
            
            myPane.loadPane(myItem)
            
            if myPane.paneName == ""
            {
                // Nothing was returned so lets create a new one
                myPane.createPane(myItem)
                myPanes.append(myPane)
            }
        }
    }
    
    private func getPanes() -> [Panes]
    {
        let fetchRequest = NSFetchRequest(entityName: "Panes")

        let sortDescriptor = NSSortDescriptor(key: "pane_name", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "pane_available == true")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Panes]
        
        return fetchResults!
    }
    
    var listPanes: [displayPane]
    {
        get
        {
            return myPanes
        }
    }
}

class displayPane
{
    // This is for an instance of a pane
    
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    private var myPaneName: String = ""
    private var myPaneAvailable: Bool = true
    private var myPaneVisible: Bool = true
    private var myPaneOrder: Int = 0
    private var paneLoaded: Bool = false
    
    func savePane()
    {
        // Save the details of this pane to the database
        var error: NSError?
        let myPane = NSEntityDescription.insertNewObjectForEntityForName("Panes", inManagedObjectContext: managedObjectContext!) as! Panes
       
        myPane.pane_name = myPaneName
        myPane.pane_available = myPaneAvailable
        myPane.pane_visible = myPaneVisible
        myPane.pane_order = myPaneOrder
        
        if(managedObjectContext!.save(&error) )
        {
            println(error?.localizedDescription)
        }
        
        paneLoaded = true
    }
    
    func createPane(paneName:String)
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
    
    func loadPane(paneName:String)
    {
        paneLoaded = false
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "pane_name == \"\(paneName)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Panes]
        
        if fetchResults!.count > 0
        {
            for myPane in fetchResults!
            {
                myPaneName = paneName
                myPaneAvailable = myPane.pane_available as Bool
                myPaneVisible = myPane.pane_visible as Bool
                myPaneOrder = myPane.pane_order as Int
                paneLoaded = true
            }
        }
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
        }
    }
}