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


var events: [EKEvent] = []


func parseCalendarDetails (inType: String, contactRecord: ABRecord)-> [String]
{
    
    var emailAddresses:[String] = [" "]
    var tableContents:[String] = [" "]
    
    emailAddresses.removeAll()
    tableContents.removeAll()
    
    // First we need to find out the email addresses for the person so can check through calendar entries

//    addToContactDetailTable (contactRecord, "", kABPersonEmailProperty, &emailAddresses)

    if inType == "Calendar"
    {
        let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonEmailProperty).takeUnretainedValue() as ABMultiValueRef
    
        let recordCount = ABMultiValueGetCount(decodeProperty)
    
        if recordCount > 0
        {
            for loopCount in 0...recordCount-1
            {
  //          emailAddresses.append(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String)
                parseCalendar(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String, &tableContents)
            
            }
        }
    }
    else if inType == "Reminders"
    {
        var myString = "Reminders"
        writeRowToArray(myString, &tableContents )
    }

    return tableContents
}


func parseCalendar(inEmail: String, inout tableContents: [String])
{
    // Find calendar entries based on email addresses and invitees
    
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

    // Seup Date format for display
    var startDateFormatter = NSDateFormatter()
    var endDateFormatter = NSDateFormatter()
    
    var dateFormat = NSDateFormatterStyle.MediumStyle
    var timeFormat = NSDateFormatterStyle.ShortStyle
    startDateFormatter.dateStyle = dateFormat
    startDateFormatter.timeStyle = timeFormat
    endDateFormatter.timeStyle = timeFormat
    
    /* Instantiate the event store */
    let eventStore = EKEventStore()
 
    
    /* The event starts from today, right now */
    let startDate = NSDate()
    
    /* The end date will be 1 year from today */
    //Calculate
    // Days * hours * mins * secs
    
    
    let endDate = startDate.dateByAddingTimeInterval(14 * 24 * 60 * 60)
    
    /* Create the predicate that we can later pass to the
    event store in order to fetch the events */
    let searchPredicate = eventStore.predicateForEventsWithStartDate(
            startDate,
            endDate: endDate,
            calendars: nil)
  
    /* Fetch all the events that fall between
        the starting and the ending dates */
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
                        var emailEndPos = emailText.endIndex.predecessor()
                        let emailAddress = emailText[nextPlace!...emailEndPos]
                        
                        if emailAddress == inEmail
                        {
                            let dateStart = startDateFormatter.stringFromDate(event.startDate)
                            let dateEnd = endDateFormatter.stringFromDate(event.endDate)
                        
                            let attendStatus = attendeeStatus[Int(attendee.participantStatus.value)]
                            let type = attendeeType[Int(attendee.participantType.value)]
                            
                            // Build up the details we want to show ing the calendar
                            
                            var myString = "\(event.title)\n"
                            myString += "\(dateStart) - \(dateEnd)\n"
                            if event.location != ""
                            {
                                myString += "At \(event.location)\n"
                            }
                            myString += "Status = \(attendStatus)"
                        
                            writeRowToArray(myString, &tableContents )
                        }
                    }
                }
            }
        }
    }
}

func sourceInEventStore(
    eventStore: EKEventStore,
    type: EKSourceType,
    title: String) -> EKSource?{
        
        for source in eventStore.sources() as! [EKSource]{
            if source.sourceType.value == type.value &&
                source.title.caseInsensitiveCompare(title) ==
                NSComparisonResult.OrderedSame{
                    return source
            }
        }
        
        return nil
}
/*
func calendarWithTitle(
    title: String,
    type: EKCalendarType,
    source: EKSource,
    eventType: EKEntityType) -> EKCalendar?{
        
        for calendar in source.calendarsForEntityType(eventType)
            as [EKCalendar]{
                if calendar.title.caseInsensitiveCompare(title) ==
                    NSComparisonResult.OrderedSame &&
                    calendar.type.value == type.value{
                        return calendar
                }
        }
        
        return nil
}
*/