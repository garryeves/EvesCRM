//
//  IOSCalendar.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 26/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import EventKit

class iOSCalendar
{
    fileprivate var eventRecords: [EKEvent] = Array()
    
    var events: [EKEvent]
    {
        get
        {
            return eventRecords
        }
    }
    
    fileprivate func parseCalendarByEmail(_ email: String, teamID: Int)
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
    
    fileprivate func parseCalendarByProject(_ project: String, teamID: Int)
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
        let events: [EKEvent] = []
        
//        let baseDate = Date()
//        
//        /* The event starts date */
//        //Calculate - Days * hours * mins * secs
//        
//        let myStartDateString = myDatabaseConnection.getDecodeValue("Calendar - Weeks before current date")
//        // This is string value so need to convert to integer, and subtract from 0 to get a negative
//        
//        let myStartDateValue:TimeInterval = 0 - ((((myStartDateString as NSString).doubleValue * 7) + 1) * 24 * 60 * 60)
//        
//        let startDate = baseDate.addingTimeInterval(myStartDateValue)
//        
//        /* The end date */
//        //Calculate - Days * hours * mins * secs
//        
//        let myEndDateString = myDatabaseConnection.getDecodeValue("Calendar - Weeks after current date")
//        // This is string value so need to convert to integer
//        
//        let myEndDateValue:TimeInterval = (myEndDateString as NSString).doubleValue * 7 * 24 * 60 * 60
//        
//        let endDate = baseDate.addingTimeInterval(myEndDateValue)
//        
//        /* Create the predicate that we can later pass to the event store in order to fetch the events */
//        let searchPredicate = globalEventStore.predicateForEvents(
//            withStart: startDate,
//            end: endDate,
//            calendars: nil)
//        
//        /* Fetch all the events that fall between the starting and the ending dates */
//        
//        if globalEventStore.sources.count > 0
//        {
//            events = globalEventStore.events(matching: searchPredicate)
//        }
        return events
    }
    
    fileprivate func storeEvent(_ event: EKEvent, attendee: EKParticipant?, teamID: Int)
    {
        eventRecords.append(event)
    }
    
//    func displayEvent() -> [TableData]
//    {
//        var tableContents: [TableData] = [TableData]()
//        
//        // Build up the details we want to show ing the calendar
//        
//        for event in eventDetails
//        {
//            var myString = "\(event.title)\n"
//            myString += "\(event.displayScheduledDate)\n"
//            
//            if event.recurrence != -1
//            {
//                myString += "Occurs every \(event.recurrenceFrequency) \(event.displayRecurrence)\n"
//            }
//            
//            if event.location != ""
//            {
//                myString += "At \(event.location)\n"
//            }
//            
//            if event.status != -1
//            {
//                myString += "Status = \(event.displayStatus)"
//            }
//            
//            if event.startDate.compare(Date()) == ComparisonResult.orderedAscending
//            {
//                // Event is in the past
//                writeRowToArray(myString, table: &tableContents, targetEvent: event, displayFormat: "Gray")
//            }
//            else
//            {
//                writeRowToArray(myString, table: &tableContents, targetEvent: event)
//            }
//        }
//        return tableContents
//    }
    
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

class iOSReminder
{
    fileprivate var reminderStore: EKEventStore!
    fileprivate var targetReminderCal: EKCalendar!
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
//                    let workingString: ReminderData = ReminderData(reminderText: reminder.title, reminderCalendar: reminder.calendar)
//                    
//                    if reminder.notes != nil
//                    {
//                        workingString.notes = reminder.notes!
//                    }
//                    workingString.priority = reminder.priority
//                    workingString.calendarItemIdentifier = reminder.calendarItemIdentifier
//                    self.reminderDetails.append(workingString)
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
    
//    func displayReminder() -> [TableData]
//    {
//        var tableContents: [TableData] = [TableData]()
//        
//        // Build up the details we want to show ing the calendar
//        
//        if reminderDetails.count == 0
//        {
//            writeRowToArray("No reminders list found", table: &tableContents)
//        }
//        else
//        {
//            for myReminder in reminderDetails
//            {
//                let myString = "\(myReminder.reminderText)"
//                
//                switch myReminder.priority
//                {
//                case 1: writeRowToArray(myString, table: &tableContents, displayFormat: "Red")  //  High priority
//                    
//                case 5: writeRowToArray(myString , table: &tableContents, displayFormat: "Orange") // Medium priority
//                    
//                default: writeRowToArray(myString , table: &tableContents)
//                }
//            }
//            
//        }
//        return tableContents
//    }
}

