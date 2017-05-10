//
//  rolesClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 24/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension coreDatabase
{
    func getRoles(_ teamID: Int32)->[Roles]
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID))")
        
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
    
    func deleteAllRoles(_ teamID: Int32)
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        
        let predicate = NSPredicate(format: "(teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.updateTime = NSDate()
                myStage.updateType = "Delete"
                myCloudDB.saveRolesRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func getMaxRoleID()-> Int32
    {
        var retVal: Int32 = 0
        
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        
        fetchRequest.propertiesToFetch = ["roleID"]
        
        let sortDescriptor = NSSortDescriptor(key: "roleID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                retVal = myItem.roleID
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        return retVal + 1
    }
    
    func saveRole(_ roleName: String, teamID: Int32, updateTime: Date =  Date(), updateType: String = "CODE", roleID: Int32 = 0)
    {
        let myRoles = getRole(roleID)
        
        var mySelectedRole: Roles
        if myRoles.count == 0
        {
            mySelectedRole = Roles(context: objectContext)
            
            // Get the role number
            mySelectedRole.roleID = getNextID("Roles")
            mySelectedRole.roleDescription = roleName
            mySelectedRole.teamID = teamID
            if updateType == "CODE"
            {
                mySelectedRole.updateTime =  NSDate()
                mySelectedRole.updateType = "Add"
            }
            else
            {
                mySelectedRole.updateTime = updateTime as NSDate
                mySelectedRole.updateType = updateType
            }
        }
        else
        {
            mySelectedRole = myRoles[0]
            mySelectedRole.roleDescription = roleName
            if updateType == "CODE"
            {
                mySelectedRole.updateTime =  NSDate()
                if mySelectedRole.updateType != "Add"
                {
                    mySelectedRole.updateType = "Update"
                }
            }
            else
            {
                mySelectedRole.updateTime = updateTime as NSDate
                mySelectedRole.updateType = updateType
            }
        }
        
        saveContext()
        
        myCloudDB.saveRolesRecordToCloudKit(mySelectedRole)
    }
    
    func saveCloudRole(_ roleName: String, teamID: Int32, updateTime: Date, updateType: String, roleID: Int32 = 0)
    {
        let myRoles = getRole(roleID)
        
        var mySelectedRole: Roles
        if myRoles.count == 0
        {
            mySelectedRole = Roles(context: objectContext)
            
            // Get the role number
            mySelectedRole.roleID = roleID
            mySelectedRole.roleDescription = roleName
            mySelectedRole.teamID = teamID
            mySelectedRole.updateTime = updateTime as NSDate
            mySelectedRole.updateType = updateType
        }
        else
        {
            mySelectedRole = myRoles[0]
            mySelectedRole.roleDescription = roleName
            mySelectedRole.updateTime = updateTime as NSDate
            mySelectedRole.updateType = updateType
        }
        
        saveContext()
    }
    
    func replaceRole(_ roleName: String, teamID: Int32, updateTime: Date =  Date(), updateType: String = "CODE", roleID: Int32 = 0)
    {
        let mySelectedRole = Roles(context: objectContext)
        
        // Get the role number
        mySelectedRole.roleID = roleID
        mySelectedRole.roleDescription = roleName
        mySelectedRole.teamID = teamID
        if updateType == "CODE"
        {
            mySelectedRole.updateTime =  NSDate()
            mySelectedRole.updateType = "Add"
        }
        else
        {
            mySelectedRole.updateTime = updateTime as NSDate
            mySelectedRole.updateType = updateType
        }
        
        saveContext()
    }
    
    func getRole(_ roleID: Int32, teamID: Int32)->[Roles]
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (roleID == \(roleID))")
        
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
    
    func getRole(_ roleID: Int32)->[Roles]
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (roleID == \(roleID))")
        
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
    
    func deleteRoleEntry(_ roleName: String, teamID: Int32)
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        
        let predicate = NSPredicate(format: "(roleDescription == \"\(roleName)\") && (teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.updateTime =  NSDate()
                myStage.updateType = "Delete"
                myCloudDB.saveRolesRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getRoleDescription(_ roleID: Int32, teamID: Int32)->String
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        let predicate = NSPredicate(format: "(roleID == \(roleID)) && (updateType != \"Delete\") && (teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count == 0
            {
                return ""
            }
            else
            {
                return fetchResults[0].roleDescription!
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return ""
        }
    }

    func clearDeletedRoles(predicate: NSPredicate)
    {
        let fetchRequest14 = NSFetchRequest<Roles>(entityName: "Roles")
        
        // Set the predicate on the fetch request
        fetchRequest14.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults14 = try objectContext.fetch(fetchRequest14)
            for myItem14 in fetchResults14
            {
                objectContext.delete(myItem14 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedRoles(predicate: NSPredicate)
    {
        let fetchRequest14 = NSFetchRequest<Roles>(entityName: "Roles")
        
        // Set the predicate on the fetch request
        fetchRequest14.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults14 = try objectContext.fetch(fetchRequest14)
            for myItem14 in fetchResults14
            {
                myItem14.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func initialiseTeamForRoles(_ teamID: Int32)
    {
        var maxID: Int32 = 1
        
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        
        let sortDescriptor = NSSortDescriptor(key: "roleID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            {
                for myItem in fetchResults
                {
                    myItem.teamID = teamID
                    maxID = myItem.roleID
                }
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Roles", codeValue: tempInt, codeType: "hidden")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func getRolesForSync(_ syncDate: Date) -> [Roles]
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        
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

    func deleteAllRoleRecords()
    {
        let fetchRequest14 = NSFetchRequest<Roles>(entityName: "Roles")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        
        do
        {
            let fetchResults14 = try objectContext.fetch(fetchRequest14)
            for myItem14 in fetchResults14
            {
                self.objectContext.delete(myItem14 as NSManagedObject)
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
    func saveRolesToCloudKit()
    {
        for myItem in myDatabaseConnection.getRolesForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Roles"))
        {
            saveRolesRecordToCloudKit(myItem)
        }
    }

    func updateRolesInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "Roles") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1

            self.updateRolesRecord(record)
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

    func deleteRoles()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
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

    func replaceRolesInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let roleID = record.object(forKey: "roleID") as! Int32
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
            let teamID = record.object(forKey: "teamID") as! Int32
            let roleDescription = record.object(forKey: "roleDescription") as! String
            
            myDatabaseConnection.replaceRole(roleDescription, teamID: teamID, updateTime: updateTime, updateType: updateType, roleID: roleID)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveRolesRecordToCloudKit(_ sourceRecord: Roles)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(roleID == \(sourceRecord.roleID)) AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Roles", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.roleDescription, forKey: "roleDescription")
                    
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
                    let record = CKRecord(recordType: "Roles")
                    record.setValue(sourceRecord.roleID, forKey: "roleID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.roleDescription, forKey: "roleDescription")
                    record.setValue(myTeamID, forKey: "teamID")
                    
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

    func updateRolesRecord(_ sourceRecord: CKRecord)
    {
        let roleID = sourceRecord.object(forKey: "roleID") as! Int32
        var updateTime = Date()
        if sourceRecord.object(forKey: "updateTime") != nil
        {
            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
        }
        
        var updateType = ""
        
        if sourceRecord.object(forKey: "updateType") != nil
        {
            updateType = sourceRecord.object(forKey: "updateType") as! String
        }
        let teamID = sourceRecord.object(forKey: "teamID") as! Int32
        let roleDescription = sourceRecord.object(forKey: "roleDescription") as! String
        
        myDatabaseConnection.saveCloudRole(roleDescription, teamID: teamID, updateTime: updateTime, updateType: updateType, roleID: roleID)
    }
}
