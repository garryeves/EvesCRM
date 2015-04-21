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


func parseCalendarDetails (contactRecord: ABRecord)-> [String]
{
    
    var emailAddresses:[String] = [" "]
    var tableContents:[String] = [" "]
    
    emailAddresses.removeAll()
    tableContents.removeAll()
    
    // First we need to find out the email addresses for the person so can check through calendar entries

    addToContactDetailTable (contactRecord, "", kABPersonEmailProperty, &emailAddresses)

    
    for email in emailAddresses
    {
        println(email)
  
    }
    
    parseCalendar()
    
    
    
//    for (itemDescription, itemKey) in contactComponentsProperty
//    {
//        addToContactDetailTable (contactRecord, itemDescription, itemKey, &tableContents)
//    }
    
    return tableContents
    
}


func parseCalendar()
{
    // Find calendar entries based on email addresses and invitees
    
    /* Instantiate the event store */
    let eventStore = EKEventStore()
 
    /*
    let icloudSource = sourceInEventStore(eventStore,
        EKSourceTypeCalDAV,
        "iCloud")
    
    if icloudSource == nil{
        println("You have not configured iCloud for your device.")
        return
    }
    
    let calendar = calendarWithTitle("Calendar",
        EKCalendarTypeCalDAV,
        icloudSource!,
        EKEntityTypeEvent)
    
    if calendar == nil{
        println("Could not find the calendar we were looking for.")
        return
    }
    
*/

    
    /* The event starts from today, right now */
    let startDate = NSDate()
    
    /* The end date will be 1 day from today */
    let endDate = startDate.dateByAddingTimeInterval(24 * 60 * 60)
    
    /* Create the predicate that we can later pass to the
    event store in order to fetch the events */
    let searchPredicate = eventStore.predicateForEventsWithStartDate(
        startDate,
        endDate: endDate,
        calendars: nil)
    //calendars: [calendar!])
    
    /* Fetch all the events that fall between
    the starting and the ending dates */
    events = eventStore.eventsMatchingPredicate(searchPredicate)
        as! [EKEvent]
    
    if events.count == 0 {
        println("No events could be found")
    } else {
        
        // Go through all the events and print them to the console
        for event in events{
            
            println("Event title = \(event.title)")
            println("Event start date = \(event.startDate)")
            println("Event end date = \(event.endDate)")
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