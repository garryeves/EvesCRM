//
//  userTeamsClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 12/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class userTeams: NSObject
{
    fileprivate var myUserTeams:[userTeamItem] = Array()
    
    init(userID: Int)
    {
        for myItem in myDatabaseConnection.getTeamsForUser(userID: userID)
        {
            let myObject = userTeamItem(userID: Int(myItem.userID), teamID: Int(myItem.teamID))
            myUserTeams.append(myObject)
        }
    }
    
    init(teamID: Int)
    {
        for myItem in myDatabaseConnection.getUsersForTeam(teamID: teamID)
        {
            let myObject = userTeamItem(userID: Int(myItem.userID), teamID: Int(myItem.teamID))
            myUserTeams.append(myObject)
        }
    }
    
    var UserTeams: [userTeamItem]
    {
        get
        {
            return myUserTeams
        }
    }
}

class userTeamItem: NSObject
{
    fileprivate var myTeamID: Int = 0
    fileprivate var myUserID: Int = 0
    
    var teamID: Int
    {
        get
        {
            return myTeamID
        }
    }
    
    var userID: Int
    {
        get
        {
            return myUserID
        }
    }
    
    init(userID: Int,
         teamID: Int
         )
    {
        super.init()
        
        myTeamID = teamID
        myUserID = userID
    }
    
    func save()
    {
        myDatabaseConnection.saveUserTeam(myUserID, teamID: myTeamID)
    }
    
    func delete()
    {
        myDatabaseConnection.deleteUserTeam(myUserID, teamID: myTeamID)
    }
}

extension coreDatabase
{
    func saveUserTeam(_ userID: Int,
                       teamID: Int,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: UserTeams!
        
        let myReturn = getUserTeamsDetails(userID, teamID: teamID)
        
        if myReturn.count == 0
        { // Add
            myItem = UserTeams(context: objectContext)
            myItem.teamID = Int64(teamID)
            myItem.userID = Int64(userID)
            
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
        
        saveContext()
    }
    
    func replaceUserTeam(_ userID: Int,
                          teamID: Int,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = UserTeams(context: objectContext)
        myItem.teamID = Int64(teamID)
        myItem.userID = Int64(userID)
        
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
    
    func deleteUserTeam(_ userID: Int,
                         teamID: Int)
    {
        let myReturn = getUserTeamsDetails(userID, teamID: teamID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getTeamsForUser(userID: Int)->[UserTeams]
    {
        let fetchRequest = NSFetchRequest<UserTeams>(entityName: "UserTeams")
        
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
    
    func getUsersForTeam(teamID: Int)->[UserTeams]
    {
        let fetchRequest = NSFetchRequest<UserTeams>(entityName: "UserTeams")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID)) && (updateType != \"Delete\")")
        
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
    
    func getUserTeamsDetails(_ userID: Int, teamID: Int)->[UserTeams]
    {
        let fetchRequest = NSFetchRequest<UserTeams>(entityName: "UserTeams")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(userID == \(userID)) AND (teamID == \(teamID)) && (updateType != \"Delete\")")
        
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
    
    func resetAllUserTeams()
    {
        let fetchRequest = NSFetchRequest<UserTeams>(entityName: "UserTeams")
        
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
    
    func clearDeletedUserTeams(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<UserTeams>(entityName: "UserTeams")
        
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
    
    func clearSyncedUserTeams(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<UserTeams>(entityName: "UserTeams")
        
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
    
    func getUserTeamsForSync(_ syncDate: Date) -> [UserTeams]
    {
        let fetchRequest = NSFetchRequest<UserTeams>(entityName: "UserTeams")
        
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
    
    func deleteAllUserTeams()
    {
        let fetchRequest2 = NSFetchRequest<UserTeams>(entityName: "UserTeams")
        
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
    func saveUserTeamsToCloudKit()
    {
        for myItem in myDatabaseConnection.getUserTeamsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "UserTeams"))
        {
            saveUserTeamsRecordToCloudKit(myItem)
        }
    }
    
    func updateUserTeamsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "UserTeams") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "UserTeams", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateUserTeamsRecord(record)
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
    
    func deleteUserTeams(userID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (userID == \(userID))")
        let query: CKQuery = CKQuery(recordType: "UserTeams", predicate: predicate)
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
    
    func replaceUserTeamsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "UserTeams", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            var userID: Int = 0
            if record.object(forKey: "userID") != nil
            {
                userID = record.object(forKey: "userID") as! Int
            }
            
            var teamID: Int = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int
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
            
            myDatabaseConnection.replaceUserTeam(userID,
                                                teamID: teamID
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
    
    func saveUserTeamsRecordToCloudKit(_ sourceRecord: UserTeams)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(userID == \(sourceRecord.userID)) AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "UserTeams", predicate: predicate)
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
                    // Do nothing
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "UserTeams")
                    record.setValue(sourceRecord.userID, forKey: "userID")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
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
    
    func updateUserTeamsRecord(_ sourceRecord: CKRecord)
    {
        var userID: Int = 0
        if sourceRecord.object(forKey: "userID") != nil
        {
            userID = sourceRecord.object(forKey: "userID") as! Int
        }
        
        var teamID: Int = 0
        if sourceRecord.object(forKey: "teamID") != nil
        {
            teamID = sourceRecord.object(forKey: "teamID") as! Int
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
        
        myDatabaseConnection.saveUserTeam(userID,
                                         teamID: teamID
                                         , updateTime: updateTime, updateType: updateType)
    }
}

