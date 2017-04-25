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

class myCalendarItem
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
    fileprivate var myEventID: String = ""
    fileprivate var myEvent: EKEvent?
    fileprivate var myAttendees: [meetingAttendee] = Array()
    fileprivate var myChair: String = ""
    fileprivate var myMinutes: String = ""
    fileprivate var myPreviousMinutes: String = ""
    fileprivate var myNextMeeting: String = ""
    fileprivate var myMinutesType: String = ""
    fileprivate var myAgendaItems: [meetingAgendaItem] = Array()
    fileprivate var myTeamID: Int = 0

    // Seup Date format for display
    fileprivate var startDateFormatter = DateFormatter()
    fileprivate var endDateFormatter = DateFormatter()
    fileprivate var dateFormat = DateFormatter.Style.medium
    fileprivate var timeFormat = DateFormatter.Style.short
    
    // This is used in order to allow to identify unique instances of a repeating Event
    
    fileprivate var myUniqueIdentifier: String = ""
    fileprivate var myEventStore: EKEventStore!
    
    // Flag to indicate if we have data saved in database as well
    
    fileprivate var mySavedData: Bool = false
    fileprivate var saveCalled: Bool = false

    init(inEventStore: EKEventStore, inEvent: EKEvent, inAttendee: EKParticipant?, teamID: Int)
    {
        startDateFormatter.dateStyle = dateFormat
        startDateFormatter.timeStyle = timeFormat
        endDateFormatter.timeStyle = timeFormat
        myEventStore = inEventStore
        
        myTeamID = teamID
        // Check to see if there is an existing entry for the meeting
        
        let mySavedValues = myDatabaseConnection.loadAgenda("\(inEvent.calendarItemExternalIdentifier) Date: \(inEvent.startDate)", inTeamID: myTeamID)
        
        if mySavedValues.count > 0
        {
            myEvent = inEvent
            myTitle = mySavedValues[0].name!
            myStartDate = mySavedValues[0].startTime! as Date
            myEndDate = mySavedValues[0].endTime! as Date
            myLocation = mySavedValues[0].location!
            myPreviousMinutes = mySavedValues[0].previousMeetingID!
            myEventID = mySavedValues[0].meetingID!
            myChair = mySavedValues[0].chair!
            myMinutes = mySavedValues[0].minutes!
            myLocation = mySavedValues[0].location!
            myMinutesType = mySavedValues[0].minutesType!
            mySavedData = true
        }
        else
        {
            myEvent = inEvent
            myTitle = inEvent.title
            myStartDate = inEvent.startDate
            myEndDate = inEvent.endDate
            if inEvent.location == nil
            {
                myLocation = ""
            }
            else
            {
                myLocation = inEvent.location!
            }
        
            if inEvent.recurrenceRules != nil
            {
                // This is a recurring event
                let myWorkingRecur: NSArray = inEvent.recurrenceRules! as NSArray
            
                for myItem in myWorkingRecur
                {
                    myRecurrenceFrequency = (myItem as AnyObject).interval
                    let testFrequency: EKRecurrenceFrequency = (myItem as AnyObject).frequency
                    myRecurrence = Int(testFrequency.rawValue)
                }
            }
        }
        // Need to validate this works when displaying by person and also by project
        if inAttendee != nil
        {
            myStatus = Int(inAttendee!.participantStatus.rawValue)
            myType = Int(inAttendee!.participantType.rawValue)
        }
        
        loadAttendees()
        loadAgendaItems()
    }
    
    init(inEventStore: EKEventStore, inMeetingAgenda: MeetingAgenda)
    {
        startDateFormatter.dateStyle = dateFormat
        startDateFormatter.timeStyle = timeFormat
        endDateFormatter.timeStyle = timeFormat
        myEventStore = inEventStore
        
        myTitle = inMeetingAgenda.name!
        myStartDate = inMeetingAgenda.startTime as Date!
        myEndDate = inMeetingAgenda.endTime as Date!
        myLocation = inMeetingAgenda.location!
        myPreviousMinutes = inMeetingAgenda.previousMeetingID!
        myEventID = inMeetingAgenda.meetingID!
        myChair = inMeetingAgenda.chair!
        myMinutes = inMeetingAgenda.minutes!
        myLocation = inMeetingAgenda.location!
        myMinutesType = inMeetingAgenda.minutesType!
        myTeamID = inMeetingAgenda.teamID as! Int
        
        loadAttendees()
        loadAgendaItems()
    }
    
    init(inEventStore: EKEventStore, inMeetingID: String, teamID: Int)
    {
        myTeamID = teamID
        let mySavedValues = myDatabaseConnection.loadAgenda(inMeetingID, inTeamID: myTeamID)
        
        if mySavedValues.count > 0
        {
            myTitle = mySavedValues[0].name!
            myStartDate = mySavedValues[0].startTime! as Date
            myEndDate = mySavedValues[0].endTime! as Date
            myLocation = mySavedValues[0].location!
            myPreviousMinutes = mySavedValues[0].previousMeetingID!
            myEventID = mySavedValues[0].meetingID!
            myChair = mySavedValues[0].chair!
            myMinutes = mySavedValues[0].minutes!
            myLocation = mySavedValues[0].location!
            myMinutesType = mySavedValues[0].minutesType!
            mySavedData = true
        }

        startDateFormatter.dateStyle = dateFormat
        startDateFormatter.timeStyle = timeFormat
        endDateFormatter.timeStyle = timeFormat
        myEventStore = inEventStore
        
        // We neeed to go and the the event details from the calendar, if they exist
        
        let nextEvent = iOSCalendar(inEventStore: myEventStore)
        
        nextEvent.loadCalendarForEvent(myEventID, inStartDate: myStartDate, teamID: myTeamID)
        
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
            myEventID = "\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)"
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
            
            if myEventID != ""
            {
                let myItems = myDatabaseConnection.loadPreviousAgenda(myEventID, inTeamID: myTeamID)
            
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
    
    var eventID: String
    {
        get
        {
            if myEventID != ""
            {
                return myEventID
            }
            else
            {
                myEventID = "\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)"
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
    
    var teamID: Int
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
    
    func addAttendee(_ inName: String, inEmailAddress: String, inType: String, inStatus: String)
    {
        // make sure we have saved the Agenda
        
        save()

        let attendee: meetingAttendee = meetingAttendee()
        attendee.name = inName
        attendee.emailAddress = inEmailAddress
        attendee.type = inType
        attendee.status = inStatus
        attendee.meetingID = eventID
        attendee.save()
        
        myAttendees.append(attendee)
    }
    
    fileprivate func initaliseAttendee(_ inName: String, inEmailAddress: String, inType: String, inStatus: String)
    {
        let attendee: meetingAttendee = meetingAttendee()
        attendee.name = inName
        attendee.emailAddress = inEmailAddress
        attendee.type = inType
        attendee.status = inStatus
        attendee.meetingID = eventID
        
        myAttendees.append(attendee)
    }

    func removeAttendee(_ inIndex: Int)
    {
        // we should know the index of the item we want to delete from the control, so only need its index in order to perform the required action
        myAttendees.remove(at: inIndex)
        
        // Save Attendees
        
        myAttendees[inIndex].delete()
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
                
                addAttendee(attendee.name!, inEmailAddress: emailSplit[1], inType: "Participant", inStatus: "Invited")
            }
            
//            let emailText: String = "\(attendee.url)"
//            let emailStartPos = emailText.characters.index(of: ":")
//            let nextPlace = emailText.index(after: (emailStartPos)!)
//            var emailAddress: String = ""
//            if nextPlace != nil
//            {
//                let emailEndPos = emailText.characters.index(before: emailText.endIndex)
//                emailAddress = emailText[nextPlace...emailEndPos]
//            }
//            
//            addAttendee(attendee.name!, inEmailAddress: emailAddress, inType: "Participant", inStatus: "Invited")
        }
    }
    
    func save()
    {
        if myEvent != nil
        {
            myEventID = "\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)"
            
            /*
            if myEvent!.hasRecurrenceRules
            {  // recurring event
            // if we do not have a "unique" id for this occurrence then we need to save the calendar event, with a small change, and then get the event ID again
            
            if myEvent!.isDetached
            { // Event is already detached from the recurring event
            // Do nothing
            }
            else
            { // Not found
            if myEvent!.hasNotes
            {
            myEvent!.notes = myEvent!.notes! + "."
            }
            else
            {
            myEvent!.notes = "."
            }
            do {
            try eventStore.saveEvent(myEvent!,span: .ThisEvent, commit: true)
            } catch _ {
            }
            
            myEventID = myEvent!.eventIdentifier
            }
            }
            */
        }
        
        //  Here we save the Agenda details
        
        // Save Agenda details
        if mySavedData
        {
            myDatabaseConnection.createAgenda(self)
        }
        else
        {
            myDatabaseConnection.createAgenda(self)
        }
        
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
        let myAgenda = myDatabaseConnection.loadAgenda(myEventID, inTeamID: myTeamID)[0]
        
        myCloudDB.saveMeetingAgendaRecordToCloudKit(myAgenda)
        
        saveCalled = false
    }
    
    func loadAgenda()
    {
        // Used where the invite is no longer in the calendar, and also to load up historical items for the "minutes" views
        
        var mySavedValues: [MeetingAgenda]!
        if myEventID == ""
        {
            mySavedValues = myDatabaseConnection.loadAgenda("\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)", inTeamID: myTeamID)
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAgenda(myEventID, inTeamID: myTeamID)
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
        
        if myEventID == ""
        {
            mySavedValues = myDatabaseConnection.loadAttendees("\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)")
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAttendees(myEventID)
        }
        
        myAttendees.removeAll(keepingCapacity: false)
        
        if myEvent == nil
        { // No calendar event has been loaded, so go straight from table
            for savedAttendee in mySavedValues
            {
                initaliseAttendee(savedAttendee.name!, inEmailAddress: savedAttendee.email!, inType: savedAttendee.type!, inStatus: savedAttendee.attendenceStatus!)
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

//                                    let emailText: String = "\(invitee.url)"
//                                    let emailStartPos = emailText.characters.index(of: ":")
//                                    let nextPlace = emailText.index(after: (emailStartPos)!)
//                                    var emailAddress: String = ""
//                                    if nextPlace != nil
//                                    {
//                                        let emailEndPos = emailText.characters.index(before: emailText.endIndex)
//                                        emailAddress = emailText[nextPlace...emailEndPos]
//                                    }
                    
                                        initaliseAttendee(invitee.name!, inEmailAddress: emailSplit[1], inType: "Participant", inStatus: "Invited")
             
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
                                initaliseAttendee(tempName, inEmailAddress: tempEmail, inType: tempType, inStatus: tempStatus)
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
            
                    if myEventID == ""
                    {
                        mySavedValues = myDatabaseConnection.loadAttendees("\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)")
                    }
                    else
                    {
                        mySavedValues = myDatabaseConnection.loadAttendees(myEventID)
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
                                
//                                let emailText: String = "\(invitee.url)"
//                                let emailStartPos = emailText.characters.index(of: ":")
//                                let nextPlace = emailText.index(after: (emailStartPos)!)
//                                var emailAddress: String = ""
//                                if nextPlace != nil
//                                {
//                                    let emailEndPos = emailText.characters.index(before: emailText.endIndex)
//                                    emailAddress = emailText[nextPlace...emailEndPos]
//                                }
                
                                    addAttendee(invitee.name!, inEmailAddress: emailSplit[1], inType: "Participant", inStatus: "Invited")
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
                              
//                            let emailText: String = "\(invitee.url)"
//                            let emailStartPos = emailText.characters.index(of: ":")
//                            let nextPlace = emailText.index(after: (emailStartPos)!)
//                            var emailAddress: String = ""
//                            if nextPlace != nil
//                            {
//                                let emailEndPos = emailText.characters.index(before: emailText.endIndex)
//                                emailAddress = emailText[nextPlace...emailEndPos]
//                            }
                    
                                addAttendee(invitee.name!, inEmailAddress: emailSplit[1], inType: "Participant", inStatus: "Invited")
                            }
                        }
                    }
                }
            }
            else
            { // In the past so we just used the entried from the table
                for savedAttendee in mySavedValues
                {
                    initaliseAttendee(savedAttendee.name!, inEmailAddress: savedAttendee.email!, inType: savedAttendee.type!, inStatus: savedAttendee.attendenceStatus!)
                }
            }
        }
    }
    
    func loadAgendaItems()
    {
        var mySavedValues: [MeetingAgendaItem]!
        
        if myEventID == ""
        {
            mySavedValues = myDatabaseConnection.loadAgendaItem("\(myEvent!.calendarItemExternalIdentifier) Date: \(myEvent!.startDate)")
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAgendaItem(myEventID)
        }
        
        myAgendaItems.removeAll(keepingCapacity: false)
        
        if mySavedValues.count > 0
        {
            var runningMeetingOrder: Int = 0
            
            for savedAgenda in mySavedValues
            {
                let myAgendaItem =  meetingAgendaItem(inMeetingID: savedAgenda.meetingID!, inAgendaID:savedAgenda.agendaID as! Int)
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
        
    func updateAgendaItems(_ inAgendaID: Int, inTitle: String, inOwner: String, inStatus: String, inDecisionMade: String, inDiscussionNotes: String, inTimeAllocation: Int, inActualStartTime: Date, inActualEndTime: Date)
    {
        for myAgendaItem in myAgendaItems
        {
            if myAgendaItem.agendaID == inAgendaID
            {
                myAgendaItem.status = inStatus
                myAgendaItem.decisionMade = inDecisionMade
                myAgendaItem.discussionNotes = inDiscussionNotes
                myAgendaItem.timeAllocation = inTimeAllocation
                myAgendaItem.owner = inOwner
                myAgendaItem.title = inTitle
                myAgendaItem.actualEndTime = inActualEndTime
                myAgendaItem.actualStartTime = inActualStartTime
            }
            break
        }
    }
    
    fileprivate func writeLine(_ inTargetString: String, inLineString: String) -> String
    {
        var myString = inTargetString
        
        if inTargetString.characters.count > 0
        {
            myString += "\n"
        }
        
        myString += inLineString
        
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
        
        myExportString = writeLine(myExportString, inLineString: myLine)
        
        myExportString = writeLine(myExportString, inLineString: "")
        
        myLine = "       Meeting: \(myTitle)"
        myExportString = writeLine(myExportString, inLineString: myLine)
        
        myExportString = writeLine(myExportString, inLineString: "")
        
        myLine = "On: \(displayScheduledDate)    "
        
        if myLocation != ""
        {
            myLine += "At: \(myLocation)"
        }
        myExportString = writeLine(myExportString, inLineString: myLine)
        
        myExportString = writeLine(myExportString, inLineString: "")
        
        myLine = ""
        
        if myChair != ""
        {
            myLine += "Chair: \(myChair)       "
        }
        
        if myMinutes != ""
        {
            myLine += "Minutes: \(myMinutes)"
        }
        
        myExportString = writeLine(myExportString, inLineString: myLine)
        myExportString = writeLine(myExportString, inLineString: "")
        
        if myPreviousMinutes != ""
        {
            // Get the previous meetings details
            
            let myItems = myDatabaseConnection.loadAgenda(myPreviousMinutes, inTeamID: myTeamID)
            
            for myItem in myItems
            {
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                
                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                
                myLine = "Previous Meeting: \(myDisplayString)"
                myExportString = writeLine(myExportString, inLineString: myLine)
            }
        }
        
        //  Now we are going to get the Agenda Items
        
        if myPreviousMinutes != ""
        { // Previous meeting exists
            // Does the previous meeting have any tasks
            let myData = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
            
            if myData.count > 0
            {  // There are tasks for the previous meeting
                myExportString = writeLine(myExportString, inLineString: "")
                myExportString = writeLine(myExportString, inLineString: "")
                myExportString = writeLine(myExportString, inLineString: "")
                myLine = "Actions from Previous Meeting"
                myExportString = writeLine(myExportString, inLineString: myLine)
                myExportString = writeLine(myExportString, inLineString: "")
                
                var myTaskList: [task] = Array()
                
                let myData2 = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
                
                for myItem2 in myData2
                {
                    let newTask = task(taskID: myItem2.taskID as! Int)
                    myTaskList.append(newTask)
                }
                
                // We want to build up a table here to display the data
                
                myLine = "||Task"
                myLine += "||Status"
                myLine += "||Project"
                myLine += "||Due Date"
                myLine += "||Context||"
                
                myExportString = writeLine(myExportString, inLineString: myLine)
                
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
                    
                    myExportString = writeLine(myExportString, inLineString: myLine)
                }
            }
            
            // Outstanding previous meetings
            
            let myOutstandingTasks = parsePastMeeting(myPreviousMinutes)
            
            if myOutstandingTasks.count > 0
            {
                // We want to build up a table here to display the data
                myExportString = writeLine(myExportString, inLineString: "")
                myExportString = writeLine(myExportString, inLineString: "")
                myLine = "Outstanding Actions from Previous Meetings"
                myExportString = writeLine(myExportString, inLineString: myLine)
                myExportString = writeLine(myExportString, inLineString: "")
                
                myLine = "||Task"
                myLine += "||Status"
                myLine += "||Project"
                myLine += "||Due Date"
                myLine += "||Context||"
                
                myExportString = writeLine(myExportString, inLineString: myLine)
                
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
                    myExportString = writeLine(myExportString, inLineString: myLine)
                }
            }
        }
        
        myExportString = writeLine(myExportString, inLineString: "")
        myExportString = writeLine(myExportString, inLineString: "")
        
        myLine = "                Agenda Items"
        myExportString = writeLine(myExportString, inLineString: myLine)
        myExportString = writeLine(myExportString, inLineString: "")
        
        if myStartDate.compare(Date()) == ComparisonResult.orderedAscending
        {  // Historical so show Minutes
            
            for myItem in myAgendaItems
            {
                myLine = "\(myItem.title)"
                myExportString = writeLine(myExportString, inLineString: myLine)
                
                myExportString = writeLine(myExportString, inLineString: "")
                
                if myItem.discussionNotes != ""
                {
                    myLine = "Discussion Notes"
                    myExportString = writeLine(myExportString, inLineString: myLine)
                
                    myLine = "\(myItem.discussionNotes)"
                    myExportString = writeLine(myExportString, inLineString: myLine)
                
                    myExportString = writeLine(myExportString, inLineString: "")
                }
                
                if myItem.decisionMade != ""
                {
                    myLine = "Decisions Made"
                    myExportString = writeLine(myExportString, inLineString: myLine)
                
                    myLine = "\(myItem.decisionMade)"
                    myExportString = writeLine(myExportString, inLineString: myLine)
                
                    myExportString = writeLine(myExportString, inLineString: "")
                }
                
                if myItem.tasks.count != 0
                {
                    myLine = "Actions"
                    myExportString = writeLine(myExportString, inLineString: myLine)
                
                    myLine = "||Task"
                    myLine += "||Status"
                    myLine += "||Project"
                    myLine += "||Due Date"
                    myLine += "||Context||"
                    
                    myExportString = writeLine(myExportString, inLineString: myLine)
                    
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
                        
                        myExportString = writeLine(myExportString, inLineString: myLine)
                    }
                    myExportString = writeLine(myExportString, inLineString: "")
                }
            }
        }
        else
        {  // Future so show Agenda
            myLine = "||Time"
            myLine += "||Item"
            myLine += "||Owner||"
            myExportString = writeLine(myExportString, inLineString: myLine)
            
            if myPreviousMinutes != ""
            { // Previous meeting exists
                // Does the previous meeting have any tasks
                let myData = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
                
                if myData.count > 0
                {  // There are tasks for the previous meeting
                    myLine = "||\(myDateFormatter.string(from: myWorkingTime!))"
                    myLine += "||Actions from Previous Meeting"
                    myLine += "||All||"
                    myExportString = writeLine(myExportString, inLineString: myLine)
                    
                    myWorkingTime = myCalendar.date(
                        byAdding: .minute,
                        value: 10,
                        to: myWorkingTime!)!
                }
            }
            
            myExportString = writeLine(myExportString, inLineString: "")
            
            for myItem in myAgendaItems
            {
                myLine = "||\(myDateFormatter.string(from: myWorkingTime!))"
                myLine += "||\(myItem.title)"
                myLine += "||\(myItem.owner)||"
                myExportString = writeLine(myExportString, inLineString: myLine)
                
                myWorkingTime = myCalendar.date(
                    byAdding: .minute,
                    value: myItem.timeAllocation,
                    to: myWorkingTime!)!
                
            }
            
            myLine = "||\(myDateFormatter.string(from: myWorkingTime!))"
            myLine += "||Meeting Close"
            myLine += "||||"
            
            myExportString = writeLine(myExportString, inLineString: myLine)
        }
        
        if nextMeeting != ""
        {
            // Get the previous meetings details
            
            let myItems = myDatabaseConnection.loadAgenda(nextMeeting, inTeamID: myTeamID)
            
            for myItem in myItems
            {
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                
                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                
                myExportString = writeLine(myExportString, inLineString: "")
                myExportString = writeLine(myExportString, inLineString: "")
                
                myLine = "Next Meeting: \(myDisplayString)"
                myExportString = writeLine(myExportString, inLineString: myLine)
                
            }
        }
        return myExportString
    }
    
    fileprivate func writeHTMLLine(_ inTargetString: String, inLineString: String) -> String
    {
        var myString = inTargetString
        
        if inTargetString.characters.count > 0
        {
            myString += "<p>"
        }
        
        myString += inLineString
        
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
        
        myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        
        myLine = "<center><h2>\(myTitle)</h2></center>"
        myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        
        myExportString = writeHTMLLine(myExportString, inLineString: "")
        
        myLine = "On: \(displayScheduledDate)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        
        if myLocation != ""
        {
            myLine += "At: \(myLocation)"
        }
        
        myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        
        myExportString = writeHTMLLine(myExportString, inLineString: "")
        myLine = ""
        
        if myChair != ""
        {
            myLine += "Chair: \(myChair)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        }
        
        if myMinutes != ""
        {
            myLine += "Minutes: \(myMinutes)"
        }
        
        myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        myExportString = writeHTMLLine(myExportString, inLineString: "")
        
        if myPreviousMinutes != ""
        {
            // Get the previous meetings details
            
            let myItems = myDatabaseConnection.loadAgenda(myPreviousMinutes, inTeamID: myTeamID)
            
            for myItem in myItems
            {
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                
                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                
                myLine = "Previous Meeting: \(myDisplayString)"
                myExportString = writeHTMLLine(myExportString, inLineString: myLine)
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
                myExportString = writeHTMLLine(myExportString, inLineString: myLine)
                
                var myTaskList: [task] = Array()
                
                let myData2 = myDatabaseConnection.getMeetingsTasks(myPreviousMinutes)
                
                for myItem2 in myData2
                {
                    let newTask = task(taskID: myItem2.taskID as! Int)
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
                myExportString = writeHTMLLine(myExportString, inLineString: myTaskTable)
            }
            
            // Outstanding previous meetings
            
            let myOutstandingTasks = parsePastMeeting(myPreviousMinutes)
                
            if myOutstandingTasks.count > 0
            {
                // We want to build up a table here to display the data
                myLine = "<center><h3>Outstanding Actions from Previous Meetings</h3></center>"
                myExportString = writeHTMLLine(myExportString, inLineString: myLine)
                
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
                myExportString = writeHTMLLine(myExportString, inLineString: myTaskTable)
            }
        }
        
        myLine = "<center><h3>Agenda Items</h3></center>"
        myExportString = writeHTMLLine(myExportString, inLineString: myLine)
        
        if myStartDate.compare(Date()) == ComparisonResult.orderedAscending
        {  // Historical so show Minutes

            for myItem in myAgendaItems
            {
                myLine = "<h4>\(myItem.title)</h4>"
                myExportString = writeHTMLLine(myExportString, inLineString: myLine)
            
                myExportString = writeHTMLLine(myExportString, inLineString: "")
                
                if myItem.discussionNotes != ""
                {
                    myLine = "<h5>Discussion Notes</h5>"
                    myExportString = writeHTMLLine(myExportString, inLineString: myLine)
                
                    myLine = "\(myItem.discussionNotes)"
                    myExportString = writeHTMLLine(myExportString, inLineString: myLine)

                    myExportString = writeHTMLLine(myExportString, inLineString: "")
                }
                
                if myItem.decisionMade != ""
                {
                    myLine = "<h5>Decisions Made</h5>"
                    myExportString = writeHTMLLine(myExportString, inLineString: myLine)
                
                    myLine = "\(myItem.decisionMade)"
                    myExportString = writeHTMLLine(myExportString, inLineString: myLine)

                    myExportString = writeHTMLLine(myExportString, inLineString: "")
                }
                
                if myItem.tasks.count != 0
                {
                    myLine = "<h5>Actions</h5>"
                    myExportString = writeHTMLLine(myExportString, inLineString: myLine)

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
                    myExportString = writeHTMLLine(myExportString, inLineString: myTaskTable)
                }
                myExportString = writeHTMLLine(myExportString, inLineString: "")
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
                    value: myItem.timeAllocation,
                    to: myWorkingTime!)!
                
            }
            
            myTaskTable += "<tr>"
            myTaskTable += "<td>\(myDateFormatter.string(from: myWorkingTime!))</td>"
            myTaskTable += "<td>Meeting Close</td>"
            myTaskTable += "<td></td>"
            myTaskTable += "</tr>"
            myTaskTable += "</table>"
            myExportString = writeHTMLLine(myExportString, inLineString: myTaskTable)
        }
        
        if nextMeeting != ""
        {
            // Get the previous meetings details
            
            let myItems = myDatabaseConnection.loadAgenda(nextMeeting, inTeamID: myTeamID)
            
            for myItem in myItems
            {
                let startDateFormatter = DateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.string(from: myItem.startTime! as Date)
                
                let myDisplayString = "\(myItem.name!) - \(myDisplayDate)"
                
                myExportString = writeHTMLLine(myExportString, inLineString: "")
                myExportString = writeHTMLLine(myExportString, inLineString: "")
                
                myLine = "<b>Next Meeting:</b> \(myDisplayString)"
                myExportString = writeHTMLLine(myExportString, inLineString: myLine)
                
            }
        }
        myExportString = writeHTMLLine(myExportString, inLineString: "</body></html>")
        return myExportString
    }
    
    func setNextMeeting(_ inCalendarItem: myCalendarItem)
    {
        // Need to update the "next meeting", to sets its previous meeting ID to be this one
            
        // check to see if there is already a meeting
        
        let nextMeetingID = inCalendarItem.eventID
        let tempAgenda = myDatabaseConnection.loadAgenda(nextMeetingID, inTeamID: myTeamID)
        
        if tempAgenda.count > 0
        { // existing record found, so update
            myDatabaseConnection.updatePreviousAgendaID(myEventID, inMeetingID: nextMeetingID, inTeamID: myTeamID)
            myNextMeeting = nextMeetingID
        }
        else
        { // No record found so insert
            inCalendarItem.previousMinutes = myEventID
            myNextMeeting = inCalendarItem.eventID
        }
    }
    
    func checkForEvent() -> Bool
    {
  //      var itemFound: Bool = false
        
        // Using the eventID get the calendar eventID and start date
        
 //       let myStringArr = myEventID.componentsSeparatedByString(" Date: ")
        
//    NSLog("Meeting Parts = \(myStringArr[0]) - \(myStringArr[1])")
        
        // Go an get the calendar entry
        
 //       let searchString = myStringArr[0]
        
 //       let myItems = myEventStore.calendarItemsWithExternalIdentifier(searchString)
        
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
    fileprivate var myEventStore: EKEventStore!
    fileprivate var eventDetails: [myCalendarItem] = Array()
    fileprivate var eventRecords: [EKEvent] = Array()

    init(inEventStore: EKEventStore)
    {
        myEventStore = inEventStore
    }
    
    var events: [EKEvent]
    {
        get
        {
            return eventRecords
        }
    }
    
    var calendarItems: [myCalendarItem]
    {
        get
        {
            return eventDetails
        }
    }
    
    func loadCalendarDetails(_ emailAddresses: [String], teamID: Int)
    {
        for myEmail in emailAddresses
        {
            parseCalendarByEmail(myEmail, teamID: teamID)
            loadMeetingsForContext(myEmail)
        }
        
        // Now sort the array into date order
        
         eventDetails.sort(by: {$0.startDate.timeIntervalSinceNow < $1.startDate.timeIntervalSinceNow})
    }
    
    func loadCalendarForEvent(_ inEventID: String, inStartDate: Date, teamID: Int)
    {
        /* The end date */
        //Calculate - Days * hours * mins * secs
        
        let myEndDateValue:TimeInterval = 60 * 60
        
        let endDate = inStartDate.addingTimeInterval(myEndDateValue)
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        let searchPredicate = myEventStore.predicateForEvents(
            withStart: inStartDate,
            end: endDate,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if myEventStore.sources.count > 0
        {
            let calItems = myEventStore.events(matching: searchPredicate)
            
            for calItem in calItems
            {
                if "\(calItem.calendarItemExternalIdentifier) Date: \(calItem.startDate)" == inEventID
                {
                    eventRecords.append(calItem)
                    let calendarEntry = myCalendarItem(inEventStore: myEventStore, inEvent: calItem, inAttendee: nil, teamID: teamID)
                    
                    eventDetails.append(calendarEntry)
                    eventRecords.append(calItem)
                }
            }
        }
    }
    
    func loadCalendarDetails(_ projectName: String, teamID: Int)
    {
        parseCalendarByProject(projectName, teamID: teamID)
        
        loadMeetingsForProject(projectName)
        
        // now sort the array into date order
        
        eventDetails.sort(by: {$0.startDate.timeIntervalSinceNow < $1.startDate.timeIntervalSinceNow})
    }

    fileprivate func loadMeetingsForContext(_ inSearchString: String)
    {
        var meetingFound: Bool = false
        
        let myMeetingArray = getMeetingsForDateRange()
        
        // Check through the meetings for ones that match the context
        
        for myMeeting in myMeetingArray
        {
            let myAttendeeList = myDatabaseConnection.loadAttendees(myMeeting.meetingID!)

            for myAttendee in myAttendeeList
            {
                if (myAttendee.name == inSearchString) || (myAttendee.email == inSearchString)
                {
                    // Check to see if there is already an entry for this meeting, as if there is we do not need to add it
                    meetingFound = false
                    for myCheck in eventDetails
                    {
                        if myCheck.eventID == myMeeting.meetingID
                        {
                            meetingFound = true
                            break
                        }
                    }
                    
                    if !meetingFound
                    {
                        let calendarEntry = myCalendarItem(inEventStore: myEventStore, inMeetingAgenda: myMeeting)
                    
                        eventDetails.append(calendarEntry)
            //        eventRecords.append(nil)
                    }
                }
            }
        }
    }
    
    fileprivate func loadMeetingsForProject(_ inSearchString: String)
    {
        var meetingFound: Bool = false
        var dateMatch: Bool = false
        
        let myMeetingArray = getMeetingsForDateRange()
        
        // Check through the meetings for ones that match the context
        
        for myMeeting in myMeetingArray
        {
            if myMeeting.name?.lowercased().range(of: inSearchString.lowercased()) != nil
            {
                // Check to see if there is already an entry for this meeting, as if there is we do not need to add it
                meetingFound = false
                dateMatch = true
                for myCheck in eventDetails
                {
                    if myCheck.eventID == myMeeting.meetingID
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
                    let calendarEntry = myCalendarItem(inEventStore: myEventStore, inMeetingAgenda: myMeeting)
                    
                    eventDetails.append(calendarEntry)
                    //        eventRecords.append(nil)
                }
                
                if !dateMatch
                {
                    let calendarEntry = myCalendarItem(inEventStore: myEventStore, inMeetingAgenda: myMeeting)
                    
                    eventDetails.append(calendarEntry)
                    //        eventRecords.append(nil)
                }
            }
        }
    }
    
    fileprivate func parseCalendarByEmail(_ inEmail: String, teamID: Int)
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

                                if emailSplit[1] == inEmail
                                {
                                    storeEvent(event, inAttendee: attendee, teamID: teamID)
                                }
                            }
                            
//                            let emailText: String = "\(attendee.url)"
//                            let emailStartPos = emailText.characters.index(of: ":")
//                            let nextPlace = emailText.index(after: (emailStartPos)!)
//                            var emailAddress: String = ""
//                            if nextPlace != nil
//                            {
//                                let emailEndPos = emailText.characters.index(before: emailText.endIndex)
//                                emailAddress = emailText[nextPlace...emailEndPos]
//                            }
//                            if emailAddress == inEmail
//                            {
//                                storeEvent(event, inAttendee: attendee, teamID: teamID)
//                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func parseCalendarByProject(_ inProject: String, teamID: Int)
    {
        let events = getEventsForDateRange()
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                let myTitle = event.title
                        
                if myTitle.lowercased().range(of: inProject.lowercased()) != nil
                {
                    storeEvent(event, inAttendee: nil, teamID: teamID)
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
        let searchPredicate = myEventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if myEventStore.sources.count > 0
        {
            events = myEventStore.events(matching: searchPredicate)
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
        _ = myEventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil)
        
        /* Fetch all the meetings that fall between the starting and the ending dates */
        
        return myDatabaseConnection.getAgendaForDateRange(startDate as NSDate, inEndDate: endDate as NSDate, inTeamID: myCurrentTeam.teamID)
    }
    
    fileprivate func storeEvent(_ inEvent: EKEvent, inAttendee: EKParticipant?, teamID: Int)
    {
        let calendarEntry = myCalendarItem(inEventStore: myEventStore, inEvent: inEvent, inAttendee: inAttendee, teamID: teamID)
        
        eventDetails.append(calendarEntry)
        eventRecords.append(inEvent)
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
    
    func parseReminderDetails (_ inSearch: String)
    {
        let cals = reminderStore.calendars(for: EKEntityType.reminder)
        var myCalFound = false
    
        for cal in cals
        {
            if cal.title == inSearch
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
            writeRowToArray("No reminders list found", inTable: &tableContents)
        }
        else
        {
            for myReminder in reminderDetails
            {
                let myString = "\(myReminder.reminderText)"
                
                switch myReminder.priority
                {
                    case 1: writeRowToArray(myString, inTable: &tableContents, inDisplayFormat: "Red")  //  High priority
                    
                    case 5: writeRowToArray(myString , inTable: &tableContents, inDisplayFormat: "Orange") // Medium priority
                    
                    default: writeRowToArray(myString , inTable: &tableContents)
                }
            }
   
        }
        return tableContents
    }
}

class MeetingModel: NSObject
{
    fileprivate var myDelegate: MyMeetingsDelegate!
    fileprivate var myEvent: myCalendarItem!
    fileprivate var myActionType: String = ""
        
    var delegate: MyMeetingsDelegate
    {
        get
        {
            return myDelegate
        }
        set
        {
            myDelegate = newValue
        }
    }
        
    var actionType: String
    {
        get
        {
            return myActionType
        }
        set
        {
            myActionType = newValue
        }
    }
        
    var event: myCalendarItem
    {
        get
        {
            return myEvent
        }
        set
        {
            myEvent = newValue
        }
    }
}


func parsePastMeeting(_ inMeetingID: String) -> [task]
{
    // Get the the details for the meeting, in order to determine the previous task ID
    var myReturnArray: [task] = Array()
    
    let myData = myDatabaseConnection.loadAgenda(inMeetingID, inTeamID: myCurrentTeam.teamID)
    
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
                let newTask = task(taskID: myItem2.taskID as! Int)
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
    func searchPastAgendaByPartialMeetingIDBeforeStart(_ inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
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
    
    func searchPastAgendaWithoutPartialMeetingIDBeforeStart(_ inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
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
    
    func listAgendaReverseDateBeforeStart(_ inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
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
    
    func searchPastAgendaByPartialMeetingIDAfterStart(_ inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
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
    
    func searchPastAgendaWithoutPartialMeetingIDAfterStart(_ inSearchText: String, inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
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
    
    func listAgendaReverseDateAfterStart(_ inMeetingStartDate: NSDate, inTeamID: Int)->[MeetingAgenda]
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
    
    func saveAgenda(_ inMeetingID: String, inPreviousMeetingID : String, inName: String, inChair: String, inMinutes: String, inLocation: String, inStartTime: Date, inEndTime: Date, inMinutesType: String, inTeamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
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
            myAgenda.startTime = inStartTime as NSDate
            myAgenda.endTime = inEndTime as NSDate
            myAgenda.minutesType = inMinutesType
            myAgenda.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myAgenda.updateTime =  NSDate()
                myAgenda.updateType = "Add"
            }
            else
            {
                myAgenda.updateTime = inUpdateTime as NSDate
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
            myAgenda.startTime = inStartTime as NSDate
            myAgenda.endTime = inEndTime as NSDate
            myAgenda.minutesType = inMinutesType
            myAgenda.teamID = NSNumber(value: inTeamID)
            if inUpdateType == "CODE"
            {
                myAgenda.updateTime =  NSDate()
                if myAgenda.updateType != "Add"
                {
                    myAgenda.updateType = "Update"
                }
            }
            else
            {
                myAgenda.updateTime = inUpdateTime as NSDate
                myAgenda.updateType = inUpdateType
            }
        }
        
        saveContext()
    }
    
    func replaceAgenda(_ inMeetingID: String, inPreviousMeetingID : String, inName: String, inChair: String, inMinutes: String, inLocation: String, inStartTime: Date, inEndTime: Date, inMinutesType: String, inTeamID: Int, inUpdateTime: Date =  Date(), inUpdateType: String = "CODE")
    {
        let myAgenda = MeetingAgenda(context: objectContext)
        myAgenda.meetingID = inMeetingID
        myAgenda.previousMeetingID = inPreviousMeetingID
        myAgenda.name = inName
        myAgenda.chair = inChair
        myAgenda.minutes = inMinutes
        myAgenda.location = inLocation
        myAgenda.startTime = inStartTime as NSDate
        myAgenda.endTime = inEndTime as NSDate
        myAgenda.minutesType = inMinutesType
        myAgenda.teamID = NSNumber(value: inTeamID)
        if inUpdateType == "CODE"
        {
            myAgenda.updateTime =  NSDate()
            myAgenda.updateType = "Add"
        }
        else
        {
            myAgenda.updateTime = inUpdateTime as NSDate
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
    
    func getAgendaForDateRange(_ inStartDate: NSDate, inEndDate: NSDate, inTeamID: Int)->[MeetingAgenda]
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
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }

    func getMeetingAgendasForSync(_ inLastSyncDate: NSDate) -> [MeetingAgenda]
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
}

extension CloudKitInteraction
{
    func saveMeetingAgendaToCloudKit(_ inLastSyncDate: NSDate)
    {
        //        NSLog("Syncing Meeting Agenda")
        for myItem in myDatabaseConnection.getMeetingAgendasForSync(inLastSyncDate)
        {
            saveMeetingAgendaRecordToCloudKit(myItem)
        }
    }

    func updateMeetingAgendaInCoreData(_ inLastSyncDate: NSDate)
    {
        let sem = DispatchSemaphore(value: 0);
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                self.updateMeetingAgendaRecord(record)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func deleteMeetingAgenda()
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(value: true)
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
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

    func replaceMeetingAgendaInCoreData()
    {
        let sem = DispatchSemaphore(value: 0);
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateStyle = DateFormatter.Style.short
        let inLastSyncDate = myDateFormatter.date(from: "01/01/15")
        
        let predicate: NSPredicate = NSPredicate(format: "updateTime >= %@", inLastSyncDate! as CVarArg)
        let query: CKQuery = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                let meetingID = record.object(forKey: "meetingID") as! String
                let updateTime = record.object(forKey: "updateTime") as! Date
                let updateType = record.object(forKey: "updateType") as! String
                let chair = record.object(forKey: "chair") as! String
                let endTime = record.object(forKey: "endTime") as! Date
                let location = record.object(forKey: "location") as! String
                let minutes = record.object(forKey: "minutes") as! String
                let minutesType = record.object(forKey: "minutesType") as! String
                let name = record.object(forKey: "name") as! String
                let previousMeetingID = record.object(forKey: "previousMeetingID") as! String
                let startTime = record.object(forKey: "meetingStartTime") as! Date
                let teamID = record.object(forKey: "actualTeamID") as! Int
                
                myDatabaseConnection.replaceAgenda(meetingID, inPreviousMeetingID : previousMeetingID, inName: name, inChair: chair, inMinutes: minutes, inLocation: location, inStartTime: startTime, inEndTime: endTime, inMinutesType: minutesType, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
            }
            sem.signal()
        })
        
        sem.wait()
    }

    func saveMeetingAgendaRecordToCloudKit(_ sourceRecord: MeetingAgenda)
    {
        let predicate = NSPredicate(format: "(meetingID == \"\(sourceRecord.meetingID!)\") && (actualTeamID == \(sourceRecord.teamID as! Int))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "MeetingAgenda", predicate: predicate)
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
                    record!.setValue(sourceRecord.chair, forKey: "chair")
                    record!.setValue(sourceRecord.endTime, forKey: "endTime")
                    record!.setValue(sourceRecord.location, forKey: "location")
                    record!.setValue(sourceRecord.minutes, forKey: "minutes")
                    record!.setValue(sourceRecord.minutesType, forKey: "minutesType")
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.previousMeetingID, forKey: "previousMeetingID")
                    record!.setValue(sourceRecord.startTime, forKey: "meetingStartTime")
                    
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
                    let record = CKRecord(recordType: "MeetingAgenda")
                    record.setValue(sourceRecord.meetingID, forKey: "meetingID")
                    record.setValue(sourceRecord.updateTime, forKey: "updateTime")
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

    func updateMeetingAgendaRecord(_ sourceRecord: CKRecord)
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
        let teamID = sourceRecord.object(forKey: "actualTeamID") as! Int
        
        myDatabaseConnection.saveAgenda(meetingID, inPreviousMeetingID : previousMeetingID, inName: name, inChair: chair, inMinutes: minutes, inLocation: location, inStartTime: startTime, inEndTime: endTime, inMinutesType: minutesType, inTeamID: teamID, inUpdateTime: updateTime, inUpdateType: updateType)
    }
}
