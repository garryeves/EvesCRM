//
//  userRolesClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class userRoles: NSObject
{
    fileprivate var myUserRoles:[userRoleItem] = Array()
    
    init(userID: Int32)
    {
        for myItem in myDatabaseConnection.getUserRoles(userID: userID)
        {
            let myObject = userRoleItem(roleID: myItem.roleID,
                                    userID: myItem.userID,
                                    roleTypeID: myItem.roleTypeID,
                                    readAccess: myItem.readAccess,
                                    writeAccess: myItem.writeAccess
                                   )
            myUserRoles.append(myObject)
        }
    }

    var userRole: [userRoleItem]
    {
        get
        {
            return myUserRoles
        }
    }
}

class userRoleItem: NSObject
{
    fileprivate var myRoleID: Int32 = 0
    fileprivate var myUserID: Int32 = 0
    fileprivate var myRoleTypeID: Int32 = 0
    fileprivate var myReadAccess: Bool = false
    fileprivate var myWriteAccess: Bool = false
    
    var roleID: Int32
    {
        get
        {
            return myRoleID
        }
    }
    
    var userID: Int32
    {
        get
        {
            return myUserID
        }
    }
    
    var roleTypeID: Int32
    {
        get
        {
            return myRoleTypeID
        }
    }
    
    var readAccess: Bool
    {
        get
        {
            return myReadAccess
        }
        set
        {
            myReadAccess = newValue
            save()
        }
    }
    
    var writeAccess: Bool
    {
        get
        {
            return myWriteAccess
        }
        set
        {
            myWriteAccess = newValue
            save()
        }
    }
    
    init(userID: Int32, roleTypeID: Int32)
    {
        super.init()
        
        myRoleID = myDatabaseConnection.getNextID("UserRoles")
        myUserID = userID
        myRoleTypeID = roleTypeID
        myReadAccess = false
        myWriteAccess = false
        
        save()
    }
    
    init(roleID: Int32)
    {
        let myReturn = myDatabaseConnection.getUserRolesDetails(roleID)
        
        for myItem in myReturn
        {
            myRoleID = myItem.roleID
            myUserID = myItem.userID
            myRoleTypeID = myItem.roleTypeID
            myReadAccess = myItem.readAccess
            myWriteAccess = myItem.writeAccess
        }
    }
    
    init(roleID: Int32,
         userID: Int32,
         roleTypeID: Int32,
         readAccess: Bool,
         writeAccess: Bool
         )
    {
        super.init()
        
        myRoleID = roleID
        myUserID = userID
        myRoleTypeID = roleTypeID
        myReadAccess = readAccess
        myWriteAccess = writeAccess
    }
    
    func save()
    {
        myDatabaseConnection.saveUserRoles(myRoleID,
                                           userID: myUserID,
                                           roleTypeID: myRoleTypeID,
                                           readAccess: myReadAccess,
                                           writeAccess: myWriteAccess
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deleteUserRoles(myRoleID)
    }
}

extension coreDatabase
{
    func saveUserRoles(_ roleID: Int32,
                       userID: Int32,
                       roleTypeID: Int32,
                       readAccess: Bool,
                       writeAccess: Bool,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: UserRoles!
        
        let myReturn = getUserRolesDetails(roleID)
        
        if myReturn.count == 0
        { // Add
            myItem = UserRoles(context: objectContext)
            myItem.roleID = roleID
            myItem.userID = userID
            myItem.roleTypeID = roleTypeID
            myItem.readAccess = readAccess
            myItem.writeAccess = writeAccess

            if updateType == "CODE"
            {
                myItem.updateTime =  NSDate()
                
                myItem.updateType = "Add"
            }
            else
            {
                myItem.updateTime = updateTime as NSDate
                myItem.updateType = updateType
            }
        }
        else
        {
            myItem = myReturn[0]
            myItem.readAccess = readAccess
            myItem.writeAccess = writeAccess
            
            if updateType == "CODE"
            {
                myItem.updateTime =  NSDate()
                if myItem.updateType != "Add"
                {
                    myItem.updateType = "Update"
                }
            }
            else
            {
                myItem.updateTime = updateTime as NSDate
                myItem.updateType = updateType
            }
        }
        
        saveContext()
    }
    
    func replaceUserRoles(_ roleID: Int32,
                          userID: Int32,
                          roleTypeID: Int32,
                          readAccess: Bool,
                          writeAccess: Bool,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = UserRoles(context: objectContext)
        myItem.roleID = roleID
        myItem.userID = userID
        myItem.roleTypeID = roleTypeID
        myItem.readAccess = readAccess
        myItem.writeAccess = writeAccess
        
        if updateType == "CODE"
        {
            myItem.updateTime =  NSDate()
            myItem.updateType = "Add"
        }
        else
        {
            myItem.updateTime = updateTime as NSDate
            myItem.updateType = updateType
        }
        
        saveContext()
    }
    
    func deleteUserRoles(_ roleID: Int32)
    {
        let myReturn = getUserRolesDetails(roleID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getUserRoles(userID: Int32)->[UserRoles]
    {
        let fetchRequest = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(userID == \(userID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func getUserRolesDetails(_ roleID: Int32)->[UserRoles]
    {
        let fetchRequest = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(roleID == \(roleID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func resetAllUserRoles()
    {
        let fetchRequest = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                myItem.updateTime =  NSDate()
                myItem.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearDeletedUserRoles(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                objectContext.delete(myItem2 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func clearSyncedUserRoles(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                myItem2.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getUserRolesForSync(_ syncDate: Date) -> [UserRoles]
    {
        let fetchRequest = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", syncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func deleteAllUserRoles()
    {
        let fetchRequest2 = NSFetchRequest<UserRoles>(entityName: "UserRoles")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                self.objectContext.delete(myItem2 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
}

extension CloudKitInteraction
{
    func saveUserRolesToCloudKit()
    {
        for myItem in myDatabaseConnection.getUserRolesForSync(myDatabaseConnection.getSyncDateForTable(tableName: "UserRoles"))
        {
            saveUserRolesRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateUserRolesInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(teamID))", myDatabaseConnection.getSyncDateForTable(tableName: "UserRoles") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "UserRoles", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateUserRolesRecord(record)
            self.recordCount -= 1
            
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }
    
    func deleteUserRoles(roleID: Int32, teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID)) AND (roleID == \(roleID))")
        let query: CKQuery = CKQuery(recordType: "UserRoles", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performPublicDelete(myRecordList)
            sem.signal()
        })
        
        sem.wait()
    }
    
    func replaceUserRolesInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "UserRoles", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            var roleID: Int32 = 0
            if record.object(forKey: "roleID") != nil
            {
                roleID = record.object(forKey: "roleID") as! Int32
            }
            
            var userID: Int32 = 0
            if record.object(forKey: "userID") != nil
            {
                userID = record.object(forKey: "userID") as! Int32
            }
            
            var roleTypeID: Int32 = 0
            if record.object(forKey: "roleTypeID") != nil
            {
                roleTypeID = record.object(forKey: "roleTypeID") as! Int32
            }
            
            var readAccess: Bool = false
            if record.object(forKey: "readAccess") != nil
            {
                readAccess = record.object(forKey: "readAccess") as! Bool
            }
            
            var writeAccess: Bool = false
            if record.object(forKey: "writeAccess") != nil
            {
                writeAccess = record.object(forKey: "writeAccess") as! Bool
            }
            
            var updateTime = Date()
            if record.object(forKey: "updateTime") != nil
            {
                updateTime = record.object(forKey: "updateTime") as! Date
            }
            
            var updateType: String = ""
            if record.object(forKey: "updateType") != nil
            {
                updateType = record.object(forKey: "updateType") as! String
            }
            
            myDatabaseConnection.replaceUserRoles(roleID,
                                                  userID: userID,
                                                  roleTypeID: roleTypeID,
                                                  readAccess: readAccess,
                                                  writeAccess: writeAccess
                                                , updateTime: updateTime, updateType: updateType)
            
            usleep(useconds_t(self.sleepTime))
        }
        
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }
    
    func saveUserRolesRecordToCloudKit(_ sourceRecord: UserRoles, teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(roleID == \(sourceRecord.roleID)) AND (teamID == \(teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "UserRoles", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.readAccess, forKey: "readAccess")
                    record!.setValue(sourceRecord.writeAccess, forKey: "writeAccess")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully updated record!")
                            }
                        }
                    })
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "UserRoles")
                    record.setValue(sourceRecord.roleID, forKey: "roleID")
                    record.setValue(sourceRecord.userID, forKey: "userID")
                    record.setValue(sourceRecord.roleTypeID, forKey: "roleTypeID")
                    record.setValue(sourceRecord.readAccess, forKey: "readAccess")
                    record.setValue(sourceRecord.writeAccess, forKey: "writeAccess")
                    
                    record.setValue(teamID, forKey: "teamID")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully saved record!")
                            }
                        }
                    })
                }
            }
            sem.signal()
        })
        sem.wait()
    }

    func updateUserRolesRecord(_ sourceRecord: CKRecord)
    {
        var roleID: Int32 = 0
        if sourceRecord.object(forKey: "roleID") != nil
        {
            roleID = sourceRecord.object(forKey: "roleID") as! Int32
        }
        
        var userID: Int32 = 0
        if sourceRecord.object(forKey: "userID") != nil
        {
            userID = sourceRecord.object(forKey: "userID") as! Int32
        }
        
        var roleTypeID: Int32 = 0
        if sourceRecord.object(forKey: "roleTypeID") != nil
        {
            roleTypeID = sourceRecord.object(forKey: "roleTypeID") as! Int32
        }
        
        var readAccess: Bool = false
        if sourceRecord.object(forKey: "readAccess") != nil
        {
            readAccess = sourceRecord.object(forKey: "readAccess") as! Bool
        }
        
        var writeAccess: Bool = false
        if sourceRecord.object(forKey: "writeAccess") != nil
        {
            writeAccess = sourceRecord.object(forKey: "writeAccess") as! Bool
        }
        
        var updateTime = Date()
        if sourceRecord.object(forKey: "updateTime") != nil
        {
            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
        }
        
        var updateType: String = ""
        if sourceRecord.object(forKey: "updateType") != nil
        {
            updateType = sourceRecord.object(forKey: "updateType") as! String
        }
        
        myDatabaseConnection.saveUserRoles(roleID,
                                           userID: userID,
                                           roleTypeID: roleTypeID,
                                           readAccess: readAccess,
                                           writeAccess: writeAccess
                                         , updateTime: updateTime, updateType: updateType)
    }
}
