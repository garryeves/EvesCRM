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
    fileprivate var myProjectID: Int32 = 0
    fileprivate var myProjectMemberNotes: String = ""
    fileprivate var myRoleID: Int32 = 0
    fileprivate var myTeamMember: String = ""
    fileprivate var myTeamID: Int32 = 0
    fileprivate var saveCalled: Bool = false
    
    var projectID: Int32
    {
        get
        {
            return myProjectID
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
    
    var roleID: Int32
    {
        get
        {
            return myRoleID
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
            return myDatabaseConnection.getRoleDescription(myRoleID, teamID: myTeamID)
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
    
    init(projectID: Int32, teamMember: String, roleID: Int32, teamID: Int32)
    {
        super.init()
        myProjectID = projectID
        myTeamMember = teamMember
        myRoleID = roleID
        myTeamID = teamID
        save()
    }
    
    override init()
    {
        // Do nothing
    }
    
    func save()
    {
        myDatabaseConnection.saveTeamMember(myProjectID, roleID: myRoleID, personName: myTeamMember, notes: myProjectMemberNotes)
        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
        }
    }
    
    func performSave()
    {
        let myProjectTeamRecord = myDatabaseConnection.getTeamMemberRecord(myProjectID, personName: myTeamMember)[0]
        
        myCloudDB.saveProjectTeamMembersRecordToCloudKit(myProjectTeamRecord, teamID: currentUser.currentTeam!.teamID)
        
        saveCalled = false
    }
    
    func delete()
    {
        myDatabaseConnection.deleteTeamMember(myProjectID, personName: myTeamMember)
    }
}

extension coreDatabase
{
    func saveTeamMember(_ projectID: Int32, roleID: Int32, personName: String, notes: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myProjectTeam: ProjectTeamMembers!
        
        let myProjectTeamRecords = getTeamMemberRecord(projectID, personName: personName)
        if myProjectTeamRecords.count == 0
        { // Add
            myProjectTeam = ProjectTeamMembers(context: objectContext)
            myProjectTeam.projectID = projectID
            myProjectTeam.teamMember = personName
            myProjectTeam.roleID = roleID
            myProjectTeam.projectMemberNotes = notes
            if updateType == "CODE"
            {
                myProjectTeam.updateTime =  NSDate()
                myProjectTeam.updateType = "Add"
            }
            else
            {
                myProjectTeam.updateTime = updateTime as NSDate
                myProjectTeam.updateType = updateType
            }
        }
        else
        { // Update
            myProjectTeam = myProjectTeamRecords[0]
            myProjectTeam.roleID = roleID
            myProjectTeam.projectMemberNotes = notes
            if updateType == "CODE"
            {
                myProjectTeam.updateTime =  NSDate()
                if myProjectTeam.updateType != "Add"
                {
                    myProjectTeam.updateType = "Update"
                }
            }
            else
            {
                myProjectTeam.updateTime = updateTime as NSDate
                myProjectTeam.updateType = updateType
            }
        }
        
        saveContext()
    }
    
    func replaceTeamMember(_ projectID: Int32, roleID: Int32, personName: String, notes: String, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myProjectTeam = ProjectTeamMembers(context: objectContext)
        myProjectTeam.projectID = projectID
        myProjectTeam.teamMember = personName
        myProjectTeam.roleID = roleID
        myProjectTeam.projectMemberNotes = notes
        if updateType == "CODE"
        {
            myProjectTeam.updateTime =  NSDate()
            myProjectTeam.updateType = "Add"
        }
        else
        {
            myProjectTeam.updateTime = updateTime as NSDate
            myProjectTeam.updateType = updateType
        }
        
        saveContext()
        self.refreshObject(myProjectTeam)
    }
    
    func deleteTeamMember(_ projectID: Int32, personName: String)
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (teamMember == \"\(personName)\")")
        
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
    
    func getTeamMemberRecord(_ projectID: Int32, personName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) && (teamMember == \"\(personName)\") && (updateType != \"Delete\")")
        
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
    
    func getTeamMembers(_ projectID: Int32)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) && (updateType != \"Delete\")")
        
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
    
    func getProjectsForPerson(_ personName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(teamMember == \"\(personName)\") && (updateType != \"Delete\")")
        
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
    
    func getProjectTeamMembersForSync(_ syncDate: Date) -> [ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
        
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
    func saveProjectTeamMembersToCloudKit()
    {
        for myItem in myDatabaseConnection.getProjectTeamMembersForSync(myDatabaseConnection.getSyncDateForTable(tableName: "ProjectTeamMembers"))
        {
            saveProjectTeamMembersRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }

    func updateProjectTeamMembersInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(teamID))", myDatabaseConnection.getSyncDateForTable(tableName: "ProjectTeamMembers") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1

            self.updateProjectTeamMembersRecord(record)
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

    func deleteProjectTeamMembers(teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
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

    func replaceProjectTeamMembersInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let projectID = record.object(forKey: "projectID") as! Int32
            let teamMember = record.object(forKey: "teamMember") as! String
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
            let roleID = record.object(forKey: "roleID") as! Int32
            let projectMemberNotes = record.object(forKey: "projectMemberNotes") as! String
            
            myDatabaseConnection.replaceTeamMember(projectID, roleID: roleID, personName: teamMember, notes: projectMemberNotes, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveProjectTeamMembersRecordToCloudKit(_ sourceRecord: ProjectTeamMembers, teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(projectID == \(sourceRecord.projectID)) && (teamMember == \"\(sourceRecord.teamMember!)\") AND (teamID == \(teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "ProjectTeamMembers", predicate: predicate)
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
                    record!.setValue(sourceRecord.roleID, forKey: "roleID")
                    record!.setValue(sourceRecord.projectMemberNotes, forKey: "projectMemberNotes")
                    
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
                    let record = CKRecord(recordType: "ProjectTeamMembers")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.teamMember, forKey: "teamMember")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.roleID, forKey: "roleID")
                    record.setValue(sourceRecord.projectMemberNotes, forKey: "projectMemberNotes")
                    record.setValue(teamID, forKey: "teamID")
                    
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

    func updateProjectTeamMembersRecord(_ sourceRecord: CKRecord)
    {
        let projectID = sourceRecord.object(forKey: "projectID") as! Int32
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
        let roleID = sourceRecord.object(forKey: "roleID") as! Int32
        let projectMemberNotes = sourceRecord.object(forKey: "projectMemberNotes") as! String
        
        myDatabaseConnection.saveTeamMember(projectID, roleID: roleID, personName: teamMember, notes: projectMemberNotes, updateTime: updateTime, updateType: updateType)
    }
}
