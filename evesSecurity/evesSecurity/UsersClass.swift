//
//  UsersClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import RNCryptor

class UserItem: NSObject
{
    fileprivate var myUserID: Int32 = 0
    fileprivate var myRoles: userRoles!
    fileprivate var myTeam: team!
    fileprivate let secretKey = "djskfPnmjYUPFEUingljmyzdls"
    private let defaultsName = "group.com.garryeves.EvesCRM"
    
    var userID: Int32
    {
        get
        {
            return myUserID
        }
    }
    
    var roles: userRoles
    {
        get
        {
            return myRoles
        }
    }
    
//    var isAuthorised: Bool
//    {
//        get
//        {
//            return ??
//        }
//    }
    
    init(userID: Int32)
    {
        super.init()

        myUserID = userID
    }
    

    
    func save()
    {
//        myDatabaseConnection.saveUsers(myUsersID,
//                                         UsersLine1: myUsersLine1,
//                                         UsersLine2: myUsersLine2,
//                                         )
    }
    
    func delete()
    {
//        myDatabaseConnection.deleteUsers(myUserID)
    }
    
    func writeDefaultString(_  keyName: String, value: String)
    {
        let defaults = UserDefaults(suiteName: defaultsName)!
        
        defaults.set(value, forKey: keyName)
        
        defaults.synchronize()
    }
    
    func readDefaultString(_  keyName: String) -> String
    {
        let defaults = UserDefaults(suiteName: defaultsName)!
        
        if defaults.string(forKey: keyName) != nil
        {
            return (defaults.string(forKey: keyName))!
        }
        else
        {
            return ""
        }
    }

    func encryptText(_ textString: String)->Data
    {
        let data: Data = textString.data(using: .utf8)!
        let ciphertext = RNCryptor.encrypt(data: data, withPassword: secretKey)

        print("ciphertext \(ciphertext)")
        
        return ciphertext
    }
    
    func decryptText(_  textData: Data)
    {
        //
        // Decryption
        //
        

        do {
            let originalData = try RNCryptor.decrypt(data: textData, withPassword: secretKey)
            // ...
            print("originalData \(originalData)")
            let newString = String(data: originalData, encoding: .utf8)
            print("newString \(newString)")
        } catch {
            print(error)
        }
        

    }
}
//
//extension coreDatabase
//{
//    func saveUsers(_ UsersID: Int32,
//                     UsersLine1: String,
//                     UsersLine2: String,
//                     
//                     updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        var myItem: Users!
//        
//        let myReturn = getUsersDetails(UsersID)
//        
//        if myReturn.count == 0
//        { // Add
//            myItem = Users(context: objectContext)
//            myItem.UsersID = UsersID
//            myItem.UsersLine1 = UsersLine1
//            myItem.UsersLine2 = UsersLine2
//            
//            
//            if updateType == "CODE"
//            {
//                myItem.updateTime =  NSDate()
//                
//                myItem.updateType = "Add"
//            }
//            else
//            {
//                myItem.updateTime = updateTime as NSDate
//                myItem.updateType = updateType
//            }
//        }
//        else
//        {
//            myItem = myReturn[0]
//            myItem.UsersLine1 = UsersLine1
//            myItem.UsersLine2 = UsersLine2
//            
//            
//            if updateType == "CODE"
//            {
//                myItem.updateTime =  NSDate()
//                if myItem.updateType != "Add"
//                {
//                    myItem.updateType = "Update"
//                }
//            }
//            else
//            {
//                myItem.updateTime = updateTime as NSDate
//                myItem.updateType = updateType
//            }
//        }
//        
//        saveContext()
//    }
//    
//    func replaceUsers(_ UsersID: Int32,
//                        UsersLine1: String,
//                        UsersLine2: String,
//                        
//                        updateTime: Date =  Date(), updateType: String = "CODE")
//    {
//        let myItem = Users(context: objectContext)
//        myItem.UsersID = UsersID
//        myItem.UsersLine1 = UsersLine1
//        myItem.UsersLine2 = UsersLine2
//        
//        
//        if updateType == "CODE"
//        {
//            myItem.updateTime =  NSDate()
//            myItem.updateType = "Add"
//        }
//        else
//        {
//            myItem.updateTime = updateTime as NSDate
//            myItem.updateType = updateType
//        }
//        
//        saveContext()
//    }
//    
//    func deleteUsers(_ UsersID: Int32)
//    {
//        let myReturn = getUsersDetails(UsersID)
//        
//        if myReturn.count > 0
//        {
//            let myItem = myReturn[0]
//            myItem.updateTime =  NSDate()
//            myItem.updateType = "Delete"
//        }
//        
//        saveContext()
//    }
//    
//    func getUsersDetails(_ UsersID: Int32)->[Users]
//    {
//        let fetchRequest = NSFetchRequest<Users>(entityName: "Users")
//        
//        // Create a new predicate that filters out any object that
//        // doesn't have a title of "Best Language" exactly.
//        let predicate = NSPredicate(format: "(UsersID == \(UsersID)) && (updateType != \"Delete\")")
//        
//        // Set the predicate on the fetch request
//        fetchRequest.predicate = predicate
//        
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults = try objectContext.fetch(fetchRequest)
//            return fetchResults
//        }
//        catch
//        {
//            print("Error occurred during execution: \(error)")
//            return []
//        }
//    }
//    
//    func resetAllUsers()
//    {
//        let fetchRequest = NSFetchRequest<Users>(entityName: "Users")
//        
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults = try objectContext.fetch(fetchRequest)
//            for myItem in fetchResults
//            {
//                myItem.updateTime =  NSDate()
//                myItem.updateType = "Delete"
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: \(error)")
//        }
//        
//        saveContext()
//    }
//    
//    func clearDeletedUsers(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<Users>(entityName: "Users")
//        
//        // Set the predicate on the fetch request
//        fetchRequest2.predicate = predicate
//        
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults2 = try objectContext.fetch(fetchRequest2)
//            for myItem2 in fetchResults2
//            {
//                objectContext.delete(myItem2 as NSManagedObject)
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: \(error)")
//        }
//        saveContext()
//    }
//    
//    func clearSyncedUsers(predicate: NSPredicate)
//    {
//        let fetchRequest2 = NSFetchRequest<Users>(entityName: "Users")
//        
//        // Set the predicate on the fetch request
//        fetchRequest2.predicate = predicate
//        
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults2 = try objectContext.fetch(fetchRequest2)
//            for myItem2 in fetchResults2
//            {
//                myItem2.updateType = ""
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: \(error)")
//        }
//        
//        saveContext()
//    }
//    
//    func getUsersForSync(_ syncDate: Date) -> [Users]
//    {
//        let fetchRequest = NSFetchRequest<Users>(entityName: "Users")
//        
//        let predicate = NSPredicate(format: "(updateTime >= %@)", syncDate as CVarArg)
//        
//        // Set the predicate on the fetch request
//        
//        fetchRequest.predicate = predicate
//        // Execute the fetch request, and cast the results to an array of  objects
//        do
//        {
//            let fetchResults = try objectContext.fetch(fetchRequest)
//            
//            return fetchResults
//        }
//        catch
//        {
//            print("Error occurred during execution: \(error)")
//            return []
//        }
//    }
//    
//    func deleteAllUsers()
//    {
//        let fetchRequest2 = NSFetchRequest<Users>(entityName: "Users")
//        
//        // Execute the fetch request, and cast the results to an array of LogItem objects
//        do
//        {
//            let fetchResults2 = try objectContext.fetch(fetchRequest2)
//            for myItem2 in fetchResults2
//            {
//                self.objectContext.delete(myItem2 as NSManagedObject)
//            }
//        }
//        catch
//        {
//            print("Error occurred during execution: \(error)")
//        }
//        
//        saveContext()
//    }
//}
//
//extension CloudKitInteraction
//{
//    func saveUsersToCloudKit()
//    {
//        for myItem in myDatabaseConnection.getUsersForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Users"))
//        {
//            saveUsersRecordToCloudKit(myItem)
//        }
//    }
//    
//    func updateUsersInCoreData()
//    {
//        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "Users") as CVarArg)
//        let query: CKQuery = CKQuery(recordType: "Users", predicate: predicate)
//        
//        let operation = CKQueryOperation(query: query)
//        
//        waitFlag = true
//        
//        operation.recordFetchedBlock = { (record) in
//            self.recordCount += 1
//            
//            self.updateUsersRecord(record)
//            self.recordCount -= 1
//            
//            usleep(useconds_t(self.sleepTime))
//        }
//        let operationQueue = OperationQueue()
//        
//        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
//        
//        while waitFlag
//        {
//            sleep(UInt32(0.5))
//        }
//    }
//    
//    func deleteUsers(UsersID: Int32)
//    {
//        let sem = DispatchSemaphore(value: 0);
//        
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID)) AND (UsersID == \(UsersID))")
//        let query: CKQuery = CKQuery(recordType: "Users", predicate: predicate)
//        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
//            for record in results!
//            {
//                myRecordList.append(record.recordID)
//            }
//            self.performPublicDelete(myRecordList)
//            sem.signal()
//        })
//        
//        sem.wait()
//    }
//    
//    func replaceUsersInCoreData()
//    {
//        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
//        let query: CKQuery = CKQuery(recordType: "Users", predicate: predicate)
//        let operation = CKQueryOperation(query: query)
//        
//        waitFlag = true
//        
//        operation.recordFetchedBlock = { (record) in
//            let UsersLine1 = record.object(forKey: "UsersLine1") as! String
//            let UsersLine2 = record.object(forKey: "UsersLine2") as! String
//            
//            var UsersID: Int32 = 0
//            if record.object(forKey: "UsersID") != nil
//            {
//                UsersID = record.object(forKey: "UsersID") as! Int32
//            }
//            
//            var updateTime = Date()
//            if record.object(forKey: "updateTime") != nil
//            {
//                updateTime = record.object(forKey: "updateTime") as! Date
//            }
//            
//            var updateType: String = ""
//            if record.object(forKey: "updateType") != nil
//            {
//                updateType = record.object(forKey: "updateType") as! String
//            }
//            
//            myDatabaseConnection.replaceUsers(UsersID,
//                                                UsersLine1: UsersLine1,
//                                                UsersLine2: UsersLine2,
//                                                , updateTime: updateTime, updateType: updateType)
//            
//            usleep(useconds_t(self.sleepTime))
//        }
//        
//        let operationQueue = OperationQueue()
//        
//        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
//        
//        while waitFlag
//        {
//            sleep(UInt32(0.5))
//        }
//    }
//    
//    func saveUsersRecordToCloudKit(_ sourceRecord: Users)
//    {
//        let sem = DispatchSemaphore(value: 0)
//        
//        let predicate = NSPredicate(format: "(UsersID == \(sourceRecord.UsersID)) AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
//        let query = CKQuery(recordType: "Users", predicate: predicate)
//        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
//            if error != nil
//            {
//                NSLog("Error querying records: \(error!.localizedDescription)")
//            }
//            else
//            {
//                // Lets go and get the additional details from the context1_1 table
//                
//                if records!.count > 0
//                {
//                    let record = records!.first// as! CKRecord
//                    // Now you have grabbed your existing record from iCloud
//                    // Apply whatever changes you want
//                    
//                    record!.setValue(sourceRecord.UsersID, forKey: "UsersID")
//                    record!.setValue(sourceRecord.UsersLine1, forKey: "ddressLine1")
//                    record!.setValue(sourceRecord.UsersLine2, forKey: "UsersLine2")
//                    
//                    if sourceRecord.updateTime != nil
//                    {
//                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
//                    }
//                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
//                    
//                    // Save this record again
//                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
//                        if saveError != nil
//                        {
//                            NSLog("Error saving record: \(saveError!.localizedDescription)")
//                        }
//                        else
//                        {
//                            if debugMessages
//                            {
//                                NSLog("Successfully updated record!")
//                            }
//                        }
//                    })
//                }
//                else
//                {  // Insert
//                    let record = CKRecord(recordType: "Users")
//                    record.setValue(sourceRecord.UsersID, forKey: "UsersID")
//                    record.setValue(sourceRecord.UsersLine1, forKey: "ddressLine1")
//                    record.setValue(sourceRecord.UsersLine2, forKey: "UsersLine2")
//                    
//                    record.setValue(myTeamID, forKey: "teamID")
//                    
//                    if sourceRecord.updateTime != nil
//                    {
//                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
//                    }
//                    record.setValue(sourceRecord.updateType, forKey: "updateType")
//                    
//                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
//                        if saveError != nil
//                        {
//                            NSLog("Error saving record: \(saveError!.localizedDescription)")
//                        }
//                        else
//                        {
//                            if debugMessages
//                            {
//                                NSLog("Successfully saved record!")
//                            }
//                        }
//                    })
//                }
//            }
//            sem.signal()
//        })
//        sem.wait()
//    }
//    
//    func updateUsersRecord(_ sourceRecord: CKRecord)
//    {
//        let UsersLine1 = sourceRecord.object(forKey: "UsersLine1") as! String
//        let UsersLine2 = sourceRecord.object(forKey: "UsersLine2") as! String
//        
//        var UsersID: Int32 = 0
//        if sourceRecord.object(forKey: "UsersID") != nil
//        {
//            UsersID = sourceRecord.object(forKey: "UsersID") as! Int32
//        }
//        
//        var updateTime = Date()
//        if sourceRecord.object(forKey: "updateTime") != nil
//        {
//            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
//        }
//        
//        var updateType: String = ""
//        if sourceRecord.object(forKey: "updateType") != nil
//        {
//            updateType = sourceRecord.object(forKey: "updateType") as! String
//        }
//        
//        myDatabaseConnection.saveUsers(UsersID,
//                                         UsersLine1: UsersLine1,
//                                         UsersLine2: UsersLine2,
//                                         
//                                         , updateTime: updateTime, updateType: updateType)
//    }
//}
//
