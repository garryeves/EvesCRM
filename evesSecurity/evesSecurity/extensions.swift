//
//  extensions.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 4/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation

extension String
{
//    var html2String:String
//    {
//        do
//        {
//            return try NSAttributedString(data: data(using: String.Encoding.utf8)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:String.Encoding.utf8], documentAttributes: nil).string
//        }
//        catch let error as NSError
//        {
//            NSLog("Warning: failed to create plain text \(error)")
//            return ""
//        }
//        catch
//        {
//            NSLog("html2String unknown error")
//            return ""
//        }
//    }
    
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
    
    func characterAtIndex(index: Int) -> Character {
        var cur = 0
        var retVal: Character!
        for char in self.characters {
            if cur == index {
                retVal = char
            }
            cur += 1
        }
        return retVal
    }
    
    func stringByChangingChars(oldChar: String, newChar: String) -> String
    {
        let regex = try! NSRegularExpression(pattern:oldChar, options:.caseInsensitive)
        let myString = regex.stringByReplacingMatches(in: self, options:  NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, self.characters.count), withTemplate:newChar)
        
        return myString
    }
    
    var getFirstPartofString: String
    {
        let start = self.startIndex
        let end = self.characters.index(of: ":")
        
        var selectedType: String = ""
        
        if end != nil
        {
            let myEnd = self.index(before: (end)!)
            selectedType = self[start...myEnd]
        }
        else
        { // no space found
            selectedType = self
        }
        return selectedType
    }
    
    var formatStringToDateTime: Date
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "E dd MMM yy HH:mm"
        return myDateFormatter.date(from: self)!
    }
}

extension Double
{
    var formatHours: String
    {
        // Format the hours display
        
        if self == Double(Int(self))
        {
            return "\(Int(self))"
        }
        else
        {
            return "\(self)"
        }
    }
    
    var formatPercent: String
    {
        // Format the hours display
        
        if self == Double(Int(self))
        {
            return "\(Int(self))%"
        }
        else
        {
            let doubleStr = String(format: "%.1f", self)
            // Need to format to only 1 decimal place
            return "\(doubleStr)%"
        }
    }
    
    var formatCurrency: String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2;
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: self as NSNumber);
        return result!;
    }
    
    var formatCurrencyNoDecimal: String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0;
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: self as NSNumber);
        return result!;
    }
    
    var formatIntString: String
    {
        return "\(Int(self))"
    }
}

extension Date
{
    var formatDateToString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "E dd MMM yy"
        return myDateFormatter.string(from: self)
    }
    
    var formatTimeString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "h:mm"
        return myDateFormatter.string(from: self)
    }
    
    var formatDateAndTimeString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "E dd MMM yy h:mm"
        return myDateFormatter.string(from: self)
    }
    
    var formatDateToShortString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "E dd/MM"
        return myDateFormatter.string(from: self)
    }
    
    func dateDifferenceHours(to: Date) -> Int
    {
        return Calendar.current.dateComponents([.hour], from: self, to: to).hour ?? 0
    }
    
    func dateDifferenceMinutes(to: Date) -> Int
    {
        // Get number of hours
        
        let numHours = self.dateDifferenceHours(to: to)
        
        let numMins = Calendar.current.dateComponents([.minute], from: self, to: to).minute ?? 0
        
        return numMins - (numHours * 60)
    }
    
    var getDayOfWeek: Int
    {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: self)
        return weekDay
    }
    
    func add(_ unit: Calendar.Component, amount: Int) -> Date
    {
        let myCalendar = Calendar(identifier: .gregorian)
        
        return myCalendar.date(
            byAdding: unit,
            value: Int(amount),
            to: self)!
    }
    
    var getWeekEndingDate: Date
    {
        let dateModifier = (7 - self.getDayOfWeek) + 1
        
        if dateModifier != 7
        {
            return self.add(.day, amount: dateModifier).startOfDay
        }
        else
        {
            return self.startOfDay
        }
    }
    
    func calculateDateForWeekDay(dayToFind: Int) -> Date
    {
        var returnDate: Date!
        var daysToAdd: Int = 0
        
        let calendar = Calendar.current
        
        var currentDateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: self)
        currentDateComponents.timeZone = TimeZone(identifier: "UTC")
        
        // Need to work out the days to add
        
        if dayToFind == currentDateComponents.weekday
        {  // The date has hit the correct day of the week
            returnDate = self
            daysToAdd = 0
        }
        else if dayToFind > currentDateComponents.weekday!
        {
            daysToAdd = dayToFind - currentDateComponents.weekday!
        }
        else
        {
            daysToAdd = 7 - currentDateComponents.weekday! + dayToFind
        }
        
        if daysToAdd > 0
        {
            returnDate = calendar.date(
                byAdding: .day,
                value: daysToAdd,
                to: self)!
        }
        
        return returnDate
    }
    
    func calculateNewDate(dateBase: String, interval: Int16, period: String) -> Date
    {
        var addCalendarUnit: Calendar.Component!
        var tempInterval = interval
        var returnDate = Date()
        
        var calendar = Calendar.current
        
        switch period
        {
            case "Day":
                addCalendarUnit = .day
                
            case "Week":
                addCalendarUnit = .day
                tempInterval = interval * 7   // fudge a there is no easy week setting
                
            case "Month":
                addCalendarUnit = .month
                
            case "Quarter":
                addCalendarUnit = .month
                tempInterval = interval * 3   // fudge a there is no easy quarter setting
                
            case "Year":
                addCalendarUnit = .year
                
            default:
                NSLog("calculateNewDate inPeriod hit default")
                addCalendarUnit = .day
        }
        
        calendar.timeZone = TimeZone.current
        
        switch dateBase
        {
            case "Completion Date", "Start Date" :
                returnDate = self.add(addCalendarUnit, amount: Int(tempInterval))
            
            case "1st of month":
                // date math to get appropriate month
                
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                var currentDateComponents = calendar.dateComponents([.year, .month], from: tempDate)
                currentDateComponents.day = 1
                
                currentDateComponents.timeZone = TimeZone(identifier: "UTC")
                
                returnDate = calendar.date(from: currentDateComponents)!
                
            case "Monday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 2)
                
            case "Tuesday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 3)
                
            case "Wednesday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 4)
                
            case "Thursday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 5)
                
            case "Friday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 6)
                
            case "Saturday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 7)
                
            case "Sunday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 1)
                
            default:
                NSLog("calculateNewDate Bases hit default")
        }
        
        return returnDate
    }
    
    var startOfDay: Date
    {
       // let calendar = Calendar.current
        // get the start of the day of the selected date
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar.startOfDay(for: self)
    }
}
