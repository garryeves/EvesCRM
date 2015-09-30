//
//  coreDatabase.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 14/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import CoreData


class coreDatabase: NSObject
{
    
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    func refreshObject(objectID: NSManagedObject)
    {
        managedObjectContext!.refreshObject(objectID, mergeChanges: true)
      //  managedObjectContext!.processPendingChanges()
      //  managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    func getOpenProjectsForGTDItem(inGTDItemID: Int, inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Completed\") && (projectStatus != \"Deleted\") && (areaID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        let sortDescriptor = NSSortDescriptor(key: "projectID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Projects]
        
        return fetchResults!
    }

    
    func getProjectDetails(projectID: Int)->[Projects]
    {
        
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Projects]
        
        return fetchResults!
    }
    
    func getProjectSuccessor(projectID: Int)->Int
    {
        
        let fetchRequest = NSFetchRequest(entityName: "ProjectNote")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(predecessor == \(projectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProjectNote]
        
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

    func getGTDItemSuccessor(projectID: Int)->Int
    {
        
        let fetchRequest = NSFetchRequest(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(predecessor == \(projectID)) && (updateType != \"Delete\") && (status != \"Closed\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDItem]
        
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
  
    func getAllProjects(inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Projects]
        
        return fetchResults!
    }
    
    func getProjectCount()->Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Projects]
        
        return fetchResults!.count
    }
    
    func getRoles(inTeamID: Int)->[Roles]
    {
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Roles]
        
        return fetchResults!
    }
    
    func deleteAllRoles(inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "Roles")

        let predicate = NSPredicate(format: "(teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Roles]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
            
         //   managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }
    
    func getMaxRoleID()-> Int
    {
        var retVal: Int = 0
        
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        
        fetchRequest.propertiesToFetch = ["roleID"]
        
        let sortDescriptor = NSSortDescriptor(key: "roleID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Roles]
        
        for myItem in fetchResults!
        {
            retVal = myItem.roleID as Int
        }
        
        return retVal + 1
    }
    
    func saveRole(roleName: String, teamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE", roleID: Int = 0)
    {
        
        
        let myRoles = getRole(roleID, teamID: teamID)
        
        managedObjectContext!.performBlock
            {
                var mySelectedRole: Roles
        if myRoles.count == 0
        {
            
            mySelectedRole = NSEntityDescription.insertNewObjectForEntityForName("Roles", inManagedObjectContext: self.managedObjectContext!) as! Roles
        
            // Get the role number
            mySelectedRole.roleID = self.getNextID("Roles")
            mySelectedRole.roleDescription = roleName
            mySelectedRole.teamID = teamID
            if inUpdateType == "CODE"
            {
                mySelectedRole.updateTime = NSDate()
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
                mySelectedRole.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    func replaceRole(roleName: String, teamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE", roleID: Int = 0)
    {
        managedObjectContext!.performBlock
            {
        let mySelectedRole = NSEntityDescription.insertNewObjectForEntityForName("Roles", inManagedObjectContext: self.managedObjectContext!) as! Roles
                    
                    // Get the role number
                    mySelectedRole.roleID = roleID
                    mySelectedRole.roleDescription = roleName
                    mySelectedRole.teamID = teamID
                    if inUpdateType == "CODE"
                    {
                        mySelectedRole.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    
    func getRole(roleID: Int, teamID: Int)->[Roles]
    {
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (roleID == \(roleID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Roles]
        
        return fetchResults!
    }
    
    func deleteRoleEntry(inRoleName: String, inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        
        let predicate = NSPredicate(format: "(roleDescription == \"\(inRoleName)\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Roles]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
           // managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }
    
    func saveTeamMember(inProjectID: Int, inRoleID: Int, inPersonName: String, inNotes: String, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myProjectTeam: ProjectTeamMembers!
        
        let myProjectTeamRecords = getTeamMemberRecord(inProjectID, inPersonName: inPersonName)
        if myProjectTeamRecords.count == 0
        { // Add
            myProjectTeam = NSEntityDescription.insertNewObjectForEntityForName("ProjectTeamMembers", inManagedObjectContext: self.managedObjectContext!) as! ProjectTeamMembers
            myProjectTeam.projectID = inProjectID
            myProjectTeam.teamMember = inPersonName
            myProjectTeam.roleID = inRoleID
            myProjectTeam.projectMemberNotes = inNotes
            if inUpdateType == "CODE"
            {
                myProjectTeam.updateTime = NSDate()
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
            myProjectTeam.roleID = inRoleID
            myProjectTeam.projectMemberNotes = inNotes
            if inUpdateType == "CODE"
            {
                myProjectTeam.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    func replaceTeamMember(inProjectID: Int, inRoleID: Int, inPersonName: String, inNotes: String, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myProjectTeam = NSEntityDescription.insertNewObjectForEntityForName("ProjectTeamMembers", inManagedObjectContext: self.managedObjectContext!) as! ProjectTeamMembers
            myProjectTeam.projectID = inProjectID
            myProjectTeam.teamMember = inPersonName
            myProjectTeam.roleID = inRoleID
            myProjectTeam.projectMemberNotes = inNotes
            if inUpdateType == "CODE"
            {
                myProjectTeam.updateTime = NSDate()
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
        
        
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    
    func deleteTeamMember(inProjectID: Int, inPersonName: String)
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) AND (teamMember == \"\(inPersonName)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProjectTeamMembers]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
            // managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }

    func getTeamMemberRecord(inProjectID: Int, inPersonName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) && (teamMember == \"\(inPersonName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    func getTeamMembers(inProjectID: NSNumber)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(inProjectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    func getProjects(inTeamID: Int, inArchiveFlag: Bool = false) -> [Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
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
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Projects]
        
        return fetchResults!

    }
    
    func getProjectsForPerson(inPersonName: String)->[ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(teamMember == \"\(inPersonName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProjectTeamMembers]
        
        return fetchResults!
    }
    
    func getRoleDescription(inRoleID: NSNumber, inTeamID: Int)->String
    {
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        let predicate = NSPredicate(format: "(roleID == \(inRoleID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Roles]
        
        if fetchResults!.count == 0
        {
            return ""
        }
        else
        {
            return fetchResults![0].roleDescription
        }
    }
    
    func getDecodeValue(inCodeKey: String) -> String
    {
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
   //     let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\") && (updateType != \"Delete\")")
        let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Decodes]
        
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
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
        
 //       let predicate = NSPredicate(format: "(decodeType != \"hidden\") && (updateType != \"Delete\")")
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Decodes]
        
        return fetchResults!
    }
    
    func updateDecodeValue(inCodeKey: String, inCodeValue: String, inCodeType: String, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        // first check to see if decode exists, if not we create
        var myDecode: Decodes!
        
        if getDecodeValue(inCodeKey) == ""
        { // Add
            myDecode = NSEntityDescription.insertNewObjectForEntityForName("Decodes", inManagedObjectContext: managedObjectContext!) as! Decodes
            
            myDecode.decode_name = inCodeKey
            myDecode.decode_value = inCodeValue
            myDecode.decodeType = inCodeType
            if inUpdateType == "CODE"
            {
                myDecode.updateTime = NSDate()
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
            let fetchRequest = NSFetchRequest(entityName: "Decodes")
            let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\") && (updateType != \"Delete\")")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
            
            // Execute the fetch request, and cast the results to an array of  objects
            let myDecodes = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Decodes]
            myDecode = myDecodes![0]
            myDecode.decode_value = inCodeValue
            myDecode.decodeType = inCodeType
            if inUpdateType == "CODE"
            {
                myDecode.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func replaceDecodeValue(inCodeKey: String, inCodeValue: String, inCodeType: String, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myDecode = NSEntityDescription.insertNewObjectForEntityForName("Decodes", inManagedObjectContext: self.managedObjectContext!) as! Decodes
            
        myDecode.decode_name = inCodeKey
        myDecode.decode_value = inCodeValue
        myDecode.decodeType = inCodeType
        if inUpdateType == "CODE"
        {
            myDecode.updateTime = NSDate()
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
    
    func getStages(inTeamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Stages]
        
        return fetchResults!
    }
    
    func getVisibleStages(inTeamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
    
        let predicate = NSPredicate(format: "(stageDescription != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
    
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Stages]
        
        return fetchResults!
    }
    
    func deleteAllStages(inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        let predicate = NSPredicate(format: "(teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Stages]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        //    managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }

    func stageExists(inStageDesc:String, inTeamID: Int)-> Bool
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(stageDescription == \"\(inStageDesc)\") && (teamID == \(inTeamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Stages]
        
        if fetchResults!.count > 0
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func getStage(stageDesc:String, teamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (stageDescription == \"\(stageDesc)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Stages]
        
        return fetchResults!
    }
    
    func saveStage(stageDesc: String, teamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myStage: Stages!
        
        let myStages = getStage(stageDesc, teamID: teamID)
        
        if myStages.count == 0
        {
            myStage = NSEntityDescription.insertNewObjectForEntityForName("Stages", inManagedObjectContext: managedObjectContext!) as! Stages
        
            myStage.stageDescription = stageDesc
            myStage.teamID = teamID
            if inUpdateType == "CODE"
            {
                myStage.updateTime = NSDate()
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
                myStage.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func replaceStage(stageDesc: String, teamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myStage = NSEntityDescription.insertNewObjectForEntityForName("Stages", inManagedObjectContext: self.managedObjectContext!) as! Stages
            
            myStage.stageDescription = stageDesc
            myStage.teamID = teamID
            if inUpdateType == "CODE"
            {
                myStage.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    
    func deleteStageEntry(inStageDesc: String, inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        let predicate = NSPredicate(format: "(stageDescription == \"\(inStageDesc)\") && (teamID == \(inTeamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Stages]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

//            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }
    
    func searchPastAgendaByPartialMeetingIDBeforeStart(inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID contains \"\(inSearchText)\") && (startTime <= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func searchPastAgendaWithoutPartialMeetingIDBeforeStart(inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(teamID == \(inTeamID))  && (updateType != \"Delete\") && (startTime <= %@) && (not meetingID contains \"\(inSearchText)\") ", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }

    func listAgendaReverseDateBeforeStart(inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime <= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func searchPastAgendaByPartialMeetingIDAfterStart(inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID contains \"\(inSearchText)\") && (startTime >= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func searchPastAgendaWithoutPartialMeetingIDAfterStart(inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
 
        predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID)) && NOT (meetingID contains \"\(inSearchText)\") && (startTime >= %@)", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func listAgendaReverseDateAfterStart(inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime >= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inMeetingStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func createAgenda(inEvent: myCalendarItem)
    {
        saveAgenda(inEvent.eventID, inPreviousMeetingID : inEvent.previousMinutes, inName: inEvent.title, inChair: inEvent.chair, inMinutes: inEvent.minutes, inLocation: inEvent.location, inStartTime: inEvent.startDate, inEndTime: inEvent.endDate, inMinutesType: inEvent.minutesType, inTeamID: inEvent.teamID)
    }
    
    func saveAgenda(inMeetingID: String, inPreviousMeetingID : String, inName: String, inChair: String, inMinutes: String, inLocation: String, inStartTime: NSDate, inEndTime: NSDate, inMinutesType: String, inTeamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myAgenda: MeetingAgenda
        
        let myAgendas = loadAgenda(inMeetingID, inTeamID: inTeamID)
        
        if myAgendas.count == 0
        {
            myAgenda = NSEntityDescription.insertNewObjectForEntityForName("MeetingAgenda", inManagedObjectContext: managedObjectContext!) as! MeetingAgenda
            myAgenda.meetingID = inMeetingID
            myAgenda.previousMeetingID = inPreviousMeetingID
            myAgenda.name = inName
            myAgenda.chair = inChair
            myAgenda.minutes = inMinutes
            myAgenda.location = inLocation
            myAgenda.startTime = inStartTime
            myAgenda.endTime = inEndTime
            myAgenda.minutesType = inMinutesType
            myAgenda.teamID = inTeamID
            if inUpdateType == "CODE"
            {
                myAgenda.updateTime = NSDate()
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
            let myAgenda = myAgendas[0]
            myAgenda.previousMeetingID = inPreviousMeetingID
            myAgenda.name = inName
            myAgenda.chair = inChair
            myAgenda.minutes = inMinutes
            myAgenda.location = inLocation
            myAgenda.startTime = inStartTime
            myAgenda.endTime = inEndTime
            myAgenda.minutesType = inMinutesType
            myAgenda.teamID = inTeamID
            if inUpdateType == "CODE"
            {
                myAgenda.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    func replaceAgenda(inMeetingID: String, inPreviousMeetingID : String, inName: String, inChair: String, inMinutes: String, inLocation: String, inStartTime: NSDate, inEndTime: NSDate, inMinutesType: String, inTeamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myAgenda = NSEntityDescription.insertNewObjectForEntityForName("MeetingAgenda", inManagedObjectContext: self.managedObjectContext!) as! MeetingAgenda
            myAgenda.meetingID = inMeetingID
            myAgenda.previousMeetingID = inPreviousMeetingID
            myAgenda.name = inName
            myAgenda.chair = inChair
            myAgenda.minutes = inMinutes
            myAgenda.location = inLocation
            myAgenda.startTime = inStartTime
            myAgenda.endTime = inEndTime
            myAgenda.minutesType = inMinutesType
            myAgenda.teamID = inTeamID
            if inUpdateType == "CODE"
            {
                myAgenda.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    
    func loadPreviousAgenda(inMeetingID: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(previousMeetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")

        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func loadAgenda(inMeetingID: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }

    func updatePreviousAgendaID(inPreviousMeetingID: String, inMeetingID: String, inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        for myResult in fetchResults!
        {
            myResult.previousMeetingID = inPreviousMeetingID
            myResult.updateTime = NSDate()
            if myResult.updateType != "Add"
            {
                myResult.updateType = "Update"
            }
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func loadAgendaForProject(inProjectName: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name contains \"\(inProjectName)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
   
    func getAgendaForDateRange(inStartDate: NSDate, inEndDate: NSDate, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime >= %@) && (endTime <= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inStartDate, inEndDate)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func loadAttendees(inMeetingID: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAttendees]
        
        return fetchResults!
    }
    
    func loadMeetingsForAttendee(inAttendeeName: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name == \"\(inAttendeeName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAttendees]
        
        return fetchResults!
    }

    func saveAttendee(inMeetingID: String, inAttendees: [meetingAttendee])
    {
        var myPerson: MeetingAttendees
        
        // Before we can add attendees, we first need to clear out the existing entries
        deleteAllAttendees(inMeetingID)
        
        for myAttendee in inAttendees
        {
            myPerson = NSEntityDescription.insertNewObjectForEntityForName("MeetingAttendees", inManagedObjectContext: managedObjectContext!) as! MeetingAttendees
            myPerson.attendenceStatus = myAttendee.status
            myPerson.meetingID = inMeetingID
            myPerson.email = myAttendee.emailAddress
            myPerson.name = myAttendee.name
            myPerson.type = myAttendee.type
            myPerson.updateTime = NSDate()
            myPerson.updateType = "Add"
            
            managedObjectContext!.performBlock
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
    }
    
    
    func checkMeetingsForAttendee(attendeeName: String, meetingID: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name == \"\(attendeeName)\") && (updateType != \"Delete\") && (meetingID == \"\(meetingID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAttendees]
        
        return fetchResults!
    }

    
    func saveAttendee(meetingID: String, name: String, email: String,  type: String, status: String, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myPerson: MeetingAttendees!
        
        let myMeeting = checkMeetingsForAttendee(name, meetingID: meetingID)
        
        if myMeeting.count == 0
        {
            myPerson = NSEntityDescription.insertNewObjectForEntityForName("MeetingAttendees", inManagedObjectContext: managedObjectContext!) as! MeetingAttendees
            myPerson.meetingID = meetingID
            myPerson.name = name
            myPerson.attendenceStatus = status
            myPerson.email = email
            myPerson.type = type
            if inUpdateType == "CODE"
            {
                myPerson.updateTime = NSDate()
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
                myPerson.updateTime = NSDate()
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
            
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    func replaceAttendee(meetingID: String, name: String, email: String,  type: String, status: String, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myPerson = NSEntityDescription.insertNewObjectForEntityForName("MeetingAttendees", inManagedObjectContext: self.managedObjectContext!) as! MeetingAttendees
            myPerson.meetingID = meetingID
            myPerson.name = name
            myPerson.attendenceStatus = status
            myPerson.email = email
            myPerson.type = type
            if inUpdateType == "CODE"
            {
                myPerson.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    func deleteAllAttendees(inMeetingID: String)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest(entityName: "MeetingAttendees")
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAttendees]
        
        for myMeeting in fetchResults!
        {
            myMeeting.updateTime = NSDate()
            myMeeting.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

         //   managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
    }
    
    func loadAgendaItem(inMeetingID: String)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgendaItem]
        
        return fetchResults!
    }
    
    func saveAgendaItem(inMeetingID: String, inItem: meetingAgendaItem)
    {
        var mySavedItem: MeetingAgendaItem
        
        mySavedItem = NSEntityDescription.insertNewObjectForEntityForName("MeetingAgendaItem", inManagedObjectContext: managedObjectContext!) as! MeetingAgendaItem
        mySavedItem.meetingID = inMeetingID
        if inItem.actualEndTime != nil
        {
            mySavedItem.actualEndTime = inItem.actualEndTime!
        }
        if inItem.actualStartTime != nil
        {
            mySavedItem.actualStartTime = inItem.actualStartTime!
        }
        mySavedItem.status = inItem.status
        mySavedItem.decisionMade = inItem.decisionMade
        mySavedItem.discussionNotes = inItem.discussionNotes
        mySavedItem.timeAllocation = inItem.timeAllocation
        mySavedItem.owner = inItem.owner
        mySavedItem.title = inItem.title
        mySavedItem.agendaID = inItem.agendaID
        mySavedItem.updateTime = NSDate()
        mySavedItem.updateTime = NSDate()
        mySavedItem.updateType = "Add"

        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

    }
    
    func saveAgendaItem(meetingID: String, actualEndTime: NSDate, actualStartTime: NSDate, status: String, decisionMade: String, discussionNotes: String, timeAllocation: Int, owner: String, title: String, agendaID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var mySavedItem: MeetingAgendaItem
        
        let myAgendaItem = loadSpecificAgendaItem(meetingID,inAgendaID: agendaID)
        
        if myAgendaItem.count == 0
        {
            mySavedItem = NSEntityDescription.insertNewObjectForEntityForName("MeetingAgendaItem", inManagedObjectContext: managedObjectContext!) as! MeetingAgendaItem
            mySavedItem.meetingID = meetingID
            mySavedItem.agendaID = agendaID
            mySavedItem.actualEndTime = actualEndTime
            mySavedItem.actualStartTime = actualStartTime
            mySavedItem.status = status
            mySavedItem.decisionMade = decisionMade
            mySavedItem.discussionNotes = discussionNotes
            mySavedItem.timeAllocation = timeAllocation
            mySavedItem.owner = owner
            mySavedItem.title = title
            if inUpdateType == "CODE"
            {
                mySavedItem.updateTime = NSDate()
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
            mySavedItem.timeAllocation = timeAllocation
            mySavedItem.owner = owner
            mySavedItem.title = title
            if inUpdateType == "CODE"
            {
                mySavedItem.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
    }
    
    func replaceAgendaItem(meetingID: String, actualEndTime: NSDate, actualStartTime: NSDate, status: String, decisionMade: String, discussionNotes: String, timeAllocation: Int, owner: String, title: String, agendaID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let mySavedItem = NSEntityDescription.insertNewObjectForEntityForName("MeetingAgendaItem", inManagedObjectContext: self.managedObjectContext!) as! MeetingAgendaItem
            mySavedItem.meetingID = meetingID
            mySavedItem.agendaID = agendaID
            mySavedItem.actualEndTime = actualEndTime
            mySavedItem.actualStartTime = actualStartTime
            mySavedItem.status = status
            mySavedItem.decisionMade = decisionMade
            mySavedItem.discussionNotes = discussionNotes
            mySavedItem.timeAllocation = timeAllocation
            mySavedItem.owner = owner
            mySavedItem.title = title
            if inUpdateType == "CODE"
            {
                mySavedItem.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
    }
    
    
    func loadSpecificAgendaItem(inMeetingID: String, inAgendaID: Int)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") AND (agendaID == \(inAgendaID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgendaItem]
        
        return fetchResults!
    }
    
    func updateAgendaItem(inMeetingID: String, inItem: meetingAgendaItem)
    {
        let myAgendaItem = loadSpecificAgendaItem(inMeetingID,inAgendaID: inItem.agendaID)[0]
        if inItem.actualEndTime != nil
        {
            myAgendaItem.actualEndTime = inItem.actualEndTime!
        }
        if inItem.actualStartTime != nil
        {
            myAgendaItem.actualStartTime = inItem.actualStartTime!
        }
        myAgendaItem.status = inItem.status
        myAgendaItem.decisionMade = inItem.decisionMade
        myAgendaItem.discussionNotes = inItem.discussionNotes
        myAgendaItem.timeAllocation = inItem.timeAllocation
        myAgendaItem.owner = inItem.owner
        myAgendaItem.title = inItem.title
        myAgendaItem.updateTime = NSDate()
        if myAgendaItem.updateType != "Add"
        {
            myAgendaItem.updateType = "Update"
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

    }

    func deleteAgendaItem(inMeetingID: String, inItem: meetingAgendaItem)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") AND (agendaID == \(inItem.agendaID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgendaItem]
        
        for myMeeting in fetchResults!
        {
            myMeeting.updateTime = NSDate()
            myMeeting.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

           // managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
    }
    
    func deleteAllAgendaItems(inMeetingID: String)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "meetingID == \"\(inMeetingID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgendaItem]
        
        for myMeeting in fetchResults!
        {
            myMeeting.updateTime = NSDate()
            myMeeting.updateType = "Delete"
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }


           // managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
    }

    func saveTask(inTaskID: Int, inTitle: String, inDetails: String, inDueDate: NSDate, inStartDate: NSDate, inStatus: String, inPriority: String, inEnergyLevel: String, inEstimatedTime: Int, inEstimatedTimeType: String, inProjectID: Int, inCompletionDate: NSDate, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inFlagged: Bool, inUrgency: String, inTeamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myTask: Task!
        
        let myTasks = getTask(inTaskID)
        
        if myTasks.count == 0
        { // Add
            myTask = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: self.managedObjectContext!) as! Task
            myTask.taskID = inTaskID
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = inEstimatedTime
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = inProjectID
            myTask.completionDate = inCompletionDate
            myTask.repeatInterval = inRepeatInterval
            myTask.repeatType = inRepeatType
            myTask.repeatBase = inRepeatBase
            myTask.flagged = inFlagged
            myTask.urgency = inUrgency
            myTask.teamID = inTeamID
            
            if inUpdateType == "CODE"
            {
                myTask.updateTime = NSDate()
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
            myTask.estimatedTime = inEstimatedTime
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = inProjectID
            myTask.completionDate = inCompletionDate
            myTask.repeatInterval = inRepeatInterval
            myTask.repeatType = inRepeatType
            myTask.repeatBase = inRepeatBase
            myTask.flagged = inFlagged
            myTask.urgency = inUrgency
            myTask.teamID = inTeamID
            
            if inUpdateType == "CODE"
            {
                myTask.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func replaceTask(inTaskID: Int, inTitle: String, inDetails: String, inDueDate: NSDate, inStartDate: NSDate, inStatus: String, inPriority: String, inEnergyLevel: String, inEstimatedTime: Int, inEstimatedTimeType: String, inProjectID: Int, inCompletionDate: NSDate, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inFlagged: Bool, inUrgency: String, inTeamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myTask = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: self.managedObjectContext!) as! Task
            myTask.taskID = inTaskID
            myTask.title = inTitle
            myTask.details = inDetails
            myTask.dueDate = inDueDate
            myTask.startDate = inStartDate
            myTask.status = inStatus
            myTask.priority = inPriority
            myTask.energyLevel = inEnergyLevel
            myTask.estimatedTime = inEstimatedTime
            myTask.estimatedTimeType = inEstimatedTimeType
            myTask.projectID = inProjectID
            myTask.completionDate = inCompletionDate
            myTask.repeatInterval = inRepeatInterval
            myTask.repeatType = inRepeatType
            myTask.repeatBase = inRepeatBase
            myTask.flagged = inFlagged
            myTask.urgency = inUrgency
            myTask.teamID = inTeamID
            
            if inUpdateType == "CODE"
            {
                myTask.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func deleteTask(inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        let predicate = NSPredicate(format: "taskID == \(inTaskID)")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

//            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }
    
    func getTasksNotDeleted(inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "taskID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        
        return fetchResults!
    }

    func getAllTasksForProject(inProjectID: Int, inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(inProjectID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        
        return fetchResults!
    }
    
    func getTasksForProject(projectID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(projectID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        
        return fetchResults!
    }
    
    func getActiveTasksForProject(projectID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
       let predicate = NSPredicate(format: "(projectID = \(projectID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\") && (status != \"Pause\") && ((startDate == %@) || (startDate <= %@))", getDefaultDate(), NSDate())
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        
        return fetchResults!
    }

    func getTasksWithoutProject(teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == 0) && (updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\") && (status != \"Complete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        
        return fetchResults!
    }
    
    func getTaskWithoutContext(teamID: Int)->[Task]
    {
        // first get a list of all tasks that have a context
        
        let fetchContext = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate1 = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchContext.predicate = predicate1

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchContextResults = (try? managedObjectContext!.executeFetchRequest(fetchContext)) as? [TaskContext]
        
        // Get the list of all current tasks
        let fetchTask = NSFetchRequest(entityName: "Task")
        
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate2 = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\") && (status != \"Complete\")")
        
        // Set the predicate on the fetch request
        fetchTask.predicate = predicate2
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchTaskResults = (try? managedObjectContext!.executeFetchRequest(fetchTask)) as? [Task]

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
    
    func getTask(taskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        
        return fetchResults!
    }
    
    func getActiveTask(taskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        
        return fetchResults!
    }

    func getTaskCount()->Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        
        return fetchResults!.count
    }
    
    func getTaskPredecessors(inTaskID: Int)->[TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskPredecessor")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskPredecessor]
        
        return fetchResults!
    }
   
    func savePredecessorTask(inTaskID: Int, inPredecessorID: Int, inPredecessorType: String, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myTask: TaskPredecessor!
        
        let myTasks = getTaskPredecessors(inTaskID)
        
        if myTasks.count == 0
        { // Add
            myTask = NSEntityDescription.insertNewObjectForEntityForName("TaskPredecessor", inManagedObjectContext: self.managedObjectContext!) as! TaskPredecessor
            myTask.taskID = inTaskID
            myTask.predecessorID = inPredecessorID
            myTask.predecessorType = inPredecessorType
            if inUpdateType == "CODE"
            {
                myTask.updateTime = NSDate()
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
            myTask.predecessorID = inPredecessorID
            myTask.predecessorType = inPredecessorType
            if inUpdateType == "CODE"
            {
                myTask.updateTime = NSDate()
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

        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func replacePredecessorTask(inTaskID: Int, inPredecessorID: Int, inPredecessorType: String, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myTask = NSEntityDescription.insertNewObjectForEntityForName("TaskPredecessor", inManagedObjectContext: self.managedObjectContext!) as! TaskPredecessor
            myTask.taskID = inTaskID
            myTask.predecessorID = inPredecessorID
            myTask.predecessorType = inPredecessorType
            if inUpdateType == "CODE"
            {
                myTask.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func updatePredecessorTaskType(inTaskID: Int, inPredecessorID: Int, inPredecessorType: String)
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (predecessorID == \(inPredecessorID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskPredecessor]
        for myStage in fetchResults!
        {
            myStage.predecessorType = inPredecessorType
            myStage.updateTime = NSDate()
            if myStage.updateType != "Add"
            {
                myStage.updateType = "Update"
            }
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
    }

    func deleteTaskPredecessor(inTaskID: Int, inPredecessorID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (predecessorID == \(inPredecessorID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskPredecessor]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
            //            managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }
    
    func saveProject(inProjectID: Int, inProjectEndDate: NSDate, inProjectName: String, inProjectStartDate: NSDate, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: NSDate, inGTDItemID: Int, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inTeamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID)
        
        if myProjects.count == 0
        { // Add
            myProject = NSEntityDescription.insertNewObjectForEntityForName("Projects", inManagedObjectContext: self.managedObjectContext!) as! Projects
            myProject.projectID = inProjectID
            myProject.projectEndDate = inProjectEndDate
            myProject.projectName = inProjectName
            myProject.projectStartDate = inProjectStartDate
            myProject.projectStatus = inProjectStatus
            myProject.reviewFrequency = inReviewFrequency
            myProject.lastReviewDate = inLastReviewDate
            myProject.areaID = inGTDItemID
            myProject.repeatInterval = inRepeatInterval
            myProject.repeatType = inRepeatType
            myProject.repeatBase = inRepeatBase
            myProject.teamID = inTeamID
            
            if inUpdateType == "CODE"
            {
                myProject.updateTime = NSDate()
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
            myProject.reviewFrequency = inReviewFrequency
            myProject.lastReviewDate = inLastReviewDate
            myProject.areaID = inGTDItemID
            myProject.repeatInterval = inRepeatInterval
            myProject.repeatType = inRepeatType
            myProject.repeatBase = inRepeatBase
            myProject.teamID = inTeamID
            if inUpdateType == "CODE"
            {
                myProject.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    func replaceProject(inProjectID: Int, inProjectEndDate: NSDate, inProjectName: String, inProjectStartDate: NSDate, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: NSDate, inGTDItemID: Int, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inTeamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myProject = NSEntityDescription.insertNewObjectForEntityForName("Projects", inManagedObjectContext: self.managedObjectContext!) as! Projects
            myProject.projectID = inProjectID
            myProject.projectEndDate = inProjectEndDate
            myProject.projectName = inProjectName
            myProject.projectStartDate = inProjectStartDate
            myProject.projectStatus = inProjectStatus
            myProject.reviewFrequency = inReviewFrequency
            myProject.lastReviewDate = inLastReviewDate
            myProject.areaID = inGTDItemID
            myProject.repeatInterval = inRepeatInterval
            myProject.repeatType = inRepeatType
            myProject.repeatBase = inRepeatBase
            myProject.teamID = inTeamID
            
            if inUpdateType == "CODE"
            {
                myProject.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    func deleteProject(inProjectID: Int, inTeamID: Int)
    {
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID)
        
        if myProjects.count > 0
        { // Update
            myProject = myProjects[0]
            myProject.updateTime = NSDate()
            myProject.updateType = "Delete"
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        var myProjectNote: ProjectNote!
        
        let myTeams = getProjectNote(inProjectID)
        
        if myTeams.count > 0
        { // Update
            myProjectNote = myTeams[0]
            myProjectNote.updateType = "Delete"
            myProjectNote.updateTime = NSDate()
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func saveTaskUpdate(inTaskID: Int, inDetails: String, inSource: String, inUpdateDate: NSDate = NSDate(), inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myTaskUpdate: TaskUpdates!

        if getTaskUpdate(inTaskID, updateDate: inUpdateDate).count == 0
        {
            myTaskUpdate = NSEntityDescription.insertNewObjectForEntityForName("TaskUpdates", inManagedObjectContext: self.managedObjectContext!) as! TaskUpdates
            myTaskUpdate.taskID = inTaskID
            myTaskUpdate.updateDate = inUpdateDate
            myTaskUpdate.details = inDetails
            myTaskUpdate.source = inSource
            if inUpdateType == "CODE"
            {
                myTaskUpdate.updateTime = NSDate()
                myTaskUpdate.updateType = "Add"
            }
            else
            {
                myTaskUpdate.updateTime = inUpdateTime
                myTaskUpdate.updateType = inUpdateType
            }
        
            managedObjectContext!.performBlock
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
    }
    
    func replaceTaskUpdate(inTaskID: Int, inDetails: String, inSource: String, inUpdateDate: NSDate = NSDate(), inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myTaskUpdate = NSEntityDescription.insertNewObjectForEntityForName("TaskUpdates", inManagedObjectContext: self.managedObjectContext!) as! TaskUpdates
            myTaskUpdate.taskID = inTaskID
            myTaskUpdate.updateDate = inUpdateDate
            myTaskUpdate.details = inDetails
            myTaskUpdate.source = inSource
            if inUpdateType == "CODE"
            {
                myTaskUpdate.updateTime = NSDate()
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


    func getTaskUpdate(taskID: Int, updateDate: NSDate)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (updateDate == %@)", updateDate)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskUpdates]
        
        return fetchResults!
    }
    
    func getTaskUpdates(inTaskID: Int)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskUpdates]
        
        return fetchResults!
    }

    func saveContext(inContextID: Int, inName: String, inEmail: String, inAutoEmail: String, inParentContext: Int, inStatus: String, inPersonID: Int, inTeamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myContext: Context!
        
        let myContexts = getContextDetails(inContextID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObjectForEntityForName("Context", inManagedObjectContext: self.managedObjectContext!) as! Context
            myContext.contextID = inContextID
            myContext.name = inName
            myContext.email = inEmail
            myContext.autoEmail = inAutoEmail
            myContext.parentContext = inParentContext
            myContext.status = inStatus
            myContext.personID = inPersonID
            myContext.teamID = inTeamID
            if inUpdateType == "CODE"
            {
                myContext.updateTime = NSDate()
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
            myContext.parentContext = inParentContext
            myContext.status = inStatus
            myContext.personID = inPersonID
            myContext.teamID = inTeamID
            if inUpdateType == "CODE"
            {
                myContext.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func replaceContext(inContextID: Int, inName: String, inEmail: String, inAutoEmail: String, inParentContext: Int, inStatus: String, inPersonID: Int, inTeamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myContext = NSEntityDescription.insertNewObjectForEntityForName("Context", inManagedObjectContext: self.managedObjectContext!) as! Context
        myContext.contextID = inContextID
        myContext.name = inName
        myContext.email = inEmail
        myContext.autoEmail = inAutoEmail
        myContext.parentContext = inParentContext
        myContext.status = inStatus
        myContext.personID = inPersonID
        myContext.teamID = inTeamID
        if inUpdateType == "CODE"
        {
            myContext.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    func deleteContext(inContextID: Int, inTeamID: Int)
    {
        let myContexts = getContextDetails(inContextID)
        
        if myContexts.count > 0
       {
            let myContext = myContexts[0]
            myContext.updateTime = NSDate()
            myContext.updateType = "Delete"
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let myContexts2 = getContext1_1(inContextID)
        
        if myContexts2.count > 0
        {
            let myContext = myContexts[0]
            myContext.updateTime = NSDate()
            myContext.updateType = "Delete"
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

    }
    
    func getContexts(inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(status != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Context]
        
        return fetchResults!
    }

    func getContextByName(inContextName: String, inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(name = \"\(inContextName)\") && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Context]
        
        return fetchResults!
    }
    
    func getContextDetails(contextID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID == \(contextID)) && (updateType != \"Delete\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Context]
        
        return fetchResults!
    }

    func getAllContexts(inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Context]
        
        return fetchResults!
    }
    
    func getContextCount()->Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Context]
        
        return fetchResults!.count
    }

    
    func saveTaskContext(inContextID: Int, inTaskID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myContext: TaskContext!
        
        let myContexts = getTaskContext(inContextID, inTaskID: inTaskID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObjectForEntityForName("TaskContext", inManagedObjectContext: self.managedObjectContext!) as! TaskContext
            myContext.contextID = inContextID
            myContext.taskID = inTaskID
            if inUpdateType == "CODE"
            {
                myContext.updateTime = NSDate()
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
                myContext.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

func replaceTaskContext(inContextID: Int, inTaskID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
{
    managedObjectContext!.performBlock
        {
    let myContext = NSEntityDescription.insertNewObjectForEntityForName("TaskContext", inManagedObjectContext: self.managedObjectContext!) as! TaskContext
        myContext.contextID = inContextID
        myContext.taskID = inTaskID
        if inUpdateType == "CODE"
        {
            myContext.updateTime = NSDate()
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
    
    //       do
    //       {
    //            try managedObjectContext!.save()
    //        }
    //        catch let error as NSError
    //        {
    //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
    
    //            print("Failure to save context: \(error)")
    //       }
}


    func deleteTaskContext(inContextID: Int, inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        let predicate = NSPredicate(format: "(contextID == \(inContextID)) AND (taskID = \(inTaskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskContext]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

          //  managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }
    }

    private func getTaskContext(inContextID: Int, inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) AND (contextID = \(inContextID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskContext]
        
        return fetchResults!
    }

    func getContextsForTask(inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskContext]
        
        return fetchResults!
    }

    func getTasksForContext(inContextID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID = \(inContextID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskContext]
        
        return fetchResults!
    }

    func saveGTDLevel(inGTDLevel: Int, inLevelName: String, inTeamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myGTD: GTDLevel!
        
        let myGTDItems = getGTDLevel(inGTDLevel, inTeamID: inTeamID)
        
        if myGTDItems.count == 0
        { // Add
            myGTD = NSEntityDescription.insertNewObjectForEntityForName("GTDLevel", inManagedObjectContext: self.managedObjectContext!) as! GTDLevel
            myGTD.gTDLevel = inGTDLevel
            myGTD.levelName = inLevelName
            myGTD.teamID = inTeamID
            
            if inUpdateType == "CODE"
            {
                myGTD.updateType = "Add"
                myGTD.updateTime = NSDate()
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
                myGTD.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func replaceGTDLevel(inGTDLevel: Int, inLevelName: String, inTeamID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myGTD = NSEntityDescription.insertNewObjectForEntityForName("GTDLevel", inManagedObjectContext: self.managedObjectContext!) as! GTDLevel
            myGTD.gTDLevel = inGTDLevel
            myGTD.levelName = inLevelName
            myGTD.teamID = inTeamID
            
            if inUpdateType == "CODE"
            {
                myGTD.updateType = "Add"
                myGTD.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func getGTDLevel(inGTDLevel: Int, inTeamID: Int)->[GTDLevel]
    {
        let fetchRequest = NSFetchRequest(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(inGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDLevel]
        
        return fetchResults!
    }
    
    func changeGTDLevel(oldGTDLevel: Int, newGTDLevel: Int, inTeamID: Int)
    {
        var myGTD: GTDLevel!
        
        let fetchRequest = NSFetchRequest(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(oldGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDLevel]
        
        if fetchResults!.count > 0
        { // Update
            myGTD = fetchResults![0]
         //   myGTD.gTDLevel = newGTDLevel
            myGTD.setValue(newGTDLevel, forKey: "gTDLevel")
            myGTD.updateTime = NSDate()
            if myGTD.updateType != "Add"
            {
                myGTD.updateType = "Update"
            }
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    
    func deleteGTDLevel(inGTDLevel: Int, inTeamID: Int)
    {
        var myGTD: GTDLevel!
        
        let myGTDItems = getGTDLevel(inGTDLevel, inTeamID: inTeamID)
        
        if myGTDItems.count > 0
        { // Update
            myGTD = myGTDItems[0]
            myGTD.updateTime = NSDate()
            myGTD.updateType = "Delete"
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    
    func getGTDLevels(inTeamID: Int)->[GTDLevel]
    {
        let fetchRequest = NSFetchRequest(entityName: "GTDLevel")
        
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
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDLevel]
        
        return fetchResults!
    }
    
    func saveGTDItem(inGTDItemID: Int, inParentID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: NSDate, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int, inGTDLevel: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myGTD: GTDItem!
        
        let myGTDItems = checkGTDItem(inGTDItemID, inTeamID: inTeamID)
        
        if myGTDItems.count == 0
        { // Add
            myGTD = NSEntityDescription.insertNewObjectForEntityForName("GTDItem", inManagedObjectContext: self.managedObjectContext!) as! GTDItem
            myGTD.gTDItemID = inGTDItemID
            myGTD.gTDParentID = inParentID
            myGTD.title = inTitle
            myGTD.status = inStatus
            myGTD.teamID = inTeamID
            myGTD.note = inNote
            myGTD.lastReviewDate = inLastReviewDate
            myGTD.reviewFrequency = inReviewFrequency
            myGTD.reviewPeriod = inReviewPeriod
            myGTD.predecessor = inPredecessor
            myGTD.gTDLevel = inGTDLevel
            if inUpdateType == "CODE"
            {
                myGTD.updateTime = NSDate()
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
            myGTD.gTDParentID = inParentID
            myGTD.title = inTitle
            myGTD.status = inStatus
            myGTD.updateTime = NSDate()
            myGTD.teamID = inTeamID
            myGTD.note = inNote
            myGTD.lastReviewDate = inLastReviewDate
            myGTD.reviewFrequency = inReviewFrequency
            myGTD.reviewPeriod = inReviewPeriod
            myGTD.predecessor = inPredecessor
            myGTD.gTDLevel = inGTDLevel
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
      
        managedObjectContext!.performBlock
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
    
 //       do
 //       {
//            try managedObjectContext!.save()
//        }
//        catch let error as NSError
//        {
//            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
//            print("Failure to save context: \(error)")
 //       }
    }
    
    func replaceGTDItem(inGTDItemID: Int, inParentID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: NSDate, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int, inGTDLevel: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myGTD = NSEntityDescription.insertNewObjectForEntityForName("GTDItem", inManagedObjectContext: self.managedObjectContext!) as! GTDItem
            myGTD.gTDItemID = inGTDItemID
            myGTD.gTDParentID = inParentID
            myGTD.title = inTitle
            myGTD.status = inStatus
            myGTD.teamID = inTeamID
            myGTD.note = inNote
            myGTD.lastReviewDate = inLastReviewDate
            myGTD.reviewFrequency = inReviewFrequency
            myGTD.reviewPeriod = inReviewPeriod
            myGTD.predecessor = inPredecessor
            myGTD.gTDLevel = inGTDLevel
            if inUpdateType == "CODE"
            {
                myGTD.updateTime = NSDate()
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

        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func deleteGTDItem(inGTDItemID: Int, inTeamID: Int)
    {
        var myGTD: GTDItem!
        
        let myGTDItems = checkGTDItem(inGTDItemID, inTeamID: inTeamID)
        
        if myGTDItems.count > 0
        { // Update
            myGTD = myGTDItems[0]
            myGTD.updateTime = NSDate()
            myGTD.updateType = "Delete"
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func getGTDItem(inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDItemID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDItem]
        
        return fetchResults!
    }
    
    func getGTDItemsForLevel(inGTDLevel: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(inGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDItem]
        
        return fetchResults!
    }
    
    func getGTDItemCount() -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "GTDItem")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDItem]
        
        return fetchResults!.count
    }
    
    func getOpenGTDChildItems(inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDParentID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDItem]
        
        return fetchResults!
    }
    
    private func checkGTDItem(inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDItemID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDItem]
        
        return fetchResults!
    }
    
    func resetprojects()
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
    
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProjectTeamMembers]
        for myStage in fetchResults!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

            //managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }

        let fetchRequest2 = NSFetchRequest(entityName: "Projects")
            
        // Execute the fetch request, and cast the results to an array of objects
        let fetchResults2 = (try? managedObjectContext!.executeFetchRequest(fetchRequest2)) as? [Projects]
        for myStage in fetchResults2!
        {
            myStage.updateTime = NSDate()
            myStage.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

          //  managedObjectContext!.deleteObject(myStage as NSManagedObject)
        }

    }
    
    func deleteAllPanes()
    {  // This is used to allow for testing of pane creation, so can delete all the panes if needed
        let fetchRequest = NSFetchRequest(entityName: "Panes")

        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Panes]
        for myPane in fetchResults!
        {
            myPane.updateTime = NSDate()
            myPane.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

         //   managedObjectContext!.deleteObject(myPane as NSManagedObject)
        }
    }

    func getPanes() -> [Panes]
    {
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
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
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Panes]
        
        return fetchResults!
    }

    func getPane(paneName:String) -> [Panes]
    {
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
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
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Panes]
        
        return fetchResults!
    }
    
    func togglePaneVisible(paneName: String)
    {
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Panes]
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
            
            myPane.updateTime = NSDate()
            if myPane.updateType != "Add"
            {
                myPane.updateType = "Update"
            }

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
    }

    func setPaneOrder(paneName: String, paneOrder: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Panes]
        for myPane in fetchResults!
        {
            myPane.pane_order = paneOrder
            myPane.updateTime = NSDate()
            if myPane.updateType != "Add"
            {
                myPane.updateType = "Update"
            }
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
    }
    
    func savePane(inPaneName:String, inPaneAvailable: Bool, inPaneVisible: Bool, inPaneOrder: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myPane: Panes!
        
        let myPanes = getPane(inPaneName)
        
        if myPanes.count == 0
        {
            // Save the details of this pane to the database
            myPane = NSEntityDescription.insertNewObjectForEntityForName("Panes", inManagedObjectContext: self.managedObjectContext!) as! Panes
        
            myPane.pane_name = inPaneName
            myPane.pane_available = inPaneAvailable
            myPane.pane_visible = inPaneVisible
            myPane.pane_order = inPaneOrder
            if inUpdateType == "CODE"
            {
                myPane.updateTime = NSDate()
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
            myPane.pane_available = inPaneAvailable
            myPane.pane_visible = inPaneVisible
            myPane.pane_order = inPaneOrder
            if inUpdateType == "CODE"
            {
                myPane.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func replacePane(inPaneName:String, inPaneAvailable: Bool, inPaneVisible: Bool, inPaneOrder: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myPane = NSEntityDescription.insertNewObjectForEntityForName("Panes", inManagedObjectContext: self.managedObjectContext!) as! Panes
            
            myPane.pane_name = inPaneName
            myPane.pane_available = inPaneAvailable
            myPane.pane_visible = inPaneVisible
            myPane.pane_order = inPaneOrder
            if inUpdateType == "CODE"
            {
                myPane.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    
    func resetMeetings()
    {
        let fetchRequest1 = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults1 = (try? managedObjectContext!.executeFetchRequest(fetchRequest1)) as? [MeetingAgenda]
        
        for myMeeting in fetchResults1!
        {
            myMeeting.updateTime = NSDate()
            myMeeting.updateType = "Delete"
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }


          //  managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }
        
        let fetchRequest2 = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? managedObjectContext!.executeFetchRequest(fetchRequest2)) as? [MeetingAttendees]
        
        for myMeeting2 in fetchResults2!
        {
            myMeeting2.updateTime = NSDate()
            myMeeting2.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

           // managedObjectContext!.deleteObject(myMeeting2 as NSManagedObject)
        }
        
        let fetchRequest3 = NSFetchRequest(entityName: "MeetingAgendaItem")

        let fetchResults3 = (try? managedObjectContext!.executeFetchRequest(fetchRequest3)) as? [MeetingAgendaItem]
        
        for myMeeting3 in fetchResults3!
        {
            myMeeting3.updateTime = NSDate()
            myMeeting3.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

            
           // managedObjectContext!.deleteObject(myMeeting3 as NSManagedObject)
        }
        
        let fetchRequest4 = NSFetchRequest(entityName: "MeetingTasks")
        
        let fetchResults4 = (try? managedObjectContext!.executeFetchRequest(fetchRequest4)) as? [MeetingTasks]
        
        for myMeeting4 in fetchResults4!
        {
            myMeeting4.updateTime = NSDate()
            myMeeting4.updateType = "Delete"
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

          //  managedObjectContext!.deleteObject(myMeeting4 as NSManagedObject)
        }
        
        let fetchRequest6 = NSFetchRequest(entityName: "MeetingSupportingDocs")
        
        let fetchResults6 = (try? managedObjectContext!.executeFetchRequest(fetchRequest6)) as? [MeetingSupportingDocs]
        
        for myMeeting6 in fetchResults6!
        {
            myMeeting6.updateTime = NSDate()
            myMeeting6.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

           // managedObjectContext!.deleteObject(myMeeting6 as NSManagedObject)
        }
    }
    
    func resetTasks()
    {
        let fetchRequest1 = NSFetchRequest(entityName: "MeetingTasks")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults1 = (try? managedObjectContext!.executeFetchRequest(fetchRequest1)) as? [MeetingTasks]
        
        for myMeeting in fetchResults1!
        {
            myMeeting.updateTime = NSDate()
            myMeeting.updateType = "Delete"
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

            
           // managedObjectContext!.deleteObject(myMeeting as NSManagedObject)
        }

        let fetchRequest2 = NSFetchRequest(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? managedObjectContext!.executeFetchRequest(fetchRequest2)) as? [Task]
        
        for myMeeting2 in fetchResults2!
        {
            myMeeting2.updateTime = NSDate()
            myMeeting2.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        //    managedObjectContext!.deleteObject(myMeeting2 as NSManagedObject)
        }
        
        let fetchRequest3 = NSFetchRequest(entityName: "TaskContext")
        
        let fetchResults3 = (try? managedObjectContext!.executeFetchRequest(fetchRequest3)) as? [TaskContext]
        
        for myMeeting3 in fetchResults3!
        {
            myMeeting3.updateTime = NSDate()
            myMeeting3.updateType = "Delete"
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

           // managedObjectContext!.deleteObject(myMeeting3 as NSManagedObject)
        }
        
        let fetchRequest4 = NSFetchRequest(entityName: "TaskUpdates")
        
        let fetchResults4 = (try? managedObjectContext!.executeFetchRequest(fetchRequest4)) as? [TaskUpdates]
        
        for myMeeting4 in fetchResults4!
        {
            myMeeting4.updateTime = NSDate()
            myMeeting4.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

//            managedObjectContext!.deleteObject(myMeeting4 as NSManagedObject)
        }
    }

    func getAgendaTasks(inMeetingID: String, inAgendaID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) AND (meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func getMeetingsTasks(inMeetingID: String)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func saveAgendaTask(inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        var myTask: MeetingTasks
        
        myTask = NSEntityDescription.insertNewObjectForEntityForName("MeetingTasks", inManagedObjectContext: managedObjectContext!) as! MeetingTasks
        myTask.agendaID = inAgendaID
        myTask.meetingID = inMeetingID
        myTask.taskID = inTaskID
        myTask.updateTime = NSDate()
        myTask.updateType = "Add"
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func replaceAgendaTask(inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        managedObjectContext!.performBlock
            {
        let myTask = NSEntityDescription.insertNewObjectForEntityForName("MeetingTasks", inManagedObjectContext: self.managedObjectContext!) as! MeetingTasks
        myTask.agendaID = inAgendaID
        myTask.meetingID = inMeetingID
        myTask.taskID = inTaskID
        myTask.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    func checkMeetingTask(meetingID: String, agendaID: Int, taskID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) && (meetingID == \"\(meetingID)\") && (updateType != \"Delete\") && (taskID == \(taskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingTasks]
        
        return fetchResults!
    }

    
    func saveMeetingTask(agendaID: Int, meetingID: String, taskID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myTask: MeetingTasks
        
        let myTaskList = checkMeetingTask(meetingID, agendaID: agendaID, taskID: taskID)
        
        if myTaskList.count == 0
        {
            myTask = NSEntityDescription.insertNewObjectForEntityForName("MeetingTasks", inManagedObjectContext: managedObjectContext!) as! MeetingTasks
            myTask.agendaID = agendaID
            myTask.meetingID = meetingID
            myTask.taskID = taskID
            if inUpdateType == "CODE"
            {
                myTask.updateTime = NSDate()
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
                myTask.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    func replaceMeetingTask(agendaID: Int, meetingID: String, taskID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myTask = NSEntityDescription.insertNewObjectForEntityForName("MeetingTasks", inManagedObjectContext: self.managedObjectContext!) as! MeetingTasks
            myTask.agendaID = agendaID
            myTask.meetingID = meetingID
            myTask.taskID = taskID
            if inUpdateType == "CODE"
            {
                myTask.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func deleteAgendaTask(inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) AND (meetingID == \"\(inMeetingID)\") AND (taskID == \(inTaskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingTasks]
        
        for myItem in fetchResults!
        {
            myItem.updateTime = NSDate()
            myItem.updateType = "Delete"
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        //    managedObjectContext!.deleteObject(myItem as NSManagedObject)
        }
    }
    
    func getAgendaTask(inAgendaID: Int, inMeetingID: String, inTaskID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) && (meetingID == \"\(inMeetingID)\") && (taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func resetContexts()
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
                // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Context]
        
        for myItem in fetchResults!
        {
            myItem.updateTime = NSDate()
            myItem.updateType = "Delete"
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

           // managedObjectContext!.deleteObject(myItem as NSManagedObject)
        }

        let fetchRequest2 = NSFetchRequest(entityName: "TaskContext")
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults2 = (try? managedObjectContext!.executeFetchRequest(fetchRequest2)) as? [TaskContext]
        for myItem2 in fetchResults2!
        {
            myItem2.updateTime = NSDate()
            myItem2.updateType = "Delete"

            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

          //  managedObjectContext!.deleteObject(myItem2 as NSManagedObject)
        }
    }
    
    func clearDeletedItems()
    {
        let predicate = NSPredicate(format: "(updateType == \"Delete\")")

        let fetchRequest2 = NSFetchRequest(entityName: "Context")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? managedObjectContext!.executeFetchRequest(fetchRequest2)) as? [Context]
        
        for myItem2 in fetchResults2!
        {
            managedObjectContext!.deleteObject(myItem2 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest3 = NSFetchRequest(entityName: "Decodes")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults3 = (try? managedObjectContext!.executeFetchRequest(fetchRequest3)) as? [Decodes]
        
        for myItem3 in fetchResults3!
        {
            managedObjectContext!.deleteObject(myItem3 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest5 = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Set the predicate on the fetch request
        fetchRequest5.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults5 = (try? managedObjectContext!.executeFetchRequest(fetchRequest5)) as? [MeetingAgenda]
        
        for myItem5 in fetchResults5!
        {
            managedObjectContext!.deleteObject(myItem5 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest6 = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Set the predicate on the fetch request
        fetchRequest6.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults6 = (try? managedObjectContext!.executeFetchRequest(fetchRequest6)) as? [MeetingAgendaItem]
        
        for myItem6 in fetchResults6!
        {
            managedObjectContext!.deleteObject(myItem6 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest7 = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Set the predicate on the fetch request
        fetchRequest7.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults7 = (try? managedObjectContext!.executeFetchRequest(fetchRequest7)) as? [MeetingAttendees]
        
        for myItem7 in fetchResults7!
        {
            managedObjectContext!.deleteObject(myItem7 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest8 = NSFetchRequest(entityName: "MeetingSupportingDocs")
        
        // Set the predicate on the fetch request
        fetchRequest8.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults8 = (try? managedObjectContext!.executeFetchRequest(fetchRequest8)) as? [MeetingSupportingDocs]
        
        for myItem8 in fetchResults8!
        {
            managedObjectContext!.deleteObject(myItem8 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest9 = NSFetchRequest(entityName: "MeetingTasks")
        
        // Set the predicate on the fetch request
        fetchRequest9.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults9 = (try? managedObjectContext!.executeFetchRequest(fetchRequest9)) as? [MeetingTasks]
        
        for myItem9 in fetchResults9!
        {
            managedObjectContext!.deleteObject(myItem9 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest10 = NSFetchRequest(entityName: "Panes")
        
        // Set the predicate on the fetch request
        fetchRequest10.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults10 = (try? managedObjectContext!.executeFetchRequest(fetchRequest10)) as? [Panes]
        
        for myItem10 in fetchResults10!
        {
            managedObjectContext!.deleteObject(myItem10 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest11 = NSFetchRequest(entityName: "Projects")
        
        // Set the predicate on the fetch request
        fetchRequest11.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults11 = (try? managedObjectContext!.executeFetchRequest(fetchRequest11)) as? [Projects]
        
        for myItem11 in fetchResults11!
        {
            managedObjectContext!.deleteObject(myItem11 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest12 = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Set the predicate on the fetch request
        fetchRequest12.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults12 = (try? managedObjectContext!.executeFetchRequest(fetchRequest12)) as? [ProjectTeamMembers]
        
        for myItem12 in fetchResults12!
        {
            managedObjectContext!.deleteObject(myItem12 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest14 = NSFetchRequest(entityName: "Roles")
        
        // Set the predicate on the fetch request
        fetchRequest14.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults14 = (try? managedObjectContext!.executeFetchRequest(fetchRequest14)) as? [Roles]
        
        for myItem14 in fetchResults14!
        {
            managedObjectContext!.deleteObject(myItem14 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest15 = NSFetchRequest(entityName: "Stages")
        
        // Set the predicate on the fetch request
        fetchRequest15.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults15 = (try? managedObjectContext!.executeFetchRequest(fetchRequest15)) as? [Stages]
        
        for myItem15 in fetchResults15!
        {
            managedObjectContext!.deleteObject(myItem15 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest16 = NSFetchRequest(entityName: "Task")
        
        // Set the predicate on the fetch request
        fetchRequest16.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults16 = (try? managedObjectContext!.executeFetchRequest(fetchRequest16)) as? [Task]
        
        for myItem16 in fetchResults16!
        {
            managedObjectContext!.deleteObject(myItem16 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest17 = NSFetchRequest(entityName: "TaskAttachment")
        
        // Set the predicate on the fetch request
        fetchRequest17.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults17 = (try? managedObjectContext!.executeFetchRequest(fetchRequest17)) as? [TaskAttachment]
        
        for myItem17 in fetchResults17!
        {
            managedObjectContext!.deleteObject(myItem17 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest18 = NSFetchRequest(entityName: "TaskContext")
        
        // Set the predicate on the fetch request
        fetchRequest18.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults18 = (try? managedObjectContext!.executeFetchRequest(fetchRequest18)) as? [TaskContext]
        
        for myItem18 in fetchResults18!
        {
            managedObjectContext!.deleteObject(myItem18 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest19 = NSFetchRequest(entityName: "TaskUpdates")
        
        // Set the predicate on the fetch request
        fetchRequest19.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults19 = (try? managedObjectContext!.executeFetchRequest(fetchRequest19)) as? [TaskUpdates]
        
        for myItem19 in fetchResults19!
        {
            managedObjectContext!.deleteObject(myItem19 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest21 = NSFetchRequest(entityName: "TaskPredecessor")
        
        // Set the predicate on the fetch request
        fetchRequest21.predicate = predicate
        let fetchResults21 = (try? managedObjectContext!.executeFetchRequest(fetchRequest21)) as? [TaskPredecessor]
        
        for myItem21 in fetchResults21!
        {
            managedObjectContext!.deleteObject(myItem21 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest22 = NSFetchRequest(entityName: "Team")
        
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        let fetchResults22 = (try? managedObjectContext!.executeFetchRequest(fetchRequest22)) as? [Team]
        
        for myItem22 in fetchResults22!
        {
            managedObjectContext!.deleteObject(myItem22 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest23 = NSFetchRequest(entityName: "ProjectNote")
        
        // Set the predicate on the fetch request
        fetchRequest23.predicate = predicate
        let fetchResults23 = (try? managedObjectContext!.executeFetchRequest(fetchRequest23)) as? [ProjectNote]
        
        for myItem23 in fetchResults23!
        {
            managedObjectContext!.deleteObject(myItem23 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest24 = NSFetchRequest(entityName: "Context1_1")
        
        // Set the predicate on the fetch request
        fetchRequest24.predicate = predicate
        let fetchResults24 = (try? managedObjectContext!.executeFetchRequest(fetchRequest24)) as? [Context1_1]
        
        for myItem24 in fetchResults24!
        {
            managedObjectContext!.deleteObject(myItem24 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest25 = NSFetchRequest(entityName: "GTDItem")
        
        // Set the predicate on the fetch request
        fetchRequest25.predicate = predicate
        let fetchResults25 = (try? managedObjectContext!.executeFetchRequest(fetchRequest25)) as? [GTDItem]
        
        for myItem25 in fetchResults25!
        {
            managedObjectContext!.deleteObject(myItem25 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest26 = NSFetchRequest(entityName: "GTDLevel")
        
        // Set the predicate on the fetch request
        fetchRequest26.predicate = predicate
        let fetchResults26 = (try? managedObjectContext!.executeFetchRequest(fetchRequest26)) as? [GTDLevel]
        
        for myItem26 in fetchResults26!
        {
            managedObjectContext!.deleteObject(myItem26 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest27 = NSFetchRequest(entityName: "ProcessedEmails")
        
        // Set the predicate on the fetch request
        fetchRequest27.predicate = predicate
        let fetchResults27 = (try? managedObjectContext!.executeFetchRequest(fetchRequest27)) as? [ProcessedEmails]
        
        for myItem27 in fetchResults27!
        {
            managedObjectContext!.deleteObject(myItem27 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        let fetchRequest2 = NSFetchRequest(entityName: "Context")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? managedObjectContext!.executeFetchRequest(fetchRequest2)) as? [Context]
        
        for myItem2 in fetchResults2!
        {
            myItem2.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
        
        let fetchRequest3 = NSFetchRequest(entityName: "Decodes")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults3 = (try? managedObjectContext!.executeFetchRequest(fetchRequest3)) as? [Decodes]
        
        for myItem3 in fetchResults3!
        {
            myItem3.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
        
        let fetchRequest5 = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Set the predicate on the fetch request
        fetchRequest5.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults5 = (try? managedObjectContext!.executeFetchRequest(fetchRequest5)) as? [MeetingAgenda]
        
        for myItem5 in fetchResults5!
        {
            myItem5.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
        
        let fetchRequest6 = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Set the predicate on the fetch request
        fetchRequest6.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults6 = (try? managedObjectContext!.executeFetchRequest(fetchRequest6)) as? [MeetingAgendaItem]
        
        for myItem6 in fetchResults6!
        {
            myItem6.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
       
        let fetchRequest7 = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Set the predicate on the fetch request
        fetchRequest7.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults7 = (try? managedObjectContext!.executeFetchRequest(fetchRequest7)) as? [MeetingAttendees]
        
        for myItem7 in fetchResults7!
        {
            myItem7.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
        
        let fetchRequest8 = NSFetchRequest(entityName: "MeetingSupportingDocs")
        
        // Set the predicate on the fetch request
        fetchRequest8.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults8 = (try? managedObjectContext!.executeFetchRequest(fetchRequest8)) as? [MeetingSupportingDocs]
        
        for myItem8 in fetchResults8!
        {
            myItem8.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
        
        let fetchRequest9 = NSFetchRequest(entityName: "MeetingTasks")
        
        // Set the predicate on the fetch request
        fetchRequest9.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults9 = (try? managedObjectContext!.executeFetchRequest(fetchRequest9)) as? [MeetingTasks]
        
        for myItem9 in fetchResults9!
        {
            myItem9.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
        
        let fetchRequest10 = NSFetchRequest(entityName: "Panes")
        
        // Set the predicate on the fetch request
        fetchRequest10.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults10 = (try? managedObjectContext!.executeFetchRequest(fetchRequest10)) as? [Panes]
        
        for myItem10 in fetchResults10!
        {
            myItem10.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest11 = NSFetchRequest(entityName: "Projects")
        
        // Set the predicate on the fetch request
        fetchRequest11.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults11 = (try? managedObjectContext!.executeFetchRequest(fetchRequest11)) as? [Projects]
        
        for myItem11 in fetchResults11!
        {
            myItem11.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
        
        let fetchRequest12 = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Set the predicate on the fetch request
        fetchRequest12.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults12 = (try? managedObjectContext!.executeFetchRequest(fetchRequest12)) as? [ProjectTeamMembers]
        
        for myItem12 in fetchResults12!
        {
            myItem12.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest14 = NSFetchRequest(entityName: "Roles")
        
        // Set the predicate on the fetch request
        fetchRequest14.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults14 = (try? managedObjectContext!.executeFetchRequest(fetchRequest14)) as? [Roles]
        
        for myItem14 in fetchResults14!
        {
            myItem14.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest15 = NSFetchRequest(entityName: "Stages")
        
        // Set the predicate on the fetch request
        fetchRequest15.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults15 = (try? managedObjectContext!.executeFetchRequest(fetchRequest15)) as? [Stages]
        
        for myItem15 in fetchResults15!
        {
            myItem15.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }

        }
        
        let fetchRequest16 = NSFetchRequest(entityName: "Task")
        
        // Set the predicate on the fetch request
        fetchRequest16.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults16 = (try? managedObjectContext!.executeFetchRequest(fetchRequest16)) as? [Task]
        
        for myItem16 in fetchResults16!
        {
            myItem16.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest17 = NSFetchRequest(entityName: "TaskAttachment")
        
        // Set the predicate on the fetch request
        fetchRequest17.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults17 = (try? managedObjectContext!.executeFetchRequest(fetchRequest17)) as? [TaskAttachment]
        
        for myItem17 in fetchResults17!
        {
            myItem17.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest18 = NSFetchRequest(entityName: "TaskContext")
        
        // Set the predicate on the fetch request
        fetchRequest18.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults18 = (try? managedObjectContext!.executeFetchRequest(fetchRequest18)) as? [TaskContext]
        
        for myItem18 in fetchResults18!
        {
            myItem18.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest19 = NSFetchRequest(entityName: "TaskUpdates")
        
        // Set the predicate on the fetch request
        fetchRequest19.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults19 = (try? managedObjectContext!.executeFetchRequest(fetchRequest19)) as? [TaskUpdates]
        
        for myItem19 in fetchResults19!
        {
            myItem19.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest21 = NSFetchRequest(entityName: "TaskPredecessor")
        
        // Set the predicate on the fetch request
        fetchRequest21.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults21 = (try? managedObjectContext!.executeFetchRequest(fetchRequest21)) as? [TaskPredecessor]
        
        for myItem21 in fetchResults21!
        {
            myItem21.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest22 = NSFetchRequest(entityName: "Team")
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults22 = (try? managedObjectContext!.executeFetchRequest(fetchRequest22)) as? [Team]
        
        for myItem22 in fetchResults22!
        {
            myItem22.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }

        let fetchRequest23 = NSFetchRequest(entityName: "ProjectNote")
        // Set the predicate on the fetch request
        fetchRequest23.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults23 = (try? managedObjectContext!.executeFetchRequest(fetchRequest23)) as? [ProjectNote]
        
        for myItem23 in fetchResults23!
        {
            myItem23.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest24 = NSFetchRequest(entityName: "Context1_1")
        // Set the predicate on the fetch request
        fetchRequest24.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults24 = (try? managedObjectContext!.executeFetchRequest(fetchRequest24)) as? [Context1_1]
        
        for myItem24 in fetchResults24!
        {
            myItem24.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest25 = NSFetchRequest(entityName: "GTDItem")
        // Set the predicate on the fetch request
        fetchRequest25.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults25 = (try? managedObjectContext!.executeFetchRequest(fetchRequest25)) as? [GTDItem]
        
        for myItem25 in fetchResults25!
        {
            myItem25.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }

        let fetchRequest26 = NSFetchRequest(entityName: "GTDLevel")
        // Set the predicate on the fetch request
        fetchRequest26.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults26 = (try? managedObjectContext!.executeFetchRequest(fetchRequest26)) as? [GTDLevel]
        
        for myItem26 in fetchResults26!
        {
            myItem26.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        let fetchRequest27 = NSFetchRequest(entityName: "ProcessedEmails")
        // Set the predicate on the fetch request
        fetchRequest27.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults27 = (try? managedObjectContext!.executeFetchRequest(fetchRequest27)) as? [ProcessedEmails]
        
        for myItem27 in fetchResults27!
        {
            myItem27.updateType = ""
            
            managedObjectContext!.performBlockAndWait
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
    
    func saveTeam(inTeamID: Int, inName: String, inStatus: String, inNote: String, inType: String, inPredecessor: Int, inExternalID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myTeam: Team!
        
        let myTeams = getTeam(inTeamID)
        
        if myTeams.count == 0
        { // Add
            myTeam = NSEntityDescription.insertNewObjectForEntityForName("Team", inManagedObjectContext: self.managedObjectContext!) as! Team
            myTeam.teamID = inTeamID
            myTeam.name = inName
            myTeam.status = inStatus
            myTeam.note = inNote
            myTeam.type = inType
            myTeam.predecessor = inPredecessor
            myTeam.externalID = inExternalID
            if inUpdateType == "CODE"
            {
                myTeam.updateTime = NSDate()
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
            myTeam.predecessor = inPredecessor
            myTeam.externalID = inExternalID
            if inUpdateType == "CODE"
            {
                if myTeam.updateType != "Add"
                {
                    myTeam.updateType = "Update"
                }
                myTeam.updateTime = NSDate()
            }
            else
            {
                myTeam.updateTime = inUpdateTime
                myTeam.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func replaceTeam(inTeamID: Int, inName: String, inStatus: String, inNote: String, inType: String, inPredecessor: Int, inExternalID: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myTeam = NSEntityDescription.insertNewObjectForEntityForName("Team", inManagedObjectContext: self.managedObjectContext!) as! Team
            myTeam.teamID = inTeamID
            myTeam.name = inName
            myTeam.status = inStatus
            myTeam.note = inNote
            myTeam.type = inType
            myTeam.predecessor = inPredecessor
            myTeam.externalID = inExternalID
            if inUpdateType == "CODE"
            {
                myTeam.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    
    func getTeam(inTeamID: Int)->[Team]
    {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Team]
        
        return fetchResults!
    }
    
    func getAllTeams()->[Team]
    {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Team]
    
        return fetchResults!
    }
    
    func getMyTeams(myID: String)->[Team]
    {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Team]
        
        return fetchResults!
    }
    
    func getTeamsCount() -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        fetchRequest.shouldRefreshRefetchedObjects = true
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Team]
        
        return fetchResults!.count
    }
    
    func deleteAllTeams()
    {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Team]
        
        for myItem in fetchResults!
        {
            managedObjectContext!.deleteObject(myItem as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

        let fetchRequest2 = NSFetchRequest(entityName: "GTDLevel")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? managedObjectContext!.executeFetchRequest(fetchRequest2)) as? [GTDLevel]
        
        for myItem2 in fetchResults2!
        {
            managedObjectContext!.deleteObject(myItem2 as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func saveProjectNote(inProjectID: Int, inNote: String, inReviewPeriod: String, inPredecessor: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myProjectNote: ProjectNote!
        
        let myTeams = getProjectNote(inProjectID)
        
        if myTeams.count == 0
        { // Add
            myProjectNote = NSEntityDescription.insertNewObjectForEntityForName("ProjectNote", inManagedObjectContext: self.managedObjectContext!) as! ProjectNote
            myProjectNote.projectID = inProjectID
            myProjectNote.note = inNote

            myProjectNote.reviewPeriod = inReviewPeriod
            myProjectNote.predecessor = inPredecessor
            if inUpdateType == "CODE"
            {
                myProjectNote.updateTime = NSDate()
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
            myProjectNote.predecessor = inPredecessor
            if inUpdateType == "CODE"
            {
                if myProjectNote.updateType != "Add"
                {
                    myProjectNote.updateType = "Update"
                }
                myProjectNote.updateTime = NSDate()
            }
            else
            {
                myProjectNote.updateTime = inUpdateTime
                myProjectNote.updateType = inUpdateType
            }
        }
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
 
    func replaceProjectNote(inProjectID: Int, inNote: String, inReviewPeriod: String, inPredecessor: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myProjectNote = NSEntityDescription.insertNewObjectForEntityForName("ProjectNote", inManagedObjectContext: self.managedObjectContext!) as! ProjectNote
            myProjectNote.projectID = inProjectID
            myProjectNote.note = inNote
            
            myProjectNote.reviewPeriod = inReviewPeriod
            myProjectNote.predecessor = inPredecessor
            if inUpdateType == "CODE"
            {
                myProjectNote.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    
    func getProjectNote(inProjectID: Int)->[ProjectNote]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectNote")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (projectID == \(inProjectID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProjectNote]
        
        return fetchResults!
    }

    func getNextID(inTableName: String, inInitialValue: Int = 1) -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
        let predicate = NSPredicate(format: "(decode_name == \"\(inTableName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Decodes]
        
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
    
    func initialiseTeamForMeetingAgenda(inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
            }
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
    }

    func initialiseTeamForContext(inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        let sortDescriptor = NSSortDescriptor(key: "contextID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Context]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
                maxID = myItem.contextID as Int
            }
        
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Context", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func initialiseTeamForProject(inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        let sortDescriptor = NSSortDescriptor(key: "projectID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Projects]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
                maxID = myItem.projectID as Int
            }
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Projects", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func initialiseTeamForRoles(inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        
        let sortDescriptor = NSSortDescriptor(key: "roleID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Roles]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
                maxID = myItem.roleID as Int
            }
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Roles", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func initialiseTeamForStages(inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Stages]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
            }
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
    }

    func initialiseTeamForTask(inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        let sortDescriptor = NSSortDescriptor(key: "taskID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        
        if fetchResults!.count > 0
        {
            for myItem in fetchResults!
            {
                myItem.teamID = inTeamID
                maxID = myItem.taskID as Int
            }
            
            managedObjectContext!.performBlockAndWait
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
            
            //       do
            //       {
            //            try managedObjectContext!.save()
            //        }
            //        catch let error as NSError
            //        {
            //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            //            print("Failure to save context: \(error)")
            //       }
        }
        
        // Now go and populate the Decode for this
        
        let tempInt = "\(maxID)"
        updateDecodeValue("Task", inCodeValue: tempInt, inCodeType: "hidden")
    }

    func saveContext1_1(inContextID: Int, inPredecessor: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        var myContext: Context1_1!
        
        let myContexts = getContext1_1(inContextID)
        
        if myContexts.count == 0
        { // Add
            myContext = NSEntityDescription.insertNewObjectForEntityForName("Context1_1", inManagedObjectContext: self.managedObjectContext!) as! Context1_1
            myContext.contextID = inContextID
            myContext.predecessor = inPredecessor
            if inUpdateType == "CODE"
            {
                myContext.updateTime = NSDate()
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
            myContext.predecessor = inPredecessor
            if inUpdateType == "CODE"
            {
                myContext.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    func replaceContext1_1(inContextID: Int, inPredecessor: Int, inUpdateTime: NSDate = NSDate(), inUpdateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myContext = NSEntityDescription.insertNewObjectForEntityForName("Context1_1", inManagedObjectContext: self.managedObjectContext!) as! Context1_1
        myContext.contextID = inContextID
        myContext.predecessor = inPredecessor
        if inUpdateType == "CODE"
        {
            myContext.updateTime = NSDate()
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }

    
    func getContext1_1(inContextID: Int)->[Context1_1]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context1_1")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (contextID == \(inContextID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "contextID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Context1_1]
        
        return fetchResults!
    }
    
    func resetDecodes()
    {
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(decodeType != \"hidden\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Decodes]
        
        for myItem in fetchResults!
        {
            managedObjectContext!.deleteObject(myItem as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
    }
    
    
    func performTidyDecodes(inString: String)
    {
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: inString)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Decodes]
        
        for myItem in fetchResults!
        {
            managedObjectContext!.deleteObject(myItem as NSManagedObject)
        }
        
        managedObjectContext!.performBlockAndWait
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }

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
    }
    
    func getContextsForSync(inLastSyncDate: NSDate) -> [Context]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Context]
        
        return fetchResults!
    }

    func getContexts1_1ForSync(inLastSyncDate: NSDate) -> [Context1_1]
    {
        let fetchRequest = NSFetchRequest(entityName: "Context1_1")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Context1_1]
        
        return fetchResults!
    }

    func getDecodesForSync(inLastSyncDate: NSDate) -> [Decodes]
    {
        let fetchRequest = NSFetchRequest(entityName: "Decodes")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Decodes]
        
        return fetchResults!
    }

    func getGTDItemsForSync(inLastSyncDate: NSDate) -> [GTDItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "GTDItem")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDItem]
        
        return fetchResults!
    }
    
    func getGTDLevelsForSync(inLastSyncDate: NSDate) -> [GTDLevel]
    {
        let fetchRequest = NSFetchRequest(entityName: "GTDLevel")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [GTDLevel]
        
        return fetchResults!
    }
    
    func getMeetingAgendasForSync(inLastSyncDate: NSDate) -> [MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgenda")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgenda]
        
        return fetchResults!
    }
    
    func getMeetingAgendaItemsForSync(inLastSyncDate: NSDate) -> [MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAgendaItem]
        
        return fetchResults!
    }
    
    func getMeetingAttendeesForSync(inLastSyncDate: NSDate) -> [MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingAttendees")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingAttendees]
        
        return fetchResults!
    }
    
    func getMeetingSupportingDocsForSync(inLastSyncDate: NSDate) -> [MeetingSupportingDocs]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingSupportingDocs")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingSupportingDocs]
        
        return fetchResults!
    }
    
    func getMeetingTasksForSync(inLastSyncDate: NSDate) -> [MeetingTasks]
    {
        let fetchRequest = NSFetchRequest(entityName: "MeetingTasks")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MeetingTasks]
        
        return fetchResults!
    }
    
    func getPanesForSync(inLastSyncDate: NSDate) -> [Panes]
    {
        let fetchRequest = NSFetchRequest(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Panes]
        
        return fetchResults!
    }
    
    func getProjectsForSync(inLastSyncDate: NSDate) -> [Projects]
    {
        let fetchRequest = NSFetchRequest(entityName: "Projects")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Projects]
        
        return fetchResults!
    }
    
    func getProjectNotesForSync(inLastSyncDate: NSDate) -> [ProjectNote]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectNote")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProjectNote]
        
        return fetchResults!
    }
    
    func getProjectTeamMembersForSync(inLastSyncDate: NSDate) -> [ProjectTeamMembers]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProjectTeamMembers]
        
        return fetchResults!
    }

    func getRolesForSync(inLastSyncDate: NSDate) -> [Roles]
    {
        let fetchRequest = NSFetchRequest(entityName: "Roles")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Roles]
        
        return fetchResults!
    }
    
    func getStagesForSync(inLastSyncDate: NSDate) -> [Stages]
    {
        let fetchRequest = NSFetchRequest(entityName: "Stages")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Stages]
        
        return fetchResults!
    }

    func getTaskForSync(inLastSyncDate: NSDate) -> [Task]
    {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Task]
        
        return fetchResults!
    }

    func getTaskAttachmentsForSync(inLastSyncDate: NSDate) -> [TaskAttachment]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskAttachment")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskAttachment]
        
        return fetchResults!
    }
    
    func getTaskContextsForSync(inLastSyncDate: NSDate) -> [TaskContext]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskContext")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskContext]
        
        return fetchResults!
    }
    
    func getTaskPredecessorsForSync(inLastSyncDate: NSDate) -> [TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskPredecessor]
        
        return fetchResults!
    }
    
    func getTaskUpdatesForSync(inLastSyncDate: NSDate) -> [TaskUpdates]
    {
        let fetchRequest = NSFetchRequest(entityName: "TaskUpdates")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [TaskUpdates]
        
        return fetchResults!
    }
    
    func getTeamsForSync(inLastSyncDate: NSDate) -> [Team]
    {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Team]
        
        return fetchResults!
    }
    
    func getProcessedEmailsForSync(inLastSyncDate: NSDate) -> [ProcessedEmails]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProcessedEmails")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", inLastSyncDate)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProcessedEmails]
        
        return fetchResults!
    }
    
    func deleteAllCoreData()
    {
        let fetchRequest2 = NSFetchRequest(entityName: "Context")
        managedObjectContext!.performBlockAndWait
            {
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults2 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest2)) as? [Context]
 

        for myItem2 in fetchResults2!
        {
            self.managedObjectContext!.deleteObject(myItem2 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest3 = NSFetchRequest(entityName: "Decodes")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                
                let fetchResults3 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest3)) as? [Decodes]

        for myItem3 in fetchResults3!
        {
            self.managedObjectContext!.deleteObject(myItem3 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest5 = NSFetchRequest(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                
                let fetchResults5 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest5)) as? [MeetingAgenda]

        for myItem5 in fetchResults5!
        {
            self.managedObjectContext!.deleteObject(myItem5 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest6 = NSFetchRequest(entityName: "MeetingAgendaItem")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                
                let fetchResults6 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest6)) as? [MeetingAgendaItem]

        for myItem6 in fetchResults6!
        {
            self.managedObjectContext!.deleteObject(myItem6 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest7 = NSFetchRequest(entityName: "MeetingAttendees")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                
                let fetchResults7 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest7)) as? [MeetingAttendees]

        for myItem7 in fetchResults7!
        {
            self.managedObjectContext!.deleteObject(myItem7 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest8 = NSFetchRequest(entityName: "MeetingSupportingDocs")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults8 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest8)) as? [MeetingSupportingDocs]

                
                for myItem8 in fetchResults8!
        {
            self.managedObjectContext!.deleteObject(myItem8 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest9 = NSFetchRequest(entityName: "MeetingTasks")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                
                let fetchResults9 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest9)) as? [MeetingTasks]

        for myItem9 in fetchResults9!
        {
            self.managedObjectContext!.deleteObject(myItem9 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest10 = NSFetchRequest(entityName: "Panes")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {

                let fetchResults10 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest10)) as? [Panes]

            for myItem10 in fetchResults10!
        {
            self.managedObjectContext!.deleteObject(myItem10 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest11 = NSFetchRequest(entityName: "Projects")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults11 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest11)) as? [Projects]

        for myItem11 in fetchResults11!
        {
            self.managedObjectContext!.deleteObject(myItem11 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest12 = NSFetchRequest(entityName: "ProjectTeamMembers")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults12 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest12)) as? [ProjectTeamMembers]

        for myItem12 in fetchResults12!
        {
            self.managedObjectContext!.deleteObject(myItem12 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest14 = NSFetchRequest(entityName: "Roles")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        
        managedObjectContext!.performBlockAndWait
        {
            let fetchResults14 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest14)) as? [Roles]

            for myItem14 in fetchResults14!
            {
                self.managedObjectContext!.deleteObject(myItem14 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest15 = NSFetchRequest(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults15 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest15)) as? [Stages]

        for myItem15 in fetchResults15!
        {
            self.managedObjectContext!.deleteObject(myItem15 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest16 = NSFetchRequest(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults16 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest16)) as? [Task]

        for myItem16 in fetchResults16!
        {
            self.managedObjectContext!.deleteObject(myItem16 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest17 = NSFetchRequest(entityName: "TaskAttachment")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults17 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest17)) as? [TaskAttachment]

        for myItem17 in fetchResults17!
        {
            self.managedObjectContext!.deleteObject(myItem17 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest18 = NSFetchRequest(entityName: "TaskContext")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults18 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest18)) as? [TaskContext]

        for myItem18 in fetchResults18!
        {
            self.managedObjectContext!.deleteObject(myItem18 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest19 = NSFetchRequest(entityName: "TaskUpdates")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults19 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest19)) as? [TaskUpdates]

        for myItem19 in fetchResults19!
        {
            self.managedObjectContext!.deleteObject(myItem19 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest21 = NSFetchRequest(entityName: "TaskPredecessor")
        
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults21 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest21)) as? [TaskPredecessor]

        for myItem21 in fetchResults21!
        {
            self.managedObjectContext!.deleteObject(myItem21 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest22 = NSFetchRequest(entityName: "Team")
        
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults22 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest22)) as? [Team]

        for myItem22 in fetchResults22!
        {
            self.managedObjectContext!.deleteObject(myItem22 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest23 = NSFetchRequest(entityName: "ProjectNote")
        
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults23 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest23)) as? [ProjectNote]

        for myItem23 in fetchResults23!
        {
            self.managedObjectContext!.deleteObject(myItem23 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest24 = NSFetchRequest(entityName: "Context1_1")
        
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults24 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest24)) as? [Context1_1]
                
        for myItem24 in fetchResults24!
        {
            self.managedObjectContext!.deleteObject(myItem24 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest25 = NSFetchRequest(entityName: "GTDItem")
        
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults25 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest25)) as? [GTDItem]

        for myItem25 in fetchResults25!
        {
            self.managedObjectContext!.deleteObject(myItem25 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest26 = NSFetchRequest(entityName: "GTDLevel")
        
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults26 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest26)) as? [GTDLevel]

        for myItem26 in fetchResults26!
        {
            self.managedObjectContext!.deleteObject(myItem26 as NSManagedObject)
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
        
        //       do
        //       {
        //            try managedObjectContext!.save()
        //        }
        //        catch let error as NSError
        //        {
        //            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        //            print("Failure to save context: \(error)")
        //       }
        
        let fetchRequest27 = NSFetchRequest(entityName: "ProcessedEmails")
        
        managedObjectContext!.performBlockAndWait
            {
                let fetchResults27 = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest27)) as? [ProcessedEmails]
                
                for myItem27 in fetchResults27!
                {
                    self.managedObjectContext!.deleteObject(myItem27 as NSManagedObject)
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

    func saveProcessedEmail(emailID: String, emailType: String, processedDate: NSDate, updateTime: NSDate = NSDate(), updateType: String = "CODE")
    {
        var myEmail: ProcessedEmails!
        
        let myEmailItems = getProcessedEmail(emailID)
        
        if myEmailItems.count == 0
        { // Add
            myEmail = NSEntityDescription.insertNewObjectForEntityForName("ProcessedEmails", inManagedObjectContext: self.managedObjectContext!) as! ProcessedEmails
            myEmail.emailID = emailID
            myEmail.emailType = emailType
            myEmail.processedDate = processedDate

            if updateType == "CODE"
            {
                myEmail.updateTime = NSDate()
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
        
        managedObjectContext!.performBlock
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
    
    func replaceProcessedEmail(emailID: String, emailType: String, processedDate: NSDate, updateTime: NSDate = NSDate(), updateType: String = "CODE")
    {
        managedObjectContext!.performBlock
            {
        let myEmail = NSEntityDescription.insertNewObjectForEntityForName("ProcessedEmails", inManagedObjectContext: self.managedObjectContext!) as! ProcessedEmails
        myEmail.emailID = emailID
        myEmail.emailType = emailType
        myEmail.processedDate = processedDate
        
        if updateType == "CODE"
        {
            myEmail.updateTime = NSDate()
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
    
    func deleteProcessedEmail(emailID: String)
    {
        var myEmail: ProcessedEmails!
        
        let myEmailItems = getProcessedEmail(emailID)
        
        if myEmailItems.count > 0
        { // Update
            myEmail = myEmailItems[0]
            myEmail.updateTime = NSDate()
            myEmail.updateType = "Delete"
        }
        
        managedObjectContext!.performBlockAndWait
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
    
    func getProcessedEmail(emailID: String)->[ProcessedEmails]
    {
        let fetchRequest = NSFetchRequest(entityName: "ProcessedEmails")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(emailID == \"\(emailID)\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [ProcessedEmails]
        
        return fetchResults!
    }

}
