//
//  CalendarDetails.swift
//  EvesCRM
//
//  Created by Garry Eves on 21/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import AddressBook
import EventKit
import CoreData
import CloudKit

class calendarItem
{
    fileprivate var myTitle: String = ""
    fileprivate var myStartDate: Date!
    fileprivate var myEndDate: Date!
    fileprivate var myRecurrence: Int = -1
    fileprivate var myRecurrenceFrequency: Int = -1
    fileprivate var myLocation: String = ""
    fileprivate var myStatus: Int = -1
    fileprivate var myType: Int = -1
    fileprivate var myRole: Int = -1
    fileprivate var myMeetingID: String = ""
    fileprivate var myEvent: EKEvent?
    fileprivate var myAttendees: [meetingAttendee] = Array()
    fileprivate var myChair: String = ""
    fileprivate var myMinutes: String = ""
    fileprivate var myPreviousMinutes: String = ""
    fileprivate var myNextMeeting: String = ""
    fileprivate var myMinutesType: String = ""
    fileprivate var myAgendaItems: [meetingAgendaItem] = Array()
    fileprivate var myTeamID: Int32 = 0

    // Seup Date format for display
    fileprivate var startDateFormatter = DateFormatter()
    fileprivate var endDateFormatter = DateFormatter()
    fileprivate var dateFormat = DateFormatter.Style.medium
    fileprivate var timeFormat = DateFormatter.Style.short
    
    // This is used in order to allow to identify unique instances of a repeating Event
    
    fileprivate var myUniqueIdentifier: String = ""
    
    // Flag to indicate if we have data saved in database as well
    
    fileprivate var mySavedData: Bool = false
    fileprivate var saveCalled: Bool = false

    init(event: EKEvent, attendee: EKParticipant?, teamID: Int32)
    {
        startDateFormatter.dateStyle = dateFormat
        startDateFormatter.timeStyle = timeFormat
        endDateFormatter.timeStyle = timeFormat
        
        myTeamID = teamID
        // Check to see if there is an existing entry for the meeting
        
        let mySavedValues = myDatabaseConnection.loadAgenda("\(event.calendarItemExternalIdentifier) Date: \(event.startDate)", teamID: myTeamID)
        
        if mySavedValues.count > 0
        {
            myEvent = event
            myTitle = mySavedValues[0].name!
            myStartDate = mySavedValues[0].startTime! as Date
            myEndDate = mySavedValues[0].endTime! as Date
            myLocation = mySavedValues[0].location!
            myPreviousMinutes = mySavedValues[0].previousMeetingID!
            myMeetingID = mySavedValues[0].meetingID!
            myChair = mySavedValues[0].chair!
            myMinutes = mySavedValues[0].minutes!
            myLocation = mySavedValues[0].location!
            myMinutesType = mySavedValues[0].minutesType!
            mySavedData = true
        }
        else
        {
            myEvent = event
            myTitle = event.title
            myStartDate = event.startDate
            myEndDate = event.endDate
            if event.location == nil
            {
                myLocation = ""
            }
            else
            {
                myLocation = event.location!
            }
        
            if event.recurrenceRules != nil
            {
                // This is a recurring event
                let myWorkingRecur: NSArray = event.recurrenceRules! as NSArray
            
                for myItem in myWorkingRecur
                {
                    myRecurrenceFrequency = (myItem as AnyObject).interval
                    let testFrequency: EKRecurrenceFrequency = (myItem as AnyObject).frequency
                    myRecurrence = testFrequency.rawValue
                }
            }
        }
        // Need to validate this works when displaying by person and also by project
        if attendee != nil
        {
            myStatus = attendee!.participantStatus.rawValue
            myType = attendee!.participantType.rawValue
        }
        
        loadAttendees()
        loadAgendaItems()
    }
    
    init(meetingAgenda: MeetingAgenda)
    {
        startDateFormatter.dateStyle = dateFormat
        startDateFormatter.timeStyle = timeFormat
        endDateFormatter.timeStyle = timeFormat
        
        myTitle = meetingAgenda.name!
        myStartDate = meetingAgenda.startTime as Date!
        myEndDate = meetingAgenda.endTime as Date!
        myLocation = meetingAgenda.location!
        myPreviousMinutes = meetingAgenda.previousMeetingID!
        myMeetingID = meetingAgenda.meetingID!
        myChair = meetingAgenda.chair!
        myMinutes = meetingAgenda.minutes!
        myLocation = meetingAgenda.location!
        myMinutesType = meetingAgenda.minutesType!
        myTeamID = meetingAgenda.teamID
        
        loadAttendees()
        loadAgendaItems()
    }
    
    init(meetingID: String, teamID: Int32)
    {
        myTeamID = teamID
        let mySavedValues = myDatabaseConnection.loadAgenda(meetingID, teamID: myTeamID)
        
        if mySavedValues.count > 0
        {
            myTitle = mySavedValues[0].name!
            myStartDate = mySavedValues[0].startTime! as Date
            myEndDate = mySavedValues[0].endTime! as Date
            myLocation = mySavedValues[0].location!
            myPreviousMinutes = mySavedValues[0].previousMeetingID!
            myMeetingID = mySavedValues[0].meetingID!
            myChair = mySavedValues[0].chair!
            myMinutes = mySavedValues[0].minutes!
            myLocation = mySavedValues[0].location!
            myMinutesType = mySavedValues[0].minutesType!
            mySavedData = true
        }

        startDateFormatter.dateStyle = dateFormat
        startDateFormatter.timeStyle = timeFormat
        endDateFormatter.timeStyle = timeFormat
        
        // We neeed to go and the the event details from the calendar, if they exist
        
        let nextEvent = iOSCalendar()
        
        nextEvent.loadCalendarForEvent(myMeetingID, startDate: myStartDate, teamID: myTeamID)
        
        if nextEvent.events.count == 0
        {
            // No event found, so do nothing else
        }
        else if nextEvent.events.count == 1
        {
            // only 1 found so set it
            myEvent = nextEvent.events[0]
        }
        else
        {
            // Multiple found, so find the one with the matching start date
            
            for myItem in nextEvent.events
            {
                if myItem.startDate == myStartDate
                {
                    myEvent = myItem
                }
            }
        }
        
        loadAttendees()
        loadAgendaItems()
    }

    var event: EKEvent?
    {
        get
        {
            return myEvent
        }
        set
        {
            myEvent = newValue
            myMeetingID = "\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)"
            save()
        }
    }
    
    var title: String
    {
        get
        {
            return myTitle
        }
        set
        {
            myTitle = newValue
            save()
        }
    }
    
    var startDate: Date
    {
        get
        {
            return myStartDate
        }
        set
        {
            myStartDate = newValue
            save()
        }
    }
    
    var displayStartDate: String
    {
        get
        {
            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
            return startDateFormatter.string(from: myStartDate)
        }
    }
    
    var displayScheduledDate: String
    {
        get
        {
            var myString: String = ""
            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
            
            myString = startDateFormatter.string(from: myStartDate)
            myString += " - "
            myString += endDateFormatter.string(from: myEndDate)
            
            return myString
        }
    }
    
    var endDate: Date
    {
        get
        {
            return myEndDate
        }
        set
        {
            myEndDate = newValue
            save()
        }
    }
    
    var displayEndDate: String
    {
        get
        {
            return endDateFormatter.string(from: myEndDate)
        }
    }
    
    var recurrence: Int
    {
        get
        {
            return myRecurrence
        }
        set
        {
            myRecurrence = newValue
            save()
        }
    }
    
    var displayRecurrence: String
    {
        get
        {
            let recurType = [
                "days",
                "weeks",
                "months",
                "year",
                "Unknown"
            ]
            
            return recurType[myRecurrence]
        }
    }
    
    var recurrenceFrequency: Int
    {
        get
        {
            return myRecurrenceFrequency
        }
        set
        {
            myRecurrenceFrequency = newValue
            save()
        }
    }

    var location: String
    {
        get
        {
            return myLocation
        }
        set
        {
            myLocation = newValue
            save()
        }
    }

    var status: Int
    {
        get
        {
            return myStatus
        }
        set
        {
            myStatus = newValue
            save()
        }
    }
    
    var displayStatus: String
    {
        get
        {
            let attendeeStatus = [
                "Unknown",
                "Pending",
                "Accepted",
                "Declined",
                "Tentative",
                "Delegated",
                "Completed",
                "In Process"
            ]
            return attendeeStatus[myStatus]
        }
    }
    
    var attendeeType: Int
    {
        get
        {
            return myType
        }
        set
        {
            myType = newValue
            save()
        }
    }
    
    var displayAttendeeType: String
    {
        get
        {
            let attendeeType = [
                "Unknown",
                "Person",
                "Room",
                "Resource",
                "Group"
            ]
            return attendeeType[myType]
        }
    }
    
    var attendees: [meetingAttendee]
    {
        get
        {
            return myAttendees
        }
    }
    
    var chair: String
    {
        get
        {
            return myChair
        }
        set
        {
            myChair = newValue
            save()
        }
    }

    var minutes: String
    {
        get
        {
            return myMinutes
        }
        set
        {
            myMinutes = newValue
            save()
        }
    }
    
    var previousMinutes: String
    {
        get
        {
            return myPreviousMinutes
        }
        set
        {            
            myPreviousMinutes = newValue
            save()
        }
    }
    
    var nextMeeting: String
    {
        get
        {
            // get the meeting record for the meeting that has this meetings ID as it previousMeetingID
            var retVal: String = ""
            
            if myMeetingID != ""
            {
                let myItems = myDatabaseConnection.loadPreviousAgenda(myMeetingID, teamID: myTeamID)
            
                for myItem in myItems
                {
                    retVal = myItem.meetingID!
                }
            }
            
            return retVal
        }
        set
        {
            myNextMeeting = newValue
        }
    }
    
    var meetingID: String
    {
        get
        {
            if myMeetingID != ""
            {
                return myMeetingID
            }
            else
            {
                myMeetingID = "\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)"
                return "\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)"
            }
        }
    }
    
    var minutesType: String
    {
        get
        {
            return myMinutesType
        }
        set
        {
            myMinutesType = newValue
            save()
        }
    }
    
    var agendaItems: [meetingAgendaItem]
    {
        get
        {
            return myAgendaItems
        }
    }

    var fullAgenda: [meetingAgendaItem]
    {
        get
        {
            var agendaArray: [meetingAgendaItem] = Array()
            // Add in Welcome
            
            let welcomeItem = meetingAgendaItem(rowType: "Welcome")
            agendaArray.append(welcomeItem)
            
            // Check for outstanding actions
            
            if myPreviousMinutes != ""
            { // Previous meeting exists
                // Does the previous meeting have any tasks
                let myData = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
                
                if myData.count > 0
                {  // There are tasks for the previous meeting
                    
                    let previousItem = meetingAgendaItem(rowType: "PreviousMinutes")
                    agendaArray.append(previousItem)
                }
                else
                {
                    let myOutstandingTasks = parsePastMeeting(myPreviousMinutes)
                    
                    if myOutstandingTasks.count > 0
                    {
                        let previousItem = meetingAgendaItem(rowType: "PreviousMinutes")
                        agendaArray.append(previousItem)
                    }
                }
            }
            
            // Add in Agenda Items
            
            for myItem in myAgendaItems
            {
                agendaArray.append(myItem)
            }
            
            // Add in Close
            let closeItem = meetingAgendaItem(rowType: "Close")
            agendaArray.append(closeItem)

            return agendaArray
        }
    }
    
    var teamID: Int32
    {
        get
        {
            return myTeamID
        }
        set
        {
            myTeamID = newValue
            save()
        }
    }
    
    func addAttendee(_ name: String, emailAddress: String, type: String, status: String)
    {
        // make sure we have saved the Agenda
        
        save()

        let attendee: meetingAttendee = meetingAttendee()
        attendee.name = name
        attendee.emailAddress = emailAddress
        attendee.type = type
        attendee.status = status
        attendee.meetingID = meetingID
        attendee.save()
        
        myAttendees.append(attendee)
    }
    
    fileprivate func initaliseAttendee(_ name: String, emailAddress: String, type: String, status: String)
    {
        let attendee: meetingAttendee = meetingAttendee()
        attendee.name = name
        attendee.emailAddress = emailAddress
        attendee.type = type
        attendee.status = status
        attendee.meetingID = meetingID
        
        myAttendees.append(attendee)
    }

    func removeAttendee(_ index: Int)
    {
        // we should know the index of the item we want to delete from the control, so only need its index in order to perform the required action
        myAttendees.remove(at: index)
        
        // Save Attendees
        
        myAttendees[index].delete()
    }
    
    func populateAttendeesFromInvite()
    {
        // Use this for the initial population of the attendees
        
        for attendee in event!.attendees!
        {
            if !attendee.isCurrentUser
            {
                // Is the Attendee is not the current user then we need to parse the email address
                
                // Split the URL string on : - to give an array, the second element is the email address
                
                let emailSplit = String(describing: attendee.url).components(separatedBy: ":")
                
                addAttendee(attendee.name!, emailAddress: emailSplit[1], type: "Participant", status: "Invited")
            }
        }
    }
    
    func save()
    {
        if myEvent != nil
        {
            myMeetingID = "\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)"
        }
        
        //  Here we save the Agenda details
        
        // Save Agenda details
  //      if mySavedData
 //       {
            myDatabaseConnection.saveAgenda(myMeetingID, previousMeetingID : myPreviousMinutes, name: myTitle, chair: myChair, minutes: myMinutes, location: myLocation, startTime: myStartDate, endTime: myEndDate, minutesType: myMinutesType, teamID: myTeamID)
//        }
//        else
//        {
//            myDatabaseConnection.saveAgenda(event!.eventIdentifier, previousMeetingID : event.previousMinutes, name: event.title, chair: event.chair, minutes: event.minutes, location: event.location, startTime: event.startDate as Date, endTime: event.endDate as Date, minutesType: event.minutesType, teamID: event.teamID)
//        }
        
        mySavedData = true

        
        if !saveCalled
        {
            saveCalled = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performSave), userInfo: nil, repeats: false)
        }
    }
    
    @objc func performSave()
    {
        // if this is for a repeating event then we need to add in the original startdate to the Notes
        let myAgenda = myDatabaseConnection.loadAgenda(myMeetingID, teamID: myTeamID)[0]
        
        myCloudDB.saveMeetingAgendaRecordToCloudKit(myAgenda, teamID: currentUser.currentTeam!.teamID)
        
        saveCalled = false
    }
    
    func loadAgenda()
    {
        // Used where the invite is no longer in the calendar, and also to load up historical items for the "minutes" views
        
        var mySavedValues: [MeetingAgenda]!
        if myMeetingID == ""
        {
            mySavedValues = myDatabaseConnection.loadAgenda("\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)", teamID: myTeamID)
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAgenda(myMeetingID, teamID: myTeamID)
        }
        
        if mySavedValues.count > 0
        {
            myPreviousMinutes = mySavedValues[0].previousMeetingID!
            myChair = mySavedValues[0].chair!
            myMinutes = mySavedValues[0].minutes!
            myMinutesType = mySavedValues[0].minutesType!
            mySavedData = true
        }
        
        loadAttendees()
        
        loadAgendaItems()
    }
    
    func loadAttendees()
    {
        var mySavedValues: [MeetingAttendees]!
        var inviteeFound: Bool = false
        var chairFound: Bool = false
        var minutesFound: Bool = false
        
        var tempName: String = ""
        var tempStatus: String = ""
        var tempEmail: String = ""
        var tempType: String = ""
        
        
        // Get all of the attendees
        
        if myMeetingID == ""
        {
            mySavedValues = myDatabaseConnection.loadAttendees("\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)")
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAttendees(myMeetingID)
        }
        
        myAttendees.removeAll(keepingCapacity: false)
        
        if myEvent == nil
        { // No calendar event has been loaded, so go straight from table
            for savedAttendee in mySavedValues
            {
                initaliseAttendee(savedAttendee.name!, emailAddress: savedAttendee.email!, type: savedAttendee.type!, status: savedAttendee.attendenceStatus!)
            }
        }
        else
        {
            if myStartDate.compare(Date()) == ComparisonResult.orderedDescending
            { // Start date is in the future, so we need to check the meeting invite attendeees
            
                if mySavedValues.count > 0
                {
                    for savedAttendee in mySavedValues
                    {
                        inviteeFound = false
                        tempName = savedAttendee.name!
                        tempStatus = savedAttendee.attendenceStatus!
                        tempEmail = savedAttendee.email!
                        tempType = savedAttendee.type!
                    
                        if myEvent!.hasAttendees
                        {
                            for invitee in myEvent!.attendees!
                            {
                                // Check to see if any "Invited" people are no longer on calendar invite, and if so remove from Agenda.
                
                                if invitee.name == tempName
                                {
                                    // Invitee found

                                    // Is the Attendee is not the current user then we need to parse the email address
                                        
                                    // Split the URL string on : - to give an array, the second element is the email address
                                    if !invitee.isCurrentUser
                                    {
                                        let emailSplit = String(describing: invitee.url).components(separatedBy: ":")

                                        initaliseAttendee(invitee.name!, emailAddress: emailSplit[1], type: "Participant", status: "Invited")
             
                                        inviteeFound = true
                    
                                        break
                                    }
                                }
                            }
                        }
                
                        if !inviteeFound
                        {
                            // Person not found on invite
                    
                            if tempStatus == "Added"
                            {
                                // Mnaually added person, so continue
                                initaliseAttendee(tempName, emailAddress: tempEmail, type: tempType, status: tempStatus)
                            }
                        }
            
                        if tempName == myChair
                        {
                            chairFound = true
                        }
            
                        if tempName == myMinutes
                        {
                            minutesFound = true
                        }
                    }
            
                    if !chairFound
                    {
                        myChair = ""
                        save()
                    }
            
                    if !minutesFound
                    {
                        myMinutes = ""
                        save()
                    }

                    // Now we need to check for people added into the meeting but not in the saved list.
            
                    if myMeetingID == ""
                    {
                        mySavedValues = myDatabaseConnection.loadAttendees("\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)")
                    }
                    else
                    {
                        mySavedValues = myDatabaseConnection.loadAttendees(myMeetingID)
                    }
            
                    if myEvent!.hasAttendees
                    {
                        for invitee in myEvent!.attendees!
                        {
                            // Check to see if any "Invited" people are no longer on calendar invite, and if so remove from Agenda.
                
                            inviteeFound = false
                            for checkAttendee in mySavedValues
                            {
                                tempName = checkAttendee.name!
                                if invitee.name == tempName
                                {
                                    // Invitee found
                                    inviteeFound = true
                                    break
                                }
                            }
                
                            if !inviteeFound
                            {
                                // New invitee so add into table

                                // Is the Attendee is not the current user then we need to parse the email address
                                    
                                // Split the URL string on : - to give an array, the second element is the email address
                                
                                if !invitee.isCurrentUser
                                {
                                    let emailSplit = String(describing: invitee.url).components(separatedBy: ":")
                                
                                    addAttendee(invitee.name!, emailAddress: emailSplit[1], type: "Participant", status: "Invited")
                                }
                            }
                        }
                    }
                }
                else
                {
                    if myEvent!.hasAttendees
                    {
                        for invitee in myEvent!.attendees!
                        {
                            // Split the URL string on : - to give an array, the second element is the email address
                            
                            if !invitee.isCurrentUser
                            {
                                let emailSplit = String(describing: invitee.url).components(separatedBy: ":")
                                
                                addAttendee(invitee.name!, emailAddress: emailSplit[1], type: "Participant", status: "Invited")
                            }
                        }
                    }
                }
            }
            else
            { // In the past so we just used the entried from the table
                for savedAttendee in mySavedValues
                {
                    initaliseAttendee(savedAttendee.name!, emailAddress: savedAttendee.email!, type: savedAttendee.type!, status: savedAttendee.attendenceStatus!)
                }
            }
        }
    }
    
    func loadAgendaItems()
    {
        var mySavedValues: [MeetingAgendaItem]!
        
        if myMeetingID == ""
        {
            mySavedValues = myDatabaseConnection.loadAgendaItem("\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)")
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAgendaItem(myMeetingID)
        }
        
        myAgendaItems.removeAll(keepingCapacity: false)
        
        if mySavedValues.count > 0
        {
            var runningMeetingOrder: Int32 = 0
            
            for savedAgenda in mySavedValues
            {
                let myAgendaItem =  meetingAgendaItem(meetingID: savedAgenda.meetingID!, agendaID: savedAgenda.agendaID)
                if myAgendaItem.meetingOrder == 0
                {
                    myAgendaItem.meetingOrder += runningMeetingOrder
                }
                else
                {
                    runningMeetingOrder = myAgendaItem.meetingOrder
                }
                myAgendaItem.loadTasks()
                myAgendaItems.append(myAgendaItem)
            }
        }
    }
        
    func updateAgendaItems(_ agendaID: Int32, title: String, owner: String, status: String, decisionMade: String, discussionNotes: String, timeAllocation: Int16, actualStartTime: Date, actualEndTime: Date)
    {
        for myAgendaItem in myAgendaItems
        {
            if myAgendaItem.agendaID == agendaID
            {
                myAgendaItem.status = status
                myAgendaItem.decisionMade = decisionMade
                myAgendaItem.discussionNotes = discussionNotes
                myAgendaItem.timeAllocation = timeAllocation
                myAgendaItem.owner = owner
                myAgendaItem.title = title
                myAgendaItem.actualEndTime = actualEndTime
                myAgendaItem.actualStartTime = actualStartTime
            }
            break
        }
    }
    
    fileprivate func writeLine(_ targetString: String, lineString: String) -> String
    {
        var myString = targetString
        
        if targetString.characters.count > 0
        {
            myString += "\n"
        }
        
        myString += lineString
        
        return myString
    }
    
    
    func buildShareString() -> String
    {
        var myExportString: String = ""
        var myLine: String = ""
        let myDateFormatter = DateFormatter()
        myDateFormatter.timeStyle = DateFormatter.Style.short
        
        let myCalendar = Calendar.current
        
        var myWorkingTime = myStartDate
        
        if myStartDate.compare(Date()) == ComparisonResult.orderedAscending
        {  // Historical so show Minutes
            myLine = "                Minutes"
        }
        else
        {
            myLine = "                Agenda"
        }
        
        myExportString = writeLine(myExportString, lineString: myLine)
        
        myExportString = writeLine(myExportString, lineString: "")
        
        myLine = "       Meeting: \(myTitle)"
        myExportString = writeLine(myExportString, lineString: myLine)
        
        myExportString = writeLine(myExportString, lineString: "")
        
        myLine = "On: \(displayScheduledDate)    "
        
        if myLocation != ""
        {
            myLine += "At: \(myLocation)"
        }
        myExportString = writeLine(myExportString, lineString: myLine)
        
        myExportString = writeLine(myExportString, lineString: "")
        
        myLine = ""
        
        if myChair != ""
        {
            myLine += "Chair: \(myChair)       "
        }
        
        if myMinutes != ""
        {
            myLine += "Minutes: \(myMinutes)"
        }
        
        myExportString = writeLine(myExportString, lineString: myLine)
        myExportString = writeLine(myExportString, lineString: "")
        
        if myPreviousMinutes != ""
        {
            // Get the previous meetings details
            
            let myItems = myDatabaseConnection.loadAgenda(myPreviousMinutes, teamID: myTeamID)
            
            for myItem in myItems
            {
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                
                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                
                myLine = "Previous Meeting: \(myDisplayString)"
                myExportString = writeLine(myExportString, lineString: myLine)
            }
        }
        
        //  Now we are going to get the Agenda Items
        
        if myPreviousMinutes != ""
        { // Previous meeting exists
            // Does the previous meeting have any tasks
            let myData = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
            
            if myData.count > 0
            {  // There are tasks for the previous meeting
                myExportString = writeLine(myExportString, lineString: "")
                myExportString = writeLine(myExportString, lineString: "")
                myExportString = writeLine(myExportString, lineString: "")
                myLine = "Actions from Previous Meeting"
                myExportString = writeLine(myExportString, lineString: myLine)
                myExportString = writeLine(myExportString, lineString: "")
                
                var myTaskList: [task] = Array()
                
                let myData2 = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
                
                for myItem2 in myData2
                {
                    let newTask = task(taskID: myItem2.taskID)
                    myTaskList.append(newTask)
                }
                
                // We want to build up a table here to display the data
                
                myLine = "||Task"
                myLine += "||Status"
                myLine += "||Project"
                myLine += "||Due Date"
                myLine += "||Context||"
                
                myExportString = writeLine(myExportString, lineString: myLine)
                
                for myTask in myTaskList
                {
                    myLine = "||\(myTask.title)"
                    myLine += "||\(myTask.status)"
                    
                    // Get the project name to display
                    
                    let myData3 = myDatabaseConnection.getProjectDetails(myTask.projectID)
                    
                    if myData3.count == 0
                    {
                        myLine += "||No Project set"
                    }
                    else
                    {
                        myLine += "||\(myData3[0].projectName!)"
                    }
                    
                    if myTask.displayDueDate == ""
                    {
                        myLine += "||No due date set"
                    }
                    else
                    {
                        myLine += "||\(myTask.displayDueDate)"
                    }
                    
                    if myTask.contexts.count == 0
                    {
                        myLine += "||No context set"
                    }
                    else if myTask.contexts.count == 1
                    {
                        myLine += "||\(myTask.contexts[0].name)"
                    }
                    else
                    {
                        var itemCount: Int = 0
                        myLine += "||"
                        for myItem4 in myTask.contexts
                        {
                            if itemCount > 0
                            {
                                myLine += ", "
                            }
                            myLine += "\(myItem4.name)"
                            itemCount += 1
                        }
                        myLine += "||"
                    }
                    
                    myExportString = writeLine(myExportString, lineString: myLine)
                }
            }
            
            // Outstanding previous meetings
            
            let myOutstandingTasks = parsePastMeeting(myPreviousMinutes)
            
            if myOutstandingTasks.count > 0
            {
                // We want to build up a table here to display the data
                myExportString = writeLine(myExportString, lineString: "")
                myExportString = writeLine(myExportString, lineString: "")
                myLine = "Outstanding Actions from Previous Meetings"
                myExportString = writeLine(myExportString, lineString: myLine)
                myExportString = writeLine(myExportString, lineString: "")
                
                myLine = "||Task"
                myLine += "||Status"
                myLine += "||Project"
                myLine += "||Due Date"
                myLine += "||Context||"
                
                myExportString = writeLine(myExportString, lineString: myLine)
                
                for myTask in myOutstandingTasks
                {
                    myLine = "||\(myTask.title)"
                    myLine += "||\(myTask.status)"
                    
                    // Get the project name to display
                    
                    let myData3 = myDatabaseConnection.getProjectDetails(myTask.projectID)
                    
                    if myData3.count == 0
                    {
                        myLine += "||No Project set"
                    }
                    else
                    {
                        myLine += "||\(myData3[0].projectName!)"
                    }
                    
                    if myTask.displayDueDate == ""
                    {
                        myLine += "||No due date set"
                    }
                    else
                    {
                        myLine += "||\(myTask.displayDueDate)"
                    }
                    
                    if myTask.contexts.count == 0
                    {
                        myLine += "||No context set"
                    }
                    else if myTask.contexts.count == 1
                    {
                        myLine += "||\(myTask.contexts[0].name)"
                    }
                    else
                    {
                        var itemCount: Int = 0
                        myLine += "||"
                        for myItem4 in myTask.contexts
                        {
                            if itemCount > 0
                            {
                                myLine += ", "
                            }
                            myLine += "\(myItem4.name)"
                            itemCount += 1
                        }
                        myLine += "||"
                    }
                    myExportString = writeLine(myExportString, lineString: myLine)
                }
            }
        }
        
        myExportString = writeLine(myExportString, lineString: "")
        myExportString = writeLine(myExportString, lineString: "")
        
        myLine = "                Agenda Items"
        myExportString = writeLine(myExportString, lineString: myLine)
        myExportString = writeLine(myExportString, lineString: "")
        
        if myStartDate.compare(Date()) == ComparisonResult.orderedAscending
        {  // Historical so show Minutes
            
            for myItem in myAgendaItems
            {
                myLine = "\(myItem.title)"
                myExportString = writeLine(myExportString, lineString: myLine)
                
                myExportString = writeLine(myExportString, lineString: "")
                
                if myItem.discussionNotes != ""
                {
                    myLine = "Discussion Notes"
                    myExportString = writeLine(myExportString, lineString: myLine)
                
                    myLine = "\(myItem.discussionNotes)"
                    myExportString = writeLine(myExportString, lineString: myLine)
                
                    myExportString = writeLine(myExportString, lineString: "")
                }
                
                if myItem.decisionMade != ""
                {
                    myLine = "Decisions Made"
                    myExportString = writeLine(myExportString, lineString: myLine)
                
                    myLine = "\(myItem.decisionMade)"
                    myExportString = writeLine(myExportString, lineString: myLine)
                
                    myExportString = writeLine(myExportString, lineString: "")
                }
                
                if myItem.tasks.count != 0
                {
                    myLine = "Actions"
                    myExportString = writeLine(myExportString, lineString: myLine)
                
                    myLine = "||Task"
                    myLine += "||Status"
                    myLine += "||Project"
                    myLine += "||Due Date"
                    myLine += "||Context||"
                    
                    myExportString = writeLine(myExportString, lineString: myLine)
                    
                    for myTask in myItem.tasks
                    {
                        myLine = "||\(myTask.title)"
                        myLine += "||\(myTask.status)"
                        
                        // Get the project name to display
                        
                        let myData3 = myDatabaseConnection.getProjectDetails(myTask.projectID)
                        
                        if myData3.count == 0
                        {
                            myLine += "||No Project set"
                        }
                        else
                        {
                            myLine += "||\(myData3[0].projectName!)"
                        }
                        
                        if myTask.displayDueDate == ""
                        {
                            myLine += "||No due date set"
                        }
                        else
                        {
                            myLine += "||\(myTask.displayDueDate)"
                        }
                        
                        if myTask.contexts.count == 0
                        {
                            myLine += "||No context set"
                        }
                        else if myTask.contexts.count == 1
                        {
                            myLine += "||\(myTask.contexts[0].name)"
                        }
                        else
                        {
                            var itemCount: Int = 0
                            myLine += "||"
                            for myItem4 in myTask.contexts
                            {
                                if itemCount > 0
                                {
                                    myLine += ", "
                                }
                                myLine += "\(myItem4.name)"
                                itemCount += 1
                            }
                            myLine += "||"
                        }
                        
                        myExportString = writeLine(myExportString, lineString: myLine)
                    }
                    myExportString = writeLine(myExportString, lineString: "")
                }
            }
        }
        else
        {  // Future so show Agenda
            myLine = "||Time"
            myLine += "||Item"
            myLine += "||Owner||"
            myExportString = writeLine(myExportString, lineString: myLine)
            
            if myPreviousMinutes != ""
            { // Previous meeting exists
                // Does the previous meeting have any tasks
                let myData = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
                
                if myData.count > 0
                {  // There are tasks for the previous meeting
                    myLine = "||\(myDateFormatter.string(from: myWorkingTime!))"
                    myLine += "||Actions from Previous Meeting"
                    myLine += "||All||"
                    myExportString = writeLine(myExportString, lineString: myLine)
                    
                    myWorkingTime = myCalendar.date(
                        byAdding: .minute,
                        value: 10,
                        to: myWorkingTime!)!
                }
            }
            
            myExportString = writeLine(myExportString, lineString: "")
            
            for myItem in myAgendaItems
            {
                myLine = "||\(myDateFormatter.string(from: myWorkingTime!))"
                myLine += "||\(myItem.title)"
                myLine += "||\(myItem.owner)||"
                myExportString = writeLine(myExportString, lineString: myLine)
                
                myWorkingTime = myCalendar.date(
                    byAdding: .minute,
                    value: Int(myItem.timeAllocation),
                    to: myWorkingTime!)!
                
            }
            
            myLine = "||\(myDateFormatter.string(from: myWorkingTime!))"
            myLine += "||Meeting Close"
            myLine += "||||"
            
            myExportString = writeLine(myExportString, lineString: myLine)
        }
        
        if nextMeeting != ""
        {
            // Get the previous meetings details
            
            let myItems = myDatabaseConnection.loadAgenda(nextMeeting, teamID: myTeamID)
            
            for myItem in myItems
            {
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                
                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                
                myExportString = writeLine(myExportString, lineString: "")
                myExportString = writeLine(myExportString, lineString: "")
                
                myLine = "Next Meeting: \(myDisplayString)"
                myExportString = writeLine(myExportString, lineString: myLine)
                
            }
        }
        return myExportString
    }
    
    fileprivate func writeHTMLLine(_ targetString: String, lineString: String) -> String
    {
        var myString = targetString
        
        if targetString.characters.count > 0
        {
            myString += "<p>"
        }
        
        myString += lineString
        
        return myString
    }
    
    func buildShareHTMLString() -> String
    {
        var myExportString: String = ""
        var myLine: String = ""
        var myTaskTable: String = ""
        let myDateFormatter = DateFormatter()
        myDateFormatter.timeStyle = DateFormatter.Style.short
        
        let myCalendar = Calendar.current
        
        var myWorkingTime = myStartDate
        
        myLine = "<html><body>"
        
        if myStartDate.compare(Date()) == ComparisonResult.orderedAscending
        {  // Historical so show Minutes
            myLine += "<center><h1>Minutes</h1></center>"
        }
        else
        {
            myLine += "<center><h1>Agenda</h1></center>"
        }
        
        myExportString = writeHTMLLine(myExportString, lineString: myLine)
        
        myLine = "<center><h2>\(myTitle)</h2></center>"
        myExportString = writeHTMLLine(myExportString, lineString: myLine)
        
        myExportString = writeHTMLLine(myExportString, lineString: "")
        
        myLine = "On: \(displayScheduledDate)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        
        if myLocation != ""
        {
            myLine += "At: \(myLocation)"
        }
        
        myExportString = writeHTMLLine(myExportString, lineString: myLine)
        
        myExportString = writeHTMLLine(myExportString, lineString: "")
        myLine = ""
        
        if myChair != ""
        {
            myLine += "Chair: \(myChair)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        }
        
        if myMinutes != ""
        {
            myLine += "Minutes: \(myMinutes)"
        }
        
        myExportString = writeHTMLLine(myExportString, lineString: myLine)
        myExportString = writeHTMLLine(myExportString, lineString: "")
        
        if myPreviousMinutes != ""
        {
            // Get the previous meetings details
            
            let myItems = myDatabaseConnection.loadAgenda(myPreviousMinutes, teamID: myTeamID)
            
            for myItem in myItems
            {
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                
                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                
                myLine = "Previous Meeting: \(myDisplayString)"
                myExportString = writeHTMLLine(myExportString, lineString: myLine)
            }
        }
        
        //  Now we are going to get the Agenda Items
        
        if myPreviousMinutes != ""
        { // Previous meeting exists
            // Does the previous meeting have any tasks
            let myData = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
            
            if myData.count > 0
            {  // There are tasks for the previous meeting
                myLine = "<center><h3>Actions from Previous Meeting</h3></center>"
                myExportString = writeHTMLLine(myExportString, lineString: myLine)
                
                var myTaskList: [task] = Array()
                
                let myData2 = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
                
                for myItem2 in myData2
                {
                    let newTask = task(taskID: myItem2.taskID)
                    myTaskList.append(newTask)
                }
                
                // We want to build up a table here to display the data
                
                myTaskTable = "<table border=\"1\">"
                myTaskTable += "<tr>"
                myTaskTable += "<th>Task</th>"
                myTaskTable += "<th>Status</th>"
                myTaskTable += "<th>Project</th>"
                myTaskTable += "<th>Due Date</th>"
                myTaskTable += "<th>Context</th>"
                myTaskTable += "</tr>"
                
                for myTask in myTaskList
                {
                    myTaskTable += "<tr>"
                    myTaskTable += "<td>\(myTask.title)</td>"
                    myTaskTable += "<td>\(myTask.status)</td>"
                    
                    // Get the project name to display
                    
                    let myData3 = myDatabaseConnection.getProjectDetails(myTask.projectID)
                    
                    if myData3.count == 0
                    {
                        myTaskTable += "<td>No Project set</td>"
                    }
                    else
                    {
                        myTaskTable += "<td>\(myData3[0].projectName!)</td>"
                    }
                    
                    if myTask.displayDueDate == ""
                    {
                        myTaskTable += "<td>No due date set</td>"
                    }
                    else
                    {
                        myTaskTable += "<td>\(myTask.displayDueDate)</td>"
                    }
                    
                    if myTask.contexts.count == 0
                    {
                        myTaskTable += "<td>No context set</td>"
                    }
                    else if myTask.contexts.count == 1
                    {
                        myTaskTable += "<td>\(myTask.contexts[0].name)</td>"
                    }
                    else
                    {
                        var itemCount: Int = 0
                        myTaskTable += "<td>"
                        for myItem4 in myTask.contexts
                        {
                            if itemCount > 0
                            {
                                myTaskTable += "<p>"
                            }
                            myTaskTable += "\(myItem4.name)"
                            itemCount += 1
                        }
                        myTaskTable += "</td>"
                    }
                    
                    myTaskTable += "</tr>"
                }
                myTaskTable += "</table>"
                myExportString = writeHTMLLine(myExportString, lineString: myTaskTable)
            }
            
            // Outstanding previous meetings
            
            let myOutstandingTasks = parsePastMeeting(myPreviousMinutes)
                
            if myOutstandingTasks.count > 0
            {
                // We want to build up a table here to display the data
                myLine = "<center><h3>Outstanding Actions from Previous Meetings</h3></center>"
                myExportString = writeHTMLLine(myExportString, lineString: myLine)
                
                myTaskTable = "<table border=\"1\">"
                myTaskTable += "<tr>"
                myTaskTable += "<th>Task</th>"
                myTaskTable += "<th>Status</th>"
                myTaskTable += "<th>Project</th>"
                myTaskTable += "<th>Due Date</th>"
                myTaskTable += "<th>Context</th>"
                myTaskTable += "</tr>"

                for myTask in myOutstandingTasks
                {
                    myTaskTable += "<tr>"
                    myTaskTable += "<td>\(myTask.title)</td>"
                    myTaskTable += "<td>\(myTask.status)</td>"
                        
                    // Get the project name to display
                        
                    let myData3 = myDatabaseConnection.getProjectDetails(myTask.projectID)
                        
                    if myData3.count == 0
                    {
                        myTaskTable += "<td>No Project set</td>"
                    }
                    else
                    {
                        myTaskTable += "<td>\(myData3[0].projectName!)</td>"
                    }
                        
                    if myTask.displayDueDate == ""
                    {
                        myTaskTable += "<td>No due date set</td>"
                    }
                    else
                    {
                        myTaskTable += "<td>\(myTask.displayDueDate)</td>"
                    }
                        
                    if myTask.contexts.count == 0
                    {
                        myTaskTable += "<td>No context set</td>"
                    }
                    else if myTask.contexts.count == 1
                    {
                        myTaskTable += "<td>\(myTask.contexts[0].name)</td>"
                    }
                    else
                    {
                        var itemCount: Int = 0
                        myTaskTable += "<td>"
                        for myItem4 in myTask.contexts
                        {
                            if itemCount > 0
                            {
                                myTaskTable += "<p>"
                            }
                            myTaskTable += "\(myItem4.name)"
                            itemCount += 1
                        }
                        myTaskTable += "</td>"
                    }
                        
                    myTaskTable += "</tr>"
                }
                myTaskTable += "</table>"
                myExportString = writeHTMLLine(myExportString, lineString: myTaskTable)
            }
        }
        
        myLine = "<center><h3>Agenda Items</h3></center>"
        myExportString = writeHTMLLine(myExportString, lineString: myLine)
        
        if myStartDate.compare(Date()) == ComparisonResult.orderedAscending
        {  // Historical so show Minutes

            for myItem in myAgendaItems
            {
                myLine = "<h4>\(myItem.title)</h4>"
                myExportString = writeHTMLLine(myExportString, lineString: myLine)
            
                myExportString = writeHTMLLine(myExportString, lineString: "")
                
                if myItem.discussionNotes != ""
                {
                    myLine = "<h5>Discussion Notes</h5>"
                    myExportString = writeHTMLLine(myExportString, lineString: myLine)
                
                    myLine = "\(myItem.discussionNotes)"
                    myExportString = writeHTMLLine(myExportString, lineString: myLine)

                    myExportString = writeHTMLLine(myExportString, lineString: "")
                }
                
                if myItem.decisionMade != ""
                {
                    myLine = "<h5>Decisions Made</h5>"
                    myExportString = writeHTMLLine(myExportString, lineString: myLine)
                
                    myLine = "\(myItem.decisionMade)"
                    myExportString = writeHTMLLine(myExportString, lineString: myLine)

                    myExportString = writeHTMLLine(myExportString, lineString: "")
                }
                
                if myItem.tasks.count != 0
                {
                    myLine = "<h5>Actions</h5>"
                    myExportString = writeHTMLLine(myExportString, lineString: myLine)

                    myTaskTable = "<table border=\"1\">"
                    myTaskTable += "<tr>"
                    myTaskTable += "<th>Task</th>"
                    myTaskTable += "<th>Status</th>"
                    myTaskTable += "<th>Project</th>"
                    myTaskTable += "<th>Due Date</th>"
                    myTaskTable += "<th>Context</th>"
                    myTaskTable += "</tr>"
                    
                    for myTask in myItem.tasks
                    {
                        myTaskTable += "<tr>"
                        myTaskTable += "<td>\(myTask.title)</td>"
                        myTaskTable += "<td>\(myTask.status)</td>"
                        
                        // Get the project name to display
                        
                        let myData3 = myDatabaseConnection.getProjectDetails(myTask.projectID)
                        
                        if myData3.count == 0
                        {
                            myTaskTable += "<td>No Project set</td>"
                        }
                        else
                        {
                            myTaskTable += "<td>\(myData3[0].projectName!)</td>"
                        }
                        
                        if myTask.displayDueDate == ""
                        {
                            myTaskTable += "<td>No due date set</td>"
                        }
                        else
                        {
                            myTaskTable += "<td>\(myTask.displayDueDate)</td>"
                        }
                        
                        if myTask.contexts.count == 0
                        {
                            myTaskTable += "<td>No context set</td>"
                        }
                        else if myTask.contexts.count == 1
                        {
                            myTaskTable += "<td>\(myTask.contexts[0].name)</td>"
                        }
                        else
                        {
                            var itemCount: Int = 0
                            myTaskTable += "<td>"
                            for myItem4 in myTask.contexts
                            {
                                if itemCount > 0
                                {
                                    myTaskTable += "<p>"
                                }
                                myTaskTable += "\(myItem4.name)"
                                itemCount += 1
                            }
                            myTaskTable += "</td>"
                        }
                        
                        myTaskTable += "</tr>"
                    }
                    myTaskTable += "</table>"
                    myExportString = writeHTMLLine(myExportString, lineString: myTaskTable)
                }
                myExportString = writeHTMLLine(myExportString, lineString: "")
            }
        }
        else
        {  // Future so show Agenda
            myTaskTable = "<table border=\"1\">"
            myTaskTable += "<tr>"
            myTaskTable += "<th>Time</th>"
            myTaskTable += "<th>Item</th>"
            myTaskTable += "<th>Owner</th>"
            myTaskTable += "</tr>"
            
            if myPreviousMinutes != ""
            { // Previous meeting exists
                // Does the previous meeting have any tasks
                let myData = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
                
                if myData.count > 0
                {  // There are tasks for the previous meeting
                    myTaskTable += "<tr>"
                    myTaskTable += "<td>\(myDateFormatter.string(from: myWorkingTime!))</td>"
                    myTaskTable += "<td>Actions from Previous Meeting</td>"
                    myTaskTable += "<td>All</td>"
                    myTaskTable += "</tr>"
                    
                    myWorkingTime = myCalendar.date(
                        byAdding: .minute,
                        value: 10,
                        to: myWorkingTime!)!
                }
            }
            
            for myItem in myAgendaItems
            {
                myTaskTable += "<tr>"
                myTaskTable += "<td>\(myDateFormatter.string(from: myWorkingTime!))</td>"
                myTaskTable += "<td>\(myItem.title)</td>"
                myTaskTable += "<td>\(myItem.owner)</td>"
                myTaskTable += "</tr>"
                
                myWorkingTime = myCalendar.date(
                    byAdding: .minute,
                    value: Int(myItem.timeAllocation),
                    to: myWorkingTime!)!
                
            }
            
            myTaskTable += "<tr>"
            myTaskTable += "<td>\(myDateFormatter.string(from: myWorkingTime!))</td>"
            myTaskTable += "<td>Meeting Close</td>"
            myTaskTable += "<td></td>"
            myTaskTable += "</tr>"
            myTaskTable += "</table>"
            myExportString = writeHTMLLine(myExportString, lineString: myTaskTable)
        }
        
        if nextMeeting != ""
        {
            // Get the previous meetings details
            
            let myItems = myDatabaseConnection.loadAgenda(nextMeeting, teamID: myTeamID)
            
            for myItem in myItems
            {
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                
                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                
                myExportString = writeHTMLLine(myExportString, lineString: "")
                myExportString = writeHTMLLine(myExportString, lineString: "")
                
                myLine = "<b>Next Meeting:</b> \(myDisplayString)"
                myExportString = writeHTMLLine(myExportString, lineString: myLine)
                
            }
        }
        myExportString = writeHTMLLine(myExportString, lineString: "</body></html>")
        return myExportString
    }
    
    func setNextMeeting(_ nextMeeting: calendarItem)
    {
        // Need to update the "next meeting", to sets its previous meeting ID to be this one
            
        // check to see if there is already a meeting
        
        let nextMeetingID = nextMeeting.meetingID
        let tempAgenda = myDatabaseConnection.loadAgenda(nextMeetingID, teamID: myTeamID)
        
        if tempAgenda.count > 0
        { // existing record found, so update
            myDatabaseConnection.updatePreviousAgendaID(myMeetingID, meetingID: nextMeetingID, teamID: myTeamID)
            myNextMeeting = nextMeetingID
        }
        else
        { // No record found so insert
            nextMeeting.previousMinutes = myMeetingID
            myNextMeeting = nextMeeting.meetingID
        }
    }
    
    func checkForEvent() -> Bool
    {
  //      var itemFound: Bool = false
        
        // Using the eventID get the calendar eventID and start date
        
 //       let myStringArr = myMeetingID.componentsSeparatedByString(" Date: ")
        
//    NSLog("Meeting Parts = \(myStringArr[0]) - \(myStringArr[1])")
        
        // Go an get the calendar entry
        
 //       let searchString = myStringArr[0]
        
 //       let myItems = globalEventStore.calendarItemsWithExternalIdentifier(searchString)
        
 //       if myItems.count == 0
 //       {
 //           itemFound = true
 //       }
 //       else
 //       {
 //           for myItem in myItems
 //           {
 //               let foundEvent: EKEvent = myItem as! EKEvent
//NSLog("found date = \(foundEvent.startDate)")
    
 //               if foundEvent.startDate == myStringArr[1]
 //               {
 //                   itemFound = true
 //               }
 //           }
 //       }
  //      return itemFound
        return true
    }
    
    func updateEventForNewEventDate(_ newEvent: EKEvent)
    {
        NSLog("Do code to chnage the event details")
    }
}

class iOSCalendar
{
    fileprivate var eventDetails: [calendarItem] = Array()
    fileprivate var eventRecords: [EKEvent] = Array()

    var events: [EKEvent]
    {
        get
        {
            return eventRecords
        }
    }
    
    var calendarItems: [calendarItem]
    {
        get
        {
            return eventDetails
        }
    }
    
    func loadCalendarDetails(_ emailAddresses: [String], teamID: Int32)
    {
        for myEmail in emailAddresses
        {
            parseCalendarByEmail(myEmail, teamID: teamID)
            loadMeetingsForContext(myEmail)
        }
        
        // Now sort the array into date order
        
         eventDetails.sort(by: {$0.startDate.timeIntervalSinceNow < $1.startDate.timeIntervalSinceNow})
    }
    
    func loadCalendarForEvent(_ meetingID: String, startDate: Date, teamID: Int32)
    {
        /* The end date */
        //Calculate - Days * hours * mins * secs
        
        let myEndDateValue:TimeInterval = 60 * 60
        
        let endDate = startDate.addingTimeInterval(myEndDateValue)
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        let searchPredicate = globalEventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if globalEventStore.sources.count > 0
        {
            let calItems = globalEventStore.events(matching: searchPredicate)
            
            for calItem in calItems
            {
                if "\(calItem.calendarItemExternalIdentifier) Date: \(calItem.startDate)" == meetingID
                {
                    eventRecords.append(calItem)
                    let calendarEntry = calendarItem(event: calItem, attendee: nil, teamID: teamID)
                    
                    eventDetails.append(calendarEntry)
                    eventRecords.append(calItem)
                }
            }
        }
    }
    
    func loadCalendarDetails(_ projectName: String, teamID: Int32)
    {
        parseCalendarByProject(projectName, teamID: teamID)
        
        loadMeetingsForProject(projectName)
        
        // now sort the array into date order
        
        eventDetails.sort(by: {$0.startDate.timeIntervalSinceNow < $1.startDate.timeIntervalSinceNow})
    }

    fileprivate func loadMeetingsForContext(_ searchString: String)
    {
        var meetingFound: Bool = false
        
        let myMeetingArray = getMeetingsForDateRange()
        
        // Check through the meetings for ones that match the context
        
        for myMeeting in myMeetingArray
        {
            let myAttendeeList = myDatabaseConnection.loadAttendees(myMeeting.meetingID!)

            for myAttendee in myAttendeeList
            {
                if (myAttendee.name == searchString) || (myAttendee.email == searchString)
                {
                    // Check to see if there is already an entry for this meeting, as if there is we do not need to add it
                    meetingFound = false
                    for myCheck in eventDetails
                    {
                        if myCheck.meetingID == myMeeting.meetingID
                        {
                            meetingFound = true
                            break
                        }
                    }
                    
                    if !meetingFound
                    {
                        let calendarEntry = calendarItem(meetingAgenda: myMeeting)
                    
                        eventDetails.append(calendarEntry)
            //        eventRecords.append(nil)
                    }
                }
            }
        }
    }
    
    fileprivate func loadMeetingsForProject(_ searchString: String)
    {
        var meetingFound: Bool = false
        var dateMatch: Bool = false
        
        let myMeetingArray = getMeetingsForDateRange()
        
        // Check through the meetings for ones that match the context
        
        for myMeeting in myMeetingArray
        {
            if myMeeting.name?.lowercased().range(of: searchString.lowercased()) != nil
            {
                // Check to see if there is already an entry for this meeting, as if there is we do not need to add it
                meetingFound = false
                dateMatch = true
                for myCheck in eventDetails
                {
                    if myCheck.meetingID == myMeeting.meetingID
                    {
                        meetingFound = true
                        break
                    }
                    
                    if myCheck.title == myMeeting.name
                    {  // Meeting names are the same
                        if myCheck.startDate == myMeeting.startTime! as Date
                        { // Dates are the same
                            dateMatch = true
                            break
                        }
                    }
                    // Events Ids do not match
                }
                
                if !meetingFound
                {
                    let calendarEntry = calendarItem(meetingAgenda: myMeeting)
                    
                    eventDetails.append(calendarEntry)
                }
                
                if !dateMatch
                {
                    let calendarEntry = calendarItem(meetingAgenda: myMeeting)
                    
                    eventDetails.append(calendarEntry)
                }
            }
        }
    }
    
    fileprivate func parseCalendarByEmail(_ email: String, teamID: Int32)
    {
        let events = getEventsForDateRange()
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                if event.attendees != nil
                {
                    if event.attendees!.count > 0
                    {
                        for attendee in event.attendees!
                        {
                            if !attendee.isCurrentUser
                            {
                                // Is the Attendee is not the current user then we need to parse the email address

                                // Split the URL string on : - to give an array, the second element is the email address
                                
                                let emailSplit = String(describing: attendee.url).components(separatedBy: ":")

                                if emailSplit[1] == email
                                {
                                    storeEvent(event, attendee: attendee, teamID: teamID)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func parseCalendarByProject(_ project: String, teamID: Int32)
    {
        let events = getEventsForDateRange()
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                let myTitle = event.title
                        
                if myTitle.lowercased().range(of: project.lowercased()) != nil
                {
                    storeEvent(event, attendee: nil, teamID: teamID)
                }
            }
        }
    }
    
    fileprivate func getEventsForDateRange() -> [EKEvent]
    {
        var events: [EKEvent] = []
        
        let baseDate = Date()
        
        /* The event starts date */
        //Calculate - Days * hours * mins * secs
        
        let myStartDateString = myDatabaseConnection.getDecodeValue("Calendar - Weeks before current date")
        // This is string value so need to convert to integer, and subtract from 0 to get a negative
        
        let myStartDateValue:TimeInterval = 0 - ((((myStartDateString as NSString).doubleValue * 7) + 1) * 24 * 60 * 60)
        
        let startDate = baseDate.addingTimeInterval(myStartDateValue)
        
        /* The end date */
        //Calculate - Days * hours * mins * secs
        
        let myEndDateString = myDatabaseConnection.getDecodeValue("Calendar - Weeks after current date")
        // This is string value so need to convert to integer
        
        let myEndDateValue:TimeInterval = (myEndDateString as NSString).doubleValue * 7 * 24 * 60 * 60
        
        let endDate = baseDate.addingTimeInterval(myEndDateValue)
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        let searchPredicate = globalEventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if globalEventStore.sources.count > 0
        {
            events = globalEventStore.events(matching: searchPredicate)
        }
        return events
    }

    fileprivate func getMeetingsForDateRange() -> [MeetingAgenda]
    {
        let baseDate = Date()
        
        /* The event starts date */
        //Calculate - Days * hours * mins * secs
        
        let myStartDateString = myDatabaseConnection.getDecodeValue("Calendar - Weeks before current date")
        // This is string value so need to convert to integer, and subtract from 0 to get a negative
        
        let myStartDateValue:TimeInterval = 0 - ((((myStartDateString as NSString).doubleValue * 7) + 1) * 24 * 60 * 60)
        
        let startDate = baseDate.addingTimeInterval(myStartDateValue)
        
        /* The end date */
        //Calculate - Days * hours * mins * secs
        
        let myEndDateString = myDatabaseConnection.getDecodeValue("Calendar - Weeks after current date")
        // This is string value so need to convert to integer
        
        let myEndDateValue:TimeInterval = (myEndDateString as NSString).doubleValue * 7 * 24 * 60 * 60
        
        let endDate = baseDate.addingTimeInterval(myEndDateValue)
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        _ = globalEventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil)
        
        /* Fetch all the meetings that fall between the starting and the ending dates */
        
        return myDatabaseConnection.getAgendaForDateRange(startDate as NSDate, endDate: endDate as NSDate, teamID: currentUser.currentTeam!.teamID)
    }
    
    fileprivate func storeEvent(_ event: EKEvent, attendee: EKParticipant?, teamID: Int32)
    {
        let calendarEntry = calendarItem(event: event, attendee: attendee, teamID: teamID)
        
        eventDetails.append(calendarEntry)
        eventRecords.append(event)
    }

    func displayEvent() -> [TableData]
    {
        var tableContents: [TableData] = [TableData]()
        
        // Build up the details we want to show ing the calendar
        
        for event in eventDetails
        {
            var myString = "\(event.title)\n"
            myString += "\(event.displayScheduledDate)\n"

            if event.recurrence != -1
            {
                myString += "Occurs every \(event.recurrenceFrequency) \(event.displayRecurrence)\n"
            }
            
            if event.location != ""
            {
                myString += "At \(event.location)\n"
            }
            
            if event.status != -1
            {
                myString += "Status = \(event.displayStatus)"
            }
            
            if event.startDate.compare(Date()) == ComparisonResult.orderedAscending
            {
                // Event is in the past
                writeRowToArray(myString, table: &tableContents, targetEvent: event, displayFormat: "Gray")
            }
            else
            {
                writeRowToArray(myString, table: &tableContents, targetEvent: event)
            }
        }
        return tableContents
    }
    
    func getCalendarRecords() -> [TableData]
    {
        var outputArray: [TableData] = Array()
        
        let endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        let searchPredicate = globalEventStore.predicateForEvents(
            withStart: Date(),
            end: endDate!,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if globalEventStore.sources.count > 0
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short

            for calItem in globalEventStore.events(matching: searchPredicate)
            {
                var tempEntry = TableData(displayText: calItem.title)
                tempEntry.notes = dateFormatter.string(from: calItem.startDate)
                tempEntry.event = calItem

                outputArray.append(tempEntry)
            }

            return outputArray
        }
        else
        {
            return []
        }
    }
}

class ReminderData
{
    var reminderText: String
    fileprivate var myDisplayFormat: String
    fileprivate var myPriority: Int
    fileprivate var myNotes: String!
    fileprivate var mycalendarItemIdentifier: String!
    
    var reminderCalendar: EKCalendar?
    
    var displaySpecialFormat: String
        {
        get {
            return myDisplayFormat
        }
        set {
            myDisplayFormat = newValue
        }
    }
    
    var priority: Int
        {
        get {
            return myPriority
        }
        set {
            myPriority = newValue
        }
    }
    
    var calendarItemIdentifier: String!
        {
        get {
            return mycalendarItemIdentifier
        }
        set {
            mycalendarItemIdentifier = newValue
        }
    }
    
    var notes: String!
        {
        get {
            return myNotes
        }
        set {
            myNotes = newValue
        }
    }
    
    init(reminderText: String, reminderCalendar: EKCalendar)
    {
        self.reminderText = reminderText
        self.myDisplayFormat = ""
        self.myPriority = 0
        self.myNotes = ""
        self.reminderCalendar = reminderCalendar
        self.mycalendarItemIdentifier = ""
    }
    
    init()
    {
        self.reminderText = ""
        self.myDisplayFormat = ""
        self.myPriority = 0
        self.myNotes = ""
        self.reminderCalendar = nil
        self.mycalendarItemIdentifier = ""
    }
    
}

class iOSReminder
{
    fileprivate var reminderStore: EKEventStore!
    fileprivate var targetReminderCal: EKCalendar!
    fileprivate var reminderDetails: [ReminderData] = Array()
    fileprivate var reminderRecords: [EKReminder] = Array()
    
    init()
    {
        reminderStore = EKEventStore()
        reminderStore.requestAccess(to: EKEntityType.reminder,
            completion: {(granted: Bool, error: Error?) in
                if !granted {
                    print("Access to reminder store not granted")
                }
        })
    }
    
    var reminders: [EKReminder]
        {
        get
        {
            return reminderRecords
        }
    }
    
    func parseReminderDetails (_ search: String)
    {
        let cals = reminderStore.calendars(for: EKEntityType.reminder)
        var myCalFound = false
    
        for cal in cals
        {
            if cal.title == search
            {
                myCalFound = true
                targetReminderCal = cal
            }
        }
    
        if myCalFound
        {
            let predicate = reminderStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [targetReminderCal])

            var asyncDone = false
        
            reminderStore.fetchReminders(matching: predicate, completion: {reminders in
                for reminder in reminders!
                {
                    let workingString: ReminderData = ReminderData(reminderText: reminder.title, reminderCalendar: reminder.calendar)
 
                    if reminder.notes != nil
                    {
                        workingString.notes = reminder.notes!
                    }
                    workingString.priority = reminder.priority
                    workingString.calendarItemIdentifier = reminder.calendarItemIdentifier
                    self.reminderDetails.append(workingString)
                    self.reminderRecords.append(reminder)
                }
                asyncDone = true
            })
        
            // Bit of a nasty workaround but this is to allow async to finish
        
            while !asyncDone
            {
                usleep(500)
            }
        }
    }
    
    func displayReminder() -> [TableData]
    {
        var tableContents: [TableData] = [TableData]()
        
        // Build up the details we want to show ing the calendar
        
        if reminderDetails.count == 0
        {
            writeRowToArray("No reminders list found", table: &tableContents)
        }
        else
        {
            for myReminder in reminderDetails
            {
                let myString = "\(myReminder.reminderText)"
                
                switch myReminder.priority
                {
                    case 1: writeRowToArray(myString, table: &tableContents, displayFormat: "Red")  //  High priority
                    
                    case 5: writeRowToArray(myString , table: &tableContents, displayFormat: "Orange") // Medium priority
                    
                    default: writeRowToArray(myString , table: &tableContents)
                }
            }
   
        }
        return tableContents
    }
}

func parsePastMeeting(_ meetingID: String) -> [task]
{
    // Get the the details for the meeting, in order to determine the previous task ID
    var myReturnArray: [task] = Array()
    
    let myData = myDatabaseConnection.loadAgenda(meetingID, teamID: currentUser.currentTeam!.teamID)
    
    if myData.count == 0
    {
        // No meeting found, so no further action
    }
    else
    {
        for myItem in myData
        {
            var myArray: [task] = Array()
            let myData2 = myDatabaseConnection.getMeetingsTasks(myItem.meetingID!)
            
            for myItem2 in myData2
            {
                let newTask = task(taskID: myItem2.taskID)
                if newTask.status != "Closed"
                {
                    myArray.append(newTask)
                }
            }
            
            if myItem.previousMeetingID != ""
            {
                myReturnArray = parsePastMeeting(myItem.previousMeetingID!)
                
                for myWork in myArray
                {
                    myReturnArray.append(myWork)
                }
            }
            else
            {
                myReturnArray = myArray
            }
        }
    }
    
    return myReturnArray
}

extension coreDatabase
{
    func searchPastAgendaByPartialMeetingIDBeforeStart(_ searchText: String, meetingStartDate: NSDate, teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID contains \"\(searchText)\") && (startTime <= %@) && (updateType != \"Delete\") && (teamID == \(teamID))", meetingStartDate as CVarArg)
        
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
    
    func searchPastAgendaWithoutPartialMeetingIDBeforeStart(_ searchText: String, meetingStartDate: NSDate, teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(teamID == \(teamID))  && (updateType != \"Delete\") && (startTime <= %@) && (not meetingID contains \"\(searchText)\") ", meetingStartDate as CVarArg)
        
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
    
    func listAgendaReverseDateBeforeStart(_ meetingStartDate: NSDate, teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime <= %@) && (updateType != \"Delete\") && (teamID == \(teamID))", meetingStartDate as CVarArg)
        
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
    
    func searchPastAgendaByPartialMeetingIDAfterStart(_ searchText: String, meetingStartDate: NSDate, teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID contains \"\(searchText)\") && (startTime >= %@) && (updateType != \"Delete\") && (teamID == \(teamID))", meetingStartDate as CVarArg)
        
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
    
    func searchPastAgendaWithoutPartialMeetingIDAfterStart(_ searchText: String, meetingStartDate: NSDate, teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(updateType != \"Delete\") && (teamID == \(teamID)) && NOT (meetingID contains \"\(searchText)\") && (startTime >= %@)", meetingStartDate as CVarArg)
        
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
    
    func listAgendaReverseDateAfterStart(_ meetingStartDate: NSDate, teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime >= %@) && (updateType != \"Delete\") && (teamID == \(teamID))", meetingStartDate as CVarArg)
        
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
    
    func saveAgenda(_ meetingID: String, previousMeetingID : String, name: String, chair: String, minutes: String, location: String, startTime: Date, endTime: Date, minutesType: String, teamID: Int32, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myAgenda: MeetingAgenda
        
        let myAgendas = loadAgenda(meetingID, teamID: teamID)
        
        if myAgendas.count == 0
        {
            myAgenda = MeetingAgenda(context: objectContext)
            myAgenda.meetingID = meetingID
            myAgenda.previousMeetingID = previousMeetingID
            myAgenda.name = name
            myAgenda.chair = chair
            myAgenda.minutes = minutes
            myAgenda.location = location
            myAgenda.startTime = startTime as NSDate
            myAgenda.endTime = endTime as NSDate
            myAgenda.minutesType = minutesType
            myAgenda.teamID = teamID
            if updateType == "CODE"
            {
                myAgenda.updateTime =  NSDate()
                myAgenda.updateType = "Add"
            }
            else
            {
                myAgenda.updateTime = updateTime as NSDate
                myAgenda.updateType = updateType
            }
        }
        else
        {
            myAgenda = myAgendas[0]
            myAgenda.previousMeetingID = previousMeetingID
            myAgenda.name = name
            myAgenda.chair = chair
            myAgenda.minutes = minutes
            myAgenda.location = location
            myAgenda.startTime = startTime as NSDate
            myAgenda.endTime = endTime as NSDate
            myAgenda.minutesType = minutesType
            myAgenda.teamID = teamID
            if updateType == "CODE"
            {
                myAgenda.updateTime =  NSDate()
                if myAgenda.updateType != "Add"
                {
                    myAgenda.updateType = "Update"
                }
            }
            else
            {
                myAgenda.updateTime = updateTime as NSDate
                myAgenda.updateType = updateType
            }
        }
        
        saveContext()
    }
 
    func replaceAgenda(_ meetingID: String, previousMeetingID : String, name: String, chair: String, minutes: String, location: String, startTime: Date, endTime: Date, minutesType: String, teamID: Int32, updateTime: Date =  Date(), updateType: String = "CODE")
    {
        let myAgenda = MeetingAgenda(context: objectContext)
        myAgenda.meetingID = meetingID
        myAgenda.previousMeetingID = previousMeetingID
        myAgenda.name = name
        myAgenda.chair = chair
        myAgenda.minutes = minutes
        myAgenda.location = location
        myAgenda.startTime = startTime as NSDate
        myAgenda.endTime = endTime as NSDate
        myAgenda.minutesType = minutesType
        myAgenda.teamID = teamID
        if updateType == "CODE"
        {
            myAgenda.updateTime =  NSDate()
            myAgenda.updateType = "Add"
        }
        else
        {
            myAgenda.updateTime = updateTime as NSDate
            myAgenda.updateType = updateType
        }
        
        saveContext()
    }
    
    func loadPreviousAgenda(_ meetingID: String, teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(previousMeetingID == \"\(meetingID)\") && (updateType != \"Delete\") && (teamID == \(teamID))")
        
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
    
    func loadAgenda(_ meetingID: String, teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") && (updateType != \"Delete\") && (teamID == \(teamID))")
        
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
    
    func updatePreviousAgendaID(_ previousMeetingID: String, meetingID: String, teamID: Int32)
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(meetingID == \"\(meetingID)\") && (updateType != \"Delete\") && (teamID == \(teamID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myResult in fetchResults
            {
                myResult.previousMeetingID = previousMeetingID
                myResult.updateTime =  NSDate()
                if myResult.updateType != "Add"
                {
                    myResult.updateType = "Update"
                }
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func loadAgendaForProject(_ projectName: String, teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(name contains \"\(projectName)\") && (updateType != \"Delete\") && (teamID == \(teamID))")
        
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

    func getAgendaForDateRange(_ inStartDate: NSDate, endDate: NSDate, teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(startTime >= %@) && (endTime <= %@) && (updateType != \"Delete\") && (teamID == \(teamID))", inStartDate as CVarArg, endDate as CVarArg)
        
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

    func resetMeetings()
    {
        let fetchRequest1 = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults1 = try objectContext.fetch(fetchRequest1)
            for myMeeting in fetchResults1
            {
                myMeeting.updateTime =  NSDate()
                myMeeting.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
        
        resetMeetingAttendees()
        
        resetMeetingAgendaItems()
        
        resetMeetingTasks()
        
        resetMeetingSupportingDocs()        
    }
    
    func clearDeletedMeetingAgenda(predicate: NSPredicate)
    {
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
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearSyncedMeetingAgenda(predicate: NSPredicate)
    {
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
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func initialiseTeamForMeetingAgenda(_ teamID: Int32)
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
                    myItem.teamID = teamID
                }
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func getMeetingAgendasForSync(_ syncDate: Date) -> [MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
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

    func deleteAllMeetingAgendaRecords()
    {
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
    }
    
    func getAgendaForTeam(_ teamID: Int32)->[MeetingAgenda]
    {
        let fetchRequest = NSFetchRequest<MeetingAgenda>(entityName: "MeetingAgenda")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        
        var predicate: NSPredicate
        
        predicate = NSPredicate(format: "(teamID == \(teamID)) && (updateType != \"Delete\")")
        
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

extension CloudKitInteraction
{
    func saveMeetingAgendaToCloudKit()
    {
        for myItem in myDatabaseConnection.getMeetingAgendasForSync(myDatabaseConnection.getSyncDateForTable(tableName: "MeetingAgenda"))
        {
            saveMeetingAgendaRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }

    func updateMeetingAgendaInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND (teamID == \(teamID))", myDatabaseConnection.getSyncDateForTable(tableName: "MeetingAgenda") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            self.recordCount += 1

            self.updateMeetingAgendaRecord(record, teamID: currentUser.currentTeam!.teamID)
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

    func deleteMeetingAgenda(teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
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

    func replaceMeetingAgendaInCoreData(teamID: Int32)
    {
        let predicate: NSPredicate = NSPredicate(format: "(teamID == \(teamID))")
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)

        let operation = CKQueryOperation(query: query)
        
        waitFlag = true
        
        operation.recordFetchedBlock = { (record) in
            let meetingID = record.object(forKey: "meetingID") as! String
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
            let chair = record.object(forKey: "chair") as! String
            let endTime = record.object(forKey: "endTime") as! Date
            let location = record.object(forKey: "location") as! String
            let minutes = record.object(forKey: "minutes") as! String
            let minutesType = record.object(forKey: "minutesType") as! String
            let name = record.object(forKey: "name") as! String
            let previousMeetingID = record.object(forKey: "previousMeetingID") as! String
            let startTime = record.object(forKey: "meetingStartTime") as! Date
            let teamID = record.object(forKey: "actualTeamID") as! Int32
            
            myDatabaseConnection.replaceAgenda(meetingID, previousMeetingID : previousMeetingID, name: name, chair: chair, minutes: minutes, location: location, startTime: startTime, endTime: endTime, minutesType: minutesType, teamID: teamID, updateTime: updateTime, updateType: updateType)
            usleep(useconds_t(self.sleepTime))
        }
        
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(queryOperation: operation, onOperationQueue: operationQueue)
        
        while waitFlag
        {
            sleep(UInt32(0.5))
        }
    }

    func saveMeetingAgendaRecordToCloudKit(_ sourceRecord: MeetingAgenda, teamID: Int32)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID!)\") && (actualTeamID == \(sourceRecord.teamID)) AND (teamID == \(teamID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
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
                    record!.setValue(sourceRecord.chair, forKey: "chair")
                    record!.setValue(sourceRecord.endTime, forKey: "endTime")
                    record!.setValue(sourceRecord.location, forKey: "location")
                    record!.setValue(sourceRecord.minutes, forKey: "minutes")
                    record!.setValue(sourceRecord.minutesType, forKey: "minutesType")
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.previousMeetingID, forKey: "previousMeetingID")
                    record!.setValue(sourceRecord.startTime, forKey: "meetingStartTime")
                    
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
                    let record = CKRecord(recordType: "MeetingAgenda")
                    record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    record.setValue(sourceRecord.chair, forKey: "chair")
                    record.setValue(sourceRecord.endTime, forKey: "endTime")
                    record.setValue(sourceRecord.location, forKey: "location")
                    record.setValue(sourceRecord.minutes, forKey: "minutes")
                    record.setValue(sourceRecord.minutesType, forKey: "minutesType")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.previousMeetingID, forKey: "previousMeetingID")
                    record.setValue(sourceRecord.startTime, forKey: "meetingStartTime")
                    record.setValue(sourceRecord.teamID, forKey: "actualTeamID")
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

    func updateMeetingAgendaRecord(_ sourceRecord: CKRecord, teamID: Int32)
    {
        let meetingID = sourceRecord.object(forKey: "meetingID") as! String
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
        let chair = sourceRecord.object(forKey: "chair") as! String
        let endTime = sourceRecord.object(forKey: "endTime") as! Date
        let location = sourceRecord.object(forKey: "location") as! String
        let minutes = sourceRecord.object(forKey: "minutes") as! String
        let minutesType = sourceRecord.object(forKey: "minutesType") as! String
        let name = sourceRecord.object(forKey: "name") as! String
        let previousMeetingID = sourceRecord.object(forKey: "previousMeetingID") as! String
        let startTime = sourceRecord.object(forKey: "meetingStartTime") as! Date
        let teamID = sourceRecord.object(forKey: "actualTeamID") as! Int32
        
        myDatabaseConnection.saveAgenda(meetingID, previousMeetingID : previousMeetingID, name: name, chair: chair, minutes: minutes, location: location, startTime: startTime, endTime: endTime, minutesType: minutesType, teamID: teamID, updateTime: updateTime, updateType: updateType)
    }
}
