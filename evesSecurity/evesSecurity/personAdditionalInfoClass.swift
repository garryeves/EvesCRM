//
//  personAdditionalInfoClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class personAdditionalInfos: NSObject
{
    fileprivate var myAdditional:[personAdditionalInfo] = Array()
    
    init(teamID: Int)
    {
        for myItem in myDatabaseConnection.getPersonAdditionalInfo(teamID: teamID)
        {
            let myObject = personAdditionalInfo(addInfoID: Int(myItem.addInfoID),
                                   addInfoName: myItem.addInfoName!,
                addInfoType: myItem.addInfoType!,
                teamID: Int(myItem.teamID)
                                   )
            myAdditional.append(myObject)
        }
    }
    
    var personAdditionalInfos: [personAdditionalInfo]
    {
        get
        {
            return myAdditional
        }
    }
}

class personAdditionalInfo: NSObject
{
    fileprivate var myAddInfoID: Int = 0
    fileprivate var myAddInfoName: String = ""
    fileprivate var myAddInfoType: String = ""
    fileprivate var myTeamID: Int = 0
    
    var addInfoID: Int
    {
        get
        {
            return myAddInfoID
        }
    }
    
    var addInfoName: String
    {
        get
        {
            return myAddInfoName
        }
        set
        {
            myAddInfoName = newValue
        }
    }
    
    var addInfoType: String
    {
        get
        {
            return myAddInfoType
        }
        set
        {
            myAddInfoType = newValue
        }
    }
    
    init(teamID: Int)
    {
        super.init()
        
        myAddInfoID = myDatabaseConnection.getNextID("personAdditionalInfo")
        myTeamID = teamID
        
        save()
    }
    
    init(addInfoID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getPersonAdditionalInfoDetails(addInfoID)
        
        for myItem in myReturn
        {
            myAddInfoID = Int(myItem.addInfoID)
            myAddInfoName = myItem.addInfoName!
            myAddInfoType = myItem.addInfoType!
            myTeamID = Int(myItem.teamID)
        }
    }
    
    init(addInfoID: Int,
         addInfoName: String,
         addInfoType: String,
         teamID: Int
         )
    {
        super.init()
        
        myAddInfoID = addInfoID
        myAddInfoName = addInfoName
        myAddInfoType = addInfoType
        myTeamID = teamID
    }
    
    func save()
    {
        myDatabaseConnection.savePersonAdditionalInfo(myAddInfoID,
                                         addInfoName: myAddInfoName,
                                         addInfoType: myAddInfoType,
                                         teamID: myTeamID
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deletePersonAdditionalInfo(myAddInfoID)
    }
}

extension coreDatabase
{
    func savePersonAdditionalInfo(_ addInfoID: Int,
                     addInfoName: String,
                     addInfoType: String,
                     teamID: Int,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: PersonAdditionalInfo!
        
        let myReturn = getPersonAdditionalInfoDetails(addInfoID)
        
        if myReturn.count == 0
        { // Add
            myItem = PersonAdditionalInfo(context: objectContext)
            myItem.addInfoID = Int64(addInfoID)
            myItem.addInfoName = addInfoName
            myItem.addInfoType = addInfoType
            myItem.teamID = Int64(teamID)
            
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
            myItem.addInfoName = addInfoName
            myItem.addInfoType = addInfoType
            
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
    
    func replacePersonAdditionalInfo(_ addInfoID: Int,
                        addInfoName: String,
                        addInfoType: String,
                        teamID: Int,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = PersonAdditionalInfo(context: objectContext)
        myItem.addInfoID = Int64(addInfoID)
        myItem.addInfoName = addInfoName
        myItem.addInfoType = addInfoType
        myItem.teamID = Int64(teamID)
        
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
    
    func deletePersonAdditionalInfo(_ addInfoID: Int)
    {
        let myReturn = getPersonAdditionalInfoDetails(addInfoID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getPersonAdditionalInfo(teamID: Int)->[PersonAdditionalInfo]
    {
        let fetchRequest = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
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
    
    func getPersonAdditionalInfoDetails(_ addInfoID: Int)->[PersonAdditionalInfo]
    {
        let fetchRequest = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(addInfoID == \(addInfoID)) && (updateType != \"Delete\")")
        
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
    
    func resetAllPersonAdditionalInfoDetails()
    {
        let fetchRequest = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
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
    
    func clearDeletedPersonAdditionalInfo(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
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
    
    func clearSyncedPersonAdditionalInfo(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
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
    
    func getPersonAdditionalInfoForSync(_ syncDate: Date) -> [PersonAdditionalInfo]
    {
        let fetchRequest = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
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
    
    func deleteAllPersonAdditionalInfo()
    {
        let fetchRequest2 = NSFetchRequest<PersonAdditionalInfo>(entityName: "PersonAdditionalInfo")
        
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
    func savePersonAdditionalInfoToCloudKit()
    {
        for myItem in myDatabaseConnection.getPersonAdditionalInfoForSync(myDatabaseConnection.getSyncDateForTable(tableName: "PersonAdditionalInfo"))
        {
            savePersonAdditionalInfoRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updatePersonAdditionalInfoInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "PersonAdditionalInfo") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        while waitFlag
        {
            usleep(self.sleepTime)
        }
        
        waitFlag = true

        operation.recordFetchedBlock = { (record) in
            
            while self.recordCount > 0
            {
                usleep(self.sleepTime)
            }

            
            self.recordCount += 1
            self.updatePersonAdditionalInfoRecord(record)
            self.recordCount -= 1
            
//            usleep(self.sleepTime)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "PersonAdditionalInfo", queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }
    
    func deletePersonAdditionalInfo(addInfoID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (addInfoID == \(addInfoID))")
        let query: CKQuery = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
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
    
    func replacePersonAdditionalInfoInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true

        operation.recordFetchedBlock = { (record) in
            let addInfoName = record.object(forKey: "addInfoName") as! String
            let addInfoType = record.object(forKey: "addInfoType") as! String
            
            var addInfoID: Int = 0
            if record.object(forKey: "addInfoID") != nil
            {
                addInfoID = record.object(forKey: "addInfoID") as! Int
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
            
            var teamID: Int = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int
            }
            
            myDatabaseConnection.replacePersonAdditionalInfo(addInfoID,
                                                addInfoName: addInfoName,
                                                addInfoType: addInfoType,
                                                teamID: teamID
                                                , updateTime: updateTime, updateType: updateType)
            
            usleep(self.sleepTime)
        }
        
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "PersonAdditionalInfo", queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }
    
    func savePersonAdditionalInfoRecordToCloudKit(_ sourceRecord: PersonAdditionalInfo, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(addInfoName == \"\(sourceRecord.addInfoName!)\") AND \(buildTeamList(currentUser.userID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "PersonAdditionalInfo", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: GRE A - \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.addInfoID, forKey: "addInfoID")
                    record!.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record!.setValue(sourceRecord.addInfoType, forKey: "addInfoType")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record:  GRE B - \(saveError!.localizedDescription)")
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
                    let record = CKRecord(recordType: "PersonAdditionalInfo")
                    record.setValue(sourceRecord.addInfoName, forKey: "addInfoName")
                    record.setValue(sourceRecord.addInfoType, forKey: "addInfoType")
                    
                    record.setValue(teamID, forKey: "teamID")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record:  GRE C - \(saveError!.localizedDescription)")
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
    
    func updatePersonAdditionalInfoRecord(_ sourceRecord: CKRecord)
    {
        let addInfoName = sourceRecord.object(forKey: "addInfoName") as! String
        let addInfoType = sourceRecord.object(forKey: "addInfoType") as! String
        
        var addInfoID: Int = 0
        if sourceRecord.object(forKey: "addInfoID") != nil
        {
            addInfoID = sourceRecord.object(forKey: "addInfoID") as! Int
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
        
        var teamID: Int = 0
        if sourceRecord.object(forKey: "teamID") != nil
        {
            teamID = sourceRecord.object(forKey: "teamID") as! Int
        }
        
        myDatabaseConnection.savePersonAdditionalInfo(addInfoID,
                                         addInfoName: addInfoName,
                                         addInfoType: addInfoType,
                                         teamID: teamID
                                         , updateTime: updateTime, updateType: updateType)
    }
    
}
