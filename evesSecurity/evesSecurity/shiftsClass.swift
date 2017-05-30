//
//  shiftsClass.swift
//  evesSecurity
//
//  Created by Garry Eves on 11/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

struct mergedShiftList
{
    var contract: String!
    var projectID: Int!
    var description: String!
    var WEDate: Date!
    var shiftLineID: Int!
    var monShift: shift!
    var tueShift: shift!
    var wedShift: shift!
    var thuShift: shift!
    var friShift: shift!
    var satShift: shift!
    var sunShift: shift!
    var type: String!
}

class shifts: NSObject
{
    fileprivate var myShifts:[shift] = Array()
    fileprivate var myWeeklyShifts:[mergedShiftList] = Array()
    
    init(teamID: Int, WEDate: Date, type: String)
    {
        super.init()
        
        myWeeklyShifts.removeAll()
        
        for myItem in myDatabaseConnection.getShifts(teamID: teamID, WEDate: WEDate, type: type)
        {
            let myObject = shift(shiftID: Int(myItem.shiftID),
                                 projectID: Int(myItem.projectID),
                                 personID: Int(myItem.personID),
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime! as Date,
                                 endTime: myItem.endTime! as Date,
                                 teamID: Int(myItem.teamID),
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: Int(myItem.shiftLineID),
                                 rateID: Int(myItem.rateID),
                                 type: myItem.type!,
                                 clientInvoiceNumber: Int(myItem.clientInvoiceNumber),
                                 personInvoiceNumber: Int(myItem.personInvoiceNumber)
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(teamID: Int, WEDate: Date, includeEvents: Bool = false)
    {
        super.init()
        
        myWeeklyShifts.removeAll()
        
        for myItem in myDatabaseConnection.getShifts(teamID: teamID, WEDate: WEDate, includeEvents: includeEvents)
        {
            let myObject = shift(shiftID: Int(myItem.shiftID),
                                 projectID: Int(myItem.projectID),
                                 personID: Int(myItem.personID),
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime! as Date,
                                 endTime: myItem.endTime! as Date,
                                 teamID: Int(myItem.teamID),
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: Int(myItem.shiftLineID),
                                 rateID: Int(myItem.rateID),
                                 type: myItem.type!,
                                 clientInvoiceNumber: Int(myItem.clientInvoiceNumber),
                                 personInvoiceNumber: Int(myItem.personInvoiceNumber)
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(projectID: Int, month: String, year: String)
    {
        super.init()
        
        myWeeklyShifts.removeAll()
        
        for myItem in myDatabaseConnection.getShifts(projectID: projectID, month: month, year: year)
        {
            let myObject = shift(shiftID: Int(myItem.shiftID),
                                 projectID: Int(myItem.projectID),
                                 personID: Int(myItem.personID),
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime! as Date,
                                 endTime: myItem.endTime! as Date,
                                 teamID: Int(myItem.teamID),
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: Int(myItem.shiftLineID),
                                 rateID: Int(myItem.rateID),
                                 type: myItem.type!,
                                 clientInvoiceNumber: Int(myItem.clientInvoiceNumber),
                                 personInvoiceNumber: Int(myItem.personInvoiceNumber)
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }

    init(personID: Int, searchFrom: Date, searchTo: Date, teamID: Int, type: String)
    {
        super.init()
        
        myWeeklyShifts.removeAll()

        for myItem in myDatabaseConnection.getShifts(personID: personID, searchFrom: searchFrom, searchTo: searchTo, teamID: teamID, type: type)
        {
            let myObject = shift(shiftID: Int(myItem.shiftID),
                                 projectID: Int(myItem.projectID),
                                 personID: Int(myItem.personID),
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime! as Date,
                                 endTime: myItem.endTime! as Date,
                                 teamID: Int(myItem.teamID),
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: Int(myItem.shiftLineID),
                                 rateID: Int(myItem.rateID),
                                 type: myItem.type!,
                                 clientInvoiceNumber: Int(myItem.clientInvoiceNumber),
                                 personInvoiceNumber: Int(myItem.personInvoiceNumber)

                                   )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(projectID: Int, searchFrom: Date, searchTo: Date, teamID: Int, type: String)
    {
        super.init()
        
        myWeeklyShifts.removeAll()

        for myItem in myDatabaseConnection.getShifts(projectID: projectID, searchFrom: searchFrom, searchTo: searchTo, teamID: teamID, type: type)
        {
            let myObject = shift(shiftID: Int(myItem.shiftID),
                                 projectID: Int(myItem.projectID),
                                 personID: Int(myItem.personID),
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime! as Date,
                                 endTime: myItem.endTime! as Date,
                                 teamID: Int(myItem.teamID),
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: Int(myItem.shiftLineID),
                                 rateID: Int(myItem.rateID),
                                 type: myItem.type!,
                                 clientInvoiceNumber: Int(myItem.clientInvoiceNumber),
                                 personInvoiceNumber: Int(myItem.personInvoiceNumber)

            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(projectID: Int)
    {
        super.init()
        
        myWeeklyShifts.removeAll()
        
        for myItem in myDatabaseConnection.getShifts(projectID: projectID)
        {
            let myObject = shift(shiftID: Int(myItem.shiftID),
                                 projectID: Int(myItem.projectID),
                                 personID: Int(myItem.personID),
                                 workDate: myItem.workDate! as Date,
                                 shiftDescription: myItem.shiftDescription!,
                                 startTime: myItem.startTime! as Date,
                                 endTime: myItem.endTime! as Date,
                                 teamID: Int(myItem.teamID),
                                 weekEndDate: myItem.weekEndDate! as Date,
                                 status: myItem.status!,
                                 shiftLineID: Int(myItem.shiftLineID),
                                 rateID: Int(myItem.rateID),
                                 type: myItem.type!,
                                 clientInvoiceNumber: Int(myItem.clientInvoiceNumber),
                                 personInvoiceNumber: Int(myItem.personInvoiceNumber)
                
            )
            myShifts.append(myObject)
        }
        
        if myShifts.count > 0
        {
            createWeeklyArray()
        }
        
        sortArray()
    }
    
    init(query: String, teamID: Int)
    {
        super.init()
        
        var returnArray: [Shifts]!
        
        myShifts.removeAll()
        
        switch query
        {
            case "shifts no person or rate":
                returnArray = myDatabaseConnection.getShiftsNoPersonOrRate(teamID: teamID)
                
            case "shifts no person":
                returnArray = myDatabaseConnection.getShiftsNoPerson(teamID: teamID)
                
            case "shifts no rate":
                returnArray = myDatabaseConnection.getShiftsNoRate(teamID: teamID)
                
            default:
                let _ = 1
        }
        
        if returnArray != nil
        {
            for myItem in returnArray
            {
                let myObject = shift(shiftID: Int(myItem.shiftID),
                                     projectID: Int(myItem.projectID),
                                     personID: Int(myItem.personID),
                                     workDate: myItem.workDate! as Date,
                                     shiftDescription: myItem.shiftDescription!,
                                     startTime: myItem.startTime! as Date,
                                     endTime: myItem.endTime! as Date,
                                     teamID: Int(myItem.teamID),
                                     weekEndDate: myItem.weekEndDate! as Date,
                                     status: myItem.status!,
                                     shiftLineID: Int(myItem.shiftLineID),
                                     rateID: Int(myItem.rateID),
                                     type: myItem.type!,
                                     clientInvoiceNumber: Int(myItem.clientInvoiceNumber),
                                     personInvoiceNumber: Int(myItem.personInvoiceNumber)
                    
                )
                myShifts.append(myObject)
            }
            
            if myShifts.count > 0
            {
                createWeeklyArray()
            }
            
            sortArray()
        }
    }
    
    private func sortArray()
    {
        if myShifts.count > 0
        {
            myShifts.sort
                {
                    // Because workdate has time it throws everything out
                    
                    if $0.workDate == $1.workDate
                    {
                        return $0.shiftDescription < $1.shiftDescription
                    }
                    else
                    {
                        return $0.workDate < $1.workDate
                    }
            }
        }
    }
    
    private func createWeeklyArray()
    {
        // sort the array by week, contract, line ID
        
        if myShifts.count > 0
        {
            myShifts.sort
            {
                // Because workdate has time it throws everything out
                
                if $0.projectID == $1.projectID
                {
                    if $0.shiftLineID == $1.shiftLineID
                    {
                        return $0.workDate < $1.workDate
                    }
                    else
                    {
                        return $0.shiftLineID < $1.shiftLineID
                    }
                }
                else
                {
                    return $0.projectID < $1.projectID
                }
            }
        }
        
        // now we iterate through the array and build the weekly array
        var contract: String!
        var projectID: Int!
        var description: String!
        var WEDate: Date!
        var shiftLineID: Int!
        var type: String!
        
        var monShift: shift!
        var tueShift: shift!
        var wedShift: shift!
        var thuShift: shift!
        var friShift: shift!
        var satShift: shift!
        var sunShift: shift!
        
        for myItem in myShifts
        {
            if shiftLineID != nil
            {
                if shiftLineID != myItem.shiftLineID
                {
                    // Thus is a new week
                    let tempShift = mergedShiftList(contract: contract,
                                                    projectID: projectID,
                                                    description: description,
                                                    WEDate: WEDate,
                                                    shiftLineID: shiftLineID,
                                                    monShift: monShift,
                                                    tueShift: tueShift,
                                                    wedShift: wedShift,
                                                    thuShift: thuShift,
                                                    friShift: friShift,
                                                    satShift: satShift,
                                                    sunShift: sunShift,
                                                    type: type
                                                   )

                    myWeeklyShifts.append(tempShift)
                    
                    let myContract = project(projectID: myItem.projectID)
                    contract = myContract.projectName
                    projectID = myItem.projectID
                    description = myItem.shiftDescription
                    WEDate = myItem.weekEndDate
                    shiftLineID = myItem.shiftLineID
                    type = myItem.type
                    
                    monShift = nil
                    tueShift = nil
                    wedShift = nil
                    thuShift = nil
                    friShift = nil
                    satShift = nil
                    sunShift = nil
                }
            }
            else
            {
                let myContract = project(projectID: myItem.projectID)
                contract = myContract.projectName
                projectID = myItem.projectID
                description = myItem.shiftDescription
                WEDate = myItem.weekEndDate
                shiftLineID = myItem.shiftLineID
                type = myItem.type
            }
            
            switch myItem.dayOfWeekNumber
            {
                case 1: // Sun
                    sunShift = myItem

                case 2: // Mon
                    monShift = myItem
                    
                case 3: // Tue
                    tueShift = myItem
                    
                case 4: // Wed
                    wedShift = myItem
                    
                case 5: // Thu
                    thuShift = myItem
                    
                case 6: // Fri
                    friShift = myItem
                    
                case 7: // Sat
                    satShift = myItem
                    
                default: print("Shift createWeeklyArray hit default - value = \(myItem.dayOfWeekNumber)")

            }
        }
        
        let tempShift = mergedShiftList(contract: contract,
                                        projectID: projectID,
                                        description: description,
                                        WEDate: WEDate,
                                        shiftLineID: shiftLineID,
                                        monShift: monShift,
                                        tueShift: tueShift,
                                        wedShift: wedShift,
                                        thuShift: thuShift,
                                        friShift: friShift,
                                        satShift: satShift,
                                        sunShift: sunShift,
                                        type: type
        )
        
        myWeeklyShifts.append(tempShift)
    }
    
    var shifts: [shift]
    {
        get
        {
            return myShifts
        }
    }
    
    var weeklyShifts: [mergedShiftList]
    {
        get
        {
            return myWeeklyShifts
        }
    }
}

class shift: NSObject
{
    fileprivate var myShiftID: Int = 0
    fileprivate var myProjectID: Int = 0
    fileprivate var myPersonID: Int = 0
    fileprivate var myWorkDate: Date!
    fileprivate var myShiftDescription: String = ""
    fileprivate var myStartTime: Date!
    fileprivate var myEndTime: Date!
    fileprivate var myWeekEndDate: Date!
    fileprivate var myTeamID: Int = 0
    fileprivate var myStatus: String = ""
    fileprivate var myShiftLineID: Int = 0
    fileprivate var myRateID: Int = 0
    fileprivate var myType: String = ""
    fileprivate var myClientInvoiceNumber = 0
    fileprivate var myPersonInvoiceNumber = 0
    
    var shiftID: Int
    {
        get
        {
            return myShiftID
        }
    }
    
    var shiftLineID: Int
    {
        get
        {
            return myShiftLineID
        }
    }
    
    var projectID: Int
    {
        get
        {
            return myProjectID
        }
    }
    
    var type: String
    {
        get
        {
            return myType
        }
        set
        {
            myType = newValue
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
    
    var personName: String
    {
        get
        {
            if myPersonID == 0
            {
                return "Select Person"
            }
            else
            {
                return person(personID: myPersonID).name
            }
        }
    }
    
    var rateID: Int
    {
        get
        {
            return myRateID
        }
        set
        {
            myRateID = newValue
        }
    }
    
    var rateDescription: String
    {
        get
        {
            if myRateID == 0
            {
                return "Select Rate"
            }
            else
            {
                return rate(rateID: myRateID).rateName
            }
        }
    }
    
    var status: String
    {
        get
        {
            return myStatus
        }
        set
        {
            myStatus = newValue
        }
    }
    
    var workDate: Date
    {
        get
        {
            return myWorkDate
        }
    }
    
    var workDateString: String
    {
        get
        {
            return formatDateToString(myWorkDate)
        }
    }
    
    var dayOfWeek: String
    {
        get
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E"
            return dateFormatter.string(from: myWorkDate)
        }
    }
    
    var dayOfWeekNumber: Int
    {
        get
        {
            let myCalendar = Calendar(identifier: .gregorian)
            let weekDay = myCalendar.component(.weekday, from: myWorkDate)
            return weekDay
        }
    }
    
    var shiftDescription: String
    {
        get
        {
            return myShiftDescription
        }
        set
        {
            myShiftDescription = newValue
        }
    }
    
    var startTime: Date
    {
        get
        {
            return myStartTime
        }
        set
        {
            myStartTime = newValue
        }
    }
    
    var startTimeString: String
    {
        get
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: myStartTime)
        }
    }
    
    var endTime: Date
    {
        get
        {
            return myEndTime
        }
        set
        {
            myEndTime = newValue
        }
    }
    
    var endTimeString: String
    {
        get
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: endTime)
        }
    }
    
    var weekEndDate: Date
    {
        get
        {
            return myWeekEndDate
        }
    }
    
    var clientInvoiceNumber: Int
    {
        get
        {
            return myClientInvoiceNumber
        }
        set
        {
            myClientInvoiceNumber = newValue
        }
    }
    
    var personInvoiceNumber: Int
    {
        get
        {
            return myPersonInvoiceNumber
        }
        set
        {
            myPersonInvoiceNumber = newValue
        }
    }
    
    var numHours: Int
    {
        get
        {
            if startTime > endTime
            {
                // Start date is after endTime, so add 24 hours to end time (becuase of date handling
                
                let modifiedEndTime = Calendar.current.date(byAdding: .day, value: 1, to: endTime)!
                
                return dateDifferenceHours(startTime, to: modifiedEndTime)
            }
            else
            {
                return dateDifferenceHours(startTime, to: endTime)
            }
        }
    }
    
    var numMins: Double
    {
        get
        {
            var tempNum: Int = 0
            
            if startTime > endTime
            {
                // Start date is after endTime, so add 24 hours to end time (becuase of date handling
                
                let modifiedEndTime = Calendar.current.date(byAdding: .day, value: 1, to: endTime)!

                tempNum = dateDifferenceMinutes(startTime, to: modifiedEndTime)
            }
            else
            {
                tempNum = dateDifferenceMinutes(startTime, to: endTime)
            }
    
            if tempNum > 0 && tempNum < 16
            {
                return 0.25
            }
            else if tempNum > 15 && tempNum < 31
            {
                return 0.5
            }
            else if tempNum > 30 && tempNum < 46
            {
                return 0.75
            }
            else if tempNum > 45 && tempNum < 61
            {
                return 1
            }
            
            return 0
        }
    }
    
    var income: Double
    {
        get
        {
            if rateID == 0
            {
                return 0
            }
            else
            {
                // Go and get the rate
                
                let rateRecord = rate(rateID: rateID)
                
                if rateRecord.chargeAmount == 0
                {
                    return 0
                }
                else
                {
                    return calculateAmount(numHours: numHours, numMins: numMins, rate: rateRecord.chargeAmount)
                }
            }
            
        }
    }
    
    var expense: Double
    {
        get
        {
            if rateID == 0
            {
                return 0
            }
            else
            {
                // Go and get the rate
                
                let rateRecord = rate(rateID: rateID)
                
                if rateRecord.rateAmount == 0
                {
                    return 0
                }
                else
                {
                    return calculateAmount(numHours: numHours, numMins: numMins, rate: rateRecord.rateAmount)
                }
            }
        }
    }
    
    init(projectID: Int, workDate: Date, weekEndDate: Date, teamID: Int, shiftLineID: Int, type: String, saveToCloud: Bool = true)
    {
        super.init()
        
        myShiftID = myDatabaseConnection.getNextID("Shifts", saveToCloud: saveToCloud)
        myProjectID = projectID
        myTeamID = teamID
        myWeekEndDate = weekEndDate
        myStatus = "Open"
        myWorkDate = workDate
        myShiftLineID = shiftLineID
        myType = type
        
        save()
    }
    
    init(shiftID: Int)
    {
        super.init()
        let myReturn = myDatabaseConnection.getShiftDetails(shiftID)
        
        for myItem in myReturn
        {
            myShiftID = Int(myItem.shiftID)
            myProjectID = Int(myItem.projectID)
            myPersonID = Int(myItem.personID)
            myWorkDate = myItem.workDate! as Date
            myShiftDescription = myItem.shiftDescription!
            myStartTime = myItem.startTime! as Date
            myEndTime = myItem.endTime! as Date
            myTeamID = Int(myItem.teamID)
            myWeekEndDate = myItem.weekEndDate! as Date
            myStatus = myItem.status!
            myShiftLineID = Int(myItem.shiftLineID)
            myRateID = Int(myItem.rateID)
            myType = myItem.type!
            myClientInvoiceNumber = Int(myItem.clientInvoiceNumber)
            myPersonInvoiceNumber = Int(myItem.personInvoiceNumber)
        }
    }
    
    init(shiftID: Int,
         projectID: Int,
         personID: Int,
         workDate: Date,
         shiftDescription: String,
         startTime: Date,
         endTime: Date,
         teamID: Int,
         weekEndDate: Date,
         status: String,
         shiftLineID: Int,
         rateID: Int,
         type: String,
         clientInvoiceNumber: Int,
         personInvoiceNumber: Int
         )
    {
        super.init()
        
        myShiftID = shiftID
        myProjectID = projectID
        myPersonID = personID
        myWorkDate = workDate
        myShiftDescription = shiftDescription
        myStartTime = startTime
        myEndTime = endTime
        myTeamID = teamID
        myWeekEndDate = weekEndDate
        myStatus = status
        myShiftLineID = shiftLineID
        myRateID = rateID
        myType = type
        myClientInvoiceNumber = clientInvoiceNumber
        myPersonInvoiceNumber = personInvoiceNumber
    }
    
    func save()
    {
        if myStartTime != nil && myEndTime != nil
        {
            myDatabaseConnection.saveShifts(myShiftID,
                                            projectID: myProjectID,
                                            personID: myPersonID,
                                            workDate: myWorkDate,
                                            shiftDescription: myShiftDescription,
                                            startTime: myStartTime,
                                            endTime: myEndTime,
                                            teamID: myTeamID,
                                            weekEndDate: myWeekEndDate,
                                            status: myStatus,
                                            shiftLineID: myShiftLineID,
                                            rateID: myRateID,
                                            type: myType,
                                            clientInvoiceNumber: myClientInvoiceNumber,
                                            personInvoiceNumber: myPersonInvoiceNumber
                                             )
        }
    }
    
    func delete()
    {
        myDatabaseConnection.deleteShifts(myShiftID)
    }
}

extension team
{
    var reportingMonths: [String]
    {
        get
        {
            var returnArray: [String] = Array()
            var workingArray: [Int] = Array()
            
            for myItem in myDatabaseConnection.getShifts(teamID: teamID)
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM"
                
                let month = dateFormatter.string(from: myItem.workDate! as Date)
                
                let monthInt = Int(month)
                
                var found: Bool = false
                
                for myMonth in workingArray
                {
                    if myMonth == monthInt
                    {
                        found = true
                        break
                    }
                }
                
                if !found
                {
                    workingArray.append(monthInt!)
                }
            }
            
            // Now we have all the entries sort into numerical ascending order
            
            if workingArray.count > 0
            {
                workingArray.sort { $0 < $1 }
            }
            
            // Now Convert to Month Names
            
            for myItem in workingArray
            {
                switch myItem
                {
                    case 1:
                        returnArray.append("January")
                        
                    case 2:
                        returnArray.append("February")
                        
                    case 3:
                        returnArray.append("March")

                    case 4:
                        returnArray.append("April")

                    case 5:
                        returnArray.append("May")

                    case 6:
                        returnArray.append("June")

                    case 7:
                        returnArray.append("July")

                    case 8:
                        returnArray.append("August")

                    case 9:
                        returnArray.append("September")

                    case 10:
                        returnArray.append("October")

                    case 11:
                        returnArray.append("November")
                    
                    case 12:
                        returnArray.append("December")
                    
                    default:
                        print("Teams reportingMonths - got unexpected month - myItem")
                }
                
            }
            
            return returnArray
        }
    }
}

extension projects
{
    func loadFinancials(month: String, year: String)
    {
        // Need to get the
        
        // get the projects for the team
        
        for workingProject in projects
        {
            workingProject.loadFinancials(month: month, year: year)
        }
    }
}

extension project
{
    func loadFinancials(month: String = "", year: String = "")
    {
        var financeArray: [monthlyFinancialsStruct] = Array()
        
        if month == ""
        {
            // Going to get all financials
print("GRE - Do project loadFinancials for all")
     
            
            
        }
        else
        {
            let shiftArray = shifts(projectID: projectID, month: month, year: year)
            
            financeArray.append(processMonth(shiftArray: shiftArray, month: month, year: year))
        }

        financials = financeArray
    }
    
    private func processMonth(shiftArray: shifts, month: String, year: String) -> monthlyFinancialsStruct
    {
        var income: Double = 0.0
        var expenditure: Double = 0.0
        var hours: Double = 0.0
        
        for myItem in shiftArray.shifts
        {
            income += myItem.income
            expenditure += myItem.expense
            hours += Double(myItem.numHours)
            hours += myItem.numMins
            
//            print("GRE - date = \(myItem.workDate) - start \(myItem.startTimeString) End - \(myItem.endTimeString) hours \(myItem.numHours):\(myItem.numMins)")
//            print("")
//            print("GRE - expense \(myItem.expense)    income \(myItem.income)")
//            print("")
        }
        
        return monthlyFinancialsStruct(
            month: month,
            year: year,
            income: income,
            expense: expenditure,
            hours: hours
        )
    }
}

extension coreDatabase
{
    func saveShifts(_ shiftID: Int,
                    projectID: Int,
                    personID: Int,
                    workDate: Date,
                    shiftDescription: String,
                    startTime: Date,
                    endTime: Date,
                    teamID: Int,
                    weekEndDate: Date,
                    status: String,
                    shiftLineID: Int,
                    rateID: Int,
                    type: String,
                    clientInvoiceNumber: Int,
                    personInvoiceNumber: Int,
                     updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Shifts!
        
        // get the current calendar
        let calendar = Calendar.current
        // get the start of the day of the selected date
        let adjustedWorkDate = calendar.startOfDay(for: workDate)
        // get the start of the day of the selected date
        let adjustedWEDate = calendar.startOfDay(for: weekEndDate)
        
        let myReturn = getShiftDetails(shiftID)
        
        if myReturn.count == 0
        { // Add
            myItem = Shifts(context: objectContext)
            myItem.shiftID = Int64(shiftID)
            myItem.projectID = Int64(projectID)
            myItem.personID = Int64(personID)
            myItem.workDate = adjustedWorkDate as NSDate
            myItem.shiftDescription = shiftDescription
            myItem.startTime = startTime as NSDate
            myItem.endTime = endTime as NSDate
            myItem.teamID = Int64(teamID)
            myItem.weekEndDate = adjustedWEDate as NSDate
            myItem.status = status
            myItem.shiftLineID = Int64(shiftLineID)
            myItem.rateID = Int64(rateID)
            myItem.type = type
            myItem.clientInvoiceNumber = Int64(clientInvoiceNumber)
            myItem.personInvoiceNumber = Int64(personInvoiceNumber)
            
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
            myItem.personID = Int64(personID)
            myItem.shiftDescription = shiftDescription
            myItem.startTime = startTime as NSDate
            myItem.endTime = endTime as NSDate
            myItem.status = status
            myItem.shiftLineID = Int64(shiftLineID)
            myItem.rateID = Int64(rateID)
            myItem.type = type
            myItem.clientInvoiceNumber = Int64(clientInvoiceNumber)
            myItem.personInvoiceNumber = Int64(personInvoiceNumber)

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
    
    func replaceShifts(_ shiftID: Int,
                       projectID: Int,
                       personID: Int,
                       workDate: Date,
                       shiftDescription: String,
                       startTime: Date,
                       endTime: Date,
                       teamID: Int,
                       weekEndDate: Date,
                       status: String,
                       shiftLineID: Int,
                       rateID: Int,
                       type: String,
                       clientInvoiceNumber: Int,
                       personInvoiceNumber: Int,
                        updateTime: Date =  Date(), updateType: String = "CODE")
    {
        // get the current calendar
        let calendar = Calendar.current
        // get the start of the day of the selected date
        let adjustedWorkDate = calendar.startOfDay(for: workDate)
        // get the start of the day of the selected date
        let adjustedWEDate = calendar.startOfDay(for: weekEndDate)
        
        let myItem = Shifts(context: objectContext)
        myItem.shiftID = Int64(shiftID)
        myItem.projectID = Int64(projectID)
        myItem.personID = Int64(personID)
        myItem.workDate = adjustedWorkDate as NSDate
        myItem.shiftDescription = shiftDescription
        myItem.startTime = startTime as NSDate
        myItem.endTime = endTime as NSDate
        myItem.teamID = Int64(teamID)
        myItem.weekEndDate = adjustedWEDate as NSDate
        myItem.status = status
        myItem.shiftLineID = Int64(shiftLineID)
        myItem.rateID = Int64(rateID)
        myItem.type = type
        myItem.clientInvoiceNumber = Int64(clientInvoiceNumber)
        myItem.personInvoiceNumber = Int64(personInvoiceNumber)

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
    
    func deleteShifts(_ shiftID: Int)
    {
        let myReturn = getShiftDetails(shiftID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getShifts(teamID: Int)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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
    
    func getShifts(teamID: Int, WEDate: Date, type: String)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // get the current calendar
        let calendar = Calendar.current
        // get the start of the day of the selected date
        let startDate = calendar.startOfDay(for: WEDate)
        // get the start of the day after the selected date
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(weekEndDate >= %@) AND (weekEndDate <= %@) AND (teamID == \(teamID)) AND (type == \"\(type)\") AND (updateType != \"Delete\")", startDate as CVarArg, endDate as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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
    
    func getShifts(teamID: Int, WEDate: Date, includeEvents: Bool)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // get the current calendar
        let calendar = Calendar.current
        // get the start of the day of the selected date
        let startDate = calendar.startOfDay(for: WEDate)
        // get the start of the day after the selected date
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        if includeEvents
        {
            predicate = NSPredicate(format: "(weekEndDate >= %@) AND (weekEndDate <= %@) AND (teamID == \(teamID)) AND (updateType != \"Delete\")", startDate as CVarArg, endDate as CVarArg)
        }
        else
        {
            predicate = NSPredicate(format: "(weekEndDate >= %@) AND (weekEndDate <= %@) AND (teamID == \(teamID)) AND (type != \"\(eventShiftType)\") AND (updateType != \"Delete\")", startDate as CVarArg, endDate as CVarArg)
        }
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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
    
    func getShifts(projectID: Int, month: String, year: String)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // get the current calendar
        let calendar = Calendar.current
        // get the start of the day of the selected date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        let dateString = "01 \(month) \(year)"
        let calculatedDate = dateFormatter.date(from: dateString)
        
        let startDate = calendar.startOfDay(for: calculatedDate!)
        // get the start of the day after the selected date
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(workDate >= %@) AND (workDate < %@) AND (projectID == \(projectID)) AND (updateType != \"Delete\")", startDate as CVarArg, endDate as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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

    
    func getShifts(personID: Int, searchFrom: Date, searchTo: Date, teamID: Int, type: String)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(personID == \(personID)) AND (workDate >= %@) AND (workDate <= %@) AND (teamID == \(teamID)) AND (type == \"\(type)\") AND (updateType != \"Delete\")", searchFrom as CVarArg, searchTo as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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
    
    func getShifts(projectID: Int, searchFrom: Date, searchTo: Date, teamID: Int, type: String)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (workDate >= %@) AND (workDate <= %@) AND (teamID == \(teamID)) AND (type == \"\(type)\") AND (updateType != \"Delete\")", searchFrom as CVarArg, searchTo as CVarArg)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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
    
    func getShifts(projectID: Int)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(projectID == \(projectID)) AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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
    
    func getShiftForRate(rateID: Int, type: String)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(rateID == \(rateID)) AND (type == \"\(type)\") AND (updateType != \"Delete\")")
        
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

    func getShiftsNoPersonOrRate(teamID: Int)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(personID == 0) AND (rateID == 0) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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

    func getShiftsNoPerson(teamID: Int)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(personID == 0) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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
    
    func getShiftsNoRate(teamID: Int)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(rateID == 0) AND (teamID == \(teamID)) AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "workDate", ascending: true)
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
    
    func getShiftDetails(_ shiftID: Int)->[Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(shiftID == \(shiftID)) && (updateType != \"Delete\")")
        
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
    
    func resetAllShifts()
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
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
    
    func clearDeletedShifts(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Shifts>(entityName: "Shifts")
        
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
    
    func clearSyncedShifts(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Shifts>(entityName: "Shifts")
        
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
    
    func getShiftsForSync(_ syncDate: Date) -> [Shifts]
    {
        let fetchRequest = NSFetchRequest<Shifts>(entityName: "Shifts")
        
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
    
    func deleteAllShifts()
    {
        let fetchRequest2 = NSFetchRequest<Shifts>(entityName: "Shifts")
        
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
    
    func quickFixShifts()
    {        
        let fetchRequest2 = NSFetchRequest<Shifts>(entityName: "Shifts")
        
        let predicate = NSPredicate(format: "(type == nil)")
        
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
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
}

extension CloudKitInteraction
{
    func saveShiftsToCloudKit()
    {
        for myItem in myDatabaseConnection.getShiftsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Shifts"))
        {
            saveShiftsRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateShiftsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "Shifts") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "Shifts", predicate: predicate)
        
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
            
            self.updateShiftsRecord(record)
            self.recordCount -= 1
            
//            usleep(self.sleepTime)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Shifts", queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }
    
    func deleteShifts(shiftID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (shiftID == \(shiftID))")
        let query: CKQuery = CKQuery(recordType: "Shifts", predicate: predicate)
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
    
    func replaceShiftsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID))")
        let query: CKQuery = CKQuery(recordType: "Shifts", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let shiftDescription = record.object(forKey: "shiftDescription") as! String
            let status = record.object(forKey: "status") as! String
            let type = record.object(forKey: "type") as! String
            
            var shiftID: Int = 0
            if record.object(forKey: "shiftID") != nil
            {
                shiftID = record.object(forKey: "shiftID") as! Int
            }

            var rateID: Int = 0
            if record.object(forKey: "rateID") != nil
            {
                rateID = record.object(forKey: "rateID") as! Int
            }
            
            var shiftLineID: Int = 0
            if record.object(forKey: "shiftLineID") != nil
            {
                shiftLineID = record.object(forKey: "shiftLineID") as! Int
            }
            
            var projectID: Int = 0
            if record.object(forKey: "projectID") != nil
            {
                projectID = record.object(forKey: "projectID") as! Int
            }

            var personID: Int = 0
            if record.object(forKey: "personID") != nil
            {
                personID = record.object(forKey: "personID") as! Int
            }
            
            var workDate = Date()
            if record.object(forKey: "workDate") != nil
            {
                workDate = record.object(forKey: "workDate") as! Date
            }
            
            var startTime = Date()
            if record.object(forKey: "startTime") != nil
            {
                startTime = record.object(forKey: "startTime") as! Date
            }
            
            var endTime = Date()
            if record.object(forKey: "endTime") != nil
            {
                endTime = record.object(forKey: "endTime") as! Date
            }
            
            var weekEndDate = Date()
            if record.object(forKey: "weekEndDate") != nil
            {
                weekEndDate = record.object(forKey: "weekEndDate") as! Date
            }
            
            var teamID: Int = 0
            if record.object(forKey: "teamID") != nil
            {
                teamID = record.object(forKey: "teamID") as! Int
            }

            var clientInvoiceNumber: Int = 0
            if record.object(forKey: "clientInvoiceNumber") != nil
            {
                clientInvoiceNumber = record.object(forKey: "clientInvoiceNumber") as! Int
            }

            var personInvoiceNumber: Int = 0
            if record.object(forKey: "personInvoiceNumber") != nil
            {
                personInvoiceNumber = record.object(forKey: "personInvoiceNumber") as! Int
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
            
            myDatabaseConnection.replaceShifts(shiftID,
                                               projectID: projectID,
                                               personID: personID,
                                               workDate: workDate,
                                               shiftDescription: shiftDescription,
                                               startTime: startTime,
                                               endTime: endTime,
                                               teamID: teamID,
                                               weekEndDate: weekEndDate,
                                               status: status,
                                               shiftLineID: shiftLineID,
                                               rateID: rateID,
                                               type: type,
                                               clientInvoiceNumber: clientInvoiceNumber,
                                               personInvoiceNumber: personInvoiceNumber
                                                , updateTime: updateTime, updateType: updateType)
            
            usleep(self.sleepTime)
        }
        
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "Shifts", queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }
    
    func saveShiftsRecordToCloudKit(_ sourceRecord: Shifts, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        
        let predicate = NSPredicate(format: "(shiftID == \(sourceRecord.shiftID)) AND \(buildTeamList(currentUser.userID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Shifts", predicate: predicate)
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
 
                    record!.setValue(sourceRecord.personID, forKey: "personID")
                    record!.setValue(sourceRecord.startTime, forKey: "startTime")
                    record!.setValue(sourceRecord.endTime, forKey: "endTime")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    record!.setValue(sourceRecord.shiftLineID, forKey: "shiftLineID")
                    record!.setValue(sourceRecord.rateID, forKey: "rateID")
                    record!.setValue(sourceRecord.type, forKey: "type")
                    record!.setValue(sourceRecord.clientInvoiceNumber, forKey: "clientInvoiceNumber")
                    record!.setValue(sourceRecord.personInvoiceNumber, forKey: "personInvoiceNumber")
                    
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
                    let record = CKRecord(recordType: "Shifts")
                    record.setValue(sourceRecord.shiftID, forKey: "shiftID")
                    record.setValue(sourceRecord.projectID, forKey: "projectID")
                    record.setValue(sourceRecord.personID, forKey: "personID")
                    record.setValue(sourceRecord.workDate, forKey: "workDate")
                    record.setValue(sourceRecord.shiftDescription, forKey: "shiftDescription")
                    record.setValue(sourceRecord.startTime, forKey: "startTime")
                    record.setValue(sourceRecord.endTime, forKey: "endTime")
                    record.setValue(sourceRecord.weekEndDate, forKey: "weekEndDate")
                    record.setValue(sourceRecord.status, forKey: "status")
                    record.setValue(sourceRecord.shiftLineID, forKey: "shiftLineID")
                    record.setValue(sourceRecord.rateID, forKey: "rateID")
                    record.setValue(sourceRecord.type, forKey: "type")
                    record.setValue(sourceRecord.clientInvoiceNumber, forKey: "clientInvoiceNumber")
                    record.setValue(sourceRecord.personInvoiceNumber, forKey: "personInvoiceNumber")

                    record.setValue(teamID, forKey: "teamID")
                    
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

    func updateShiftsRecord(_ sourceRecord: CKRecord)
    {
        let shiftDescription = sourceRecord.object(forKey: "shiftDescription") as! String
        let status = sourceRecord.object(forKey: "status") as! String
        let type = sourceRecord.object(forKey: "type") as! String

        var shiftID: Int = 0
        if sourceRecord.object(forKey: "shiftID") != nil
        {
            shiftID = sourceRecord.object(forKey: "shiftID") as! Int
        }
        
        var rateID: Int = 0
        if sourceRecord.object(forKey: "rateID") != nil
        {
            rateID = sourceRecord.object(forKey: "rateID") as! Int
        }
        
        var shiftLineID: Int = 0
        if sourceRecord.object(forKey: "shiftLineID") != nil
        {
            shiftLineID = sourceRecord.object(forKey: "shiftLineID") as! Int
        }
        
        var projectID: Int = 0
        if sourceRecord.object(forKey: "projectID") != nil
        {
            projectID = sourceRecord.object(forKey: "projectID") as! Int
        }
        
        var personID: Int = 0
        if sourceRecord.object(forKey: "personID") != nil
        {
            personID = sourceRecord.object(forKey: "personID") as! Int
        }
        
        var workDate = Date()
        if sourceRecord.object(forKey: "workDate") != nil
        {
            workDate = sourceRecord.object(forKey: "workDate") as! Date
        }
        
        var startTime = Date()
        if sourceRecord.object(forKey: "startTime") != nil
        {
            startTime = sourceRecord.object(forKey: "startTime") as! Date
        }
        
        var endTime = Date()
        if sourceRecord.object(forKey: "endTime") != nil
        {
            endTime = sourceRecord.object(forKey: "endTime") as! Date
        }

        var weekEndDate = Date()
        if sourceRecord.object(forKey: "weekEndDate") != nil
        {
            weekEndDate = sourceRecord.object(forKey: "weekEndDate") as! Date
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
        
        var clientInvoiceNumber: Int = 0
        if sourceRecord.object(forKey: "clientInvoiceNumber") != nil
        {
            clientInvoiceNumber = sourceRecord.object(forKey: "clientInvoiceNumber") as! Int
        }
        
        var personInvoiceNumber: Int = 0
        if sourceRecord.object(forKey: "personInvoiceNumber") != nil
        {
            personInvoiceNumber = sourceRecord.object(forKey: "personInvoiceNumber") as! Int
        }

        
        myDatabaseConnection.saveShifts(shiftID,
                                        projectID: projectID,
                                        personID: personID,
                                        workDate: workDate,
                                        shiftDescription: shiftDescription,
                                        startTime: startTime,
                                        endTime: endTime,
                                        teamID: teamID,
                                        weekEndDate: weekEndDate,
                                        status: status,
                                        shiftLineID: shiftLineID,
                                        rateID: rateID,
                                        type: type,
                                        clientInvoiceNumber: clientInvoiceNumber,
                                        personInvoiceNumber: personInvoiceNumber
                                         , updateTime: updateTime, updateType: updateType)
    }
}

