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

class oneNoteNotebooks
{
    private var myNotebooks: [oneNoteNotebook]
    
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
}
