//
//  taskManagementClasses.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

class purposeAndCoreValue: NSObject // 50k Level
{
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class vision: NSObject // (3-5 year goals) 40k Level
{
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class goalAndObjective: NSObject  // (1-2 year goals) 30k Level
{
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class areaOfResponsibility // 20k Level
{
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class project: NSObject // 10k level
{
    private var myProjectEndDate: NSDate!
    private var myProjectID: Int = 0
    private var myProjectName: String = ""
    private var myProjectStartDate: NSDate!
    private var myProjectStatus: String = ""
    
    var projectEndDate: NSDate
    {
        get
        {
            return myProjectEndDate
        }
        set
        {
            myProjectEndDate = newValue
        }
    }
    
    var displayProjectEndDate: String
    {
        get
        {
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myProjectEndDate)
        }
    }

    var projectID: Int
    {
        get
        {
            return myProjectID
        }
    }

    var projectName: String
    {
        get
        {
            return myProjectName
        }
        set
        {
            myProjectName = newValue
        }
    }

    var projectStartDate: NSDate
    {
        get
        {
            return myProjectStartDate
        }
        set
        {
            myProjectStartDate = newValue
        }
    }

    var displayProjectStartDate: String
    {
        get
        {
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myProjectStartDate)
        }
    }

    var projectStatus: String
    {
        get
        {
            return myProjectStatus
        }
        set
        {
            myProjectStatus = newValue
        }
    }
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class task: NSObject
{
    private var myTaskID: String = ""
    private var myTitle: String = ""
    private var myDetails: String = ""
    private var myDueDate: NSDate!
    private var myStartDate: NSDate!
    private var myStatus: String = ""

    var taskID: String
    {
        get
        {
            return myTaskID
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
    
    var details: String
    {
        get
        {
            return myDetails
        }
        set
        {
            myDetails = newValue
        }
    }
    
    var dueDate: NSDate
    {
        get
        {
            return myDueDate
        }
        set
        {
            myDueDate = newValue
        }
    }
    
    var displayDueDate: String
    {
        get
        {
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myDueDate)
        }
    }
    
    var startDate: NSDate
    {
        get
        {
            return myStartDate
        }
        set
        {
            myStartDate = newValue
        }
    }
 
    var displayStartDate: String
    {
        get
        {
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myStartDate)
        }
    }
    
    var status: String
    {
        get
        {
            return myStatus
        }
        set
        {
            myStatus = newValue
        }
    }
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class context: NSObject
{
    private var myContextID: String = ""
    private var myName: String = ""
    private var myEmail: String = ""
    private var myAutoEmail: String = ""
    private var myParentContext: String = ""
    private var myStatus: String = ""
    
    var contextID: String
    {
        get
        {
            return myContextID
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
    
    var email: String
    {
        get
        {
            return myEmail
        }
        set
        {
            myEmail = newValue
        }
    }
    
    var autoEmail: String
    {
        get
        {
            return myAutoEmail
        }
        set
        {
            myAutoEmail = newValue
        }
    }
    
    var parentContext: String
    {
        get
        {
            return myParentContext
        }
        set
        {
            myParentContext = newValue
        }
    }
    
    var status: String
    {
        get
        {
            return myStatus
        }
        set
        {
            myStatus = newValue
        }
    }
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}

class taskUpdates: NSObject
{
    private var myTaskID: String = ""
    private var myUpdateDate: NSDate!
    private var myDetails: String = ""
    private var mySource: String = ""

    var updateDate: NSDate
    {
        get
        {
            return myUpdateDate
        }
        set
        {
            myUpdateDate = newValue
        }
    }
    
    var displayUpdateDate: String
    {
        get
        {
            var myDateFormatter = NSDateFormatter()
            myDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return myDateFormatter.stringFromDate(myUpdateDate)
        }
    }
    
    var details: String
        {
        get
        {
            return myDetails
        }
        set
        {
            myDetails = newValue
        }
    }
    
    var source: String
        {
        get
        {
            return mySource
        }
        set
        {
            mySource = newValue
        }
    }
    
    func load()
    {
        
    }
    
    func save()
    {
        
    }
}