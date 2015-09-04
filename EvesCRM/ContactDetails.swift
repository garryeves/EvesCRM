//
//  ContactDetails.swift
//  EvesCRM
//
//  Created by Garry Eves on 16/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

//This file is used to populate Contact details table

import Foundation
import AddressBook

class iOSContact
{
    private var myFacebookID: String = ""
    private var myLinkedInID: String = ""
    private var myTwitterID: String = ""
    private var tableContents:[TableData] = [TableData]()
    private var myContactRecord: ABRecord!
    private var myEmailAddresses: [String]!
    private var myFullName: String = ""
    
    var facebookID: String
    {
        get
        {
            return myFacebookID
        }
    }

    var linkedInID: String
    {
        get
        {
            return myLinkedInID
        }
    }
    
    var twitterID: String
    {
        get
        {
            return myTwitterID
        }
    }
    
    var tableData: [TableData]
    {
        get
        {
            return tableContents
        }
    }
    
    var contactRecord: ABRecord
    {
        get
        {
            return myContactRecord
        }
    }
 
    var emailAddresses: [String]
    {
        get
        {
            return myEmailAddresses
        }
    }
    
    var fullName: String
    {
        get
        {
            return myFullName
        }
    }

    init (contactRecord: ABRecord)
    {
        myContactRecord = contactRecord
        tableContents.removeAll()
        myEmailAddresses = Array()
        
        addToContactDetailTable ("Name", rowType: kABPersonFirstNameProperty)
        addToContactDetailTable ("Address", rowType: kABPersonAddressProperty)
        addToContactDetailTable ("Organisation", rowType: kABPersonOrganizationProperty)
        addToContactDetailTable ("Job Title", rowType: kABPersonJobTitleProperty)
        addToContactDetailTable ("Dept", rowType: kABPersonDepartmentProperty)
        addToContactDetailTable ("Phone", rowType: kABPersonPhoneProperty)
        addToContactDetailTable ("Email", rowType: kABPersonEmailProperty)
        addToContactDetailTable ("Note", rowType: kABPersonNoteProperty)
        addToContactDetailTable ("DOB", rowType: kABPersonDateProperty)
        addToContactDetailTable ("IM", rowType: kABPersonInstantMessageProperty)
        addToContactDetailTable ("Social Media", rowType: kABPersonSocialProfileProperty)
        addToContactDetailTable ("Home Page", rowType: kABPersonURLProperty)
        addToContactDetailTable ("Birthday", rowType: kABPersonBirthdayProperty)
        addToContactDetailTable ("Nickname", rowType: kABPersonNicknameProperty)
        
        myFullName = (ABRecordCopyCompositeName(myContactRecord).takeRetainedValue() as String) ?? ""
    }

    private func addToContactDetailTable (rowDescription: String, rowType: ABPropertyID)
    {
        var line1:String = ""
        var line2:String = ""
        var line3:String = ""
        var line4:String = ""
        
        switch rowType
        {
        case kABPersonAddressProperty:
            let decodeProperty : ABMultiValueRef = ABRecordCopyValue(myContactRecord, kABPersonAddressProperty).takeUnretainedValue() as ABMultiValueRef
            
            if ABMultiValueGetCount(decodeProperty) > 0
            {
                let decode: NSDictionary = ABMultiValueCopyValueAtIndex(decodeProperty,0).takeRetainedValue() as! NSDictionary
                
                if decode.count > 0
                {
                    if decode[kABPersonAddressStreetKey as String]?.length > 0
                    {
                        line1 = decode[kABPersonAddressStreetKey as String] as! String
                    }
                    if decode[kABPersonAddressCityKey as String]?.length > 0
                    {
                        line2 = decode[kABPersonAddressCityKey as String] as! String
                    }
                    if decode[kABPersonAddressCountryKey as String]?.length > 0
                    {
                        line3 = decode[kABPersonAddressCountryKey as String] as! String
                    }
                    if decode[kABPersonAddressZIPKey as String]?.length > 0
                    {
                        line4 = decode[kABPersonAddressZIPKey as String] as! String
                    }
                    
                    writeRowToArray("Address : \(line1)\n\(line2)\n\(line3)\n\(line4)", inTable: &tableContents)
                }
            }
            
        case kABPersonDateProperty:
            let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonDateProperty).takeUnretainedValue() as ABMultiValueRef
            
            if ABMultiValueGetCount(decodeProperty) > 0
            {
                let recordCount = ABMultiValueGetCount(decodeProperty)
                
                if recordCount > 0
                {
                    for loopCount in 0...recordCount-1
                    {
                        let initialDate: NSDate = ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! NSDate
                        
                        let dateFormatter = NSDateFormatter()
                        
                        let dateFormat = NSDateFormatterStyle.ShortStyle
                        
                        dateFormatter.dateStyle = dateFormat
                        
                        let dateString = dateFormatter.stringFromDate(initialDate)
                        
                        switch loopCount
                        {
                        case 0:
                            
                            writeRowToArray("Anniversary = " + dateString, inTable: &tableContents)
                            
                        default:  // Do nothing
                            writeRowToArray("Unknown date = " + dateString, inTable: &tableContents)
                        }
                    }
                }
            }
            
            
        case kABPersonPhoneProperty:
            
            let decodeProperty = ABRecordCopyValue(contactRecord, kABPersonPhoneProperty)
            let phonesNums: ABMultiValueRef = Unmanaged.fromOpaque(decodeProperty.toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
            
            let recordCount = ABMultiValueGetCount(phonesNums)
            
            var myString: String = ""
            
            for index in 0..<recordCount
            {
                var myType: CFString!
                
                if ABMultiValueCopyLabelAtIndex(phonesNums, index) != nil
                {
                    myType = ABMultiValueCopyLabelAtIndex(phonesNums, index).takeRetainedValue() as CFStringRef
                }
                else
                {
                    myType = "Unknown"
                }
                
                if myType == kABPersonPhoneMainLabel
                {
                    myString = "Main : "
                }
                else if myType == "_$!<Home>!$_"
                {
                    myString = "Home : "
                }
                else if myType == kABPersonPhoneMobileLabel
                {
                    myString = "Mobile : "
                }
                else if myType == kABPersonPhoneIPhoneLabel
                {
                    myString = "iPhone : "
                }
                else if myType == kABPersonPhoneHomeFAXLabel
                {
                    myString = "Home Fax : "
                }
                else if myType == kABPersonPhoneWorkFAXLabel
                {
                    myString = "Work Fax : "
                }
                else if myType == kABPersonPhoneOtherFAXLabel
                {
                    myString = "Other Fax : "
                }
                else if myType == kABPersonPhonePagerLabel
                {
                    myString = "Pager : "
                }
                else
                {
                    myString = "Unknown : "
                }
                
                myString += ABMultiValueCopyValueAtIndex(phonesNums, index).takeRetainedValue() as! String
                
                writeRowToArray(myString, inTable: &tableContents)
            }
            
        case kABPersonEmailProperty:
            let decodeProperty = ABRecordCopyValue(contactRecord, kABPersonEmailProperty)
            let emailAddrs: ABMultiValueRef = Unmanaged.fromOpaque(decodeProperty.toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
            
            let recordCount = ABMultiValueGetCount(emailAddrs)
            var myType: CFString!
            var myString: String = ""
            myEmailAddresses.removeAll(keepCapacity: false)
            
            if recordCount > 0
            {
                for loopCount in 0...recordCount-1
                {
                    
                    if ABMultiValueCopyLabelAtIndex(emailAddrs, loopCount) != nil
                    {
                        myType = ABMultiValueCopyLabelAtIndex(emailAddrs, loopCount).takeRetainedValue() as CFStringRef
                    }
                    else
                    {
                        myType = "Unknown"
                    }
                    
                    if myType == "_$!<Work>!$_"
                    {
                        myString = "Work : "
                    }
                    else if myType == "_$!<Home>!$_"
                    {
                        myString = "Home : "
                    }
                    else if myType == "_$!<Other>!$_"
                    {
                        myString = "Other : "
                    }
                    else
                    {
                        myString = "Email : "
                    }
                    
                    myString += ABMultiValueCopyValueAtIndex(emailAddrs, loopCount).takeRetainedValue() as! String
                    
                    myEmailAddresses.append(ABMultiValueCopyValueAtIndex(emailAddrs, loopCount).takeRetainedValue() as! String)
                    
                    writeRowToArray(myString, inTable: &tableContents)
                }
            }
            
        case kABPersonInstantMessageProperty:
            var strHolder :String = ""
            
            let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonInstantMessageProperty).takeUnretainedValue() as ABMultiValueRef
            
            if ABMultiValueGetCount(decodeProperty) > 0
            {
                
                let decode: NSDictionary = ABMultiValueCopyValueAtIndex(decodeProperty,0).takeRetainedValue() as! NSDictionary
                
                if decode.count > 0
                {
                    
                    if decode[kABPersonInstantMessageServiceYahoo as String]?.length > 0
                    {
                        strHolder = decode[kABPersonInstantMessageServiceYahoo as String]! as! String
                        writeRowToArray("Yahoo : " + strHolder, inTable: &tableContents)
                    }
                    if decode[kABPersonInstantMessageServiceJabber as String]?.length > 0
                    {
                        strHolder = decode[kABPersonInstantMessageServiceJabber as  String]! as! String
                        writeRowToArray("Jabber : " + strHolder, inTable: &tableContents )
                    }
                    if decode[kABPersonInstantMessageServiceMSN as String]?.length > 0
                    {
                        strHolder = decode[kABPersonInstantMessageServiceMSN as String]! as! String
                        writeRowToArray("MSN : " + strHolder, inTable: &tableContents)
                    }
                    if decode[kABPersonInstantMessageServiceICQ as String]?.length > 0
                    {
                        strHolder = decode[kABPersonInstantMessageServiceICQ as String]! as! String
                        writeRowToArray("ICQ : " + strHolder, inTable: &tableContents)
                    }
                    if decode[kABPersonInstantMessageServiceAIM as String]?.length > 0
                    {
                        strHolder = decode[kABPersonInstantMessageServiceAIM as String]! as! String
                        writeRowToArray("AIM : " + strHolder, inTable: &tableContents)
                    }
                    if decode[kABPersonInstantMessageServiceQQ as String]?.length > 0
                    {
                        strHolder = decode[kABPersonInstantMessageServiceQQ as String]! as! String
                        writeRowToArray("QQ : " + strHolder, inTable: &tableContents)
                    }
                    if decode[kABPersonInstantMessageServiceGoogleTalk as String]?.length > 0
                    {
                        strHolder = decode[kABPersonInstantMessageServiceGoogleTalk as String]! as! String
                        writeRowToArray("Google Talk : " + strHolder, inTable: &tableContents)
                    }
                    if decode[kABPersonInstantMessageServiceSkype as String]?.length > 0
                    {
                        strHolder = decode[kABPersonInstantMessageServiceSkype as String]! as! String
                        writeRowToArray("Skype : " + strHolder, inTable: &tableContents)
                    }
                    if decode[kABPersonInstantMessageServiceFacebook as String]?.length > 0
                    {
                        strHolder = decode[kABPersonInstantMessageServiceFacebook as String]! as! String
                        writeRowToArray("Facebook IM : " + strHolder, inTable: &tableContents )
                    }
                    if decode[kABPersonInstantMessageServiceGaduGadu as String]?.length > 0
                    {
                        strHolder = decode[kABPersonInstantMessageServiceGaduGadu as String]! as! String
                        writeRowToArray("GaduGadu : " + strHolder, inTable: &tableContents)
                    }
                }
            }
            
        case kABPersonSocialProfileProperty:
            var strHolder :String = ""
            
            myFacebookID = ""
            myLinkedInID = ""
            myTwitterID = ""
            
            let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonSocialProfileProperty).takeUnretainedValue() as ABMultiValueRef
            
            var loopcount: Int = 0
            var tempStr: String = ""
            
            while ABMultiValueGetCount(decodeProperty) > loopcount
            {
                tempStr = ""
                let myDecode: NSDictionary = ABMultiValueCopyValueAtIndex(decodeProperty,loopcount).takeRetainedValue() as! NSDictionary
                
                let myServiceName: String = myDecode[kABPersonSocialProfileServiceKey as String]! as! String
                
                if myServiceName == (kABPersonSocialProfileServiceTwitter as String)
                {
                    tempStr = "Twitter : "
                    myTwitterID = myDecode[kABPersonSocialProfileUsernameKey as String]! as! String
                }
                
                if myServiceName == (kABPersonSocialProfileServiceGameCenter as String)
                {
                    tempStr = "GameCenter : "
                }
                
                if myServiceName == (kABPersonSocialProfileServiceSinaWeibo as String)
                {
                    tempStr = "Sina Weibo : "
                }
                
                if myServiceName == (kABPersonSocialProfileServiceFacebook as String)
                {
                    tempStr = "Facebook : "
                    myFacebookID = myDecode[kABPersonSocialProfileUsernameKey as String]! as! String
                }
                
                if myServiceName == (kABPersonSocialProfileServiceMyspace as String)
                {
                    tempStr = "Myspace : "
                }
                
                if myServiceName == (kABPersonSocialProfileServiceLinkedIn as String)
                {
                    tempStr = "LinkedIn : "
                    
                    if myDecode[kABPersonSocialProfileUsernameKey as String] != nil
                    {
                        myLinkedInID = myDecode[kABPersonSocialProfileUsernameKey as String]! as! String
                    }
                    else
                    {
                        myLinkedInID = myDecode[kABPersonSocialProfileURLKey as String]! as! String
                    }
                }
                
                if myServiceName == (kABPersonSocialProfileServiceFlickr as String)
                {
                    tempStr = "Flickr : "
                }
                
                if tempStr != ""
                {
                    if myDecode[kABPersonSocialProfileUsernameKey as String] != nil
                    {
                        strHolder = myDecode[kABPersonSocialProfileUsernameKey as String]! as! String
                    }
                    else
                    {
                        strHolder = myDecode[kABPersonSocialProfileURLKey as String]! as! String
                    }

                    writeRowToArray(tempStr + strHolder, inTable: &tableContents)
                }
                
                loopcount++
            }
            
        case kABPersonURLProperty:
            let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonURLProperty).takeUnretainedValue() as ABMultiValueRef
            
            let recordCount = ABMultiValueGetCount(decodeProperty)
            
            
            if recordCount > 0
            {
                for loopCount in 0...recordCount-1
                {
                    switch loopCount
                    {
                    case 0: writeRowToArray("Home Page = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String), inTable: &tableContents)
                        
                        
                    default:  // Do nothing
                        writeRowToArray("Unknown home page = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String), inTable: &tableContents)
                    }
                }
            }
            
        case kABPersonBirthdayProperty:
            // need to make sure there is something there for birthday
            
            let decodePart1 = ABRecordCopyValue(contactRecord, kABPersonBirthdayProperty)
            
            if decodePart1 != nil
            {
                
                let decodeProperty : NSDate = ABRecordCopyValue(contactRecord, kABPersonBirthdayProperty).takeUnretainedValue() as! NSDate
                
                let initialDate: NSDate = decodeProperty as NSDate
                
                let dateFormatter = NSDateFormatter()
                
                let dateFormat = NSDateFormatterStyle.ShortStyle
                
                dateFormatter.dateStyle = dateFormat
                
                let dateString = dateFormatter.stringFromDate(initialDate)
                
                writeRowToArray("Birthday = " + dateString, inTable: &tableContents)
            }
            
        case kABPersonFirstNameProperty:
            
            
            let prefix = ABRecordCopyValue(contactRecord, kABPersonPrefixProperty)
            let firstName = ABRecordCopyValue(contactRecord, kABPersonFirstNameProperty)
            let lastName = ABRecordCopyValue(contactRecord, kABPersonLastNameProperty)
            let suffix = ABRecordCopyValue(contactRecord, kABPersonSuffixProperty)
            
            var fullname: String = ""
            
            var initialSpaceAdd: Bool = false
            
            if prefix != nil
            {
                fullname += prefix.takeRetainedValue() as! String
                initialSpaceAdd = true
            }
            
            if firstName != nil
            {
                if initialSpaceAdd
                {
                    fullname += " "
                }
                fullname += firstName.takeRetainedValue() as! String
                initialSpaceAdd = true
            }
            
            if lastName != nil
            {
                if initialSpaceAdd
                {
                    fullname += " "
                }
                fullname += lastName.takeRetainedValue() as! String
            }
            
            if suffix != nil
            {
                if initialSpaceAdd
                {
                    fullname += " "
                }
                fullname += suffix.takeRetainedValue() as! String
            }
            
            writeRowToArray(rowDescription + ": " + fullname, inTable: &tableContents)
            
            
        default:        if  ABRecordCopyValue(contactRecord, rowType) == nil
        {
            // Do nothing
        }
        else
        {
            
            let firstName = ABRecordCopyValue(contactRecord, rowType)
            
            let fn = (firstName.takeRetainedValue() as? String) ?? ""
            
            writeRowToArray(rowDescription + ": " + fn, inTable: &tableContents)
            
            }
        }
    }

    
   
    
    
}

func findPersonRecord(inName: String) -> ABRecord!
{
    //  there may be a better way to do this, but it works.
    var person: ABRecord!

    let contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(adbk).takeRetainedValue()
    
    for record:ABRecordRef in contactList
    {
        let contactPerson: ABRecordRef = record
        let contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as String

        if contactName == inName
        {
            // we have found the record
            person = record
            break
        }
    }
    
    return person
}

func findPersonbyEmail(inEmail: String) -> ABRecord!
{
    //  there may be a better way to do this, but it works.
    var person: ABRecord!
    var recordFound: Bool = false
    let contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(adbk).takeRetainedValue()
    
    for record:ABRecordRef in contactList
    {
        let contactPerson: ABRecordRef = record
        
        let decodeProperty = ABRecordCopyValue(contactPerson, kABPersonEmailProperty)
        let emailAddrs: ABMultiValueRef = Unmanaged.fromOpaque(decodeProperty.toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
        
        let recordCount = ABMultiValueGetCount(emailAddrs)
        var myString: String = ""
        
        if recordCount > 0
        {
            for loopCount in 0...recordCount-1
            {
                myString = ABMultiValueCopyValueAtIndex(emailAddrs, loopCount).takeRetainedValue() as! String
                
                if myString == inEmail
                {
                    person = record
                    recordFound = true
                    break
                }
            }
        }

        if recordFound
        {
            break
        }
    }

    return person
}

/*
func decodePhone(decodeType: String, decodeProperty: ABMultiValueRef, inComingType: CFString, inout tableContents: [TableData])
{
    var myIndex: Int = inComingType.toInt()!
    
    if ABMultiValueCopyValueAtIndex(decodeProperty,myIndex) != nil
    {
        var myPhone = ABMultiValueCopyValueAtIndex(decodeProperty,myIndex).takeRetainedValue() as! String
    
        if myPhone != ""
        {
            writeRowToArray(decodeType + " = " + myPhone, &tableContents)
        }
    }
}
*/


/*
func getEmailAddress (contactRecord: ABRecord)-> [String]
{
    
    var tableContents:[String] = [String]()
    
    let decodeProperty = ABRecordCopyValue(contactRecord, kABPersonEmailProperty)
    let emailAddrs: ABMultiValueRef = Unmanaged.fromOpaque(decodeProperty.toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
    
    let recordCount = ABMultiValueGetCount(emailAddrs)
    var myType: CFString!
    var myString: String = ""
    
    if recordCount > 0
    {
        for loopCount in 0...recordCount-1
        {
            myString = ABMultiValueCopyValueAtIndex(emailAddrs, loopCount).takeRetainedValue() as! String
            
            tableContents.append(myString)
        }
    }

    return tableContents
}

*/

