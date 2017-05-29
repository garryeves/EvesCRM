//
//  UsersClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

let NotificationUserSaved = Notification.Name("NotificationUserSaved")
let NotificationUserRetrieved = Notification.Name("NotificationUserRetrieved")
let NotificationUserCountQueryDone = Notification.Name("NotificationUserCountQueryDone")
let NotificationUserCreated = Notification.Name("NotificationUserCreated")
let NotificationUserLoaded = Notification.Name("NotificationUserLoaded")
let NotificationUserListLoaded = Notification.Name("NotificationUserListLoaded")
let NotificationValidateUser = Notification.Name("NotificationValidateUser")

class userItems: NSObject
{
    init(userList: String)
    {
        super.init()
        
        // Call to cloudkey top get the list of users details
                
        myCloudDB.getUsersList(userList: userList)
        
    }
    
    var users: [returnUser]
    {
        return myCloudDB.retrieveUserList()
    }
}

class userItem: NSObject
{
    fileprivate var myUserID: Int = 0
    fileprivate var myRoles: userRoles!
    fileprivate var myTeams: [team] = Array()
    fileprivate var myAuthorised: Bool = false
    fileprivate var myName: String = ""
    fileprivate var myPhraseDate: Date = getDefaultDate()
    fileprivate var myEmail: String = ""
    fileprivate var myPassPhrase: String = ""
    fileprivate var myCurrentTeam: team!
    fileprivate var myPersonID: Int = 0
    
    fileprivate let defaultsName = "group.com.garryeves.EvesCRM"
    
    var userID: Int
    {
        get
        {
            return myUserID
        }
    }
    
    var roles: userRoles
    {
        get
        {
            return myRoles
        }
    }
    
    var isAuthorised: Bool
    {
        get
        {
            return myAuthorised
        }
    }
    
    var name: String
    {
        get
        {
            return myName
        }
        set
        {
            myName = newValue
        }
    }
    
    var email: String
    {
        get
        {
            return myEmail
        }
        set
        {
            myEmail = newValue
        }
    }
    
    var personID: Int
    {
        get
        {
            return myPersonID
        }
        set
        {
            myPersonID = newValue
        }
    }
    
    var phraseDate: Date
    {
        get
        {
            return myPhraseDate
        }
        set
        {
            myPhraseDate = newValue
        }
    }
    
    var phraseDateText: String
    {
        get
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            return dateFormatter.string(from: myPhraseDate)
        }
    }
    
    var passPhrase: String
    {
        get
        {
            return myPassPhrase
        }
        set
        {
            myPassPhrase = newValue
        }
    }
    
    var currentTeam: team?
    {
        get
        {
            return myCurrentTeam
        }
    }
    
    init(currentTeam: team)
    {
        super.init()
        
        // Create a new user
        
        myCurrentTeam = currentTeam
        notificationCenter.addObserver(self, selector: #selector(self.queryFinished), name: NotificationUserCountQueryDone, object: nil)
        
        myCloudDB.getUserCount()
    }
    
    override init()
    {
        super.init()
    }
    
    init(userID: Int)
    {
        super.init()

        myUserID = userID
    }
    
    func getUserDetails()
    {
        notificationCenter.addObserver(self, selector: #selector(self.userRetieved), name: NotificationUserRetrieved, object: nil)
        
        // check to see if user exists
        let myReachability = Reachability()
        if myReachability.isConnectedToNetwork()
        {
            myCloudDB.getUser(userID)
        }
        else
        {
            // Not connected to Internet
            
            myUserID = userID
            NotificationCenter.default.post(name: NotificationUserRetrieved, object: nil)
        }
    }
    
    func userRetieved()
    {
        let record = myCloudDB.getUserRecord()
        
        if record != nil
        {
            myUserID = record!.userID
            myName = record!.name
            myPhraseDate = record!.phraseDate
            myPassPhrase = record!.passPhrase
            myEmail = record!.email
            myPersonID = record!.personID
        }
        else
        {
            myName = ""
            myPassPhrase = ""
            myEmail = ""
        }
        
        loadTeams()
        
        loadRoles()
        
        notificationCenter.post(name: NotificationUserLoaded, object: nil)
    }
    
    func queryExistingFinished()
    {
        
    }
    
    func queryFinished()
    {
        notificationCenter.removeObserver(NotificationUserCountQueryDone)
        
        myUserID = myCloudDB.userCount() + 1

        // Now lets call to create the team in cloudkit
        
        notificationCenter.addObserver(self, selector: #selector(self.userCreated), name: NotificationUserSaved, object: nil)
        
        myCloudDB.createNewUser(myUserID)
    }
    
    func userCreated()
    {
        myAuthorised = true
        
        addTeamToUser(myCurrentTeam)
        notificationCenter.post(name: NotificationUserCreated, object: nil)
    }

    func addTeamToUser(_ teamObject: team)
    {
        myTeams.append(teamObject)
        
        myDatabaseConnection.saveUserTeam(myUserID, teamID: teamObject.teamID)
        
        if myTeams.count == 1
        {
            myCurrentTeam = teamObject
        }
    }
    
    func addRoleToUser(roleType: String, accessLevel: String, saveToCloud: Bool)
    {
        let myItem = userRoleItem(userID: myUserID, roleType: roleType, teamID: currentTeam!.teamID, saveToCloud: saveToCloud)
        myItem.accessLevel = accessLevel
    }
    
    func loadRoles()
    {
        myRoles = userRoles(userID: myUserID, teamID: currentTeam!.teamID)
    }
    
    func setCurrentTeam(_ teamObject: team)
    {
        var foundBool = false
        
        for myItem in myTeams
        {
            if myItem.teamID == teamObject.teamID
            {
                foundBool = true
                break
            }
        }
        
        if foundBool
        {
            myCurrentTeam = teamObject
        }
    }
    
    func removeTeamForUser(_ teamObject: team)
    {
        myDatabaseConnection.deleteUserTeam(myUserID, teamID: teamObject.teamID)
        
        loadTeams()
    }
    
    func loadTeams()
    {
        myTeams.removeAll()
        
        for myItem in myDatabaseConnection.getTeamsForUser(userID: myUserID)
        {
            let teamObject = team(teamID: Int(myItem.teamID))
            myTeams.append(teamObject)
        }
        
        if myTeams.count == 1
        {
            myCurrentTeam = myTeams[0]
        }
    }

    func save()
    {
        myCloudDB.saveUser(myUserID, name: myName, phraseDate: myPhraseDate, passPhrase: myPassPhrase, email: myEmail, personID: myPersonID)
    }
    
    func delete() -> Bool
    {
        if myTeams.count == 0
        {
            return false
        }
        else
        {
            myCloudDB.deleteUser(myUserID)
            return true
        }
    }
    
    func generatePassPhrase()
    {
        myPassPhrase = randomString(length: 16)
        
        let calendar = Calendar.current
        myPhraseDate = calendar.date(byAdding: .day, value: 1, to: Date())!

        save()
    }
    
    private func randomString(length: Int) -> String
    {
        let letters : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var retString: String = ""
        
        for _ in 1...length
        {
            let randomIndex  = Int(arc4random_uniform(UInt32(letters.characters.count)))
            let a = letters.index(letters.startIndex, offsetBy: randomIndex)
            retString +=  String(letters[a])
        }
        
        return retString
    }
    
    func syncDatabase()
    {
        myDBSync.sync()
    }
    
    func addInitialUserRoles()
    {
        var recordCount: Int = 0
        
        let processRecords = currentUser.currentTeam!.getRoleTypes()
        
        for myItem in processRecords
        {
            if recordCount == processRecords.count - 1
            {
                addRoleToUser(roleType: myItem, accessLevel: "Write", saveToCloud: true)
                usleep(500)
            }
            else
            {
                addRoleToUser(roleType: myItem, accessLevel: "Write", saveToCloud: false)
                recordCount += 1
                usleep(500)
            }
        }
        
        loadRoles()
    }
}

extension CloudKitInteraction
{
    func getUserCount()
    {
        recordsInTable = 0
        
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "DBUsers", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        operation.desiredKeys = ["userID"]
        
        operation.recordFetchedBlock = { (record) in
            self.recordsInTable += 1
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "DBUsers", queryOperation: operation, onOperationQueue: operationQueue, notification: NotificationUserCountQueryDone)
    }
    
    func userCount() -> Int
    {
        return recordsInTable
    }
    
    func createNewUser(_ userID: Int)
    {
        let record = CKRecord(recordType: "DBUsers")
        record.setValue(userID, forKey: "userID")
        
        self.publicDB.save(record, completionHandler:
            { (savedRecord, saveError) in
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
                    NotificationCenter.default.post(name: NotificationUserSaved, object: nil)
                }
        })
    }
    
    func getUser(_ userID: Int)
    {
        let predicate = NSPredicate(format: "(userID == \(userID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "DBUsers", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler:
        { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                let record = records!.first
                
                var storedUserID: Int = 0
                if record!.object(forKey: "userID") != nil
                {
                    storedUserID = record!.object(forKey: "userID") as! Int
                }

                var personID: Int = 0
                if record!.object(forKey: "personID") != nil
                {
                    personID = record!.object(forKey: "personID") as! Int
                }

                var phraseDate = getDefaultDate()
                if record!.object(forKey: "phraseDate") != nil
                {
                    phraseDate = record!.object(forKey: "phraseDate") as! Date
                }
                
                var name: String = ""
                if record!.object(forKey: "name") != nil
                {
                    name = record!.object(forKey: "name") as! String
                }
                
                var passPhrase: String = ""
                if record!.object(forKey: "passPhrase") != nil
                {
                    passPhrase = record!.object(forKey: "passPhrase") as! String
                }
                
                var email: String = ""
                if record!.object(forKey: "email") != nil
                {
                    email = record!.object(forKey: "email") as! String
                }
                
                self.returnUserEntry = returnUser(
                    userID: storedUserID,
                    name: name,
                    passPhrase: passPhrase,
                    phraseDate: phraseDate,
                    email: email,
                    personID: personID)
                
                NotificationCenter.default.post(name: NotificationUserRetrieved, object: nil)
            }
        })
    }
    
    func getUserRecord() -> returnUser?
    {
        return returnUserEntry
    }

    func saveUser(_ userID: Int, name: String, phraseDate: Date, passPhrase: String, email: String, personID: Int)
    {
        let sem = DispatchSemaphore(value: 0)

        let predicate = NSPredicate(format: "(userID == \(userID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "DBUsers", predicate: predicate)
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

                    record!.setValue(name, forKey: "name")
                    record!.setValue(phraseDate, forKey: "phraseDate")
                    record!.setValue(passPhrase, forKey: "passPhrase")
                    record!.setValue(email, forKey: "email")
                    record!.setValue(personID, forKey: "personID")
                    
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
                    let record = CKRecord(recordType: "DBUsers")
                    record.setValue(userID, forKey: "userID")
                    record.setValue(name, forKey: "name")
                    record.setValue(phraseDate, forKey: "phraseDate")
                    record.setValue(passPhrase, forKey: "passPhrase")
                    record.setValue(email, forKey: "email")
                    record.setValue(personID, forKey: "personID")

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
    
    func deleteUser(_ userID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(userID == \(userID))")
        let query: CKQuery = CKQuery(recordType: "DBUsers", predicate: predicate)
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
    
    func getUsersList(userList: String)
    {
        returnUserArray.removeAll()
        
        let predicate = NSPredicate(format: "userID IN { \(userList) } AND (updateType != \"Delete\")") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "DBUsers", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.processUserList(record)
            usleep(self.sleepTime)
        }
        
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "DBUsers", queryOperation: operation, onOperationQueue: operationQueue, notification: NotificationUserListLoaded)
    }
    
    private func processUserList(_ sourceRecord: CKRecord)
    {
        var storedUserID: Int = 0
        if sourceRecord.object(forKey: "userID") != nil
        {
            storedUserID = sourceRecord.object(forKey: "userID") as! Int
        }
        
        var personID: Int = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int
        }
        
        var phraseDate = getDefaultDate()
        if sourceRecord.object(forKey: "phraseDate") != nil
        {
            phraseDate = sourceRecord.object(forKey: "phraseDate") as! Date
        }
        
        var name: String = ""
        if sourceRecord.object(forKey: "name") != nil
        {
            name = sourceRecord.object(forKey: "name") as! String
        }
        
        var passPhrase: String = ""
        if sourceRecord.object(forKey: "passPhrase") != nil
        {
            passPhrase = sourceRecord.object(forKey: "passPhrase") as! String
        }
        
        var email: String = ""
        if sourceRecord.object(forKey: "email") != nil
        {
            email = sourceRecord.object(forKey: "email") as! String
        }
        
        let returnUserEntry = returnUser(
            userID: storedUserID,
            name: name,
            passPhrase: passPhrase,
            phraseDate: phraseDate,
            email: email,
            personID: personID)

        returnUserArray.append(returnUserEntry)
    }
    
    func retrieveUserList() -> [returnUser]
    {
        return returnUserArray
    }
    
    func validateUser(email: String, passPhrase: String)
    {
        returnUserArray.removeAll()
        
        let predicate = NSPredicate(format: "(email == \"\(email)\") AND (passPhrase == \"\(passPhrase)\") AND (%@ != phraseDate) AND (%@ <= phraseDate) AND (updateType != \"Delete\")", getDefaultDate() as CVarArg, Date() as CVarArg) // better be accurate to get only the record you need
        let query = CKQuery(recordType: "DBUsers", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.processUserList(record)
            usleep(self.sleepTime)
        }
        
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "DBUsers", queryOperation: operation, onOperationQueue: operationQueue, notification: NotificationValidateUser)
    }
}

