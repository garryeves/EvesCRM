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

var eventStore: EKEventStore!
var targetReminderCal: EKCalendar!

func parseCalendarDetails (contactRecord: ABRecord, inEventStore: EKEventStore, inout eventDetails: [EKEvent])-> [TableData]
{
    
    var emailAddresses:[String] = [" "]
    var tableContents:[TableData] = [TableData]()
    
    eventStore = inEventStore
    
    emailAddresses.removeAll()
    tableContents.removeAll()
    eventDetails.removeAll()
    
    // First we need to find out the email addresses for the person so can check through calendar entries

    let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonEmailProperty).takeUnretainedValue() as ABMultiValueRef
    
    let recordCount = ABMultiValueGetCount(decodeProperty)
    
    if recordCount > 0
    {
        for loopCount in 0...recordCount-1
        {
            parseCalendarByEmail(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String, &tableContents, &eventDetails)
        }
    }

    return tableContents
}

func parseCalendarDetails (projectName: String, inEventStore: EKEventStore, inout eventDetails: [EKEvent])-> [TableData]
{
    var tableContents:[TableData] = [TableData]()
    
    eventStore = inEventStore
    
    tableContents.removeAll()
    eventDetails.removeAll()
    
    parseCalendarBySubject(projectName, &tableContents, &eventDetails)
    
    return tableContents
}

func parseReminderDetails (contactRecord: ABRecord, inEventStore: EKEventStore, inout reminderDetails: [EKReminder])-> [TableData]
{
    
    var emailAddresses:[String] = [" "]
    var tableContents:[TableData] = [TableData]()
    
    eventStore = inEventStore
    
    emailAddresses.removeAll()
    tableContents.removeAll()
    reminderDetails.removeAll()
    
    // First we need to find out the email addresses for the person so can check through calendar entries
    
    var workingName: String = ABRecordCopyCompositeName(contactRecord).takeUnretainedValue() as String
    parseReminders(workingName, &tableContents, &reminderDetails)
    
    return tableContents
}

func parseCalendarDetails (inType: String, projectName: String, inEventStore: EKEventStore, inout reminderDetails: [EKReminder])-> [TableData]
{
    var tableContents:[TableData] = [TableData]()
    
    eventStore = inEventStore
    
    tableContents.removeAll()
    reminderDetails.removeAll()
    
    parseReminders(projectName, &tableContents, &reminderDetails)
    
    return tableContents
}



func parseCalendarByEmail(inEmail: String, inout tableContents: [TableData], inout eventDetails: [EKEvent])
{
    // Find calendar entries based on email addresses and invitees
    
    var events: [EKEvent] = []

    let attendeeType = [
        "Unknown",
        "Person",
        "Room",
        "Resource",
        "Group"
    ]
    
    let attendeeRole = [
        "Unknown",
        "Required",
        "Optional",
        "Chair",
        "Nonparticipant"
    ]

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
    
    let recurType = [
        "days",
        "weeks",
        "months",
        "year",
        "Unknown"
    ]

    // Seup Date format for display
    var startDateFormatter = NSDateFormatter()
    var endDateFormatter = NSDateFormatter()
    
    var dateFormat = NSDateFormatterStyle.MediumStyle
    var timeFormat = NSDateFormatterStyle.ShortStyle
    startDateFormatter.dateStyle = dateFormat
    startDateFormatter.timeStyle = timeFormat
    endDateFormatter.timeStyle = timeFormat
    
    /* Instantiate the event store */
    let baseDate = NSDate()
    
     /* The event starts from 1 week ago, right now */
    //Calculate
    // Days * hours * mins * secs
 
    let myStartDateString = getDecodeValue("CalBeforeWeeks")
    // This is string value so need to convert to integer, and subtract from 0 to get a negative
    
    let myStartDateValue:NSTimeInterval = 0 - ((((myStartDateString as NSString).doubleValue * 7) + 1) * 24 * 60 * 60)

    let startDate = baseDate.dateByAddingTimeInterval(myStartDateValue)
    
    /* The end date will be 1 month from today */
    //Calculate
    // Days * hours * mins * secs
  
    let myEndDateString = getDecodeValue("CalAfterWeeks")
    // This is string value so need to convert to integer
    
    let myEndDateValue:NSTimeInterval = (myEndDateString as NSString).doubleValue * 7 * 24 * 60 * 60
    
    let endDate = baseDate.dateByAddingTimeInterval(myEndDateValue)
    
    /* Create the predicate that we can later pass to the
    event store in order to fetch the events */
    let searchPredicate = eventStore.predicateForEventsWithStartDate(
            startDate,
            endDate: endDate,
            calendars: nil)
  
    /* Fetch all the events that fall between
        the starting and the ending dates */
    
    if eventStore.sources().count > 0
    {
        if eventStore.eventsMatchingPredicate(searchPredicate) != nil
        {
            events = eventStore.eventsMatchingPredicate(searchPredicate) as! [EKEvent]
    
            if events.count >  0
            {
                // Go through all the events and print them to the console
                for event in events{
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
                                    let dateStart = startDateFormatter.stringFromDate(event.startDate)
                                    let dateEnd = endDateFormatter.stringFromDate(event.endDate)
                        
                                    let attendStatus = attendeeStatus[Int(attendee.participantStatus.value)]
                                    let type = attendeeType[Int(attendee.participantType.value)]
                            
                                    var myRecurrence: String = ""
                                    if event.recurrenceRules != nil
                                    {
                                        // This is a recurring event
                                        var myWorkingRecur: NSArray = event.recurrenceRules
                                
                                        for myItem in myWorkingRecur
                                        {
                                            var myRecurDisplay: String = "\(myItem.interval)"
                                    
                                            var testFrequency: EKRecurrenceFrequency = myItem.frequency
                                    
                                            var myFrequency: String = recurType[Int(testFrequency.value)]
 
                                            myRecurrence =  ("\(myRecurDisplay) \(myFrequency)")
                                        }
                                    }

                                    // Build up the details we want to show ing the calendar
                            
                                    var myString = "\(event.title)\n"
                                    myString += "\(dateStart) - \(dateEnd)\n"
                                    if !myRecurrence.isEmpty
                                    {
                                        myString += "Occurs every \(myRecurrence)\n"
                                    }
                                    if event.location != ""
                                    {
                                        myString += "At \(event.location)\n"
                                    }
                                    myString += "Status = \(attendStatus)"
                        
                                    eventDetails.append(event)
                                    
                                    if event.startDate.compare(NSDate()) == NSComparisonResult.OrderedAscending
                                    {
                                        // Event is in the past
                                        writeRowToArray(myString, &tableContents, inDisplayFormat: "Gray")
                                    } else
                                    {
                                        writeRowToArray(myString, &tableContents)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

func parseCalendarBySubject(inProject: String, inout tableContents: [TableData], inout eventDetails: [EKEvent])
{
    // Find calendar entries based on email addresses and invitees
    
    var events: [EKEvent] = []
    
    let attendeeType = [
        "Unknown",
        "Person",
        "Room",
        "Resource",
        "Group"
    ]
    
    let attendeeRole = [
        "Unknown",
        "Required",
        "Optional",
        "Chair",
        "Nonparticipant"
    ]
    
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
    
    let recurType = [
        "days",
        "weeks",
        "months",
        "year",
        "Unknown"
    ]
    
    // Seup Date format for display
    var startDateFormatter = NSDateFormatter()
    var endDateFormatter = NSDateFormatter()
    
    var dateFormat = NSDateFormatterStyle.MediumStyle
    var timeFormat = NSDateFormatterStyle.ShortStyle
    startDateFormatter.dateStyle = dateFormat
    startDateFormatter.timeStyle = timeFormat
    endDateFormatter.timeStyle = timeFormat
    
    /* Instantiate the event store */
    let baseDate = NSDate()

    let myStartDateString = getDecodeValue("CalBeforeWeeks")
    // This is string value so need to convert to integer, and subtract from 0 to get a negative
    
    let myStartDateValue:NSTimeInterval = 0 - ((((myStartDateString as NSString).doubleValue * 7) + 1) * 24 * 60 * 60)
    
    let startDate = baseDate.dateByAddingTimeInterval(myStartDateValue)
    
    /* The end date will be 1 month from today */
    //Calculate
    // Days * hours * mins * secs
    
    let myEndDateString = getDecodeValue("CalAfterWeeks")
    // This is string value so need to convert to integer
    
    let myEndDateValue:NSTimeInterval = (myEndDateString as NSString).doubleValue * 7 * 24 * 60 * 60

    let endDate = baseDate.dateByAddingTimeInterval(myEndDateValue)
    
    /* The event starts from 1 week ago, right now */
    //Calculate
    // Days * hours * mins * secs
    
//    let startDate = baseDate.dateByAddingTimeInterval(-8 * 24 * 60 * 60)
    
    /* The end date will be 1 month from today */
    //Calculate
    // Days * hours * mins * secs
    
    
 //   let endDate = baseDate.dateByAddingTimeInterval(31 * 24 * 60 * 60)
    
    /* Create the predicate that we can later pass to the
    event store in order to fetch the events */
    
    let searchPredicate = eventStore.predicateForEventsWithStartDate(
        startDate,
        endDate: endDate,
        calendars: nil)
    
    /* Fetch all the events that fall between
    the starting and the ending dates */
    
    if eventStore.sources().count > 0
    {
        if eventStore.eventsMatchingPredicate(searchPredicate) != nil
        {
            events = eventStore.eventsMatchingPredicate(searchPredicate) as! [EKEvent]
            
            if events.count >  0
            {
                // Go through all the events and print them to the console
                for event in events{
                    var myTitle = event.title

                    if myTitle.lowercaseString.rangeOfString(inProject.lowercaseString) != nil
                    {
                        let dateStart = startDateFormatter.stringFromDate(event.startDate)
                        let dateEnd = endDateFormatter.stringFromDate(event.endDate)
                        
                        var myRecurrence: String = ""
                        if event.recurrenceRules != nil
                        {
                            // This is a recurring event
                            var myWorkingRecur: NSArray = event.recurrenceRules
                                        
                            for myItem in myWorkingRecur
                            {
                                var myRecurDisplay: String = "\(myItem.interval)"
                                            
                                var testFrequency: EKRecurrenceFrequency = myItem.frequency
                                            
                                var myFrequency: String = recurType[Int(testFrequency.value)]
                                            
                                myRecurrence =  ("\(myRecurDisplay) \(myFrequency)")
                            }
                        }
                                    
                        // Build up the details we want to show ing the calendar
                                    
                        var myString = "\(event.title)\n"
                        myString += "\(dateStart) - \(dateEnd)"
                        if !myRecurrence.isEmpty
                        {
                            myString += "\nOccurs every \(myRecurrence)"
                        }
                        if event.location != ""
                        {
                            myString += "\nAt \(event.location)"
                        }
                        
                        eventDetails.append(event)
                        
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
                }
            }
        }
    }
}


func parseReminders(workingName: String, inout tableContents: [TableData], inout reminderDetails: [EKReminder])
{
    var reminders: [EKReminder] = Array()

    var reminderStore = EKEventStore()
    
    reminderStore.requestAccessToEntityType(EKEntityTypeReminder,
        completion: {(granted: Bool, error:NSError!) in
            if !granted {
                println("Access to store not granted")
            }
    })
    
    var cals = reminderStore.calendarsForEntityType(EKEntityTypeReminder) as! [EKCalendar]
    var myString: String = ""
    var myCalFound = false
    
    for cal in cals
    {
        if cal.title == workingName
        {
            myCalFound = true
            
            targetReminderCal = cal
        }
    }
    
    if !myCalFound
    {
        myString = "No reminders list found"
        writeRowToArray(myString, &tableContents)
    }
    else
    {
        var predicate = reminderStore.predicateForIncompleteRemindersWithDueDateStarting(nil, ending: nil, calendars: [targetReminderCal])
        
        var myDisplayStrings: [ReminderData] = Array()

        var asyncDone = false
        
        reminderStore.fetchRemindersMatchingPredicate(predicate, completion: {reminders in
            for reminder in reminders {
                var workingString: ReminderData = ReminderData(reminderText: reminder.title!!, reminderCalendar: reminder.calendar)
 
                if reminder.notes! != nil
                {
                    workingString.notes = reminder.notes!
                }
                workingString.priority = reminder.priority
                workingString.calendarItemIdentifier = reminder.calendarItemIdentifier
                myDisplayStrings.append(workingString)
                reminderDetails.append(reminder as! EKReminder)
            }
            asyncDone = true
            })
   
        
        // Bit of a nasty workaround but this is to allow async to finish
        
        while !asyncDone
        {
            usleep(500)
        }
        
        for displayString in myDisplayStrings
        {
            switch displayString.priority
            {
            case 1: writeRowToArray("Red", displayString, &tableContents)  //  High priority
                
                case 5: writeRowToArray("Orange", displayString , &tableContents) // Medium priority
                
                default: writeRowToArray("None:", displayString , &tableContents)
            }
        }
    }
}
