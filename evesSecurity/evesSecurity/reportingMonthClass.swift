//
//  reportingMonthClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class reportingMonths: NSObject
{
    fileprivate var myReportingMonth:[reportingMonthItem] = Array()
    
    override init()
    {
        for myItem in myDatabaseConnection.getReportingMonth()
        {
            let myObject = reportingMonthItem(monthStartDate: myItem.monthStartDate! as Date,
                                          monthName: myItem.monthName!,
                                          yearName: myItem.yearName!
                                   )
            myReportingMonth.append(myObject)
        }
    }
    
    var reportingMonth: [reportingMonthItem]
    {
        get
        {
            return myReportingMonth
        }
    }
}

class reportingMonthItem: NSObject
{
    fileprivate var myMonthStartDate: Date!
    fileprivate var myMonthName: String = ""
    fileprivate var myYearName: String = ""

    var monthStartDate: Date
    {
        get
        {
            return myMonthStartDate
        }
    }
    
    var monthName: String
    {
        get
        {
            return myMonthName
        }
        set
        {
            myMonthName = newValue
            save()
        }
    }
    
    var yearName: String
    {
        get
        {
            return myYearName
        }
        set
        {
            myYearName = newValue
            save()
        }
    }
    
    init(monthStartDate: Date)
    {
        super.init()
        let myReturn = myDatabaseConnection.getReportingMonthDetails(monthStartDate)
        
        for myItem in myReturn
        {
            myMonthStartDate = myItem.monthStartDate! as Date
            myMonthName = myItem.monthName!
            myYearName = myItem.yearName!
        }
    }
    
    init(monthStartDate: Date,
         monthName: String,
         yearName: String
         )
    {
        super.init()
        
        myMonthStartDate = monthStartDate
        myMonthName = monthName
        myYearName = yearName
    }
    
    func save()
    {
        myDatabaseConnection.saveReportingMonth(myMonthStartDate,
                                         monthName: myMonthName,
                                         yearName: myYearName
                                         )
    }
    
    func delete()
    {
        myDatabaseConnection.deleteReportingMonth(myMonthStartDate)
    }
}

extension coreDatabase
{
    func saveReportingMonth(_ monthStartDate: Date,
                     monthName: String,
                     yearName: String,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: ReportingMonth!
        
        let myReturn = getReportingMonthDetails(monthStartDate)
        
        if myReturn.count == 0
        { // Add
            myItem = ReportingMonth(context: objectContext)
            myItem.monthStartDate = monthStartDate as NSDate
            myItem.monthName = monthName
            myItem.yearName = yearName
            
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
            myItem.monthName = monthName
            myItem.yearName = yearName
            
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
    
    func replaceReportingMonth(_ monthStartDate: Date,
                               monthName: String,
                               yearName: String,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myItem = ReportingMonth(context: objectContext)
        myItem.monthStartDate = monthStartDate as NSDate
        myItem.monthName = monthName
        myItem.yearName = yearName
        
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
    
    func deleteReportingMonth(_ monthStartDate: Date)
    {
        let myReturn = getReportingMonthDetails(monthStartDate)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getReportingMonth()->[ReportingMonth]
    {
        let fetchRequest = NSFetchRequest<ReportingMonth>(entityName: "ReportingMonth")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "monthStartDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
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
    
    func getReportingMonthDetails(_ monthStartDate: Date)->[ReportingMonth]
    {
        let fetchRequest = NSFetchRequest<ReportingMonth>(entityName: "ReportingMonth")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(monthStartDate == %@) && (updateType != \"Delete\")", monthStartDate as CVarArg)
        
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
    
    func resetAllReportingMonth()
    {
        let fetchRequest = NSFetchRequest<ReportingMonth>(entityName: "ReportingMonth")
        
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
    
    func clearDeletedReportingMonth(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<ReportingMonth>(entityName: "ReportingMonth")
        
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
    
    func clearSyncedReportingMonth(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<ReportingMonth>(entityName: "ReportingMonth")
        
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
    
    func getReportingMonthForSync(_ syncDate: Date) -> [ReportingMonth]
    {
        let fetchRequest = NSFetchRequest<ReportingMonth>(entityName: "ReportingMonth")
        
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
    
    func deleteAllReportingMonth()
    {
        let fetchRequest2 = NSFetchRequest<ReportingMonth>(entityName: "ReportingMonth")
        
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
    func saveReportingMonthToCloudKit()
    {
        for myItem in myDatabaseConnection.getReportingMonthForSync(myDatabaseConnection.getSyncDateForTable(tableName: "ReportingMonth"))
        {
            saveReportingMonthRecordToCloudKit(myItem)
        }
    }
    
    func updateReportingMonthInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(myTeamID))", myDatabaseConnection.getSyncDateForTable(tableName: "ReportingMonth") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "ReportingMonth", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1
            
            self.updateReportingMonthRecord(record)
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
    
    func deleteReportingMonth(ReportingMonthID: Int32)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID)) AND (monthStartDate == \(ReportingMonthID))")
        let query: CKQuery = CKQuery(recordType: "ReportingMonth", predicate: predicate)
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
    
    func replaceReportingMonthInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(myTeamID))")
        let query: CKQuery = CKQuery(recordType: "ReportingMonth", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let monthName = record.object(forKey: "monthName") as! String
            let yearName = record.object(forKey: "yearName") as! String
            
            var monthStartDate = Date()
            if record.object(forKey: "monthStartDate") != nil
            {
                monthStartDate = record.object(forKey: "monthStartDate") as! Date
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
            
            myDatabaseConnection.replaceReportingMonth(monthStartDate,
                                                monthName: monthName,
                                                yearName: yearName
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
    
    func saveReportingMonthRecordToCloudKit(_ sourceRecord: ReportingMonth)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(monthStartDate == \(sourceRecord.monthStartDate!)) AND (teamID == \(myTeamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "ReportingMonth", predicate: predicate)
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
                    
                    record!.setValue(sourceRecord.monthName, forKey: "monthName")
                    record!.setValue(sourceRecord.yearName, forKey: "yearName")
                    
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
                    let record = CKRecord(recordType: "ReportingMonth")
                    record.setValue(sourceRecord.monthStartDate, forKey: "monthStartDate")
                    record.setValue(sourceRecord.monthName, forKey: "monthName")
                    record.setValue(sourceRecord.yearName, forKey: "yearName")
                    
                    record.setValue(myTeamID, forKey: "teamID")
                    
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
    
    func updateReportingMonthRecord(_ sourceRecord: CKRecord)
    {
        let monthName = sourceRecord.object(forKey: "monthName") as! String
        let yearName = sourceRecord.object(forKey: "yearName") as! String
        
        var monthStartDate = Date()
        if sourceRecord.object(forKey: "monthStartDate") != nil
        {
            monthStartDate = sourceRecord.object(forKey: "monthStartDate") as! Date
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
        
        myDatabaseConnection.saveReportingMonth(monthStartDate,
                                         monthName: monthName,
                                         yearName: yearName
                                         , updateTime: updateTime, updateType: updateType)
    }
}

