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
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "EvesCRM")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var objectContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    override init()
    {
        super.init()
        objectContext = persistentContainer.viewContext
    }
    
    func saveContext()
    {
        if objectContext.hasChanges
        {
            do
            {
                try objectContext.save()
            }
            catch
            {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func refreshObject(_ objectID: NSManagedObject)
    {
        objectContext.refresh(objectID, mergeChanges: true)
    }
    
    func getOpenProjectsForGTDItem(_ inGTDItemID: Int, inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectStatus != \"Archived\") && (projectStatus != \"Completed\") && (projectStatus != \"Deleted\") && (areaID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        let sortDescriptor = NSSortDescriptor(key: "projectID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
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
            print("Error ocurred during execution: \(error)")
            return []
        }
    }

    func getProjectDetails(_ projectID: Int)->[Projects]
    {
        
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
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
    
    func getProjectSuccessor(_ projectID: Int)->Int
    {
        
        let fetchRequest = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(predecessor == \(projectID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults[0].projectID as Int
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }

    func getGTDItemSuccessor(_ projectID: Int)->Int
    {
        
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(predecessor == \(projectID)) && (updateType != \"Delete\") && (status != \"Closed\") && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults[0].gTDItemID as! Int
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
  
    func getAllProjects(_ inTeamID: Int)->[Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Execute the fetch request, and cast the results to an array of objects
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
    
    func getProjectCount()->Int
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults.count
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
    
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
                
                saveContext()
                myCloudDB.saveRolesRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
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
                retVal = myItem.roleID as Int
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        return retVal + 1
    }
    
    func saveRole(_ roleName: String, teamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE", roleID: Int = 0)
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

    func replaceRole(_ roleName: String, teamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE", roleID: Int = 0)
    {
        let mySelectedRole = Roles(context: objectContext)
                    
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
                myStage.updateTime = Date()
                myStage.updateType = "Delete"
                
                saveContext()
                
                myCloudDB.saveRolesRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func saveTeamMember(_ inProjectID: Int, inRoleID: Int, inPersonName: String, inNotes: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
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
        
        saveContext()
    }

    func replaceTeamMember(_ inProjectID: Int, inRoleID: Int, inPersonName: String, inNotes: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myProjectTeam = ProjectTeamMembers(context: objectContext)
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
                myStage.updateTime = Date()
                myStage.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
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
    
    func getProjects(_ inTeamID: Int, inArchiveFlag: Bool = false) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
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
    
    func getDecodeValue(_ inCodeKey: String) -> String
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
   //     let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\") && (updateType != \"Delete\")")
        let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\")")
        
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
                return fetchResults[0].decode_value
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return ""
        }
    }
    
    func getVisibleDecodes() -> [Decodes]
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        let predicate = NSPredicate(format: "(decodeType != \"hidden\") && (updateType != \"Delete\")")
        
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
    
    func updateDecodeValue(_ inCodeKey: String, inCodeValue: String, inCodeType: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        // first check to see if decode exists, if not we create
        var myDecode: Decodes!

        if getDecodeValue(inCodeKey) == ""
        { // Add
            myDecode = Decodes(context: objectContext)
            
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
            let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
            let predicate = NSPredicate(format: "(decode_name == \"\(inCodeKey)\") && (updateType != \"Delete\")")
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
            
            // Execute the fetch request, and cast the results to an array of  objects
            do
            {
                let myDecodes = try objectContext.fetch(fetchRequest)
                myDecode = myDecodes[0]
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
                saveContext()
                myCloudDB.saveDecodesRecordToCloudKit(myDecode, syncName: myDBSync.getSyncID())
            }
            catch
            {
                print("Error occurred during execution: \(error)")
            }
        }
    }
    
    func replaceDecodeValue(_ inCodeKey: String, inCodeValue: String, inCodeType: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myDecode = Decodes(context: objectContext)
            
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

        saveContext()
    }
    
    func getStages(_ inTeamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
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
    
    func getVisibleStages(_ inTeamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
    
        let predicate = NSPredicate(format: "(stageDescription != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
    
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
    
    func deleteAllStages(_ inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
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
                
                saveContext()
                
                myCloudDB.saveStagesRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func stageExists(_ inStageDesc:String, inTeamID: Int)-> Bool
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(stageDescription == \"\(inStageDesc)\") && (teamID == \(inTeamID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Create a new fetch request using the entity
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            {
                return true
            }
            else
            {
                return false
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return false
        }
    }
    
    func getStage(_ stageDesc:String, teamID: Int)->[Stages]
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (stageDescription == \"\(stageDesc)\")")
        
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
    
    func saveStage(_ stageDesc: String, teamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myStage: Stages!
        
        let myStages = getStage(stageDesc, teamID: teamID)
        
        if myStages.count == 0
        {
            myStage = Stages(context: objectContext)
        
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
        
        saveContext()
        
        myCloudDB.saveStagesRecordToCloudKit(myStage)
    }
    
    func replaceStage(_ stageDesc: String, teamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myStage = Stages(context: objectContext)
            
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

        saveContext()
    }
    
    func deleteStageEntry(_ inStageDesc: String, inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
        let predicate = NSPredicate(format: "(stageDescription == \"\(inStageDesc)\") && (teamID == \(inTeamID)) && (updateType != \"Delete\")")
        
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
                saveContext()
                
                myCloudDB.saveStagesRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func searchPastAgendaByPartialMeetingIDBeforeStart(_ inSearchText: String, inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
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
    
    func searchPastAgendaWithoutPartialMeetingIDBeforeStart(_ inSearchText: String, inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
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

    func listAgendaReverseDateBeforeStart(_ inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
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
    
    func searchPastAgendaByPartialMeetingIDAfterStart(_ inSearchText: String, inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
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
    
    func searchPastAgendaWithoutPartialMeetingIDAfterStart(_ inSearchText: String, inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
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
    
    func listAgendaReverseDateAfterStart(_ inMeetingStartDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
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
            myAgenda = MeetingAgenda(context: objectContext)
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
        
        saveContext()
    }

    func replaceAgenda(_ inMeetingID: String, inPreviousMeetingID : String, inName: String, inChair: String, inMinutes: String, inLocation: String, inStartTime: Date, inEndTime: Date, inMinutesType: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myAgenda = MeetingAgenda(context: objectContext)
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
        
        saveContext()
    }
    
    func loadPreviousAgenda(_ inMeetingID: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(previousMeetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")

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
    
    func loadAgenda(_ inMeetingID: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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

    func updatePreviousAgendaID(_ inPreviousMeetingID: String, inMeetingID: String, inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myResult in fetchResults
            {
                myResult.previousMeetingID = inPreviousMeetingID
                myResult.updateTime = Date()
                if myResult.updateType != "Add"
                {
                    myResult.updateType = "Update"
                }
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func loadAgendaForProject(_ inProjectName: String, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name contains \"\(inProjectName)\") && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
   
    func getAgendaForDateRange(_ inStartDate: Date, inEndDate: Date, inTeamID: Int)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime >= %@) && (endTime <= %@) && (updateType != \"Delete\") && (teamID == \(inTeamID))", inStartDate as CVarArg, inEndDate as CVarArg)
        
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
    
    func loadAttendees(_ inMeetingID: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
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
    
    func loadMeetingsForAttendee(_ inAttendeeName: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name == \"\(inAttendeeName)\") && (updateType != \"Delete\")")
        
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

    func checkMeetingsForAttendee(_ attendeeName: String, meetingID: String)->[MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name == \"\(attendeeName)\") && (updateType != \"Delete\") && (meetingID == \"\(meetingID)\")")
        
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

    func saveAttendee(_ meetingID: String, name: String, email: String,  type: String, status: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myPerson: MeetingAttendees!
        
        let myMeeting = checkMeetingsForAttendee(name, meetingID: meetingID)
        
        if myMeeting.count == 0
        {
            myPerson = MeetingAttendees(context: objectContext)
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
            
        saveContext()
    }

    func replaceAttendee(_ meetingID: String, name: String, email: String,  type: String, status: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myPerson = MeetingAttendees(context: objectContext)
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
        
        saveContext()
    }

    func deleteAttendee(_ meetingID: String, name: String)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") && (name == \"\(name)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myMeeting in fetchResults
            {
                myMeeting.updateTime = Date()
                myMeeting.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func loadAgendaItem(_ inMeetingID: String)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
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
    
    func saveAgendaItem(_ meetingID: String, actualEndTime: Date, actualStartTime: Date, status: String, decisionMade: String, discussionNotes: String, timeAllocation: Int, owner: String, title: String, agendaID: Int, meetingOrder: Int,  inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var mySavedItem: MeetingAgendaItem
        
        let myAgendaItem = loadSpecificAgendaItem(meetingID,inAgendaID: agendaID)
        
        if myAgendaItem.count == 0
        {
            mySavedItem = MeetingAgendaItem(context: objectContext)
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
        
        saveContext()
    }
    
    func replaceAgendaItem(_ meetingID: String, actualEndTime: Date, actualStartTime: Date, status: String, decisionMade: String, discussionNotes: String, timeAllocation: Int, owner: String, title: String, agendaID: Int, meetingOrder: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let mySavedItem = MeetingAgendaItem(context: objectContext)
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

        saveContext()
    }
    
    func loadSpecificAgendaItem(_ inMeetingID: String, inAgendaID: Int)->[MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
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
    
    func deleteAgendaItem(_ meetingID: String, agendaID: Int)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") AND (agendaID == \(agendaID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myMeeting in fetchResults
            {
                myMeeting.updateTime = Date()
                myMeeting.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func deleteAllAgendaItems(_ inMeetingID: String)
    {
        var predicate: NSPredicate
        
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        predicate = NSPredicate(format: "meetingID == \"\(inMeetingID)\"")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myMeeting in fetchResults
            {
                myMeeting.updateTime = Date()
                myMeeting.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func saveTask(_ inTaskID: Int, inTitle: String, inDetails: String, inDueDate: Date, inStartDate: Date, inStatus: String, inPriority: String, inEnergyLevel: String, inEstimatedTime: Int, inEstimatedTimeType: String, inProjectID: Int, inCompletionDate: Date, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inFlagged: Bool, inUrgency: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myTask: Task!
        
        let myTasks = getTask(inTaskID)
        
        if myTasks.count == 0
        { // Add
            myTask = Task(context: objectContext)
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
        
        saveContext()
    }
    
    func replaceTask(_ inTaskID: Int, inTitle: String, inDetails: String, inDueDate: Date, inStartDate: Date, inStatus: String, inPriority: String, inEnergyLevel: String, inEstimatedTime: Int, inEstimatedTimeType: String, inProjectID: Int, inCompletionDate: Date, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inFlagged: Bool, inUrgency: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myTask = Task(context: objectContext)
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

        saveContext()
    }
    
    func deleteTask(_ inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        let predicate = NSPredicate(format: "taskID == \(inTaskID)")
        
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
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

    }
    
    func getTasksNotDeleted(_ inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "taskID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

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

    func getAllTasksForProject(_ inProjectID: Int, inTeamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(inProjectID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
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
    
    func getTasksForProject(_ projectID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID = \(projectID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\")")
        
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
    
    func getActiveTasksForProject(_ projectID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
       let predicate = NSPredicate(format: "(projectID = \(projectID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\") && (status != \"Pause\") && ((startDate == %@) || (startDate <= %@))", getDefaultDate() as CVarArg, Date() as CVarArg)
        
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

    func getTasksWithoutProject(_ teamID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == 0) && (updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\") && (status != \"Complete\")")
        
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
    
    func getTaskWithoutContext(_ teamID: Int)->[Task]
    {
        // first get a list of all tasks that have a context
        
        let fetchContext = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate1 = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchContext.predicate = predicate1

        // Execute the fetch request, and cast the results to an array of LogItem objects
        
        var fetchContextResults: [TaskContext] = Array()
        
        do
        {
            fetchContextResults = try objectContext.fetch(fetchContext)
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        // Get the list of all current tasks
        let fetchTask = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate2 = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && (status != \"Deleted\") && (status != \"Complete\")")
        
        // Set the predicate on the fetch request
        fetchTask.predicate = predicate2
        
        var fetchTaskResults: [Task] = Array()
        
        do
        {
            fetchTaskResults = try objectContext.fetch(fetchTask)
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        // Execute the fetch request, and cast the results to an array of LogItem objects

        var myTaskArray: [Task] = Array()
        var taskFound: Bool = false
        
        for myTask in fetchTaskResults
        {
            // loop though the context tasks
            taskFound = false
            for myContext in fetchContextResults
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
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (status != \"Deleted\")")
        
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
    
    func getTaskRegardlessOfStatus(_ taskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID))")
        
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
    
    func getActiveTask(_ taskID: Int)->[Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (status != \"Deleted\") && (status != \"Complete\") && ((startDate == %@) || (startDate <= %@))", getDefaultDate() as CVarArg, Date() as CVarArg)
        
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

    func getTaskCount()->Int
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults.count
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
    
    func getTaskPredecessors(_ inTaskID: Int)->[TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
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
   
    func savePredecessorTask(_ inTaskID: Int, inPredecessorID: Int, inPredecessorType: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myTask: TaskPredecessor!
        
        let myTasks = getTaskPredecessors(inTaskID)
        
        if myTasks.count == 0
        { // Add
            myTask = TaskPredecessor(context: objectContext)
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

        saveContext()
        
        myCloudDB.saveTaskPredecessorRecordToCloudKit(myTask)
    }
    
    func replacePredecessorTask(_ inTaskID: Int, inPredecessorID: Int, inPredecessorType: String, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myTask = TaskPredecessor(context: objectContext)
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
        
        saveContext()
    }
    
    func updatePredecessorTaskType(_ inTaskID: Int, inPredecessorID: Int, inPredecessorType: String)
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (predecessorID == \(inPredecessorID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.predecessorType = inPredecessorType
                myStage.updateTime = Date()
                if myStage.updateType != "Add"
                {
                    myStage.updateType = "Update"
                }
                
                saveContext()
                
                myCloudDB.saveTaskPredecessorRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func deleteTaskPredecessor(_ inTaskID: Int, inPredecessorID: Int)
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (predecessorID == \(inPredecessorID))")
        
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
                
                saveContext()
                
                myCloudDB.saveTaskPredecessorRecordToCloudKit(myStage)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func saveProject(_ inProjectID: Int, inProjectEndDate: Date, inProjectName: String, inProjectStartDate: Date, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: Date, inGTDItemID: Int, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myProject: Projects!
        
        let myProjects = getProjectDetails(inProjectID)
        
        if myProjects.count == 0
        { // Add
            myProject = Projects(context: objectContext)
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
        
        saveContext()
    }

    func replaceProject(_ inProjectID: Int, inProjectEndDate: Date, inProjectName: String, inProjectStartDate: Date, inProjectStatus: String, inReviewFrequency: Int, inLastReviewDate: Date, inGTDItemID: Int, inRepeatInterval: Int, inRepeatType: String, inRepeatBase: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {

        let myProject = Projects(context: objectContext)
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

        saveContext()
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
        
        saveContext()
        
        var myProjectNote: ProjectNote!
        
        let myTeams = getProjectNote(inProjectID)
        
        if myTeams.count > 0
        { // Update
            myProjectNote = myTeams[0]
            myProjectNote.updateType = "Delete"
            myProjectNote.updateTime = Date()
        }
        
        saveContext()
    }
    
    func saveTaskUpdate(_ inTaskID: Int, inDetails: String, inSource: String, inUpdateDate: Date = Date(), inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myTaskUpdate: TaskUpdates!

        if getTaskUpdate(inTaskID, updateDate: inUpdateDate).count == 0
        {
            myTaskUpdate = TaskUpdates(context: objectContext)
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
        
            saveContext()
        }
    }
    
    func replaceTaskUpdate(_ inTaskID: Int, inDetails: String, inSource: String, inUpdateDate: Date = Date(), inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {

        let myTaskUpdate = TaskUpdates(context: objectContext)
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
        
        saveContext()
    }

    func getTaskUpdate(_ taskID: Int, updateDate: Date)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(taskID)) && (updateType != \"Delete\") && (updateDate == %@)", updateDate as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
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
    
    func getTaskUpdates(_ inTaskID: Int)->[TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "updateDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
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

    func saveContext(_ inContextID: Int, inName: String, inEmail: String, inAutoEmail: String, inParentContext: Int, inStatus: String, inPersonID: Int, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myContext: Context!
        
        let myContexts = getContextDetails(inContextID)
        
        if myContexts.count == 0
        { // Add
            myContext = Context(context: objectContext)
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
        
         saveContext()
    }
    
    func replaceContext(_ inContextID: Int, inName: String, inEmail: String, inAutoEmail: String, inParentContext: Int, inStatus: String, inPersonID: Int, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myContext = Context(context: objectContext)
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

        saveContext()
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
        
        saveContext()
        
        let myContexts2 = getContext1_1(inContextID)
        
        if myContexts2.count > 0
        {
            let myContext = myContexts[0]
            myContext.updateTime = Date()
            myContext.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getContexts(_ inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(status != \"Archived\") && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Deleted\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
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

    func getContextsForType(_ contextType: String)->[Context1_1]
    {
        let fetchRequest = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextType == \"\(contextType)\") && (updateType != \"Delete\")")
        
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
    
    func getContextByName(_ contextName: String)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(name = \"\(contextName)\") && (updateType != \"Delete\") && (status != \"Deleted\")")
        
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
    
    func getContextDetails(_ contextID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID == \(contextID)) && (updateType != \"Delete\") && (status != \"Deleted\")")
        
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

    func getAllContexts(_ inTeamID: Int)->[Context]
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
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
    
    func objectContextCount()->Int
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults.count
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }

    func saveTaskContext(_ inContextID: Int, inTaskID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myContext: TaskContext!
        
        let myContexts = getTaskContext(inContextID, inTaskID: inTaskID)
        
        if myContexts.count == 0
        { // Add
            myContext = TaskContext(context: objectContext)
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
        
        saveContext()
        
        myCloudDB.saveTaskContextRecordToCloudKit(myContext)
    }

    func replaceTaskContext(_ inContextID: Int, inTaskID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {

        let myContext = TaskContext(context: objectContext)
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
        saveContext()
    }

    func deleteTaskContext(_ inContextID: Int, inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        let predicate = NSPredicate(format: "(contextID == \(inContextID)) AND (taskID = \(inTaskID))")
        
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
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    private func getTaskContext(_ inContextID: Int, inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) AND (contextID = \(inContextID)) && (updateType != \"Delete\")")
        
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

    func getContextsForTask(_ inTaskID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(taskID = \(inTaskID)) && (updateType != \"Delete\")")
        
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

    func getTasksForContext(_ inContextID: Int)->[TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(contextID = \(inContextID)) && (updateType != \"Delete\")")
        
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

    func saveGTDLevel(_ inGTDLevel: Int, inLevelName: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myGTD: GTDLevel!
        
        let myGTDItems = getGTDLevel(inGTDLevel, inTeamID: inTeamID)
        
        if myGTDItems.count == 0
        { // Add
            myGTD = GTDLevel(context: objectContext)
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
        
        saveContext()
    }
    
    func replaceGTDLevel(_ inGTDLevel: Int, inLevelName: String, inTeamID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myGTD = GTDLevel(context: objectContext)
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

        saveContext()
    }
    
    func getGTDLevel(_ inGTDLevel: Int, inTeamID: Int)->[GTDLevel]
    {
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(inGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
    
    func changeGTDLevel(_ oldGTDLevel: Int, newGTDLevel: Int, inTeamID: Int)
    {
        var myGTD: GTDLevel!
        
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(oldGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            { // Update
                myGTD = fetchResults[0]
                //   myGTD.gTDLevel = newGTDLevel
                myGTD.setValue(newGTDLevel, forKey: "gTDLevel")
                myGTD.updateTime = Date()
                if myGTD.updateType != "Add"
                {
                    myGTD.updateType = "Update"
                }
            }
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
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
        
        saveContext()
    }

    func getGTDLevels(_ inTeamID: Int)->[GTDLevel]
    {
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
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
    
    func saveGTDItem(_ inGTDItemID: Int, inParentID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: Date, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int, inGTDLevel: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myGTD: GTDItem!
        
        let myGTDItems = checkGTDItem(inGTDItemID, inTeamID: inTeamID)
        
        if myGTDItems.count == 0
        { // Add
            myGTD = GTDItem(context: objectContext)
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
      
        saveContext()
    }
    
    func replaceGTDItem(_ inGTDItemID: Int, inParentID: Int, inTitle: String, inStatus: String, inTeamID: Int, inNote: String, inLastReviewDate: Date, inReviewFrequency: Int, inReviewPeriod: String, inPredecessor: Int, inGTDLevel: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myGTD = GTDItem(context: objectContext)
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

        saveContext()
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
        saveContext()
    }
    
    func getGTDItem(_ inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDItemID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
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
    
    func getGTDItemsForLevel(_ inGTDLevel: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDLevel == \(inGTDLevel)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
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
    
    func getGTDItemCount() -> Int
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults.count
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
    
    func getOpenGTDChildItems(_ inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDParentID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID)) && (status != \"Closed\") && (status != \"Deleted\")")
        
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
    
    func checkGTDItem(_ inGTDItemID: Int, inTeamID: Int)->[GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(gTDItemID == \(inGTDItemID)) && (updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
    
    func resetprojects()
    {
        let fetchRequest = NSFetchRequest<ProjectTeamMembers>(entityName: "ProjectTeamMembers")
    
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myStage in fetchResults
            {
                myStage.updateTime = Date()
                myStage.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest2 = NSFetchRequest<Projects>(entityName: "Projects")
            
        // Execute the fetch request, and cast the results to an array of objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myStage in fetchResults2
            {
                myStage.updateTime = Date()
                myStage.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func deleteAllPanes()
    {  // This is used to allow for testing of pane creation, so can delete all the panes if needed
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")

        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myPane in fetchResults
            {
                myPane.updateTime = Date()
                myPane.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func getPanes() -> [Panes]
    {
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
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

    func getPane(_ paneName:String) -> [Panes]
    {
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
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
    
    func togglePaneVisible(_ paneName: String)
    {
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myPane in fetchResults
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
                
                saveContext()
                
                myCloudDB.savePanesRecordToCloudKit(myPane)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func setPaneOrder(_ paneName: String, paneOrder: Int)
    {
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
        let predicate = NSPredicate(format: "(pane_name == \"\(paneName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myPane in fetchResults
            {
                myPane.pane_order = NSNumber(value: paneOrder)
                myPane.updateTime = Date()
                if myPane.updateType != "Add"
                {
                    myPane.updateType = "Update"
                }
                
                saveContext()
                
                myCloudDB.savePanesRecordToCloudKit(myPane)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func savePane(_ inPaneName:String, inPaneAvailable: Bool, inPaneVisible: Bool, inPaneOrder: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myPane: Panes!
        
        let myPanes = getPane(inPaneName)
        
        if myPanes.count == 0
        {
            // Save the details of this pane to the database
            myPane = Panes(context: objectContext)
        
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
        
        saveContext()
        
        myCloudDB.savePanesRecordToCloudKit(myPane)
    }
    
    func replacePane(_ inPaneName:String, inPaneAvailable: Bool, inPaneVisible: Bool, inPaneOrder: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myPane = Panes(context: objectContext)
            
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

        saveContext()
    }

    func resetMeetings()
    {
        let fetchRequest1 = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults1 = try objectContext.fetch(fetchRequest1)
            for myMeeting in fetchResults1
            {
                myMeeting.updateTime = Date()
                myMeeting.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest2 = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myMeeting2 in fetchResults2
            {
                myMeeting2.updateTime = Date()
                myMeeting2.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest3 = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")

        do
        {
            let fetchResults3 = try objectContext.fetch(fetchRequest3)
            for myMeeting3 in fetchResults3
            {
                myMeeting3.updateTime = Date()
                myMeeting3.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest4 = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        do
        {
            let fetchResults4 = try objectContext.fetch(fetchRequest4)
            for myMeeting4 in fetchResults4
            {
                myMeeting4.updateTime = Date()
                myMeeting4.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest6 = NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
        
        do
        {
            let fetchResults6 = try objectContext.fetch(fetchRequest6)
            for myMeeting6 in fetchResults6
            {
                myMeeting6.updateTime = Date()
                myMeeting6.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func resetTasks()
    {
        let fetchRequest1 = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults1 = try objectContext.fetch(fetchRequest1)
            for myMeeting in fetchResults1
            {
                myMeeting.updateTime = Date()
                myMeeting.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest2 = NSFetchRequest<Task>(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myMeeting2 in fetchResults2
            {
                myMeeting2.updateTime = Date()
                myMeeting2.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest3 = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        do
        {
            let fetchResults3 = try objectContext.fetch(fetchRequest3)
            for myMeeting3 in fetchResults3
            {
                myMeeting3.updateTime = Date()
                myMeeting3.updateType = "Delete"
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest4 = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        do
        {
            let fetchResults4 = try objectContext.fetch(fetchRequest4)
            for myMeeting4 in fetchResults4
            {
                myMeeting4.updateTime = Date()
                myMeeting4.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func getAgendaTasks(_ inMeetingID: String, inAgendaID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) AND (meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
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
    
    func getMeetingsTasks(_ inMeetingID: String)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(meetingID == \"\(inMeetingID)\") && (updateType != \"Delete\")")
        
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
    
    func saveAgendaTask(_ inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        var myTask: MeetingTasks
        
        myTask = MeetingTasks(context: objectContext)
        myTask.agendaID = NSNumber(value: inAgendaID)
        myTask.meetingID = inMeetingID
        myTask.taskID = NSNumber(value: inTaskID)
        myTask.updateTime = Date()
        myTask.updateType = "Add"
        
        saveContext()
        
        myCloudDB.saveMeetingTasksRecordToCloudKit(myTask)
    }
    
    func replaceAgendaTask(_ inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        let myTask = MeetingTasks(context: objectContext)
        myTask.agendaID = NSNumber(value: inAgendaID)
        myTask.meetingID = inMeetingID
        myTask.taskID = NSNumber(value: inTaskID)
        myTask.updateTime = Date()
        myTask.updateType = "Add"

        saveContext()
    }

    func checkMeetingTask(_ meetingID: String, agendaID: Int, taskID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(agendaID)) && (meetingID == \"\(meetingID)\") && (updateType != \"Delete\") && (taskID == \(taskID))")
        
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
    
    func saveMeetingTask(_ agendaID: Int, meetingID: String, taskID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myTask: MeetingTasks
        
        let myTaskList = checkMeetingTask(meetingID, agendaID: agendaID, taskID: taskID)
        
        if myTaskList.count == 0
        {
            myTask = MeetingTasks(context: objectContext)
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
        
        saveContext()
    }

    func replaceMeetingTask(_ agendaID: Int, meetingID: String, taskID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myTask = MeetingTasks(context: objectContext)
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
        saveContext()
    }
    
    func deleteAgendaTask(_ inAgendaID: Int, inMeetingID: String, inTaskID: Int)
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) AND (meetingID == \"\(inMeetingID)\") AND (taskID == \(inTaskID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                myItem.updateTime = Date()
                myItem.updateType = "Delete"
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func getAgendaTask(_ inAgendaID: Int, inMeetingID: String, inTaskID: Int)->[MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(agendaID == \(inAgendaID)) && (meetingID == \"\(inMeetingID)\") && (taskID == \(inTaskID)) && (updateType != \"Delete\")")
        
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
    
    func resetContexts()
    {
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
                // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                myItem.updateTime = Date()
                myItem.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest2 = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                myItem2.updateTime = Date()
                myItem2.updateType = "Delete"
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func clearDeletedItems()
    {
        let predicate = NSPredicate(format: "(updateType == \"Delete\")")

        let fetchRequest2 = NSFetchRequest<Context>(entityName: "Context")
        
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
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest3 = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults3 = try objectContext.fetch(fetchRequest3)
            for myItem3 in fetchResults3
            {
                objectContext.delete(myItem3 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest5 = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Set the predicate on the fetch request
        fetchRequest5.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults5 = try objectContext.fetch(fetchRequest5)
            for myItem5 in fetchResults5
            {
                objectContext.delete(myItem5 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest6 = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        // Set the predicate on the fetch request
        fetchRequest6.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults6 = try objectContext.fetch(fetchRequest6)
            for myItem6 in fetchResults6
            {
                objectContext.delete(myItem6 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest7 = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Set the predicate on the fetch request
        fetchRequest7.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults7 = try objectContext.fetch(fetchRequest7)
            for myItem7 in fetchResults7
            {
                objectContext.delete(myItem7 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest8 = NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
        
        // Set the predicate on the fetch request
        fetchRequest8.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults8 = try objectContext.fetch(fetchRequest8)
            for myItem8 in fetchResults8
            {
                objectContext.delete(myItem8 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest9 = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Set the predicate on the fetch request
        fetchRequest9.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults9 = try objectContext.fetch(fetchRequest9)
            for myItem9 in fetchResults9
            {
                objectContext.delete(myItem9 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest10 = NSFetchRequest<Panes>(entityName: "Panes")
        
        // Set the predicate on the fetch request
        fetchRequest10.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults10 = try objectContext.fetch(fetchRequest10)
            for myItem10 in fetchResults10
            {
                objectContext.delete(myItem10 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest11 = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Set the predicate on the fetch request
        fetchRequest11.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults11 = try objectContext.fetch(fetchRequest11)
            for myItem11 in fetchResults11
            {
                objectContext.delete(myItem11 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
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
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

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
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest15 = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Set the predicate on the fetch request
        fetchRequest15.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults15 = try objectContext.fetch(fetchRequest15)
            for myItem15 in fetchResults15
            {
                objectContext.delete(myItem15 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
 
        let fetchRequest16 = NSFetchRequest<Task>(entityName: "Task")
        
        // Set the predicate on the fetch request
        fetchRequest16.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults16 = try objectContext.fetch(fetchRequest16)
            for myItem16 in fetchResults16
            {
                objectContext.delete(myItem16 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest17 = NSFetchRequest<TaskAttachment>(entityName: "TaskAttachment")
        
        // Set the predicate on the fetch request
        fetchRequest17.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults17 = try objectContext.fetch(fetchRequest17)
            for myItem17 in fetchResults17
            {
                objectContext.delete(myItem17 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
 
        let fetchRequest18 = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Set the predicate on the fetch request
        fetchRequest18.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults18 = try objectContext.fetch(fetchRequest18)
            for myItem18 in fetchResults18
            {
                objectContext.delete(myItem18 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
  
        let fetchRequest19 = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Set the predicate on the fetch request
        fetchRequest19.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults19 = try objectContext.fetch(fetchRequest19)
            for myItem19 in fetchResults19
            {
                objectContext.delete(myItem19 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest21 = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        // Set the predicate on the fetch request
        fetchRequest21.predicate = predicate
        do
        {
            let fetchResults21 = try objectContext.fetch(fetchRequest21)
            for myItem21 in fetchResults21
            {
                objectContext.delete(myItem21 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
   
        let fetchRequest22 = NSFetchRequest<Team>(entityName: "Team")
        
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        do
        {
            let fetchResults22 = try objectContext.fetch(fetchRequest22)
            for myItem22 in fetchResults22
            {
                objectContext.delete(myItem22 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest23 = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        
        // Set the predicate on the fetch request
        fetchRequest23.predicate = predicate
        do
        {
            let fetchResults23 = try objectContext.fetch(fetchRequest23)
            for myItem23 in fetchResults23
            {
                objectContext.delete(myItem23 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest24 = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
        // Set the predicate on the fetch request
        fetchRequest24.predicate = predicate
        do
        {
            let fetchResults24 = try objectContext.fetch(fetchRequest24)
            for myItem24 in fetchResults24
            {
                objectContext.delete(myItem24 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest25 = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        // Set the predicate on the fetch request
        fetchRequest25.predicate = predicate
        do
        {
            let fetchResults25 = try objectContext.fetch(fetchRequest25)
            for myItem25 in fetchResults25
            {
                objectContext.delete(myItem25 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
   
        let fetchRequest26 = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Set the predicate on the fetch request
        fetchRequest26.predicate = predicate
        do
        {
            let fetchResults26 = try objectContext.fetch(fetchRequest26)
            for myItem26 in fetchResults26
            {
                objectContext.delete(myItem26 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest27 = NSFetchRequest<ProcessedEmails>(entityName: "ProcessedEmails")
        
        // Set the predicate on the fetch request
        fetchRequest27.predicate = predicate
        do
        {
            let fetchResults27 = try objectContext.fetch(fetchRequest27)
            for myItem27 in fetchResults27
            {
                objectContext.delete(myItem27 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    
        let fetchRequest28 = NSFetchRequest<Outline>(entityName: "Outline")
        
        // Set the predicate on the fetch request
        fetchRequest28.predicate = predicate
        do
        {
            let fetchResults28 = try objectContext.fetch(fetchRequest28)
            for myItem28 in fetchResults28
            {
                objectContext.delete(myItem28 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest29 = NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
        
        // Set the predicate on the fetch request
        fetchRequest29.predicate = predicate
        do
        {
            let fetchResults29 = try objectContext.fetch(fetchRequest29)
            for myItem29 in fetchResults29
            {
                objectContext.delete(myItem29 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func clearSyncedItems()
    {
        let predicate = NSPredicate(format: "(updateType != \"\")")
        
        let fetchRequest2 = NSFetchRequest<Context>(entityName: "Context")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                myItem2.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
     
        let fetchRequest3 = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        // Set the predicate on the fetch request
        fetchRequest3.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults3 = try objectContext.fetch(fetchRequest3)
            for myItem3 in fetchResults3
            {
                myItem3.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest5 = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Set the predicate on the fetch request
        fetchRequest5.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults5 = try objectContext.fetch(fetchRequest5)
            for myItem5 in fetchResults5
            {
                myItem5.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest6 = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        // Set the predicate on the fetch request
        fetchRequest6.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults6 = try objectContext.fetch(fetchRequest6)
            for myItem6 in fetchResults6
            {
                myItem6.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest7 = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Set the predicate on the fetch request
        fetchRequest7.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults7 = try objectContext.fetch(fetchRequest7)
            for myItem7 in fetchResults7
            {
                myItem7.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
     
        let fetchRequest8 = NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
        
        // Set the predicate on the fetch request
        fetchRequest8.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults8 = try objectContext.fetch(fetchRequest8)
            for myItem8 in fetchResults8
            {
                myItem8.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
     
        let fetchRequest9 = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Set the predicate on the fetch request
        fetchRequest9.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults9 = try objectContext.fetch(fetchRequest9)
            for myItem9 in fetchResults9
            {
                myItem9.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
 
        let fetchRequest10 = NSFetchRequest<Panes>(entityName: "Panes")
        
        // Set the predicate on the fetch request
        fetchRequest10.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults10 = try objectContext.fetch(fetchRequest10)
            for myItem10 in fetchResults10
            {
                myItem10.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
 
        let fetchRequest11 = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Set the predicate on the fetch request
        fetchRequest11.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults11 = try objectContext.fetch(fetchRequest11)
            for myItem11 in fetchResults11
            {
                myItem11.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    
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
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    
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
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
      
        let fetchRequest15 = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Set the predicate on the fetch request
        fetchRequest15.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults15 = try objectContext.fetch(fetchRequest15)
            for myItem15 in fetchResults15
            {
                myItem15.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        

        
        let fetchRequest16 = NSFetchRequest<Task>(entityName: "Task")
        
        // Set the predicate on the fetch request
        fetchRequest16.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults16 = try objectContext.fetch(fetchRequest16)
            for myItem16 in fetchResults16
            {
                myItem16.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest17 = NSFetchRequest<TaskAttachment>(entityName: "TaskAttachment")
        
        // Set the predicate on the fetch request
        fetchRequest17.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults17 = try objectContext.fetch(fetchRequest17)
            for myItem17 in fetchResults17
            {
                myItem17.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest18 = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Set the predicate on the fetch request
        fetchRequest18.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults18 = try objectContext.fetch(fetchRequest18)
            for myItem18 in fetchResults18
            {
                myItem18.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest19 = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Set the predicate on the fetch request
        fetchRequest19.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults19 = try objectContext.fetch(fetchRequest19)
            for myItem19 in fetchResults19
            {
                myItem19.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest21 = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        // Set the predicate on the fetch request
        fetchRequest21.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem object
        do
        {
            let fetchResults21 = try objectContext.fetch(fetchRequest21)
            for myItem21 in fetchResults21
            {
                myItem21.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest22 = NSFetchRequest<Team>(entityName: "Team")
        // Set the predicate on the fetch request
        fetchRequest22.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults22 = try objectContext.fetch(fetchRequest22)
            for myItem22 in fetchResults22
            {
                myItem22.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest23 = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        // Set the predicate on the fetch request
        fetchRequest23.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults23 = try objectContext.fetch(fetchRequest23)
            for myItem23 in fetchResults23
            {
                myItem23.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest24 = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        // Set the predicate on the fetch request
        fetchRequest24.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults24 = try objectContext.fetch(fetchRequest24)
            for myItem24 in fetchResults24
            {
                myItem24.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest25 = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        // Set the predicate on the fetch request
        fetchRequest25.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults25 = try objectContext.fetch(fetchRequest25)
            for myItem25 in fetchResults25
            {
                myItem25.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }

        let fetchRequest26 = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        // Set the predicate on the fetch request
        fetchRequest26.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults26 = try objectContext.fetch(fetchRequest26)
            for myItem26 in fetchResults26
            {
                myItem26.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest27 = NSFetchRequest<ProcessedEmails>(entityName: "ProcessedEmails")
        // Set the predicate on the fetch request
        fetchRequest27.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults27 = try objectContext.fetch(fetchRequest27)
            for myItem27 in fetchResults27
            {
                myItem27.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest28 = NSFetchRequest<Outline>(entityName: "Outline")
        // Set the predicate on the fetch request
        fetchRequest28.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults28 = try objectContext.fetch(fetchRequest28)
            for myItem28 in fetchResults28
            {
                myItem28.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest29 = NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
        // Set the predicate on the fetch request
        fetchRequest29.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults29 = try objectContext.fetch(fetchRequest29)
            for myItem29 in fetchResults29
            {
                myItem29.updateType = ""
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func saveTeam(_ inTeamID: Int, inName: String, inStatus: String, inNote: String, inType: String, inPredecessor: Int, inExternalID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myTeam: Team!
        
        let myTeams = getTeam(inTeamID)
        
        if myTeams.count == 0
        { // Add
            myTeam = Team(context: objectContext)
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
        
        saveContext()
    }
    
    func replaceTeam(_ inTeamID: Int, inName: String, inStatus: String, inNote: String, inType: String, inPredecessor: Int, inExternalID: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myTeam = Team(context: persistentContainer.viewContext)
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

        saveContext()
        self.refreshObject(myTeam)
    }

    func getTeam(_ inTeamID: Int)->[Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(inTeamID))")
        
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
    
    func getAllTeams()->[Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors

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
    
    func getMyTeams(_ myID: String)->[Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
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
    
    func getTeamsCount() -> Int
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        fetchRequest.shouldRefreshRefetchedObjects = true
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults.count
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
    
    func deleteAllTeams()
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                objectContext.delete(myItem as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        let fetchRequest2 = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                objectContext.delete(myItem2 as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func saveProjectNote(_ inProjectID: Int, inNote: String, inReviewPeriod: String, inPredecessor: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        var myProjectNote: ProjectNote!
        
        let myTeams = getProjectNote(inProjectID)
        
        if myTeams.count == 0
        { // Add
            myProjectNote = ProjectNote(context: objectContext)
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
        
        saveContext()
    }
 
    func replaceProjectNote(_ inProjectID: Int, inNote: String, inReviewPeriod: String, inPredecessor: Int, inUpdateTime: Date = Date(), inUpdateType: String = "CODE")
    {
        let myProjectNote = ProjectNote(context: objectContext)
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

        saveContext()
    }

    func getProjectNote(_ inProjectID: Int)->[ProjectNote]
    {
        let fetchRequest = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (projectID == \(inProjectID))")
        
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

    func getNextID(_ inTableName: String, inInitialValue: Int = 1) -> Int
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        let predicate = NSPredicate(format: "(decode_name == \"\(inTableName)\") && (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count == 0
            {
                // Create table entry
                let storeKey = "\(inInitialValue)"
                updateDecodeValue(inTableName, inCodeValue: storeKey, inCodeType: "hidden")
                
                return inInitialValue
            }
            else
            {
                // Increment table value by 1 and save back to database
                let storeint = Int(fetchResults[0].decode_value)! + 1
                
                let storeKey = "\(storeint)"
                updateDecodeValue(inTableName, inCodeValue: storeKey, inCodeType: "hidden")
                
                return storeint
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return 0
        }
    }
    
    func initialiseTeamForMeetingAgenda(_ inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            {
                for myItem in fetchResults
                {
                    myItem.teamID = NSNumber(value: inTeamID)
                }
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func initialiseTeamForContext(_ inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")
        
        let sortDescriptor = NSSortDescriptor(key: "contextID", ascending: true)
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
                    maxID = myItem.contextID as Int
                }
                
                saveContext()
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Context", inCodeValue: tempInt, inCodeType: "hidden")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func initialiseTeamForProject(_ inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
        let sortDescriptor = NSSortDescriptor(key: "projectID", ascending: true)
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
                    maxID = myItem.projectID as Int
                }
                
                saveContext()
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Projects", inCodeValue: tempInt, inCodeType: "hidden")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
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
                    maxID = myItem.roleID as Int
                }
                
                saveContext()
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Roles", inCodeValue: tempInt, inCodeType: "hidden")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func initialiseTeamForStages(_ inTeamID: Int)
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            if fetchResults.count > 0
            {
                for myItem in fetchResults
                {
                    myItem.teamID = NSNumber(value: inTeamID)
                }
                
                saveContext()
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func initialiseTeamForTask(_ inTeamID: Int)
    {
        var maxID: Int = 1
        
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
        let sortDescriptor = NSSortDescriptor(key: "taskID", ascending: true)
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
                    maxID = myItem.taskID as Int
                }
                
                saveContext()
            }
            
            // Now go and populate the Decode for this
            
            let tempInt = "\(maxID)"
            updateDecodeValue("Task", inCodeValue: tempInt, inCodeType: "hidden")
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }

    func saveContext1_1(_ contextID: Int, predecessor: Int, contextType: String, updateTime: Date = Date(), updateType: String = "CODE")
    {
        var myContext: Context1_1!
        
        let myContexts = getContext1_1(contextID)
        
        if myContexts.count == 0
        { // Add
            myContext = Context1_1(context: objectContext)
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
        
        saveContext()
    }
    
    func replaceContext1_1(_ contextID: Int, predecessor: Int, contextType: String, updateTime: Date = Date(), updateType: String = "CODE")
    {
        let myContext = Context1_1(context: objectContext)
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

        saveContext()
    }

    func getContext1_1(_ inContextID: Int)->[Context1_1]
    {
        let fetchRequest = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(updateType != \"Delete\") && (contextID == \(inContextID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "contextID", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
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
    
    func resetDecodes()
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(decodeType != \"hidden\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                objectContext.delete(myItem as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
    }
    
    func performTidyDecodes(_ inString: String)
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: inString)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                objectContext.delete(myItem as NSManagedObject)
            }
            
            saveContext()
        }
        catch
        {
            print("Error occurred during execution: \(error)")
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
        let fetchRequest = NSFetchRequest<Context>(entityName: "Context")

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

    func getContexts1_1ForSync(_ inLastSyncDate: Date) -> [Context1_1]
    {
        let fetchRequest = NSFetchRequest<Context1_1>(entityName: "Context1_1")
     
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

    func getDecodesForSync(_ inLastSyncDate: Date) -> [Decodes]
    {
        let fetchRequest = NSFetchRequest<Decodes>(entityName: "Decodes")
        
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

    func getGTDItemsForSync(_ inLastSyncDate: Date) -> [GTDItem]
    {
        let fetchRequest = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
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
    
    func getGTDLevelsForSync(_ inLastSyncDate: Date) -> [GTDLevel]
    {
        let fetchRequest = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
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
    
    func getMeetingAgendasForSync(_ inLastSyncDate: Date) -> [MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
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
    
    func getMeetingAgendaItemsForSync(_ inLastSyncDate: Date) -> [MeetingAgendaItem]
    {
        let fetchRequest = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
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
    
    func getMeetingAttendeesForSync(_ inLastSyncDate: Date) -> [MeetingAttendees]
    {
        let fetchRequest = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
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
    
    func getMeetingSupportingDocsForSync(_ inLastSyncDate: Date) -> [MeetingSupportingDocs]
    {
        let fetchRequest = NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
        
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
    
    func getMeetingTasksForSync(_ inLastSyncDate: Date) -> [MeetingTasks]
    {
        let fetchRequest = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
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
    
    func getPanesForSync(_ inLastSyncDate: Date) -> [Panes]
    {
        let fetchRequest = NSFetchRequest<Panes>(entityName: "Panes")
        
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
    
    func getProjectsForSync(_ inLastSyncDate: Date) -> [Projects]
    {
        let fetchRequest = NSFetchRequest<Projects>(entityName: "Projects")
        
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
    
    func getProjectNotesForSync(_ inLastSyncDate: Date) -> [ProjectNote]
    {
        let fetchRequest = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        
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
    
    func getProjectTeamMembersForSync(_ inLastSyncDate: Date) -> [ProjectTeamMembers]
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

    func getRolesForSync(_ inLastSyncDate: Date) -> [Roles]
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
    
    func getStagesForSync(_ inLastSyncDate: Date) -> [Stages]
    {
        let fetchRequest = NSFetchRequest<Stages>(entityName: "Stages")
        
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

    func getTaskForSync(_ inLastSyncDate: Date) -> [Task]
    {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        
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

    func getTaskAttachmentsForSync(_ inLastSyncDate: Date) -> [TaskAttachment]
    {
        let fetchRequest = NSFetchRequest<TaskAttachment>(entityName: "TaskAttachment")
        
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
    
    func getTaskContextsForSync(_ inLastSyncDate: Date) -> [TaskContext]
    {
        let fetchRequest = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
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
    
    func getTaskPredecessorsForSync(_ inLastSyncDate: Date) -> [TaskPredecessor]
    {
        let fetchRequest = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
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
    
    func getTaskUpdatesForSync(_ inLastSyncDate: Date) -> [TaskUpdates]
    {
        let fetchRequest = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
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
    
    func getTeamsForSync(_ inLastSyncDate: Date) -> [Team]
    {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
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
    
    func getProcessedEmailsForSync(_ inLastSyncDate: Date) -> [ProcessedEmails]
    {
        let fetchRequest = NSFetchRequest<ProcessedEmails>(entityName: "ProcessedEmails")
        
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

    func getOutlineForSync(_ inLastSyncDate: Date) -> [Outline]
    {
        let fetchRequest = NSFetchRequest<Outline>(entityName: "Outline")
        
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
    
    func getOutlineDetailsForSync(_ inLastSyncDate: Date) -> [OutlineDetails]
    {
        let fetchRequest = NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
        
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
    
    func deleteAllCoreData()
    {
        let fetchRequest2 = NSFetchRequest<Context>(entityName: "Context")

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
        
        let fetchRequest3 = NSFetchRequest<Decodes>(entityName: "Decodes")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults3 = try objectContext.fetch(fetchRequest3)
            for myItem3 in fetchResults3
            {
                self.objectContext.delete(myItem3 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest5 = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        do
        {
            let fetchResults5 = try objectContext.fetch(fetchRequest5)
            for myItem5 in fetchResults5
            {
                self.objectContext.delete(myItem5 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest6 = NSFetchRequest<MeetingAgendaItem>(entityName: "MeetingAgendaItem")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults6 = try objectContext.fetch(fetchRequest6)
            for myItem6 in fetchResults6
            {
                self.objectContext.delete(myItem6 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest7 = NSFetchRequest<MeetingAttendees>(entityName: "MeetingAttendees")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        
        do
        {
            let fetchResults7 = try objectContext.fetch(fetchRequest7)
            for myItem7 in fetchResults7
            {
                self.objectContext.delete(myItem7 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest8 = NSFetchRequest<MeetingSupportingDocs>(entityName: "MeetingSupportingDocs")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults8 = try objectContext.fetch(fetchRequest8)
            for myItem8 in fetchResults8
            {
                self.objectContext.delete(myItem8 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest9 = NSFetchRequest<MeetingTasks>(entityName: "MeetingTasks")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults9 = try objectContext.fetch(fetchRequest9)
            for myItem9 in fetchResults9
            {
                self.objectContext.delete(myItem9 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest10 = NSFetchRequest<Panes>(entityName: "Panes")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults10 = try objectContext.fetch(fetchRequest10)
            for myItem10 in fetchResults10
            {
                self.objectContext.delete(myItem10 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest11 = NSFetchRequest<Projects>(entityName: "Projects")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults11 = try objectContext.fetch(fetchRequest11)
            for myItem11 in fetchResults11
            {
                self.objectContext.delete(myItem11 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
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
        
        let fetchRequest15 = NSFetchRequest<Stages>(entityName: "Stages")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults15 = try objectContext.fetch(fetchRequest15)
            for myItem15 in fetchResults15
            {
                self.objectContext.delete(myItem15 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest16 = NSFetchRequest<Task>(entityName: "Task")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults16 = try objectContext.fetch(fetchRequest16)
            for myItem16 in fetchResults16
            {
                self.objectContext.delete(myItem16 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest17 = NSFetchRequest<TaskAttachment>(entityName: "TaskAttachment")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults17 = try objectContext.fetch(fetchRequest17)
            for myItem17 in fetchResults17
            {
                self.objectContext.delete(myItem17 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest18 = NSFetchRequest<TaskContext>(entityName: "TaskContext")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults18 = try objectContext.fetch(fetchRequest18)
            for myItem18 in fetchResults18
            {
                self.objectContext.delete(myItem18 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest19 = NSFetchRequest<TaskUpdates>(entityName: "TaskUpdates")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults19 = try objectContext.fetch(fetchRequest19)
            for myItem19 in fetchResults19
            {
                self.objectContext.delete(myItem19 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest21 = NSFetchRequest<TaskPredecessor>(entityName: "TaskPredecessor")
        
        do
        {
            let fetchResults21 = try objectContext.fetch(fetchRequest21)
            for myItem21 in fetchResults21
            {
                self.objectContext.delete(myItem21 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest22 = NSFetchRequest<Team>(entityName: "Team")
        
        do
        {
            let fetchResults22 = try objectContext.fetch(fetchRequest22)
            for myItem22 in fetchResults22
            {
                self.objectContext.delete(myItem22 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest23 = NSFetchRequest<ProjectNote>(entityName: "ProjectNote")
        
        do
        {
            let fetchResults23 = try objectContext.fetch(fetchRequest23)
            for myItem23 in fetchResults23
            {
                self.objectContext.delete(myItem23 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest24 = NSFetchRequest<Context1_1>(entityName: "Context1_1")
        
        do
        {
            let fetchResults24 = try objectContext.fetch(fetchRequest24)
            for myItem24 in fetchResults24
            {
                self.objectContext.delete(myItem24 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest25 = NSFetchRequest<GTDItem>(entityName: "GTDItem")
        
        do
        {
            let fetchResults25 = try objectContext.fetch(fetchRequest25)
            for myItem25 in fetchResults25
            {
                self.objectContext.delete(myItem25 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest26 = NSFetchRequest<GTDLevel>(entityName: "GTDLevel")
        
        do
        {
            let fetchResults26 = try objectContext.fetch(fetchRequest26)
            for myItem26 in fetchResults26
            {
                self.objectContext.delete(myItem26 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest27 = NSFetchRequest<ProcessedEmails>(entityName: "ProcessedEmails")
        
        do
        {
            let fetchResults27 = try objectContext.fetch(fetchRequest27)
            for myItem27 in fetchResults27
            {
                self.objectContext.delete(myItem27 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()

        let fetchRequest28 = NSFetchRequest<Outline>(entityName: "Outline")
        
        do
        {
            let fetchResults28 = try objectContext.fetch(fetchRequest28)
            for myItem28 in fetchResults28
            {
                self.objectContext.delete(myItem28 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        let fetchRequest29 = NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
        
        do
        {
            let fetchResults29 = try objectContext.fetch(fetchRequest29)
            for myItem29 in fetchResults29
            {
                self.objectContext.delete(myItem29 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func saveProcessedEmail(_ emailID: String, emailType: String, processedDate: Date, updateTime: Date = Date(), updateType: String = "CODE")
    {
        var myEmail: ProcessedEmails!
        
        let myEmailItems = getProcessedEmail(emailID)
        
        if myEmailItems.count == 0
        { // Add
            myEmail = ProcessedEmails(context: objectContext)
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
        
        saveContext()
        
        myCloudDB.saveProcessedEmailsRecordToCloudKit(myEmail)
    }
    
    func replaceProcessedEmail(_ emailID: String, emailType: String, processedDate: Date, updateTime: Date = Date(), updateType: String = "CODE")
    {
        let myEmail = ProcessedEmails(context: objectContext)
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

        saveContext()
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
        
        saveContext()
    }
    
    func getProcessedEmail(_ emailID: String)->[ProcessedEmails]
    {
        let fetchRequest = NSFetchRequest<ProcessedEmails>(entityName: "ProcessedEmails")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(emailID == \"\(emailID)\")")
        
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

    func saveOutline(_ outlineID: Int, parentID: Int, parentType: String, title: String, status: String, updateTime: Date = Date(), updateType: String = "CODE")
    {
        var myOutline: Outline!
        
        let myOutlineItems = getOutline(outlineID)
        
        if myOutlineItems.count == 0
        { // Add
            myOutline = Outline(context: objectContext)
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
        
        saveContext()
        
        myCloudDB.saveOutlineRecordToCloudKit(myOutline)
    }
    
    func replaceOutline(_ outlineID: Int, parentID: Int, parentType: String, title: String, status: String, updateTime: Date = Date(), updateType: String = "CODE")
    {
        let myOutline = Outline(context: objectContext)
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
        
        saveContext()
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
        saveContext()
    }
    
    func getOutline(_ outlineID: Int)->[Outline]
    {
        let fetchRequest = NSFetchRequest<Outline>(entityName: "Outline")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(outlineID == \"\(outlineID)\")")
        
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

    func saveOutlineDetail(_ outlineID: Int, lineID: Int, lineOrder: Int, parentLine: Int, lineText: String, lineType: String, checkBoxValue: Bool, updateTime: Date = Date(), updateType: String = "CODE")
    {
        var myOutline: OutlineDetails!
        
        let myOutlineItems = getOutlineDetails(outlineID, lineID: lineID)
        
        if myOutlineItems.count == 0
        { // Add
            myOutline = OutlineDetails(context: objectContext)
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
        
        saveContext()
        
        myCloudDB.saveOutlineDetailsRecordToCloudKit(myOutline)
    }
    
    func replaceOutlineDetails(_ outlineID: Int, lineID: Int, lineOrder: Int, parentLine: Int, lineText: String, lineType: String, checkBoxValue: Bool, updateTime: Date = Date(), updateType: String = "CODE")
    {
        let myOutline = OutlineDetails(context: objectContext)
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
        
        saveContext()
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
        
        saveContext()
    }
    
    func getOutlineDetails(_ outlineID: Int, lineID: Int)->[OutlineDetails]
    {
        let fetchRequest = NSFetchRequest<OutlineDetails>(entityName: "OutlineDetails")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(outlineID == \"\(outlineID)\") && (lineID == \"\(lineID)\")")
        
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
}
