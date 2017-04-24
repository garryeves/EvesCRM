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
    func getRoles(_ inTeamID: Int)->[Roles]
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
    
    func deleteAllRoles(_ inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        
        let predicate = NSPredicate(format: "(teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.updateTime = Date()
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
    
    func getMaxRoleID()-> Int
    {
        var retVal: Int = 0
        
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
                retVal = myItem.roleID as! Int
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        return retVal + 1
    }
    
    func saveRole(_ roleName: String, teamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE", roleID: Int = 0)
    {
        let myRoles = getRole(roleID)
        
        var mySelectedRole: Roles
        if myRoles.count == 0
        {
            mySelectedRole = Roles(context: objectContext)
            
            // Get the role number
            mySelectedRole.roleID = NSNumber(value: getNextID("Roles"))
            mySelectedRole.roleDescription = roleName
            mySelectedRole.teamID = NSNumber(value: teamID)
            if inUpdateType == "CODE"
            {
                mySelectedRole.updateTime =  Date()
                mySelectedRole.updateType = "Add"
            }
            else
            {
                mySelectedRole.updateTime = inUpdateTime
                mySelectedRole.updateType = inUpdateType
            }
        }
        else
        {
            mySelectedRole = myRoles[0]
            mySelectedRole.roleDescription = roleName
            if inUpdateType == "CODE"
            {
                mySelectedRole.updateTime =  Date()
                if mySelectedRole.updateType != "Add"
                {
                    mySelectedRole.updateType = "Update"
                }
            }
            else
            {
                mySelectedRole.updateTime = inUpdateTime
                mySelectedRole.updateType = inUpdateType
            }
        }
        
        saveContext()
        
        myCloudDB.saveRolesRecordToCloudKit(mySelectedRole)
    }
    
    func saveCloudRole(_ roleName: String, teamID: Int, inUpdateTime: Date, inUpdateType: String, roleID: Int = 0)
    {
        let myRoles = getRole(roleID)
        
        var mySelectedRole: Roles
        if myRoles.count == 0
        {
            mySelectedRole = Roles(context: objectContext)
            
            // Get the role number
            mySelectedRole.roleID = NSNumber(value: roleID)
            mySelectedRole.roleDescription = roleName
            mySelectedRole.teamID = NSNumber(value: teamID)
            mySelectedRole.updateTime = inUpdateTime
            mySelectedRole.updateType = inUpdateType
        }
        else
        {
            mySelectedRole = myRoles[0]
            mySelectedRole.roleDescription = roleName
            mySelectedRole.updateTime = inUpdateTime
            mySelectedRole.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func replaceRole(_ roleName: String, teamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE", roleID: Int = 0)
    {
        let mySelectedRole = Roles(context: objectContext)
        
        // Get the role number
        mySelectedRole.roleID = NSNumber(value: roleID)
        mySelectedRole.roleDescription = roleName
        mySelectedRole.teamID = NSNumber(value: teamID)
        if inUpdateType == "CODE"
        {
            mySelectedRole.updateTime =  Date()
            mySelectedRole.updateType = "Add"
        }
        else
        {
            mySelectedRole.updateTime = inUpdateTime
            mySelectedRole.updateType = inUpdateType
        }
        
        saveContext()
    }
    
    func getRole(_ roleID: Int, teamID: Int)->[Roles]
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
    
    func getRole(_ roleID: Int)->[Roles]
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
    
    func deleteRoleEntry(_ inRoleName: String, inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        
        let predicate = NSPredicate(format: "(roleDescription == \"\(inRoleName)\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.updateTime =  Date()
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
    
    func getRoleDescription(_ inRoleID: NSNumber, inTeamID: Int)->String
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        let predicate = NSPredicate(format: "(roleID == \(inRoleID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
                return fetchResults[0].roleDescription
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
    
    func initialiseTeamForRoles(_ inTeamID: Int)
    {
        var maxID: Int = 1
        
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
                    myItem.teamID = NSNumber(value: inTeamID)
                    maxID = myItem.roleID as! Int
                }
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Roles", inCodeValue: tempInt, inCodeType: "hidden")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func getRolesForSync(_ inLastSyncDate: NSDate) -> [Roles]
    {
        let fetchRequest = NSFetchRequest<Roles>(entityName: "Roles")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
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
    func saveRolesToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing Roles")
        for myItem in myDatabaseConnection.getRolesForSync(inLastSyncDate)
        {
            saveRolesRecordToCloudKit(myItem)
        }
    }

    func updateRolesInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateRolesRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteRoles()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performDelete(myRecordList)
            sem.signal()
        })
        sem.wait()
    }

    func replaceRolesInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Roles", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let roleID = record.object(forKey: "roleID") as! Int
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let teamID = record.object(forKey: "teamID") as! Int
                let roleDescription = record.object(forKey: "roleDescription") as! String
                
                myDatabaseConnection.replaceRole(roleDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType, roleID: roleID)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveRolesRecordToCloudKit(_ sourceRecord: Roles)
    {
        let predicate = NSPredicate(format: "(roleID == \(sourceRecord.roleID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Roles", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
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
                    record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    record!.setValue(sourceRecord.roleDescription, forKey: "roleDescription")
                    
                    // Save this record again
                    self.privateDB.save(record!, completionHandler: { (savedRecord, saveError) in
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
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.roleDescription, forKey: "roleDescription")
                    
                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
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
        })
    }

    func updateRolesRecord(_ sourceRecord: CKRecord)
    {
        let roleID = sourceRecord.object(forKey: "roleID") as! Int
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
        let teamID = sourceRecord.object(forKey: "teamID") as! Int
        let roleDescription = sourceRecord.object(forKey: "roleDescription") as! String
        
        myDatabaseConnection.saveCloudRole(roleDescription, teamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType, roleID: roleID)
    }
}
