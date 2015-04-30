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


func parseContactDetails (contactRecord: ABRecord)-> [TableData]
{

    var tableContents:[TableData] = [TableData]()

    tableContents.removeAll()

    addToContactDetailTable (contactRecord, "Name", kABPersonFirstNameProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Address", kABPersonAddressProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Organisation", kABPersonOrganizationProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Job Title", kABPersonJobTitleProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Dept", kABPersonDepartmentProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Phone", kABPersonPhoneProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Email", kABPersonEmailProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Note", kABPersonNoteProperty, &tableContents)
    addToContactDetailTable (contactRecord, "DOB", kABPersonDateProperty, &tableContents)
    addToContactDetailTable (contactRecord, "IM", kABPersonInstantMessageProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Social Media", kABPersonSocialProfileProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Home Page", kABPersonURLProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Birthday", kABPersonBirthdayProperty, &tableContents)
    addToContactDetailTable (contactRecord, "Nickname", kABPersonNicknameProperty, &tableContents)
    
    return tableContents
}

func addToContactDetailTable (contactRecord: ABRecord, rowDescription: String, rowType: ABPropertyID, inout tableContents: [TableData])
{
    var line1:String = ""
    var line2:String = ""
    var line3:String = ""
    var line4:String = ""
    
    switch rowType
    {
    case kABPersonAddressProperty:
        let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonAddressProperty).takeUnretainedValue() as ABMultiValueRef
        
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
                
                writeRowToArray("Address : \(line1)\n\(line2)\n\(line3)\n\(line4)", &tableContents)
                
            }
        }
 
    case kABPersonDateProperty:
        let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonDateProperty).takeUnretainedValue() as ABMultiValueRef
        
        if ABMultiValueGetCount(decodeProperty) > 0
        {
            let decode: NSDate = ABMultiValueCopyValueAtIndex(decodeProperty,0).takeRetainedValue() as! NSDate
            let recordCount = ABMultiValueGetCount(decodeProperty)

            
            if recordCount > 0
            {
                for loopCount in 0...recordCount-1
                {
                    let initialDate: NSDate = ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! NSDate
                    
                    var dateFormatter = NSDateFormatter()
                
                    var dateFormat = NSDateFormatterStyle.ShortStyle
                
                    dateFormatter.dateStyle = dateFormat
                
                    var dateString = dateFormatter.stringFromDate(initialDate)
                
                    switch loopCount
                    {
                        case 0:
                    
                                writeRowToArray("Anniversary = " + dateString, &tableContents)
                    
                        default:  // Do nothing
                                writeRowToArray("Unknown date = " + dateString, &tableContents)
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
            
            writeRowToArray(myString, &tableContents)
        }

    case kABPersonEmailProperty:
        let decodeProperty = ABRecordCopyValue(contactRecord, kABPersonEmailProperty)
        let emailAddrs: ABMultiValueRef = Unmanaged.fromOpaque(decodeProperty.toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
        
        let recordCount = ABMultiValueGetCount(emailAddrs)
        var myType: CFString!
        var myString: String = ""
            
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
                
                writeRowToArray(myString, &tableContents)
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
                    writeRowToArray("Yahoo : " + strHolder, &tableContents)
                }
                if decode[kABPersonInstantMessageServiceJabber as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceJabber as  String]! as! String
                    writeRowToArray("Jabber : " + strHolder, &tableContents )
                }
                if decode[kABPersonInstantMessageServiceMSN as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceMSN as String]! as! String
                    writeRowToArray("MSN : " + strHolder, &tableContents)
                }
                if decode[kABPersonInstantMessageServiceICQ as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceICQ as String]! as! String
                    writeRowToArray("ICQ : " + strHolder, &tableContents)
                }
                if decode[kABPersonInstantMessageServiceAIM as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceAIM as String]! as! String
                    writeRowToArray("AIM : " + strHolder, &tableContents)
                }
                if decode[kABPersonInstantMessageServiceQQ as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceQQ as String]! as! String
                    writeRowToArray("QQ : " + strHolder, &tableContents)
                }
                if decode[kABPersonInstantMessageServiceGoogleTalk as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceGoogleTalk as String]! as! String
                    writeRowToArray("Google Talk : " + strHolder, &tableContents)
                }
                if decode[kABPersonInstantMessageServiceSkype as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceSkype as String]! as! String
                    writeRowToArray("Skype : " + strHolder, &tableContents)
                }
                if decode[kABPersonInstantMessageServiceFacebook as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceFacebook as String]! as! String
                    writeRowToArray("Facebook IM : " + strHolder, &tableContents )
                }
                if decode[kABPersonInstantMessageServiceGaduGadu as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceGaduGadu as String]! as! String
                    writeRowToArray("GaduGadu : " + strHolder, &tableContents)
                }
            }
        }
        
    case kABPersonSocialProfileProperty:
        
        var strHolder :String = ""
        
        let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonSocialProfileProperty).takeUnretainedValue() as ABMultiValueRef
        
        if ABMultiValueGetCount(decodeProperty) > 0
        {
            
            let decode: NSDictionary = ABMultiValueCopyValueAtIndex(decodeProperty,0).takeRetainedValue() as! NSDictionary
            
            if decode.count > 0
            {
                
                if decode[kABPersonSocialProfileServiceTwitter as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Twitter : " + strHolder, &tableContents)
                }
                if decode[kABPersonSocialProfileServiceGameCenter as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Game Center : " + strHolder, &tableContents)
                }
                if decode[kABPersonSocialProfileServiceSinaWeibo as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Sina Weibo : " + strHolder, &tableContents)
                }
                if decode[kABPersonSocialProfileServiceFacebook as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Facebook : " + strHolder, &tableContents)
                }
                if decode[kABPersonSocialProfileServiceMyspace as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Myspace : " + strHolder, &tableContents)
                }
                if decode[kABPersonSocialProfileServiceLinkedIn as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("LinkedIn : " + strHolder, &tableContents)
                }
                if decode[kABPersonSocialProfileServiceFlickr as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Flickr : " + strHolder, &tableContents)
                }
            }
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
                case 0: writeRowToArray("Home Page = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String), &tableContents)
                    
 
                default:  // Do nothing
                    writeRowToArray("Unknown home page = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String), &tableContents)
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
                
            var dateFormatter = NSDateFormatter()
                
            var dateFormat = NSDateFormatterStyle.ShortStyle
                
            dateFormatter.dateStyle = dateFormat
                
            var dateString = dateFormatter.stringFromDate(initialDate)
                
            writeRowToArray("Birthday = " + dateString, &tableContents)
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
        
        writeRowToArray(rowDescription + ": " + fullname, &tableContents)
        
    
    default:        if  ABRecordCopyValue(contactRecord, rowType) == nil
                    {
                                // Do nothing
                    }
                    else
                    {
        
                            let firstName = ABRecordCopyValue(contactRecord, rowType)
        
                            let fn = (firstName.takeRetainedValue() as? String) ?? ""
                        
                            writeRowToArray(rowDescription + ": " + fn, &tableContents)
        
                    }
    }
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

