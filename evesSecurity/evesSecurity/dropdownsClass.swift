//
//  dropdownsClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class dropdowns: NSObject
{
    fileprivate var myDropdowns:[dropdownItem] = Array()
    fileprivate var myDropdownTypes: [String] = Array()
    
    init(teamID: Int)
    {
        myDropdownTypes = myDatabaseConnection.getDropdownsTypes(teamID: teamID)
    }
    
    init(dropdownType: String, teamID: Int)
    {
        for myItem in myDatabaseConnection.getDropdowns(dropdownType: dropdownType, teamID: teamID)
        {
            let myObject = dropdownItem(dropdownType: myItem.dropDownType!,
                                   dropdownValue: myItem.dropDownValue!,
                                   teamID: Int(myItem.teamID)
                                   )
            myDropdowns.append(myObject)
        }
    }
    
    var dropdowns: [dropdownItem]
    {
        get
        {
            return myDropdowns
        }
    }
    
    var dropDownTypes: [String]
    {
        return myDropdownTypes
    }
}

class dropdownItem: NSObject
{
    fileprivate var myDropdownValue: String = ""
    fileprivate var myDropdownType: String = ""
    fileprivate var myTeamID: Int = 0
    
    var dropdownType: String
    {
        get
        {
            return myDropdownType
        }
    }
    
    var dropdownValue: String
    {
        get
        {
            return myDropdownValue
        }
        set
        {
            myDropdownValue = newValue
            save()
        }
    }
    
    init(dropdownType: String, teamID: Int)
    {
        super.init()
        
        myDropdownType = dropdownType
        myTeamID = teamID
        save()
    }
    
    init(dropdownType: String, dropdownValue: String, teamID: Int)
    {
        super.init()
        
        myDropdownType = dropdownType
        myDropdownValue = dropdownValue
        myTeamID = teamID
        save()
    }
    
    func save()
    {
        if currentUser.checkPermission(adminRoleType) == writePermission
        {
            myDatabaseConnection.saveDropdowns(myDropdownType, dropdownValue: myDropdownValue, teamID: myTeamID)
        }
    }
    
    func delete()
    {
        if currentUser.checkPermission(adminRoleType) == writePermission
        {
            myDatabaseConnection.deleteDropdowns(myDropdownType, dropdownValue: myDropdownValue, teamID: myTeamID)
        }
    }
}

extension coreDatabase
{
    func saveDropdowns(_ dropdownType: String,
                        dropdownValue: String,
                        teamID: Int,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Dropdowns!
        
        let myReturn = getDropdowns(dropdownType: dropdownType, dropdownValue: dropdownValue, teamID: teamID)
        
        if myReturn.count == 0
        { // Add
            myItem = Dropdowns(context: objectContext)
            myItem.dropDownType = dropdownType
            myItem.dropDownValue = dropdownValue
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

        self.recordsProcessed += 1
    }
    
    func deleteDropdowns(_ dropdownType: String, dropdownValue: String, teamID: Int)
    {
        let myReturn = getDropdowns(dropdownType: dropdownType, dropdownValue: dropdownValue, teamID: teamID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getDropdownsTypes(teamID: Int)->[String]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Dropdowns")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (dropDownType != 'Privacy') AND (dropDownType != 'ProjectType') AND (dropDownType != 'Reports') AND (dropDownType != 'RoleAccess') AND (dropDownType != 'RoleType') AND (dropDownType !=  'ShiftType') AND (dropDownType != 'TeamState') AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .dictionaryResultType
        
        fetchRequest.propertiesToFetch = ["dropDownType"]
        fetchRequest.returnsDistinctResults = true
        
        let sortDescriptor = NSSortDescriptor(key: "dropDownType", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            var returnArray: [String] = Array()
            
            let resultsDict = fetchResults as! [[String: String]]
            
            for myItem in resultsDict
            {
                returnArray.append(myItem["dropDownType"]!)
            }
            
 //           returnArray.sorted({$0 < $1})
            
            return returnArray
        }
        catch
        {
            print("Error occurred during execution: D \(error.localizedDescription)")
            return []
        }
    }
    
    func getDropdowns(dropdownType: String, teamID: Int)->[Dropdowns]
    {
        let fetchRequest = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (dropDownType == \"\(dropdownType)\") && (updateType != \"Delete\")")
        
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
            print("Error occurred during execution: D \(error.localizedDescription)")
            return []
        }
    }
    
    func getDropdowns(dropdownType: String, dropdownValue: String, teamID: Int)->[Dropdowns]
    {
        let fetchRequest = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(dropDownType == \"\(dropdownType)\") AND (dropDownValue == \"\(dropdownValue)\") AND (teamID == \(teamID)) && (updateType != \"Delete\")")
        
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
            print("Error occurred during execution: E \(error.localizedDescription)")
            return []
        }
    }
    
    func resetAllDropdowns(teamID: Int)
    {
        let fetchRequest = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
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
            print("Error occurred during execution: F \(error.localizedDescription)")
        }
        
        saveContext()
    }
    
    func clearDeletedDropdowns(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
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
            print("Error occurred during execution: G \(error.localizedDescription)")
        }
        saveContext()
    }
    
    func clearSyncedDropdowns(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
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
            print("Error occurred during execution: H \(error.localizedDescription)")
        }
        
        saveContext()
    }
    
    func getDropdownsForSync(_ syncDate: Date) -> [Dropdowns]
    {
        let fetchRequest = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
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
            print("Error occurred during execution: I \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAllDropdowns(teamID: Int)
    {
        let fetchRequest2 = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
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
            print("Error occurred during execution: J \(error.localizedDescription)")
        }
        
        saveContext()
    }
    
    func deleteDropdowns(_ forType: String, teamID: Int)
    {
        let fetchRequest = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (dropDownType == \"\(forType)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                self.objectContext.delete(myItem as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: J \(error.localizedDescription)")
        }
        
        saveContext()
    }
    
    
    func fixDropDowns()
    {
        // first delete the unneeded ones
        let fetchRequest = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "((dropDownType == 'ProjectType') OR (dropDownType == 'Reports') OR (dropDownType == 'RoleAccess') OR (dropDownType == 'RoleType') OR (dropDownType ==  'ShiftType') OR (dropDownType == 'TeamState')) AND (updateType != \"Delete\")")
        
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                myItem.updateTime = NSDate()
                myItem.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: J \(error.localizedDescription)")
        }
        
        saveContext()
        
        // Now we rename
        
        let fetchRequest1 = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate1 = NSPredicate(format: "updateType != \"Delete\"")
        
        // Set the predicate on the fetch request
        fetchRequest1.predicate = predicate1
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults1 = try objectContext.fetch(fetchRequest1)
            for myItem in fetchResults1
            {
                if myItem.dropDownType == "Event"
                {
                    myItem.dropDownType = "Event Project"
                    myItem.updateTime = NSDate()
                }
                
                if myItem.dropDownType == "Regular"
                {
                    myItem.dropDownType = "Regular Project"
                    myItem.updateTime = NSDate()
                }
                
                if myItem.dropDownType == "Sales"
                {
                    myItem.dropDownType = "Sales Project"
                    myItem.updateTime = NSDate()
                }
                
                if myItem.dropDownType == "Roles"
                {
                    myItem.dropDownType = "Project Roles"
                    myItem.updateTime = NSDate()
                }
                
                if myItem.dropDownType == "ShowRole"
                {
                    myItem.dropDownType = "Event Roles"
                    myItem.updateTime = NSDate()
                }
            }
        }
        catch
        {
            print("Error occurred during execution: D \(error.localizedDescription)")
        }
        saveContext()
        
        let fetchRequest2 = NSFetchRequest<Dropdowns>(entityName: "Dropdowns")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate2 = NSPredicate(format: "(dropDownType == \"ProjectType\") AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate2
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem in fetchResults2
            {
                if myItem.dropDownValue == "Event"
                {
                    myItem.dropDownValue = "Event Project"
                    myItem.updateTime = NSDate()
                }
                
                if myItem.dropDownValue == "Regular"
                {
                    myItem.dropDownValue = "Regular Project"
                    myItem.updateTime = NSDate()
                }
                
                if myItem.dropDownValue == "Sales"
                {
                    myItem.dropDownValue = "Sales Project"
                    myItem.updateTime = NSDate()
                }
                
                if myItem.dropDownValue == "Project"
                {
                    myItem.updateType = "Delete"
                    myItem.updateTime = NSDate()
                }
            }
        }
        catch
        {
            print("Error occurred during execution: D \(error.localizedDescription)")
        }
        saveContext()
        
        let fetchRequest3 = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate3 = NSPredicate(format: "updateType != \"Delete\"")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate3
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults3 = try objectContext.fetch(fetchRequest3)
            for myItem in fetchResults3
            {
                if myItem.type == "Event"
                {
                    myItem.type = "Event Project"
                    myItem.updateTime = NSDate()
                }
                
                if myItem.type == "Regular"
                {
                    myItem.type = "Regular Project"
                    myItem.updateTime = NSDate()
                }
                
                if myItem.type == "Sales"
                {
                    myItem.type = "Sales Project"
                    myItem.updateTime = NSDate()
                }
                
                if myItem.type == "Project"
                {
                    myItem.type = "Regular Project"
                    myItem.updateTime = NSDate()
                }
            }
        }
        catch
        {
            print("Error occurred during execution: D \(error.localizedDescription)")
        }
        saveContext()
    }
}

extension CloudKitInteraction
{
    func saveDropdownsToCloudKit()
    {
        for myItem in myDatabaseConnection.getDropdownsForSync(getSyncDateForTable(tableName: "Dropdowns"))
        {
            saveDropdownsRecordToCloudKit(myItem)
        }
    }
    
    func updateDropdownsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", getSyncDateForTable(tableName: "Dropdowns") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Dropdowns", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateDropdownsRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Dropdowns", queryOperation: operation, onOperationQueue: operationQueue)
    }
    
//    func deleteDropdowns(dropdownType: String, dropdownName: String)
//    {
//        let sem = DispatchSemaphore(value: 0);
//
//        var myRecordList: [CKRecordID] = Array()
//        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (dropDownType == \"\(dropdownType)\") AND (dropdownName == \"\(dropdownName)\")")
//        let query: CKQuery = CKQuery(recordType: "Dropdowns", predicate: predicate)
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
    
    func saveDropdownsRecordToCloudKit(_ sourceRecord: Dropdowns)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(dropDownType == \"\(sourceRecord.dropDownType!)\") AND (dropDownValue == \"\(sourceRecord.dropDownValue!)\") AND (teamID == \(sourceRecord.teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Dropdowns", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: A \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.dropDownValue, forKey: "dropDownValue")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: B \(saveError!.localizedDescription)")
                            self.saveOK = false
                            print("next level = \(saveError!)")
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
                    let record = CKRecord(recordType: "Dropdowns")
                    record.setValue(sourceRecord.dropDownType, forKey: "dropDownType")
                    record.setValue(sourceRecord.dropDownValue, forKey: "dropDownValue")
                    
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: C \(saveError!.localizedDescription)")
                            self.saveOK = false
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
    
    func updateDropdownsRecord(_ sourceRecord: CKRecord)
    {

        let dropdownType = sourceRecord.object(forKey: "dropDownType") as! String
        let dropDownValue = sourceRecord.object(forKey: "dropDownValue") as! String
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
        
        myDatabaseConnection.recordsToChange += 1
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }

        self.recordCount += 1
        
        myDatabaseConnection.saveDropdowns(dropdownType,
                                         dropdownValue: dropDownValue,
                                         teamID: teamID
                                         , updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
}

