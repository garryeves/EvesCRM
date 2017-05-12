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
let NotificationUserCountQueryString = "NotificationUserCountQueryDone"
let NotificationUserCreated = Notification.Name("NotificationUserCreated")


class userItem: NSObject
{
    fileprivate var myUserID: Int32 = 0
    fileprivate var myRoles: userRoles!
    fileprivate var myTeams: [team] = Array()
    fileprivate var myAuthorised: Bool = false
    fileprivate var myName: String = ""
    fileprivate var myPhraseDate: Date = getDefaultDate()
    fileprivate var myPassPhrase: String = ""
    fileprivate var myCurrentTeam: team!
    
    fileprivate let defaultsName = "group.com.garryeves.EvesCRM"
    
    var userID: Int32
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
    
    init(userID: Int32)
    {
        super.init()

        notificationCenter.addObserver(self, selector: #selector(self.queryFinished), name: NotificationUserRetrieved, object: nil)
    }
    
    func userRetieved()
    {
        notificationCenter.removeObserver(NotificationUserRetrieved)
        
        let record = myCloudDB.getUserRecord()
        
        if record != nil
        {
            myUserID = record!.userID
            myName = record!.name
            myPhraseDate = record!.phraseDate
            myPassPhrase = record!.passPhrase
            
            loadTeams()
        }
    }
    
    override init()
    {
        super.init()
        
        // Create a new user
        
        notificationCenter.addObserver(self, selector: #selector(self.queryFinished), name: NotificationUserCountQueryDone, object: nil)
        
        myCloudDB.getUserCount()
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
        // once created populate private items
        populatePrivateDecodes()
        
        myAuthorised = true
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
            let teamObject = team(teamID: myItem.teamID)
            myTeams.append(teamObject)
        }
        
        if myTeams.count == 1
        {
            myCurrentTeam = myTeams[0]
        }
    }

    func save()
    {
        myCloudDB.saveUser(myUserID, name: myName, phraseDate: myPhraseDate, passPhrase: myPassPhrase)
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
    
    private func populatePrivateDecodes()
    {
        var decodeString = myDatabaseConnection.getDecodeValue("Calendar - Weeks before current date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Calendar - Weeks before current date", codeValue: "1", codeType: "stepper", decode_privacy: "Private")
        }
        
        decodeString = myDatabaseConnection.getDecodeValue("Calendar - Weeks after current date")
        
        if decodeString == ""
        {  // Nothing found so go and create
            myDatabaseConnection.updateDecodeValue("Calendar - Weeks after current date", codeValue: "4", codeType: "stepper", decode_privacy: "Private")
        }
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
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue, notification: NotificationUserCountQueryString)
    }
    
    func userCount() -> Int32
    {
        return recordsInTable
    }
    
    func createNewUser(_ userID: Int32)
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
    
    func getUser(_ userID: Int32)
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
                self.returnUserEntry = returnUser(
                    userID: record?.object(forKey: "userID") as! Int32,
                    name: record?.object(forKey: "name") as! String,
                    passPhrase: record?.object(forKey: "passPhrase") as! String,
                    phraseDate: record?.object(forKey: "phraseDate") as! Date)
                
                NotificationCenter.default.post(name: NotificationUserRetrieved, object: nil)
            }
        })
    }
    
    func getUserRecord() -> returnUser?
    {
        return returnUserEntry
    }

    func saveUser(_ userID: Int32, name: String, phraseDate: Date, passPhrase: String)
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

                    record!.setValue(userID, forKey: "userID")
                    record!.setValue(name, forKey: "name")
                    record!.setValue(phraseDate, forKey: "phraseDate")
                    record!.setValue(passPhrase, forKey: "passPhrase")

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
    
    func deleteUser(_ userID: Int32)
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
        
        sem.wait()    }
}

