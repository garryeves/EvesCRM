//
//  projectteamMemberClass.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class projectTeamMember: NSObject
{
    fileprivate var myProjectID: Int = 0
    fileprivate var myProjectMemberNotes: String = ""
    fileprivate var myRoleID: Int = 0
    fileprivate var myTeamMember: String = ""
    fileprivate var myTeamID: Int = 0
    fileprivate var saveCalled: Bool = false
    
    var projectID: Int
    {
        get
        {
            return myProjectID as Int
        }
        set
        {
            myProjectID = newValue
            save()
        }
    }
    
    var projectMemberNotes: String
    {
        get
        {
            return myProjectMemberNotes
        }
        set
        {
            myProjectMemberNotes = newValue
            save()
        }
    }
    
    var roleID: Int
    {
        get
        {
            return myRoleID as Int
        }
        set
        {
            myRoleID = newValue
            save()
        }
    }
    
    var roleName: String
    {
        get
        {
            return myDatabaseConnection.getRoleDescription(NSNumber(value: myRoleID as Int), inTeamID: myTeamID)
        }
    }
    
    var teamMember: String
    {
        get
        {
            return myTeamMember
        }
        set
        {
            myTeamMember = newValue
            save()
        }
    }
    
    init(inProjectID: Int, inTeamMember: String, inRoleID: Int, inTeamID: Int)
    {
        super.init()
        myProjectID = inProjectID
        myTeamMember = inTeamMember
        myRoleID = inRoleID
        myTeamID = inTeamID
        save()
    }
    
    override init()
    {
        // Do nothing
    }
    
    func save()
    {
        myDatabaseConnection.saveTeamMember(myProjectID, inRoleID: myRoleID, inPersonName: myTeamMember, inNotes: myProjectMemberNotes)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(workingGTDLevel.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myProjectTeamRecord = myDatabaseConnection.getTeamMemberRecord(myProjectID, inPersonName: myTeamMember)[0]
        
        myCloudDB.saveProjectTeamMembersRecordToCloudKit(myProjectTeamRecord)
        
        saveCalled = false
    }
    
    func delete()
    {
        myDatabaseConnection.deleteTeamMember(myProjectID, inPersonName: myTeamMember)
    }
}

extension coreDatabase
{
    func saveTeamMember(_ inProjectID: Int, inRoleID: Int, inPersonName: String, inNotes: String, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        var myProjectTeam: ProjectTeamMembers!
        
        let myProjectTeamRecords = getTeamMemberRecord(inProjectID, inPersonName: inPersonName)
        if myProjectTeamRecords.count == 0
        { // Add
            myProjectTeam = ProjectTeamMembers(context: objectContext)
            myProjectTeam.projectID = NSNumber(value: inProjectID)
            myProjectTeam.teamMember = inPersonName
            myProjectTeam.roleID = NSNumber(value: inRoleID)
            myProjectTeam.projectMemberNotes = inNotes
            if inUpdateType == "CODE"
            {
                myProjectTeam.updateTime =  NSDate()
                myProjectTeam.updateType = "Add"
            }
            else
            {
                myProjectTeam.updateTime = inUpdateTime as NSDate
                myProjectTeam.updateType = inUpdateType
            }
        }
        else
        { // Update
            myProjectTeam = myProjectTeamRecords[0]
            myProjectTeam.roleID = NSNumber(value: inRoleID)
            myProjectTeam.projectMemberNotes = inNotes
            if inUpdateType == "CODE"
            {
                myProjectTeam.updateTime =  NSDate()
                if myProjectTeam.updateType != "Add"
                {
                    myProjectTeam.updateType = "Update"
                }
            }
            else
            {
                myProjectTeam.updateTime = inUpdateTime as NSDate
                myProjectTeam.updateType = inUpdateType
            }
        }
        
        saveContext()
    }
    
    func replaceTeamMember(_ inProjectID: Int, inRoleID: Int, inPersonName: String, inNotes: String, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myProjectTeam = ProjectTeamMembers(context: objectContext)
        myProjectTeam.projectID = NSNumber(value: inProjectID)
        myProjectTeam.teamMember = inPersonName
        myProjectTeam.roleID = NSNumber(value: inRoleID)
        myProjectTeam.projectMemberNotes = inNotes
        if inUpdateType == "CODE"
        {
            myProjectTeam.updateTime =  NSDate()
            myProjectTeam.updateType = "Add"
        }
        else
        {
            myProjectTeam.updateTime = inUpdateTime as NSDate
            myProjectTeam.updateType = inUpdateType
        }
        
        saveContext()
        self.refreshObject(myProjectTeam)
    }
    
    func deleteTeamMember(_ inProjectID: Int, inPersonName: String)
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) AND (teamMember == \"\(inPersonName)\")")
        
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
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func getTeamMemberRecord(_ inProjectID: Int, inPersonName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) && (teamMember == \"\(inPersonName)\") && (updateType != \"Delete\")")
        
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
    
    func getTeamMembers(_ inProjectID: NSNumber)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) && (updateType != \"Delete\")")
        
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
    
    func getProjectsForPerson(_ inPersonName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(teamMember == \"\(inPersonName)\") && (updateType != \"Delete\")")
        
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

    func resetProjectTeamMembers()
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.updateTime =  NSDate()
                myStage.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearDeletedProjectTeamMembers(predicate: NSPredicate)
    {
        let fetchRequest12 = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        // Set the predicate on the fetch request
        fetchRequest12.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults12 = try objectContext.fetch(fetchRequest12)
            for myItem12 in fetchResults12
            {
                objectContext.delete(myItem12 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedProjectTeamMembers(predicate: NSPredicate)
    {
        let fetchRequest12 = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        // Set the predicate on the fetch request
        fetchRequest12.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults12 = try objectContext.fetch(fetchRequest12)
            for myItem12 in fetchResults12
            {
                myItem12.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getProjectTeamMembersForSync(_ inLastSyncDate: NSDate) -> [ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
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

    func deleteAllProjectTeamMemberRecords()
    {
        let fetchRequest12 = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults12 = try objectContext.fetch(fetchRequest12)
            for myItem12 in fetchResults12
            {
                self.objectContext.delete(myItem12 as NSManagedObject)
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
    func saveProjectTeamMembersToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing ProjectTeamMembers")
        for myItem in myDatabaseConnection.getProjectTeamMembersForSync(inLastSyncDate)
        {
            saveProjectTeamMembersRecordToCloudKit(myItem)
        }
    }

    func updateProjectTeamMembersInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateProjectTeamMembersRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteProjectTeamMembers()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
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

    func replaceProjectTeamMembersInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let projectID = record.object(forKey: "projectID") as! Int
                let teamMember = record.object(forKey: "teamMember") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let roleID = record.object(forKey: "roleID") as! Int
                let projectMemberNotes = record.object(forKey: "projectMemberNotes") as! String
                
                myDatabaseConnection.replaceTeamMember(projectID, inRoleID: roleID, inPersonName: teamMember, inNotes: projectMemberNotes, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveProjectTeamMembersRecordToCloudKit(_ sourceRecord: ProjectTeamMembers)
    {
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID as! Int)) && (teamMember == \"\(sourceRecord.teamMember!)\")") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
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
                    record!.setValue(sourceRecord.roleID, forKey: "roleID")
                    record!.setValue(sourceRecord.projectMemberNotes, forKey: "projectMemberNotes")
                    
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
                    let record = CKRecord(recordType: "ProjectTeamMembers")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.teamMember, forKey: "teamMember")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.roleID, forKey: "roleID")
                    record.setValue(sourceRecord.projectMemberNotes, forKey: "projectMemberNotes")
                    
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

    func updateProjectTeamMembersRecord(_ sourceRecord: CKRecord)
    {
        let projectID = sourceRecord.object(forKey: "projectID") as! Int
        let teamMember = sourceRecord.object(forKey: "teamMember") as! String
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
        let roleID = sourceRecord.object(forKey: "roleID") as! Int
        let projectMemberNotes = sourceRecord.object(forKey: "projectMemberNotes") as! String
        
        myDatabaseConnection.saveTeamMember(projectID, inRoleID: roleID, inPersonName: teamMember, inNotes: projectMemberNotes, inUpdateTime: updateTime, inUpdateType: updateType)
    }
}
