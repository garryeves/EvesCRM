//
//  backupClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 24/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import Foundation

class backupClass: NSObject
{
    private var filemgr: NSFileManager = NSFileManager()
    private var document: MyDocument?
    private var documentURL: NSURL?
    private var ubiquityURL: NSURL?
    private var metaDataQuery: NSMetadataQuery!
    private var myTableNumber: Int = 0
//    private var myTables: [String] =
//        [
//            "AreaOfResponsibility",
//            "Context",
//            "Decodes",
//            "GoalAndObjective",
//            "MeetingAgenda",
//            "MeetingAgendaItem",
//            "MeetingAttendees",
//            "MeetingSupportingDocs",
//            "MeetingTasks",
//            "Panes",
//            "Projects",
//            "ProjectTeamMembers",
//            "PurposeAndCoreValue",
//            "Roles",
//            "Stages",
//            "Task",
//            "TaskAttachment",
//            "TaskContext",
//            "TaskPredecessor",
//            "TaskUpdates",
//            "Vision"
//    ]
    
    private var myTables: [String] =
    [
        "AreaOfResponsibility",
        "Context"
    ]
    
    private let ubiquityContainerIdentifier = "iCloud.com.garryeves.EvesCRM"

    override init()
    {
        filemgr = NSFileManager.defaultManager()
    }
    
    func backup()
    {
 println("Called backup")
    //    var docsDir: String?
     //   var dataFile: String?
        
        ubiquityURL = filemgr.URLForUbiquityContainerIdentifier(nil)!.URLByAppendingPathComponent("Documents")
        
        ubiquityURL = ubiquityURL?.URLByAppendingPathComponent("savefile.txt")
 println("ubiquityURL = \(ubiquityURL)")
        
        metaDataQuery = NSMetadataQuery()

//        metaDataQuery?.predicate = NSPredicate(format: "%K == \"savefile.txt\"", NSMetadataItemFSNameKey)
        metaDataQuery.predicate = NSPredicate(format: "%K like \"*\"", NSMetadataItemFSNameKey)
        
        metaDataQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
//        metaDataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope, NSMetadataQueryUbiquitousDataScope]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryDidFinishGathering:", name: NSMetadataQueryDidFinishGatheringNotification,object: metaDataQuery)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryRunning:", name: NSMetadataQueryGatheringProgressNotification,object: metaDataQuery)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryStarted:", name: NSMetadataQueryDidStartGatheringNotification,object: metaDataQuery)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryUpdated:", name: NSMetadataQueryDidUpdateNotification,object: metaDataQuery)

        
        dispatch_async(dispatch_get_main_queue(),
        {
println("predicate = \(self.metaDataQuery.predicate)")
println("searchScopes = \(self.metaDataQuery.searchScopes)")
            
            
            self.metaDataQuery.startQuery()
        })
        
        
println("Donr loading")
//        var startQuery = false
        
//        dispatch_sync(dispatch_get_main_queue())
//        {
//println("starting query")
           // metaDataQuery!.startQuery()
//            startQuery = self.metaDataQuery.startQuery()

//println("query started")
//        }
        
//        if !startQuery
//        {
//println("error starting query")
//        }
        
        
        
        
        
  /*
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        docsDir = dirPaths[0] as? String
        dataFile = docsDir?.stringByAppendingPathComponent("datafile.dat")
println("file \(dataFile)")
        if filemgr.fileExistsAtPath(dataFile!)
        {
println("file found")
            let databuffer = filemgr.contentsAtPath(dataFile!)
            var datastring = NSString(data: databuffer!, encoding: NSUTF8StringEncoding)
      //      textBox.text = datastring as! String
        
        }
        else
        {
println("no file found")
            let testString = "Garry"
            let databuffer = testString.dataUsingEncoding(NSUTF8StringEncoding)
            
            filemgr.createFileAtPath(dataFile!, contents: databuffer, attributes: nil)
        }
        
        // Not nice way to do this, but seems best way to be able to handle multiple files
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backupFiles", name: "BackupFilesNotification", object: nil)
        myTableNumber = 0
        backupFiles()

*/
    }
    
    func restore()
    {
        
    }
    
    private func backupFiles()
    {
        if myTableNumber >= myTables.count
        {
            // We have gone through everything, so need to exit loop
println("Backup has finished")
        }
        else
        {
            
println("Backing up \(myTableNumber) - \(myTables[myTableNumber])")
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveDocument", name: "FileCreatedNotification", object: nil)
            findFile(myTables[myTableNumber])
            myTableNumber++
        }
    }
    
    private func findFile(inFileName: String)
    {
        
 println("URL = \(filemgr.URLForUbiquityContainerIdentifier(ubiquityContainerIdentifier))")
        ubiquityURL = filemgr.URLForUbiquityContainerIdentifier(ubiquityContainerIdentifier)!.URLByAppendingPathComponent("Documents")
println("URL = \(ubiquityURL)")
        ubiquityURL = ubiquityURL?.URLByAppendingPathComponent("\(inFileName).txt")
println("URL = \(ubiquityURL)")
        metaDataQuery = NSMetadataQuery()
        
        metaDataQuery?.predicate = NSPredicate(format: "%K like \"\(inFileName)\"", NSMetadataItemFSNameKey)
        metaDataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryDidFinishGathering:", name: NSMetadataQueryDidFinishGatheringNotification,object: metaDataQuery!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryRunning:", name: NSMetadataQueryGatheringProgressNotification,object: metaDataQuery!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryStarted:", name: NSMetadataQueryDidStartGatheringNotification,object: metaDataQuery!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryUpdated:", name: NSMetadataQueryDidUpdateNotification,object: metaDataQuery!)
        
        metaDataQuery!.startQuery()
    }
    
    func metadataQueryStarted(notification: NSNotification)
    {
        println("Starting")
        let query: NSMetadataQuery = notification.object as! NSMetadataQuery
   
println("searchScopes = \(query.searchScopes)")
println("predicate = \(query.predicate)")
        
  println("results = \(query.results)")
        let results = query.results
        
  //      if query.resultCount == 1
  //      {
  //      }
        
    }
    
    func metadataQueryRunning(notification: NSNotification)
    {
        println("Still going")
    }
    
    func metadataQueryUpdated(notification: NSNotification)
    {
        println("Updted")
    }
    
    func metadataQueryDidFinishGathering(notification: NSNotification)
    {
println("Got results back")
        let query: NSMetadataQuery = notification.object as! NSMetadataQuery
        
        query.disableUpdates()
        
  //      NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidFinishGatheringNotification, object: query)
        
        query.stopQuery()
 
        /*
for(NSMetadataItem *item in results) {
NSString *filename = [item valueForAttribute:NSMetadataItemDisplayNameKey];
NSNumber *filesize = [item valueForAttribute:NSMetadataItemFSSizeKey];
NSDate *updated = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
NSLog(@"%@ (%@ bytes, updated %@)", filename, filesize, updated);
}*/



        let results = query.results
        
        if query.resultCount == 1
        {
            let resultURL =
            results[0].valueForAttribute(NSMetadataItemURLKey) as! NSURL
            
            document = MyDocument(fileURL: resultURL)
            
            document?.openWithCompletionHandler({(success: Bool) -> Void in
                if success
                {
                    println("\(resultURL) - iCloud file open OK")
               //     self.textView.text = self.document?.userText
                    self.ubiquityURL = resultURL
                }
                else
                {
                    println("\(resultURL) - iCloud file open failed")
                }
            })
        }
        else
        {
            document = MyDocument(fileURL: ubiquityURL!)
            
            document?.saveToURL(ubiquityURL!,
                forSaveOperation: .ForCreating,
                completionHandler: {(success: Bool) -> Void in
                    if success
                    {
                        println("\(self.ubiquityURL) - iCloud create OK")
                        NSNotificationCenter.defaultCenter().postNotificationName("FileCreatedNotification", object: nil)
                    }
                    else
                    {
                        println("\(self.ubiquityURL) - iCloud create failed")
                    }
            })
        }
    }
    
    private func saveDocument()
    {
      //  NSNotificationCenter.defaultCenter().removeObserver(self, name: "FileCreatedNotification", object: nil)

        document!.userText = "Garry"
        
        document?.saveToURL(ubiquityURL!,
            forSaveOperation: .ForOverwriting,
            completionHandler: {(success: Bool) -> Void in
                if success
                {
                    println("\(self.ubiquityURL) - Save overwrite OK")
               //     NSNotificationCenter.defaultCenter().postNotificationName("BackupFilesNotification", object: nil)
                }
                else
                {
                    println("\(self.ubiquityURL) - Save overwrite failed")
                }
        })
    }
}