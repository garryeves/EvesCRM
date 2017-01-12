//
//  coreDatabase.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 14/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import CoreData

#if os(OSX)
    import AppKit
#endif


class coreDatabase: NSObject
{
    fileprivate var managedObjectContext: NSManagedObjectContext!
    
    override init()
    {
        #if os(iOS)
            managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        #elseif os(OSX)
            managedObjectContext = (NSApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        #else
            NSLog("Unexpected OS")
        #endif
    }
    
    func refreshObject(_ objectID: NSManagedObject)
    {
        managedObjectContext!.refresh(objectID, mergeChanges: true)
    }
    
    func getOpenProjectsForGTDItem(_ inGTDItemID: Int, inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Completed\") && (projectStatus != \"Deleted\") && (areaID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        let sortDescriptor = NSSortDescriptor(key: "projectID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Projects]
        
        return fetchResults!
    }

    func getProjectDetails(_ projectID: Int)->[Projects]
    {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Projects]
        
        return fetchResults!
    }
    
    func getProjectSuccessor(_ projectID: Int)->Int
    {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectNote")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(predecessor == \(projectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProjectNote]
        
        var retVal: Int = 0
        
        if fetchResults!.count == 0
        {
            retVal = 0
        }
        else
        {
            retVal = fetchResults![0].projectID as Int
        }
        
        return retVal
    }

    func getGTDItemSuccessor(_ projectID: Int)->Int
    {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(predecessor == \(projectID)) && (updateType != \"Delete\") && (status != \"Closed\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [GTDItem]
        
        var retVal: Int = 0
        
        if fetchResults!.count == 0
        {
            retVal = 0
        }
        else
        {
            retVal = fetchResults![0].gTDItemID as! Int
        }
        
        return retVal
    }
  
    func getAllProjects(_ inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Projects]
        
        return fetchResults!
    }
    
    func getProjectCount()->Int
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Projects]
        
        return fetchResults!.count
    }
    
    func getRoles(_ inTeamID: Int)->[Roles]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Roles]
        
        return fetchResults!
    }
    
    func deleteAllRoles(_ inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")

        let predicate = NSPredicate(format: "(teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Roles]
        for myStage in fetchResults!
        {
            myStage.updateTime = Date()
            myStage.updateType = "Delete"
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
            
            myCloudDB.saveRolesRecordToCloudKit(myStage)
        }
    }
    
    func getMaxRoleID()-> Int
    {
        var retVal: Int = 0
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        
        fetchRequest.propertiesToFetch = ["roleID"]
        
        let sortDescriptor = NSSortDescriptor(key: "roleID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Roles]
        
        for myItem in fetchResults!
        {
            retVal = myItem.roleID as Int
        }
        
        return retVal + 1
    }
    
    func saveRole(_ roleName: String, teamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE", roleID: Int = 0)
    {
        let myRoles = getRole(roleID)
 
        var mySelectedRole: Roles
        if myRoles.count == 0
        {
            
            mySelectedRole = NSEntityDescription.insertNewObject(forEntityName: "Roles", into: self.managedObjectContext!) as! Roles
        
            // Get the role number
            mySelectedRole.roleID = NSNumber(value: getNextID("Roles"))
            mySelectedRole.roleDescription = roleName
            mySelectedRole.teamID = NSNumber(value: teamID)
            if inUpdateType == "CODE"
            {
                mySelectedRole.updateTime = Date()
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
                mySelectedRole.updateTime = Date()
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
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        myCloudDB.saveRolesRecordToCloudKit(mySelectedRole)
    }

    func saveCloudRole(_ roleName: String, teamID: Int, inUpdateTime: Date, inUpdateType: String, roleID: Int = 0)
    {
        
        
        let myRoles = getRole(roleID)
        
        
        var mySelectedRole: Roles
        if myRoles.count == 0
        {
            
            mySelectedRole = NSEntityDescription.insertNewObject(forEntityName: "Roles", into: self.managedObjectContext!) as! Roles
            
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
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func replaceRole(_ roleName: String, teamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE", roleID: Int = 0)
    {
        managedObjectContext!.perform
            {
        let mySelectedRole = NSEntityDescription.insertNewObject(forEntityName: "Roles", into: self.managedObjectContext!) as! Roles
                    
                    // Get the role number
                    mySelectedRole.roleID = NSNumber(value: roleID)
                    mySelectedRole.roleDescription = roleName
                    mySelectedRole.teamID = NSNumber(value: teamID)
                    if inUpdateType == "CODE"
                    {
                        mySelectedRole.updateTime = Date()
                        mySelectedRole.updateType = "Add"
                    }
                    else
                    {
                        mySelectedRole.updateTime = inUpdateTime
                        mySelectedRole.updateType = inUpdateType
                    }


                
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    
    func getRole(_ roleID: Int, teamID: Int)->[Roles]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (roleID == \(roleID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Roles]
        
        return fetchResults!
    }
    
    func getRole(_ roleID: Int)->[Roles]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (roleID == \(roleID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Roles]
        
        return fetchResults!
    }
    
    func deleteRoleEntry(_ inRoleName: String, inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        
        let predicate = NSPredicate(format: "(roleDescription == \"\(inRoleName)\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Roles]
        for myStage in fetchResults!
        {
            myStage.updateTime = Date()
            myStage.updateType = "Delete"
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
            
            myCloudDB.saveRolesRecordToCloudKit(myStage)
        }
    }
    
    func saveTeamMember(_ inProjectID: Int, inRoleID: Int, inPersonName: String, inNotes: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myProjectTeam: ProjectTeamMembers!
        
        let myProjectTeamRecords = getTeamMemberRecord(inProjectID, inPersonName: inPersonName)
        if myProjectTeamRecords.count == 0
        { // Add
            myProjectTeam = NSEntityDescription.insertNewObject(forEntityName: "ProjectTeamMembers", into: self.managedObjectContext!) as! ProjectTeamMembers
            myProjectTeam.projectID = NSNumber(value: inProjectID)
            myProjectTeam.teamMember = inPersonName
            myProjectTeam.roleID = NSNumber(value: inRoleID)
            myProjectTeam.projectMemberNotes = inNotes
            if inUpdateType == "CODE"
            {
                myProjectTeam.updateTime = Date()
                myProjectTeam.updateType = "Add"
            }
            else
            {
                myProjectTeam.updateTime = inUpdateTime
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
                myProjectTeam.updateTime = Date()
                if myProjectTeam.updateType != "Add"
                {
                    myProjectTeam.updateType = "Update"
                }
            }
            else
            {
                myProjectTeam.updateTime = inUpdateTime
                myProjectTeam.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func replaceTeamMember(_ inProjectID: Int, inRoleID: Int, inPersonName: String, inNotes: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myProjectTeam = NSEntityDescription.insertNewObject(forEntityName: "ProjectTeamMembers", into: self.managedObjectContext!) as! ProjectTeamMembers
            myProjectTeam.projectID = NSNumber(value: inProjectID)
            myProjectTeam.teamMember = inPersonName
            myProjectTeam.roleID = NSNumber(value: inRoleID)
            myProjectTeam.projectMemberNotes = inNotes
            if inUpdateType == "CODE"
            {
                myProjectTeam.updateTime = Date()
                myProjectTeam.updateType = "Add"
            }
            else
            {
                myProjectTeam.updateTime = inUpdateTime
                myProjectTeam.updateType = inUpdateType
            }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
                self.refreshObject(myProjectTeam)
        }
    }

    func deleteTeamMember(_ inProjectID: Int, inPersonName: String)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectTeamMembers")
        
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) AND (teamMember == \"\(inPersonName)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProjectTeamMembers]
        for myStage in fetchResults!
        {
            myStage.updateTime = Date()
            myStage.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }

    func getTeamMemberRecord(_ inProjectID: Int, inPersonName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) && (teamMember == \"\(inPersonName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    func getTeamMembers(_ inProjectID: NSNumber)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    func getProjects(_ inTeamID: Int, inArchiveFlag: Bool = false) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        if !inArchiveFlag
        {
            var predicate: NSPredicate
        
            predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Completed\") && (projectStatus != \"Deleted\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
        }
        else
        {
            // Create a new predicate that filters out any object that
            // doesn't have a title of "Best Language" exactly.
            let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
        }
        
        let sortDescriptor = NSSortDescriptor(key: "projectName", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Projects]
        
        return fetchResults!

    }
    
    func getProjectsForPerson(_ inPersonName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(teamMember == \"\(inPersonName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    func getRoleDescription(_ inRoleID: NSNumber, inTeamID: Int)->String
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        let predicate = NSPredicate(format: "(roleID == \(inRoleID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Roles]
        
        if fetchResults!.count == 0
        {
            return ""
        }
        else
        {
            return fetchResults![0].roleDescription
        }
    }
    
    func getDecodeValue(_ inCodeKey: String) -> String
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Decodes")
   //     let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\") && (updateType != \"Delete\")")
        let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Decodes]
        
        if fetchResults!.count == 0
        {
            return ""
        }
        else
        {
            return fetchResults![0].decode_value
        }
    }
    
    func getVisibleDecodes() -> [Decodes]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Decodes")
        
        let predicate = NSPredicate(format: "(decodeType != \"hidden\") && (updateType != \"Delete\")")
   //     let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Decodes]
        
        return fetchResults!
    }
    
    func updateDecodeValue(_ inCodeKey: String, inCodeValue: String, inCodeType: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        // first check to see if decode exists, if not we create
        var myDecode: Decodes!

        if getDecodeValue(inCodeKey) == ""
        { // Add
            myDecode = NSEntityDescription.insertNewObject(forEntityName: "Decodes", into: managedObjectContext!) as! Decodes
            
            myDecode.decode_name = inCodeKey
            myDecode.decode_value = inCodeValue
            myDecode.decodeType = inCodeType
            if inUpdateType == "CODE"
            {
                myDecode.updateTime = Date()
                myDecode.updateType = "Add"
            }
            else
            {
                myDecode.updateTime = inUpdateTime
                myDecode.updateType = inUpdateType
            }
        }
        else
        { // Update
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Decodes")
            let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\") && (updateType != \"Delete\")")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
            
            // Execute the fetch request, and cast the results to an array of  objects
            let myDecodes = (try? managedObjectContext!.fetch(fetchRequest)) as? [Decodes]
            myDecode = myDecodes![0]
            myDecode.decode_value = inCodeValue
            myDecode.decodeType = inCodeType
            if inUpdateType == "CODE"
            {
                myDecode.updateTime = Date()
                if myDecode.updateType != "Add"
                {
                    myDecode.updateType = "Update"
                }
            }
            else
            {
                myDecode.updateTime = inUpdateTime
                myDecode.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        myCloudDB.saveDecodesRecordToCloudKit(myDecode, syncName: myDBSync.getSyncID())
    }
    
    func replaceDecodeValue(_ inCodeKey: String, inCodeValue: String, inCodeType: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myDecode = NSEntityDescription.insertNewObject(forEntityName: "Decodes", into: self.managedObjectContext!) as! Decodes
            
        myDecode.decode_name = inCodeKey
        myDecode.decode_value = inCodeValue
        myDecode.decodeType = inCodeType
        if inUpdateType == "CODE"
        {
            myDecode.updateTime = Date()
            myDecode.updateType = "Add"
        }
        else
        {
            myDecode.updateTime = inUpdateTime
            myDecode.updateType = inUpdateType
        }

        

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func getStages(_ inTeamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Stages]
        
        return fetchResults!
    }
    
    func getVisibleStages(_ inTeamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
    
        let predicate = NSPredicate(format: "(stageDescription != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
    
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Stages]
        
        return fetchResults!
    }
    
    func deleteAllStages(_ inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
        let predicate = NSPredicate(format: "(teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Stages]
        for myStage in fetchResults!
        {
            myStage.updateTime = Date()
            myStage.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
            
            myCloudDB.saveStagesRecordToCloudKit(myStage)
        }
    }

    func stageExists(_ inStageDesc:String, inTeamID: Int)-> Bool
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(stageDescription == \"\(inStageDesc)\") && (teamID == \(inTeamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Stages]
        
        if fetchResults!.count > 0
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func getStage(_ stageDesc:String, teamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (stageDescription == \"\(stageDesc)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Stages]
        
        return fetchResults!
    }
    
    func saveStage(_ stageDesc: String, teamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myStage: Stages!
        
        let myStages = getStage(stageDesc, teamID: teamID)
        
        if myStages.count == 0
        {
            myStage = NSEntityDescription.insertNewObject(forEntityName: "Stages", into: managedObjectContext!) as! Stages
        
            myStage.stageDescription = stageDesc
            myStage.teamID = NSNumber(value: teamID)
            if inUpdateType == "CODE"
            {
                myStage.updateTime = Date()
                myStage.updateType = "Add"
            }
            else
            {
                myStage.updateTime = inUpdateTime
                myStage.updateType = inUpdateType
            }
        }
        else
        {
            myStage = myStages[0]
            if inUpdateType == "CODE"
            {
                myStage.updateTime = Date()
                if myStage.updateType != "Add"
                {
                    myStage.updateType = "Update"
                }
            }
            else
            {
                myStage.updateTime = inUpdateTime
                myStage.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        myCloudDB.saveStagesRecordToCloudKit(myStage)
    }
    
    func replaceStage(_ stageDesc: String, teamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myStage = NSEntityDescription.insertNewObject(forEntityName: "Stages", into: self.managedObjectContext!) as! Stages
            
            myStage.stageDescription = stageDesc
            myStage.teamID = NSNumber(value: teamID)
            if inUpdateType == "CODE"
            {
                myStage.updateTime = Date()
                myStage.updateType = "Add"
            }
            else
            {
                myStage.updateTime = inUpdateTime
                myStage.updateType = inUpdateType
            }

                
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func deleteStageEntry(_ inStageDesc: String, inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
        
        let predicate = NSPredicate(format: "(stageDescription == \"\(inStageDesc)\") && (teamID == \(inTeamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Stages]
        for myStage in fetchResults!
        {
            myStage.updateTime = Date()
            myStage.updateType = "Delete"
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
            
            myCloudDB.saveStagesRecordToCloudKit(myStage)
        }
    }
    
    func searchPastAgendaByPartialMeetingIDBeforeStart(_ inSearchText: String, inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID contains \"\(inSearchText)\") && (startTime <= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate as CVarArg)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func searchPastAgendaWithoutPartialMeetingIDBeforeStart(_ inSearchText: String, inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(teamID == \(inTeamID))  && (updateType != \"Delete\") && (startTime <= %@) && (not meetingID contains \"\(inSearchText)\") ", inMeetingStartDate as CVarArg)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }

    func listAgendaReverseDateBeforeStart(_ inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime <= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate as CVarArg)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func searchPastAgendaByPartialMeetingIDAfterStart(_ inSearchText: String, inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID contains \"\(inSearchText)\") && (startTime >= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate as CVarArg)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func searchPastAgendaWithoutPartialMeetingIDAfterStart(_ inSearchText: String, inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
 
        predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID)) && NOT (meetingID contains \"\(inSearchText)\") && (startTime >= %@)", inMeetingStartDate as CVarArg)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func listAgendaReverseDateAfterStart(_ inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime >= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate as CVarArg)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func createAgenda(_ inEvent: myCalendarItem)
    {
        saveAgenda(inEvent.eventID, inPreviousMeetingID : inEvent.previousMinutes, inName: inEvent.title, inChair: inEvent.chair, inMinutes: inEvent.minutes, inLocation: inEvent.location, inStartTime: inEvent.startDate as Date, inEndTime: inEvent.endDate as Date, inMinutesType: inEvent.minutesType, inTeamID: inEvent.teamID)
    }
    
    func saveAgenda(_ inMeetingID: String, inPreviousMeetingID : String, inName: String, inChair: String, inMinutes: String, inLocation: String, inStartTime: Date, inEndTime: Date, inMinutesType: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myAgenda: MeetingAgenda
        
        let myAgendas = loadAgenda(inMeetingID, inTeamID: inTeamID)
        
        if myAgendas.count == 0
        {
            myAgenda = NSEntityDescription.insertNewObject(forEntityName: "MeetingAgenda", into: managedObjectContext!) as! MeetingAgenda
            myAgenda.meetingID = inMeetingID
            myAgenda.previousMeetingID = inPreviousMeetingID
            myAgenda.name = inName
            myAgenda.chair = inChair
            myAgenda.minutes = inMinutes
            myAgenda.location = inLocation
            myAgenda.startTime = inStartTime
            myAgenda.endTime = inEndTime
            myAgenda.minutesType = inMinutesType
            myAgenda.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myAgenda.updateTime = Date()
                myAgenda.updateType = "Add"
            }
            else
            {
                myAgenda.updateTime = inUpdateTime
                myAgenda.updateType = inUpdateType
            }
        }
        else
        {
            myAgenda = myAgendas[0]
            myAgenda.previousMeetingID = inPreviousMeetingID
            myAgenda.name = inName
            myAgenda.chair = inChair
            myAgenda.minutes = inMinutes
            myAgenda.location = inLocation
            myAgenda.startTime = inStartTime
            myAgenda.endTime = inEndTime
            myAgenda.minutesType = inMinutesType
            myAgenda.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myAgenda.updateTime = Date()
                if myAgenda.updateType != "Add"
                {
                    myAgenda.updateType = "Update"
                }
            }
            else
            {
                myAgenda.updateTime = inUpdateTime
                myAgenda.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func replaceAgenda(_ inMeetingID: String, inPreviousMeetingID : String, inName: String, inChair: String, inMinutes: String, inLocation: String, inStartTime: Date, inEndTime: Date, inMinutesType: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myAgenda = NSEntityDescription.insertNewObject(forEntityName: "MeetingAgenda", into: self.managedObjectContext!) as! MeetingAgenda
            myAgenda.meetingID = inMeetingID
            myAgenda.previousMeetingID = inPreviousMeetingID
            myAgenda.name = inName
            myAgenda.chair = inChair
            myAgenda.minutes = inMinutes
            myAgenda.location = inLocation
            myAgenda.startTime = inStartTime
            myAgenda.endTime = inEndTime
            myAgenda.minutesType = inMinutesType
            myAgenda.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myAgenda.updateTime = Date()
                myAgenda.updateType = "Add"
            }
            else
            {
                myAgenda.updateTime = inUpdateTime
                myAgenda.updateType = inUpdateType
            }
        

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func loadPreviousAgenda(_ inMeetingID: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(previousMeetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")

        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func loadAgenda(_ inMeetingID: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }

    func updatePreviousAgendaID(_ inPreviousMeetingID: String, inMeetingID: String, inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        for myResult in fetchResults!
        {
            myResult.previousMeetingID = inPreviousMeetingID
            myResult.updateTime = Date()
            if myResult.updateType != "Add"
            {
                myResult.updateType = "Update"
            }
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func loadAgendaForProject(_ inProjectName: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name contains \"\(inProjectName)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
   
    func getAgendaForDateRange(_ inStartDate: Date, inEndDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime >= %@) && (endTime <= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inStartDate as CVarArg, inEndDate as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func loadAttendees(_ inMeetingID: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAttendees]
        
        return fetchResults!
    }
    
    func loadMeetingsForAttendee(_ inAttendeeName: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name == \"\(inAttendeeName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAttendees]
        
        return fetchResults!
    }

    func checkMeetingsForAttendee(_ attendeeName: String, meetingID: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name == \"\(attendeeName)\") && (updateType != \"Delete\") && (meetingID == \"\(meetingID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAttendees]
        
        return fetchResults!
    }

    func saveAttendee(_ meetingID: String, name: String, email: String,  type: String, status: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myPerson: MeetingAttendees!
        
        let myMeeting = checkMeetingsForAttendee(name, meetingID: meetingID)
        
        if myMeeting.count == 0
        {
            myPerson = NSEntityDescription.insertNewObject(forEntityName: "MeetingAttendees", into: managedObjectContext!) as! MeetingAttendees
            myPerson.meetingID = meetingID
            myPerson.name = name
            myPerson.attendenceStatus = status
            myPerson.email = email
            myPerson.type = type
            if inUpdateType == "CODE"
            {
                myPerson.updateTime = Date()
                myPerson.updateType = "Add"
            }
            else
            {
                myPerson.updateTime = inUpdateTime
                myPerson.updateType = inUpdateType
            }
        }
        else
        {
            myPerson = myMeeting[0]
            myPerson.attendenceStatus = status
            myPerson.email = email
            myPerson.type = type
            if inUpdateType == "CODE"
            {
                myPerson.updateTime = Date()
                if myPerson.updateType != "Add"
                {
                    myPerson.updateType = "Update"
                }
            }
            else
            {
                myPerson.updateTime = inUpdateTime
                myPerson.updateType = inUpdateType
            }
        }
            
        managedObjectContext!.perform
        {
            do
            {
                try self.managedObjectContext!.save()
            }
            catch let error as NSError
            {
                NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                print("Failure to save context: \(error)")
            }
        }
    }

    func replaceAttendee(_ meetingID: String, name: String, email: String,  type: String, status: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myPerson = NSEntityDescription.insertNewObject(forEntityName: "MeetingAttendees", into: self.managedObjectContext!) as! MeetingAttendees
            myPerson.meetingID = meetingID
            myPerson.name = name
            myPerson.attendenceStatus = status
            myPerson.email = email
            myPerson.type = type
            if inUpdateType == "CODE"
            {
                myPerson.updateTime = Date()
                myPerson.updateType = "Add"
            }
            else
            {
                myPerson.updateTime = inUpdateTime
                myPerson.updateType = inUpdateType
            }
        
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func deleteAttendee(_ meetingID: String, name: String)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAttendees")
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") && (name == \"\(name)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAttendees]
        
        for myMeeting in fetchResults!
        {
            myMeeting.updateTime = Date()
            myMeeting.updateType = "Delete"
            
            managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                    print("Failure to save context: \(error)")
                }
            }
        }
    }

    func loadAgendaItem(_ inMeetingID: String)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "meetingOrder", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgendaItem]
        
        return fetchResults!
    }
    
    func saveAgendaItem(_ meetingID: String, actualEndTime: Date, actualStartTime: Date, status: String, decisionMade: String, discussionNotes: String, timeAllocation: Int, owner: String, title: String, agendaID: Int, meetingOrder: Int,  inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var mySavedItem: MeetingAgendaItem
        
        let myAgendaItem = loadSpecificAgendaItem(meetingID,inAgendaID: agendaID)
        
        if myAgendaItem.count == 0
        {
            mySavedItem = NSEntityDescription.insertNewObject(forEntityName: "MeetingAgendaItem", into: managedObjectContext!) as! MeetingAgendaItem
            mySavedItem.meetingID = meetingID
            mySavedItem.agendaID = agendaID as NSNumber?
            mySavedItem.actualEndTime = actualEndTime
            mySavedItem.actualStartTime = actualStartTime
            mySavedItem.status = status
            mySavedItem.decisionMade = decisionMade
            mySavedItem.discussionNotes = discussionNotes
            mySavedItem.timeAllocation = timeAllocation as NSNumber?
            mySavedItem.owner = owner
            mySavedItem.title = title
            mySavedItem.meetingOrder = meetingOrder as NSNumber?
            
            if inUpdateType == "CODE"
            {
                mySavedItem.updateTime = Date()
                mySavedItem.updateType = "Add"
            }
            else
            {
                mySavedItem.updateTime = inUpdateTime
                mySavedItem.updateType = inUpdateType
            }
        }
        else
        {
            mySavedItem = myAgendaItem[0]
            mySavedItem.actualEndTime = actualEndTime
            mySavedItem.actualStartTime = actualStartTime
            mySavedItem.status = status
            mySavedItem.decisionMade = decisionMade
            mySavedItem.discussionNotes = discussionNotes
            mySavedItem.timeAllocation = timeAllocation as NSNumber?
            mySavedItem.owner = owner
            mySavedItem.title = title
            mySavedItem.meetingOrder = meetingOrder as NSNumber?

            if inUpdateType == "CODE"
            {
                mySavedItem.updateTime = Date()
                if mySavedItem.updateType != "Add"
                {
                    mySavedItem.updateType = "Update"
                }
            }
            else
            {
                mySavedItem.updateTime = inUpdateTime
                mySavedItem.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func replaceAgendaItem(_ meetingID: String, actualEndTime: Date, actualStartTime: Date, status: String, decisionMade: String, discussionNotes: String, timeAllocation: Int, owner: String, title: String, agendaID: Int, meetingOrder: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let mySavedItem = NSEntityDescription.insertNewObject(forEntityName: "MeetingAgendaItem", into: self.managedObjectContext!) as! MeetingAgendaItem
            mySavedItem.meetingID = meetingID
            mySavedItem.agendaID = agendaID as NSNumber?
            mySavedItem.actualEndTime = actualEndTime
            mySavedItem.actualStartTime = actualStartTime
            mySavedItem.status = status
            mySavedItem.decisionMade = decisionMade
            mySavedItem.discussionNotes = discussionNotes
            mySavedItem.timeAllocation = timeAllocation as NSNumber?
            mySavedItem.owner = owner
            mySavedItem.title = title
            mySavedItem.meetingOrder = meetingOrder as NSNumber?

            if inUpdateType == "CODE"
            {
                mySavedItem.updateTime = Date()
                mySavedItem.updateType = "Add"
            }
            else
            {
                mySavedItem.updateTime = inUpdateTime
                mySavedItem.updateType = inUpdateType
            }


                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func loadSpecificAgendaItem(_ inMeetingID: String, inAgendaID: Int)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") AND (agendaID == \(inAgendaID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "meetingOrder", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgendaItem]
        
        return fetchResults!
    }
    
    func deleteAgendaItem(_ meetingID: String, agendaID: Int)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") AND (agendaID == \(agendaID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgendaItem]
        
        for myMeeting in fetchResults!
        {
            myMeeting.updateTime = Date()
            myMeeting.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }
    
    func deleteAllAgendaItems(_ inMeetingID: String)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "meetingID == \"\(inMeetingID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgendaItem]
        
        for myMeeting in fetchResults!
        {
            myMeeting.updateTime = Date()
            myMeeting.updateType = "Delete"
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }

    func saveTask(_ inTaskID: Int, inTitle: String, inDetails: String, inDueDate: Date, inStartDate: Date, inStatus: String, inPriority: String, inEnergyLevel: String, inEstimatedTime: Int, inEstimatedTimeType: String, inProjectID: Int, inCompletionDate: Date, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inFlagged: Bool, inUrgency: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myTask: Task!
        
        let myTasks = getTask(inTaskID)
        
        if myTasks.count == 0
        { // Add
            myTask = NSEntityDescription.insertNewObject(forEntityName: "Task", into: self.managedObjectContext!) as! Task
            myTask.taskID = NSNumber(value: inTaskID)
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = NSNumber(value: inEstimatedTime)
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = NSNumber(value: inProjectID)
            myTask.completionDate = inCompletionDate
            myTask.repeatInterval = NSNumber(value: inRepeatInterval)
            myTask.repeatType = inRepeatType
            myTask.repeatBase = inRepeatBase
            myTask.flagged = inFlagged as NSNumber
            myTask.urgency = inUrgency
            myTask.teamID = NSNumber(value: inTeamID)
            
            if inUpdateType == "CODE"
            {
                myTask.updateTime = Date()
                myTask.updateType = "Add"
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }
        }
        else
        { // Update
            myTask = myTasks[0]
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = NSNumber(value: inEstimatedTime)
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = NSNumber(value: inProjectID)
            myTask.completionDate = inCompletionDate
            myTask.repeatInterval = NSNumber(value: inRepeatInterval)
            myTask.repeatType = inRepeatType
            myTask.repeatBase = inRepeatBase
            myTask.flagged = inFlagged as NSNumber
            myTask.urgency = inUrgency
            myTask.teamID = NSNumber(value: inTeamID)
            
            if inUpdateType == "CODE"
            {
                myTask.updateTime = Date()
                if myTask.updateType != "Add"
                {
                    myTask.updateType = "Update"
                }
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }
            
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func replaceTask(_ inTaskID: Int, inTitle: String, inDetails: String, inDueDate: Date, inStartDate: Date, inStatus: String, inPriority: String, inEnergyLevel: String, inEstimatedTime: Int, inEstimatedTimeType: String, inProjectID: Int, inCompletionDate: Date, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inFlagged: Bool, inUrgency: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myTask = NSEntityDescription.insertNewObject(forEntityName: "Task", into: self.managedObjectContext!) as! Task
            myTask.taskID = NSNumber(value: inTaskID)
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = NSNumber(value: inEstimatedTime)
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = NSNumber(value: inProjectID)
            myTask.completionDate = inCompletionDate
            myTask.repeatInterval = NSNumber(value: inRepeatInterval)
            myTask.repeatType = inRepeatType
            myTask.repeatBase = inRepeatBase
            myTask.flagged = inFlagged as NSNumber
            myTask.urgency = inUrgency
            myTask.teamID = NSNumber(value: inTeamID)
            
            if inUpdateType == "CODE"
            {
                myTask.updateTime = Date()
                myTask.updateType = "Add"
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }


                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func deleteTask(_ inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        let predicate = NSPredicate(format: "taskID == \(inTaskID)")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        for myStage in fetchResults!
        {
            myStage.updateTime = Date()
            myStage.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }
    
    func getTasksNotDeleted(_ inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "taskID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        return fetchResults!
    }

    func getAllTasksForProject(_ inProjectID: Int, inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(inProjectID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        return fetchResults!
    }
    
    func getTasksForProject(_ projectID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(projectID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        return fetchResults!
    }
    
    func getActiveTasksForProject(_ projectID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
       let predicate = NSPredicate(format: "(projectID = \(projectID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\") && (status != \"Pause\") && ((startDate == %@) || (startDate <= %@))", getDefaultDate() as CVarArg, Date() as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        return fetchResults!
    }

    func getTasksWithoutProject(_ teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == 0) && (updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\") && (status != \"Complete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        return fetchResults!
    }
    
    func getTaskWithoutContext(_ teamID: Int)->[Task]
    {
        // first get a list of all tasks that have a context
        
        let fetchContext = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate1 = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchContext.predicate = predicate1

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchContextResults = (try? managedObjectContext!.fetch(fetchContext)) as? [TaskContext]
        
        // Get the list of all current tasks
        let fetchTask = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate2 = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\") && (status != \"Complete\")")
        
        // Set the predicate on the fetch request
        fetchTask.predicate = predicate2
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchTaskResults = (try? managedObjectContext!.fetch(fetchTask)) as? [Task]

        var myTaskArray: [Task] = Array()
        var taskFound: Bool = false
        
        for myTask in fetchTaskResults!
        {
            // loop though the context tasks
            taskFound = false
            for myContext in fetchContextResults!
            {
                if myTask.taskID == myContext.taskID
                {
                    taskFound = true
                    break
                }
            }
            
            if !taskFound
            {
                myTaskArray.append(myTask)
            }
        }
        
        return myTaskArray
    }
    
    func getTask(_ taskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        return fetchResults!
    }
    
    func getTaskRegardlessOfStatus(_ taskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        return fetchResults!
    }
    
    func getActiveTask(_ taskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\") && ((startDate == %@) || (startDate <= %@))", getDefaultDate() as CVarArg, Date() as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        return fetchResults!
    }

    func getTaskCount()->Int
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        return fetchResults!.count
    }
    
    func getTaskPredecessors(_ inTaskID: Int)->[TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskPredecessor")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskPredecessor]
        
        return fetchResults!
    }
   
    func savePredecessorTask(_ inTaskID: Int, inPredecessorID: Int, inPredecessorType: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myTask: TaskPredecessor!
        
        let myTasks = getTaskPredecessors(inTaskID)
        
        if myTasks.count == 0
        { // Add
            myTask = NSEntityDescription.insertNewObject(forEntityName: "TaskPredecessor", into: self.managedObjectContext!) as! TaskPredecessor
            myTask.taskID = NSNumber(value: inTaskID)
            myTask.predecessorID = NSNumber(value: inPredecessorID)
            myTask.predecessorType = inPredecessorType
            if inUpdateType == "CODE"
            {
                myTask.updateTime = Date()
                myTask.updateType = "Add"
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }
        }
        else
        { // Update
            myTask.predecessorID = NSNumber(value: inPredecessorID)
            myTask.predecessorType = inPredecessorType
            if inUpdateType == "CODE"
            {
                myTask.updateTime = Date()
                if myTask.updateType != "Add"
                {
                    myTask.updateType = "Update"
                }
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }
        }

        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        myCloudDB.saveTaskPredecessorRecordToCloudKit(myTask)
    }
    
    func replacePredecessorTask(_ inTaskID: Int, inPredecessorID: Int, inPredecessorType: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myTask = NSEntityDescription.insertNewObject(forEntityName: "TaskPredecessor", into: self.managedObjectContext!) as! TaskPredecessor
            myTask.taskID = NSNumber(value: inTaskID)
            myTask.predecessorID = NSNumber(value: inPredecessorID)
            myTask.predecessorType = inPredecessorType
            if inUpdateType == "CODE"
            {
                myTask.updateTime = Date()
                myTask.updateType = "Add"
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }

        

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func updatePredecessorTaskType(_ inTaskID: Int, inPredecessorID: Int, inPredecessorType: String)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (predecessorID == \(inPredecessorID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskPredecessor]
        for myStage in fetchResults!
        {
            myStage.predecessorType = inPredecessorType
            myStage.updateTime = Date()
            if myStage.updateType != "Add"
            {
                myStage.updateType = "Update"
            }
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
            
            myCloudDB.saveTaskPredecessorRecordToCloudKit(myStage)
        }
    }

    func deleteTaskPredecessor(_ inTaskID: Int, inPredecessorID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (predecessorID == \(inPredecessorID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskPredecessor]
        for myStage in fetchResults!
        {
            myStage.updateTime = Date()
            myStage.updateType = "Delete"
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
            
            myCloudDB.saveTaskPredecessorRecordToCloudKit(myStage)
        }
    }
    
    func saveProject(_ inProjectID: Int, inProjectEndDate: Date, inProjectName: String, inProjectStartDate: Date, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: Date, inGTDItemID: Int, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID)
        
        if myProjects.count == 0
        { // Add
            myProject = NSEntityDescription.insertNewObject(forEntityName: "Projects", into: self.managedObjectContext!) as! Projects
            myProject.projectID = NSNumber(value: inProjectID)
            myProject.projectEndDate = inProjectEndDate
            myProject.projectName = inProjectName
            myProject.projectStartDate = inProjectStartDate
            myProject.projectStatus = inProjectStatus
            myProject.reviewFrequency = NSNumber(value: inReviewFrequency)
            myProject.lastReviewDate = inLastReviewDate
            myProject.areaID = NSNumber(value: inGTDItemID)
            myProject.repeatInterval = NSNumber(value: inRepeatInterval)
            myProject.repeatType = inRepeatType
            myProject.repeatBase = inRepeatBase
            myProject.teamID = NSNumber(value: inTeamID)
            
            if inUpdateType == "CODE"
            {
                myProject.updateTime = Date()
                myProject.updateType = "Add"
            }
            else
            {
                myProject.updateTime = inUpdateTime
                myProject.updateType = inUpdateType
            }
        }
        else
        { // Update
            myProject = myProjects[0]
            myProject.projectEndDate = inProjectEndDate
            myProject.projectName = inProjectName
            myProject.projectStartDate = inProjectStartDate
            myProject.projectStatus = inProjectStatus
            myProject.reviewFrequency = NSNumber(value: inReviewFrequency)
            myProject.lastReviewDate = inLastReviewDate
            myProject.areaID = NSNumber(value: inGTDItemID)
            myProject.repeatInterval = NSNumber(value: inRepeatInterval)
            myProject.repeatType = inRepeatType
            myProject.repeatBase = inRepeatBase
            myProject.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myProject.updateTime = Date()
                if myProject.updateType != "Add"
                {
                    myProject.updateType = "Update"
                }
            }
            else
            {
                myProject.updateTime = inUpdateTime
                myProject.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func replaceProject(_ inProjectID: Int, inProjectEndDate: Date, inProjectName: String, inProjectStartDate: Date, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: Date, inGTDItemID: Int, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myProject = NSEntityDescription.insertNewObject(forEntityName: "Projects", into: self.managedObjectContext!) as! Projects
            myProject.projectID = NSNumber(value: inProjectID)
            myProject.projectEndDate = inProjectEndDate
            myProject.projectName = inProjectName
            myProject.projectStartDate = inProjectStartDate
            myProject.projectStatus = inProjectStatus
            myProject.reviewFrequency = NSNumber(value: inReviewFrequency)
            myProject.lastReviewDate = inLastReviewDate
            myProject.areaID = NSNumber(value: inGTDItemID)
            myProject.repeatInterval = NSNumber(value: inRepeatInterval)
            myProject.repeatType = inRepeatType
            myProject.repeatBase = inRepeatBase
            myProject.teamID = NSNumber(value: inTeamID)
            
            if inUpdateType == "CODE"
            {
                myProject.updateTime = Date()
                myProject.updateType = "Add"
            }
            else
            {
                myProject.updateTime = inUpdateTime
                myProject.updateType = inUpdateType
            }


                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func deleteProject(_ inProjectID: Int, inTeamID: Int)
    {
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID)
        
        if myProjects.count > 0
        { // Update
            myProject = myProjects[0]
            myProject.updateTime = Date()
            myProject.updateType = "Delete"
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        var myProjectNote: ProjectNote!
        
        let myTeams = getProjectNote(inProjectID)
        
        if myTeams.count > 0
        { // Update
            myProjectNote = myTeams[0]
            myProjectNote.updateType = "Delete"
            myProjectNote.updateTime = Date()
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func saveTaskUpdate(_ inTaskID: Int, inDetails: String, inSource: String, inUpdateDate: Date = Date(), inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myTaskUpdate: TaskUpdates!

        if getTaskUpdate(inTaskID, updateDate: inUpdateDate).count == 0
        {
            myTaskUpdate = NSEntityDescription.insertNewObject(forEntityName: "TaskUpdates", into: self.managedObjectContext!) as! TaskUpdates
            myTaskUpdate.taskID = NSNumber(value: inTaskID)
            myTaskUpdate.updateDate = inUpdateDate
            myTaskUpdate.details = inDetails
            myTaskUpdate.source = inSource
            if inUpdateType == "CODE"
            {
                myTaskUpdate.updateTime = Date()
                myTaskUpdate.updateType = "Add"
            }
            else
            {
                myTaskUpdate.updateTime = inUpdateTime
                myTaskUpdate.updateType = inUpdateType
            }
        
            managedObjectContext!.perform
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }
    
    func replaceTaskUpdate(_ inTaskID: Int, inDetails: String, inSource: String, inUpdateDate: Date = Date(), inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myTaskUpdate = NSEntityDescription.insertNewObject(forEntityName: "TaskUpdates", into: self.managedObjectContext!) as! TaskUpdates
            myTaskUpdate.taskID = NSNumber(value: inTaskID)
            myTaskUpdate.updateDate = inUpdateDate
            myTaskUpdate.details = inDetails
            myTaskUpdate.source = inSource
            if inUpdateType == "CODE"
            {
                myTaskUpdate.updateTime = Date()
                myTaskUpdate.updateType = "Add"
            }
            else
            {
                myTaskUpdate.updateTime = inUpdateTime
                myTaskUpdate.updateType = inUpdateType
            }
            

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                    print("Failure to save context: \(error)")
                }
            }
    }

    func getTaskUpdate(_ taskID: Int, updateDate: Date)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (updateDate == %@)", updateDate as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskUpdates]
        
        return fetchResults!
    }
    
    func getTaskUpdates(_ inTaskID: Int)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskUpdates]
        
        return fetchResults!
    }

    func saveContext(_ inContextID: Int, inName: String, inEmail: String, inAutoEmail: String, inParentContext: Int, inStatus: String, inPersonID: Int, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myContext: Context!
        
        let myContexts = getContextDetails(inContextID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObject(forEntityName: "Context", into: self.managedObjectContext!) as! Context
            myContext.contextID = NSNumber(value: inContextID)
            myContext.name = inName
            myContext.email = inEmail
            myContext.autoEmail = inAutoEmail
            myContext.parentContext = NSNumber(value: inParentContext)
            myContext.status = inStatus
            myContext.personID = NSNumber(value: inPersonID)
            myContext.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myContext.updateTime = Date()

                myContext.updateType = "Add"
            }
            else
            {
                myContext.updateTime = inUpdateTime
                myContext.updateType = inUpdateType
            }
        }
        else
        {
            myContext = myContexts[0]
            myContext.name = inName
            myContext.email = inEmail
            myContext.autoEmail = inAutoEmail
            myContext.parentContext = NSNumber(value: inParentContext)
            myContext.status = inStatus
            myContext.personID = NSNumber(value: inPersonID)
            myContext.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myContext.updateTime = Date()
                if myContext.updateType != "Add"
                {
                    myContext.updateType = "Update"
                }
            }
            else
            {
                myContext.updateTime = inUpdateTime
                myContext.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func replaceContext(_ inContextID: Int, inName: String, inEmail: String, inAutoEmail: String, inParentContext: Int, inStatus: String, inPersonID: Int, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myContext = NSEntityDescription.insertNewObject(forEntityName: "Context", into: self.managedObjectContext!) as! Context
        myContext.contextID = NSNumber(value: inContextID)
        myContext.name = inName
        myContext.email = inEmail
        myContext.autoEmail = inAutoEmail
        myContext.parentContext = NSNumber(value: inParentContext)
        myContext.status = inStatus
        myContext.personID = NSNumber(value: inPersonID)
        myContext.teamID = NSNumber(value: inTeamID)
        if inUpdateType == "CODE"
        {
            myContext.updateTime = Date()
            myContext.updateType = "Add"
        }
        else
        {
            myContext.updateTime = inUpdateTime
            myContext.updateType = inUpdateType
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func deleteContext(_ inContextID: Int, inTeamID: Int)
    {
        let myContexts = getContextDetails(inContextID)
        
        if myContexts.count > 0
       {
            let myContext = myContexts[0]
            myContext.updateTime = Date()
            myContext.updateType = "Delete"
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let myContexts2 = getContext1_1(inContextID)
        
        if myContexts2.count > 0
        {
            let myContext = myContexts[0]
            myContext.updateTime = Date()
            myContext.updateType = "Delete"
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func getContexts(_ inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(status != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context]
        
        return fetchResults!
    }

    func getContextsForType(_ contextType: String)->[Context1_1]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context1_1")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextType == \"\(contextType)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context1_1]
        
        return fetchResults!
    }
    
    func getContextByName(_ contextName: String)->[Context]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(name = \"\(contextName)\") && (updateType != \"Delete\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context]
        
        return fetchResults!
    }
    
    func getContextDetails(_ contextID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID == \(contextID)) && (updateType != \"Delete\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context]
        
        return fetchResults!
    }

    func getAllContexts(_ inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context]
        
        return fetchResults!
    }
    
    func getContextCount()->Int
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context]
        
        return fetchResults!.count
    }

    func saveTaskContext(_ inContextID: Int, inTaskID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myContext: TaskContext!
        
        let myContexts = getTaskContext(inContextID, inTaskID: inTaskID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObject(forEntityName: "TaskContext", into: self.managedObjectContext!) as! TaskContext
            myContext.contextID = NSNumber(value: inContextID)
            myContext.taskID = NSNumber(value: inTaskID)
            if inUpdateType == "CODE"
            {
                myContext.updateTime = Date()
                myContext.updateType = "Add"
            }
            else
            {
                myContext.updateTime = inUpdateTime
                myContext.updateType = inUpdateType
            }
        }
        else
        {
            myContext = myContexts[0]
            if inUpdateType == "CODE"
            {
                myContext.updateTime = Date()
                if myContext.updateType != "Add"
                {
                    myContext.updateType = "Update"
                }
            }
            else
            {
                myContext.updateTime = inUpdateTime
                myContext.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        myCloudDB.saveTaskContextRecordToCloudKit(myContext)
    }

func replaceTaskContext(_ inContextID: Int, inTaskID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
{
    managedObjectContext!.perform
        {
    let myContext = NSEntityDescription.insertNewObject(forEntityName: "TaskContext", into: self.managedObjectContext!) as! TaskContext
        myContext.contextID = NSNumber(value: inContextID)
        myContext.taskID = NSNumber(value: inTaskID)
        if inUpdateType == "CODE"
        {
            myContext.updateTime = Date()
            myContext.updateType = "Add"
        }
        else
        {
            myContext.updateTime = inUpdateTime
            myContext.updateType = inUpdateType
        }

            do
            {
                try self.managedObjectContext!.save()
            }
            catch let error as NSError
            {
                NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                
                print("Failure to save context: \(error)")
            }
    }
}

    func deleteTaskContext(_ inContextID: Int, inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        let predicate = NSPredicate(format: "(contextID == \(inContextID)) AND (taskID = \(inTaskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskContext]
        for myStage in fetchResults!
        {
            myStage.updateTime = Date()
            myStage.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }

    fileprivate func getTaskContext(_ inContextID: Int, inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) AND (contextID = \(inContextID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskContext]
        
        return fetchResults!
    }

    func getContextsForTask(_ inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskContext]
        
        return fetchResults!
    }

    func getTasksForContext(_ inContextID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID = \(inContextID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskContext]
        
        return fetchResults!
    }

    func saveGTDLevel(_ inGTDLevel: Int, inLevelName: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myGTD: GTDLevel!
        
        let myGTDItems = getGTDLevel(inGTDLevel, inTeamID: inTeamID)
        
        if myGTDItems.count == 0
        { // Add
            myGTD = NSEntityDescription.insertNewObject(forEntityName: "GTDLevel", into: self.managedObjectContext!) as! GTDLevel
            myGTD.gTDLevel = inGTDLevel as NSNumber?
            myGTD.levelName = inLevelName
            myGTD.teamID = inTeamID as NSNumber?
            
            if inUpdateType == "CODE"
            {
                myGTD.updateType = "Add"
                myGTD.updateTime = Date()
            }
            else
            {
                myGTD.updateTime = inUpdateTime
                myGTD.updateType = inUpdateType
            }
        }
        else
        { // Update
            myGTD = myGTDItems[0]
            myGTD.levelName = inLevelName
            if inUpdateType == "CODE"
            {
                myGTD.updateTime = Date()
                if myGTD.updateType != "Add"
                {
                    myGTD.updateType = "Update"
                }
            }
            else
            {
                myGTD.updateTime = inUpdateTime
                myGTD.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func replaceGTDLevel(_ inGTDLevel: Int, inLevelName: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myGTD = NSEntityDescription.insertNewObject(forEntityName: "GTDLevel", into: self.managedObjectContext!) as! GTDLevel
            myGTD.gTDLevel = inGTDLevel as NSNumber?
            myGTD.levelName = inLevelName
            myGTD.teamID = inTeamID as NSNumber?
            
            if inUpdateType == "CODE"
            {
                myGTD.updateType = "Add"
                myGTD.updateTime = Date()
            }
            else
            {
                myGTD.updateTime = inUpdateTime
                myGTD.updateType = inUpdateType
            }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func getGTDLevel(_ inGTDLevel: Int, inTeamID: Int)->[GTDLevel]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(inGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [GTDLevel]
        
        return fetchResults!
    }
    
    func changeGTDLevel(_ oldGTDLevel: Int, newGTDLevel: Int, inTeamID: Int)
    {
        var myGTD: GTDLevel!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(oldGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [GTDLevel]
        
        if fetchResults!.count > 0
        { // Update
            myGTD = fetchResults![0]
         //   myGTD.gTDLevel = newGTDLevel
            myGTD.setValue(newGTDLevel, forKey: "gTDLevel")
            myGTD.updateTime = Date()
            if myGTD.updateType != "Add"
            {
                myGTD.updateType = "Update"
            }
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func deleteGTDLevel(_ inGTDLevel: Int, inTeamID: Int)
    {
        var myGTD: GTDLevel!
        
        let myGTDItems = getGTDLevel(inGTDLevel, inTeamID: inTeamID)
        
        if myGTDItems.count > 0
        { // Update
            myGTD = myGTDItems[0]
            myGTD.updateTime = Date()
            myGTD.updateType = "Delete"
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func getGTDLevels(_ inTeamID: Int)->[GTDLevel]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "gTDLevel", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [GTDLevel]
        
        return fetchResults!
    }
    
    func saveGTDItem(_ inGTDItemID: Int, inParentID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: Date, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int, inGTDLevel: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myGTD: GTDItem!
        
        let myGTDItems = checkGTDItem(inGTDItemID, inTeamID: inTeamID)
        
        if myGTDItems.count == 0
        { // Add
            myGTD = NSEntityDescription.insertNewObject(forEntityName: "GTDItem", into: self.managedObjectContext!) as! GTDItem
            myGTD.gTDItemID = inGTDItemID as NSNumber?
            myGTD.gTDParentID = inParentID as NSNumber?
            myGTD.title = inTitle
            myGTD.status = inStatus
            myGTD.teamID = inTeamID as NSNumber?
            myGTD.note = inNote
            myGTD.lastReviewDate = inLastReviewDate
            myGTD.reviewFrequency = inReviewFrequency as NSNumber?
            myGTD.reviewPeriod = inReviewPeriod
            myGTD.predecessor = inPredecessor as NSNumber?
            myGTD.gTDLevel = inGTDLevel as NSNumber?
            if inUpdateType == "CODE"
            {
                myGTD.updateTime = Date()
                myGTD.updateType = "Add"
            }
            else
            {
                myGTD.updateTime = inUpdateTime
                myGTD.updateType = inUpdateType
            }
        }
        else
        { // Update
            myGTD = myGTDItems[0]
            myGTD.gTDParentID = inParentID as NSNumber?
            myGTD.title = inTitle
            myGTD.status = inStatus
            myGTD.updateTime = Date()
            myGTD.teamID = inTeamID as NSNumber?
            myGTD.note = inNote
            myGTD.lastReviewDate = inLastReviewDate
            myGTD.reviewFrequency = inReviewFrequency as NSNumber?
            myGTD.reviewPeriod = inReviewPeriod
            myGTD.predecessor = inPredecessor as NSNumber?
            myGTD.gTDLevel = inGTDLevel as NSNumber?
            if inUpdateType == "CODE"
            {
                if myGTD.updateType != "Add"
                {
                    myGTD.updateType = "Update"
                }
            }
            else
            {
                myGTD.updateTime = inUpdateTime
                myGTD.updateType = inUpdateType
            }
        }
      
        managedObjectContext!.perform
        {
            do
            {
                try self.managedObjectContext!.save()
            }
            catch let error as NSError
            {
                NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                
                print("Failure to save context: \(error)")
            }
        }
    }
    
    func replaceGTDItem(_ inGTDItemID: Int, inParentID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: Date, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int, inGTDLevel: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myGTD = NSEntityDescription.insertNewObject(forEntityName: "GTDItem", into: self.managedObjectContext!) as! GTDItem
            myGTD.gTDItemID = inGTDItemID as NSNumber?
            myGTD.gTDParentID = inParentID as NSNumber?
            myGTD.title = inTitle
            myGTD.status = inStatus
            myGTD.teamID = inTeamID as NSNumber?
            myGTD.note = inNote
            myGTD.lastReviewDate = inLastReviewDate
            myGTD.reviewFrequency = inReviewFrequency as NSNumber?
            myGTD.reviewPeriod = inReviewPeriod
            myGTD.predecessor = inPredecessor as NSNumber?
            myGTD.gTDLevel = inGTDLevel as NSNumber?
            if inUpdateType == "CODE"
            {
                myGTD.updateTime = Date()
                myGTD.updateType = "Add"
            }
            else
            {
                myGTD.updateTime = inUpdateTime
                myGTD.updateType = inUpdateType
            }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func deleteGTDItem(_ inGTDItemID: Int, inTeamID: Int)
    {
        var myGTD: GTDItem!
        
        let myGTDItems = checkGTDItem(inGTDItemID, inTeamID: inTeamID)
        
        if myGTDItems.count > 0
        { // Update
            myGTD = myGTDItems[0]
            myGTD.updateTime = Date()
            myGTD.updateType = "Delete"
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func getGTDItem(_ inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDItemID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [GTDItem]
        
        return fetchResults!
    }
    
    func getGTDItemsForLevel(_ inGTDLevel: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(inGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [GTDItem]
        
        return fetchResults!
    }
    
    func getGTDItemCount() -> Int
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDItem")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [GTDItem]
        
        return fetchResults!.count
    }
    
    func getOpenGTDChildItems(_ inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDParentID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [GTDItem]
        
        return fetchResults!
    }
    
    func checkGTDItem(_ inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDItemID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? self.managedObjectContext!.fetch(fetchRequest)) as? [GTDItem]
        
        return fetchResults!
    }
    
    func resetprojects()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectTeamMembers")
    
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProjectTeamMembers]
        for myStage in fetchResults!
        {
            myStage.updateTime = Date()
            myStage.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }

        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
            
        // Execute the fetch request, and cast the results to an array of objects
        let fetchResults2 = (try? managedObjectContext!.fetch(fetchRequest2)) as? [Projects]
        for myStage in fetchResults2!
        {
            myStage.updateTime = Date()
            myStage.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }
    
    func deleteAllPanes()
    {  // This is used to allow for testing of pane creation, so can delete all the panes if needed
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Panes")

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Panes]
        for myPane in fetchResults!
        {
            myPane.updateTime = Date()
            myPane.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }

    func getPanes() -> [Panes]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Panes")
        
        let sortDescriptor = NSSortDescriptor(key: "pane_name", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(pane_available == true) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Panes]
        
        return fetchResults!
    }

    func getPane(_ paneName:String) -> [Panes]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Panes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "pane_name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Panes]
        
        return fetchResults!
    }
    
    func togglePaneVisible(_ paneName: String)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Panes]
        for myPane in fetchResults!
        {
            if myPane.pane_visible == true
            {
                myPane.pane_visible = false
            }
            else
            {
                myPane.pane_visible = true
            }
            
            myPane.updateTime = Date()
            if myPane.updateType != "Add"
            {
                myPane.updateType = "Update"
            }

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
            
            myCloudDB.savePanesRecordToCloudKit(myPane)
        }
    }

    func setPaneOrder(_ paneName: String, paneOrder: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Panes]
        for myPane in fetchResults!
        {
            myPane.pane_order = NSNumber(value: paneOrder)
            myPane.updateTime = Date()
            if myPane.updateType != "Add"
            {
                myPane.updateType = "Update"
            }
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
            
            myCloudDB.savePanesRecordToCloudKit(myPane)
        }
    }
    
    func savePane(_ inPaneName:String, inPaneAvailable: Bool, inPaneVisible: Bool, inPaneOrder: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myPane: Panes!
        
        let myPanes = getPane(inPaneName)
        
        if myPanes.count == 0
        {
            // Save the details of this pane to the database
            myPane = NSEntityDescription.insertNewObject(forEntityName: "Panes", into: self.managedObjectContext!) as! Panes
        
            myPane.pane_name = inPaneName
            myPane.pane_available = inPaneAvailable as NSNumber
            myPane.pane_visible = inPaneVisible as NSNumber
            myPane.pane_order = NSNumber(value: inPaneOrder)
            if inUpdateType == "CODE"
            {
                myPane.updateTime = Date()
                myPane.updateType = "Add"
            }
            else
            {
                myPane.updateTime = inUpdateTime
                myPane.updateType = inUpdateType
            }
        }
        else
        {
            myPane = myPanes[0]
            myPane.pane_available = inPaneAvailable as NSNumber
            myPane.pane_visible = inPaneVisible as NSNumber
            myPane.pane_order = NSNumber(value: inPaneOrder)
            if inUpdateType == "CODE"
            {
                myPane.updateTime = Date()
                if myPane.updateType != "Add"
                {
                    myPane.updateType = "Update"
                }
            }
            else
            {
                myPane.updateTime = inUpdateTime
                myPane.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        myCloudDB.savePanesRecordToCloudKit(myPane)
    }
    
    func replacePane(_ inPaneName:String, inPaneAvailable: Bool, inPaneVisible: Bool, inPaneOrder: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myPane = NSEntityDescription.insertNewObject(forEntityName: "Panes", into: self.managedObjectContext!) as! Panes
            
            myPane.pane_name = inPaneName
            myPane.pane_available = inPaneAvailable as NSNumber
            myPane.pane_visible = inPaneVisible as NSNumber
            myPane.pane_order = NSNumber(value: inPaneOrder)
            if inUpdateType == "CODE"
            {
                myPane.updateTime = Date()
                myPane.updateType = "Add"
            }
            else
            {
                myPane.updateTime = inUpdateTime
                myPane.updateType = inUpdateType
            }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func resetMeetings()
    {
        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults1 = (try? managedObjectContext!.fetch(fetchRequest1)) as? [MeetingAgenda]
        
        for myMeeting in fetchResults1!
        {
            myMeeting.updateTime = Date()
            myMeeting.updateType = "Delete"
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAttendees")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? managedObjectContext!.fetch(fetchRequest2)) as? [MeetingAttendees]
        
        for myMeeting2 in fetchResults2!
        {
            myMeeting2.updateTime = Date()
            myMeeting2.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest3 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgendaItem")

        let fetchResults3 = (try? managedObjectContext!.fetch(fetchRequest3)) as? [MeetingAgendaItem]
        
        for myMeeting3 in fetchResults3!
        {
            myMeeting3.updateTime = Date()
            myMeeting3.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest4 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        let fetchResults4 = (try? managedObjectContext!.fetch(fetchRequest4)) as? [MeetingTasks]
        
        for myMeeting4 in fetchResults4!
        {
            myMeeting4.updateTime = Date()
            myMeeting4.updateType = "Delete"
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest6 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingSupportingDocs")
        
        let fetchResults6 = (try? managedObjectContext!.fetch(fetchRequest6)) as? [MeetingSupportingDocs]
        
        for myMeeting6 in fetchResults6!
        {
            myMeeting6.updateTime = Date()
            myMeeting6.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }
    
    func resetTasks()
    {
        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults1 = (try? managedObjectContext!.fetch(fetchRequest1)) as? [MeetingTasks]
        
        for myMeeting in fetchResults1!
        {
            myMeeting.updateTime = Date()
            myMeeting.updateType = "Delete"
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }

        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? managedObjectContext!.fetch(fetchRequest2)) as? [Task]
        
        for myMeeting2 in fetchResults2!
        {
            myMeeting2.updateTime = Date()
            myMeeting2.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest3 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        let fetchResults3 = (try? managedObjectContext!.fetch(fetchRequest3)) as? [TaskContext]
        
        for myMeeting3 in fetchResults3!
        {
            myMeeting3.updateTime = Date()
            myMeeting3.updateType = "Delete"
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest4 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskUpdates")
        
        let fetchResults4 = (try? managedObjectContext!.fetch(fetchRequest4)) as? [TaskUpdates]
        
        for myMeeting4 in fetchResults4!
        {
            myMeeting4.updateTime = Date()
            myMeeting4.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }

    func getAgendaTasks(_ inMeetingID: String, inAgendaID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) AND (meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func getMeetingsTasks(_ inMeetingID: String)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func saveAgendaTask(_ inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        var myTask: MeetingTasks
        
        myTask = NSEntityDescription.insertNewObject(forEntityName: "MeetingTasks", into: managedObjectContext!) as! MeetingTasks
        myTask.agendaID = NSNumber(value: inAgendaID)
        myTask.meetingID = inMeetingID
        myTask.taskID = NSNumber(value: inTaskID)
        myTask.updateTime = Date()
        myTask.updateType = "Add"
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        myCloudDB.saveMeetingTasksRecordToCloudKit(myTask)
    }
    
    func replaceAgendaTask(_ inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        managedObjectContext!.perform
            {
        let myTask = NSEntityDescription.insertNewObject(forEntityName: "MeetingTasks", into: self.managedObjectContext!) as! MeetingTasks
        myTask.agendaID = NSNumber(value: inAgendaID)
        myTask.meetingID = inMeetingID
        myTask.taskID = NSNumber(value: inTaskID)
        myTask.updateTime = Date()
        myTask.updateType = "Add"

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func checkMeetingTask(_ meetingID: String, agendaID: Int, taskID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) && (meetingID == \"\(meetingID)\") && (updateType != \"Delete\") && (taskID == \(taskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func saveMeetingTask(_ agendaID: Int, meetingID: String, taskID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myTask: MeetingTasks
        
        let myTaskList = checkMeetingTask(meetingID, agendaID: agendaID, taskID: taskID)
        
        if myTaskList.count == 0
        {
            myTask = NSEntityDescription.insertNewObject(forEntityName: "MeetingTasks", into: managedObjectContext!) as! MeetingTasks
            myTask.agendaID = NSNumber(value: agendaID)
            myTask.meetingID = meetingID
            myTask.taskID = NSNumber(value: taskID)
            if inUpdateType == "CODE"
            {
                myTask.updateTime = Date()
                myTask.updateType = "Add"
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }
        }
        else
        {
            myTask = myTaskList[0]
            if inUpdateType == "CODE"
            {
                myTask.updateTime = Date()
                if myTask.updateType != "Add"
                {
                    myTask.updateType = "Update"
                }
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func replaceMeetingTask(_ agendaID: Int, meetingID: String, taskID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myTask = NSEntityDescription.insertNewObject(forEntityName: "MeetingTasks", into: self.managedObjectContext!) as! MeetingTasks
            myTask.agendaID = NSNumber(value: agendaID)
            myTask.meetingID = meetingID
            myTask.taskID = NSNumber(value: taskID)
            if inUpdateType == "CODE"
            {
                myTask.updateTime = Date()
                myTask.updateType = "Add"
            }
            else
            {
                myTask.updateTime = inUpdateTime
                myTask.updateType = inUpdateType
            }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func deleteAgendaTask(_ inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) AND (meetingID == \"\(inMeetingID)\") AND (taskID == \(inTaskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingTasks]
        
        for myItem in fetchResults!
        {
            myItem.updateTime = Date()
            myItem.updateType = "Delete"
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }
    
    func getAgendaTask(_ inAgendaID: Int, inMeetingID: String, inTaskID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) && (meetingID == \"\(inMeetingID)\") && (taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func resetContexts()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")
        
                // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context]
        
        for myItem in fetchResults!
        {
            myItem.updateTime = Date()
            myItem.updateType = "Delete"
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }

        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults2 = (try? managedObjectContext!.fetch(fetchRequest2)) as? [TaskContext]
        for myItem2 in fetchResults2!
        {
            myItem2.updateTime = Date()
            myItem2.updateType = "Delete"

            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }
    
    func clearDeletedItems()
    {
        let predicate = NSPredicate(format: "(updateType == \"Delete\")")

        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? managedObjectContext!.fetch(fetchRequest2)) as? [Context]
        
        for myItem2 in fetchResults2!
        {
            managedObjectContext!.delete(myItem2 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest3 = NSFetchRequest<NSFetchRequestResult>(entityName: "Decodes")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults3 = (try? managedObjectContext!.fetch(fetchRequest3)) as? [Decodes]
        
        for myItem3 in fetchResults3!
        {
            managedObjectContext!.delete(myItem3 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest5 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Set the predicate on the fetch request
        fetchRequest5.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults5 = (try? managedObjectContext!.fetch(fetchRequest5)) as? [MeetingAgenda]
        
        for myItem5 in fetchResults5!
        {
            managedObjectContext!.delete(myItem5 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest6 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgendaItem")
        
        // Set the predicate on the fetch request
        fetchRequest6.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults6 = (try? managedObjectContext!.fetch(fetchRequest6)) as? [MeetingAgendaItem]
        
        for myItem6 in fetchResults6!
        {
            managedObjectContext!.delete(myItem6 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest7 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAttendees")
        
        // Set the predicate on the fetch request
        fetchRequest7.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults7 = (try? managedObjectContext!.fetch(fetchRequest7)) as? [MeetingAttendees]
        
        for myItem7 in fetchResults7!
        {
            managedObjectContext!.delete(myItem7 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest8 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingSupportingDocs")
        
        // Set the predicate on the fetch request
        fetchRequest8.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults8 = (try? managedObjectContext!.fetch(fetchRequest8)) as? [MeetingSupportingDocs]
        
        for myItem8 in fetchResults8!
        {
            managedObjectContext!.delete(myItem8 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest9 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        // Set the predicate on the fetch request
        fetchRequest9.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults9 = (try? managedObjectContext!.fetch(fetchRequest9)) as? [MeetingTasks]
        
        for myItem9 in fetchResults9!
        {
            managedObjectContext!.delete(myItem9 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest10 = NSFetchRequest<NSFetchRequestResult>(entityName: "Panes")
        
        // Set the predicate on the fetch request
        fetchRequest10.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults10 = (try? managedObjectContext!.fetch(fetchRequest10)) as? [Panes]
        
        for myItem10 in fetchResults10!
        {
            managedObjectContext!.delete(myItem10 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest11 = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        // Set the predicate on the fetch request
        fetchRequest11.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults11 = (try? managedObjectContext!.fetch(fetchRequest11)) as? [Projects]
        
        for myItem11 in fetchResults11!
        {
            managedObjectContext!.delete(myItem11 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest12 = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectTeamMembers")
        
        // Set the predicate on the fetch request
        fetchRequest12.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults12 = (try? managedObjectContext!.fetch(fetchRequest12)) as? [ProjectTeamMembers]
        
        for myItem12 in fetchResults12!
        {
            managedObjectContext!.delete(myItem12 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest14 = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        
        // Set the predicate on the fetch request
        fetchRequest14.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults14 = (try? managedObjectContext!.fetch(fetchRequest14)) as? [Roles]
        
        for myItem14 in fetchResults14!
        {
            managedObjectContext!.delete(myItem14 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest15 = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
        
        // Set the predicate on the fetch request
        fetchRequest15.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults15 = (try? managedObjectContext!.fetch(fetchRequest15)) as? [Stages]
        
        for myItem15 in fetchResults15!
        {
            managedObjectContext!.delete(myItem15 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest16 = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Set the predicate on the fetch request
        fetchRequest16.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults16 = (try? managedObjectContext!.fetch(fetchRequest16)) as? [Task]
        
        for myItem16 in fetchResults16!
        {
            managedObjectContext!.delete(myItem16 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest17 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAttachment")
        
        // Set the predicate on the fetch request
        fetchRequest17.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults17 = (try? managedObjectContext!.fetch(fetchRequest17)) as? [TaskAttachment]
        
        for myItem17 in fetchResults17!
        {
            managedObjectContext!.delete(myItem17 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest18 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        // Set the predicate on the fetch request
        fetchRequest18.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults18 = (try? managedObjectContext!.fetch(fetchRequest18)) as? [TaskContext]
        
        for myItem18 in fetchResults18!
        {
            managedObjectContext!.delete(myItem18 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest19 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskUpdates")
        
        // Set the predicate on the fetch request
        fetchRequest19.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults19 = (try? managedObjectContext!.fetch(fetchRequest19)) as? [TaskUpdates]
        
        for myItem19 in fetchResults19!
        {
            managedObjectContext!.delete(myItem19 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest21 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskPredecessor")
        
        // Set the predicate on the fetch request
        fetchRequest21.predicate = predicate
        let fetchResults21 = (try? managedObjectContext!.fetch(fetchRequest21)) as? [TaskPredecessor]
        
        for myItem21 in fetchResults21!
        {
            managedObjectContext!.delete(myItem21 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest22 = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        let fetchResults22 = (try? managedObjectContext!.fetch(fetchRequest22)) as? [Team]
        
        for myItem22 in fetchResults22!
        {
            managedObjectContext!.delete(myItem22 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest23 = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectNote")
        
        // Set the predicate on the fetch request
        fetchRequest23.predicate = predicate
        let fetchResults23 = (try? managedObjectContext!.fetch(fetchRequest23)) as? [ProjectNote]
        
        for myItem23 in fetchResults23!
        {
            managedObjectContext!.delete(myItem23 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest24 = NSFetchRequest<NSFetchRequestResult>(entityName: "Context1_1")
        
        // Set the predicate on the fetch request
        fetchRequest24.predicate = predicate
        let fetchResults24 = (try? managedObjectContext!.fetch(fetchRequest24)) as? [Context1_1]
        
        for myItem24 in fetchResults24!
        {
            managedObjectContext!.delete(myItem24 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest25 = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDItem")
        
        // Set the predicate on the fetch request
        fetchRequest25.predicate = predicate
        let fetchResults25 = (try? managedObjectContext!.fetch(fetchRequest25)) as? [GTDItem]
        
        for myItem25 in fetchResults25!
        {
            managedObjectContext!.delete(myItem25 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest26 = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDLevel")
        
        // Set the predicate on the fetch request
        fetchRequest26.predicate = predicate
        let fetchResults26 = (try? managedObjectContext!.fetch(fetchRequest26)) as? [GTDLevel]
        
        for myItem26 in fetchResults26!
        {
            managedObjectContext!.delete(myItem26 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest27 = NSFetchRequest<NSFetchRequestResult>(entityName: "ProcessedEmails")
        
        // Set the predicate on the fetch request
        fetchRequest27.predicate = predicate
        let fetchResults27 = (try? managedObjectContext!.fetch(fetchRequest27)) as? [ProcessedEmails]
        
        for myItem27 in fetchResults27!
        {
            managedObjectContext!.delete(myItem27 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest28 = NSFetchRequest<NSFetchRequestResult>(entityName: "Outline")
        
        // Set the predicate on the fetch request
        fetchRequest28.predicate = predicate
        let fetchResults28 = (try? managedObjectContext!.fetch(fetchRequest28)) as? [Outline]
        
        for myItem28 in fetchResults28!
        {
            managedObjectContext!.delete(myItem28 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest29 = NSFetchRequest<NSFetchRequestResult>(entityName: "OutlineDetails")
        
        // Set the predicate on the fetch request
        fetchRequest29.predicate = predicate
        let fetchResults29 = (try? managedObjectContext!.fetch(fetchRequest29)) as? [OutlineDetails]
        
        for myItem29 in fetchResults29!
        {
            managedObjectContext!.delete(myItem29 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

    }

    func clearSyncedItems()
    {
        let predicate = NSPredicate(format: "(updateType != \"\")")
        
        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? managedObjectContext!.fetch(fetchRequest2)) as? [Context]
        
        for myItem2 in fetchResults2!
        {
            myItem2.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest3 = NSFetchRequest<NSFetchRequestResult>(entityName: "Decodes")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults3 = (try? managedObjectContext!.fetch(fetchRequest3)) as? [Decodes]
        
        for myItem3 in fetchResults3!
        {
            myItem3.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest5 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Set the predicate on the fetch request
        fetchRequest5.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults5 = (try? managedObjectContext!.fetch(fetchRequest5)) as? [MeetingAgenda]
        
        for myItem5 in fetchResults5!
        {
            myItem5.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest6 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgendaItem")
        
        // Set the predicate on the fetch request
        fetchRequest6.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults6 = (try? managedObjectContext!.fetch(fetchRequest6)) as? [MeetingAgendaItem]
        
        for myItem6 in fetchResults6!
        {
            myItem6.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
       
        let fetchRequest7 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAttendees")
        
        // Set the predicate on the fetch request
        fetchRequest7.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults7 = (try? managedObjectContext!.fetch(fetchRequest7)) as? [MeetingAttendees]
        
        for myItem7 in fetchResults7!
        {
            myItem7.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest8 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingSupportingDocs")
        
        // Set the predicate on the fetch request
        fetchRequest8.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults8 = (try? managedObjectContext!.fetch(fetchRequest8)) as? [MeetingSupportingDocs]
        
        for myItem8 in fetchResults8!
        {
            myItem8.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest9 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        // Set the predicate on the fetch request
        fetchRequest9.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults9 = (try? managedObjectContext!.fetch(fetchRequest9)) as? [MeetingTasks]
        
        for myItem9 in fetchResults9!
        {
            myItem9.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest10 = NSFetchRequest<NSFetchRequestResult>(entityName: "Panes")
        
        // Set the predicate on the fetch request
        fetchRequest10.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults10 = (try? managedObjectContext!.fetch(fetchRequest10)) as? [Panes]
        
        for myItem10 in fetchResults10!
        {
            myItem10.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest11 = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        // Set the predicate on the fetch request
        fetchRequest11.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults11 = (try? managedObjectContext!.fetch(fetchRequest11)) as? [Projects]
        
        for myItem11 in fetchResults11!
        {
            myItem11.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest12 = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectTeamMembers")
        
        // Set the predicate on the fetch request
        fetchRequest12.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults12 = (try? managedObjectContext!.fetch(fetchRequest12)) as? [ProjectTeamMembers]
        
        for myItem12 in fetchResults12!
        {
            myItem12.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest14 = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        
        // Set the predicate on the fetch request
        fetchRequest14.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults14 = (try? managedObjectContext!.fetch(fetchRequest14)) as? [Roles]
        
        for myItem14 in fetchResults14!
        {
            myItem14.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest15 = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
        
        // Set the predicate on the fetch request
        fetchRequest15.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults15 = (try? managedObjectContext!.fetch(fetchRequest15)) as? [Stages]
        
        for myItem15 in fetchResults15!
        {
            myItem15.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest16 = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Set the predicate on the fetch request
        fetchRequest16.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults16 = (try? managedObjectContext!.fetch(fetchRequest16)) as? [Task]
        
        for myItem16 in fetchResults16!
        {
            myItem16.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest17 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAttachment")
        
        // Set the predicate on the fetch request
        fetchRequest17.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults17 = (try? managedObjectContext!.fetch(fetchRequest17)) as? [TaskAttachment]
        
        for myItem17 in fetchResults17!
        {
            myItem17.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest18 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        // Set the predicate on the fetch request
        fetchRequest18.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults18 = (try? managedObjectContext!.fetch(fetchRequest18)) as? [TaskContext]
        
        for myItem18 in fetchResults18!
        {
            myItem18.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest19 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskUpdates")
        
        // Set the predicate on the fetch request
        fetchRequest19.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults19 = (try? managedObjectContext!.fetch(fetchRequest19)) as? [TaskUpdates]
        
        for myItem19 in fetchResults19!
        {
            myItem19.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest21 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskPredecessor")
        
        // Set the predicate on the fetch request
        fetchRequest21.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults21 = (try? managedObjectContext!.fetch(fetchRequest21)) as? [TaskPredecessor]
        
        for myItem21 in fetchResults21!
        {
            myItem21.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest22 = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults22 = (try? managedObjectContext!.fetch(fetchRequest22)) as? [Team]
        
        for myItem22 in fetchResults22!
        {
            myItem22.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }

        let fetchRequest23 = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectNote")
        // Set the predicate on the fetch request
        fetchRequest23.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults23 = (try? managedObjectContext!.fetch(fetchRequest23)) as? [ProjectNote]
        
        for myItem23 in fetchResults23!
        {
            myItem23.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest24 = NSFetchRequest<NSFetchRequestResult>(entityName: "Context1_1")
        // Set the predicate on the fetch request
        fetchRequest24.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults24 = (try? managedObjectContext!.fetch(fetchRequest24)) as? [Context1_1]
        
        for myItem24 in fetchResults24!
        {
            myItem24.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest25 = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDItem")
        // Set the predicate on the fetch request
        fetchRequest25.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults25 = (try? managedObjectContext!.fetch(fetchRequest25)) as? [GTDItem]
        
        for myItem25 in fetchResults25!
        {
            myItem25.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }

        let fetchRequest26 = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDLevel")
        // Set the predicate on the fetch request
        fetchRequest26.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults26 = (try? managedObjectContext!.fetch(fetchRequest26)) as? [GTDLevel]
        
        for myItem26 in fetchResults26!
        {
            myItem26.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest27 = NSFetchRequest<NSFetchRequestResult>(entityName: "ProcessedEmails")
        // Set the predicate on the fetch request
        fetchRequest27.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults27 = (try? managedObjectContext!.fetch(fetchRequest27)) as? [ProcessedEmails]
        
        for myItem27 in fetchResults27!
        {
            myItem27.updateType = ""
            
            managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                    print("Failure to save context: \(error)")
                }
            }
        }
        
        let fetchRequest28 = NSFetchRequest<NSFetchRequestResult>(entityName: "Outline")
        // Set the predicate on the fetch request
        fetchRequest28.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults28 = (try? managedObjectContext!.fetch(fetchRequest28)) as? [Outline]
        
        for myItem28 in fetchResults28!
        {
            myItem28.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        let fetchRequest29 = NSFetchRequest<NSFetchRequestResult>(entityName: "OutlineDetails")
        // Set the predicate on the fetch request
        fetchRequest29.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults29 = (try? managedObjectContext!.fetch(fetchRequest29)) as? [OutlineDetails]
        
        for myItem29 in fetchResults29!
        {
            myItem29.updateType = ""
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }
    
    func saveTeam(_ inTeamID: Int, inName: String, inStatus: String, inNote: String, inType: String, inPredecessor: Int, inExternalID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myTeam: Team!
        
        let myTeams = getTeam(inTeamID)
        
        if myTeams.count == 0
        { // Add
            myTeam = NSEntityDescription.insertNewObject(forEntityName: "Team", into: self.managedObjectContext!) as! Team
            myTeam.teamID = NSNumber(value: inTeamID)
            myTeam.name = inName
            myTeam.status = inStatus
            myTeam.note = inNote
            myTeam.type = inType
            myTeam.predecessor = NSNumber(value: inPredecessor)
            myTeam.externalID = NSNumber(value: inExternalID)
            if inUpdateType == "CODE"
            {
                myTeam.updateTime = Date()
                myTeam.updateType = "Add"
            }
            else
            {
                myTeam.updateTime = inUpdateTime
                myTeam.updateType = inUpdateType
            }
        }
        else
        { // Update
            myTeam = myTeams[0]
            myTeam.name = inName
            myTeam.status = inStatus
            myTeam.note = inNote
            myTeam.type = inType
            myTeam.predecessor = NSNumber(value: inPredecessor)
            myTeam.externalID = NSNumber(value: inExternalID)
            if inUpdateType == "CODE"
            {
                if myTeam.updateType != "Add"
                {
                    myTeam.updateType = "Update"
                }
                myTeam.updateTime = Date()
            }
            else
            {
                myTeam.updateTime = inUpdateTime
                myTeam.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func replaceTeam(_ inTeamID: Int, inName: String, inStatus: String, inNote: String, inType: String, inPredecessor: Int, inExternalID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myTeam = NSEntityDescription.insertNewObject(forEntityName: "Team", into: self.managedObjectContext!) as! Team
            myTeam.teamID = NSNumber(value: inTeamID)
            myTeam.name = inName
            myTeam.status = inStatus
            myTeam.note = inNote
            myTeam.type = inType
            myTeam.predecessor = NSNumber(value: inPredecessor)
            myTeam.externalID = NSNumber(value: inExternalID)
            if inUpdateType == "CODE"
            {
                myTeam.updateTime = Date()
                myTeam.updateType = "Add"
            }
            else
            {
                myTeam.updateTime = inUpdateTime
                myTeam.updateType = inUpdateType
            }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
                self.refreshObject(myTeam)
        }
    }

    func getTeam(_ inTeamID: Int)->[Team]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Team]
        
        return fetchResults!
    }
    
    func getAllTeams()->[Team]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Team]
    
        return fetchResults!
    }
    
    func getMyTeams(_ myID: String)->[Team]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Team]
        
        return fetchResults!
    }
    
    func getTeamsCount() -> Int
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        fetchRequest.shouldRefreshRefetchedObjects = true
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Team]
        
        return fetchResults!.count
    }
    
    func deleteAllTeams()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Team]
        
        for myItem in fetchResults!
        {
            managedObjectContext!.delete(myItem as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDLevel")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? managedObjectContext!.fetch(fetchRequest2)) as? [GTDLevel]
        
        for myItem2 in fetchResults2!
        {
            managedObjectContext!.delete(myItem2 as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func saveProjectNote(_ inProjectID: Int, inNote: String, inReviewPeriod: String, inPredecessor: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myProjectNote: ProjectNote!
        
        let myTeams = getProjectNote(inProjectID)
        
        if myTeams.count == 0
        { // Add
            myProjectNote = NSEntityDescription.insertNewObject(forEntityName: "ProjectNote", into: self.managedObjectContext!) as! ProjectNote
            myProjectNote.projectID = NSNumber(value: inProjectID)
            myProjectNote.note = inNote

            myProjectNote.reviewPeriod = inReviewPeriod
            myProjectNote.predecessor = NSNumber(value: inPredecessor)
            if inUpdateType == "CODE"
            {
                myProjectNote.updateTime = Date()
                myProjectNote.updateType = "Add"
            }
            else
            {
                myProjectNote.updateTime = inUpdateTime
                myProjectNote.updateType = inUpdateType
            }
        }
        else
        { // Update
            myProjectNote = myTeams[0]
            myProjectNote.note = inNote
            myProjectNote.reviewPeriod = inReviewPeriod
            myProjectNote.predecessor = NSNumber(value: inPredecessor)
            if inUpdateType == "CODE"
            {
                if myProjectNote.updateType != "Add"
                {
                    myProjectNote.updateType = "Update"
                }
                myProjectNote.updateTime = Date()
            }
            else
            {
                myProjectNote.updateTime = inUpdateTime
                myProjectNote.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
 
    func replaceProjectNote(_ inProjectID: Int, inNote: String, inReviewPeriod: String, inPredecessor: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myProjectNote = NSEntityDescription.insertNewObject(forEntityName: "ProjectNote", into: self.managedObjectContext!) as! ProjectNote
            myProjectNote.projectID = NSNumber(value: inProjectID)
            myProjectNote.note = inNote
            
            myProjectNote.reviewPeriod = inReviewPeriod
            myProjectNote.predecessor = NSNumber(value: inPredecessor)
            if inUpdateType == "CODE"
            {
                myProjectNote.updateTime = Date()
                myProjectNote.updateType = "Add"
            }
            else
            {
                myProjectNote.updateTime = inUpdateTime
                myProjectNote.updateType = inUpdateType
            }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func getProjectNote(_ inProjectID: Int)->[ProjectNote]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectNote")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (projectID == \(inProjectID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProjectNote]
        
        return fetchResults!
    }

    func getNextID(_ inTableName: String, inInitialValue: Int = 1) -> Int
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Decodes")
        let predicate = NSPredicate(format: "(decode_name == \"\(inTableName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Decodes]
        
        if fetchResults!.count == 0
        {
            // Create table entry
            let storeKey = "\(inInitialValue)"
            updateDecodeValue(inTableName, inCodeValue: storeKey, inCodeType: "hidden")

            return inInitialValue
        }
        else
        {
            // Increment table value by 1 and save back to database
            let storeint = Int(fetchResults![0].decode_value)! + 1
            
            let storeKey = "\(storeint)"
            updateDecodeValue(inTableName, inCodeValue: storeKey, inCodeType: "hidden")

            return storeint
        }
    }
    
    func initialiseTeamForMeetingAgenda(_ inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = NSNumber(value: inTeamID)
            }
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }

    func initialiseTeamForContext(_ inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")
        
        let sortDescriptor = NSSortDescriptor(key: "contextID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = NSNumber(value: inTeamID)
                maxID = myItem.contextID as Int
            }
        
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Context", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func initialiseTeamForProject(_ inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        let sortDescriptor = NSSortDescriptor(key: "projectID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Projects]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = NSNumber(value: inTeamID)
                maxID = myItem.projectID as Int
            }
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Projects", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func initialiseTeamForRoles(_ inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        
        let sortDescriptor = NSSortDescriptor(key: "roleID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Roles]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = NSNumber(value: inTeamID)
                maxID = myItem.roleID as Int
            }
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Roles", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func initialiseTeamForStages(_ inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Stages]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = NSNumber(value: inTeamID)
            }
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
    }

    func initialiseTeamForTask(_ inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        let sortDescriptor = NSSortDescriptor(key: "taskID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = NSNumber(value: inTeamID)
                maxID = myItem.taskID as Int
            }
            
            managedObjectContext!.performAndWait
                {
                    do
                    {
                        try self.managedObjectContext!.save()
                    }
                    catch let error as NSError
                    {
                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                        
                        print("Failure to save context: \(error)")
                    }
            }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Task", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func saveContext1_1(_ contextID: Int, predecessor: Int, contextType: String, updateTime: Date = Date(), updateType: String = "CODE")
    {
        var myContext: Context1_1!
        
        let myContexts = getContext1_1(contextID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObject(forEntityName: "Context1_1", into: self.managedObjectContext!) as! Context1_1
            myContext.contextID = contextID as NSNumber?
            myContext.predecessor = predecessor as NSNumber?
            myContext.contextType = contextType
            if updateType == "CODE"
            {
                myContext.updateTime = Date()
                myContext.updateType = "Add"

            }
            else
            {
                myContext.updateTime = updateTime
                myContext.updateType = updateType
            }
        }
        else
        {
            myContext = myContexts[0]
            myContext.predecessor = predecessor as NSNumber?
            myContext.contextType = contextType
            if updateType == "CODE"
            {
                myContext.updateTime = Date()
                if myContext.updateType != "Add"
                {
                    myContext.updateType = "Update"
                }
            }
            else
            {
                myContext.updateTime = updateTime
                myContext.updateType = updateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func replaceContext1_1(_ contextID: Int, predecessor: Int, contextType: String, updateTime: Date = Date(), updateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myContext = NSEntityDescription.insertNewObject(forEntityName: "Context1_1", into: self.managedObjectContext!) as! Context1_1
        myContext.contextID = contextID as NSNumber?
        myContext.predecessor = predecessor as NSNumber?
        myContext.contextType = contextType
        if updateType == "CODE"
        {
            myContext.updateTime = Date()
            myContext.updateType = "Add"
        }
        else
        {
            myContext.updateTime = updateTime
            myContext.updateType = updateType
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func getContext1_1(_ inContextID: Int)->[Context1_1]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context1_1")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (contextID == \(inContextID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "contextID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context1_1]
        
        return fetchResults!
    }
    
    func resetDecodes()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Decodes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(decodeType != \"hidden\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Decodes]
        
        for myItem in fetchResults!
        {
            managedObjectContext!.delete(myItem as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func performTidyDecodes(_ inString: String)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Decodes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: inString)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Decodes]
        
        for myItem in fetchResults!
        {
            managedObjectContext!.delete(myItem as NSManagedObject)
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func tidyDecodes()
    {
        performTidyDecodes("(decode_name == \"Context\") && (decode_value == \"1\")")
        performTidyDecodes("(decode_name == \"Projects\") && (decode_value == \"2\")")
        performTidyDecodes("(decode_name == \"Roles\") && (decode_value == \"8\")")
        performTidyDecodes("(decode_name == \"Vision\")")
        performTidyDecodes("(decode_name == \"PurposeAndCoreValue\")")
        performTidyDecodes("(decode_name == \"GoalAndObjective\")")
        performTidyDecodes("(decode_name == \"AreaOfResponsibility\")")
        performTidyDecodes("(decode_name == \"Outline\")")
    }
    
    func getContextsForSync(_ inLastSyncDate: Date) -> [Context]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")

        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context]
        
        return fetchResults!
    }

    func getContexts1_1ForSync(_ inLastSyncDate: Date) -> [Context1_1]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Context1_1")
     
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Context1_1]
        
        return fetchResults!
    }

    func getDecodesForSync(_ inLastSyncDate: Date) -> [Decodes]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Decodes")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Decodes]
        
        return fetchResults!
    }

    func getGTDItemsForSync(_ inLastSyncDate: Date) -> [GTDItem]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDItem")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [GTDItem]
        
        return fetchResults!
    }
    
    func getGTDLevelsForSync(_ inLastSyncDate: Date) -> [GTDLevel]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDLevel")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [GTDLevel]
        
        return fetchResults!
    }
    
    func getMeetingAgendasForSync(_ inLastSyncDate: Date) -> [MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func getMeetingAgendaItemsForSync(_ inLastSyncDate: Date) -> [MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgendaItem")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAgendaItem]
        
        return fetchResults!
    }
    
    func getMeetingAttendeesForSync(_ inLastSyncDate: Date) -> [MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAttendees")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingAttendees]
        
        return fetchResults!
    }
    
    func getMeetingSupportingDocsForSync(_ inLastSyncDate: Date) -> [MeetingSupportingDocs]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingSupportingDocs")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingSupportingDocs]
        
        return fetchResults!
    }
    
    func getMeetingTasksForSync(_ inLastSyncDate: Date) -> [MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func getPanesForSync(_ inLastSyncDate: Date) -> [Panes]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Panes]
        
        return fetchResults!
    }
    
    func getProjectsForSync(_ inLastSyncDate: Date) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Projects]
        
        return fetchResults!
    }
    
    func getProjectNotesForSync(_ inLastSyncDate: Date) -> [ProjectNote]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectNote")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProjectNote]
        
        return fetchResults!
    }
    
    func getProjectTeamMembersForSync(_ inLastSyncDate: Date) -> [ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectTeamMembers")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProjectTeamMembers]
        
        return fetchResults!
    }

    func getRolesForSync(_ inLastSyncDate: Date) -> [Roles]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Roles]
        
        return fetchResults!
    }
    
    func getStagesForSync(_ inLastSyncDate: Date) -> [Stages]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Stages]
        
        return fetchResults!
    }

    func getTaskForSync(_ inLastSyncDate: Date) -> [Task]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Task]
        
        return fetchResults!
    }

    func getTaskAttachmentsForSync(_ inLastSyncDate: Date) -> [TaskAttachment]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAttachment")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskAttachment]
        
        return fetchResults!
    }
    
    func getTaskContextsForSync(_ inLastSyncDate: Date) -> [TaskContext]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskContext]
        
        return fetchResults!
    }
    
    func getTaskPredecessorsForSync(_ inLastSyncDate: Date) -> [TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskPredecessor]
        
        return fetchResults!
    }
    
    func getTaskUpdatesForSync(_ inLastSyncDate: Date) -> [TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskUpdates")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [TaskUpdates]
        
        return fetchResults!
    }
    
    func getTeamsForSync(_ inLastSyncDate: Date) -> [Team]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Team]
        
        return fetchResults!
    }
    
    func getProcessedEmailsForSync(_ inLastSyncDate: Date) -> [ProcessedEmails]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProcessedEmails")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProcessedEmails]
        
        return fetchResults!
    }

    func getOutlineForSync(_ inLastSyncDate: Date) -> [Outline]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Outline")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Outline]
        
        return fetchResults!
    }
    
    func getOutlineDetailsForSync(_ inLastSyncDate: Date) -> [OutlineDetails]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OutlineDetails")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [OutlineDetails]
        
        return fetchResults!
    }
    
    func deleteAllCoreData()
    {
        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Context")
        managedObjectContext!.performAndWait
            {
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? self.managedObjectContext!.fetch(fetchRequest2)) as? [Context]
 

        for myItem2 in fetchResults2!
        {
            self.managedObjectContext!.delete(myItem2 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest3 = NSFetchRequest<NSFetchRequestResult>(entityName: "Decodes")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults3 = (try? self.managedObjectContext!.fetch(fetchRequest3)) as? [Decodes]

        for myItem3 in fetchResults3!
        {
            self.managedObjectContext!.delete(myItem3 as NSManagedObject)
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest5 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults5 = (try? self.managedObjectContext!.fetch(fetchRequest5)) as? [MeetingAgenda]

        for myItem5 in fetchResults5!
        {
            self.managedObjectContext!.delete(myItem5 as NSManagedObject)
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest6 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAgendaItem")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults6 = (try? self.managedObjectContext!.fetch(fetchRequest6)) as? [MeetingAgendaItem]

        for myItem6 in fetchResults6!
        {
            self.managedObjectContext!.delete(myItem6 as NSManagedObject)
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest7 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingAttendees")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults7 = (try? self.managedObjectContext!.fetch(fetchRequest7)) as? [MeetingAttendees]

        for myItem7 in fetchResults7!
        {
            self.managedObjectContext!.delete(myItem7 as NSManagedObject)
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest8 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingSupportingDocs")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults8 = (try? self.managedObjectContext!.fetch(fetchRequest8)) as? [MeetingSupportingDocs]
                
                for myItem8 in fetchResults8!
        {
            self.managedObjectContext!.delete(myItem8 as NSManagedObject)
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest9 = NSFetchRequest<NSFetchRequestResult>(entityName: "MeetingTasks")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults9 = (try? self.managedObjectContext!.fetch(fetchRequest9)) as? [MeetingTasks]

        for myItem9 in fetchResults9!
        {
            self.managedObjectContext!.delete(myItem9 as NSManagedObject)
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest10 = NSFetchRequest<NSFetchRequestResult>(entityName: "Panes")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults10 = (try? self.managedObjectContext!.fetch(fetchRequest10)) as? [Panes]

            for myItem10 in fetchResults10!
        {
            self.managedObjectContext!.delete(myItem10 as NSManagedObject)
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest11 = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults11 = (try? self.managedObjectContext!.fetch(fetchRequest11)) as? [Projects]

        for myItem11 in fetchResults11!
        {
            self.managedObjectContext!.delete(myItem11 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest12 = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectTeamMembers")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults12 = (try? self.managedObjectContext!.fetch(fetchRequest12)) as? [ProjectTeamMembers]

        for myItem12 in fetchResults12!
        {
            self.managedObjectContext!.delete(myItem12 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest14 = NSFetchRequest<NSFetchRequestResult>(entityName: "Roles")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        
        managedObjectContext!.performAndWait
        {
            let fetchResults14 = (try? self.managedObjectContext!.fetch(fetchRequest14)) as? [Roles]

            for myItem14 in fetchResults14!
            {
                self.managedObjectContext!.delete(myItem14 as NSManagedObject)
            }
    
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest15 = NSFetchRequest<NSFetchRequestResult>(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults15 = (try? self.managedObjectContext!.fetch(fetchRequest15)) as? [Stages]

        for myItem15 in fetchResults15!
        {
            self.managedObjectContext!.delete(myItem15 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest16 = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults16 = (try? self.managedObjectContext!.fetch(fetchRequest16)) as? [Task]

        for myItem16 in fetchResults16!
        {
            self.managedObjectContext!.delete(myItem16 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest17 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAttachment")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults17 = (try? self.managedObjectContext!.fetch(fetchRequest17)) as? [TaskAttachment]

        for myItem17 in fetchResults17!
        {
            self.managedObjectContext!.delete(myItem17 as NSManagedObject)
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest18 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskContext")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults18 = (try? self.managedObjectContext!.fetch(fetchRequest18)) as? [TaskContext]

        for myItem18 in fetchResults18!
        {
            self.managedObjectContext!.delete(myItem18 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest19 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskUpdates")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performAndWait
            {
                let fetchResults19 = (try? self.managedObjectContext!.fetch(fetchRequest19)) as? [TaskUpdates]

        for myItem19 in fetchResults19!
        {
            self.managedObjectContext!.delete(myItem19 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest21 = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskPredecessor")
        
        managedObjectContext!.performAndWait
            {
                let fetchResults21 = (try? self.managedObjectContext!.fetch(fetchRequest21)) as? [TaskPredecessor]

        for myItem21 in fetchResults21!
        {
            self.managedObjectContext!.delete(myItem21 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest22 = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        
        managedObjectContext!.performAndWait
            {
                let fetchResults22 = (try? self.managedObjectContext!.fetch(fetchRequest22)) as? [Team]

        for myItem22 in fetchResults22!
        {
            self.managedObjectContext!.delete(myItem22 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest23 = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectNote")
        
        managedObjectContext!.performAndWait
            {
                let fetchResults23 = (try? self.managedObjectContext!.fetch(fetchRequest23)) as? [ProjectNote]

        for myItem23 in fetchResults23!
        {
            self.managedObjectContext!.delete(myItem23 as NSManagedObject)
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest24 = NSFetchRequest<NSFetchRequestResult>(entityName: "Context1_1")
        
        managedObjectContext!.performAndWait
            {
                let fetchResults24 = (try? self.managedObjectContext!.fetch(fetchRequest24)) as? [Context1_1]
                
        for myItem24 in fetchResults24!
        {
            self.managedObjectContext!.delete(myItem24 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest25 = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDItem")
        
        managedObjectContext!.performAndWait
            {
                let fetchResults25 = (try? self.managedObjectContext!.fetch(fetchRequest25)) as? [GTDItem]

        for myItem25 in fetchResults25!
        {
            self.managedObjectContext!.delete(myItem25 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest26 = NSFetchRequest<NSFetchRequestResult>(entityName: "GTDLevel")
        
        managedObjectContext!.performAndWait
            {
                let fetchResults26 = (try? self.managedObjectContext!.fetch(fetchRequest26)) as? [GTDLevel]

        for myItem26 in fetchResults26!
        {
            self.managedObjectContext!.delete(myItem26 as NSManagedObject)
        }
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest27 = NSFetchRequest<NSFetchRequestResult>(entityName: "ProcessedEmails")
        
        managedObjectContext!.performAndWait
            {
                let fetchResults27 = (try? self.managedObjectContext!.fetch(fetchRequest27)) as? [ProcessedEmails]
                
                for myItem27 in fetchResults27!
                {
                    self.managedObjectContext!.delete(myItem27 as NSManagedObject)
                }
                
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

        let fetchRequest28 = NSFetchRequest<NSFetchRequestResult>(entityName: "Outline")
        
        managedObjectContext!.performAndWait
            {
                let fetchResults28 = (try? self.managedObjectContext!.fetch(fetchRequest28)) as? [Outline]
                
                for myItem28 in fetchResults28!
                {
                    self.managedObjectContext!.delete(myItem28 as NSManagedObject)
                }
                
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        let fetchRequest29 = NSFetchRequest<NSFetchRequestResult>(entityName: "OutlineDetails")
        
        managedObjectContext!.performAndWait
            {
                let fetchResults29 = (try? self.managedObjectContext!.fetch(fetchRequest29)) as? [OutlineDetails]
                
                for myItem29 in fetchResults29!
                {
                    self.managedObjectContext!.delete(myItem29 as NSManagedObject)
                }
                
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }

    func saveProcessedEmail(_ emailID: String, emailType: String, processedDate: Date, updateTime: Date = Date(), updateType: String = "CODE")
    {
        var myEmail: ProcessedEmails!
        
        let myEmailItems = getProcessedEmail(emailID)
        
        if myEmailItems.count == 0
        { // Add
            myEmail = NSEntityDescription.insertNewObject(forEntityName: "ProcessedEmails", into: self.managedObjectContext!) as! ProcessedEmails
            myEmail.emailID = emailID
            myEmail.emailType = emailType
            myEmail.processedDate = processedDate

            if updateType == "CODE"
            {
                myEmail.updateTime = Date()
                myEmail.updateType = "Add"
            }
            else
            {
                myEmail.updateTime = updateTime
                myEmail.updateType = updateType
            }
        }
        else
        { // Update
            myEmail = myEmailItems[0]
            myEmail.emailType = emailType
            myEmail.processedDate = processedDate
            if updateType == "CODE"
            {
                if myEmail.updateType != "Add"
                {
                    myEmail.updateType = "Update"
                }
            }
            else
            {
                myEmail.updateTime = updateTime
                myEmail.updateType = updateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        myCloudDB.saveProcessedEmailsRecordToCloudKit(myEmail)
    }
    
    func replaceProcessedEmail(_ emailID: String, emailType: String, processedDate: Date, updateTime: Date = Date(), updateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
        let myEmail = NSEntityDescription.insertNewObject(forEntityName: "ProcessedEmails", into: self.managedObjectContext!) as! ProcessedEmails
        myEmail.emailID = emailID
        myEmail.emailType = emailType
        myEmail.processedDate = processedDate
        
        if updateType == "CODE"
        {
            myEmail.updateTime = Date()
            myEmail.updateType = "Add"
        }
        else
        {
            myEmail.updateTime = updateTime
            myEmail.updateType = updateType
        }

                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func deleteProcessedEmail(_ emailID: String)
    {
        var myEmail: ProcessedEmails!
        
        let myEmailItems = getProcessedEmail(emailID)
        
        if myEmailItems.count > 0
        { // Update
            myEmail = myEmailItems[0]
            myEmail.updateTime = Date()
            myEmail.updateType = "Delete"
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }

    }
    
    func getProcessedEmail(_ emailID: String)->[ProcessedEmails]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProcessedEmails")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(emailID == \"\(emailID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [ProcessedEmails]
        
        return fetchResults!
    }

    func saveOutline(_ outlineID: Int, parentID: Int, parentType: String, title: String, status: String, updateTime: Date = Date(), updateType: String = "CODE")
    {
        var myOutline: Outline!
        
        let myOutlineItems = getOutline(outlineID)
        
        if myOutlineItems.count == 0
        { // Add
            myOutline = NSEntityDescription.insertNewObject(forEntityName: "Outline", into: self.managedObjectContext!) as! Outline
            myOutline.outlineID = outlineID as NSNumber?
            myOutline.parentID = parentID as NSNumber?
            myOutline.parentType = parentType
            myOutline.title = title
            myOutline.status = status
            
            if updateType == "CODE"
            {
                myOutline.updateTime = Date()
                myOutline.updateType = "Add"
            }
            else
            {
                myOutline.updateTime = updateTime
                myOutline.updateType = updateType
            }
        }
        else
        { // Update
            myOutline = myOutlineItems[0]
            myOutline.parentID = parentID as NSNumber?
            myOutline.parentType = parentType
            myOutline.title = title
            myOutline.status = status
            if updateType == "CODE"
            {
                if myOutline.updateType != "Add"
                {
                    myOutline.updateType = "Update"
                }
            }
            else
            {
                myOutline.updateTime = updateTime
                myOutline.updateType = updateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        myCloudDB.saveOutlineRecordToCloudKit(myOutline)
    }
    
    func replaceOutline(_ outlineID: Int, parentID: Int, parentType: String, title: String, status: String, updateTime: Date = Date(), updateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
                let myOutline = NSEntityDescription.insertNewObject(forEntityName: "Outline", into: self.managedObjectContext!) as! Outline
                myOutline.outlineID = outlineID as NSNumber?
                myOutline.parentID = parentID as NSNumber?
                myOutline.parentType = parentType
                myOutline.title = title
                myOutline.status = status
                
                if updateType == "CODE"
                {
                    myOutline.updateTime = Date()
                    myOutline.updateType = "Add"
                }
                else
                {
                    myOutline.updateTime = updateTime
                    myOutline.updateType = updateType
                }
                
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func deleteOutline(_ outlineID: Int)
    {
        var myOutline: Outline!
        
        let myOutlineItems = getOutline(outlineID)
        
        if myOutlineItems.count > 0
        { // Update
            myOutline = myOutlineItems[0]
            myOutline.updateTime = Date()
            myOutline.updateType = "Delete"
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
    }
    
    func getOutline(_ outlineID: Int)->[Outline]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Outline")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(outlineID == \"\(outlineID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [Outline]
        
        return fetchResults!
    }

    func saveOutlineDetail(_ outlineID: Int, lineID: Int, lineOrder: Int, parentLine: Int, lineText: String, lineType: String, checkBoxValue: Bool, updateTime: Date = Date(), updateType: String = "CODE")
    {
        var myOutline: OutlineDetails!
        
        let myOutlineItems = getOutlineDetails(outlineID, lineID: lineID)
        
        if myOutlineItems.count == 0
        { // Add
            myOutline = NSEntityDescription.insertNewObject(forEntityName: "OutlineDetails", into: self.managedObjectContext!) as! OutlineDetails
            myOutline.outlineID = outlineID as NSNumber?
            myOutline.lineID = lineID as NSNumber?
            myOutline.lineOrder = lineOrder as NSNumber?
            myOutline.parentLine = parentLine as NSNumber?
            myOutline.lineText = lineText
            myOutline.lineType = lineType
            myOutline.checkBoxValue = checkBoxValue as NSNumber?

            if updateType == "CODE"
            {
                myOutline.updateTime = Date()
                myOutline.updateType = "Add"
            }
            else
            {
                myOutline.updateTime = updateTime
                myOutline.updateType = updateType
            }
        }
        else
        { // Update
            myOutline = myOutlineItems[0]
            myOutline.lineOrder = lineOrder as NSNumber?
            myOutline.parentLine = parentLine as NSNumber?
            myOutline.lineText = lineText
            myOutline.lineType = lineType
            myOutline.checkBoxValue = checkBoxValue as NSNumber?
            
            if updateType == "CODE"
            {
                if myOutline.updateType != "Add"
                {
                    myOutline.updateType = "Update"
                }
            }
            else
            {
                myOutline.updateTime = updateTime
                myOutline.updateType = updateType
            }
        }
        
        managedObjectContext!.perform
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
        myCloudDB.saveOutlineDetailsRecordToCloudKit(myOutline)
    }
    
    func replaceOutlineDetails(_ outlineID: Int, lineID: Int, lineOrder: Int, parentLine: Int, lineText: String, lineType: String, checkBoxValue: Bool, updateTime: Date = Date(), updateType: String = "CODE")
    {
        managedObjectContext!.perform
            {
                let myOutline = NSEntityDescription.insertNewObject(forEntityName: "OutlineDetails", into: self.managedObjectContext!) as! OutlineDetails
                myOutline.outlineID = outlineID as NSNumber?
                myOutline.lineID = lineID as NSNumber?
                myOutline.lineOrder = lineOrder as NSNumber?
                myOutline.parentLine = parentLine as NSNumber?
                myOutline.lineText = lineText
                myOutline.lineType = lineType
                myOutline.checkBoxValue = checkBoxValue as NSNumber?
                
                if updateType == "CODE"
                {
                    myOutline.updateTime = Date()
                    myOutline.updateType = "Add"
                }
                else
                {
                    myOutline.updateTime = updateTime
                    myOutline.updateType = updateType
                }
                
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
    }
    
    func deleteOutlineDetails(_ outlineID: Int, lineID: Int)
    {
        var myOutline: OutlineDetails!
        
        let myOutlineItems = getOutlineDetails(outlineID, lineID: lineID)
        
        if myOutlineItems.count > 0
        { // Update
            myOutline = myOutlineItems[0]
            myOutline.updateTime = Date()
            myOutline.updateType = "Delete"
        }
        
        managedObjectContext!.performAndWait
            {
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error as NSError
                {
                    NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
                    
                    print("Failure to save context: \(error)")
                }
        }
        
    }
    
    func getOutlineDetails(_ outlineID: Int, lineID: Int)->[OutlineDetails]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OutlineDetails")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(outlineID == \"\(outlineID)\") && (lineID == \"\(lineID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.fetch(fetchRequest)) as? [OutlineDetails]
        
        return fetchResults!
    }
}
