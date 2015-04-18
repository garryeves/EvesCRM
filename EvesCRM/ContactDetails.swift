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


var contactComponentsProperty: [String: ABPropertyID] = [
    "Prefix":
    kABPersonPrefixProperty,
    "Suffix":
    kABPersonSuffixProperty,
    "Nickname":
    kABPersonNicknameProperty,
    "Organisation":
    kABPersonOrganizationProperty,
    "Job Title":
    kABPersonJobTitleProperty,
    "Dept":
    kABPersonDepartmentProperty,
    "Email":
    kABPersonEmailProperty,
    "Birthday":
    kABPersonBirthdayProperty,
    "Note":
    kABPersonNoteProperty,
    "Address Prop":
    kABPersonAddressProperty,
    "DOB":
    kABPersonDateProperty,
    "Phone":
    kABPersonPhoneProperty,
    "IM":
    kABPersonInstantMessageProperty,
    "Social Media":
    kABPersonSocialProfileProperty,
    "Home Page":
    kABPersonURLProperty
]

    var tableContents:[String] = [" "]


func parseContactDetails (contactRecord: ABRecord)-> [String]
{

    tableContents.removeAll()

    for (itemDescription, itemKey) in contactComponentsProperty
    {
        addToContactDetailTable (contactRecord, itemDescription, itemKey)
    }
    
    return tableContents
 
}

func addToContactDetailTable (contactRecord: ABRecord, rowDescription: String, rowType: ABPropertyID)
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
                writeRowToArray("Address : " + line1 + " " + line2 + " " + line3 + " " + line4)
                
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
                    
                                writeRowToArray("Anniversary = " + dateString)
                    
                        default:  // Do nothing
                                writeRowToArray("Unknown date = " + dateString)
                    }
                }
            }
        }
       
 
    case kABPersonPhoneProperty:
        let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValueRef
    
        let recordCount = ABMultiValueGetCount(decodeProperty)

        
        if recordCount > 0
        {
            for loopCount in 0...recordCount-1
            {
                switch loopCount
                {
                    case 0: writeRowToArray("Mobile = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))

                    case 1: writeRowToArray("iPhone = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))

                    case 2: writeRowToArray("Main = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))

                    case 3: writeRowToArray("Home Fax = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))

                    case 4: writeRowToArray("Work Fax = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))

                    case 5: writeRowToArray("Other Fax = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))

                    case 6: writeRowToArray("Pager = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                
                    default:  // Do nothing
                    writeRowToArray("Unknown phone = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                }
            }
        }

    case kABPersonEmailProperty:
        let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonEmailProperty).takeUnretainedValue() as ABMultiValueRef
        
        let recordCount = ABMultiValueGetCount(decodeProperty)
        
        if recordCount > 0
        {
            for loopCount in 0...recordCount-1
            {
                switch loopCount
                {
                case 0: writeRowToArray("Email = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                
                case 1: writeRowToArray("Email = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                
                case 2: writeRowToArray("Email = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                
                case 3: writeRowToArray("Email = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                
                case 4: writeRowToArray("Email = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                
                case 5: writeRowToArray("Email = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                
                case 6: writeRowToArray("Email = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                
                default:  // Do nothing
                writeRowToArray("Unknown Email = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                }
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
                    writeRowToArray("Yahoo : " + strHolder)
                }
                if decode[kABPersonInstantMessageServiceJabber as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceJabber as  String]! as! String
                    writeRowToArray("Jabber : " + strHolder )
                }
                if decode[kABPersonInstantMessageServiceMSN as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceMSN as String]! as! String
                    writeRowToArray("MSN : " + strHolder)
                }
                if decode[kABPersonInstantMessageServiceICQ as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceICQ as String]! as! String
                    writeRowToArray("ICQ : " + strHolder)
                }
                if decode[kABPersonInstantMessageServiceAIM as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceAIM as String]! as! String
                    writeRowToArray("AIM : " + strHolder)
                }
                if decode[kABPersonInstantMessageServiceQQ as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceQQ as String]! as! String
                    writeRowToArray("QQ : " + strHolder)
                }
                if decode[kABPersonInstantMessageServiceGoogleTalk as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceGoogleTalk as String]! as! String
                    writeRowToArray("Google Talk : " + strHolder)
                }
                if decode[kABPersonInstantMessageServiceSkype as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceSkype as String]! as! String
                    writeRowToArray("Skype : " + strHolder)
                }
                if decode[kABPersonInstantMessageServiceFacebook as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceFacebook as String]! as! String
                    writeRowToArray("Facebook IM : " + strHolder )
                }
                if decode[kABPersonInstantMessageServiceGaduGadu as String]?.length > 0
                {
                    strHolder = decode[kABPersonInstantMessageServiceGaduGadu as String]! as! String
                    writeRowToArray("GaduGadu : " + strHolder)
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
                    writeRowToArray("Twitter : " + strHolder)
                }
                if decode[kABPersonSocialProfileServiceGameCenter as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Game Center : " + strHolder)
                }
                if decode[kABPersonSocialProfileServiceSinaWeibo as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Sina Weibo : " + strHolder)
                }
                if decode[kABPersonSocialProfileServiceFacebook as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Facebook : " + strHolder)
                }
                if decode[kABPersonSocialProfileServiceMyspace as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Myspace : " + strHolder)
                }
                if decode[kABPersonSocialProfileServiceLinkedIn as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("LinkedIn : " + strHolder)
                }
                if decode[kABPersonSocialProfileServiceFlickr as String]?.length > 0
                {
                    strHolder = decode[kABPersonSocialProfileUsernameKey as String]! as! String
                    writeRowToArray("Flickr : " + strHolder)
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
                case 0: writeRowToArray("Home Page = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
                    
 
                default:  // Do nothing
                    writeRowToArray("Unknown home page = " + (ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue() as! String))
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
                
            writeRowToArray("Birthday = " + dateString)
        }
    
    default:        if  ABRecordCopyValue(contactRecord, rowType) == nil
                    {
                                // Do nothing
                    }
                    else
                    {
        
                            let firstName = ABRecordCopyValue(contactRecord, rowType)
        
                            let fn = (firstName.takeRetainedValue() as? String) ?? ""
                        
                            writeRowToArray(rowDescription + ": " + fn)
        
                    }
    }

    
}


func writeRowToArray(inStr: String)
{
        tableContents.append(inStr)
}