//
//  CloudKitInteraction.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 15/09/2015.
//  Copyright © 2015 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol ModelDelegate {
    func errorUpdating(_ error: Error)
    func modelUpdated()
}

class CloudKitInteraction
{
    let userInfo : UserInfo
    let container : CKContainer
    let publicDB : CKDatabase
    let privateDB : CKDatabase
    
    init()
    {
        #if os(iOS)
            container = CKContainer.init(identifier: "iCloud.com.garryeves.EvesCRM")
        #elseif os(OSX)
            container = CKContainer.init(identifier: "iCloud.com.garryeves.EvesCRM")
        #else
            NSLog("Unexpected OS")
        #endif

        publicDB = container.publicCloudDatabase // data saved here can be seen by all users
        privateDB = container.privateCloudDatabase // this is the one to use to save the data
        
        userInfo = UserInfo(container: container)        
    }
    
    func performDelete(_ inRecordSet: [CKRecordID])
    {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: inRecordSet)
        operation.savePolicy = .allKeys
        operation.database = privateDB
        operation.modifyRecordsCompletionBlock = { (added, deleted, error) in
            if error != nil
            {
                NSLog(error!.localizedDescription) // print error if any
            }
            else
            {
                // no errors, all set!
            }
        }
        
        let queue = OperationQueue()
        queue.addOperations([operation], waitUntilFinished: true)
      //  privateDB.addOperation(operation, waitUntilFinished: true)
     //   NSLog("finished delete")
    }
    
    func createSubscription(_ sourceTable:String, sourceQuery: String)
    {
        let predicate: NSPredicate = NSPredicate(format: sourceQuery)
        let subscription = CKQuerySubscription(recordType: sourceTable, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        let notification = CKNotificationInfo()
        
        subscription.notificationInfo = notification
        
        let sem = DispatchSemaphore(value: 0);
        
        NSLog("Creating subscription for \(sourceTable)")
        
        self.privateDB.save(subscription, completionHandler: { (result, error) -> Void in
            if error != nil
            {
                print("Table = \(sourceTable)  Error = \(error!.localizedDescription)")
            }
            
            sem.signal()
        }) 

        sem.wait()
    }
}
