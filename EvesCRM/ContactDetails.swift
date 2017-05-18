//
//  ContactDetails.swift
//  EvesCRM
//
//  Created by Garry Eves on 16/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

//This file is used to populate Contact details table

import Foundation
import Contacts
    
let contactDataArray = [
      CNContactNamePrefixKey,
      CNContactGivenNameKey,
      CNContactMiddleNameKey,
      CNContactFamilyNameKey,
      CNContactPreviousFamilyNameKey,
      CNContactNameSuffixKey,
      CNContactNicknameKey,
      CNContactOrganizationNameKey,
      CNContactDepartmentNameKey,
      CNContactJobTitleKey,
      CNContactBirthdayKey,
      CNContactNoteKey,
      CNContactTypeKey,
      CNContactPhoneNumbersKey,
      CNContactEmailAddressesKey,
      CNContactPostalAddressesKey,
      CNContactDatesKey,
      CNContactUrlAddressesKey,
      CNContactRelationsKey,
      CNContactSocialProfilesKey,
      CNContactInstantMessageAddressesKey,
      CNContactPhoneticGivenNameKey,
      CNContactPhoneticMiddleNameKey,
      CNContactPhoneticFamilyNameKey,
      CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
    ] as [Any]


struct PeopleData
{
    var fullName: String
    fileprivate var myDisplayFormat: String
    var personRecord: CNContact
    
    var displaySpecialFormat: String
    {
        get {
            return myDisplayFormat
        }
        set {
            myDisplayFormat = newValue
        }
    }
    
    init(fullName: String, record: CNContact)
    {
        self.fullName = fullName
        self.myDisplayFormat = ""
        self.personRecord = record
    }
}

struct addressStruct
{
    var type: String
    var line1: String
    var line2: String
    var city: String
    var state: String
    var country: String
    var postcode: String
}

struct contactStruct
{
    var type: String
    var detail: String
}

class iOSContact
{
    fileprivate var myContactRecord: CNContact!
    
    var contactRecord: CNContact
    {
        get
        {
            return myContactRecord
        }
    }
    
    var fullName: String
    {
        get
        {
            return CNContactFormatter.string(from: contactRecord, style: CNContactFormatterStyle.fullName)!
        }
    }
    
    var addresses: [addressStruct]
    {
        get
        {
            var workingArray: [addressStruct] = Array()
            
            for myAddress in myContactRecord.postalAddresses
            {
                if myAddress.label != nil
                {
                    var myType: String = ""
                    switch myAddress.label!
                    {
                        case CNLabelHome :
                            myType = "Home"
                            
                        case CNLabelWork :
                            myType = "Office"
                        
                        case CNLabelOther :
                            myType = "Other"
                            
                        default :
                            myType = "Unknown Address : \(myAddress.label!) : "
                    }
                    
                    let myAddressValue = myAddress.value
                    let tempItem = addressStruct(type: myType,
                                                 line1: myAddressValue.street,
                                                 line2: "",
                                                 city: myAddressValue.city,
                                                 state: myAddressValue.state,
                                                 country: myAddressValue.country,
                                                 postcode: myAddressValue.postalCode)
                    
                    workingArray.append(tempItem)
                }
            }
            return workingArray
        }
    }
    
    var phoneNumbers: [contactStruct]
    {
        get
        {
            var workingArray: [contactStruct] = Array()
            
            for myPhone in myContactRecord.phoneNumbers
            {
                var myType: String = ""
                
                if myPhone.label != nil
                {
                    switch myPhone.label!
                    {
                    case CNLabelHome :
                        myType = "Home Phone"
                        
                    case CNLabelWork :
                        myType = "Office Phone"
                        
                    case CNLabelOther :
                        myType = "Other Phone"
                        
                    case CNLabelPhoneNumberiPhone :
                        myType = "Mobile Phone"
                        
                    case CNLabelPhoneNumberMobile :
                        myType = "Mobile Phone"
                        
                    case CNLabelPhoneNumberMain :
                        myType = "Main Phone"
                        
                    case CNLabelPhoneNumberHomeFax :
                        myType = "Home Fax"
                        
                    case CNLabelPhoneNumberWorkFax :
                        myType = "Work Fax"
                        
                    case CNLabelPhoneNumberOtherFax :
                        myType = "Other Fax"
                        
                    case CNLabelPhoneNumberPager :
                        myType = "Pager"
                        
                    default :
                        myType = "Unknown phone number : \(myPhone.label!) : "
                    }
                    
                    let myPhoneValue = myPhone.value
                    let tempItem = contactStruct(type: myType,
                                                 detail: myPhoneValue.stringValue)
                    
                    workingArray.append(tempItem)
                }
            }
            return workingArray
        }
    }
    
    var emailAddresses: [contactStruct]
    {
        get
        {
            var workingArray: [contactStruct] = Array()
            
            for myEmail in myContactRecord.emailAddresses
            {
                if myEmail.label != nil
                {
                    var myType: String = ""
                        
                    switch myEmail.label!
                    {
                        case CNLabelEmailiCloud :
                            myType = "Home Email"
                            
                        case CNLabelHome :
                            myType = "Home Email"
                            
                        case CNLabelWork :
                            myType = "Office Email"
                            
                        case CNLabelOther :
                            myType = "Other Email"
                            
                        default :
                            myType = "Unknown email address : \(myEmail.label!) : "
                    }
            
                    let myEmailValue = myEmail.value as String
                    let tempItem = contactStruct(type: myType,
                                                 detail: myEmailValue)
                    workingArray.append(tempItem)
                }
            }
            return workingArray
        }
    }

    var dateOfBirth: Date?
    {
        get
        {
            if myContactRecord.birthday?.date != nil
            {
                return myContactRecord.birthday?.date
            }
            else
            {
                return nil
            }
        }
    }
    
    var dateOfBirthString: String
    {
        get
        {
            if myContactRecord.birthday?.date != nil
            {
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateStyle = .short
                
                return myDateFormatter.string(from: myContactRecord.birthday!.date!)
            }
            else
            {
                return ""
            }
        }
    }
    
    var instantMessageAccounts: [contactStruct]
    {
        get
        {
            var workingArray: [contactStruct] = Array()
            
            for myIM in myContactRecord.instantMessageAddresses
            {
                var myType: String = ""
                
                switch myIM.value.service
                {
                    case CNInstantMessageServiceAIM :
                        myType = "AIM"
                        
                    case CNInstantMessageServiceFacebook :
                        myType = "Facebook"
                        
                    case CNInstantMessageServiceGaduGadu :
                        myType = "GaduGadu"
                        
                    case CNInstantMessageServiceGoogleTalk :
                        myType = "Google Talk"
                        
                    case CNInstantMessageServiceICQ :
                        myType = "ICQ"
                        
                    case CNInstantMessageServiceJabber :
                        myType = "Jabber"
                        
                    case CNInstantMessageServiceMSN :
                        myType = "MSN"
                        
                    case CNInstantMessageServiceQQ :
                        myType = "QQ"
                        
                    case CNInstantMessageServiceSkype :
                        myType = "SkyPE"
                        
                    case CNInstantMessageServiceYahoo :
                        myType = "Yahoo"
                        
                    default :
                        myType = "Unknown IM address : \(myIM.label!) : "
                }
                
                let myIMValue = myIM.value 

                let tempItem = contactStruct(type: myType,
                                             detail: myIMValue.username)
                workingArray.append(tempItem)
            }
            return workingArray
        }
    }
    
    var socialProfiles: [contactStruct]
    {
        get
        {
            var workingArray: [contactStruct] = Array()

            for mySocial in myContactRecord.socialProfiles
            {
                var myType: String = ""
                
                switch mySocial.value.service
                {
                    case CNSocialProfileServiceFacebook:
                        myType = "Facebook"
                        
                    case CNSocialProfileServiceFlickr:
                        myType = "Flickr"
                        
                    case CNSocialProfileServiceLinkedIn:
                        myType = "LinkedIN"
                        
                    case CNSocialProfileServiceMySpace:
                        myType = "MySpace"
                        
                    case CNSocialProfileServiceSinaWeibo:
                        myType = "Sina Weibo"
                        
                    case CNSocialProfileServiceTencentWeibo:
                        myType = "Tencent Weibo"
                        
                    case CNSocialProfileServiceTwitter:
                        myType = "Twitter"
                        
                    case CNSocialProfileServiceYelp:
                        myType = "Yelp"
                        
                    case CNSocialProfileServiceGameCenter :
                        myType = "GameCenter"
                        
                    default:
                        myType = "Unknown Social address : \(mySocial.value.service) : "
                }
                
                let mySocialValue = mySocial.value
                
                let tempItem = contactStruct(type: myType,
                                             detail: mySocialValue.username)
                workingArray.append(tempItem)
            }
            return workingArray
        }
    }
    
    var websites: [contactStruct]
    {
        get
        {
            var workingArray: [contactStruct] = Array()

            for mySocial in myContactRecord.socialProfiles
            {
                var myType: String = ""
                
                for myURL in myContactRecord.urlAddresses
                {
                    if myURL.label != nil
                    {
                        switch myURL.label!
                        {
                            case CNLabelURLAddressHomePage :
                                myType = "Home Page"
                                
                            default :
                                myType = "Unknown URL address : \(myURL.label!) : "
                        }
    
                        let myURLValue = mySocial.value
                        
                        let tempItem = contactStruct(type: myType,
                                                     detail: myURLValue.urlString)
                        workingArray.append(tempItem)
                    }
                }
            }
            return workingArray
        }
    }

    init (contactRecord: CNContact)
    {
        myContactRecord = contactRecord
    }
}

class addressBookClass: NSObject
{
    fileprivate var adbk: CNContactStore!
    fileprivate var currentContact: iOSContact!
    
    func findPersonRecordByID(_ recordID: String)
    {
        var person: CNContact!
        
        //  there may be a better way to do this, but it works.
        do
        {
            let myPeople = try adbk.unifiedContacts(matching: CNContact.predicateForContacts(withIdentifiers: [recordID]), keysToFetch: contactDataArray as! [CNKeyDescriptor])
            
            if myPeople.count > 0
            {
                person = myPeople[0]
            }
        }
        catch let error as NSError
        {
            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            print("Failure to save context: \(error)")
        }
        
        currentContact = iOSContact(contactRecord: person)
    }

    func findPersonRecord(_ name: String)
    {
        var person: CNContact!

        //  there may be a better way to do this, but it works.
        do
        {
            let myPeople = try adbk.unifiedContacts(matching: CNContact.predicateForContacts(matchingName: name), keysToFetch: contactDataArray as! [CNKeyDescriptor])
            
            if myPeople.count > 0
            {
                person = myPeople[0]
            }
        }
        catch let error as NSError
        {
            NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
            
            print("Failure to save context: \(error)")
        }
        
        currentContact = iOSContact(contactRecord: person)
    }

    func findPersonbyEmail(_ searchEmail: String)
    {
        //  there may be a better way to do this, but it works.
        var person: CNContact!
        
        let fetch = CNContactFetchRequest(keysToFetch: contactDataArray as! [CNKeyDescriptor])
        fetch.unifyResults = true
        fetch.predicate = nil // Set this to nil will give you all Contacts
        do
        {
            _ = try adbk.enumerateContacts(with: fetch, usingBlock:
                    {
                        contact, cursor in
                        // Do something with the result...for example put it in an array of CNContacts as shown below
                        let theContact = contact as CNContact
                        
                        for myEmail in contact.emailAddresses
                        {
                            if myEmail.value as String == searchEmail
                            {
                                person = theContact
                                break
                            }
                        }
                    })
            
        }
        catch
        {
            print("Error")
        }

        currentContact = iOSContact(contactRecord: person)
    }
        
    func createAddressBook() -> Bool
    {
        if adbk != nil
        {
            return true
        }
        
        let sem = DispatchSemaphore(value: 0)

        let myAdbk = CNContactStore()
        myAdbk.requestAccess(for: CNEntityType.contacts) { (isGranted, error) in

            sem.signal()
        }
        
        sem.wait()

        adbk = myAdbk
            
        return true
    }
        
    func determineAddressBookStatus() -> Bool
    {
        var retVal: Bool = false
        
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus
        {
            case .authorized:
                retVal = true
            
            case .denied:
                retVal = false
            
            case .notDetermined:
                retVal = false
            
            default:
                retVal = false

        }
        
        return retVal
    }
}
