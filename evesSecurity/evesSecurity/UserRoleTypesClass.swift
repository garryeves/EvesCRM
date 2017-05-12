//
//  UserRoleTypesClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class userRoleTypes: NSObject
{
    fileprivate var myUserRoleTypes:[userRoleType] = Array()
    
    override init()
    {
        for myItem in myDatabaseConnection.getUserRoleTypes()
        {
            let myObject = userRoleType(roleTypeID: myItem.roleTypeID,
                                         name: myItem.name!)
            myUserRoleTypes.append(myObject)
        }
    }
    
    var UserRoleTypes: [userRoleType]
    {
        get
        {
            return myUserRoleTypes
        }
    }
}

class userRoleType: NSObject
{
    fileprivate var myRoleTypeID: Int32 = 0
    fileprivate var myName: String = ""
    
    var roleTypeID: Int32
    {
        get
        {
            return myRoleTypeID
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
            save()
        }
    }
    
    init(name: String)
    {
        super.init()
        
        myRoleTypeID = myDatabaseConnection.getNextID("UserRoleTypes")
        myName = name
        
        save()
    }
    
    init(roleTypeID: Int32)
    {
        super.init()
        
        let myReturn = myDatabaseConnection.getUserRoleTypesDetails(roleTypeID)
        
        for myItem in myReturn
        {
            myRoleTypeID = myItem.roleTypeID
            myName = myItem.name!
        }
    }
    
    init(roleTypeID: Int32,
         name: String
         )
    {
        super.init()

        myRoleTypeID = roleTypeID
        myName = name
    }
    
    func save()
    {
        myDatabaseConnection.saveUserRoleTypes(myRoleTypeID,
                                         name: myName
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deleteUserRoleTypes(myRoleTypeID)
    }
}

extension coreDatabase
{
    func saveUserRoleTypes(_ roleTypeID: Int32,
                     name: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: UserRoleTypes!
        
        let myReturn = getUserRoleTypesDetails(roleTypeID)
        
        if myReturn.count == 0
        { // Add
            myItem = UserRoleTypes(context: objectContext)
            myItem.roleTypeID = roleTypeID
            myItem.name = name
            
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
            myItem.name = name
            
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
    
    func replaceUserRoleTypes(_ roleTypeID: Int32,
                              name: String,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = UserRoleTypes(context: objectContext)
        myItem.roleTypeID = roleTypeID
        myItem.name = name
        
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
    
    func deleteUserRoleTypes(_ roleTypeID: Int32)
    {
        let myReturn = getUserRoleTypesDetails(roleTypeID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getUserRoleTypes()->[UserRoleTypes]
    {
        let fetchRequest = NSFetchRequest<UserRoleTypes>(entityName: "UserRoleTypes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
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
    
    func getUserRoleTypesDetails(_ roleTypeID: Int32)->[UserRoleTypes]
    {
        let fetchRequest = NSFetchRequest<UserRoleTypes>(entityName: "UserRoleTypes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(roleTypeID == \(roleTypeID)) && (updateType != \"Delete\")")
        
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
    
    func resetAllUserRoleTypes()
    {
        let fetchRequest = NSFetchRequest<UserRoleTypes>(entityName: "UserRoleTypes")
        
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
    
    func clearDeletedUserRoleTypes(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<UserRoleTypes>(entityName: "UserRoleTypes")
        
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
    
    func clearSyncedUserRoleTypes(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<UserRoleTypes>(entityName: "UserRoleTypes")
        
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
    
    func getUserRoleTypesForSync(_ syncDate: Date) -> [UserRoleTypes]
    {
        let fetchRequest = NSFetchRequest<UserRoleTypes>(entityName: "UserRoleTypes")
        
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
    
    func deleteAllUserRoleTypes()
    {
        let fetchRequest2 = NSFetchRequest<UserRoleTypes>(entityName: "UserRoleTypes")
        
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
    func saveUserRoleTypesToCloudKit()
    {
        for myItem in myDatabaseConnection.getUserRoleTypesForSync(myDatabaseConnection.getSyncDateForTable(tableName: "UserRoleTypes"))
        {
            saveUserRoleTypesRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateUserRoleTypesInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(teamID))", myDatabaseConnection.getSyncDateForTable(tableName: "UserRoleTypes") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "UserRoleTypes", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateUserRoleTypesRecord(record)
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
    
    func deleteUserRoleTypes(roleTypeID: Int32, teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID)) AND (roleTypeID == \(roleTypeID))")
        let query: CKQuery = CKQuery(recordType: "UserRoleTypes", predicate: predicate)
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
    
    func replaceUserRoleTypesInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "UserRoleTypes", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let name = record.object(forKey: "name") as! String
            
            var roleTypeID: Int32 = 0
            if record.object(forKey: "roleTypeID") != nil
            {
                roleTypeID = record.object(forKey: "roleTypeID") as! Int32
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
            
            myDatabaseConnection.replaceUserRoleTypes(roleTypeID,
                                                name: name
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
    
    func saveUserRoleTypesRecordToCloudKit(_ sourceRecord: UserRoleTypes, teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(roleTypeID == \(sourceRecord.roleTypeID)) AND (teamID == \(teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "UserRoleTypes", predicate: predicate)
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

                    record!.setValue(sourceRecord.name, forKey: "name")
                    
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
                    let record = CKRecord(recordType: "UserRoleTypes")
                    record.setValue(sourceRecord.roleTypeID, forKey: "roleTypeID")
                    record.setValue(sourceRecord.name, forKey: "name")
                    
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
    
    func updateUserRoleTypesRecord(_ sourceRecord: CKRecord)
    {
        let name = sourceRecord.object(forKey: "name") as! String
        
        var roleTypeID: Int32 = 0
        if sourceRecord.object(forKey: "roleTypeID") != nil
        {
            roleTypeID = sourceRecord.object(forKey: "roleTypeID") as! Int32
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
        
        myDatabaseConnection.saveUserRoleTypes(roleTypeID,
                                         name: name
                                         , updateTime: updateTime, updateType: updateType)
    }
}

