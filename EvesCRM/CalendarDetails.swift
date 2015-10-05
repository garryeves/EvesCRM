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

class meetingAgendaItem
{
    private var myActualEndTime: NSDate!
    private var myActualStartTime: NSDate!
    private var myStatus: String = ""
    private var myDecisionMade: String = ""
    private var myDiscussionNotes: String = ""
    private var myTimeAllocation: Int = 0
    private var myOwner: String = ""
    private var myTitle: String = ""
    private var myAgendaID: Int = 0
    private var myTasks: [task] = Array()
    private var myMeetingID: String = ""
    private var myUpdateAllowed: Bool = true
    private var myMeetingOrder: Int = 0

    var actualEndTime: NSDate?
    {
        get
        {
            return myActualEndTime
        }
        set
        {
            myActualEndTime = newValue
            save()
        }
    }
    
    var actualStartTime: NSDate?
    {
        get
        {
            return myActualStartTime
        }
        set
        {
            myActualStartTime = newValue
            save()
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
            save()
        }
    }
    
    var decisionMade: String
    {
        get
        {
            return myDecisionMade
        }
        set
        {
            myDecisionMade = newValue
            save()
        }
    }
    
    var discussionNotes: String
    {
        get
        {
            return myDiscussionNotes
        }
        set
        {
            myDiscussionNotes = newValue
            save()
        }
    }
    
    var timeAllocation: Int
    {
        get
        {
            return myTimeAllocation
        }
        set
        {
            myTimeAllocation = newValue
            save()
        }
    }
    
    var owner: String
    {
        get
        {
            return myOwner
        }
        set
        {
            myOwner = newValue
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
    
    var agendaID: Int
    {
        get
        {
            return myAgendaID
        }
        set
        {
            myAgendaID = newValue
            save()
        }
    }

    var meetingOrder: Int
        {
        get
        {
            return myMeetingOrder
        }
        set
        {
            myMeetingOrder = newValue
            save()
        }
    }

    var tasks: [task]
    {
        get
        {
            return myTasks
        }
    }
    
    init(inMeetingID: String)
    {
        myMeetingID = inMeetingID
        myTitle = "New Item"
        myTimeAllocation = 10
        
        let tempAgendaItems = myDatabaseConnection.loadAgendaItem(myMeetingID)
        
        myAgendaID = tempAgendaItems.count + 1
        
        save()
    }
    
    init(inMeetingID: String, inAgendaID: Int)
    {
        myMeetingID = inMeetingID
        
        let tempAgendaItems = myDatabaseConnection.loadSpecificAgendaItem(myMeetingID, inAgendaID: inAgendaID)
     
        if tempAgendaItems.count > 0
        {
            myAgendaID = tempAgendaItems[0].agendaID as! Int
            myTitle = tempAgendaItems[0].title!
            myOwner = tempAgendaItems[0].owner!
            myTimeAllocation = tempAgendaItems[0].timeAllocation as! Int
            myDiscussionNotes = tempAgendaItems[0].discussionNotes!
            myDecisionMade = tempAgendaItems[0].decisionMade!
            myStatus = tempAgendaItems[0].status!
            if tempAgendaItems[0].meetingOrder != nil
            {
                myMeetingOrder = tempAgendaItems[0].meetingOrder as! Int
            }
            myActualStartTime = tempAgendaItems[0].actualStartTime
            myActualEndTime = tempAgendaItems[0].actualEndTime
        }
        else
        {
            myAgendaID = 0
        }
    }
    
    init(rowType: String)
    {
        switch rowType
        {
            case "PreviousMinutes" :
                myTitle = "Review of previous meeting actions"
                myTimeAllocation = 10
            
            case "Close" :
                myTitle = "Close meeting"
                myTimeAllocation = 1
            
            default:
                myTitle = "Unknown item"
                myTimeAllocation = 10
        }
        
        myStatus = "Open"
        myOwner = "All"
        myUpdateAllowed = false
    }
    
    func save()
    {        
        if myUpdateAllowed
        {
            myDatabaseConnection.saveAgendaItem(myMeetingID, actualEndTime: myActualEndTime, actualStartTime: myActualStartTime, status: myStatus, decisionMade: myDecisionMade, discussionNotes: myDiscussionNotes, timeAllocation: myTimeAllocation, owner: myOwner, title: myTitle, agendaID: myAgendaID, meetingOrder: myMeetingOrder)
        }
    }
    
    func delete()
    {
        // call code to perform the delete
        if myUpdateAllowed
        {
            myDatabaseConnection.deleteAgendaItem(myMeetingID, agendaID: myAgendaID)
        }
    }
    
    func loadTasks()
    {
        myTasks.removeAll()
        
        let myAgendaTasks = myDatabaseConnection.getAgendaTasks(myMeetingID, inAgendaID:myAgendaID)
        
        for myAgendaTask in myAgendaTasks
        {
            let myNewTask = task(taskID: myAgendaTask.taskID as Int)
            myTasks.append(myNewTask)
        }
    }
    
    func addTask(inTask: task)
    {
        // Is there ale=ready a link between the agenda and the task, if there is then no need to save
        let myCheck = myDatabaseConnection.getAgendaTask(myAgendaID, inMeetingID: myMeetingID, inTaskID: inTask.taskID)
        
        if myCheck.count == 0
        {
            // Associate Agenda to Task
            myDatabaseConnection.saveAgendaTask(myAgendaID, inMeetingID: myMeetingID, inTaskID: inTask.taskID)
        }
        
        // reload the tasks array
        loadTasks()
    }
    
    func removeTask(inTask: task)
    {
        // Associate Agenda to Task
        myDatabaseConnection.deleteAgendaTask(myAgendaID, inMeetingID: myMeetingID, inTaskID: inTask.taskID)
        
        // reload the tasks array
        loadTasks()
    }
}

class meetingAttendee
{
    private var myName: String = ""
    private var myEmailAddress: String = ""
    private var myType: String = ""
    private var myStatus: String = ""
 
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

    var emailAddress: String
    {
        get
        {
            return myEmailAddress
        }
        set
        {
            myEmailAddress = newValue
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
}

class myCalendarItem
{
    private var myTitle: String = ""
    private var myStartDate: NSDate!
    private var myEndDate: NSDate!
    private var myRecurrence: Int = -1
    private var myRecurrenceFrequency: Int = -1
    private var myLocation: String = ""
    private var myStatus: Int = -1
    private var myType: Int = -1
    private var myRole: Int = -1
    private var myEventID: String = ""
    private var myEvent: EKEvent?
    private var myAttendees: [meetingAttendee] = Array()
    private var myChair: String = ""
    private var myMinutes: String = ""
    private var myPreviousMinutes: String = ""
    private var myNextMeeting: String = ""
    private var myMinutesType: String = ""
    private var myAgendaItems: [meetingAgendaItem] = Array()
    private var myTeamID: Int = 0

    // Seup Date format for display
    private var startDateFormatter = NSDateFormatter()
    private var endDateFormatter = NSDateFormatter()
    private var dateFormat = NSDateFormatterStyle.MediumStyle
    private var timeFormat = NSDateFormatterStyle.ShortStyle
    
    // This is used in order to allow to identify unique instances of a repeating Event
    
    private var myUniqueIdentifier: String = ""
    private var eventStore: EKEventStore!
    
    // Flag to indicate if we have data saved in database as well
    
    private var mySavedData: Bool = false

    init(inEventStore: EKEventStore, inEvent: EKEvent, inAttendee: EKParticipant?)
    {
        startDateFormatter.dateStyle = dateFormat
        startDateFormatter.timeStyle = timeFormat
        endDateFormatter.timeStyle = timeFormat
        eventStore = inEventStore
        
        myEvent = inEvent
        myTitle = inEvent.title
        myStartDate = inEvent.startDate
        myEndDate = inEvent.endDate
        myLocation = inEvent.location!
        
        if inEvent.recurrenceRules != nil
        {
            // This is a recurring event
            let myWorkingRecur: NSArray = inEvent.recurrenceRules!
            
            for myItem in myWorkingRecur
            {
                myRecurrenceFrequency = myItem.interval
                let testFrequency: EKRecurrenceFrequency = myItem.frequency
                myRecurrence = Int(testFrequency.rawValue)
            }
        }
        // Need to validate this works when displaying by person and also by project
        if inAttendee != nil
        {
            myStatus = Int(inAttendee!.participantStatus.rawValue)
            myType = Int(inAttendee!.participantType.rawValue)
        }
    }
    
    init(inEventStore: EKEventStore, inMeetingAgenda: MeetingAgenda)
    {
        startDateFormatter.dateStyle = dateFormat
        startDateFormatter.timeStyle = timeFormat
        endDateFormatter.timeStyle = timeFormat
        eventStore = inEventStore
        
        myTitle = inMeetingAgenda.name
        myStartDate = inMeetingAgenda.startTime
        myEndDate = inMeetingAgenda.endTime
        myLocation = inMeetingAgenda.location
        myPreviousMinutes = inMeetingAgenda.previousMeetingID
        myEventID = inMeetingAgenda.meetingID
        myChair = inMeetingAgenda.chair
        myMinutes = inMeetingAgenda.minutes
        myLocation = inMeetingAgenda.location
        myMinutesType = inMeetingAgenda.minutesType
    }
    
    init(inEventStore: EKEventStore, inMeetingID: String)
    {
        let mySavedValues = myDatabaseConnection.loadAgenda(inMeetingID, inTeamID: myTeamID)
        
        if mySavedValues.count > 0
        {
            myTitle = mySavedValues[0].name
            myStartDate = mySavedValues[0].startTime
            myEndDate = mySavedValues[0].endTime
            myLocation = mySavedValues[0].location
            myPreviousMinutes = mySavedValues[0].previousMeetingID
            myEventID = mySavedValues[0].meetingID
            myChair = mySavedValues[0].chair
            myMinutes = mySavedValues[0].minutes
            myLocation = mySavedValues[0].location
            myMinutesType = mySavedValues[0].minutesType
            mySavedData = true
        }

        startDateFormatter.dateStyle = dateFormat
        startDateFormatter.timeStyle = timeFormat
        endDateFormatter.timeStyle = timeFormat
        eventStore = inEventStore
        
        // We neeed to go and the the event details from the calendar, if they exist
        
        let nextEvent = iOSCalendar(inEventStore: eventStore)
        
        nextEvent.loadCalendarForEvent(myEventID, inStartDate: myStartDate)
        
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
            myEventID = myEvent!.eventIdentifier
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
    
    var startDate: NSDate
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
            return startDateFormatter.stringFromDate(myStartDate)
        }
    }
    
    var displayScheduledDate: String
    {
        get
        {
            var myString: String = ""
            startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
            
            myString = startDateFormatter.stringFromDate(myStartDate)
            myString += " - "
            myString += endDateFormatter.stringFromDate(myEndDate)
            
            return myString
        }
    }
    
    var endDate: NSDate
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
            return endDateFormatter.stringFromDate(myEndDate)
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
                    retVal = myItem.meetingID
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
                myEventID = myEvent!.eventIdentifier
                return myEvent!.eventIdentifier
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
    
    func addAttendee(inName: String, inEmailAddress: String, inType: String, inStatus: String)
    {
        let attendee: meetingAttendee = meetingAttendee()
        attendee.name = inName
        attendee.emailAddress = inEmailAddress
        attendee.type = inType
        attendee.status = inStatus
 
        myAttendees.append(attendee)
        
        // make sure we have saved the Agenda
        
        save()
        
        // Save Attendees
        
        myDatabaseConnection.saveAttendee(eventID, inAttendees: myAttendees)
    }
    
    private func initaliseAttendee(inName: String, inEmailAddress: String, inType: String, inStatus: String)
    {
        let attendee: meetingAttendee = meetingAttendee()
        attendee.name = inName
        attendee.emailAddress = inEmailAddress
        attendee.type = inType
        attendee.status = inStatus
        
        myAttendees.append(attendee)
    }

    func removeAttendee(inIndex: Int)
    {
        // we should know the index of the item we want to delete from the control, so only need its index in order to perform the required action
        myAttendees.removeAtIndex(inIndex)
        
        // Save Attendees
        
        myDatabaseConnection.saveAttendee(eventID, inAttendees: myAttendees)
    }
    
    func populateAttendeesFromInvite()
    {
        // Use this for the initial population of the attendees
        
        for attendee in event!.attendees!
        {
            let emailText: String = "\(attendee.URL)"
            let emailStartPos = emailText.characters.indexOf(":")
            let nextPlace = emailStartPos?.successor()
            var emailAddress: String = ""
            if nextPlace != nil
            {
                let emailEndPos = emailText.endIndex.predecessor()
                emailAddress = emailText[nextPlace!...emailEndPos]
            }
            
            addAttendee(attendee.name!, inEmailAddress: emailAddress, inType: "Participant", inStatus: "Invited")
        }
    }
    
    func save()
    {
        // if this is for a repeating event then we need to add in the original startdate to the Notes

        if myEvent != nil
        {
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
    }
    
    func loadAgenda()
    {
        // Used where the invite is no longer in the calendar, and also to load up historical items for the "minutes" views
        
        var mySavedValues: [MeetingAgenda]!
        if myEventID == ""
        {
            mySavedValues = myDatabaseConnection.loadAgenda(myEvent!.eventIdentifier, inTeamID: myTeamID)
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAgenda(myEventID, inTeamID: myTeamID)
        }
        
        if mySavedValues.count > 0
        {
            myPreviousMinutes = mySavedValues[0].previousMeetingID
            myChair = mySavedValues[0].chair
            myMinutes = mySavedValues[0].minutes
            myMinutesType = mySavedValues[0].minutesType
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
            mySavedValues = myDatabaseConnection.loadAttendees(myEvent!.eventIdentifier)
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAttendees(myEventID)
        }
        
        myAttendees.removeAll(keepCapacity: false)
        
        if myEvent == nil
        { // No calendar event has been loaded, so go straight from table
            for savedAttendee in mySavedValues
            {
                initaliseAttendee(savedAttendee.name, inEmailAddress: savedAttendee.email, inType: savedAttendee.type, inStatus: savedAttendee.attendenceStatus)
            }
        }
        else
        {
            if myStartDate.compare(NSDate()) == NSComparisonResult.OrderedDescending
            { // Start date is in the future, so we need to check the meeting invite attendeees
            
                if mySavedValues.count > 0
                {
                    for savedAttendee in mySavedValues
                    {
                        inviteeFound = false
                        tempName = savedAttendee.name
                        tempStatus = savedAttendee.attendenceStatus
                        tempEmail = savedAttendee.email
                        tempType = savedAttendee.type
                    
                        if myEvent!.hasAttendees
                        {
                            for invitee in myEvent!.attendees!
                            {
                                // Check to see if any "Invited" people are no longer on calendar invite, and if so remove from Agenda.
                
                                if invitee.name == tempName
                                {
                                    // Invitee found
                    
                                    let emailText: String = "\(invitee.URL)"
                                    let emailStartPos = emailText.characters.indexOf(":")
                                    let nextPlace = emailStartPos?.successor()
                                    var emailAddress: String = ""
                                    if nextPlace != nil
                                    {
                                        let emailEndPos = emailText.endIndex.predecessor()
                                        emailAddress = emailText[nextPlace!...emailEndPos]
                                    }
                    
                                    initaliseAttendee(invitee.name!, inEmailAddress: emailAddress, inType: "Participant", inStatus: "Invited")
             
                                    inviteeFound = true
                    
                                    break
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
                        mySavedValues = myDatabaseConnection.loadAttendees(myEvent!.eventIdentifier)
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
                                tempName = checkAttendee.name
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
                
                                let emailText: String = "\(invitee.URL)"
                                let emailStartPos = emailText.characters.indexOf(":")
                                let nextPlace = emailStartPos?.successor()
                                var emailAddress: String = ""
                                if nextPlace != nil
                                {
                                    let emailEndPos = emailText.endIndex.predecessor()
                                    emailAddress = emailText[nextPlace!...emailEndPos]
                                }
                
                                addAttendee(invitee.name!, inEmailAddress: emailAddress, inType: "Participant", inStatus: "Invited")
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
                            let emailText: String = "\(invitee.URL)"
                            let emailStartPos = emailText.characters.indexOf(":")
                            let nextPlace = emailStartPos?.successor()
                            var emailAddress: String = ""
                            if nextPlace != nil
                            {
                                let emailEndPos = emailText.endIndex.predecessor()
                                emailAddress = emailText[nextPlace!...emailEndPos]
                            }
                    
                            addAttendee(invitee.name!, inEmailAddress: emailAddress, inType: "Participant", inStatus: "Invited")
                        }
                    }
                }
            }
            else
            { // In the past so we just used the entried from the table
                for savedAttendee in mySavedValues
                {
                    initaliseAttendee(savedAttendee.name, inEmailAddress: savedAttendee.email, inType: savedAttendee.type, inStatus: savedAttendee.attendenceStatus)
                }
            }

            // Save Attendees
        
            if myAttendees.count > 0
            {
                myDatabaseConnection.saveAttendee(eventID, inAttendees: myAttendees)
            }
        }
    }
    
    func loadAgendaItems()
    {
        var mySavedValues: [MeetingAgendaItem]!
        
        if myEventID == ""
        {
            mySavedValues = myDatabaseConnection.loadAgendaItem(myEvent!.eventIdentifier)
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAgendaItem(myEventID)
        }
        
        myAgendaItems.removeAll(keepCapacity: false)
        
        if mySavedValues.count > 0
        {
            var runningMeetingOrder: Int = 0
            
            for savedAgenda in mySavedValues
            {
                let myAgendaItem =  meetingAgendaItem(inMeetingID: savedAgenda.meetingID!, inAgendaID:savedAgenda.agendaID as! Int)
                if myAgendaItem.meetingOrder == 0
                {
                    myAgendaItem.meetingOrder = ++runningMeetingOrder
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
        
    func updateAgendaItems(inAgendaID: Int, inTitle: String, inOwner: String, inStatus: String, inDecisionMade: String, inDiscussionNotes: String, inTimeAllocation: Int, inActualStartTime: NSDate, inActualEndTime: NSDate)
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
    
    private func writeLine(inTargetString: String, inLineString: String) -> String
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
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let myCalendar = NSCalendar.currentCalendar()
        
        var myWorkingTime = myStartDate
        
        if myStartDate.compare(NSDate()) == NSComparisonResult.OrderedAscending
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
                let startDateFormatter = NSDateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                
                let myDisplayString = "\(myItem.name) - \(myDisplayDate)"
                
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
                    let newTask = task(taskID: myItem2.taskID as Int)
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
                        myLine += "||\(myData3[0].projectName)"
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
                            itemCount++
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
                        myLine += "||\(myData3[0].projectName)"
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
                            itemCount++
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
        
        if myStartDate.compare(NSDate()) == NSComparisonResult.OrderedAscending
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
                            myLine += "||\(myData3[0].projectName)"
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
                                itemCount++
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
                    myLine = "||\(myDateFormatter.stringFromDate(myWorkingTime))"
                    myLine += "||Actions from Previous Meeting"
                    myLine += "||All||"
                    myExportString = writeLine(myExportString, inLineString: myLine)
                    
                    myWorkingTime = myCalendar.dateByAddingUnit(
                        .Minute,
                        value: 10,
                        toDate: myWorkingTime,
                        options: [])!
                }
            }
            
            myExportString = writeLine(myExportString, inLineString: "")
            
            for myItem in myAgendaItems
            {
                myLine = "||\(myDateFormatter.stringFromDate(myWorkingTime))"
                myLine += "||\(myItem.title)"
                myLine += "||\(myItem.owner)||"
                myExportString = writeLine(myExportString, inLineString: myLine)
                
                myWorkingTime = myCalendar.dateByAddingUnit(
                    .Minute,
                    value: myItem.timeAllocation,
                    toDate: myWorkingTime,
                    options: [])!
                
            }
            
            myLine = "||\(myDateFormatter.stringFromDate(myWorkingTime))"
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
                let startDateFormatter = NSDateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                
                let myDisplayString = "\(myItem.name) - \(myDisplayDate)"
                
                myExportString = writeLine(myExportString, inLineString: "")
                myExportString = writeLine(myExportString, inLineString: "")
                
                myLine = "Next Meeting: \(myDisplayString)"
                myExportString = writeLine(myExportString, inLineString: myLine)
                
            }
        }
        return myExportString
    }
    
    private func writeHTMLLine(inTargetString: String, inLineString: String) -> String
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
        let myDateFormatter = NSDateFormatter()
        myDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let myCalendar = NSCalendar.currentCalendar()
        
        var myWorkingTime = myStartDate
        
        myLine = "<html><body>"
        
        if myStartDate.compare(NSDate()) == NSComparisonResult.OrderedAscending
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
                let startDateFormatter = NSDateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                
                let myDisplayString = "\(myItem.name) - \(myDisplayDate)"
                
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
                    let newTask = task(taskID: myItem2.taskID as Int)
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
                        myTaskTable += "<td>\(myData3[0].projectName)</td>"
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
                            itemCount++
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
                        myTaskTable += "<td>\(myData3[0].projectName)</td>"
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
                            itemCount++
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
        
        if myStartDate.compare(NSDate()) == NSComparisonResult.OrderedAscending
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
                            myTaskTable += "<td>\(myData3[0].projectName)</td>"
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
                                itemCount++
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
                    myTaskTable += "<td>\(myDateFormatter.stringFromDate(myWorkingTime))</td>"
                    myTaskTable += "<td>Actions from Previous Meeting</td>"
                    myTaskTable += "<td>All</td>"
                    myTaskTable += "</tr>"
                    
                    myWorkingTime = myCalendar.dateByAddingUnit(
                        .Minute,
                        value: 10,
                        toDate: myWorkingTime,
                        options: [])!
                }
            }
            
            for myItem in myAgendaItems
            {
                myTaskTable += "<tr>"
                myTaskTable += "<td>\(myDateFormatter.stringFromDate(myWorkingTime))</td>"
                myTaskTable += "<td>\(myItem.title)</td>"
                myTaskTable += "<td>\(myItem.owner)</td>"
                myTaskTable += "</tr>"
                
                myWorkingTime = myCalendar.dateByAddingUnit(
                    .Minute,
                    value: myItem.timeAllocation,
                    toDate: myWorkingTime,
                    options: [])!
                
            }
            
            myTaskTable += "<tr>"
            myTaskTable += "<td>\(myDateFormatter.stringFromDate(myWorkingTime))</td>"
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
                let startDateFormatter = NSDateFormatter()
                startDateFormatter.dateFormat = "EEE d MMM h:mm aaa"
                let myDisplayDate = startDateFormatter.stringFromDate(myItem.startTime)
                
                let myDisplayString = "\(myItem.name) - \(myDisplayDate)"
                
                myExportString = writeHTMLLine(myExportString, inLineString: "")
                myExportString = writeHTMLLine(myExportString, inLineString: "")
                
                myLine = "<b>Next Meeting:</b> \(myDisplayString)"
                myExportString = writeHTMLLine(myExportString, inLineString: myLine)
                
            }
        }
        myExportString = writeHTMLLine(myExportString, inLineString: "</body></html>")
        return myExportString
    }
    
    func setNextMeeting(inCalendarItem: myCalendarItem)
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
}

class iOSCalendar
{
    private var eventStore: EKEventStore!
    private var eventDetails: [myCalendarItem] = Array()
    private var eventRecords: [EKEvent] = Array()

    init(inEventStore: EKEventStore)
    {
        eventStore = inEventStore
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
    
    func loadCalendarDetails(emailAddresses: [String])
    {
        for myEmail in emailAddresses
        {
            parseCalendarByEmail(myEmail)
            loadMeetingsForContext(myEmail)
        }
        
        // Now sort the array into date order
        
         eventDetails.sortInPlace({$0.startDate.timeIntervalSinceNow < $1.startDate.timeIntervalSinceNow})
    }
    
    func loadCalendarForEvent(inEventID: String, inStartDate: NSDate)
    {
        /* The end date */
        //Calculate - Days * hours * mins * secs
        
        let myEndDateValue:NSTimeInterval = 60 * 60
        
        let endDate = inStartDate.dateByAddingTimeInterval(myEndDateValue)
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        let searchPredicate = eventStore.predicateForEventsWithStartDate(
            inStartDate,
            endDate: endDate,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if eventStore.sources.count > 0
        {
            let events = eventStore.eventsMatchingPredicate(searchPredicate)
            
            for event in events
            {
                if event.eventIdentifier == inEventID
                {
                    eventRecords.append(event)
                    let calendarEntry = myCalendarItem(inEventStore: eventStore, inEvent: event, inAttendee: nil)
                    
                    eventDetails.append(calendarEntry)
                    eventRecords.append(event)
                }
            }
        }
    }
    
    func loadCalendarDetails(projectName: String)
    {
        parseCalendarByProject(projectName)
        
        loadMeetingsForProject(projectName)
        
        // now sort the array into date order
        
        eventDetails.sortInPlace({$0.startDate.timeIntervalSinceNow < $1.startDate.timeIntervalSinceNow})
    }

    private func loadMeetingsForContext(inSearchString: String)
    {
        var meetingFound: Bool = false
        
        let myMeetingArray = getMeetingsForDateRange()
        
        // Check through the meetings for ones that match the context
        
        for myMeeting in myMeetingArray
        {
            let myAttendeeList = myDatabaseConnection.loadAttendees(myMeeting.meetingID)

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
                        let calendarEntry = myCalendarItem(inEventStore: eventStore, inMeetingAgenda: myMeeting)
                    
                        eventDetails.append(calendarEntry)
            //        eventRecords.append(nil)
                    }
                }
            }
        }
    }
    
    private func loadMeetingsForProject(inSearchString: String)
    {
        var meetingFound: Bool = false
        var dateMatch: Bool = false
        
        let myMeetingArray = getMeetingsForDateRange()
        
        // Check through the meetings for ones that match the context
        
        for myMeeting in myMeetingArray
        {
            if myMeeting.name.lowercaseString.rangeOfString(inSearchString.lowercaseString) != nil
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
                        if myCheck.startDate == myMeeting.startTime
                        { // Dates are the same
                            dateMatch = true
                            break
                        }
                    }
                    // Events Ids do not match
                }
                
                if !meetingFound
                {
                    let calendarEntry = myCalendarItem(inEventStore: eventStore, inMeetingAgenda: myMeeting)
                    
                    eventDetails.append(calendarEntry)
                    //        eventRecords.append(nil)
                }
                
                if !dateMatch
                {
                    let calendarEntry = myCalendarItem(inEventStore: eventStore, inMeetingAgenda: myMeeting)
                    
                    eventDetails.append(calendarEntry)
                    //        eventRecords.append(nil)
                }
            }
        }
    }
    
    private func parseCalendarByEmail(inEmail: String)
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
                            let emailText: String = "\(attendee.URL)"
                            let emailStartPos = emailText.characters.indexOf(":")
                            let nextPlace = emailStartPos?.successor()
                            var emailAddress: String = ""
                            if nextPlace != nil
                            {
                                let emailEndPos = emailText.endIndex.predecessor()
                                emailAddress = emailText[nextPlace!...emailEndPos]
                            }
                            if emailAddress == inEmail
                            {
                                storeEvent(event, inAttendee: attendee)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func parseCalendarByProject(inProject: String)
    {
        let events = getEventsForDateRange()
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                let myTitle = event.title
                        
                if myTitle.lowercaseString.rangeOfString(inProject.lowercaseString) != nil
                {
                    storeEvent(event, inAttendee: nil)
                }
            }
        }
    }
    
    private func getEventsForDateRange() -> [EKEvent]
    {
        var events: [EKEvent] = []
        
        let baseDate = NSDate()
        
        /* The event starts date */
        //Calculate - Days * hours * mins * secs
        
        let myStartDateString = myDatabaseConnection.getDecodeValue("Calendar - Weeks before current date")
        // This is string value so need to convert to integer, and subtract from 0 to get a negative
        
        let myStartDateValue:NSTimeInterval = 0 - ((((myStartDateString as NSString).doubleValue * 7) + 1) * 24 * 60 * 60)
        
        let startDate = baseDate.dateByAddingTimeInterval(myStartDateValue)
        
        /* The end date */
        //Calculate - Days * hours * mins * secs
        
        let myEndDateString = myDatabaseConnection.getDecodeValue("Calendar - Weeks after current date")
        // This is string value so need to convert to integer
        
        let myEndDateValue:NSTimeInterval = (myEndDateString as NSString).doubleValue * 7 * 24 * 60 * 60
        
        let endDate = baseDate.dateByAddingTimeInterval(myEndDateValue)
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        let searchPredicate = eventStore.predicateForEventsWithStartDate(
            startDate,
            endDate: endDate,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if eventStore.sources.count > 0
        {
            events = eventStore.eventsMatchingPredicate(searchPredicate)
        }
        return events
    }

    private func getMeetingsForDateRange() -> [MeetingAgenda]
    {
        let baseDate = NSDate()
        
        /* The event starts date */
        //Calculate - Days * hours * mins * secs
        
        let myStartDateString = myDatabaseConnection.getDecodeValue("Calendar - Weeks before current date")
        // This is string value so need to convert to integer, and subtract from 0 to get a negative
        
        let myStartDateValue:NSTimeInterval = 0 - ((((myStartDateString as NSString).doubleValue * 7) + 1) * 24 * 60 * 60)
        
        let startDate = baseDate.dateByAddingTimeInterval(myStartDateValue)
        
        /* The end date */
        //Calculate - Days * hours * mins * secs
        
        let myEndDateString = myDatabaseConnection.getDecodeValue("Calendar - Weeks after current date")
        // This is string value so need to convert to integer
        
        let myEndDateValue:NSTimeInterval = (myEndDateString as NSString).doubleValue * 7 * 24 * 60 * 60
        
        let endDate = baseDate.dateByAddingTimeInterval(myEndDateValue)
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        _ = eventStore.predicateForEventsWithStartDate(
            startDate,
            endDate: endDate,
            calendars: nil)
        
        /* Fetch all the meetings that fall between the starting and the ending dates */
        
        return myDatabaseConnection.getAgendaForDateRange(startDate, inEndDate: endDate, inTeamID: myCurrentTeam.teamID)
    }
    
    private func storeEvent(inEvent: EKEvent, inAttendee: EKParticipant?)
    {
        let calendarEntry = myCalendarItem(inEventStore: eventStore, inEvent: inEvent, inAttendee: inAttendee)
        
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
            
            if event.startDate.compare(NSDate()) == NSComparisonResult.OrderedAscending
            {
                // Event is in the past
                writeRowToArray(myString, inTable: &tableContents, inDisplayFormat: "Gray")
            }
            else
            {
                writeRowToArray(myString, inTable: &tableContents)
            }
        }
        return tableContents
    }
}

class ReminderData
{
    var reminderText: String
    private var myDisplayFormat: String
    private var myPriority: Int
    private var myNotes: String!
    private var mycalendarItemIdentifier: String!
    
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
    private var reminderStore: EKEventStore!
    private var targetReminderCal: EKCalendar!
    private var reminderDetails: [ReminderData] = Array()
    private var reminderRecords: [EKReminder] = Array()
    
    init()
    {
        reminderStore = EKEventStore()
        reminderStore.requestAccessToEntityType(EKEntityType.Reminder,
            completion: {(granted: Bool, error:NSError?) in
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
    
    func parseReminderDetails (inSearch: String)
    {
        let cals = reminderStore.calendarsForEntityType(EKEntityType.Reminder)
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
            let predicate = reminderStore.predicateForIncompleteRemindersWithDueDateStarting(nil, ending: nil, calendars: [targetReminderCal])

            var asyncDone = false
        
            reminderStore.fetchRemindersMatchingPredicate(predicate, completion: {reminders in
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
    private var myDelegate: MyMeetingsDelegate!
    private var myEvent: myCalendarItem!
    private var myActionType: String = ""
    
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

func parsePastMeeting(inMeetingID: String) -> [task]
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
            let myData2 = myDatabaseConnection.getMeetingsTasks(myItem.meetingID)
            
            for myItem2 in myData2
            {
                let newTask = task(taskID: myItem2.taskID as Int)
                if newTask.status != "Closed"
                {
                    myArray.append(newTask)
                }
            }
            
            if myItem.previousMeetingID != ""
            {
                myReturnArray = parsePastMeeting(myItem.previousMeetingID)
                
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

