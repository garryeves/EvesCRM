//
//  IOSCalendar.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 26/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import EventKit

class iOSCalendarList
{
    fileprivate var myList: [iOSCalendarListItem] = Array()
    
    var list: [iOSCalendarListItem]
    {
        return myList
    }
    
    init()
    {
        myList.removeAll()
        
        for myItem in globalEventStore.calendars(for: .event)
        {
            let name = "\(myItem.source.title) - \(myItem.title)"
            var state: Bool = false
            if readDefaultString(name) == "True"
            {
                state = true
            }
            
            let newItem = iOSCalendarListItem(name: name, state: state, calendar: myItem)
            myList.append(newItem)
        }
        
        if myList.count > 0
        {
            myList.sort
            {
                return $0.name < $1.name
            }
        }
    }
}

class iOSCalendarListItem
{
    fileprivate var myName: String = ""
    fileprivate var myState: Bool = false
    fileprivate var myCalendar: EKCalendar!
    
    var name: String
    {
        return myName
    }
    
    var state: Bool
    {
        get
        {
            return myState
        }
        set
        {
            if newValue
            {
                writeDefaultString(myName, value: "True")
            }
            else
            {
                writeDefaultString(myName, value: "False")
            }
            
            myState = newValue
        }
    }
    
    var calendar: EKCalendar
    {
        return myCalendar
    }
    
    init(name: String, state: Bool, calendar: EKCalendar)
    {
        myName = name
        myState = state
        myCalendar = calendar
    }
}

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
    
    init(email: String, teamID: Int, startDate: Date, endDate: Date)
    {
        let events = getEventsForDateRange(startDate: startDate, endDate: endDate)
        
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
    
    init(projectName: String, teamID: Int, startDate: Date, endDate: Date)
    {
        let events = getEventsForDateRange(startDate: startDate, endDate: endDate)
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                let myTitle = event.title
                
                if myTitle.lowercased().range(of: projectName.lowercased()) != nil
                {
                    storeEvent(event, attendee: nil, teamID: teamID)
                }
            }
        }
    }
    
    init(teamID: Int, startDate: Date, endDate: Date)
    {
        let events = getEventsForDateRange(startDate: startDate, endDate: endDate)
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                storeEvent(event, attendee: nil, teamID: teamID)
            }
        }
    }
    
    init(teamID: Int, workingDate: Date)
    {
        let events = getEventsForDate(workingDate)
        
        if events.count >  0
        {
            // Go through all the events and print them to the console
            for event in events
            {
                storeEvent(event, attendee: nil, teamID: teamID)
            }
        }
    }
    
    fileprivate func getEventsForDateRange(startDate: Date, endDate: Date) -> [EKEvent]
    {
        /* Create the predicate that we can later pass to the event store in order to fetch the events */
        
        // Build the list of calendars to search
        
        var selectedCalendar: [EKCalendar] = Array()
        
        for myItem in iOSCalendarList().list
        {
            if myItem.state
            {
                selectedCalendar.append(myItem.calendar)
            }
        }
        
        var searchPredicate: NSPredicate!
        
        if selectedCalendar.count > 0
        {
            searchPredicate = globalEventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: selectedCalendar)
        }
        else
        {
            searchPredicate = globalEventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: nil)
        }
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if globalEventStore.sources.count > 0
        {
            return globalEventStore.events(matching: searchPredicate)
        }
        else
        {
            return []
        }
    }
    
    fileprivate func getEventsForDate(_ workingDate: Date) -> [EKEvent]
    {
        let startDate = workingDate.startOfDay
        
        /* The end date */
        
        let endDate = workingDate.add(.day, amount: 1).startOfDay
        
        var selectedCalendar: [EKCalendar] = Array()
        
        for myItem in iOSCalendarList().list
        {
            if myItem.state
            {
                selectedCalendar.append(myItem.calendar)
            }
        }
        
        var searchPredicate: NSPredicate!
        
        if selectedCalendar.count > 0
        {
            searchPredicate = globalEventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: selectedCalendar)
        }
        else
        {
            searchPredicate = globalEventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: nil)
        }
        
        /* Fetch all the events that fall between the starting and the ending dates */
        
        if globalEventStore.sources.count > 0
        {
            return globalEventStore.events(matching: searchPredicate)
        }
        else
        {
            return []
        }
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
    
//    func getCalendarRecords() -> [TableData]
//    {
//        var outputArray: [TableData] = Array()
//        
//        let endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
//        
//        /* Create the predicate that we can later pass to the event store in order to fetch the events */
//        let searchPredicate = globalEventStore.predicateForEvents(
//            withStart: Date(),
//            end: endDate!,
//            calendars: nil)
//        
//        /* Fetch all the events that fall between the starting and the ending dates */
//        
//        if globalEventStore.sources.count > 0
//        {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .medium
//            dateFormatter.timeStyle = .short
//            
//            for calItem in globalEventStore.events(matching: searchPredicate)
//            {
//                var tempEntry = TableData(displayText: calItem.title)
//                tempEntry.notes = dateFormatter.string(from: calItem.startDate)
//                tempEntry.event = calItem
//                
//                outputArray.append(tempEntry)
//            }
//            
//            return outputArray
//        }
//        else
//        {
//            return []
//        }
//    }
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

