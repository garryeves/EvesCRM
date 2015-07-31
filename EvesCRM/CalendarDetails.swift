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
    private var myAgendaID: String = ""
    private var myTasks: [task] = Array()
    private var myMeetingID: String = ""

    var actualEndTime: NSDate?
    {
        get
        {
            return myActualEndTime
        }
        set
        {
            myActualEndTime = newValue
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
    
    var decisionMade: String
    {
        get
        {
            return myDecisionMade
        }
        set
        {
            myDecisionMade = newValue
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
        }
    }
    
    var agendaID: String
    {
        get
        {
            return myAgendaID
        }
        set
        {
            myAgendaID = newValue
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
    }
    
    func save()
    {
        // call code to perform the save
        
        // Before we can save this we need to get the Agenda ID.
        // To allow for previous meeting actions this will mean that the first AgendaID will alway be 2

        if myAgendaID == ""
        {
            let tempAgendaItems = myDatabaseConnection.loadAgendaItem(myMeetingID)
        
            myAgendaID = "\(tempAgendaItems.count + 2)"
        
            myDatabaseConnection.saveAgendaItem(myMeetingID, inItem: self)
        }
        else
        {
            myDatabaseConnection.updateAgendaItem(myMeetingID, inItem: self)
        }
    }
    
    func delete()
    {
        // call code to perform the delete
        myDatabaseConnection.deleteAgendaItem(myMeetingID, inItem: self)
    }
    
    func loadTasks()
    {
        myTasks.removeAll()
        
        let myAgendaTasks = myDatabaseConnection.getAgendaTasks(myMeetingID, inAgendaID:myAgendaID)
        
        for myAgendaTask in myAgendaTasks
        {
            let myNewTask = task(inTaskID: myAgendaTask.taskID as Int)
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
    private var myEvent: EKEvent!
    private var myAttendees: [meetingAttendee] = Array()
    private var myChair: String = ""
    private var myMinutes: String = ""
    private var myPreviousMinutes: String = ""
    private var myNextMeeting: String = ""
    private var myMinutesType: String = ""
    private var myAgendaItems: [meetingAgendaItem] = Array()

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

    init(inEventStore: EKEventStore)
    {
        startDateFormatter.dateStyle = dateFormat
        startDateFormatter.timeStyle = timeFormat
        endDateFormatter.timeStyle = timeFormat
        eventStore = inEventStore
    }
    
    var event: EKEvent
    {
        get
        {
            return myEvent
        }
        set
        {
            myEvent = newValue
            myEventID = myEvent.eventIdentifier
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
            var myString : String = ""
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
        }
    }
    
    var nextMeeting: String
    {
        get
        {
            return myNextMeeting
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
                myEventID = myEvent.eventIdentifier
                return myEvent.eventIdentifier
            }
        }
    }
/*
    var originalEventID: String
    {  // This is used because changing a recurring event occurance adds some extra text into the ID, this is to allow us to strip that off
        get
        {
            if myEventID == ""
            {
                myEventID = myEvent.eventIdentifier
            }
            
            let start = myEventID.startIndex
            let end = find(myEventID, "/")
            
            var returnString: String = ""
            
            if end != nil
            {
                let myEnd = end?.predecessor()
                returnString = myEventID[start...myEnd!]
            }
            else
            { // no space found
                returnString = myEventID
            }

            return returnString
        }
    }
*/
    var minutesType: String
    {
        get
        {
            return myMinutesType
        }
        set
        {
            myMinutesType = newValue
        }
    }
    
    var agendaItems: [meetingAgendaItem]
    {
        get
        {
            return myAgendaItems
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
    }
    
    func removeAttendee(inIndex: Int)
    {
        // we should know the index of the item we want to delete from the control, so only need its index in order to perform the required action
        myAttendees.removeAtIndex(inIndex)
    }
    
    func populateAttendeesFromInvite()
    {
        // Use this for the initial population of the attendees
        
        for attendee in event.attendees as! [EKParticipant]
        {
            var emailText: String = "\(attendee.URL)"
            var emailStartPos = find(emailText,":")
            var nextPlace = emailStartPos?.successor()
            var emailAddress: String = ""
            if nextPlace != nil
            {
                var emailEndPos = emailText.endIndex.predecessor()
                emailAddress = emailText[nextPlace!...emailEndPos]
            }
            
            addAttendee(attendee.name, inEmailAddress: emailAddress, inType: "Participant", inStatus: "Invited")
        }
    }
    
    func saveAgenda()
    {
        // if this is for a repeating event then we need to add in the original startdate to the Notes

        if event.hasRecurrenceRules
        {  // recurring event
            // if we do not have a "unique" id for this occurrence then we need to save the calendar event, with a small change, and then get the event ID again
            
            if event.isDetached
            { // Event is already detached from the recurring event
               // Do nothing
            }
            else
            { // Not found
                if event.hasNotes
                {
                    event.notes = event.notes + "."
                }
                else
                {
                    event.notes = "."
                }
                eventStore.saveEvent(event,span: EKSpanThisEvent, commit: true,  error: nil)
                
                myEventID = myEvent.eventIdentifier
            }
        }
        
        //  Here we save the Agenda details
        
        // Save Agenda details
        if mySavedData
        {
            myDatabaseConnection.updateAgenda(self)
        }
        else
        {
            myDatabaseConnection.createAgenda(self)
        }
        // Save Attendees
        
        myDatabaseConnection.saveAttendee(eventID, inAttendees: myAttendees)
        
        mySavedData = true
    }
    
    func loadAgenda()
    {
        // Used where the invite is no longer in the calendar, and also to load up historical items for the "minutes" views
        
        var mySavedValues: [MeetingAgenda]!
        if myEventID == ""
        {
            mySavedValues = myDatabaseConnection.loadAgenda(myEvent.eventIdentifier)
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAgenda(myEventID)
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
        
        if myEventID == ""
        {
            mySavedValues = myDatabaseConnection.loadAttendees(myEvent.eventIdentifier)
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAttendees(myEventID)
        }
        
        myAttendees.removeAll(keepCapacity: false)
        
        if myStartDate.compare(NSDate()) == NSComparisonResult.OrderedDescending
        { // Start date is in the future, so we need to check the meeting invite attendeees
            
            if mySavedValues.count > 0
            {
                for savedAttendee in mySavedValues
                {
                    inviteeFound = false
                    for invitee in myEvent.attendees as! [EKParticipant]
                    {
                        // Check to see if any "Invited" people are no longer on calendar invite, and if so remove from Agenda.
                
                        if invitee.name == savedAttendee.name
                        {
                            // Invitee found
                    
                            var emailText: String = "\(invitee.URL)"
                            var emailStartPos = find(emailText,":")
                            var nextPlace = emailStartPos?.successor()
                            var emailAddress: String = ""
                            if nextPlace != nil
                            {
                                var emailEndPos = emailText.endIndex.predecessor()
                                emailAddress = emailText[nextPlace!...emailEndPos]
                            }
                    
                            addAttendee(invitee.name, inEmailAddress: emailAddress, inType: "Participant", inStatus: "Invited")
                    
                            inviteeFound = true
                    
                            break
                        }
                    }
                
                    if !inviteeFound
                    {
                        // Person not found on invite
                    
                        if savedAttendee.attendenceStatus == "Added"
                        {
                            // Mnaually added person, so continue
                            addAttendee(savedAttendee.name, inEmailAddress: savedAttendee.email, inType: savedAttendee.type, inStatus: savedAttendee.attendenceStatus)
                        }
                    }
            
                    if savedAttendee.name == myChair
                    {
                        chairFound = true
                    }
            
                    if savedAttendee.name == myMinutes
                    {
                        minutesFound = true
                    }
                }
            
                if !chairFound
                {
                    myChair = ""
                    saveAgenda()
                }
            
                if !minutesFound
                {
                    myMinutes = ""
                    saveAgenda()
                }

                // Now we need to check for people added into the meeting but not in the saved list.
            
                if myEventID == ""
                {
                    mySavedValues = myDatabaseConnection.loadAttendees(myEvent.eventIdentifier)
                }
                else
                {
                    mySavedValues = myDatabaseConnection.loadAttendees(myEventID)
                }
            
                for invitee in myEvent.attendees as! [EKParticipant]
                {
                    // Check to see if any "Invited" people are no longer on calendar invite, and if so remove from Agenda.
                
                    inviteeFound = false
                    for checkAttendee in mySavedValues
                    {
                        if invitee.name == checkAttendee.name
                        {
                            // Invitee found
                            inviteeFound = true
                            break
                        }
                    }
                
                    if !inviteeFound
                    {
                        // New invitee so add into table
                
                        var emailText: String = "\(invitee.URL)"
                        var emailStartPos = find(emailText,":")
                        var nextPlace = emailStartPos?.successor()
                        var emailAddress: String = ""
                        if nextPlace != nil
                        {
                            var emailEndPos = emailText.endIndex.predecessor()
                            emailAddress = emailText[nextPlace!...emailEndPos]
                        }
                
                        addAttendee(invitee.name, inEmailAddress: emailAddress, inType: "Participant", inStatus: "Invited")
                    }
                }
            }
            else
            {
                for invitee in myEvent.attendees as! [EKParticipant]
                {
                    var emailText: String = "\(invitee.URL)"
                    var emailStartPos = find(emailText,":")
                    var nextPlace = emailStartPos?.successor()
                    var emailAddress: String = ""
                    if nextPlace != nil
                    {
                        var emailEndPos = emailText.endIndex.predecessor()
                        emailAddress = emailText[nextPlace!...emailEndPos]
                    }
                    
                    addAttendee(invitee.name, inEmailAddress: emailAddress, inType: "Participant", inStatus: "Invited")
                }
            }
        }
        else
        { // In the past so we just used the entried from the table
            for savedAttendee in mySavedValues
            {
                addAttendee(savedAttendee.name, inEmailAddress: savedAttendee.email, inType: savedAttendee.type, inStatus: savedAttendee.attendenceStatus)
            }
        }
    }
    
    func loadAgendaItems()
    {
        var mySavedValues: [MeetingAgendaItem]!
        
        if myEventID == ""
        {
            mySavedValues = myDatabaseConnection.loadAgendaItem(myEvent.eventIdentifier)
        }
        else
        {
            mySavedValues = myDatabaseConnection.loadAgendaItem(myEventID)
        }
        
        myAgendaItems.removeAll(keepCapacity: false)
        
        if mySavedValues.count > 0
        {
            for savedAttendee in mySavedValues
            {
                addAgendaItem(savedAttendee.agendaID, inTitle: savedAttendee.title, inOwner: savedAttendee.owner, inStatus: savedAttendee.status, inDecisionMade: savedAttendee.decisionMade, inDiscussionNotes: savedAttendee.discussionNotes, inTimeAllocation: savedAttendee.timeAllocation as Int)
            }
        }
    }
    
    func addAgendaItem(inAgendaID: String, inTitle: String, inOwner: String, inStatus: String, inDecisionMade: String, inDiscussionNotes: String, inTimeAllocation: Int)
    {
        let myAgendaItem: meetingAgendaItem = meetingAgendaItem(inMeetingID: myEventID)
        
        myAgendaItem.status = inStatus
        myAgendaItem.decisionMade = inDecisionMade
        myAgendaItem.discussionNotes = inDiscussionNotes
        myAgendaItem.timeAllocation = inTimeAllocation
        myAgendaItem.owner = inOwner
        myAgendaItem.title = inTitle
        myAgendaItem.agendaID = inAgendaID
        myAgendaItem.loadTasks()
        
        myAgendaItems.append(myAgendaItem)
    }
    
    func updateAgendaItems(inAgendaID: String, inTitle: String, inOwner: String, inStatus: String, inDecisionMade: String, inDiscussionNotes: String, inTimeAllocation: Int, inActualStartTime: NSDate, inActualEndTime: NSDate)
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
        }
    }
    
    func loadCalendarDetails(projectName: String)
    {
        parseCalendarByProject(projectName)
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
                    if event.attendees.count > 0
                    {
                        for attendee in event.attendees as! [EKParticipant]
                        {
                            var emailText: String = "\(attendee.URL)"
                            var emailStartPos = find(emailText,":")
                            var nextPlace = emailStartPos?.successor()
                            var emailAddress: String = ""
                            if nextPlace != nil
                            {
                                var emailEndPos = emailText.endIndex.predecessor()
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
                var myTitle = event.title
                        
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
        
        let myStartDateString = myDatabaseConnection.getDecodeValue("CalBeforeWeeks")
        // This is string value so need to convert to integer, and subtract from 0 to get a negative
        
        let myStartDateValue:NSTimeInterval = 0 - ((((myStartDateString as NSString).doubleValue * 7) + 1) * 24 * 60 * 60)
        
        let startDate = baseDate.dateByAddingTimeInterval(myStartDateValue)
        
        /* The end date */
        //Calculate - Days * hours * mins * secs
        
        let myEndDateString = myDatabaseConnection.getDecodeValue("CalAfterWeeks")
        // This is string value so need to convert to integer
        
        let myEndDateValue:NSTimeInterval = (myEndDateString as NSString).doubleValue * 7 * 24 * 60 * 60
        
        let endDate = baseDate.dateByAddingTimeInterval(myEndDateValue)
        
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        let searchPredicate = eventStore.predicateForEventsWithStartDate(
            startDate,
            endDate: endDate,
            calendars: nil)
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if eventStore.sources().count > 0
        {
            if eventStore.eventsMatchingPredicate(searchPredicate) != nil
            {
                events = eventStore.eventsMatchingPredicate(searchPredicate) as! [EKEvent]
            }
        }
        return events
    }

    private func storeEvent(inEvent: EKEvent, inAttendee: EKParticipant?)
    {
        let calendarEntry = myCalendarItem(inEventStore: eventStore)
        
        calendarEntry.event = inEvent
        calendarEntry.title = inEvent.title
        calendarEntry.startDate = inEvent.startDate
        calendarEntry.endDate = inEvent.endDate
        calendarEntry.location = inEvent.location
        
        var myRecurrence: String = ""
        if inEvent.recurrenceRules != nil
        {
            // This is a recurring event
            var myWorkingRecur: NSArray = inEvent.recurrenceRules
            
            for myItem in myWorkingRecur
            {
                calendarEntry.recurrenceFrequency = myItem.interval
                var testFrequency: EKRecurrenceFrequency = myItem.frequency
                calendarEntry.recurrence = Int(testFrequency.value)
            }
        }
        // Need to validate this works when displaying by person and also by project
        if inAttendee != nil
        {
            calendarEntry.status = Int(inAttendee!.participantStatus.value)
            calendarEntry.attendeeType = Int(inAttendee!.participantType.value)
        }
        
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
                writeRowToArray(myString, &tableContents, inDisplayFormat: "Gray")
            }
            else
            {
                writeRowToArray(myString, &tableContents)
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
        reminderStore.requestAccessToEntityType(EKEntityTypeReminder,
            completion: {(granted: Bool, error:NSError!) in
                if !granted {
                    println("Access to reminder store not granted")
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
        var cals = reminderStore.calendarsForEntityType(EKEntityTypeReminder) as! [EKCalendar]
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
            var predicate = reminderStore.predicateForIncompleteRemindersWithDueDateStarting(nil, ending: nil, calendars: [targetReminderCal])

            var asyncDone = false
        
            reminderStore.fetchRemindersMatchingPredicate(predicate, completion: {reminders in
                for reminder in reminders
                {
                    var workingString: ReminderData = ReminderData(reminderText: reminder.title!!, reminderCalendar: reminder.calendar)
 
                    if reminder.notes! != nil
                    {
                        workingString.notes = reminder.notes!
                    }
                    workingString.priority = reminder.priority
                    workingString.calendarItemIdentifier = reminder.calendarItemIdentifier
                    self.reminderDetails.append(workingString)
                    self.reminderRecords.append(reminder as! EKReminder)
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
            writeRowToArray("No reminders list found", &tableContents)
        }
        else
        {
            for myReminder in reminderDetails
            {
                var myString = "\(myReminder.reminderText)"
                
                switch myReminder.priority
                {
                    case 1: writeRowToArray(myString, &tableContents, inDisplayFormat: "Red")  //  High priority
                    
                    case 5: writeRowToArray(myString , &tableContents, inDisplayFormat: "Orange") // Medium priority
                    
                    default: writeRowToArray(myString , &tableContents)
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
