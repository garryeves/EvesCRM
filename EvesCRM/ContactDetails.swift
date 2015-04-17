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



func parseContactDetails (contactRecord: ABRecord)
{

    for (itemDescription, itemKey) in contactComponentsProperty
    {
        addToContactDetailTable (contactRecord, itemDescription, itemKey)
    }
 
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
                println("Address : \(line1) \(line2) \(line3) \(line4)")
                
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
                    
                                println("Anniversary = \(dateString)")
                    
                        default:  // Do nothing
                                println("Unknown date = \(dateString)")
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
                    case 0: println("Mobile = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")

                    case 1: println("iPhone = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")

                    case 2: println("Main = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")

                    case 3: println("Home Fax = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")

                    case 4: println("Work Fax = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")

                    case 5: println("Other Fax = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")

                    case 6: println("Pager = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                
                    default:  // Do nothing
                    println("Unknown phone = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
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
                case 0: println("Email = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                
                case 1: println("Email = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                
                case 2: println("Email = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                
                case 3: println("Email = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                
                case 4: println("Email = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                
                case 5: println("Email = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                
                case 6: println("Email = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                
                default:  // Do nothing
                println("Unknown Email = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                }
            }
        }
        
    case kABPersonInstantMessageProperty:
        let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonInstantMessageProperty).takeUnretainedValue() as ABMultiValueRef
        
        if ABMultiValueGetCount(decodeProperty) > 0
        {
            
            let decode: NSDictionary = ABMultiValueCopyValueAtIndex(decodeProperty,0).takeRetainedValue() as! NSDictionary
            
            if decode.count > 0
            {
                
                if decode[kABPersonInstantMessageServiceYahoo as String]?.length > 0
                {
                    println("Yahoo : \(decode[kABPersonInstantMessageServiceYahoo as String])")
                }
                if decode[kABPersonInstantMessageServiceJabber as String]?.length > 0
                {
                    println("Jabber : \(decode[kABPersonInstantMessageServiceJabber as String])")
                }
                if decode[kABPersonInstantMessageServiceMSN as String]?.length > 0
                {
                    println("MSN : \(decode[kABPersonInstantMessageServiceMSN as String])")
                }
                if decode[kABPersonInstantMessageServiceICQ as String]?.length > 0
                {
                    println("ICQ : \(decode[kABPersonInstantMessageServiceICQ as String])")
                }
                if decode[kABPersonInstantMessageServiceAIM as String]?.length > 0
                {
                    println("AIM : \(decode[kABPersonInstantMessageServiceAIM as String])")
                }
                if decode[kABPersonInstantMessageServiceQQ as String]?.length > 0
                {
                    println("QQ : \(decode[kABPersonInstantMessageServiceQQ as String])")
                }
                if decode[kABPersonInstantMessageServiceGoogleTalk as String]?.length > 0
                {
                    println("Google Talk : \(decode[kABPersonInstantMessageServiceGoogleTalk as String])")
                }
                if decode[kABPersonInstantMessageServiceSkype as String]?.length > 0
                {
                    println("Skype : \(decode[kABPersonInstantMessageServiceSkype as String])")
                }
                if decode[kABPersonInstantMessageServiceFacebook as String]?.length > 0
                {
                    println("Facebook IM : \(decode[kABPersonInstantMessageServiceFacebook as String])")
                }
                if decode[kABPersonInstantMessageServiceGaduGadu as String]?.length > 0
                {
                    println("GaduGadu : \(decode[kABPersonInstantMessageServiceGaduGadu as String])")
                }
            }
        }
        
    case kABPersonSocialProfileProperty:
        let decodeProperty : ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonSocialProfileProperty).takeUnretainedValue() as ABMultiValueRef
        
        if ABMultiValueGetCount(decodeProperty) > 0
        {
            
            let decode: NSDictionary = ABMultiValueCopyValueAtIndex(decodeProperty,0).takeRetainedValue() as! NSDictionary
            
            if decode.count > 0
            {
                
                if decode[kABPersonSocialProfileServiceTwitter as String]?.length > 0
                {
                    println("Twitter : \(decode[kABPersonSocialProfileUsernameKey as String])")
                }
                if decode[kABPersonSocialProfileServiceGameCenter as String]?.length > 0
                {
                    println("Game Center : \(decode[kABPersonSocialProfileUsernameKey as String])")
                }
                if decode[kABPersonSocialProfileServiceSinaWeibo as String]?.length > 0
                {
                    println("Sina Weibo : \(decode[kABPersonSocialProfileUsernameKey as String])")
                }
                if decode[kABPersonSocialProfileServiceFacebook as String]?.length > 0
                {
                    println("Facebook : \(decode[kABPersonSocialProfileUsernameKey as String])")
                }
                if decode[kABPersonSocialProfileServiceMyspace as String]?.length > 0
                {
                    println("Myspace : \(decode[kABPersonSocialProfileUsernameKey as String])")
                }
                if decode[kABPersonSocialProfileServiceLinkedIn as String]?.length > 0
                {
                    println("LinkedIn : \(decode[kABPersonSocialProfileUsernameKey as String])")
                }
                if decode[kABPersonSocialProfileServiceFlickr as String]?.length > 0
                {
                    println("Flickr : \(decode[kABPersonSocialProfileUsernameKey as String])")
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
                case 0: println("Home Page = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                    
 
                default:  // Do nothing
                    println("Unknown home page = \(ABMultiValueCopyValueAtIndex(decodeProperty,loopCount).takeRetainedValue())")
                }
            }
        }
        
    default:        if  ABRecordCopyValue(contactRecord, rowType) == nil
                    {
                                // Do nothing
                    }
                    else
                    {
        
                            let firstName = ABRecordCopyValue(contactRecord, rowType)
        
                            let fn = (firstName.takeRetainedValue() as? String) ?? ""
                        
                            println("\(rowDescription): \(fn)")
        
                    }
    }

    
}